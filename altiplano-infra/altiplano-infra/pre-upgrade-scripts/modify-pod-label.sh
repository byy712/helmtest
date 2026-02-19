#!/bin/sh
RELEASE=$1
NAMESPACE="default"

usage(){
   echo "Script which needs to be run before upgarding nokia infra chart using 'helm upgrade -i nokia infra...' command"
   echo "Note: it is needed only for upgrading from 22.9 or below to 22.12 or above using helm upgrade command"
   echo "Usage: bash modify-pod-label.sh -r <INFRA_RELEASE_NAME> -n <namespace>"
   echo "Example:"
   echo "  bash modify-pod-label.sh -r nokia-infra -n my_namespace"
   echo ""
   echo "Note: In case namespace is not provided 'default' value will be used."
   exit 1
}

if [ -z $RELEASE ]; then usage
fi

while [[ $# -gt 0 ]]; do
 case $1 in
   -r|--release)
     RELEASE="$2"
     if [ -z $RELEASE ]; then
       usage
     fi
     shift # past argument
     shift # past value
     ;;
   -n|--namespace)
     NAMESPACE="$2"
     shift # past argument
     shift # past value
     ;;
   -h|--help)
     usage
     exit 1;
     ;;
   -*)
     echo "Unknown option $1"
     exit 1
     ;;
    *)
     echo "Unknown option $1"
     exit 1
 esac
done

WORKDIR=$(mktemp -d -t modify-pod-label-XXXX)
[ ! -d "${WORKDIR}" ] && echo "Failed to create temporary working directory" >&2 && exit 1

cleanup() {
  rm -rf "${WORKDIR}"
}

trap cleanup EXIT

MAX_POD_WAIT_RETRY=60
POD_WAIT_INTERVAL=3

# indexSearchData
indexSearchDataStsName=$RELEASE-altiplano-indexsearch-data
indexSearchDataRelease=$(kubectl get sts $indexSearchDataStsName -o jsonpath='{.metadata.labels.release}' 2>/dev/null)
if [ -z "$indexSearchDataRelease" ];then
  kubectl delete sts $indexSearchDataStsName -n $NAMESPACE
fi

# indexSearchManager
indexSearchManagerStsName=$RELEASE-altiplano-indexsearch-manager
indexSearchManagerRelease=$(kubectl get sts $indexSearchManagerStsName -o jsonpath='{.metadata.labels.release}' 2>/dev/null)
if [ -z "$indexSearchManagerRelease" ];then
  kubectl delete sts $indexSearchManagerStsName -n $NAMESPACE
fi

# indexSearchClient
indexSearchClientDeployName=$RELEASE-altiplano-indexsearch-client
indexSearchClientRelease=$(kubectl get deploy $indexSearchClientDeployName -o jsonpath='{.metadata.labels.release}' 2>/dev/null)
if [ -z "$indexSearchClientRelease" ];then
  kubectl delete deploy $indexSearchClientDeployName -n $NAMESPACE
fi

# indexSearchDashboards
indexSearchDashboardsDeployName=$RELEASE-altiplano-indexsearch-dashboards
indexSearchDashboardsRelease=$(kubectl get deploy $indexSearchDashboardsDeployName -o jsonpath='{.metadata.labels.release}' 2>/dev/null)
if [ -z "$indexSearchDashboardsRelease" ];then
  kubectl delete deploy $indexSearchDashboardsDeployName -n $NAMESPACE
fi

#altiplanoFluentdDs
altiplanoFluentdDsDsName=$(kubectl get ds -n $NAMESPACE | awk '/fluentd/ {print $1}')
altiplanoFluentdDsRelease=$(kubectl get ds $altiplanoFluentdDsDsName -o jsonpath='{.metadata.labels.release}' 2>/dev/null)
if [ -z "$altiplanoFluentdDsRelease" ];then
  kubectl delete ds $altiplanoFluentdDsDsName -n $NAMESPACE
fi

echo "Delete pods to add release name label completed"

# redis admin
redisAdminYaml=$WORKDIR/altiplano-redis-admin-tmp.yaml
redisStsName=$RELEASE-altiplano-redis-admin
kubectl get sts $redisStsName -n $NAMESPACE -o yaml > $redisAdminYaml
redisLabel=$(kubectl get sts $redisStsName  -o jsonpath='{.metadata.labels.altiplano-role}' 2>/dev/null)

if [ -s $redisAdminYaml ] && [ -z "$redisLabel" ]
then
  sed -i "/app: $RELEASE-altiplano-redis/s/\\( *\\)\\(app: $RELEASE-altiplano-redis\\)/\\1\\2\n\\1altiplano-role: internal-access/" $redisAdminYaml
  kubectl delete sts $redisStsName -n $NAMESPACE

  kubectl apply -f $redisAdminYaml -n $NAMESPACE

  for ((i=0; i < $MAX_POD_WAIT_RETRY; i++)); do
    ready_replicas=$(kubectl get sts $redisStsName -n $NAMESPACE -o jsonpath='{.status.readyReplicas}')
    desired_replicas=$(kubectl get sts $redisStsName -n $NAMESPACE -o jsonpath='{.spec.replicas}')
    if [ "$desired_replicas" == "$ready_replicas" ]; then
      echo "Statefulset $redisStsName has all replicas ready."
      rm -f $redisAdminYaml
      redisStarted=true
      break
    else
      echo "Statefulset $redisStsName is not fully ready yet. Waiting for 3 seconds..."
      sleep $POD_WAIT_INTERVAL
    fi
  done
  [ "$redisStarted" != "true" ] && echo "Statefulset $redisStsName is not ready after timeout" && exit 1
fi

# mariadb admin
mariaAdminYaml=$WORKDIR/altiplano-mariadb-admin-tmp.yaml
mariaAdminDeployName=$RELEASE-altiplano-mariadb-admin
kubectl get deploy $mariaAdminDeployName -n $NAMESPACE -o yaml > $mariaAdminYaml
mariadbLabel=$(kubectl get deploy $mariaAdminDeployName  -o jsonpath='{.metadata.labels.altiplano-role}' 2>/dev/null)

if [ -s $mariaAdminYaml ]  && [ -z "$mariadbLabel" ]
then
  sed -i "/app: $RELEASE-altiplano-mariadb/s/\\( *\\)\\(app: $RELEASE-altiplano-mariadb\\)/\\1\\2\n\\1altiplano-role: internal-access/" $mariaAdminYaml
  kubectl delete deploy $mariaAdminDeployName -n $NAMESPACE

  if kubectl get secret -n $NAMESPACE altiplano-secrets-all-certs -o=jsonpath='{.data}' | grep -q 'fluentd_is_username'; then
    kubectl apply -f $mariaAdminYaml -n $NAMESPACE

    desired_replicas=$(kubectl get deployment $mariaAdminDeployName -n $NAMESPACE -o jsonpath='{.spec.replicas}')
    ready_replicas=$(kubectl get deployment $mariaAdminDeployName -n $NAMESPACE -o jsonpath='{.status.readyReplicas}')

    for ((i=0; i < $MAX_POD_WAIT_RETRY; i++)); do
      ready_replicas=$(kubectl get deployment $mariaAdminDeployName -n $NAMESPACE -o jsonpath='{.status.readyReplicas}')
      desired_replicas=$(kubectl get deployment $mariaAdminDeployName -n $NAMESPACE -o jsonpath='{.spec.replicas}')
      if [ "$desired_replicas" == "$ready_replicas" ]; then
        echo "Deployment $mariaAdminDeployName has all replicas ready."
        rm -f $mariaAdminYaml
        mariadbStarted=true
        break
      else
        echo "Deployment $mariaAdminDeployName is not fully ready yet. Waiting for 3 seconds..."
        sleep $POD_WAIT_INTERVAL
      fi
    done

    [ "$mariadbStarted" != "true" ] && echo "Deployment $mariaAdminDeployName is not ready after timeout" && exit 1
  else
    echo "Secret 'altiplano-secrets-all-certs' does not contain the key 'fluentd_is_username', will not recreate deployment, but proceed with upgrade"
  fi
fi

echo "Modifying access label completed"

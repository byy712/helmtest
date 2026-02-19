#!/bin/sh
namespace="${4:-default}"
usage(){
  echo "=========================================================================================================="
  echo "Script which needs to be run before upgarding nokia infra chart using 'helm upgrade -i nokia infra...' command"
  echo "Note: it is needed only for upgrading from 22.6 to 22.9 or above using helm upgrade command"
  echo
  echo "Syntax: bash modify-hbase-hdfs-labels.sh [releasename -h] [namespace]"
  echo "releasename:  Infra chart Release Name."
  echo "namespace    infra release namespace. If not provided, 'default' namespace is used"
  echo "-h or --help Print Help"
  echo "=========================================================================================================="
}

if [ $# -ge 1 ]
then
  if [ $1 = "--help" -o $1 = "-h" ]
  then
    usage
  else
    releasename=$2
    namenodeStsName=$releasename-altiplano-hdfs-namenode
    namenodeVersion=$(kubectl get sts $namenodeStsName -n $namespace -o jsonpath='{.metadata.labels.app\.kubernetes\.io/version}' 2>/dev/null)
    if [ ! -z "$namenodeVersion" ]
    then
      echo "modifying hbase hdfs labels"
      kubectl get sts $releasename-altiplano-hbase-master -n $namespace -o yaml > /tmp/altiplano-hbase-master-tmpsts.yaml
      kubectl get sts $releasename-altiplano-hbase-regionserver -n $namespace -o yaml > /tmp/altiplano-hbase-regionserver-tmpsts.yaml
      kubectl get sts $releasename-altiplano-hdfs-datanode -n $namespace -o yaml > /tmp/altiplano-hdfs-datanode-tmpsts.yaml
      kubectl get sts $releasename-altiplano-hdfs-namenode -n $namespace -o yaml > /tmp/altiplano-hdfs-namenode-tmpsts.yaml
      sed -i '/helm.sh\/chart: altiplano-hdfs-/d' /tmp/altiplano-hdfs-namenode-tmpsts.yaml
      sed -i '/app.kubernetes.io\/version: 2.7.7/d' /tmp/altiplano-hdfs-namenode-tmpsts.yaml
      sed -i '/helm.sh\/chart: altiplano-hdfs-/d' /tmp/altiplano-hdfs-datanode-tmpsts.yaml
      sed -i '/app.kubernetes.io\/version: 2.7.7/d' /tmp/altiplano-hdfs-datanode-tmpsts.yaml
      sed -i '/helm.sh\/chart: altiplano-hbase-/d' /tmp/altiplano-hbase-regionserver-tmpsts.yaml
      sed -i '/app.kubernetes.io\/version: 2.0.1/d' /tmp/altiplano-hbase-regionserver-tmpsts.yaml
      sed -i '/helm.sh\/chart: altiplano-hbase-/d' /tmp/altiplano-hbase-master-tmpsts.yaml
      sed -i '/app.kubernetes.io\/version: 2.0.1/d' /tmp/altiplano-hbase-master-tmpsts.yaml

      if [ -e /tmp/altiplano-hdfs-namenode-tmpsts.yaml ]
      then
        kubectl delete sts $releasename-altiplano-hdfs-namenode $releasename-altiplano-hdfs-datanode $releasename-altiplano-hbase-regionserver $releasename-altiplano-hbase-master -n $namespace

        grep_result=$(grep -A 4 "name: IS_USERNAME" /tmp/altiplano-hdfs-namenode-tmpsts.yaml)
        echo $grep_result > /tmp/nn-grep-result.txt
        file_content=$(</tmp/nn-grep-result.txt)

        if [[ "$file_content" != *"- name: IS_USERNAME valueFrom: secretKeyRef: key: fluentd_is_username name: altiplano-secrets-all-certs"* ]]; then
          kubectl apply -f /tmp/altiplano-hdfs-namenode-tmpsts.yaml -n $namespace
          kubectl apply -f /tmp/altiplano-hdfs-datanode-tmpsts.yaml -n $namespace
          kubectl apply -f /tmp/altiplano-hbase-master-tmpsts.yaml -n $namespace
          kubectl apply -f /tmp/altiplano-hbase-regionserver-tmpsts.yaml -n $namespace
        fi
        rm /tmp/nn-grep-result.txt
      fi

      rm /tmp/altiplano-hdfs-namenode-tmpsts.yaml /tmp/altiplano-hdfs-datanode-tmpsts.yaml /tmp/altiplano-hbase-master-tmpsts.yaml /tmp/altiplano-hbase-regionserver-tmpsts.yaml
    fi
  fi
else
  echo "Illegal number of arguments"
	echo
	usage
fi

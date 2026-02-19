#!/bin/bash

# Initialize variables
RELEASE_NAME=""
NAME_SPACE=""

usage() {
  echo "Usage: bash reloadSecurityAdminConfig.sh --releaseName <releaseName> --namespace <namespace>"
  echo "Example: bash reloadSecurityAdminConfig.sh --releaseName nokiainfra --namespace altiplano"
  echo "releaseName         - Helm release name of Opensearch"
  echo "namespace         	- The K8S namespace that Opensearch is running. If not provided, 'default' namespace is used"
  echo "help   		          - Show this help message"
}

# Loop through command line arguments
while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
        --releaseName)
            RELEASE_NAME="$2"
            shift 2
            ;;
        --namespace)
            NAME_SPACE="$2"
            shift 2
            ;;
        --help)
            usage
            exit 1
            ;;
        *)
            echo "Unknown argument: $1"
            usage
            exit 1
            ;;
    esac
done

# Check for required parameters
if [ -z "$RELEASE_NAME" ]; then
    echo "Error: --releaseName parameter is required"
    usage
    exit 1
fi


if [ -z "$NAME_SPACE" ]; then
    echo "--namespace parameter isn't provided, then using default"
    NAME_SPACE="default"
fi

decrypt_files(){
  directory="$1"
  files_list=($(kubectl exec -i --namespace $NAME_SPACE $POD_NAME -- bash -c "cd $directory && find . -name '*.enc' | cut -f2 -d'/'"))

  echo "Decrypting files..."
  for i in "${files_list[@]}"
  do
    srcFile=$(echo $i | tr -dc '[:alnum:]._')
    desFile=${i%.*}
    kubectl exec -i "$POD_NAME" --namespace "$NAME_SPACE" -- bash -c "cd $directory && cp $srcFile $desFile; java -cp /etc/sharedMount/Nokia-encrypter.jar com.nokia.fileencrypter.Decrypter /etc/sharedMount/.secretKey $directory/$desFile"
  done
  echo "Done"
}

delete_decrypted_files(){
  directory="$1"
  files_list=($(kubectl exec -i --namespace $NAME_SPACE $POD_NAME -- bash -c "cd $directory && find . -name '*.enc' | cut -f2 -d'/'"))

  echo "Delete files list..."
  for i in "${files_list[@]}"
  do
    fileName=$(echo $i | tr -dc '[:alnum:]._')
    fileName=${fileName%.*}
    kubectl exec -i --namespace $NAME_SPACE $POD_NAME -- bash -c "cd $directory && rm -f $fileName"
  done
}

POD_NAME=$(kubectl get po --namespace $NAME_SPACE | grep $RELEASE_NAME-altiplano-indexsearch-client | head -1 | cut -d' ' -f1)

decrypt_files "/etc/opensearch/config/certs"
decrypt_files "/etc/opensearch/securityconfig"

echo "Deleting security index..."
kubectl exec -i $POD_NAME --namespace $NAME_SPACE -- bash -c 'source /opt/opensearch/scripts/utility.sh && exportEnv && cd /etc/opensearch/securityconfig/ && /usr/share/opensearch/plugins/opensearch-security/tools/securityadmin.sh -ts $TRUSTSTORE_FILEPATH -ks $CLIENT_KEYSTORE_FILEPATH -cn $CLUSTER_NAME -kspass $KS_PWD -tspass $TS_PWD -h $HOSTNAME -p $HTTP_PORT -nhnv -dci'
echo
reinitialize_security_index=$(kubectl exec -i $POD_NAME --namespace $NAME_SPACE -- bash -c 'source /opt/opensearch/scripts/utility.sh && exportEnv && cd /etc/opensearch/securityconfig/ && /usr/share/opensearch/plugins/opensearch-security/tools/securityadmin.sh -ts $TRUSTSTORE_FILEPATH -ks $CLIENT_KEYSTORE_FILEPATH -cn $CLUSTER_NAME -kspass $KS_PWD -tspass $TS_PWD -h $HOSTNAME -p $HTTP_PORT -nhnv')
echo -e "Reinitialize security index... \n $reinitialize_security_index"

if [[ $(echo "$reinitialize_security_index" | grep "Done with success" ) || ($(echo "$reinitialize_security_index" | grep -E -c "SUCC: Configuration for .* created or updated") -ge 9) ]] ; then
  echo "Securityadmin executed successfully at `date +'%Y.%m.%d-%H:%M:%S'`. Install setup is success."
  delete_decrypted_files "/etc/opensearch/config/certs"
  delete_decrypted_files "/etc/opensearch/securityconfig"
  exit 0
else
  echo "Securityadmin executed failed at `date +'%Y.%m.%d-%H:%M:%S'`."
  delete_decrypted_files "/etc/opensearch/config/certs"
  delete_decrypted_files "/etc/opensearch/securityconfig"
  exit 1
fi


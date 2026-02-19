#!/bin/bash

# Initialize variables
RELEASE_NAME=""
NAME_SPACE=""
BACKUP_REPO_NAME=""
SNAPSHOT_NAME=""

usage() {
  echo "Usage: bash restoreIndexsearchBackupWithClusterState.sh --releaseName <releaseName> --namespace <namespace>"
  echo "Example: bash restoreIndexsearchBackupWithClusterState.sh --releaseName nokiainfra --namespace altiplano"
  echo "releaseName         - Helm release name of Opensearch"
  echo "namespace         	- The K8S namespace that Opensearch is running. If not provided, 'default' namespace is used"
  echo "backupRepoName      - Opensearch backup repo name. If not provided, 'nav_is_backup' is used"
  echo "snapshotName        - Opensearch snapshot name. If not provided, 'snapshot_1' is used"
  echo "help   		        - Show this help message"
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
        --backupRepoName)
            BACKUP_REPO_NAME="$2"
            shift 2
            ;;
        --snapshotName)
            SNAPSHOT_NAME="$2"
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

if [ -z "$BACKUP_REPO_NAME" ]; then
    echo "--backupRepoName parameter isn't provided, then using nav_is_backup"
    BACKUP_REPO_NAME="nav_is_backup"
fi

if [ -z "$SNAPSHOT_NAME" ]; then
    echo "--snapshotName parameter isn't provided, then using snapshot_1"
    SNAPSHOT_NAME="snapshot_1"
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

decrypt_files "/etc/sharedMount"

echo "Restoring backup..."

isUrl='https://altiplano-indexsearch:9200/_snapshot/'$BACKUP_REPO_NAME'/'$SNAPSHOT_NAME'/_restore?wait_for_completion=true'
restoreHeaders='-H "Content-Type: application/json" -d '\''{ "indices": "*,-.opendistro_security,-.kibana*,-.signals*,-.task*", "ignore_unavailable": true, "include_global_state": true }'\'
kubectl exec -i $POD_NAME --namespace $NAME_SPACE -- bash -c "curl -s -XPOST $isUrl -k --cert /etc/sharedMount/clientCrtPem --key /etc/sharedMount/clientKeyPem $restoreHeaders"
echo

trap 'delete_decrypted_files "/etc/sharedMount"' EXIT

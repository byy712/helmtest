#!/usr/bin/env bash
#set -u
#set -x
#trap read debug
#!/bin/bash
RELEASE=$1
NAMESPACE="default"
PVC_WEBDAV_CBURTMP="webdav-cburtmp-pvclaim"
PVC_WEBDAV="webdav-pvclaim"

usage(){
   echo "Release name is not provided"
   echo "Usage: ./altiplano-pre-upgrade-pvc.sh -r <INFRA_RELEASE_NAME> -n <namespace>"
   echo "Example:"
   echo "  ./altiplano-pre-upgrade-pvc.sh -r nokia-infra -n my_namespace"
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


declare -a PVCs=(
                'webdav-cburtmp-pvclaim'
                'webdav-pvclaim'
                )

patch_PVs() {
 echo "PV ReclaimPolicy is updated to 'Retain'. This is to avoid PV deletion in case of Dynamic Storage"
 pv_list=$(kubectl get pv --no-headers 2>/dev/null  | awk '{print $1}' 2>&1)
 for pv_name in $pv_list; do
    kubectl patch pv "$pv_name" -p '{"spec":{"persistentVolumeReclaimPolicy": "Retain" }}' >/dev/null 2>&1
 done
 pvc=${#PVCs[@]}
 echo "Patching PVs and deleting the relevant PVCs..."
 for (( i=0; i<$pvc; i++)); do
   pv_item=$(kubectl get pvc ${PVCs[${i}]} -o jsonpath='{.spec.volumeName}' 2>&1)
   echo -e "\n${PVCs[${i}]} : "
   if [[ $pv_item != *"Error"* ]]; then
      timeout 10s kubectl delete pvc ${PVCs[${i}]}
      kubectl patch pvc ${PVCs[${i}]} -p '{"metadata":{"finalizers":null}}' >/dev/null 2>&1
        if [[ -n $pv_item ]]; then
          kubectl patch pv $pv_item -p '{"spec":{"claimRef": null}}' >/dev/null 2>&1
           if [[ ${PVCs[${i}]} == $PVC_WEBDAV_CBURTMP ]]; then
             kubectl patch pv $pv_item -p '{"spec":{"claimRef": {"name":"webdav-cburtmp-pvclaim", "namespace":"'$NAMESPACE'"} }}'
           elif [[ ${PVCs[${i}]} == $PVC_WEBDAV ]]; then
             kubectl patch pv $pv_item -p '{"spec":{"claimRef": {"name":"webdav-pvclaim", "namespace":"'$NAMESPACE'"} }}'
           fi
        else
          echo "no PV for this PVC"
        fi
   else
     echo "PVC not found"
   fi
 done
}

patch_PVs
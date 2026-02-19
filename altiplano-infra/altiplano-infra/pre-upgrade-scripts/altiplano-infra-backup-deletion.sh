#!/bin/sh
NAMESPACE="default"
usage(){
   echo "This script deletes CBUR 'altiplano-infra-backup' cronjob that is installed as part of altiplano-infra chart until 23.12.0 Altiplano releases."
   echo "If 'altiplano-infra-backup' cronjob is not created  (from 23.12.1 Altiplano release & later) nothing is done."
   echo "Usage: ./altiplano-infra-backup-deletion.sh -r <infra_release_name> -n <namespace>"
   echo "Example:"
   echo "  ./altiplano-infra-backup-deletion.sh -r <infra_release_name> -n my_namespace"
   echo ""
   echo "Note: In case namespace is not provided 'default' value will be used."
   exit 1
}

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
infra_cronjob_output=$(kubectl -n $NAMESPACE get cronjob | awk '{print $1}' | grep altiplano-infra-backup)
if [ "$infra_cronjob_output" != "" ]; then
    echo "$(date) Deleting 'altiplano-infra-backup' cronjob..."
    kubectl delete cronjob $infra_cronjob_output
fi
#!/bin/sh
# This script deletes all CRDS that are installed as part of altiplano-infra/crds on 22.3 & 22.6 Altiplano releases.
# Note that helm uninstall does not remove CRDs.
# If crds are installed as part of altiplano-crds chart (from 22.9 Altiplano release & later) nothing is done.

#echo "$(date) Check if CRDs are installed as part of "altiplano-infra" OR "altiplano-crds" chart: "
crds_output=$(kubectl get crds -l app.kubernetes.io/managed-by!=Helm | awk '{print $1}' | grep cbur)
if [ "$crds_output" != "" ]; then
    echo "$(date) Deleting CRDs..."
    kubectl delete crd $crds_output
fi
#! /bin/bash
# Description: This script is used for post upgrade job in Altiplano Infra Helm Chart with dynamic storage like Ceph.

echo -e "\n$(date) - Executing the script upgradeInfraWithDynamicStorage.sh ..."
NAME=$1
NS=$2
storageClass=$(kubectl get sc --no-headers | grep '(default)')
if [[ -n $storageClass ]]; then
    name=$(echo "$storageClass" | awk '{print $1}')
    allowVolumeExpansion=$(echo "$storageClass" | awk '{print $6}')
    if [[ $allowVolumeExpansion = false ]]; then
        echo "Default storage class $name is not allowed for volume expansion !!!"
        exit 0
    fi
else
    echo 'Default storage class not found !!!'
    exit 0
fi

sts=$(kubectl get sts -n "$NS" --no-headers -o custom-columns=':metadata.name' -l app.kubernetes.io/instance="$NAME" & kubectl get sts -n "$NS" --no-headers -o custom-columns=':metadata.name' -l release="$NAME")
mapfile -t sts < <(echo "$sts" | tr ' ' '\n' | sort -u)
for name in "${sts[@]}"; do
    length=$(kubectl get sts -n "$NS" "$name" -o=jsonpath='{@.spec.volumeClaimTemplates[*]}' | tr ' ' '\n' | grep -c '^')
    if [ "$length" -eq 0 ]; then
        continue
    fi

    echo -e "\nUpdating $name ..."
    isChanged=false
    for i in $(seq 1 $(("$length"))); do
        kind=$(kubectl get sts -n "$NS" "$name" -o=jsonpath='{@.spec.volumeClaimTemplates[*]}' | tr ' ' '\n' | sed -n "$i"p | sed -n 's/.*"kind":"\([^"]*\).*/\1/p')
        if [ "$kind" == 'PersistentVolumeClaim' ]; then
            labels=$(kubectl get sts -n "$NS" "$name" -o=jsonpath='{@.spec.volumeClaimTemplates[*]}' | tr ' ' '\n' | sed -n "$i"p | sed -n 's/.*"metadata":{\([^}]*\).*"labels":{\([^}]*\).*/\2/p')
            if [ -n "$labels" ]; then
                labels=$(kubectl get sts -n "$NS" "$name" -o=jsonpath='{@.spec.selector.matchLabels}')
                labels="${labels:1:-1}"
            fi

            selector=$(echo "$labels" | sed 's/"//g; s/:/=/g')
            metadataName=$(kubectl get sts -n "$NS" "$name" -o=jsonpath='{@.spec.volumeClaimTemplates[*]}' | tr ' ' '\n' | sed -n "$i"p | sed -n 's/.*"metadata":{\([^}]*\).*"name":"\([^"]*\).*/\2/p')
            pvcName=$(kubectl get pvc -n "$NS" -l "$selector" --no-headers -o custom-columns=':metadata.name' | grep "$metadataName")
            storage=$(kubectl get sts -n "$NS" "$name" -o=jsonpath='{@.spec.volumeClaimTemplates[*]}' | tr ' ' '\n' | sed -n "$i"p | sed -n 's/.*"spec":{\([^}]*\).*"resources":{\([^}]*\).*"requests":{\([^}]*\).*"storage":"\([^"]*\).*/\4/p')
            # shellcheck disable=SC2086
            result=$(kubectl patch pvc -n "$NS" $pvcName -p '{"spec":{"resources":{"requests":{"storage":"'"$storage"'"}}}}')
            echo "$result"
            if [[ $result != *'(no change)'* && $result != '' ]]; then
                isChanged=true
            fi
        fi
    done

    if [ $isChanged = true ]; then
        echo -e "\nRestarting $name ..."
        kubectl rollout restart sts -n "$NS" "$name"
    fi
done

echo -e "\n$(date) - Executed the script upgradeInfraWithDynamicStorage.sh !!!"

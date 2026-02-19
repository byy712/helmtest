#!/bin/bash
####$$ The process number of the current shell. For shell scripts, this is the process ID under which they are executing.
####proc/[pid]/fd/ This is a subdirectory containing one entry for each file which the process has open, named by its file descriptor, and which is a symbolic link to the actual file. Thus, 0 is standard input, 1 standard output, 2 standard error, and so on

declare NAMESPACE=$1
declare SRC_STS_MASTER=$2
declare SRC_STS_DATA=$3
declare DST_STS_MASTER=$4
declare DST_STS_DATA=$5
declare PV_ORG_RETAIN_POLICY
declare ROOT_PID="$$"

function _log_on_level_with_fd() {
  echo "$(date --iso-8601=ns):$1: $3" > /proc/${ROOT_PID}/fd/$2
}

function _log_on_level_stdout() {
  _log_on_level_with_fd "$1" "1" "$2"
}

function _log_on_level_stderr() {
  _log_on_level_with_fd "$1" "2" "$2"
}

function log_error() {
  _log_on_level_stderr "ERROR" "$1"
}

function log_info() {
  _log_on_level_stdout "INFO" "$1"
}

function log_warn() {
  _log_on_level_stdout "WARN" "$1"
}

function check_exit_code() {
  if [[ $1 -ne 0 ]];
  then
    log_error "$2"
    return $1
  fi
  return 0
}

function fatal_exit_code() {
  check_exit_code "$1" "$2" || exit 1
}

if [ -z "$NAMESPACE" ]; then
  echo "Namespace must be provided"
  exit 1
fi

if [ -z "$SRC_STS_MASTER" ]; then
  echo "Source master statefulset name not found!!"
  exit 1
fi

if [ -z "$SRC_STS_DATA" ]; then
  echo "Source data statefulset name not found!!"
  exit 1
fi

if [ -z "$DST_STS_MASTER" ]; then
  echo "Destination master statefulset name not found!!"
  exit 1
fi

if [ -z "$SRC_STS_DATA" ]; then
  echo "Destination data statefulset name not found!!"
  exit 1
fi

function rename_stateful_set_pvcs() {
  local SRC_STATEFULSET_NAME="$1"
  local DST_STATEFULSET_NAME="$2"

  log_info "Attempt to migrate PVC from StatefulSet '${SRC_STATEFULSET_NAME}' to '${DST_STATEFULSET_NAME}'"
  if does_resource_exists "statefulsets/${SRC_STATEFULSET_NAME}";
  then
    log_info "Found StatefulSet '${SRC_STATEFULSET_NAME}'. Will attempt to migrate PVC"
    migrate_stateful_set_pvcs "${SRC_STATEFULSET_NAME}" "${DST_STATEFULSET_NAME}"
  else
    log_info "StatefulSet '${SRC_STATEFULSET_NAME}' does not exist. Will skip PVC migration"
  fi
}

function does_resource_exists() {
  local RESOURCE="$1"
  local OUTPUT="$(kubectl --namespace ${NAMESPACE} get "$RESOURCE" --ignore-not-found --no-headers=true -oname)" ret=$?
  fatal_exit_code $ret "Unable to check if resource '$RESOURCE' exist: ${OUTPUT}"
  [[ ! -z "$OUTPUT" ]]
}

function migrate_stateful_set_pvcs() {
  local SOURCE_STATEFUL_SET_NAME="$1"
  local DESTINATION_STATEFUL_SET_NAME="$2"
  local VOLUME_CLAIM_TEMPLATE_NAMES=$(find_stateful_set_volume_claim_template_names "$SOURCE_STATEFUL_SET_NAME") ret=$?
  delete_statefulset "${SOURCE_STATEFUL_SET_NAME}"
  fatal_exit_code $ret "Unable to extract volume claim template names for StatefulSet '${SOURCE_STATEFUL_SET_NAME}': ${VOLUME_CLAIM_TEMPLATE_NAMES}"
  # If both source, destination sts name is same(In case of fullnameOverride), PV migration is not required, but due to common labels changes sts has to be deleted. Hence this condition is added here
  if [ $SOURCE_STATEFUL_SET_NAME != $DESTINATION_STATEFUL_SET_NAME ]; then
      log_info "Migrating PVCs for volume claim template name '${VOLUME_CLAIM_TEMPLATE_NAMES}'"
      migrate_statuful_set_pvcs_for_template_name "${SOURCE_STATEFUL_SET_NAME}" "${DESTINATION_STATEFUL_SET_NAME}" "${VOLUME_CLAIM_TEMPLATE_NAMES}"
  else
   echo "PV Migration is not required as old pvc $SOURCE_STATEFUL_SET_NAME and new pvc $DESTINATION_STATEFUL_SET_NAME are same"
  fi
}

function delete_statefulset() {
  local STATEFUL_SET_NAME="$1"
  kubectl --namespace "$NAMESPACE" delete statefulset "$STATEFUL_SET_NAME"
  ret=$?
  if [ $ret -ne 0 ]; then
    echo "Could not delete $STATEFUL_SET_NAME"
    exit 1
  fi
}

function find_stateful_set_volume_claim_template_names() {
  local STATEFUL_SET_NAME="$1"
  log_info "Search for StatefulSet '${STATEFUL_SET_NAME}' volume templates names"
  kubectl --namespace ${NAMESPACE} get statefulsets "${STATEFUL_SET_NAME}" -ojsonpath='{range.spec.volumeClaimTemplates[*]}{.metadata.name}{"\n"}{end}'

}

function find_pvc_names()
{
  local STATEFUL_SET_NAME="$1"
  local VOLUME_TEMPLATE_CLAIM_NAME="$2"
  local PVC_NAME_PATTERN="${VOLUME_TEMPLATE_CLAIM_NAME}-${STATEFUL_SET_NAME}-[0-9]+"
  log_info "Will search for PVCs using pattern: ${PVC_NAME_PATTERN}"
  local OUTPUT=$(kubectl --namespace ${NAMESPACE} get pvc --no-headers=true -o custom-columns=:metadata.name) ret=$?
  fatal_exit_code $ret "Unable to read pvc names: $OUTPUT"
  echo "$OUTPUT" | grep -E "${PVC_NAME_PATTERN}" || true
}

function find_pv_for_pvc() {
  local PVC_NAME="$1"
  local PV_NAME=$(kubectl get pvc $PVC_NAME -ojsonpath='{.spec.volumeName}' --namespace $NAMESPACE) ret=$?
  if [[ $ret -ne 0 ]];then
    log_error "Unable to find PV with PVC '${PVC_NAME}'"
    exit 1
  fi
  echo "$PV_NAME"
  return $ret
}

function migrate_statuful_set_pvcs_for_template_name() {
  local SOURCE_STATEFUL_SET_NAME="$1"
  local DESTINATION_STATEFUL_SET_NAME="$2"
  local VOLUME_CLAIM_TEMPLATE_NAME="$3"
  local PVC_NAMES=$(find_pvc_names "${SOURCE_STATEFUL_SET_NAME}" "${VOLUME_CLAIM_TEMPLATE_NAME}") ret=$?
  fatal_exit_code $ret "Unable to find PVCs for StatefulSet ${SOURCE_STATEFUL_SET_NAME} with template name '${VOLUME_CLAIM_TEMPLATE_NAME}'"
  for pvcName in ${PVC_NAMES};
  do
    log_info "Will attempt to migrate PVC '${pvcName}' from StatefulSet '${SOURCE_STATEFUL_SET_NAME}' to '${DESTINATION_STATEFUL_SET_NAME}'"
    pvName=$(find_pv_for_pvc "${pvcName}") retPv=$?
    fatal_exit_code $retPv "Unable to find PV for PVC '${pvcName}': ${pvName}"
    log_info "Found PV ${pvName} for ${pvcName}"
    if [ $retPv -ne 0 ]; then
      echo "PV ${pvName} for ${pvcName} not found"
      exit 1
    fi
    check_retain_policy_before_migration "$pvName"
    change_pv_retain_policy "$pvName" "Retain"
    destinationPvcName=$(create_destination_pvc_if_not_exist "$SOURCE_STATEFUL_SET_NAME" "$DESTINATION_STATEFUL_SET_NAME" "$pvcName") retPvc=$?
    fatal_exit_code $retPvc "Unable to create new PVC: ${destinationPvcName}"
    rebound_pv_to_new_pvc "$pvName" "$destinationPvcName"
    log_info "Removing old PVC '${pvcName}'"
    kubectl --namespace "$NAMESPACE" delete persistentvolumeclaim "$pvcName"
    fatal_exit_code $? "Unable to delete PVC '${pvcName}'"
    restore_pv_retain_policy "${pvName}"
  done
}

function change_pv_retain_policy() {
  local PV_NAME="$1"
  local RETAIN_POLICY="$2"
  log_info "Changing retain policy for PV '${PV_NAME}' to: ${RETAIN_POLICY}"
  kubectl patch persistentvolumes "${PV_NAME}" --patch '{"spec":{"persistentVolumeReclaimPolicy": "'$RETAIN_POLICY'"}}'
  fatal_exit_code $ret "Unable to change PV '${PV_NAME}' retain policy"
}

function create_destination_pvc_if_not_exist() {
  local SOURCE_STATEFUL_SET_NAME="$1"
  local DESTINATION_STATEFUL_SET_NAME="$2"
  local SOURCE_PVC_NAME="$3"
  local DESTINATION_PVC_NAME="${SOURCE_PVC_NAME%${SOURCE_STATEFUL_SET_NAME}*}${DESTINATION_STATEFUL_SET_NAME}${SOURCE_PVC_NAME##*${SOURCE_STATEFUL_SET_NAME}}"
  ##volumeClaimTemplate name is changed from masterdir to managerdir after name changes. Hence below check is added
  if [[ "$DESTINATION_PVC_NAME" == "masterdir"* ]]; then
    pvClaimName=managerdir
    DESTINATION_PVC_NAME=$(echo "${DESTINATION_PVC_NAME/masterdir/$pvClaimName}")
  fi
  if does_resource_exists "persistentvolumeclaims/$DESTINATION_PVC_NAME";
  then
    log_warn "PVC '${DESTINATION_PVC_NAME}' already exist. Will not recreate it."
  else
    log_info "Attempt to create PVC '${DESTINATION_PVC_NAME}'."
    local SOURCE_PVC_SPEC=$(kubectl --namespace "${NAMESPACE}" get persistentvolumeclaims "$SOURCE_PVC_NAME" -ojsonpath='{.spec}') ret=$?
    fatal_exit_code $ret "Unable to read spec of PV '${SOURCE_PVC_NAME}'"
    if [ $ret -ne 0 ]; then
      echo "Unable to read spec of PV '${SOURCE_PVC_NAME}'"
    fi
    local DESTINATION_PVC_DEFINITION='{"apiVersion":"v1","kind":"PersistentVolumeClaim","metadata":{"name":"'${DESTINATION_PVC_NAME}'"},"spec":'${SOURCE_PVC_SPEC}'}'
    log_info "Will create PVC using definition: ${DESTINATION_PVC_DEFINITION}"
    echo "$DESTINATION_PVC_DEFINITION" | kubectl --namespace "${NAMESPACE}" apply -f - > /proc/${ROOT_PID}/fd/1
    fatal_exit_code $? "Unable to create new PVC with name: ${DESTINATION_PVC_NAME}"
  fi
  echo "$DESTINATION_PVC_NAME"

}

function rebound_pv_to_new_pvc() {
  local PV_NAME="$1"
  local PVC_NAME="$2"
  local PVC_UID=$(kubectl --namespace "$NAMESPACE" get "persistentvolumeclaim/${PVC_NAME}" -ojsonpath={.metadata.uid}) ret=$?
  fatal_exit_code $ret "Unable to extract PVC '${PVC_NAME}' UID: ${PVC_UID}"
  log_info "Will patch PV '${PV_NAME}' to rebound it to PVC '${PVC_NAME}' with UID: ${PVC_UID}"
  kubectl patch "persistentvolumes/$PV_NAME" --patch '{"spec":{"claimRef":{"name":"'$PVC_NAME'","uid":"'$PVC_UID'"}}}'
  fatal_exit_code $ret "Unable to patch PV '${PV_NAME}'."
  wait_for_pvc_status_phase "$PVC_NAME" "Bound"
}

function wait_for_pvc_status_phase() {
  local PVC_NAME="$1"
  local PVC_STATUS_PHASE="$2"
  log_info "Waiting for PVC '${PVC_NAME} to be in phase: ${PVC_STATUS_PHASE}"
  local PVC_CURRENT_PHASE=$(kubectl --namespace "${NAMESPACE}" get "persistentvolumeclaim/${PVC_NAME}" -ojsonpath={.status.phase}) ret=$?
  fatal_exit_code $ret "Unable to read status of PersistentVolumeClaim '${PVC_CURRENT_PHASE}'"
  log_info "Current phase of PersistentVolumeClaim '${PVC_NAME}': ${PVC_CURRENT_PHASE}"
  while [[ "$PVC_CURRENT_PHASE" != "$PVC_STATUS_PHASE" ]];
  do
    sleep 5s
    local PVC_CURRENT_PHASE=$(kubectl --namespace "${NAMESPACE}" get "persistentvolumeclaim/${PVC_NAME}" -ojsonpath={.status.phase}) ret=$?
    fatal_exit_code $ret "Unable to read status of PersistentVolumeClaim '${PVC_CURRENT_PHASE}'"
    log_info "Current phase of PersistentVolumeClaim '${PVC_NAME}': ${PVC_STATUS_PHASE}"
  done
}

function check_retain_policy_before_migration() {
  local PV_NAME="$1"
  local PV_RECLAIM_POLICY=$(kubectl get pv "$PV_NAME" -ojsonpath={.spec.persistentVolumeReclaimPolicy} 2>&1) ret=$?
  fatal_exit_code $ret "Unable to read current PV '${PV_NAME}' reclaim policy: ${PV_RECLAIM_POLICY}"
  PV_ORG_RETAIN_POLICY=$PV_RECLAIM_POLICY
  echo "Current reclaim policy for PV '${PV_NAME}': ${PV_RECLAIM_POLICY}"
}

function restore_pv_retain_policy() {
  local PV_NAME="$1"
  change_pv_retain_policy "$PV_NAME" "${PV_ORG_RETAIN_POLICY}"

}

echo "Will migrate Master PVC from StatefulSet '$SRC_STS_MASTER' to '$DST_STS_MASTER' in namespace '$NAMESPACE'."
rename_stateful_set_pvcs "$SRC_STS_MASTER" "$DST_STS_MASTER"
echo "Will migrate Data PVC from StatefulSet '$SRC_STS_DATA' to '$DST_STS_DATA' in namespace '$NAMESPACE'."
rename_stateful_set_pvcs "$SRC_STS_DATA" "$DST_STS_DATA"


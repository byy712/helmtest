#!/bin/bash
LIVENESS_LOG_FILE="/tmp/opt/keycloak/liveness.log"

log() {
    if [ ! -f $LIVENESS_LOG_FILE ]
    then
        touch $LIVENESS_LOG_FILE
    fi
    echo ""$(date +'%Y-%m-%d %H:%M:%S,%3N') [quarkusLivenessprobe.sh] " $*" >>${LIVENESS_LOG_FILE}
}

PORT=${KC_HTTPS_PORT:-8443}
INGRESS_PATH=${KC_HTTP_RELATIVE_PATH:-"/"}
KEYCLOAK_URL="https://localhost:"${PORT}"${INGRESS_PATH}"/health
VERTX_URL="http://localhost:"${VERTX_HEALTH_CHECK_PORT}"/health"

KEYCLOAK_STATUS_CODE=$(curl -skL -w "%{http_code}" "${KEYCLOAK_URL}" -o /dev/null)
VERTX_STATUS_CODE=$(curl -sL -w "%{http_code}" "${VERTX_URL}" -o /dev/null)

# log "DEBUG Keycloak" "${KEYCLOAK_URL} returned response with ${KEYCLOAK_STATUS_CODE}\n"
# log "DEBUG Logger" "${VERTX_URL} returned response with ${VERTX_STATUS_CODE}\n"

if [ "${KEYCLOAK_STATUS_CODE}" -eq '200' ] && [ "${VERTX_STATUS_CODE}" -eq '200' ]; then
    exit 0
fi

log "ERROR: Exited with keycloak status ${KEYCLOAK_STATUS_CODE} and vertx status ${VERTX_STATUS_CODE}"
exit 1

#!/bin/bash

WAIT_IS_LOOPS=15
WAIT_IS_SLEEP=30
IS_REQUEST_HEADER="-H Content-Type:application/json"
DIR_IS_TEMPLATE="/etc/initContainerMount/altiplano-config/IS-templates"

GET_HTTP_STATUS_CODE="curl --write-out %{http_code} --silent --output /dev/null"

is_IS_ready() {
    eval "[ $($GET_HTTP_STATUS_CODE $IS_CERT_OPTION $IS_URL/_cat/health?h=st) = 200 ]"
}

template_check() {
    template_check_status_code=`($GET_HTTP_STATUS_CODE $IS_CERT_OPTION $IS_TEMPLATE_URL)`
    echo "Checking template exists using command: $GET_HTTP_STATUS_CODE <IS_CERT_OPTION> $IS_TEMPLATE_URL, response code: $template_check_status_code"
    eval "[ ${template_check_status_code} = 200 ]"
}

insertTemplate() {
    curl -XPUT ${IS_REQUEST_HEADER} ${IS_CERT_OPTION} ${IS_TEMPLATE_URL} -d @${file}
    echo "Inserted template ${NAME}."
}

import_templates() {
    echo "====> Insert the custom template"
    mkdir -p /tmp/fluentd/IS-templates-tmp

    ls /tmp/fluentd/IS-templates/*.json | while read file
    do
        NAME=`basename ${file} .json`
        IS_TEMPLATE_URL=${IS_URL}/_template/${NAME}
        if template_check ; then
            echo "Template ${NAME} was existing. Checking version."
            curl -s ${IS_CERT_OPTION} ${IS_TEMPLATE_URL} > /tmp/fluentd/IS-templates-tmp/${NAME}-tmp.json
            version_from_IS=$(cat /tmp/fluentd/IS-templates-tmp/${NAME}-tmp.json | grep -o '"version":[^,}]*' | awk -F: '{print $2}')
            version_from_Template=$(cat ${file} | grep '"version"' | grep '"version"' | awk -F: '{print $2}' | tr -d ' ,')
            echo "Version from IS: ${version_from_IS}; version from Template: ${version_from_Template}."
            if [[ ${version_from_IS} -lt ${version_from_Template} ]] ; then
                echo "Version from IS is less than version from Template ====> Need to insert template ${NAME}."
                insertTemplate
            else
                echo "No need to insert template ${NAME}."
            fi
        else
            insertTemplate
            # drop old indices belong to this template if it's not time based (not the case for now)
        fi
    done

    echo "====> Done insert the custom template"
}

if [ "$CREATE_INDEX_TEMPLATE" == "true" ]; then
    mkdir -p /tmp/fluentd/
    cp /etc/sharedMount/fluentd_indexsearch_username.enc /tmp/fluentd/fluentd_indexsearch_username.enc
    cp /etc/sharedMount/fluentd_indexsearch_password.enc /tmp/fluentd/fluentd_indexsearch_password.enc
    java -cp /etc/sharedMount/Nokia-encrypter.jar com.nokia.fileencrypter.Decrypter /etc/sharedMount/.secretKey /tmp/fluentd/fluentd_indexsearch_username.enc
    java -cp /etc/sharedMount/Nokia-encrypter.jar com.nokia.fileencrypter.Decrypter /etc/sharedMount/.secretKey /tmp/fluentd/fluentd_indexsearch_password.enc

    IS_USER=$(</tmp/fluentd/fluentd_indexsearch_username.enc)
    IS_PASSWORD=$(</tmp/fluentd/fluentd_indexsearch_password.enc)

    rm /tmp/fluentd/fluentd_indexsearch_username.enc /tmp/fluentd/fluentd_indexsearch_password.enc

    if [[ $IS_URL == *"https"* ]]; then
        IS_CERT_OPTION="-k -u $IS_USER:$IS_PASSWORD"
    else
        IS_CERT_OPTION="-u $IS_USER:$IS_PASSWORD"
    fi

    # wait until IS is ready
    while ! is_IS_ready; do
        echo "$(date) - waiting IndexSearch to be ready"
        sleep $WAIT_IS_SLEEP
    done

    echo "====> IndexSearch is started"

    mkdir -p /tmp/fluentd/IS-templates
    cp -R $DIR_IS_TEMPLATE /tmp/fluentd/
    sed -i "s/--LOG_INDEX_PATTERN--/$LOG_INDEX_PATTERN/" /tmp/fluentd/IS-templates/logstash-index-template.json

    sed -i "s/--UAL_INDEX_PATTERN--/$UAL_INDEX_PATTERN/" /tmp/fluentd/IS-templates/user-activity-log-index-template.json

    sed -i "s/--NUMBER_OF_REPLICAS--/$NUMBER_OF_REPLICAS/" /tmp/fluentd/IS-templates/logstash-index-template.json
    sed -i "s/--NUMBER_OF_REPLICAS--/$NUMBER_OF_REPLICAS/" /tmp/fluentd/IS-templates/user-activity-log-index-template.json
    sed -i "s/--NUMBER_OF_REPLICAS--/$NUMBER_OF_REPLICAS/" /tmp/fluentd/IS-templates/syslog-index-template.json

    #import the templates to IS
    import_templates

    echo "====> All imports are done"
fi

echo "FluentD is ready" > /tmp/fluentd.status

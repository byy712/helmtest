#!/bin/bash

: ${HADOOP_HOME:=/usr/local/hadoop}

. $HADOOP_HOME/etc/hadoop/hadoop-env.sh

# Directory to find config artifacts
CONFIG_DIR="/tmp/hadoop-config"

# Copy config files from volume mount

for f in slaves core-site.xml hdfs-site.xml mapred-site.xml yarn-site.xml hadoop-policy.xml kms-acls.xml; do
    if [[ -e ${CONFIG_DIR}/$f ]]; then
    cp ${CONFIG_DIR}/$f $HADOOP_HOME/etc/hadoop/$f
    else
    echo "ERROR: Could not find $f in $CONFIG_DIR"
    exit 1
    fi
done

# installing libraries if any - (resource urls added comma separated to the ACP system variable)
cd $HADOOP_HOME/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -
if [[ $2 == "journalnode" ]]; then
    if [ ! -d "/dfs/journal" ]; then
    mkdir -p /dfs/journal
    echo "/dfs/journal dir created"
    fi
    echo "starting journalnode"
    $HADOOP_HOME/bin/hdfs --daemon start journalnode
fi
if [[ $2 == "namenode" ]]; then
    if [ ! -d "/dfs/name" ]; then
    mkdir -p /dfs/name
    echo "/dfs/name dir created"
    fi
    if [[ "$MY_POD" = "$NAMENODE_POD_0" ]]; then
      echo "this is namenode 0"
      _METADATA_DIR=/dfs/name/current
      if [[ ! -d $_METADATA_DIR ]]; then
          $HADOOP_HOME/bin/hdfs namenode -format  \
              -nonInteractive altiplano-hdfs ||
              (rm -rf $_METADATA_DIR; exit 1)
      fi
    elif [[ "$MY_POD" = "$NAMENODE_POD_1" ]]; then
      echo "this is namenode 1"
      if [[ ! -d $_METADATA_DIR ]]; then
        $HADOOP_HOME/bin/hdfs namenode -bootstrapStandby  \
            -nonInteractive ||  \
            (rm -rf $_METADATA_DIR; exit 1)
      fi
    else
      if [ "`ls -A /dfs/name --ignore=lost+found`" == "" ]; then
      $HADOOP_HOME/bin/hdfs namenode -format -force -nonInteractive
      echo "namenode formated"
      fi
    fi
    if [ $NAMENODE_HA == true ]; then
      _ZKFC_FORMATTED=/dfs/name/current/.hdfs-k8s-zkfc-formatted
      if [[ ! -f $_ZKFC_FORMATTED ]]; then
        echo "formating zkfc"
        _OUT=$($HADOOP_HOME/bin/hdfs zkfc -formatZK -nonInteractive 2>&1)
        # zkfc masks fatal exceptions and returns exit code 0
        (echo $_OUT | grep -q "FATAL") && exit 1
        touch $_ZKFC_FORMATTED
      fi
      ISZKFCRUNNING=false
      while [ $ISZKFCRUNNING == false ]; do
        echo "zookeeper is not up failed to create zkfc process"
        ZKFC=$(echo `jps |grep DFSZKFailoverController`)
        if [[ $ZKFC == *"DFSZKFailoverController"* ]]; then
          ISZKFCRUNNING=true
          echo "zookeeper is up zkfc process created"
        else
          $HADOOP_HOME/bin/hdfs --daemon start zkfc
        fi
      done
    fi
    {{- if .Values.prometheus.enabled }}
      export HDFS_NAMENODE_OPTS="-XX:+UseG1GC -javaagent:/jmx-exporter/jmx_prometheus_javaagent.jar={{ .Values.prometheus.port }}:/etc/exporter/config-exporter.yml"
    {{- end }}
    $HADOOP_HOME/bin/hdfs --daemon start namenode
    sleep 25
    NNP=$(echo `jps |grep NameNode`)
    if [[ $NNP == *"NameNode"* ]]; then
      echo "namenode process started"
    else
      echo "namenode process not running"
      echo "starting namenode process"
      $HADOOP_HOME/bin/hdfs --daemon start namenode -upgrade
    fi
fi
if [[ $2 == "datanode" ]]; then
    if [ ! -d "/dfs/data" ]; then
    mkdir -p /dfs/data
    fi
    #  wait up to 30 seconds for namenode
    (while [[ $count -lt 15 && -z `curl -sf http://{{ include "hdfs.fullname" . }}-namenode:9870/index.html` ]]; do ((count=count+1)) ; echo "Waiting for {{ include "hdfs.fullname" . }}-namenode" ; sleep 2; done && [[ $count -lt 15 ]])
    [[ $? -ne 0 ]] && echo "Timeout waiting for hdfs namenode, exiting." && exit 1
    {{- if .Values.prometheus.enabled }}
      export HDFS_DATANODE_OPTS="-XX:+UseG1GC -javaagent:/jmx-exporter/jmx_prometheus_javaagent.jar={{ .Values.prometheus.port }}:/etc/exporter/config-exporter.yml"
    {{- end }}
    $HADOOP_HOME/bin/hdfs --daemon start datanode
fi
if [[ $1 == "-d" ]]; then
    until find ${HADOOP_HOME}/logs -mmin -1 | egrep -q '.*'; echo "`date`: Waiting for logs..." ; do sleep 2 ; done
    tail -F ${HADOOP_HOME}/logs/* &
    while true; do sleep 1000; done
fi

if [[ $1 == "-bash" ]]; then
    /bin/bash
fi
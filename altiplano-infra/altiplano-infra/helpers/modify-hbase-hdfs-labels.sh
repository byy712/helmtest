#!/bin/sh
namespace="${2:-default}"
usage(){
  echo "=========================================================================================================="
  echo "Script which needs to be run before upgarding nokia infra chart using 'helm upgrade -i nokia infra...' command"
  echo "Note: it is needed only for upgrading from 22.6 to 22.9 or above using helm upgrade command"
  echo
  echo "Syntax: bash modify-hbase-hdfs-labels.sh [releasename -h] [namespace]"
  echo "releasename:  Infra chart Release Name."
  echo "namespace    infra release namespace. If not provided, 'default' namespace is used"
  echo "-h or --help Print Help"
  echo "=========================================================================================================="
}

if [ $# -ge 1 ]
then
  if [ $1 = "--help" -o $1 = "-h" ]
  then
    usage
  else
    releasename=$1
    kubectl get sts $releasename-altiplano-hbase-master -n $namespace -o yaml > altiplano-hbase-master-tmpsts.yaml
    kubectl get sts $releasename-altiplano-hbase-regionserver -n $namespace -o yaml > altiplano-hbase-regionserver-tmpsts.yaml
    kubectl get sts $releasename-altiplano-hdfs-datanode -n $namespace -o yaml > altiplano-hdfs-datanode-tmpsts.yaml
    kubectl get sts $releasename-altiplano-hdfs-namenode -n $namespace -o yaml > altiplano-hdfs-namenode-tmpsts.yaml
    sed -i '/helm.sh\/chart: altiplano-hdfs-/d' altiplano-hdfs-namenode-tmpsts.yaml
    sed -i '/app.kubernetes.io\/version: 2.7.7/d' altiplano-hdfs-namenode-tmpsts.yaml
    sed -i '/helm.sh\/chart: altiplano-hdfs-/d' altiplano-hdfs-datanode-tmpsts.yaml
    sed -i '/app.kubernetes.io\/version: 2.7.7/d' altiplano-hdfs-datanode-tmpsts.yaml
    sed -i '/helm.sh\/chart: altiplano-hbase-/d' altiplano-hbase-regionserver-tmpsts.yaml
    sed -i '/app.kubernetes.io\/version: 2.0.1/d' altiplano-hbase-regionserver-tmpsts.yaml
    sed -i '/helm.sh\/chart: altiplano-hbase-/d' altiplano-hbase-master-tmpsts.yaml
    sed -i '/app.kubernetes.io\/version: 2.0.1/d' altiplano-hbase-master-tmpsts.yaml

    if [ -e altiplano-hdfs-namenode-tmpsts.yaml ]
    then
      kubectl delete sts $releasename-altiplano-hdfs-namenode $releasename-altiplano-hdfs-datanode $releasename-altiplano-hbase-regionserver $releasename-altiplano-hbase-master -n $namespace
    fi

    kubectl apply -f altiplano-hdfs-namenode-tmpsts.yaml -n $namespace
    kubectl apply -f altiplano-hdfs-datanode-tmpsts.yaml -n $namespace
    kubectl apply -f altiplano-hbase-master-tmpsts.yaml -n $namespace
    kubectl apply -f altiplano-hbase-regionserver-tmpsts.yaml -n $namespace
    rm altiplano-hdfs-namenode-tmpsts.yaml altiplano-hdfs-datanode-tmpsts.yaml altiplano-hbase-master-tmpsts.yaml altiplano-hbase-regionserver-tmpsts.yaml
  fi
else
  echo "Illegal number of arguments"
	echo
	usage
fi
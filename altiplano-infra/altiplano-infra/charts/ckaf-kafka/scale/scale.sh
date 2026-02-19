#!/bin/bash

set -u
IFS=$'\n'       # make newlines the only separator
GREEN="\e[32m";RED="\e[31m";BLUE="\e[34m";NORMAL="\\033[0;39m";OK="$GREEN[OK]$NORMAL";KO="$RED[KO]$NORMAL";

usage() {
cat << EOF
Scale Helm Chart Release
Lets you scale the helm release given the release name and replica count.

  scale   scales the replicas set,statefulsets,deployments and job scalars
  
Syntax :
  helm scale << helm release name >> << replica_count >>
       Do Helm list to get the release name.
Example:
  helm scale mycmdb 2  

Available options:
   -x   list of apps to not scale,accepts statefulsets/deployments name
    example: helm scale mycmdb 5 -x mykafka-ckaf-zookeeper

EOF
}



scale() {

echo " the release namespace is $releasenamespace"
zkcurrentreplicacount=$(helm status $helmreleasename   | sed -e '1,/StatefulSet/d' | sed -e '1d'  | sed -e '/^$/,$d'|grep ^zk | awk '{print $3;}')
 echo "zkcurrentreplicacount $zkcurrentreplicacount"
 kfcurrentreplicacount=$(helm status $helmreleasename  | sed -e '1,/StatefulSet/d' | sed -e '1d'  | sed -e '/^$/,$d'|grep ^kf| awk '{print $3;}')
 echo "kfcurrentreplicacount $kfcurrentreplicacount"

if (($zkcurrentreplicacount > $replicacount));then
 zkscalein=true
else
 zkscalein=false
fi

if (($zkcurrentreplicacount == $replicacount));then
 zkscale=false
 echo "current zk num same with $replicacount, no need scale"
fi

if (($kfcurrentreplicacount > $replicacount));then
 kfscalein=true
else
 kfscalein=false
fi

if (($kfcurrentreplicacount == $replicacount));then
 kfscale=false
 echo "current kf num same with $replicacount, no need scale"
fi

echo "kfscalein $kfscalein"
echo "zkscalein $zkscalein"

helm status $helmreleasename | sed -e '1,/StatefulSet/d' | sed -e '1d' | sed -e '/^$/,$d' | awk '{print $1;}' > temp/statefulsets.txt |tee /dev/tty 
 #cat temp/statefulsets.txt

if [ -s temp/statefulsets.txt ]
then
    if [ "$zkscale" == "true" ];then
      echo "Enter zkscalefunc"
      zkscalefunc
    fi

    if [[ "$kfscale" == "true" && "$zkscale" == "true" ]];then
      echo "sleep 120s, wait for zookeeper ready"
      sleep 200
    fi

    if [ "$kfscale" == "true" ];then
      echo "Enter kfscalefunc"
      kfscalefunc
    fi
else
   echo "no statefulsets found to scale"
fi

cleanup
}

zkscalefunc(){
     zkprescale
     echo "kubectl apply -f $zkstatefulset --namespace $releasenamespace"
     kubectl apply -f $zkstatefulset --namespace $releasenamespace
     echo "sleep 200s, wait for zookeeper scale ready"
     sleep 200
     zkpostscale
}

kfscalefunc(){
     if [ "$kfscalein" == "true" ];then
       echo "kf prescalein enter"
       kfprescalein
     fi
     stline=$(grep ^kf temp/statefulsets.txt)
     echo "kfscalefunc stline $stline"
     echo "kubectl scale --replicas=$replicacount sts/$stline $releasenamespace"
     kubectl scale --replicas=$replicacount sts/$stline --namespace $releasenamespace
     echo "Executing postscale scripts"
     if [ "$kfscalein" == "true" ];then
       echo "kf postscalein enter"
       kfpostscalein
     fi
}

zkprescale(){
 echo "Enter zkprescale"

if [ -e /tmp/$helmreleasename.yaml ]; then
       rm -rf /tmp/$helmreleasename.yaml
 fi
test=$(helm install --name pluginautomation $chartrepo --version $chartversion --set prescale=yes --dry-run --debug >> /tmp/$helmreleasename.yaml)
findreplacefile=$(sed -i -e "s/pluginautomation/$helmreleasename/g" /tmp/$helmreleasename.yaml)
splitfile=$(cd $DIRECTORY;csplit --digits=2  --quiet --prefix=outfile /tmp/$helmreleasename.yaml "/---/+1" "{*}" --elide-empty-files)

zkstatefulset=""
for  filename in $DIRECTORY/*
 do
 if [[ "$zkscale" == "true" && -z "$zkstatefulset" ]];then
   zkstatefulset=$(grep -H -R "ckaf-zookeeper/templates/statefulset.yaml" $filename | cut -d: -f1 |tee /dev/tty)
 fi
done

 #grep -A 1 ZOOKEEPER_ENSEMBLE $zkstatefulset
 oldzkensemble=$(grep -A 1 ZOOKEEPER_ENSEMBLE $zkstatefulset | sed -e '1d' |  sed -e '/^$/,$d' |sed -e 's/value: //'| sed -e 's/^[ ]*//g')
 newzkensemble=""
 num=`expr $replicacount - 1`
 for i in $(seq  0 1 $num)
 do
   zkensemble=zk-$helmreleasename-$i
   newzkensemble=$newzkensemble$zkensemble";"
 done
 newzkensemble=${newzkensemble%?}
 echo "old zkensemble is $oldzkensemble"
 echo "new zkensemble is $newzkensemble"
 sed -i "s/$oldzkensemble/zookeeperoldensemble/" $zkstatefulset
 #grep zookeeperoldensemble $zkstatefulset
 #grep -A 1 ZOOKEEPER_ENSEMBLE $zkstatefulset 
 echo "Update ZOOKEEPER_ENSEMBLE in $zkstatefulset"
 sed -i "s/zookeeperoldensemble/$newzkensemble/" $zkstatefulset
 #grep -A 1 ZOOKEEPER_ENSEMBLE $zkstatefulset

 #update replica num
 echo "Update replica in $zkstatefulset"
 oldreplicas=$(grep replicas $zkstatefulset | awk '{print $2;}')
 sed -i "s/replicas: $oldreplicas/replicas: $replicacount/" $zkstatefulset

 #cat $zkstatefulset 
}

kfprescalein(){
echo "Enter kfprescalein"
 brokers=""
 for i in $(seq  0 1 `expr $replicacount - 1`)
 do
    logdir=$(kubectl exec kf-$helmreleasename-$i -c ckaf-kafka-broker -- find / -path "/proc" -prune -o -name meta.properties | sed -e '/proc/d')
   echo $logdir
   brokerid=$(kubectl exec kf-$helmreleasename-$i -c ckaf-kafka-broker -- cat $logdir |grep broker.id| sed -e 's/broker.id=//')
   echo $brokerid
   brokers=$brokers$brokerid","
 done

 brokers=${brokers%?} 
 zookeeper_ip=$(kubectl get pods -o wide | grep zk-$helmreleasename-0 | awk '{print $6;}')
 
 $HELM_PLUGIN_DIR/ckaf-reassign-partitions --zookeeper  $zookeeper_ip:2181 --broker $brokers --topic all
}

zkpostscale(){
 echo "Enter zkpostscale"
 if [ $zkscalein == true ];then
  num=`expr $replicacount - 1`
 else
  num=`expr $zkcurrentreplicacount - 1`
 fi

 for i in $(seq 0 1 $num)
 do
   echo "restart pod zk-$helmreleasename-$i"
   kubectl delete pod zk-$helmreleasename-$i
   sleep 120
 done 

 if [ "$zkscalein" == "true" ];then
  echo "zk postscalein enter"
  zkpostscalein
 fi

}
zkpostscalein(){

echo "Enter zkpostscalein"
 kubectl get pvc |grep zk-$helmreleasename
 num=`expr $zkcurrentreplicacount - 1`
 for i in $(seq  $num -1 $replicacount)
 do
   echo "delete pvc d-zk-$helmreleasename-$i"
   kubectl delete pvc d-zk-$helmreleasename-$i
 done

}
kfpostscalein(){
 echo "Enter kfpostscalein"
 kubectl get pvc |grep kf-$helmreleasename 
 num=`expr $kfcurrentreplicacount - 1`
 for i in $(seq  $num -1 $replicacount)
 do
   echo "delete pvc d-kf-$helmreleasename-$i"
   kubectl delete pvc d-kf-$helmreleasename-$i
 done
}

function kol() {
	export ERROR_MSG="$*"
        echo -e "$RED[KO] ${ERROR_MSG}$NORMAL"
}


cleanup(){
  
   if [ -d "$DIRECTORY" ]; then
        rm -rf $DIRECTORY
   fi

   if [ -e /tmp/$helmreleasename.yaml ]; then
       rm -rf /tmp/$helmreleasename.yaml
   fi
   
    if [ -d "temp" ]; then
        rm -rf temp
     fi
   
}

createtempdir(){

     if [ -d "$DIRECTORY" ]; then
        rm -rf $DIRECTORY
     fi
     mkdir $DIRECTORY

     if [ -d "temp" ]; then
        rm -rf temp 
     fi
      mkdir temp 
}

if [[ $# < 2 ]]; then
  usage
  exit 0 

else
echo "helm scale $1 $2" 
     replicacount=$2
    echo " the value of replicaount is $replicacount"
    if !( let replicacount=$2 > /dev/null 2>&1 )
     then
         kol " Enter a valid integer value for replicacount"
         usage
         exit 1
     else
        echo "replicacount has an integer value"
     fi
    
   helmreleasename=$1
   releasevalidation=$(helm list  | grep -w $helmreleasename | awk '{print $1}' | grep -v NAME)
   if [[ ${releasevalidation} == $helmreleasename ]]; then
     echo "its a valid helm release name"
  else
    kol "enter the valid release name  or check the usage for syntax"
    exit 1;
  fi
 
fi 
     

     # directory to hold helm templates 
     DIRECTORY="$helmreleasename"

     # call to the function to create directories 
     createtempdir
    
    # Extracting all the Global values required in the functions
     releasenamespace=$(helm list  | grep $helmreleasename | awk '{print $10}')
     chartnameext=$(helm list  | grep $helmreleasename  | awk '{print $9}' | grep -v NAME)
     chartversion=$(egrep -o '[0-9]+.*' <<< $chartnameext)
     echo "$chartversion"
     chartname=${chartnameext//-$chartversion/}
     echo " chartname is $chartname "
     chartrepo=$(helm search -l $chartname  | grep $chartversion  | awk 'NR==1{print $1}')
     #scale 

     zkscale=false
     kfscale=false
     helm status $helmreleasename | sed -e '1,/StatefulSet/d' | sed -e '1d' | sed -e '/^$/,$d' | awk '{print $1;}' > temp/statefulsets.txt |tee /dev/tty
    echo "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    cat temp/statefulsets.txt
    if grep ^kf temp/statefulsets.txt;then
     kfscale=true
    fi

    if grep ^zk temp/statefulsets.txt;then
     zkscale=true
    fi

    if [[ $# > 2 ]]; then
    case $3 in
      -x)
          appslist="$4" 
          echo " -x was triggered, $appslist" 
          excludelist=$(echo "$appslist" | tr "," "\n")
          for app in $excludelist
          do
            echo "${app}" >> temp/excludelist.txt
          done
           cat temp/excludelist.txt 
           if grep ^kf temp/excludelist.txt;then
             kfscale=false
             echo "kfscale $kfscale"
           fi
 
           if grep ^zk temp/excludelist.txt;then
             zkscale=false
             echo "zkscale $zkscale"
           fi 
          echo "zkscale $zkscale kfscale $kfscale"
          scale 
       ;;
       *)
        usage
        exit 1
    ;;
    esac
    exit 0
  else
    scale 
  fi
 
   

exit 0

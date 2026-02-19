#!/bin/bash

CLEANFILE=/tmp/pts_cleaning.lock

trap 'echo "got sigterm" ;rm -f $CLEANFILE; exit 0' SIGTERM

EXPIRATION_SECONDS=${1:-${PTS_METRICS_EXPIRATION_SECONDS:-300}}
PGW_URL=${2:-${PTS_URL:-http://local-pts-altiplano-pts-pushgateway:9091}}

#
# convert number from scientific notation to standar d( ie  '1.5383780136826127e+09' )
#
function convert_to_standardnotation(){
    printf '%.0f' $1
}

#
# extract_pushgateway_variable 'push_time_seconds{instance="10.32.32.7",job="bk_jenkins"} 1.5383802210997093e+09' 'instance'
#
function extract_pushgateway_variable(){
 local -r _METRIC=$1
 local -r _VARNAME=$2
 echo $_METRIC | sed -r "s/.*${_VARNAME}=\"([^\"]*).*/\\1/g"
}

#
# extract_groupingKey 'push_time_seconds{instance="10.32.32.7",job="bk_jenkins",tag1="value1",tag2="value2"}
# return /tag1/value1/tag2/value2
function extract_groupingKey(){
  local -r _TAGS=$(echo $1 | grep -o -P '(?<={).*(?=})' | sed 's/"//g')
  groupingKey=''
  IFS=',' read -ra ADDR <<< "$_TAGS"
  for tag in "${ADDR[@]}"; do
    if [[ $tag != 'instance='* && $tag != 'job='* ]]; then
      groupingKey+=/$(echo $tag | tr "=" "/")
    fi
  done
  echo $groupingKey
}

#
#
#
function delete_stale_metric(){
   local -r _line=$1
   METRIC_TIME=$(echo $_line | awk '{print $2}' )
   METRIC_TIME=$(convert_to_standardnotation $METRIC_TIME)
   METRIC_AGE_SECONDS=$((CURRENT_TIME-METRIC_TIME))
   if [ "$METRIC_AGE_SECONDS" -gt "$EXPIRATION_SECONDS" ]; then
     metricJob=$(extract_pushgateway_variable "$_line" 'job')
     groupingKey=$(extract_groupingKey "$_line")
     echo "[INFO] Deleting the job $metricJob - grouping key: $groupingKey - age: $METRIC_AGE_SECONDS sec"
     curl -s -X DELETE "$PGW_URL/metrics/job/${metricJob}${groupingKey}"
   fi
}

# main
function main(){
echo "`date` Cleaning stale data from push gateway..."
export CURRENT_TIME=$(date +%s)
METRICS_LIST=$(curl -s  $PGW_URL/metrics | egrep "^push_time_seconds")
echo "$METRICS_LIST" | while  read -r line || [[ -n "$line" ]]; do
   delete_stale_metric "$line"
done
echo "`date` done"
}

#Skip Cleaning if the previously triggered clean is still under progress
#if CLEANFILE file exists, skip the current run
#else, start clean and create cleaning.lock
#after done, rm the file
if [ ! -f $CLEANFILE ]; then
   touch $CLEANFILE
   main || true
   rm -f $CLEANFILE
fi

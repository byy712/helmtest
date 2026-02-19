#!/bin/bash
usage(){
  echo "=================================================================================================================================================="
  echo "Syntax: bash elasticsearch-reindex-unsupported-index.sh [URL | -h | --help] [username] [password]"
  echo "options:"
  echo "URL                   Your URL to access to elasticsearch. EX: https://10.10.10.10/altiplano-elasticsearch/"
  echo "username              Username of elasticsearch"
  echo "password              Password of elasticsearch"
  echo "-h or --help          Print Help"
  echo "Before the 23.3 release, Elasticsearch was recommended for search and indexing. After the release, it is recommended to use IndexSearch instead."
  echo "This script performs the re-index from the old unsupported ES index version to the supported ES index version"
  echo "=================================================================================================================================================="
}
URL=$1
USERNAME=$2
PASSWORD=$3

reIndex_func(){
  source_index="$1"
  destination_index="$2"

  echo "Reindex from [$source_index] to [$destination_index]..."
  REINDEX=$(curl -s -X POST "$URL/_reindex?wait_for_completion=false" \
  -H "Content-Type: application/json" \
  -d '{
    "source": {
      "index": "'"$source_index"'"
    },
    "dest": {
      "index": "'"$destination_index"'"
    }
  }' -k -u"$USERNAME:$PASSWORD" -k -u"$USERNAME:$PASSWORD")

  echo "Confirming that the task of reindexing has been finished successfully..."
  TASK_ID=$(echo "$REINDEX" | jq -r '.task')
  TASK=$(curl -s -X GET "$URL/_tasks/$TASK_ID" -k -u"$USERNAME:$PASSWORD" -k -u"$USERNAME:$PASSWORD")
  IS_COMPLETED=$(echo $TASK | jq -r '.completed')

  while [ "$IS_COMPLETED" == "false" ]
  do
    echo "task_id: $TASK_ID - complete : $IS_COMPLETED "
    TASK=$(curl -s -X GET "$URL/_tasks/$TASK_ID" -k -u"$USERNAME:$PASSWORD" -k -u"$USERNAME:$PASSWORD")
    IS_COMPLETED=$(echo $TASK | jq -r '.completed')
  done
  echo "task_id: $TASK_ID - complete : $IS_COMPLETED "
  echo "Removing the index"
  curl -X DELETE "$URL/$source_index" -k -u"$USERNAME:$PASSWORD"
  echo
  echo "Removed the index"
}

if [ $# -gt 3 ] || [ -z "$1" ]
then
  echo "Illegal number of parameters"
  echo
  usage
elif [ $1 = "--help" -o $1 = "-h" ]
then
  usage
else
  # Get indices
  INDICES=$(curl -s -XGET "$URL/_cat/indices" -k -u"$USERNAME:$PASSWORD" | awk '{print $3}' | cut -d' ' -f1)

  # Remove the parentheses from the string
  INDICES=${INDICES#\(}
  INDICES=${INDICES%\)}
  ARRAY=($INDICES)

  # Identify the index that not suported and reindex it
  for i in "${ARRAY[@]}"
  do
    response=$(curl -s -XGET "$URL/$i/_settings?human" -k -u"$USERNAME:$PASSWORD")
    # Retrieve the value of the variable named "created_string"
    created_string=$(echo "$response" | jq -r '.[].settings.index.version.created_string')
    if [[ ("${created_string}" > "7.0.0" && "${created_string}" < "8.0.0") ]]; then
      continue
    else
      echo "Index '$i' with created_string: ${created_string}"
      reIndex_func "$i" "index-tmp"
      reIndex_func "index-tmp" "$i"
    fi
  done
fi


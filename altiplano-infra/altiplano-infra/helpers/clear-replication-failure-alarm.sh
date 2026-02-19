#!/bin/sh

echo "$(date) - Clearing the replication failure alarm ..."
kubectl exec altiplano-kafka-0 -c ckaf-kafka-broker -- bash -c "echo '{\"alarm\": {\"task\": \"notify\", \"name\": \"RMT_REPL_BROKEN\", \"text\": \"Remote DC replication broken\", \"probable-cause\": \"306\", \"key\": \"3000609\", \"event-type\": \"2\", \"data\": \"Thread Running (IO,SQL) = (Connecting,Yes), Last IO Errno=2003\", \"id\": 3000609, \"severity\": \"CLEARED\"}}' | bin/kafka-console-producer.sh --broker-list localhost:9092 --producer.config /etc/kafka/kafka.properties --topic ALTIPLANO_INTERNAL_maxscale-alarm $1 2> >(grep -v WARN)"
echo "$(date) - done!!"

# Apache Kafka Helm Chart

## Pre Requisites:

* Kubernetes 1.3 with alpha APIs enabled and support for storage classes

* PV support on underlying infrastructure

* Requires at least `v2.0.0-beta.1` version of helm to support
  dependency management with requirements.yaml

## StatefulSet Details

* https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/

## StatefulSet Caveats

* https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#limitations

## Chart Details

This chart will do the following:

* Implement a dynamically scalable kafka cluster using Kubernetes StatefulSets

* Implement a dynamically scalable zookeeper cluster as another Kubernetes StatefulSet required for the Kafka cluster above

### Installing the Chart

To install the chart with the release name `my-kafka` in the default
namespace:

```
$ helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator
$ helm install --name my-kafka incubator/kafka
```

If using a dedicated namespace(recommended) then make sure the namespace
exists with:

```
$ kubectl create ns kafka
$ helm install --name my-kafka --set global.namespace=kafka incubator/kafka
```

This chart includes a ZooKeeper chart as a dependency to the Kafka
cluster in its `requirement.yaml`. The chart can be customized using the
following configurable parameters:

| Parameter                         | Description                                      | Default Value                                        |
| --------------------------------- | ------------------------------------------------ | ---------------------------------------------------- |
| global.registry                   | Used for kafka-broker container image            | csf-docker-delivered.repo.cci.nokia.net  |
| global.registry1                  | Used for jmx-exporter container image            | csf-docker-delivered.repo.cci.nokia.net  |
| global.registry2                  | Used for cbur-agent container image              | csf-docker-delivered.repo.cci.nokia.net  |
| global.registry3                  | Used for pre/post hook container image           | csf-docker-delivered.repo.cci.nokia.net  |
| global.registry4                  | Not used yet, reserved for future                | nil                                                  |
| global.registry5                  | Not used yet, reserved for future                | nil                                                  |
| global.seccompAllowedProfileNames | Secure Computing Mode Allowed for these profiles | runtime/default                                      |
| global.seccompDefaultProfileName  | Secure Computing Default Profile                 | runtime/default                                      |
| global.storageClass               | Global Storage Class for dynamic provisioning    | default                                              |
| global.rbac.enabled                                | Enables Role based Access control Authorization                              | TRUE                |
| global.forceUpgrade                                | Enable this flag to forcefully upgrade kafka                                 | FALSE               |
| global.prepareRollback                             | Enable this flag to prepare kafka for rollback                               | FALSE               |
| global.preheal                                     | Kafka preheal job will spawns during install if value is greater than 0      | 0                   |
| global.postheal                                    | Kafka postheal job will spawns during install if value is greater than 0     | 0                   |
| global.clog.enabled                                | CSF Logging Solution On/Off                                                  | TRUE                |
| global.jobhook.enabled                             | Backup Restore Hooks Switch                                                  | TRUE                |
| global.jobtimeout                                  | JobTimeout For Scale Event                                                   | 600                 |
| global.istio.version                               | Supports istio version > 1.4                                                 | 1.6                 |
| global.istio.enabled                               | Setting "enabled true" injects istio proxy side cars to the kafka pods       | FALSE               |
| global.istio.createDrForClient                     | Creates a Destination rule for kafka workload with tls mode as "DISABLE"     | FALSE               |
| global.istio.cni.enabled                           | Whether istio cni is enabled in the environment                              | TRUE                |
| global.istio.mtls.enabled                          | Is strict MTLS enabled in the environment                                    | TRUE                |
| global.istio.permissive                            | Should allow mutual TLS as well as clear text for your deployment            | FALSE               |
| global.enable_scale_via_upgrade                    | enable this flag to perform scale via upgrade                                | FALSE               |
| global.priorityClassName                           | Set a priority for a Pod using the PriorityClass |                                           |
| <workload>.priorityClassName                       | Workload level PriorityClass takes higher predence than global.priorityClassName|                                           |
| Replicas                                           | Number of replicas for kafka brokers                                         | 3                   |
| serviceAccountName                                 | precreated Service Account Name                                              | nil                 |
| clusterDomain                                      | Kubernetes cluster domain name                                               | cluster.local       |
| imageRepo                                          | Image Repository Path after the registry                                     | "ckaf/kafka"        |
| imageTag                                           | Image version                                                                | "4.1.0-5.4.1-3837"  |
| InterBrokerProtocolVersion                         | Communication among Broker Replicas Version                                  | nil                 |
| LogMessageFormatVersion                            | Message Format Version                                                       | nil                 |
| imagePullPolicy                                    | How the Image should be pulled                                               | "IfNotPresent"      |
| kubectlImage                                       | kubectl Image path                                                           | "tools/kubectl"     |
| kubectlTag                                         | kubectl version                                                              | "v1.14.3-nano"      |
| resources.requests.cpu                             | CPU for Kafka broker wanted                                                  | 500m                |
| resources.requests.memory                          | Memory for Kafka broker wanted                                               | 2Gi                 |
| resources.limits.cpu                               | Upper Limit for CPU that can be assigned                                     | 1                   |
| resources.limits.memory                            | Upper Limit for memory that can be assigned                                  | 4Gi                 |
| podManagementPolicy                                | Pods Management Policy                                                       | OrderedReady        |
| antiAffinity                                       | Soft Or Hard , Affects the reschedulability                                  | "hard"              |
| timezone.mountHostLocaltime                        | To ensure that data & logs are in sync among pods & hosted components        | TRUE                |
| kafkaNodeSelector.enable                           | Enable to use node label feature                                             | FALSE               |
| kafkaNodeSelector.nodeLabel                        | Put a "key1" "value1" under this , if user defined labels are desired        | nil                 |
| tolerationsForTaints.enable                        | Enable/Disable switch                                                        | FALSE               |
| tolerationsForTaints.tolerations                   | Multiple tolerations can be added , an example is below                      | nil                 |
| tolerationsForTaints.tolerations.key               | Label                                                                        | <"key1">            |
| tolerationsForTaints.tolerations.operator          | Operators                                                                    | <"Equal">           |
| tolerationsForTaints.tolerations.value             | Value for operator and key                                                   | <"val1">            |
| tolerationsForTaints.tolerations.effect            | Which Toleration Effect should occure                                        | <"NoSchedule">      |
| ingress.enableExternalAccess                       | Allows the user to access Kafka broker's outside the k8s                     | FALSE               |
| ingress.startPortRangeOnEdgeNode                   | Port on all edge nodes available for kafka brokers                           | nil                 |
| ingress.IngressConfigMap.citmPrefixName              | citm chart configmap prefix name on k8s cluster                               | nil                 |
| ingress.externalServiceName                        | External Service Name                                                        | nil                 |
| ingress.disableIstioTls                            | Disable Istio tls                                                            | FALSE               |
| security.enabled                                   | Security Enable Switch                                                       | TRUE                |
| security.runAsUser                                 | Run As this User ID which will run withing the pod                           | 999                 |
| security.fsGroup                                   | User Group for schema registry                                               | 998                 |
| security.runAsGroup                                | Specifies the primary group ID for all process within any conainers of a pod | 997                 |
| security.supplementalGroups                        | Other Non primary Groups                                                     | nil                 |
| security.seLinuxOptions.enabled                    | Security Context for Pods to be enabled or not                               | FALSE               |
| security.seLinuxOptions.level                      | seLinux level label that applies to container                                | nil                 |
| security.seLinuxOptions.role                       | seLinux role label that applies to container                                 | nil                 |
| security.seLinuxOptions.type                       | seLinux type label that applies to container                                 | nil                 |
| security.seLinuxOptions.user                       | seLinux user label that applies to container                                 | nil                 |
| DataStorage                                        | Storage Space For Data                                                       | "10Gi"              |
| LogStorage                                         | Storage Space For Log                                                        | "10Gi"              |
| JmxExporter.imageRepo                              | Image Repository path to be added after the jmx registry                     | "cpro/jmx-exporter" |
| JmxExporter.imageTag                               | Image version                                                                | "v2.2.0"            |
| JmxExporter.imagePullPolicy                        | Image Pull Policy                                                            | "IfNotPresent"      |
| JmxExporter.port                                   | Port Number                                                                  | 7071                |
| JmxExporter.jmxResources.resources.requests.cpu    | CPU requested for JmxExporter                                                | 100m                |
| JmxExporter.jmxResources.resources.requests.memory | memory requested for JmxExporter                                             | 1Gi                 |
| JmxExporter.jmxResources.resources.limits.cpu      | Max CPU that can be requested for JmxExporter                                | 1                   |
| JmxExporter.jmxResources.resources.limits.memory   | Max memory that can be requested for JmxExporter                             | 4Gi                 |
| jobResources.requests.cpu                 | CPU requested for job                                                           | 200m                  |
| jobResources.requests.memory              | memory requested for job                                                        | 1Gi                   |
| jobResources.limits.cpu                   | Max CPU that can be requested for job                                           | 1                     |
| jobResources.limits.memory                | Max memory that can be requested for job                                        | 4Gi                   |
| KafkaPort                                 | Port For Kafka                                                                  | 9092                  |
| UncleanLeaderElectionEnable               | Allow out of sync replica to be elected when there is no live in-sync replica   | "false"               |
| AutoCreateTopicsEnable                    | Topics get created automatically if message belonging to no existing topic      | "true"                |
| DefaultReplicationFactor                  | Replication Factor                                                              | "1"                   |
| GroupInitialRebalanceDelayMs              | Delay for Group Initial Rebalance                                               | "0"                   |
| NumRecoveryThreadsPerDataDir              | Used by log Manager for log recovery                                            | "1"                   |
| TransactionStateLogReplicationFactor      | Replication Factor for transaction topic                                        | "1"                   |
| TransactionStateLogMinIsr                 | Controls the minimum ISR(In Sync Replica) for a topic                           | "1"                   |
| BackgroundThreads                         | Number of background Threads                                                    | "10"                  |
| MessageMaxBytes                           | Message Capacity                                                                | "1000012"             |
| NumIoThreads                              | Number of threads doing disk I/O                                                | "8"                   |
| NumNetworkThreads                         | Number of threads handling network requests                                     | "3"                   |
| QueuedMaxRequests                         | How many Requests can be queued                                                 | "500"                 |
| SocketSendBufferBytes                     | Send buffer (SO_SNDBUF) used by the socket server                               | "102400"              |
| SocketReceiveBufferBytes                  | Receive buffer (SO_RCVBUF) used by the socket server                            | "102400"              |
| SocketRequestMaxBytes                     | Maximum size of a request that the socket server will accept                    | "104857600"           |
| NumReplicaFetchers                        | Number of Fetcher threads used to replicate messages                            | "1"                   |
| ReplicaFetchMaxBytes                      | Number of bytes of messages to attempt to fetch for each partition              | "1048576"             |
| ReplicaFetchWaitMaxMs                     | Max wait time for each fetcher request issued by follower replicas              | "500"                 |
| ReplicaHighWatermarkCheckpointIntervalMs  | Frequency with which the high watermark is saved out to disk                    | "5000"                |
| ReplicaSocketTimeoutMs                    | Socket timeout for network requests                                             | "30000"               |
| ReplicaSocketReceiveBufferBytes           | Socket receive buffer for network requests                                      | "65536"               |
| ReplicaLagTimeMaxMs                       | If a follower hasn't sent or fetch anything then it will be removed after       | "10000"               |
| ControllerSocketTimeoutMs                 | Socket timeout for controller-to-broker channels                                | "30000"               |
| NumPartitions                             | Default number of log partitions per topic                                      | "1"                   |
| OffsetsTopicReplicationFactor             | Replication factor for the offsets topic                                        | "3"                   |
| CompressionType                           | Specify the final compression type for a given topic                            | "producer"            |
| LogIndexIntervalBytes                     | Interval with which we add an entry to the offset index                         | "4096"                |
| LogIndexSizeMaxBytes                      | Maximum size in bytes of the offset index                                       | "10485760"            |
| LogRetentionHours                         | Number of hours to keep a log file before deleting it                           | "168"                 |
| LogRetentionBytes                         | Maximum size of the log before deleting it                                      | "-1"          |
| LogFlushIntervalMs                        | Maximum time that any message is kept in memory before flushed to disk          | "1000"                |
| LogFlushIntervalMessages                  | Number of messages accumulated on a log partition before flushed to disk        | "10000"               |
| LogFlushSchedulerIntervalMs               | Frequency in ms that the log flusher checks whether any log to be flushed       | "9223372036854775807" |
| LogRollHours                              | Maximum time before a new log segment is rolled out                             | "168"                 |
| LogRetentionCheckIntervalMs               | Frequency that the log cleaner checks if any log is eligible for deletion       | "300000"              |
| LogSegmentBytes                           | Transaction topic segment bytes                                                 | "1073741824"          |
| LogCleanerBackoffMs                       | Amount of time to sleep when there are no logs to clean                         | "15000"               |
| LogCleanerThreads                         | Number of background threads to use for log cleaning                            | "1"                   |
| LogCleanerEnable                          | Log cleaner process Switch                                                      | "true"                |
| LogCleanupPolicy                          | Cleanup policy for segments beyond the retention window                         | "delete"              |
| LogLevel                                  | Log level select                                                                | "INFO"                |
| MaxFileSize                               | Kafka Maximum File Size for logging files                                       | 50MB                  |
| MaxBackupIndex                            | Kafka Maximum Backup Index for logging files                                    | 10                    |
| AutoPvEnabledKafka                        | Switch to enable custom Persistant volume                                       | FALSE                 |
| AutoPvEnabledLabelKafka                   | Label for that PV                                                               | kafka                 |
| KafkaHeapOpts                             | Set custom heap options                                                         | "-Xmx1G -Xms1G"       |
| ZookeeperConnectionTimeoutMs              | Max time that the client waits to establish a connection to zookeeper           | "6000"                |
| ZookeeperSyncTimeMs                       | How far a ZK follower can be behind a ZK leader                                 | "2000"                |
| FetchPurgatoryPurgeIntervalRequests       | Purge interval (in number of requests) of the fetch request purgatory           | "1000"                |
| ProducerPurgatoryPurgeIntervalRequests    | Purge interval (in number of requests) of the producer request purgatory        | "1000"                |
| ZookeeperSessionTimeoutMs                 | Zookeeper session timeout                                                       | "6000"                |
| ZookeeperSetAcl                           | Set client to use secure ACLs                                                   | "false"               |
| DeleteTopicEnable                         | Enables delete topic                                                            | "true"                |
| AutoLeaderRebalanceEnable                 | Background thread checks distribution of partition leaders at regular intervals | "true"                |
| LeaderImbalanceCheckIntervalSeconds       | Frequency with which partition rebalance check is triggered by the controller   | "300"                 |
| QuotaConsumerDefault                      | Any consumer will get throttled if it fetches more bytes than                   | "9223372036854775807" |
| QuotaProducerDefault                      | Any producer will get throttled if it produces more bytes than                  | "9223372036854775807" |
| MinInsyncReplicas                         | Min No of replicas that must acknowledge a write for the it to be successful    | 1                     |
| kafkaJmxPort                              | Set the port to enable kafka's own jmx                                          | nil                   |
| configurationOverrides                    | Override confluent kafka configurations                                         | nil                   |
| zkConnect                                 | If zookeeper not installed as part of the chart, then zookeeper to be added     | nil                   |
| listenerSecurityMode.internalSecurityMode | Security modes PLAINTEXT, SSL, SASL_PLAINTEXT, SASL_SSL                         | PLAINTEXT             |
| listenerSecurityMode.externalSecurityMode | "ingressenableExternalAccess" must be enabled for this                          | PLAINTEXT             |
| zkAclAuthorizer.enable                    | Turn on the zk acl authorizer                                                   | FALSE                 |
| zkAclAuthorizer.superUsers                | Prefix 'User:' must be used for every super user                                | "User:<principal>"    |
| zkAclAuthorizer.allowEveryoneIfNoAcl      | If set to true and there is no ACL then it will allow all super users           | FALSE                 |
| sasl.enable                               | Enable SASL mechanism                                                           | FALSE                 |
| sasl.mechanism                            | Saslmechanism: "GSSAPI" or "PLAIN"                                              | "GSSAPI"              |
| sasl.basePath                             | Base Path Directory                                                             | "/etc/kafka"          |
| sasl.krb.krbConfigmapName                 | kerboros Configmap name                                                         | krb5.conf             |
| sasl.krb.KrbConfKeyName                   | kerboros config key name                                                        | ""                    |
| sasl.krb.krbRealm                         | kerboros realm name                                                             | "EXAMPLE.COM"         |
| sasl.krb.secretName                       | kerboros Secret Name                                                     | <krb-keytabs-secret-name>    |
| sasl.plain.secretName                     | ckey secret name                                                         | plain-admin-pass             |
| sasl.plain.usernameKey                    | ckey username                                                            | userkey                      |
| sasl.plain.passwordKey                    | ckey password key                                                        | passkey                      |
| sasl.plain.superUsers                | Comma seperated list of users(with admin/super priveleges) which are allowed  | "User:kafka-admin@kafka.com" |
| sasl.plain.keyCloakConfig.secretName                |                Name of the keycloak confile files              | plain-keycloak-config-files  |
| sasl.plain.keyCloakConfig.enableOAuth2AclAuthorizer | Authorization from keycloak can enabled or disabled by this flag                      | FALSE           |
| ssl.enable                                          | Enable SSL encryption                                                                 | FALSE           |
| ssl.secret_name                                     | Put secret name configured according to kubernetes                                    | <secret-name>   |
| ssl.keystore_key                                    | Key store Key                                                                         | keyStore        |
| ssl.truststore_key                                  | Truststore Key                                                                        | trustStore      |
| ssl.truststore_passwd_key                           | Truststore Password Key                                                               | trustStorePass  |
| ssl.keystore_passwd_key                             | Keystore Password Key                                                                 | keyPass         |
| ssl.keystore_key_passwd_key                         | Keystore Key Password Key                                                             | keyStorePass    |
| ssl.enabledProtocols                                | List of protocols enabled for SSL connections                                         | TLSv1.2,TLSv1.3 |
| ssl.Protocol                                        | The SSL protocol used to generate the SSLContext                                      | TLSv1.2         |

| ssl.keyStoreType                                    | File format of the key store file                                                     | JKS             |
| ssl.trustStoreType                                  | File format of the trust store file                                                   | JKS             |
| ssl.SecurityInterBrokerProtocol                     | Security protocol used to communicate between brokers                                 | SSL             |
| ssl.securityProtocols                               | Protocol used to communicate with brokers                                             | SSL             |
| ssl.secureRamdomImpl                                | Which SecureRandom PRNG implementation to use                                         | SHA1PRNG        |
| ssl.clientAuth                                      | Client authentication is required                                                     | required        |
| deleteKafkaJob.auto_remove_kf_pvc                   | Remove PVC (Persistant Volume Claim)                                                  | TRUE            |
| deleteKafkaJob.auto_remove_kf_secret                | Remove Secrets                                                                        | FALSE           |
| lcm.scale_timeout                                   | lcm scale job timeout                                                                 | 600             |
| lcm.heal.timeout                                    | lcm heal job timeout                                                                  | 600             |
| throttle                                            | Kafka Throttle time in ms                                                             | 1000            |
| selective_heal.enable                               | Selectively heal the pod                                                              | FALSE           |
| selective_heal.pod_list                             | Pod numbers seperated by "/"                                                          | nil             |
| enable_upgrade_hook                                 | Upgrade configuration                                                                 | FALSE           |
| upgrade.CURRENT_KAFKA_VERSION                       | To which kafka version you want to upgrade                                            | 1.0.0           |
| enableRollback                                      | Rollback configuration                                                                | FALSE           |
| cbur.name                                           | cbur image name                                                                       | cbura-sidecar   |
| cbur.enabled                             | enable or disable cbur container                                                                 | true|
| cbur.image                                          | cbur image directory path after registry                                              | cbur/cbura      |
| cbur.tag                                            | cbur image version                                                                    | 1.0.3-1665      |
| cbur.imagePullPolicy                                | Which Image pull policy should be used                                                | IfNotPresent    |
| cbur.resources.requests.cpu                         | CPU requested by CBUR                                                                 | 200m            |
| cbur.resources.requests.memory                      | Memory requested by CBUR                                                              | 1Gi             |
| cbur.resources.limits.cpu                           | Upper Limit for CPU requested by CBUR                                                 | 1               |
| cbur.resources.limits.memory                        | Upper Limit for memory requested by CBUR                                              | 4Gi             |
| cbur.maxCopy                                        | Number of copies that can be save                                                     | 5               |
| cbur.backendMode                                    | Modes supported now: "local","NETBKUP","AVAMAR", case insensitive                     | "local"         |
| cbur.cronJob                                        | Same format of cron job setting                                                       | "0 23 * * *"    |
| cbur.backupTopics                                   | Provide the list of metadata topics to be backuped in comma seperated                 | "_schemas"      |
| livenessProbe.initialDelaySeconds                   | Liveness Probe Initial Delay                                                          | 30              |
| livenessProbe.timeoutSeconds                        | Liveness Probe Timeout                                                                | 5               |
| readinessProbe.initialDelaySeconds                  | Readiness Probe Initial Delay                                                         | 30              |
| readinessProbe.timeoutSeconds                       | Readiness Probe Timeout                                                               | 5               |
| ----------------------------------------------------|-------------------------------------------------------------------------------------- |-----------------|
| Configuration override params                                                                                                                                 |
| ----------------------------------------------------|-------------------------------------------------------------------------------------- |-----------------|
| log.dirs                                            | Directory in which the log data is kept                                               | /tmp/kafka-logs |
| zookeeper.connect                                   | Specifies the ZooKeeper connection string in the form hostname:port                   | nil             |
| advertised.listeners               | Listeners to publish to ZooKeeper for clients to use, if different than the listeners config property  | nil             |
| background.threads                                  | Number of threads to use for various background processing tasks                      | 10              |
| control.plane.listener.name                         | Name of listener used for communication between controller and brokers                | nil             |
| leader.imbalance.per.broker.percentage              | Ratio of leader imbalance allowed per broker                                          | 10              |
| listeners                                           | List of comma-separated URLs the REST API will listen on                              | nil             |
| log.flush.offset.checkpoint.interval.ms       | Frequency with which we update the persistent record of the last flush                       | 60000   |
| log.flush.start.offset.checkpoint.interval.ms | Frequency with which we update the persistent record of log start offset                     | 60000   |
| log.retention.minutes                         | Number of minutes to keep a log file before deleting it in minutes                           | nil     |
| log.retention.ms                              | Number of milliseconds to keep a log file before deleting it (in milliseconds)               | nil     |
| log.roll.jitter.ms                            | Maximum jitter to subtract from logRollTimeMillis (in milliseconds)                          | nil     |
| log.roll.ms                                   | Maximum time before a new log segment is rolled out (in milliseconds)                        | nil     |
| log.segment.delete.delay.ms                   | Amount of time to wait before deleting a file from the filesystem                            | 60000   |
| num.replica.alter.log.dirs.threads            | Number of threads that can move replicas between log directories                             | nil     |
| offset.metadata.max.bytes                     | Maximum size for a metadata entry associated with an offset commit                           | 4096    |
| offsets.commit.required.acks                  | Required acks before the commit can be accepted                                              | -1      |
| offsets.commit.timeout.ms                     | Offset commit will be delayed until all replicas for the offsets topic receive the commit    | 5000    |
| offsets.load.buffer.size                      | Batch size for reading from the offsets segments when loading offsets into the cache         | 5242880 |
| offsets.retention.check.interval.ms           | Frequency at which to check for stale offsets                                                | 600000  |
| offsets.retention.minutes                     | If consumer group loses all its consumers its offsets will be kept for this retention period | 10080   |
| offsets.topic.compression.codec               | Compression codec for the offsets topic - compression may be used to achieve "atomic" commits | 0         |
| offsets.topic.num.partitions                  | Number of partitions for the offset commit topic                                              | 50        |
| offsets.topic.segment.bytes                   | Offsets topic segment bytes size                                                              | 104857600 |
| replica.fetch.min.bytes                       | Minimum bytes expected for each fetch response                                                | 1         |
| replica.high.watermark.checkpoint.interval.ms | Frequency with which the high watermark is saved out to disk                                  | 5000      |
| replica.lag.time.max.ms                | Leader will remove the follower from isr if it has not fetched or consumed anything within this time | 10000   |
| replica.socket.receive.buffer.bytes    | Socket receive buffer for network requests                                                           | 65536   |
| replica.socket.timeout.ms              | Socket timeout for network requests                                                                  |  30000  |
| request.timeout.ms                     | Maximum amount of time the client will wait for the response of a request                            | 30000   |
| transaction.max.timeout.ms             | Maximum allowed timeout for transactions                                                             | 900000  |
| transaction.state.log.load.buffer.size | Batch size for reading from the transaction log segments when loading producer ids and transactions  | 5242880 |
| transaction.state.log.num.partitions | Number of partitions for the transaction topic                                                              | 50       |
| transaction.state.log.segment.bytes  | Transaction topic segment bytes size                                                                        | 104857600|
| transactional.id.expiration.ms       | Time in ms that the transaction coordinator will wait without receiving any transaction status updates      | 604800000|
| zookeeper.max.in.flight.requests     | Maximum number of unacknowledged requests the client will send to Zookeeper before blocking                 | 10       |
| broker.id.generation.enable          | Enable automatic broker id generation on the server                                                         | TRUE     |
| broker.rack                          | Rack of the broker                                                                                          | nil      |
| connections.max.idle.ms              | Idle connections timeout: the server socket processor threads close the connections that idle more than this| 600000   |
| connections.max.reauth.ms            | When a positive number,session lifetime will be communicated to v220+ clients when they authenticate        | 0        |
| controlled.shutdown.enable           | Enable controlled shutdown of the server                                                                    | TRUE     |
| controlled.shutdown.max.retries      | Controlled shutdown can fail for multiple reasons                                                           | 3        |
| controlled.shutdown.retry.backoff.ms | This config determines the amount of time to wait before retrying                                           | 5000     |
| delegation.token.expiry.time.ms      | Token validity time in miliseconds before the token needs to be renewed                                     | 86400000 |
| delegation.token.master.key          | Master/secret key to generate and verify delegation tokens                                                  | nil      |
| delegation.token.max.lifetime.ms     | Token has a maximum lifetime beyond which it cannot be renewed anymore                                      | 604800000|
| delete.records.purgatory.purge.interval.requests  | Purge interval (in number of requests) of the delete records request purgatory | 1          |
| group.max.session.timeout.ms                      | Maximum allowed session timeout for registered consumers                       | 1800000    |
| group.max.size                                    | Maximum number of consumers that a single consumer group can accommodate       | 2147483647 |
| group.min.session.timeout.ms                      | Minimum allowed session timeout for registered consumers                       | 6000       |
| inter.broker.listener.name                        | Name of listener used for communication between brokers                        | nil        |
| log.cleaner.dedupe.buffer.size                    | Total memory used for log deduplication across all cleaner threads             | 134217728  |
| log.cleaner.delete.retention.ms                   | Amount of time to retain delete tombstone markers for log compacted topics     | 86400000   |
| log.cleaner.io.buffer.load.factor                 | Log cleaner dedupe buffer load factor                                          | 0.9        |
| log.cleaner.io.buffer.size                        | Total memory used for log cleaner I/O buffers across all cleaner threads       | 524288     |
| log.cleaner.io.max.bytes.per.second      | Log cleaner will be throttled if sum of read & write i/o < value on average | 1.7976931348623157E308 |
| log.cleaner.max.compaction.lag.ms        | Max time a message will remain ineligible for compaction in the log         | 9.22337E+18            |
| log.cleaner.min.cleanable.ratio          | Min ratio of dirty log to total log for a log to eligible for cleaning      | 0.5                    |
| log.cleaner.min.compaction.lag.ms        | Min time a message will remain uncompacted in the log                       | 0                      |
| log.message.timestamp.difference.max.ms   | Max difference allowed between the timestamp when a broker receives message & timestamp in it     | 9.22337E+18 |
| log.message.timestamp.type                | Define whether the timestamp in the message is message create time or log append time             | CreateTime  |
| log.preallocate                           | Pre allocate file when create new segment? For Windows user, you probably need to set it to true  | FALSE       |
| max.connections                           | Maximum number of connections we allow in the broker at any time                                  | 2147483647  |
| max.connections.per.ip                    | Maximum number of connections we allow from each ip address                                       | 2147483647  |
| max.connections.per.ip.overrides          | Comma-separated list of per-ip or hostname overrides to the default maximum number of connections | ""          |
| max.incremental.fetch.session.cache.slots | Maximum number of incremental fetch sessions that we will maintain                                | 1000        |
| password.encoder.old.secret               | Old secret that was used for encoding dynamically configured passwords                            | nil         |
| password.encoder.secret                   | Secret used for encoding dynamically configured passwords for this broker                         | nil         |
| principal.builder.class                   | Fully qualified name of a class that implements the KafkaPrincipalBuilder interface               | nil         |
| queued.max.request.bytes                  | Number of queued bytes allowed before no more requests are read                                   | -1          |
| replica.fetch.backoff.ms                  | Amount of time to sleep when fetch partition error occurs                                         | 1000        |
| replica.fetch.response.max.bytes          | Maximum bytes expected for the entire fetch response                                              | 10485760    |
| replica.selector.class                    | Fully qualified class name that implements ReplicaSelector                                        | nil         |
| reserved.broker.max.id                    | Max number that can be used for a brokerid                                                        | 1000        |
| sasl.client.callback.handler.class        | SASL client callback handler class that implements the AuthenticateCallbackHandler interface      | nil         |
| sasl.enabled.mechanisms                   | List of SASL mechanisms enabled in the Kafka server                                               | GSSAPI      |
| sasl.jaas.config                          | JAAS login context parameters for SASL connections in the format used by JAAS configuration files | nil         |
| sasl.kerberos.kinit.cmd                     | Kerberos kinit command path                                                                    | /usr/bin/kinit |
| sasl.kerberos.min.time.before.relogin       | Login thread sleep time between refresh attempts                                               | 60000          |
| sasl.kerberos.principal.to.local.rules      | List of rules for mapping from principal names to short names                                  | DEFAULT        |
| sasl.kerberos.service.name                  | Kerberos principal name that Kafka runs as                                                     | nil            |
| sasl.kerberos.ticket.renew.jitter           | Percentage of random jitter added to the renewal time                                          | 0.05           |
| sasl.kerberos.ticket.renew.window.factor    | Login thread will try to renew the ticket after window factor of this much time                | 0.08           |
| sasl.login.callback.handler.class           | SASL login callback handler class that implements the AuthenticateCallbackHandler interface    | nil            |
| sasl.login.class                            | Fully qualified name of a class that implements the Login interface Class                      | nil            |
| sasl.login.refresh.buffer.seconds           | Amount of buffer time before credential expiration to maintain when refreshing a credential    | 300            |
| sasl.login.refresh.min.period.seconds       | Desired minimum time for the login refresh thread to wait before refreshing a credential       | 60             |
| sasl.login.refresh.window.factor            | Login refresh thread will try to refresh the credential after this much window factor of time  | 0.8            |
| sasl.login.refresh.window.jitter            | Max amount of random jitter wrt credential's lifetime ie added to login refresh thread's sleep | 0.05           |
| sasl.mechanism.inter.broker.protocol        | SASL mechanism used for inter-broker communication                                             | GSSAPI         |
| sasl.server.callback.handler.class          | SASL server callback handler class that implements the AuthenticateCallbackHandler interface   | nil            |
| security.inter.broker.protocol              | Security protocol used to communicate between brokers                                          | PLAINTEXT      |
| ssl.cipher.suites                           | List of cipher suites                                                                          | nil            |
| ssl.key.password                            | Password of the private key in the key store file                                              | nil            |
| ssl.keymanager.algorithm                    | Algorithm used by key manager factory for SSL connections                                      | SunX509        |
| ssl.keystore.location                       | Location of the key store file                                                                 | nil            |
| ssl.keystore.password                       | Store password for the key store file                                                          | nil            |
| ssl.protocol                                | SSL protocol used to generate the SSLContext                                                   |  TLS           |
| ssl.provider                                | Name of the security provider used for SSL connections                                         | nil            |
| ssl.trustmanager.algorithm                  | Algorithm used by trust manager factory for SSL connections                                    | nil            |
| ssl.truststore.location                     | Location of the trust store file                                                               | nil            |
| ssl.truststore.password                     | Password for the trust store file                                                              | nil            |
| alter.config.policy.class.name              | Alter configs policy class that should be used for validation                                  | nil            |
| alter.log.dirs.replication.quota.window.num | Number of samples to retain in memory for alter log dirs replication quotas                    | 11             |
| alter.log.dirs.replication.quota.window.size.seconds | Time span of each sample for alter log dirs replication quotas                        | 1       |
| authorizer.class.name                                | Class that implements sorgapachekafkaserverauthorizerAuthorizer interface             | nil     |
| client.quota.callback.class                          | Fully qualified name of a class that implements the ClientQuotaCallback interface     | nil     |
| connection.failed.authentication.delay.ms            | Connection close delay on failed authentication within is the time (in ms)            | 100     |
| create.topic.policy.class.name                       | Create topic policy class that should be used for validation                          | nil     |
| delegation.token.expiry.check.interval.ms            | Scan interval to remove expired delegation tokens                                     | 3600000 |
| kafka.metrics.polling.interval.secs                  | Metrics polling interval which can be used in kafka.metrics.reporters implementations | 10      |
| kafka.metrics.reporters                              | List of classes to use as Yammer metrics custom reporters                             | nil     |
| listener.security.protocol.map  | Listener names security protocols map | PLAINTEXT:PLAINTEXT,SSL:SSL,SASL_PLAINTEXT:SASL_PLAINTEXT,SASL_SSL:SASL_SSL  |
| log.message.downconversion.enable | Controls whether down-conversion of message formats is enabled to satisfy consume requests     | TRUE                 |
| metric.reporters                  | List of classes to use as metrics reporters                                                    | nil                  |
| metrics.num.samples               | Number of samples maintained to compute metrics                                                | 2                    |
| metrics.recording.level           | Highest recording level for metrics                                                            | INFO                 |
| metrics.sample.window.ms          | Window of time a metrics sample is computed over                                               | 30000                |
| password.encoder.cipher.algorithm | Cipher algorithm used for encoding dynamically configured passwords                            | AES/CBC/PKCS5Padding |
| password.encoder.iterations       | Iteration count used for encoding dynamically configured passwords                             | 4096                 |
| password.encoder.key.length       | Key length used for encoding dynamically configured passwords                                  | 128                  |
| password.encoder.keyfactory.algorithm | SecretKeyFactory algorithm used for encoding dynamically configured passwords                    | nil     |
| quota.window.num                      | Number of samples to retain in memory for client quotas                                          | 11      |
| quota.window.size.seconds             | Time span of each sample for client quotas                                                       | 1       |
| replication.quota.window.num          | Number of samples to retain in memory for replication quotas                                     | 11      |
| replication.quota.window.size.seconds | Time span of each sample for replication quotas                                                  | 1       |
| security.providers                    | List of configurable creator classes each returning a provider implementing security algorithms  | nil     |
| ssl.endpoint.identification.algorithm | Endpoint identification algorithm to validate server hostname using server certificate           | https   |
| ssl.principal.mapping.rules           | List of rules for mapping from distinguished name from the client certificate to short name      | default |
| ssl.secure.random.implementation      | SecureRandom PRNG implementation to use for SSL cryptography operations                          | nil     |
| transaction.abort.timed.out.transaction.cleanup.interval.ms | Interval at which to rollback transactions that have timed out                   | 60000   |
| transaction.remove.expired.transaction.cleanup.interval.ms  | When to remove transactions that have expired due to transactionalidexpirationms | 3600000 |



# PodDisruptionBudget Configuration

The input PDB values (minAvailable/maxUnavailable) should be set based on the below two parameters defined in the values.yaml
DefaultReplicationFactor: "1"
OffsetsTopicReplicationFactor: "3"

chartMinAvailable => maximum of ( DefaultReplicationFactor or OffsetsTopicReplicationFactor)
chartMaxUnAvailable => Replicas minus chartMinAvailable

Hence you should provide PDB values (minAvailable/maxUnavailable) in the below range
chartMinAvailable <= userConfigurableMinavailable <= Replicas (No. of Kafka instances)
0 <=  userConfigurableMaxunavailable <= chartMaxUnAvailable

Ex- If Replicas=5,DefaultReplicationFactor=1,OffsetsTopicReplicationFactor=3
chartMinAvailable = max( 1,3) = 3
chartMaxUnAvailable = Replicas - chartMinAvailable = 5 - 3 = 2
Valid Input for userConfigurableMinavailable = 3|4|5
Valid Input for userConfigurableMaxunavailable = 0|1|2
Note: Setting above values ranges for pdb is recommended but users are free to set other pdb values as per their requirements.
************

Specify parameters using `--set key=value[,key=value]` argument to `helm install`

Alternatively a YAML file that specifies the values for the parameters can be provided like this:

```bash
$ helm install --name my-kafka -f values.yaml incubator/kafka
```

### Connecting to Kafka

You can connect to Kafka by running a simple pod in the K8s cluster like this with a configuration like this:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: testclient
  namespace: kafka
spec:
  containers:
  - name: kafka
    image: csf-docker-delivered.repo.cci.nokia.net/ckaf/kafka/rocky8:8.0.0-7.0.1-6149
    command:
      - sh
      - -c
      - "exec tail -f /dev/null"
```

Once you have the testclient pod above running, you can list all kafka
topics with:

` kubectl -n kafka exec testclient -- ./bin/kafka-topics.sh --bootstrap-server 
kf-<release>-headless.<namespace>.<clusterDomain>:9092 --list`

Where <release> is the name of your helm release, <namespace> is the namespace where the chart is installed and <clusterDomain> is cluster domain as per the cluster configuration.

## Known Limitations

* Topic creation is not automated
* Only supports storage options that have backends for persistent volume claims (tested mostly on AWS)

## Pod Security Standards

Helm chart can be installed in namespace with `restricted` Pod Security Standards profile.

### Special cases

#### Istio enabled with disabled CNI

Helm chart need to be installed in namespace with `privileged` Pod Security Standards profile on enviroment with installed istio with disabled CNI.

`values.yaml` parameters required to enable this case:
```yaml
istio:
  enabled: true
  cni:
    enabled: false
```

With such a configuration istio sidecar containers will be injected into all pods in this helm chart. Istio sidecar container requires the following privileges, which extending `restricted` profile:
```yaml
spec:
  containers:
    - securityContext:
        capabilities:
          add: [ "NET_ADMIN", "NET_RAW" ]
```

Explanation, why it is needed can be found at [istio documentation](https://istio.io/latest/docs/ops/deployment/requirements/#pod-requirements)

### GenericEphermalVolume
ephemeralVolume:
  enabled: true
  storageClass: ""
volumes used in cbur backup and restore
storageSize of topic-backup and cbura-tmp-volume needs to be set based on the size of data which is being restored.
  storageSize:
    topicBackup: 2Gi
    cburaTmpVolume: 1Gi

### flatRegistry
Helm chart must support container registries with a flat structure.
global:
  flatRegistry: false

Example with flatRegistry false:
global:
  registry: csf-docker-delivered.repo.cci.nokia.net
  flatRegistry: false
imageRepo: "ckaf/ckaf-kafka"
imageName: "ckaf-kafka"
imageTag: 8.6.0-rocky8-jre17-7.4.1-8073

output: csf-docker-delivered.repo.cci.nokia.net/ckaf/ckaf-kafka:8.6.0-rocky8-jre17-7.4.1-8073

Example with flatRegistry true:
global:
  registry: <user-provided-registry>
  flatRegistry: true
imageRepo: "ckaf/ckaf-kafka"
imageName: "ckaf-kafka"
imageTag: 8.6.0-rocky8-jre17-7.4.1-8073

output: <user-provided-registry>/ckaf-kafka:8.6.0-rocky8-jre17-7.4.1-8073

# Zookeeper Helm Chart
 This helm chart provides an implementation of the ZooKeeper [StatefulSet](http://kubernetes.io/docs/concepts/abstractions/controllers/statefulsets/) found in Kubernetes Contrib [Zookeeper StatefulSet](https://github.com/kubernetes/contrib/tree/master/statefulsets/zookeeper).

## Prerequisites
* Kubernetes 1.6
* PersistentVolume support on the underlying infrastructure
* A dynamic provisioner for the PersistentVolumes
* A familiarity with [Apache ZooKeeper 3.4.x](https://zookeeper.apache.org/doc/current/)

## Chart Components
This chart will do the following:

* Create a fixed size ZooKeeper ensemble using a [StatefulSet](http://kubernetes.io/docs/concepts/abstractions/controllers/statefulsets/).
* Create a [PodDisruptionBudget](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-disruption-budget/) so kubectl drain will respect the Quorum size of the ensemble.
* Create a [Headless Service](https://kubernetes.io/docs/concepts/services-networking/service/) to control the domain of the ZooKeeper ensemble.
* Create a Service configured to connect to the available ZooKeeper instance on the configured client port.
* Optionally, apply a [Pod Anti-Affinity](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#inter-pod-affinity-and-anti-affinity-beta-feature) to spread the ZooKeeper ensemble across nodes.

## Installing the Chart
You can install the chart with the release name `myzk` as below.

```console
$ helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator
$ helm install --name myzk incubator/zookeeper
```

If you do not specify a name, helm will select a name for you.

### Installed Components
You can use `kubectl get` to view all of the installed components.

```console{%raw}
$ kubectl get all -l app=zookeeper
NAME                   READY     STATUS    RESTARTS   AGE
po/myzk-zookeeper-0   1/1       Running   0          2m
po/myzk-zookeeper-1   1/1       Running   0          1m
po/myzk-zookeeper-2   1/1       Running   0          52s

NAME                           CLUSTER-IP    EXTERNAL-IP   PORT(S)             AGE
svc/myzk-zookeeper            10.3.255.86   <none>        2181/TCP            2m
svc/myzk-zookeeper-headless   None          <none>        2888/TCP,3888/TCP   2m

NAME                           DESIRED   CURRENT   AGE
statefulsets/myzk-zookeeper   3         3         2m
```

1. `statefulsets/myzk-zookeeper` is the StatefulSet created by the chart.
1. `po/myzk-zookeeper-<0|1|2>` are the Pods created by the StatefulSet. Each Pod has a single container running a ZooKeeper server.
1. `svc/myzk-zookeeper-headless` is the Headless Server used to control the network domain of the ZooKeeper ensemble.
1. `svc/myzk-zookeeper` is a Service that can be used by clients to connect to an available ZooKeeper server.

## Configuration
You can specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```console
$ helm install --name my-release -f values.yaml incubator/zookeeper
```

> **Tip**: You can use the default [values.yaml](values.yaml)

| Parameter                                 | Description                                                                  | Default values       |
| ----------------------------------------- | ---------------------------------------------------------------------------- | -------------------- |
| global.registry                   | Registry is used for zookeeper-server container image | csf-docker-delivered.repo.cci.nokia.net |
| global.registry1                  | Registry is used for jmx-exporter container image     | csf-docker-delivered.repo.cci.nokia.net |
| global.registry2                  | Registry is used for cbur-agent container image       | csf-docker-delivered.repo.cci.nokia.net |
| global.registry3                  | Registry is used for pre/post hook container image    | csf-docker-delivered.repo.cci.nokia.net |
| global.registry4                          | Reserved for future                                                          | nil                  |
| global.registry5                          | Reserved for future                                                          | nil                  |
| global.seccompAllowedProfileNames         | Secure computing allowed profile names                                       | runtime/default      |
| global.seccompDefaultProfileName          | Secure computing default profile names                                       | runtime/default      |
| global.storageClass                       | Storage class of the storage allocated for the ensemble.                     | default              |
| global.rbacEnable                         | Zookeeper rbac enable                                                        | TRUE                 |
| global.serviceAccountName                 | Zookeeper service account name                                               | {}                   |
| global.preheal                            | Zookeeper preheal job will spawns during install if value is greater than 0  | 0                    |
| global.postheal                           | Zookeeper postheal job will spawns during install if value is greater than 0 | 0                    |
| global.clogEnable                         | Zookeeper clog enable                                                        | TRUE                 |
| global.jobhookenable                      | Zookeeper hook job enable                                                    | TRUE                 |
| global.jobtimeout                         | Zookeeper job timeout                                                        | 600                  |
| global.istio.enabled                      | Zookeeper istio enabled                                                      | FALSE                |
| global.istio.createDrForClients           | Zookeeper istio create directory For Clients                                 | FALSE                |
| global.istio.overrideMtls.enabled         | Zookeeper istio override Mtls enabled                                        | FALSE                |
| global.istio.overrideMtls.mode            | Zookeeper istio override Mtls mode                                           | PERMISSIVE           |
| global.enable_scale_via_upgrade           | Zookeeper enable scale via upgrade job will scale during upgrade             | FALSE                |
| global.priorityClassName                  | Set a priority for a Pod using the PriorityClass                             |                                            |
| <workload>.priorityClassName              | Workload level PriorityClass takes higher predence than global.priorityClassName|                                            |
| imageRepo                                 | Zookeeper container image                                                    | ckaf/zookeeper       |
| imageTag                                  | Zookeeper container image tag                                                | 4.1.0-3.5.7-59       |
| kubectlImage                              | Image for kubectl CLI in any of the jobs                                     | tools/kubectl        |
| kubectlTag                                | kubectl image tag                                                            | v1.14.3-nano         |
| servers                                   | The number of ZooKeeper servers. This should always be (1,3,5, or 7)         | 3                    |
| antiAffinity                              | If present it must take the values 'hard' or 'soft'.                         | hard                 |
| clusterDomain                             | Kubernetes cluster domain name                                               | cluster.local        |
| zookeeperNodeSelector.enable              | Zookeeper NodeSelector enable allows to label the node                       | FALSE                |
| zookeeperNodeSelector.nodeLabel           | Allows to provide the label name for the node                                | {}                   |
| nameOverride                              | Allows to configure user defined name for component resources                | ckaf-zk-user-defined |
| fullnameOverride                          | Allows to configure user defined name for component resources                | user-defined         |
| tolerationsForTaints.enable               | Used to control/allow pod spawning on specific node                          | FALSE                |
| tolerationsForTaints.tolerations          | Multiple tolerations can be added , an example is below                      | nil                  |
| tolerationsForTaints.tolerations.key      | Label                                                                        | <"key1">             |
| tolerationsForTaints.tolerations.operator | Operators                                                                    | <"Equal">            |
| tolerationsForTaints.tolerations.value    | Value for operator and key                                                   | <"val1">             |
| tolerationsForTaints.tolerations.effect   | Which Toleration Effect should occure                                        | <"NoSchedule">       |
| ingress.enableExternalAccess              | Zookeeper ingress enable external access for clients outside k8s cluster     | FALSE                |
| ingress.edgeNodePort                      | Zookeeper ingress edge node port on specific port                            | nil                  |
| ingress.citmPrefixName                    | citm chart configmap prefix name on k8s cluster                              | nil                  |
| resources.requests.cpu                    | Amount of CPU to request.                                                    | 500m                 |
| resources.requests.memory                 | Amount of memory to request.                                                 | 2Gi                  |
| resources.limits.cpu                      | Zookeeper resource limits cpu                                                | 1                    |
| resources.limits.memory                   | Zookeeper resource limits memory                                             | 4Gi                  |
| heapConfig                                | Amount of JVM heap that the ZooKeeper servers will use.                                        | -Xmx750M -Xms750M                |
| dataStorage                              | Zookeeper node data storage                                                                    | 10Gi              |
| logStorage                               | Zookeeper node log storage                                                                     | 10Gi              |
| serverPort                               | Port on which the ZooKeeper servers listen for requests from other servers in the ensemble     | 2888              |
| leaderElectionPort                       | Port on which the ZooKeeper servers perform leader election                                    | 3888              |
| imagePullPolicy                          | Policy for pulling the image from the repository.                                              | Always            |
| tickTimeMs                               | Number of milliseconds in one ZooKeeper Tick                                                   | 2000              |
| initTicks                                | Amount of time, in Ticks, that a follower is allowed to connect to and sync with a leader      | 10                |
| syncTicks                                | Amount of time, in Ticks, that a follower is allowed to lag behind a leader                    | 5                 |
| preAllocSize                             | Zookeeper pre allocaton size                                                                   | 64000000KB              |
| clientCnxns                              | Maximum number of simultaneous client connections that each server in the ensemble will allow. | 60                |
| snapRetain                               | Number of snapshots to retain on disk                                                          | 3                 |
| purgeHours                               | Amount of time, in hours, between ZooKeeper snapshot and log purges                            | 1                 |
| probeInitialDelaySeconds                 | Initial delay before the liveness and readiness probes will be invoked.                        | 15                |
| probeTimeoutSeconds                      | Amount of time before the probes are considered to be failed due to a timeout.                 | 5                 |
| snapshotTrustEmpty                       | Check whether or not ZooKeeper should treat missing snapshot files as a fatal state            | FALSE             |
| krb.enable                               | Zookeeper kerboros(SASL) enable                                                                | FALSE             |
| krb.krbSecretName                        | Zookeeper  kerboros(SASL) secret name                                                          | <zookeeper-sasl>  |
| krb.krbPrincipalKey                      | Zookeeper  kerboros(SASL) principal key                                                        | <krbPrincipalKey> |
| krb.krbKeytabKey                         | Zookeeper  kerboros(SASL) keytab name                                                          | <krbKeytabKey>    |
| krb.krbConfigmapName                     | Zookeeper  kerboros(SASL) configmap name                                                       | nil               |
| krb.KrbConfKeyName                       | Zookeeper  kerboros(SASL)config key name                                                       | nil               |
| logLevel                                 | The log level of the ZooKeeper applications. One of ERROR,WARN,INFO,DEBUG.                     | INFO              |
| maxFileSize                              | Zookeeper logs max File Size                                                                   | 50MB              |
| maxBackupIndex                           | Zookeeper maximum nunber of log roll files                                                     | 10                |
| autoPvEnabledZk                          | Zookeeper auto Pv Enabled                                                                      | FALSE             |
| autoPvEnabledLabelZk                     | Zookeeper auto Pv Enabled Label                                                                | zookeeper         |
| security.enabled                         | Zookeeper security enabled                                                            | TRUE              |
| security.runAsUser                       | Zookeeper security run As User                                                        | 999               |
| security.fsGroup                         | Zookeeper security fs Group                                                           | 998               |
| security.runAsGroup                      | Zookeeper security run Group                                                          | 997               |
| security.supplementalGroups              | Zookeeper security supplemental Groups                                                | nil               |
| security.seLinuxOptions.enabled          | Zookeeper security se Linux Options enabled                                           | FALSE             |
| security.seLinuxOptions.level            | Zookeeper security se Linux Options level                                             | nil               |
| security.seLinuxOptions.role             | Zookeeper security se Linux Options role                                              | nil               |
| security.seLinuxOptions.type             | Zookeeper security se Linux Options type                                              | nil               |
| security.seLinuxOptions.user             | Zookeeper security se Linux Options user                                              | nil               |
| JmxExporter.imageRepo                    | Jmx Exporter container image Repo                                                     | cpro/jmx-exporter |
| JmxExporter.imageTag                     | Jmx Exporter container image Tag                                                      | v2.0.0            |
| JmxExporter.imagePullPolicy              | Jmx Exporter imagePull Policy                                                         | IfNotPresent      |
| JmxExporter.port                         | Jmx Exporter port                                                                     | 7072              |
| JmxExporter.resources.requests.cpu       | Jmx Exporter resources requests cpu                                                   | 100m              |
| JmxExporter.resources.requests.memory    | Jmx Exporter resources requests memory                                                | 1Gi               |
| JmxExporter.resources.limits.cpu         | Jmx Exporter resources limits cpu                                                     | 1                 |
| JmxExporter.resources.limits.memory      | Jmx Exporter resources limits memory                                                  | 4Gi               |
| jobResources.requests.cpu                | Zookeeper job resources requests cpu                                                  | 200m              |
| jobResources.requests.memory             | Zookeeper job resources requests memory                                               | 1Gi               |
| jobResources.limits.cpu                  | Zookeeper job resources limits cpu                                                    | 1                 |
| jobResources.limits.memory               | Zookeeper job resources limits memory                                                 | 4Gi               |
| deleteZookeeperJob.auto_remove_zk_pvc    | Delete Zookeeper job auto remove pvc                                                  | TRUE              |
| prescalein                               | Zookeeper pre scale in job will run during install when the values is greater than 0  | 0                 |
| postscalein                              | Zookeeper post scale in job will run during install when the values is greater than 0 | 0                 |
| lcm.scale_hooks                          | Zookeeper lcm scale hook                                                              | all               |
| lcm.scale_timeout                        | Zookeeper lcm scale job timeout                                                       | 180               |
| lcm.heal.timeout                         | Zookeeper lcm heal job timeout                                                        | 600               |
| cbur.name                                | cbur docker name                                                                      | cbura-sidecar     |
| cbur.enabled                             | enable or disable cbur container                                                                 | true   |
| cbur.image                               | cbur docker image                                                                     | cbur/cbura        |
| cbur.tag                                 | cbur docker tag                                                                       | 1.0.3-1665        |
| cbur.imagePullPolicy                     | cbur docker image pull policy                                                         | IfNotPresent      |
| cbur.resources.requests.cpu              | cbur resources requests cpu                                                           | 200m              |
| cbur.resources.requests.memory           | cbur resources requests memory                                                        | 1Gi               |
| cbur.resources.limits.cpu                | cbur resources limits cpu                                                             | 1                 |
| cbur.resources.limits.memory             | cbur resources limits memory                                                          | 4Gi               |
| cbur.maxCopy                             | cbur max copy                                                                         | 5                 |
| cbur.backendMode                         | cbur backend mode                                                                     | local             |
| cbur.cronJob                             | cbur cron job                                                                         | "0 23 * * *"      |
| ---------------------------------------- | ------------------------------------------------------------------------------------- | ----------------- |
| Configuration Override values                                                                                                                        |
| ---------------------------------------- | ------------------------------------------------------------------------------------- | ----------------- |
| Minimum Configuration                                                                                                                                |
| clientPort                               | Port to listen for client connections                                                 | 2181              |
| secureClientPort                         | Port to listen on for secure client connections using SSL.                            | nil               |
| dataDir                                  | Location where ZooKeeper will store the in-memory database snapshots                  | nil               |
| Advanced Configuration                                                                                                                                        |
| dataLogDir                     | Write the transaction log to the dataLogDir rather than the dataDir.                                | nil                    |
| globalOutstandingLimit         | Clients can submit requests faster than ZooKeeper can process them                                  | 1000                   |
| preAllocSize                   | To avoid seeks ZooKeeper allocates space in the transaction log file in blocks of preAllocSize kbs. | 64000000                   |
| snapCount                      | In order to prevent all of the machines in the quorum from taking a snapshot at the same time       | 100000                 |
| maxClientCnxns                 | Limits the number of concurrent connections (at the socket level)                                   | 60                     |
| clientPortAddress              | Address that clients attempt to connect to.                                                         | nil                    |
| minSessionTimeout              | Minimum session timeout in milliseconds that the server will allow the client to negotiate.         | 2 times the tickTime.  |
| maxSessionTimeout              | Maximum session timeout in milliseconds that the server will allow the client to negotiate.         | 20 times the tickTime. |
| fsync.warningthresholdms       | Warning message will be output to the log if an fsync in WAL takes longer than this value.          | 1000                   |
| autopurge.snapRetainCount      | When enabled, ZooKeeper auto purge feature retains the autopurge.snapRetainCount                    | 3                      |
| autopurge.purgeInterval        | Time interval in hours for which the purge task has to be triggered                                 | 0                      |
| syncEnabled                    | Observers now log transaction and write snapshot to disk by default like the participants.          | TRUE                   |
| zookeeper.extendedTypesEnabled | Define to "true" to enable extended features such as the creation of TTL Nodes.                     | Disabled               |
| zookeeper.emulate353TTLNodes   | Due to ZOOKEEPER-2901 TTL nodes created in version 3.5.3 are not supported in 3.5.4/3.6.0           | nil                    |
| serverCnxnFactory              | Specifies ServerCnxnFactory implementation.                                                         | NIOServerCnxnFactory   |

# Deep dive

## Image Details
The image used for this chart is based on Ubuntu 16.04 LTS. This image is larger than Alpine or BusyBox, but it provides glibc, rather than ulibc or mucl, and a JVM release that is built against it. You can easily convert this chart to run against a smaller image with a JVM that is build against that images libc. However, as far as we know, no Hadoop vendor supports, or has verified, ZooKeeper running on such a JVM.

## JVM Details
The Java Virtual Machine used for this chart is the OpenJDK JVM 8u111 JRE (headless).

## ZooKeeper Details
The ZooKeeper version is the latest stable version (3.4.9). The distribution is installed into /opt/zookeeper-3.4.9. This directory is symbolically linked to /opt/zookeeper. Symlinks are created to simulate a rpm installation into /usr.

## Failover
You can test failover by killing the leader. Insert a key:
```console
$ kubectl exec <RELEASE-NAME>-zookeeper-0 -- /opt/zookeeper/bin/zkCli.sh create /foo bar;
$ kubectl exec <RELEASE-NAME>-zookeeper-2 -- /opt/zookeeper/bin/zkCli.sh get /foo;
```

Watch existing members:
```console
$ kubectl run --attach bbox --image=busybox --restart=Never -- sh -c 'while true; do for i in 0 1 2; do echo zk-${i} $(echo stats | nc <pod-name>-${i}.<headless-service-name>:2181 | grep Mode); sleep 1; done; done';

zk-2 Mode: follower
zk-0 Mode: follower
zk-1 Mode: leader
zk-2 Mode: follower
```

Delete Pods and wait for the StatefulSet controller to bring them back up:
```console
$ kubectl delete po -l app=zookeeper
$ kubectl get po --watch-only
NAME                READY     STATUS    RESTARTS   AGE
myzk-zookeeper-0   0/1       Running   0          35s
myzk-zookeeper-0   1/1       Running   0         50s
myzk-zookeeper-1   0/1       Pending   0         0s
myzk-zookeeper-1   0/1       Pending   0         0s
myzk-zookeeper-1   0/1       ContainerCreating   0         0s
myzk-zookeeper-1   0/1       Running   0         19s
myzk-zookeeper-1   1/1       Running   0         40s
myzk-zookeeper-2   0/1       Pending   0         0s
myzk-zookeeper-2   0/1       Pending   0         0s
myzk-zookeeper-2   0/1       ContainerCreating   0         0s
myzk-zookeeper-2   0/1       Running   0         19s
myzk-zookeeper-2   1/1       Running   0         41s

...

zk-0 Mode: follower
zk-1 Mode: leader
zk-2 Mode: follower
```

Check the previously inserted key:
```console
$ kubectl exec myzk-zookeeper-1 -- /opt/zookeeper/bin/zkCli.sh get /foo
ionid = 0x354887858e80035, negotiated timeout = 30000

WATCHER::

WatchedEvent state:SyncConnected type:None path:null
bar
```
# PodDisruptionBudget Configuration

 As per the quorum requirement to form a healthy ensemble the formula is,
  Q = 2NF+1 ,
    Q ->  Number of zookeeper nodes required for healthy ensemble
    NF ->  Number of failures which can be tolerated

  To calculate minAvailable replicas,
  NF = (Q - 1) / 2
  computedminAvailable = Q - NF
  computedmaxUnAvailable = Q - computedminAvailable
  Ex- If Q = 5
  computedminAvailable = 5 - (( 5 - 1) / 2) = 5 - 2 = 3
  computedmaxUnAvailable = 5 - 3 = 2
  Valid Input for PodDisruptionBudget should be in below range.
  computedminAvailable <= inputvalueminAvailable <= Servers (No. of Zookeeper instances)
  0 <= inputvaluemaxUnavailable <= computedmanUnavailable
Note: Setting above values ranges for pdb is recommended but users are free to set other pdb values as per their requirements.

## Scaling
ZooKeeper can not be safely scaled in versions prior to 3.5.x. There are manual procedures for scaling an ensemble, but as noted in the [ZooKeeper 3.5.2 documentation](https://zookeeper.apache.org/doc/r3.5.2-alpha/zookeeperReconfig.html) these procedures require a rolling restart, are known to be error prone, and often result in a data loss.

While ZooKeeper 3.5.x does allow for dynamic ensemble reconfiguration (including scaling membership), the current status of the release is still alpha, and it is not recommended for production use.

## Limitations
* StatefulSet and PodDisruptionBudget are beta resources.
* Only supports storage options that have backends for persistent volume claims.

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

### Generic ephemeral volume
ephemeralVolume:
  enabled:
  storageClass: ""
volumes used in cbur backup and restore  
storageSize of zk-transaction-log-backup and cbura-tmp-volume needs to be set based on the size of data which is being restored.
  storageSize:
    zkTransactionLogBackup: 2Gi

### flatRegistry

Helm chart must support container registries with a flat structure.
global:
  flatRegistry: false

Example with flatRegistry false:
global:
  registry: csf-docker-delivered.repo.cci.nokia.net
  flatRegistry: false
imageRepo: "ckaf/ckaf-zookeeper"
imageName: "ckaf-zookeeper"
imageTag: 8.6.0-rocky8-jre17-3.6.4-8058

output: csf-docker-delivered.repo.cci.nokia.net/ckaf/ckaf-zookeeper:8.6.0-rocky8-jre17-3.6.4-8058

Example with flatRegistry true:
global:
  registry: <user-provided-registry>
  flatRegistry: true
imageRepo: "ckaf/ckaf-zookeeper"
imageName: "ckaf-zookeeper"
imageTag: 8.6.0-rocky8-jre17-3.6.4-8058

output: <user-provided-registry>/ckaf-zookeeper:8.6.0-rocky8-jre17-3.6.4-8058

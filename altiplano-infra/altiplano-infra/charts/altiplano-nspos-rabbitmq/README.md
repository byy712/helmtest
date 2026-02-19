|          Parameter                    |                       Description                       |                         Default                          |
|---------------------------------------|---------------------------------------------------------|----------------------------------------------------------|
| `global.registry`                     | Registry includes both rabbitmq image and kubectl image | `csf-docker-delivered.repo.cci.nokia.net`    |
| global.priorityClassName              | Set a priority for a Pod using the PriorityClass        |                                            |
| `image.repository`                    | Rabbitmq Image name                                     | see values.yaml                                          |
| `image.tag`                           | Rabbitmq Image tag                                      | `{VERSION}`                                              |
| `image.pullPolicy`                    | Image pull policy                                       | `Always` if `imageTag` is `latest`, else `IfNotPresent`  |
| `image.pullSecrets`                   | Specify docker-ragistry secret names as an array        | `nil`                                                    |
| `image.debug`                         | Specify if debug values should be set                   | `false`                                                  |
| `rbac.enabled`                        | Specify if rbac is enabled in your cluster              | `true`                                                   |
| `serviceAccountName`             | Specify default SA if rbac.enable false                 | `default`                                                |
| `serviceAccountNamePostDel`      | Specify post delete SA if rbac.enable false             | `default`                                                |
| `serviceAccountNameScale`        | Specify scaling SA if rbac.enable false & pvc enable    | `default`                                                |
| `serviceAccountNameAdminForgetnode`| Specify admin SA if rbac.enable false & pvc disable   | `default`                                                |
| `rbac.test.enabled`                   | Enable or disable helm test when rbac.enabled is false  | `true`                                                   |
| `serviceAccountNameHelmTest`  | Specify default SA if rbac.enable false & want to use helm test | `default`                                      |
| `helmTestSecret`            | Specify tls secret if rbac.enable false & want to use helm test | `default`                                        |
| `custom.statefulset.annotations`      | Specify custom annotation for statefulset               | ``                                                       |
| `istio.enabled`                        | Specify if deploy on istio                             | `false`                                                  |
| `istioIngress.enabled`                | Whether enable istio ingress gateway                    | `false`                                                  |
| `istioIngress.host`                   | The host used to access istio ingress                   | ``                                                       |
| `istioIngress.selector`               | The selector of istio ingress gateway                   | `{istio: ingressgateway}`                                |
| `tmpForceRecreateResources`           | Force to recreate the resource created when install     | `false`                                                  |
| `clusterDomain`                       | Change sts DnsConfig with appropriate clusterDomain     | `cluster.local`                                          |
| `rabbitmq.dynamicConfig.enable`       | Enable to run command after deploy                      | `false`                                                  |
| `rabbitmq.dynamicConfig.upgrade`      | Allow dynamicConfig set at upgrade time                 | `false`                                                  |
| `rabbitmq.dynamicConfig.timeout`      | Seconds to wait for pod ready in post-install job       | `300`                                                    |
| `rabbitmq.dynamicConfig.maxCommandRetries`| Number of times to retry a command before failing the job | `10`                                               |
| `rabbitmq.dynamicConfig.parameters`   | Rabbitmq commands to run after chart deployed           |  see values.yaml                                         |
| `rabbitmq.default_user_credentials.secretName`   | Secret name storing the default user credentials           |  none                                         |
| `rabbitmq.default_user_credentials.usernameKey`   | Key name storing the username within the default user credentials secret           |  none                                        |
| `rabbitmq.default_user_credentials.passwordKey`   | Key name storing the password within the default user credentials secret           |  none                                         |
| `rabbitmq.erlangCookie`               | Erlang cookie                                           | _random 32 character long alphanumeric string_           |
| `rabbitmq.amqpSvc`                    | To expose the amqp port                                 | `true`                                                   |
| `rabbitmq.amqpPort`                   | amqp port                                               | `5672`                                                   |
| `rabbitmq.nodePort`                   | amqp node port                                          | `30010`                                                  |
| `rabbitmq.rabbitmqClusterNodeName`    | Specify rabbitmq cluster name                           | none                                                     |
| `rabbitmq.plugins`                    | configuration file for plugins to enable                | `[rabbitmq_management,rabbitmq_peer_discovery_k8s].`     |
| `rabbitmq.configuration`              | rabbitmq.conf content                                   | see values.yaml                                          |
| `rabbitmq.advancedConfig`             | advanced.config content                                 | none                                                     |
| `rabbitmq.memory.vm_memory_high_watermark_relative`    | vm_memory_high_watermark relative option | none                                                   |
| `rabbitmq.memory.vm_memory_high_watermark_absolute`    | vm_memory_high_watermark_absolute option | none                                                   |
| `rabbitmq.memory.vm_memory_high_watermark_paging_ratio`| vm_memory_high_watermark_paging_ratio option | none                                               |
| `rabbitmq.memory.disk_free_limit_absolute`             | Specify rabbitmq disk free limit       | none                                                     |
| `rabbitmq.environment`                | rabbitmq-env.conf content                               | see values.yaml                                          |
| `rabbitmq.mqtt.enabled`               | whether to enable mqtt plugin                           | `false`                                                  |
| `rabbitmq.mqtt.vhost`                 | vhost for mqtt plugin                                   | `\`                                                      |
| `rabbitmq.mqtt.exchange`              | exchagne of vhost for mqtt plugin                       | `amq.topic`                                              |
| `rabbitmq.mqtt.DefaultTcpPort`        | default tcp port for mqtt plugin                        | `1883`                                                   |
| `rabbitmq.mqtt.tcpNodePort`           | tcp nodePort for mqtt plugin                            | ``                                                       |
| `rabbitmq.mqtt.enabledSsl`            | whether to enable SSL port for mqtt                     | `false`                                                  |
| `rabbitmq.mqtt.DefaultSslPort`        | default SSL port for mqtt                               | `8883`                                                   |
| `rabbitmq.mqtt.sslNodePort`           | ssl nodePort for mqtt plugin                            | ``                                                       |
| `rabbitmq.clustering.address_type`    | the node address type of RabbitMQ                       | `default`                                                |
| `rabbitmq.tls.cacert`                 | broker tls cacert file content                          | none                                                     |
| `rabbitmq.tls.cert`                   | broker tls cert file content                            | none                                                     |
| `rabbitmq.tls.key`                    | broker tls key file content                             | none                                                     |
| `rabbitmq.tls.verify_option`          | whether peer verification is enabled                    | `verify_peer`                                            |
| `rabbitmq.tls.fail_if_no_peer_cert`   | whether to accept clients which have no certificate     | `false`                                                  |
| `rabbitmq.tls.ssl_port`               | RabbitMQ broker tls port                                | `5671`                                                   |
| `rabbitmq.tls.nodePort`               | RabbitMQ broker tls nodePort                            | ``                                                       |
| `rabbitmq.tls.versions`               | Limits tls versions used by CRMQ                        | ``                                                       |
| `rabbitmq.tls.helm_test_tls_version`  | To specify for tls helm test when tls.version is used   | ``                                                       |
| `rabbitmq.tls.certmanager.used`       | generate cacert cert key with cert-manager              | `false`                                                  |
| `rabbitmq.tls.certmanager.dnsNames`   | specify dnsNames for cert-manager generation keys       | `- ""`                                                   |  
| `rabbitmq.tls.certmanager.duration`   | cert_m Certificate default Duration                     | `8760h`                                                  |  
| `rabbitmq.tls.certmanager.renewBefore`| cert_m Certificate renew before expiration duration     | `360h`                                                   |  
| `rabbitmq.tls.certmanager.issuerName` | to change the issuerRef for cert manager                | `ncms-ca-issuer`                                         |  
| `rabbitmq.tls.certmanager.issuerType` | to change the issuerType (Kind) for cert manager        | `ClusterIssuer`                                          |  
| `rabbitmq.management.enabled`         | Enable management plugin                                | `true`                                                   |
| `rabbitmq.management.tls.enabled`     | Enable tls for management plugin                        | `false`
                                |
| `rabbitmq.management.tls.secret.used` | Use secret to mount the cacert,cert and key for management plugin | `false`
                                |
| `rabbitmq.management.tls.secret.name` | management plugin tls secret name                       | none                                                     |
| `rabbitmq.management.tls.secret.ca_cert_key` | management plugin tls secret key name for cacert | none                                                     |
| `rabbitmq.management.tls.secret.tls_cert_key` | management plugin tls secret key name for server cert | none                                               |
| `rabbitmq.management.tls.secret.tls_key_key` | management plugin tls secret key name for server key | none                                                 | 
| `rabbitmq.management.port`            | RabbitMQ Manager port                                   | `15672`                                                  |
| `rabbitmq.management.nodePort`        | RabbitMQ Manager node port                              | `30110`                                                  |
| `rabbitmq.management.tls.certmanager.used`| generate cacert cert key with cert-manager              | `false`                                                  |
| `rabbitmq.management.tls.certmanager.dnsNames`    | specify dnsNames for cert-manager generation keys       | `- ""`                                                   |  
| `rabbitmq.management.tls.certmanager.duration`    |  cert_m Certificate default Duration                    | `8760h`                                                  |  
| `rabbitmq.management.tls.certmanager.renewBefore` | cert_m Certificate renew before expiration duration     | `360h`                                                   |  
| `rabbitmq.management.tls.certmanager.issuerName`  | to change the issuerRef for cert manager                | `ncms-ca-issuer`                                         |  
| `rabbitmq.management.tls.certmanager.issuerType`  | to change the issuerType (Kind) for cert manager        | `ClusterIssuer`                                          |  
| `rabbitmq.backuprestore.enabled`      | whether enable backup/restore                           | `false`                                                  |
| `rabbitmq.backuprestore.backendMode`  | The backendMode field of BrPolicy                       | `local`                                                  |
| `rabbitmq.backuprestore.cronJob`      | The cronJob field of BrPolicy                           | `*/10 * * * *`                                           |
| `rabbitmq.backuprestore.brOption`     | The brOption field of BrPolicy                          | `0`                                                      |
| `rabbitmq.backuprestore.maxCopy`      | The maxCopy field of BrPolicy                           | `5`                                                      |
| `rabbitmq.backuprestore.agent.imageRepo`| the image repo of cbur sidecar                        | `cbur/cbura`                                             |
| `rabbitmq.backuprestore.agent.imageTag`| the image tag of cbur sidecar                          | `1.0.3-983`                                              |
| `rabbitmq.backuprestore.agent.imagePullPolicy`| cbur sidecar image pull policy                  | `IfNotPresent`                                           |
| `rabbitmq.rsyslog.enabled`            | whether to enable rsyslog (deprecated, use clog instead)| `false`                                                  |
| `rabbitmq.rsyslog.repository`         | rsyslog docker image repository                         | see values.yaml                                          |
| `rabbitmq.rsyslog.tag`                | rsyslog docker image tag                                | `latest`                                                 |
| `rabbitmq.rsyslog.imagePullPolicy`    | rsyslog docker image pullPolicy                         | `IfNotPresent`                                           |
| `rabbitmq.rsyslog.level`              | rsyslog level                                           | `debug`                                                  |
| `rabbitmq.rsyslog.transport`          | rsyslog transport                                       | `udp`                                                    |
| `rabbitmq.thirdPartyPlugin`           | third party plugin list                                 | none                                                     |
| `rabbitmq.clog.syslog.enabled`        | whether to enable CLOG sidecar                          | `false`                                                  |
| `rabbitmq.clog.syslog.port`           | CLOG rsyslog port                                       | `2514`                                                   |
| `rabbitmq.clog.syslog.format`         | CLOG rsyslog format: rfc3164|rfc5424                    | `5424`                                                   |
| `rabbitmq.clog.syslog.level`          | CLOG rsyslog level                                      | `debug`                                                  |
| `rabbitmq.clog.syslog.transport`      | CLOG rsyslog transport                                  | `udp`                                                    |
| `rabbitmq.console.enabled`            | Log into console                                        | `true`                                                   |
| `rabbitmq.console.level`              | Log level                                               | `info`                                                   |
| `rabbitmq.prometheus.enabled`         | To enable prometheus plugin                             | `false`                                                  |
| `rabbitmq.prometheus.port`            | TCP port prometheus plugin is listening to              | `15692`                                                  |
| `rabbitmq.prometheus.tls.nodePort`        | RabbitMQ prometheus node port                              | `none`                                     |
| `rabbitmq.prometheus.tls.enabled`         | Enable prometheus plugin in tls                     | `false`                                                   |
| `rabbitmq.prometheus.tls.cacert`          | prometheus plugin tls cacert file content               | none                                                     |
| `rabbitmq.prometheus.tls.cert`            | prometheus plugin tls cert file content                 | none                                                     |
| `rabbitmq.prometheus.tls.key`             | prometheus plugin tls key file content                  | none                                                     |
| `rabbitmq.prometheus.tls.password`        | password-if-keyfile-is-encrypted                        | none                                                     |
| `rabbitmq.prometheus.tls.certmanager.used`| generate cacert cert key with cert-manager              | `false`                                                  |
| `rabbitmq.prometheus.tls.certmanager.dnsNames`    | specify dnsNames for cert-manager generation keys       | `- ""`                                           |
| `rabbitmq.prometheus.tls.certmanager.duration`    |  cert_m Certificate default Duration                    | `8760h`                                          |
| `rabbitmq.prometheus.tls.certmanager.renewBefore` | cert_m Certificate renew before expiration duration     | `360h`                                           |
| `rabbitmq.prometheus.tls.certmanager.issuerName`  | to change the issuerRef for cert manager                | `ncms-ca-issuer`                                 |
| `rabbitmq.prometheus.tls.certmanager.issuerType`  | to change the issuerType (Kind) for cert manager        | `ClusterIssuer`                                  |
| `tlsClient`                           | tls file list need to be mounted                        | none                                                     |
| `serviceType`                         | Kubernetes Service type                                 | `ClusterIP`                                              |
| `persistence.reservePvc`              | reserve persistence storage after pod deleted           | `false`                                                  |
| `persistence.reservePvcForScalein`    | reserve persistence storage after pod scale-in          | `false`                                                  |
| `persistence.data.enabled`            | enable persistence storage for data                     | `true`                                                   |
| `persistence.data.storageClass`       | storage class for pvc                                   | none                                                     |
| `persistence.data.accessMode`         | Persistent Volume Access Mode for data                  | `ReadWriteOnce`                                          |
| `persistence.data.size`               | Persistent Volume Size for data                         | `8GiB`                                                   |
| `persistence.log.enabled`             | enable persistence storage for log                      | `false`                                                  |
| `persistence.log.storageClass`        | storage class for pvc                                   | none                                                     |
| `persistence.log.accessMode`          | Persistent Volume Access Mode for log                   | `ReadWriteOnce`                                          |
| `persistence.log.size`                | Persistent Volume Size for log                          | `8GiB`                                                   |
| `priorityClassName`                   | PriorityClass to be used                                | ``                                                       |
| `resources`                           | resource needs and limits to apply to the pod           | {}                                                       |
| `replicas`                            | Replica count                                           | `3`                                                      |
| `nodeSelector`                        | Node labels for pod assignment                          | {}                                                       |
| `affinity`                            | Affinity settings for pod assignment                    | {}                                                       |
| `tolerations`                         | Toleration labels for pod assignment                    | []                                                       |
| `podAnnotations`                      | pod annotation                                          | {}                                                       |
| `svcAnnotations`                      | svc annotation                                          | {}                                                       |
| `ingress.enabled`                     | enable ingress for management console                   | `false`                                                  |
| `ingress.hostName`                    | host name of ingress                                    | `csf-crmq-nokia.net`
| `ingress.use_cert_manager`            | generated cacert cert key for ingress tls               | `false`                                                  |
| `ingress.dnsNames`                    | specify dnsNames for cert-manager generation keys       | `- ""`                                                   |  
| `ingress.duration`                    |  cert_m Certificate default Duration                    | `8760h`                                                  |  
| `ingress.renewBefore`                 | cert_m Certificate renew before expiration duration     | `360h`                                                   |  
| `ingress.issuerName`                  | to change the issuerRef for cert manager                | `ncms-ca-issuer`                                         |  
| `ingress.issuerType`                  | to change the issuerType (Kind) for cert manager        | `ClusterIssuer`                                          |  
| `livenessProbe.enabled`               | would you like a livessProbed to be enabled             | `true`                                                   |
| `livenessProbe.initialDelaySeconds`   | number of seconds                                       | 120                                                      |
| `livenessProbe.timeoutSeconds`        | number of seconds                                       | 5                                                        |
| `livenessProbe.failureThreshold`      | number of failures                                      | 6                                                        |
| `readinessProbe.enabled`              | would you like a readinessProbe to be enabled           | `true`                                                   |
| `readinessProbe.initialDelaySeconds`  | number of seconds                                       | 10                                                       |
| `readinessProbe.timeoutSeconds`       | number of seconds                                       | 3                                                        |
| `readinessProbe.periodSeconds`        | number of seconds                                       | 5                                                        |
| `lcm.scale_hooks`                     | lcm scale hook                                          | `noupgradehooks`                                         |
| `lcm.scale_timeout`                   | lcm scale timeout                                       | `120`                                                    |
| `postDeleteForceClean.enabled`        | True to force disabling ressources during post-delete   | `false`                                                  | 
| `helmTestDeletePolicy`                | Change the delete policy of helm tests                  | none                                                     |
| `hooks.deletePolicy`                  | Change the delete policy of crmq jobs                   | none                                                     |
| `localtime`                           | mount /etc/localtime in statefulset.yaml                | `true`                                                   |
| `ipv6Enabled`                         | set to true if your cluster is in pure ipv6             | `false`                                                  |
| <workload>.priorityClassName          | Workload level PriorityClass takes higher predence than global.priorityClassName|                                           |

## rsyslog / CLOG

According to CSF policy, CLOG sidecar should be used to send the CRMQ log on a BCMT cluster.

rabbitmq.rsyslog.enabled is so deprecated.

To be able to use CLOG sidecar, you must deploy CLOG as explained in the CLOG User Guide

At a glance:
    - Create the TLS certificate as mentioned (default values can be used for testing)
    - Deploy the CLOG pod (helm install --name clogsidecar csf-stable/clog-sidecar --version=2.0.7 -f ./values.yaml)

Then, you can deploy CRMQ using --set rabbitmq.clog.syslog.enabled=true

## Rbac enable false
If you chose to use you own resource you need to know that if you want to specify only one serviceAccount you can set only serviceAccountName and all other normaly needed serviceaccount will be set with the same service account.
You can check CRMQ documentation for more information

rbac:
  enabled: false
  serviceAccountName: mysa
  serviceAccountNamePostDel :
  serviceAccountNameScale :
  serviceAccountNameAdminForgetnode :
  test:
    enabled: true
    serviceAccountNameHelmTest:

## Prefix & Suffix
If you want to change prefix and suffix you can fill theses values.
podNamePrefix & containerNamePrefix need to be under global.

global:

  podNamePrefix: prefixpod-
  containerNamePrefix: prefixcontainer-

postDeleteJobName: deljob
postDeleteContainerName: delcont
postInstallJobName: instjob
postInstallContainerName: instalcont
postUpgradeJobName: upgjob
postUpgradeContainerName: upgcon
postScaleinJobName: scajob
postScaleinContainerName: scajob

# PodDisruptionBudget Configuration

1. If MQTT plugin is enabled than it requires a quorum of cluster nodes to be present. This is because client ID tracking now uses a consensus protocol which requires a quorum of nodes to be online in order to make progress. If a quorum of nodes is down or lost, the plugin won't be able to accept new client connections until the quorum is restored. This means two nodes out of three, three out of five etc should be available. This plugin cannot be used on a cluster with 2 nodes. One can calculate the minAvailable according to the equation n/2+1 where n is the replicas. For more information, please refer the below link.

For eg:  
           if replicas=3, set pdb.minAvailable=3/2+1=2 or pdb.maxUnavailable=3-2=1
	   if replicas=5, set pdb.minAvailable=5/2+1=3 or pdb.maxUnavailable=5-3=2

MQTT: https://www.rabbitmq.com/mqtt.html#requirements

2. Before creating quorum queues, make sure to set pdb accordingly. The quorum queue is a modern queue type for RabbitMQ implementing a durable, replicated FIFO queue based on the Raft consensus algorithm. It is available as of RabbitMQ 3.8.0. Consensus systems can provide certain guarantees with regard to data safety. These guarantees do mean that certain conditions need to be met before they become relevant such as requiring a minimum of three cluster nodes to provide fault tolerance and requiring more than half of members to be available to work at all. For further information on fault tolerance quorum guide, please refer the below link.

For eg:
           if replicas=3, set pdb.minAvailable=3/2+1=2 or pdb.maxUnavailable=3-2=1
	   if replicas=5, set pdb.minAvailable=5/2+1=3 or pdb.maxUnavailable=5-3=2

Quorum-Queues: https://www.rabbitmq.com/quorum-queues.html#quorum-requirements

3. Before creating mirror-queue, make sure to set pdb according to the required policy. By default, contents of a queue within a RabbitMQ cluster are located on a single node (the node on which the queue was declared). This is in contrast to exchanges and bindings, which can always be considered to be on all nodes. Queues can optionally run mirrors (additional replicas) on other cluster nodes. To cause queues to become mirrored, you need to create a policy which matches them and sets policy keys `ha-mode` and (optionally) `ha-params`. Please refer the below link for choosing the policy and set the pdb accordingly to provide the fault tolerance.

Mirror-Queues: https://www.rabbitmq.com/ha.html#mirroring-arguments

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

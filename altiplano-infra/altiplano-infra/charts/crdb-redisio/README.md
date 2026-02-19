# Helm Configuration

The crdb-redisio chart provides the packaging to deploy a [Redis](http://redis.io) (opensource) database instance in one of the supported deployment configurations (standalone, cluster).

Redis is an open source, in-memory data structure store, used as a database, cache and message broker. It supports data structures such as strings, hashes, lists, sets, sorted sets with range queries, bitmaps, hyperloglogs and geospatial indexes with radius queries. Redis has built-in replication, Lua scripting, LRU eviction, transactions and different levels of on-disk persistence, and provides high availability via Redis Sentinel and automatic partitioning with Redis Cluster.

There is a large set of configuration parameters that can be specified as input values when deploying or upgrading the crdb-redisio Helm chart. Default and input values are passed in a YAML file, or can be passed via command-line \--set argument using the YAML object reference equivalent. The following values can be provided to override the defaults specified in the chart.

*Note: There are additional values defined in the chart values.yaml file. Most of these are necessary for compliance to helm best practices or for future functionality and/or are untested. Do not change or re-set any values not specifically listed in the table below.*

## Pod Security Standards

The crdb-redisio helm chart can be installed in namespace with **restricted** Pod Security Standards profile.  See [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/).

#### Istio enabled with disabled CNI

When installing the crdb-redisio helm chart in an Istio environment with CNI disabled, it must be installed in a namespace with **privileged** Pod Security Standards profile.

`values.yaml` parameters required to enable this case:

```yaml
istio:
  enabled: true
  cni:
    enabled: false
rbac:
  psp:
    create: true
```

In the Istio (non-CNI) configuration, istio-proxy sidecar containers will be injected into all pods in the deployment. Istio-proxy sidecar container requires the following privileges, which extends the **privileged** profile:

```yaml
spec:
  containers:
    - securityContext:
        capabilities:
          add: [ "NET_ADMIN", "NET_RAW" ]
```

An explanation of why it is needed can be found at [istio documentation](https://istio.io/latest/docs/ops/deployment/requirements/#pod-requirements)

##### Mapping to gatekeeper constraints

Open source Gatekeeper `K8sPSPCapabilities` (see: [capabilities](https://github.com/open-policy-agent/gatekeeper-library/blob/master/library/pod-security-policy/capabilities)) constraint need to be relaxed to allow the following additional privileges:

```yaml
        capabilities:
          add: [ "NET_ADMIN", "NET_RAW" ]
```

# Helm Chart Parameters

!!! warning "Parameter Updates"
    Caution must be taken when updating some of the parameters listed.  Updates to some parameters marked with **Yes_** may result in Controller updates that trigger Pod recreations.  Updating these parameters may affect availability of various workloads, including the Redis database itself.

!!! tip "Some Updates Not Allowed"
    There is no mechanism to prevent updating certain values on an existing chart release. Therefore, an attempt to change any marked with an Update Allowed of No will not be prevented, but it will most likely result in the existing release of the chart being rendered unusable.  

*[Yes_]: Updates to this Value may affect Service

## Global Parameters

| **Parameter** | **Default** | **Description** | **Update Allowed** |
|:---------------------|:------------|:----------------|:----------------------|
| `global.registry` | *(empty)* | ==CHANGED IN 9.0.0== The Registry URL used to pull all container images | **Yes_** |
| ~~global.registry1~~ | ~~registry1-docker-io.repo.cci.nokia.net~~ | ==REMOVED IN 9.0.0== | |
| ~~global.registry2~~ | ~~csf-docker-delivered.repo.cci.nokia.net~~ | ==REMOVED IN 9.0.0== | |
| `global.flatRegistry` | `false` | Use flat registry for all images | **Yes_** |
| `global.podNamePrefix` | *(empty)* | ==CHANGED IN 9.0.0== Prefix name to be prepended to every pod. The prefix name will prepend the normal pod name which is made up of the release name and the fixed pod suffix.  The pod prefix is `not` part of the release name and thus does not affect other created resources (eg. configmaps, services, etc.).  NOTE: A hyphen will be added between podNamePrefix and the pod name/suffix, unless one is included in the podNamePrefix already. | No |
| `global.containerNamePrefix` | *(empty)* | ==CHANGED IN 9.0.0== Container name to be prepended to every created container for both statefulset pod containers and job pod containers. NOTE: A hyphen will be added between containerNamePrefix and the container name/suffix, unless one is included in the containerNamePrefix already. | **Yes_** |
| `global.disablePodNamePrefixRestrictions` | *(empty)* | ==NEW IN 9.0.0== If enabled, then podNamePrefix will be added to the pod name without any restrictions on hyphen separator or length limits | No |
| `global.enableDefaultCpuLimits` | *(empty)* | ==NEW IN 9.0.0== If enabled, then default cpu.limits will be set on containers.  Otherwise, cpu.limits will be unset (unlimited) | **Yes_**(#common_fn) |
| `global.priorityClassName` | *(empty)* | The kubernetes Pod priority and preemption class name. Ref: [kubernetes.io Pod Priority Preemption](https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/) | No |
| `global.imagePullSecrets` | *(empty)* | Specify the Secrets to be passed to every pod and used for pulling registry images from a secured registry. | Yes |
| `global.imageFlavor` | *(empty)* | Default image flavor for all docker container. | **Yes_** |
| `global.imageFlavorPolicy` | *(empty)* | imageFlavor enforcement policy - Can be so Strict or BestMatch | **Yes_**
| `global.serviceAccountName` | *(empty)* | Service Account to use instead of a generated one (Also disables generation of Roles/Rolebindings). See [RBAC Rules](./oam_rbac_rules.md) | **Yes_** |
| global.certManager.* | *(empty)* | Sets Certificate Manager default Certificate Parameters at the global level | **Yes_** |
| global.unifiedLogging.* | *(empty)* | Sets [Unified Logging Parameters](#logging) at the global level | Yes |
| `global.istio.sidecar.healthCheckPort` | *(empty)* | ==NEW IN 9.0.0== Healthcheck port for Istio. If unset, uses 15021 or 15050 for Istio <1.6 | **Yes_** |
| `global.istio.sidecar.stopPort` | 1500 | ==NEW IN 9.0.0== Admin port for Istio endpoint to stop container (quitquitquit) | **Yes_** |
| `global.tls.enabled` | *(empty)* | Specifies whether TLS will be enabled globally | **Yes_** |
| `global.timeZoneEnv` | *(empty)* | Set as TZ environment variable in all containers. | **Yes_** |

## Common, Chart-level Parameters

| **Parameter** | **Default** | **Description** | **Update Allowed** |
|:---------------------|:------------|:----------------|:----------------------|
| `internalRedisioRegistry` | *(empty)* | ==NEW IN 9.0.0== The Registry URL used to pull CRDB server/sentinel workload container images. If unspecified, uses CSF Delivered Docker repo. | **Yes_** |
| `internalRolemonRegistry` | *(empty)* | ==NEW IN 9.0.0== The Registry URL used to pull CRDB rolemon workload container images. If unspecified, uses CSF Delivered Docker repo. | **Yes_** |
| `internalAdminRegistry` | *(empty)* | ==NEW IN 9.0.0== The Registry URL used to pull CRDB admin workload container images. If unspecified, uses CSF Delivered Docker repo. | **Yes_** |
| `internalCburAgentRegistry` | *(empty)* | ==NEW IN 9.0.0== The Registry URL used to pull CBUR agent workload container images. If unspecified, uses CSF Delivered Docker repo. | **Yes_** |
| `internalExporterRegistry` | *(empty)* | ==NEW IN 9.0.0== The Registry URL used to pull Redis exporter container images. If unspecified, uses Docker Hub repo. | **Yes_** |
| `podNamePrefix` | *(empty)* | ==CHANGED IN 9.0.0== Prefix name to be prepended to every pod. The prefix name will prepend the normal pod name which is made up of the release name and the pod name.  The pod prefix is `not` part of the release name and thus does not affect other created resources (eg. configmaps, services, etc.).  NOTE: A hyphen will beadded between podNamePrefix and the pod name/suffix, unless one is included in the podNamePrefix already. | No |
| `containerNamePrefix` | *(empty)* | ==CHANGED IN 9.0.0== Container name to be prepended to every created container for both statefulset pod containers and job pod containers. NOTE: A hyphen will be added between containerNamePrefix and the container name/suffix, unless one is included in the containerNamePrefix already. | **Yes_** |
| `disablePodNamePrefixRestrictions` | *(empty)* | ==NEW IN 9.0.0== If enabled, then podNamePrefix should be added to the pod name without any restrictions | No |
| `enableDefaultCpuLimits` | *(empty)* | ==NEW IN 9.0.0== If enabled, then default cpu.limits will be set on containers.  Otherwise, cpu.limits will be unset (unlimited) | **Yes_** |
| `priorityClassName` | *(empty)* | The kubernetes Pod priority and preemption class name. Ref: [kubernetes.io Pod Priority Preemption](https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/) | No |
| `imageFlavor` | rocky8 | Default image flavor for all docker container. | **Yes_** |
| `imageFlavorPolicy` | *(empty)* | imageFlavor enforcement policy - Can be set to Strict or BestMatch (default) | **Yes_** |
| `imagePullSecrets` | *(empty)* | Specify the Secrets to be passed to every pod and used for pulling registry images from a secured registry. | Yes |
| `rbac.enabled` | `true` | Specifies whether Role-Based Access Control (RBAC) Resources should be created by this chart. | No |
| `rbac.psp.create` | `true` | If the chart is allowed to create PodSecurityPolicy Resources (when needed) | No |
| `rbac.psp.name` | *(empty)* | Name of created PodSecurityPolicy (when needed) | No |
| `rbac.scc.create` | `false` | If the chart is allowed to create SecurityContextConstraint Resources (when needed) | No |
| `rbac.scc.name` | *(empty)* | Name of created SecurityContextConstraint (when needed) | No |
| `serviceAccountName` | *(empty)* | Service Account to use instead of a generated one (Also disables generation of Roles/Rolebindings). See [RBAC Rules](./oam_rbac_rules.md) | No |
| `alarmServiceName` | *(empty)* | Service name to use in unified alarm messages. If unset, defaults to redisio. | **Yes_** |
| `clusterDomain` | `cluster.local` | Cluster domain used for services (...<namespace>.svc.<clusterDomain>) | No |
| `nodeAntiAffinity` | hard | Indicates if all the sentinel or server pods must be run on different workers (antiAffinity). If set to hard, all sentinels must be on different worker nodes from each other and likewise, all servers must be on different worker nodes from each other.<p>Note: This value will be replaced in the future with server.nodeAntiAffinity and sentinel.nodeAntiAffinity</p> | No |
| partOf | crdb-redisio | Specifies the parent chart that this CRDB helm chart is a part of if CRDB chart is being used as an umbrella chart | **Yes_** |
| `groupName` | <Chart Release\> | Passed into the containers as GROUP_NAME | No |
| `migrateFromChartVersion` | *(empty)* | Can be used in certain upgrade cases (e.g., reset-values) to force the old, single-default-user scheme to be carried forward | Yes |
| `addlSecretLabels` | *(empty)* | Specify the labels to assign to the Redis database secret where password is stored. Must be a single-level key/value dict | No |
| `addlSecretAnnotations` | *(empty)* | Specify the annotations to assign to the Redis database secret where password is stored. Must be a single-level key/value dict | No |
| labels | *(empty)* | Specify the global labels to assign to every created resource | No |
| annotations | *(empty)* | Specify the global annotations to assign to every created resource | No |
| custom.<type>.labels | *(empty)* | Specify the global labels to assign to every created <type> resource, e.g., pod | Yes |
| custom.<type>.annotations | *(empty)* | Specify the global annotations to assign to every created <type> resource, e.g., pod | No |
| custom.<subsystem>.labels | *(empty)* | Specify the global labels to assign to every created resource of CRDB subsystem <subsystem>, e.g., admin | No |
| custom.<subsystem>.annotations | *(empty)* | Specify the global annotations to assign to every created resource of CRDB subsystem <subsystem>, e.g., admin | No |
| `podSecurityContext` | *(empty)* | Specify the global SecurityContext to assign to every created pod | No |
| `containerSecurityContext` | *(empty)* | Specify the global SecurityContext to assign to every created container | No |
| `fifoPath` | /tmp | The path to use for fifo-based config files with sensitive information | **Yes_** |
| `timeZone.timeZoneEnv` | *(empty)* | Set as TZ environment variable in all containers. (Example: America/Chicago or GST-6). If unset, uses UTC. | Yes |
| certManager.* | *(empty)* | Sets Certificate Manager default Certificate Parameters | **Yes_** |
| `istio.version` | 1.5 | The istio version installed on the platform being used for the deployment. Only used if istio.enabled is `true`. | No |
| `istio.enabled` | `false` | Indicates if the deployment is being performed in an istio-enabled namespace. | No |
| `istio.cni.enabled` | `false` | Indicates if the istio CNI plugin is installed. | No |
| `istio.permissive` | `false` | Indicates if mTLS should be set to Permissive mode. | No |
| `istio.createDrForClient` | `false` | Indicates if DestinationRule should be created to allow a client in a non-istio-enabled namespace to access this deployment. | No |
| `istio.gateways` | *(empty)* | List of gateways to add to the deployment. | No |

## Unified Logging Parameters

<a name="logging"></a>

| **Parameter** | **Default** | **Description** | **Update Allowed** |
|:---------------------|:------------|:----------------|:----------------------|
| `unifiedLogging.extension` | None | Map of key/value messages added to each unified log message.<p>Example:</p><p>  extension:</p><p>    key1: "val1"</p><p>    key2: "val2"</p> | Yes |
| `unifiedLogging.syslog.enabled` | False | Enable logging to syslog (console logging is always enabled) | [**Yes_**^2^](#logging_fn) |
| `unifiedLogging.syslog.facility` | None | The facility used to send syslog messages | Yes |
| `unifiedLogging.syslog.host` | None | hostname/IP of the syslog server | Yes |
| `unifiedLogging.syslog.port` | None | Listening port of the syslog server | Yes |
| `unifiedLogging.syslog.protocol` | UDP | UDP, TCP or SSL are supported.<p>NOTE: All keyStore/trustStore values must be provided if specifying SSL.</p> | **Yes_** |
| `unifiedLogging.syslog.timeout` | 1000 | SSL connection / handshake timeout (milliseconds)<p>Only valid when protocol is SSL.</p> | Yes |
| `unifiedLogging.syslog.closeReqType` | `GNUTLS_SHUT_RDWR` | SSL close request type (GNUTLS_SHUT_RDWR or GNUTLS_SHUT_WR)<p>*GNUTLS_SHUT_RDWR*: Waits for response before terminating TLS connection. Not supported by all syslog servers.</p><p>*GNUTLS_SHUT_WR*: Client does not wait for response from server when termination TLS connection to syslog server. Can be used in cases where "TLS bye" errors are seen.</p><p>Only valid when protocol is SSL.</p> | Yes |
| `unifiedLogging.syslog.rfc.enabled` | False | Enable setting RFC-5424 parameters | Yes |
| `unifiedLogging.syslog.rfc.appName` | None | The value to identify the device or application that originated the message (See RFC-5424 APPNAME) | Yes |
| `unifiedLogging.syslog.rfc.procId` | None | The value to identify the process that originated the message (See RFC-5424 PROCID) | Yes |
| `unifiedLogging.syslog.rfc.msgId` | None | The value to identify the type of message (See RFC-5424 MSGID) | Yes |
| `unifiedLogging.syslog.rfc.version` | None | Denotes the version of the syslog protocol specification (See RFC-5424 VERSION) | Yes |
| `unifiedLogging.syslog.keyStore.secretName` | None | Name of secret containing the keyStore file (PCKS12 format)<p>This secret should be pre-created.</p> | **Yes_** |
| `unifiedLogging.syslog.keyStore.key` | None | Name of key within secret containing the keyStore file (PCKS12 format) | **Yes_** |
| `unifiedLogging.syslog.keyStorePassword.secretName` | None | Name of secret containing the keyStore password<p>This secret should be pre-created.</p> | **Yes_** |
| `unifiedLogging.syslog.keyStorePassword.key` | None | Name of key within secret containing the keyStore password | **Yes_** |
| `unifiedLogging.syslog.trustyStore.secretName` | None | Name of secret containing the trustStore file (PCKS12 format)<p>This secret should be pre-created.</p> | **Yes_** |
| `unifiedLogging.syslog.trustStore.key` | None | Name of key within secret containing the trustStore file (PCKS12 format) | **Yes_** |
| `unifiedLogging.syslog.trustStorePassword.secretName` | None | Name of secret containing the trustStore password<p>This secret should be pre-created.</p> | **Yes_** |
| `unifiedLogging.syslog.trustStorePassword.key` | None | Name of key within secret containing the trustStore password | **Yes_** |
| `unifiedLogging.syslog.tls.secretRef.name` | None | Secret name, pointing to a Secret object | [**Yes_**^3^](#logging_fn) |
| `unifiedLogging.syslog.tls.secretRef.keyNames.caCrt` | ca.crt | Name of Secret key, which contains CA certificate | **Yes_** |
| `unifiedLogging.syslog.tls.secretRef.keyNames.tlsKey` | tls.key | Name of Secret key, which contains TLS key | **Yes_** |
| `unifiedLogging.syslog.tls.secretRef.keyNames.tlsCrt` | tls.crt | Name of Secret key, which contains TLS certificate | **Yes_** |

<a name="logging_fn"></a>Footnotes:  
^2^ - Remote logging for init containers may not be possible when istio is enabled. 

^3^ - If syslog is configured for SSL, either the keyStore/trustStore params or the tls.secretRef params should be specified - not both.  If all are blank and certManager is available, a certificate will be generated for syslog.

## User/Authentication Parameters

| **Parameter** | **Default** | **Description** | **Update Allowed** |
|:---------------------|:------------|:----------------|:----------------------|
| systemUsers.<role> | | The system-user definitions. Keys represent the various system roles and the values equate to the username for each role.  Users listed here will have their username:password tuple published in the redis-secrets. See [Redis Security](./oam_redis_security.md) section. | No |
| `systemUsers.replication` | repl-user | Replication User | No |
| `systemUsers.probe` | probe-user | Database Probe User | No |
| `systemUsers.sentinel` | sentinel-user | Sentinel User | No |
| `systemUsers.metrics` | metrics-user | Metrics User | No |
| `systemUsers.tools` | crdb-tools-user | CRDB Tools User | No |
| acl.<username> | | The Access Control List configuration for each user. Each username defined must have rules defined.  See [Redis Security](./oam_redis_security.md) section.  For .rules format, see [Redis ACL](https://redis.io/topics/acl) | **Yes_** |
| acl.<username>.enabled | <user-dependent> | If <username> is Enabled | **Yes_** |
| acl.<username>.password | <user-dependent> | base64-encoded Password for <username>. If blank, a random password will be generated | **Yes_** |
| acl.<username>.rules | <user-dependent> | ACL Rules for <username/> | **Yes_** |
| acl.<username>.secretName | <user-dependent> | Secret where <username> Credentials are stored | No|

## Workload Parameters

### Redis Database Server Parameters

| **Parameter** | **Default** | **Description** | **Update Allowed** |
|:---------------------|:------------|:----------------|:----------------------|
| server.image.name<p>server.image.tag</p><p>server.image.flavor</p><p>server.image.pullPolicy</p> | crdb/redisio<p>imageFlavor</p><p><Version></p><p>IfNotPresent</p> | The docker image to use for the Redis server containers<p>The docker image tag to use for the Redis server containers</p><p>The image flavor (rocky8, centos7) to use for the Redis server containers</p><p>The policy used to determine when to pull a new image from the docker registry</p> | **Yes_** |
| `server.count` | 3 | The number of Redis server pods to create | **Yes_** |
| `server.confInclude` | *(empty)* | Any additional server configuration to be injected into the server conf file. The same configuration include is injected on all server pods identically.<p>*Note: Typically, this would be a multi-line value, which is easier managed in helm with a values file as opposed to attempting to set via helm commandline --set argument.*</p><p>Alternately, double semi-colon (;;) can be used as a line separator if passing this value inline. See the Guide on [Server Configuration](./oam_configuration_management.md#server-configuration-overview) for more information. | No |
| `server.tolerations` | *(empty)* | Node tolerations for server scheduling to nodes with taints. Ref: [kubernetes.io Taints and Tolerations](https://kubernetes.io/docs/concepts/configuration/taint-and-tolerations/). Use with caution. | No |
| `server.nodeSelector` | *(empty)* | Node labels for server pods assignment. Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector. Use with caution. | No |
| `server.topologySpreadConstraints` | *(empty)* | topologySpreadConstraints allow control of how Pods are spread across cluster among failure-domains such as regions, zones, nodes, and other user-defined topology domains. This can help to achieve high availability as well as efficient resource utilization.  Ref: [kubernetes.io Pod Topology Spread Constraints](https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/).<p>**`Note`**: Do not specify `labelSelector` as it will be automatically set by chart to correctly select all server pods.</p> | No |
| `server.priorityClassName` | *(empty)* | The kubernetes Pod priority and preemption class name. Ref: [kubernetes.io Pod Priority Preemption](https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/) | No |
| server.resources.requests.memory<p>server.resources.requests.cpu</p><p>server.resources.requests.ephemeral-storage</p>| 256Mi<p>250m</p><p>1Gi</p> | The Kubernetes Memory, CPU, and ephemeral resource requests for the Redis server pods (See [K8s documentation](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#how-pods-with-resource-requests-are-scheduled)) | **Yes_** |
| server.resources.limits.memory<p>server.resources.limits.cpu</p><p>server.resources.limits.ephemeral-storage</p> | <Equal to Requests\> | The Kubernetes Memory, CPU, and ephemeral resource limits for the Redis server pods (See [K8s documentation](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#how-pods-with-resource-requests-are-scheduled)) | **Yes_** |
| `server.persistence.enabled` | `true` | Enables the creation of a PVC for server pods.  There are several implications if this is disabled.  See the Guide on [Disabling Persistence](./oam_disabling_persistence.md) for more information. | No |
| `server.persistence.size` | `1Gi` | The size of the volume to attach to the Redis server pods (database storage size). <p>*Note: Unless persistence is disabled, a persistent volume is still required for retaining configuration.  The size can be extremely small if the database is not being stored.*</p> | No |
| `server.persistence.storageClass` | *(empty)* | The Kubernetes Storage Class for the volume. If not specified, the default Storage Class will be used | No |
| `server.persistence.preservePvc` | `false` | Boolean. Indicates is the Persistent Volumes should be preserved when the chart is deleted. | Yes |
| `server.tmpfsWorkingDir` | `false` | Boolean. Indicates if the working dir used for the database should be backed by a tmpfs instead of the persistent PVC. This can be used to ensure the database is not stored to disk at all. If this is enabled, there is no persistent storage of the database data and data loss is highly likely in failure scenarios and node reboots. | No |
| `server.majorRollbackDelDb` | `false` | Indicates if the database should be deleted on rollback across Major Releases where the Redis databases are not compatible. | Yes |
| server.loadModules<p>server.loadModules\[\*\].name</p><p>server.loadModules\[\*\].image</p><p>server.loadModules\[\*\].path</p> | *(empty)* | A list of custom modules to load into the Redis database servers. These are loaded using an init-container image containing the module See [Modules](./oam_redis_modules.md). fields can be template partials | **Yes_** |
| server.startupProbe.initialDelaySeconds<p>server.startupProbe.periodSeconds</p><p>server.startupProbe.timeoutSeconds</p><p>server.startupProbe.failureThreshold</p><p>server.startupProbe.successThreshold</p> | 1<p>5</p><p>1</p><p>60</p><p>1</p> | The Kubernetes startup probe configuration for the Redis Server container (See [K8s documentation](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes)) | **Yes_** |
| server.livenessProbe.initialDelaySeconds<p>server.livenessProbe.periodSeconds</p><p>server.livenessProbe.timeoutSeconds</p><p>server.livenessProbe.failureThreshold</p><p>server.livenessProbe.successThreshold</p> | 180<p>10</p><p>5</p><p>6</p><p>1</p> | The Kubernetes liveness probe configuration for the Redis Server container (See [K8s documentation](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes)) | **Yes_** |
| server.readinessProbe.initialDelaySeconds<p>server.readinessProbe.periodSeconds</p><p>server.readinessProbe.timeoutSeconds</p><p>server.readinessProbe.failureThreshold</p><p>server.readinessProbe.successThreshold</p> | 10<p>15</p><p>1</p><p>3</p><p>1</p> | The Kubernetes readiness probe configuration for the Redis Server container (See [K8s documentation](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes)) | **Yes_** |
| `server.terminationGracePeriodSeconds` | 120 | Defines the grace period for termination of server Pods | **Yes_** |
| `server.podSecurityContext` | *(empty)* | Specify the SecurityContext to assign to every server pod | No |
| `server.containerSecurityContext` | *(empty)* | Specify the SecurityContext to assign to every server container | No |
| `server.pdb.enabled` | `true` | Indicates if the PodDisruptionBudget (PDB) is enabled for the pods in the server statefulset.  Ref: [kubernetes.io Specifying a Disruption Budget for your Application](https://kubernetes.io/docs/tasks/run-application/configure-pdb/). | Yes |
| `server.pdb.minAvailable` | 50% | The number of pods from that set that must still be available after the eviction, even in the absence of the evicted pod. minAvailable can be either an absolute number or a percentage.  Ref: [kubernetes.io Specifying a Disruption Budget for your Application](https://kubernetes.io/docs/tasks/run-application/configure-pdb/). Only used if server.pdb.enabled=true.  | Yes |
| `server.pdb.maxUnavailable` | *(empty)* | The number of pods from that set that can be unavailable after the eviction. It can be either an absolute number or a percentage.  Ref: [kubernetes.io Specifying a Disruption Budget for your Application](https://kubernetes.io/docs/tasks/run-application/configure-pdb/). Only used if server.pdb.enabled=true.  | Yes |
| `server.metrics.containerSecurityContext` | *(empty)* | Specify the SecurityContext to assign to every server metrics container | No |
| server.metrics.image.name<p>server.metrics.image.tag</p><p>server.metrics.image.pullPolicy</p> | oliver006/redis_exporter<p><Version></p><p>IfNotPresent</p> | The docker image to use for the Redis server Exporter (metrics) containers<p>The docker image tag to use for the Redis server containers</p><p>The policy used to determine when to pull a new image from the docker registry</p> | **Yes_** |
| `server.auditLogging.enabled` | `true` | Boolean. Indicates if server audit logging should be enabled. | **Yes_** |
| `server.auditLogging.events` | [auth,permission] | A list of the types of audit events that should be logged. (currently supported: auth, permission) | **Yes_** |
| `server.customBind` | *(empty)* | By default server pods bind to all interfaces/IPs.  This Value can be used to define a custom bind directive.  Can use $(POD_IP), $(POD_IPS) env variable references, which will be resolved.  Commas will be replaced with spaces. | Yes |

### Redis Sentinel Parameters

| **Parameter** | **Default** | **Description** | **Update Allowed** |
|:---------------------|:------------|:----------------|:----------------------|
| `sentinel.enabled` | `true` | Boolean. Indicates if Redis Sentinel pods should be created.<p>*Note: Must be set to `false` if cluster.enabled is `true`</p> | No |
| sentinel.image.name<p>sentinel.image.tag</p><p>sentinel.image.flavor</p><p>sentinel.image.pullPolicy</p> | crdb/redisio<p>*(empty)*</p><p>*(empty)*</p><p>*(empty)*</p> | The docker image to use for the Redis Sentinel containers<p>The docker image tag to use for the Redis Sentinel container\*</p><p>The image flavor (rocky8, centos7) to use for the Redis sentinel containers\*</p><p> The policy used to determine when to pull a new image from the docker registry\*</p><p>*\*Note: If not set, the server.image values will be used*</p> | **Yes_** |
| `sentinel.count` | 3 | The number of Redis Sentinel pods to create, 3 minimum | **Yes_** |
| `sentinel.quorum` | 2 | The number of Sentinels that must agree on a master as down to invoke a failover.<p>*Note: There must still be a majority of Sentinels (≈ 1/2 + sentinel.count/2) to perform the failover.*</p> | No |
| `sentinel.downAfterMilliseconds` | 5000 | The time in milliseconds a server should not be reachable for a Sentinel starting to think it is down | No |
| `sentinel.failoverTimeout` | 30000 | The time in milliseconds before a Sentinel can failover the same master again. | No |
| `sentinel.parallelSyncs` | 1 | The number of slaves that can be reconfigured to use the new master after a failover at the same time. | No |
| `sentinel.tolerations` | *(empty)* | Node tolerations for sentinel scheduling to nodes with taints. Ref: [kubernetes.io Taints and Tolerations](https://kubernetes.io/docs/concepts/configuration/taint-and-tolerations/). Use with caution. | No |
| `sentinel.nodeSelector` | *(empty)* | Node labels for sentinel pods assignment. Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector. Use with caution. | No |
| `sentinel.topologySpreadConstraints` | *(empty)* | topologySpreadConstraints allow control of how Pods are spread across cluster among failure-domains such as regions, zones, nodes, and other user-defined topology domains. This can help to achieve high availability as well as efficient resource utilization.  Ref: [kubernetes.io Pod Topology Spread Constraints](https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/).<p>**`Note`**: Do not specify `labelSelector` as it will be automatically set by chart to correctly select all sentinel pods.</p> | No |
| `sentinel.priorityClassName` | *(empty)* | The kubernetes Pod priority and preemption class name. Ref: [kubernetes.io Pod Priority Preemption](https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/) | No |
| sentinel.resources.requests.memory<p>sentinel.resources.requests.cpu</p><p>sentinel.resources.requests.ephemeral-storage</p> | 256Mi<p>250m</p><p>64Mi</p> | The Kubernetes Memory, CPU, and ephemeral resource requests for the Redis Sentinel pods (See [K8s documentation](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#how-pods-with-resource-requests-are-scheduled)) | **Yes_** |
| sentinel.resources.limits.memory<p>sentinel.resources.limits.cpu</p><p>sentinel.resources.limits.ephemeral-storage</p> | 256Mi<p>250m</p><p>64Mi</p> | The Kubernetes Memory, CPU, and ephemeral resource limits for the Redis Sentinel pods (See [K8s documentation](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#how-pods-with-resource-requests-are-scheduled)) | **Yes_** |
| `sentinel.persistence.size` | `1Gi` | The size of the volume to attach to the Redis sentinel pods (sentinel config) | No |
| `sentinel.persistence.storageClass` | *(empty)* | The Kubernetes Storage Class for the volume. If not specified, the default Storage Class will be used | No |
| `sentinel.persistence.preservePvc` | `false` | Boolean. Indicates is the Persistent Volumes should be preserved when the chart is deleted. | Yes |
| sentinel.livenessProbe.initialDelaySeconds<p>sentinel.livenessProbe.periodSeconds</p><p>sentinel.livenessProbe.timeoutSeconds</p><p>sentinel.livenessProbe.failureThreshold</p> | 180<p>10</p><p>5</p><p>6</p> | The Kubernetes liveness probe configuration for the Redis Sentinel container (See [K8s documentation](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes)) | **Yes_** |
| sentinel.readinessProbe.initialDelaySeconds<p>sentinel.readinessProbe.periodSeconds</p><p>sentinel.readinessProbe.timeoutSeconds</p><p>sentinel.readinessProbe.failureThreshold</p> | 10<p>20</p><p>2</p><p>3</p> | The Kubernetes readiness probe configuration for the Redis Sentinel container (See [K8s documentation](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes)) | **Yes_** |
| `sentinel.podSecurityContext` | *(empty)* | Specify the SecurityContext to assign to every sentinel pod | No |
| `sentinel.containerSecurityContext` | *(empty)* | Specify the SecurityContext to assign to every sentinel container | No |
| `sentinel.pdb.enabled` | `true` | Indicates if the PodDisruptionBudget (PDB) is enabled for the pods in the sentinel statefulset.  Ref: [kubernetes.io Specifying a Disruption Budget for your Application](https://kubernetes.io/docs/tasks/run-application/configure-pdb/). | Yes |
| `sentinel.pdb.minAvailable` | 50% | The number of pods from that set that must still be available after the eviction, even in the absence of the evicted pod. minAvailable can be either an absolute number or a percentage.  Ref: [kubernetes.io Specifying a Disruption Budget for your Application](https://kubernetes.io/docs/tasks/run-application/configure-pdb/). Only used if sentinel.pdb.enabled=true.  | Yes |
| `sentinel.pdb.maxUnavailable` | *(empty)* | The number of pods from that set that can be unavailable after the eviction. It can be either an absolute number or a percentage.  Ref: [kubernetes.io Specifying a Disruption Budget for your Application](https://kubernetes.io/docs/tasks/run-application/configure-pdb/). Only used if sentinel.pdb.enabled=true.  | Yes |
| `sentinel.customBind` | *(empty)* | By default sentinel pods bind to all interfaces/IPs.  This Value can be used to define a custom bind directive.  Can use $(POD_IP), $(POD_IPS) env variable references, which will be resolved.  Commas will be replaced with spaces. | Yes |
| `sentinel.metrics.enabled` | `true` | Boolean.  Indicates if metrics should be exported for sentinel. | Yes |
| `sentinel.metrics.usePodServices` | `false` | Boolean.  Indicates if a metrics service should be created for each sentinel pod. | Yes |
| `sentinel.metrics.containerSecurityContext` | *(empty)* | Specify the SecurityContext to assign to every sentinel metrics container | No |
| sentinel.metrics.image.name<p>sentinel.metrics.image.tag</p><p>sentinel.metrics.image.pullPolicy</p> | oliver006/redis_exporter<p><Version></p><p>IfNotPresent</p> | The docker image to use for the Redis server Exporter (metrics) containers<p>The docker image tag to use for the Redis server containers</p><p>The policy used to determine when to pull a new image from the docker registry</p> | **Yes_** |
| `sentinel.acl.enabled` | `true` | Boolean.  Enables authentication for sentinel to sentinel communication.  When enabled, sentinel can only be accessed with the sentinel systemUser credentials. | **Yes_** |

### CRDB Rolemon Parameters

| **Parameter** | **Default** | **Description** | **Update Allowed** |
|:---------------------|:------------|:----------------|:----------------------|
| rolemon.image.name<p>rolemon.image.tag</p><p>rolemon.image.flavor</p><p>rolemon.image.pullPolicy</p> | crdb/rolemon<p>*(empty)*</p><p>*(empty)*</p><p>*(empty)*</p> | The docker image to use for the CRDB Redis Role-monitor sidecar containers<p>The docker image tag to use for the CRDB Redis Role-monitor sidecar containers\*</p><p>The image flavor (rocky8, centos7) to use for the CRDB Redis Role-monitor containers\*</p><p>The policy used to determine when to pull a new image from the docker registry\*</p><p>*\*Note: If not set, the server.image values will be used*</p> | **Yes_** |
| rolemon.resources.requests.memory<p>rolemon.resources.requests.cpu</p><p>rolemon.resources.requests.ephemeral-storage</p>| 64Mi<p>250m</p><p>64Mi</p> | The Kubernetes Memory, CPU, and ephemeral resource requests for the CRDB Redis Role-monitor sidecar containers (See [K8s documentation](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#how-pods-with-resource-requests-are-scheduled)) | **Yes_** |
| rolemon.resources.limits.memory<p>rolemon.resources.limits.cpu</p><p>rolemon.resources.limits.ephemeral-storage</p> | 64Mi<p>250m</p><p>64Mi</p> | The Kubernetes Memory, CPU, and ephemeral resource limits for the CRDB Redis Role-monitor sidecar containers (See [K8s documentation](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#how-pods-with-resource-requests-are-scheduled)) | **Yes_** |
| `rolemon.containerSecurityContext` | *(empty)* | Specify the SecurityContext to assign to every rolemon container | No |
| rolemon.livenessProbe.initialDelaySeconds<p>rolemon.livenessProbe.periodSeconds</p><p>rolemon.livenessProbe.timeoutSeconds</p><p>rolemon.livenessProbe.failureThreshold</p> | 180<p>60</p><p>5</p><p>6</p> | The Kubernetes liveness probe configuration for the Redis Rolemon container (See [K8s documentation](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes)) | **Yes_** |

### CRDB Administrative Parameters

| **Parameter** | **Default** | **Description** | **Update Allowed** |
|:---------------------|:------------|:----------------|:----------------------|
| `admin.image.registry` | <global.registry\> | The registry (global.registry override) to use for pulling the Admin container image. | Yes |
| `admin.image.name` | crdb/admin | The docker image to use for the Admin container(s) (Jobs) | Yes |
| `admin.image.flavor` | *(empty)* | The image flavor (rocky8, centos7) to use for the Admin containers. \* | Yes |
| `admin.image.tag` | *(empty)* | The docker image tag to use for the Admin containers.\* | Yes |
| `admin.image.pullPolicy` | *(empty)* | The policy used to determine when to pull a new image from the docker registry\*<p>*\*Note: If not set, the server.image values will be used*</p> | Yes |
| `admin.debug` | `false` | If true, the Admin container(s) will include more verbose output on stdout | Yes |
| `admin.preUpgradeActiveDeadlineSeconds` | 1800 | activeDeadlineSeconds for pre-upgrade-job | No |
| `admin.persistence.enabled` | `true` | Boolean. Indicates whether separate "admin" volume should be attached to the Admin pod. This should not be changed. | No |
| `admin.persistence.size` | `1Gi` | The size of the volume to attach to the Admin pod. | No |
| `admin.persistence.storageClass` | *(empty)* | The Kubernetes Storage Class for the admin persistent volume. Default is to use the kubernetes default storage class. | No |
| `admin.tolerations` | *(empty)* | Node tolerations for admin scheduling to nodes with taints. Ref: [kubernetes.io Taints and Tolerations](https://kubernetes.io/docs/concepts/configuration/taint-and-tolerations/). Use with caution. | No |
| `admin.nodeSelector` | *(empty)* | Node labels for admin pods assignment. Ref: [kubernetes.io Node Selector](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector). Use with caution. | No |
| `admin.topologySpreadConstraints` | *(empty)* | topologySpreadConstraints allow control of how Pods are spread across cluster among failure-domains such as regions, zones, nodes, and other user-defined topology domains. This can help to achieve high availability as well as efficient resource utilization.  Ref: [kubernetes.io Pod Topology Spread Constraints](https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/).<p>**`Note`**: Do not specify `labelSelector` as it will be automatically set by chart to correctly select all admin pods.</p> | No |
| `admin.priorityClassName` | *(empty)* | The kubernetes Pod priority and preemption class name. Ref: [kubernetes.io Pod Priority Preemption](https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/) | No |
| admin.resources.requests.memory<p>admin.resources.requests.cpu</p><p>admin.resources.requests.ephemeral-storage</p> | 256Mi<p>250m</p><p>256Mi</p> | The Kubernetes Memory, CPU, and ephemeral resource requests for the Admin pod (See [K8s documentation]( https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#how-pods-with-resource-requests-are-scheduled)) | **Yes_** |
| admin.resources.limits.memory<p>admin.resources.limits.cpu</p><p>admin.resources.limits.ephemeral-storage</p> | 256Mi<p>250m</p><p>256Mi</p> | The Kubernetes Memory, CPU, and ephemeral resource limits for the Admin pod (See [K8s documentation]( https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#how-pods-with-resource-requests-are-scheduled)) | **Yes_** |
| admin.nodeAffinity.enabled<p>admin.nodeAffinity.key</p><p>admin.nodeAffinity.value</p> | true<p>is_worker</p><p>true</p> | Node affinity key for the admin pod. | No |
| admin.livenessProbe.initialDelaySeconds<p>admin.livenessProbe.periodSeconds</p><p>admin.livenessProbe.timeoutSeconds</p><p>admin.livenessProbe.failureThreshold</p> | 300<p>10</p><p>6</p><p>6</p> | The Kubernetes liveness probe configuration for the Admin container (See [K8s documentation](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes)) | **Yes_** |
| admin.readinessProbe.initialDelaySeconds<p>admin.readinessProbe.periodSeconds</p><p>admin.readinessProbe.timeoutSeconds</p><p>admin.readinessProbe.failureThreshold</p> | 10<p>10</p><p>6</p><p>3</p> | The Kubernetes readiness probe configuration for the Admin container (See [K8s documentation](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes)) | **Yes_** |
| `admin.podSecurityContext` | *(empty)* | Specify the SecurityContext to assign to every admin pod | No |
| `admin.containerSecurityContext` | *(empty)* | Specify the SecurityContext to assign to every admin container | No |
| `admin.pdb.enabled` | `false` | Indicates if the PodDisruptionBudget (PDB) is enabled for the pods in the admin statefulset.  Ref: [kubernetes.io Specifying a Disruption Budget for your Application](https://kubernetes.io/docs/tasks/run-application/configure-pdb/). | Yes |
| `admin.pdb.minAvailable` | *(empty)* | The number of pods from that set that must still be available after the eviction, even in the absence of the evicted pod. minAvailable can be either an absolute number or a percentage.  Ref: [kubernetes.io Specifying a Disruption Budget for your Application](https://kubernetes.io/docs/tasks/run-application/configure-pdb/). Only used if admin.pdb.enabled=true.  | Yes |
| `admin.pdb.maxUnavailable` | 100% | The number of pods from that set that can be unavailable after the eviction. It can be either an absolute number or a percentage.  Ref: [kubernetes.io Specifying a Disruption Budget for your Application](https://kubernetes.io/docs/tasks/run-application/configure-pdb/). Only used if admin.pdb.enabled=true.  | Yes |

### Backup agent (CBURA) Parameters

| **Parameter** | **Default** | **Description** | **Update Allowed** |
|:---------------------|:------------|:----------------|:----------------------|
| `cbur.enabled` | `true` | If true, the Backup agent will be included as a sidecar for integration with the CBUR backup solution. | No |
| `cbur.apiVersion` | cbur.csf.nokia.com/v1 | apiVersion used for CBUR BrHook and BrPolicy Objects | Yes |
| `cbur.legacyHooks` | `false` | Forces use of legacy NCMS Helm plugin hooks to override the CBUR BrHook API | Yes |
| cbur.image.name<p>cbur.image.tag</p><p>cbur.image.pullPolicy</p> | cbur/cbur-agent<p>*(empty)*</p><p>*(empty)*</p> | ==CHANGED IN 9.0.0== The docker image to use for the CBURA sidecar containers<p>The docker image tag to use for the CBURA sidecar containers. If unset, uses the CBURA sidecar version built-in to the chart (See Release Notes for version).  \*</p><p>The policy used to determine when to pull a new image from the docker registry</p><p>*\*Note: If not set, the server.image values will be used*</p> | **Yes_** |
| cbur.resources.requests.memory<p>cbur.resources.requests.cpu</p><p>cbur.resources.requests.ephemeral-storage</p> | 256Mi<p>250m</p><p>64Mi</p> | The Kubernetes Memory, CPU, and ephemeral resource requests for the CBURA sidecar containers (See [K8s documentation]( https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#how-pods-with-resource-requests-are-scheduled)) | **Yes_** |
| cbur.resources.limits.memory<p>cbur.resources.limits.cpu</p><p>cbur.resources.limits.ephemeral-storage</p> | 256Mi<p>250m</p><p>64Mi</p> | The Kubernetes Memory, CPU, and ephemeral resource limits for the CBURA sidecar containers (See [K8s documentation]( https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#how-pods-with-resource-requests-are-scheduled)) | **Yes_** |
| `cbur.brhookType` | brpolicy | Specifies the targetType (brpolicy|release) of a specific BrHook API. | Yes |
| `cbur.brhookWeight` | 0 | Specifies the weight (integer) to control sequencing of multiple BrHook APIs. | Yes |
| `cbur.brhookEnable` | `true` | Specifies if the BrHook API should be enabled. | Yes |
| `cbur.brhookTimeout` | 600 | Specifies the timeout (seconds) of maximum wait time for the BrHook API Job. | Yes |
| cbur.brPolicy.weight<p>cbur.brPolicy.backend.mode</p><p>cbur.brPolicy.cronSpec</p><p>cbur.brPolicy.dataEncryption.enable</p><p>cbur.brPolicy.dataEncryption.secret</p><p>cbur.brPolicy.maxiCopy</p><p>cbur.brPolicy.autoEnableCron</p><p>cbur.brPolicy.autoUpdateCron</p><p>cbur.brPolicy.bypassPod.matchLabels</p><p>cbur.brPolicy.selectPod.matchLabels</p> | 0<p>local</p><p>0 0 \* \* \*</p><p>true</p><p>*(empty)*</p><p>5</p><p>false</p><p>false</p><p>*(empty)*</p><p>*(empty)*</p> | Various properties set directly on the BRPolicy object to configure the backup/restore options.  (See the Containerized CBUR Guide -> OAM Guide -> BrPolicy page for details on each).<p>Note: These values are directly passed through to the resulting BrPolicy object unmodified.</p> | Yes |
| cbur.backup.upgrade<p>cbur.backup.timeout</p> | false<p>900</p> | Perform automatic backup on (before) upgrade.<p>Triggered during pre-upgrade, only when Server image or count change detected</p><p>(Values changed: server.image.* or server.count)</p><p>Note: User must ensure admin.preUpgradeTimeout and helm timeout sufficient to perform backup AND upgrade, or timeout failures will occur.</p><p>Timeout for performing backup (sec)</p> | Yes |
| cbur.service.namespace<p>cbur.service.name</p><p>cbur.service.protocol</p> | ncms<p>`cbur-master-cbur `</p><p>http</p> | CBUR Master Service access info used to initiate backup via CBUR API, e.g., when cbur.backup.upgrade: true.<p>The <b>namespace</b> where the CBUR Master Service (ignored if url set)</p><p>The Service <b>name</b> of the CBUR Master Service (ignored if url set)</p><p>The <b>protocol</b> to use for CBUR API (http/https)</p> | Yes |
| `cbur.service.url` | *(empty)* | If unset, will be automatically constructed from cbur.service.name, cbur.service.namespace, and clusterDomain. Can be used to set a custom URL | Yes |
| `cbur.service.authSecret` | *(empty)* | The secret from CBUR copied into our namespace providing username/password for accessing the CBUR Master Service. Necessary when CBUR basic-auth is enabled | Yes |
| `cbur.containerSecurityContext` | *(empty)* | Specify the SecurityContext to assign to every cbur sidecar container | No |

## Redis Cluster Parameters

| **Parameter** | **Default** | **Description** | **Update Allowed** |
|:---------------------|:------------|:----------------|:----------------------|
| `cluster.enabled` | `false` | If Redis Cluster should be enabled<p>*Note: Must be set to `false` if sentinel.enabled is `true`</p> | No |
| `cluster.shardCount` | 3 | The number of shards to split the Redis Cluster database info, 3 minimum | **Yes_** |
| `cluster.confInclude` | *(empty)* | Any additional cluster configuration to be injected into the server conf file. The same configuration include is injected on all server pods identically.<p>*Note: Typically, this would be a multi-line value, which is easier managed in helm with a values file as opposed to attempting to set via helm commandline --set argument.*</p>| No |
| `cluster.audit.timers.no_action_time` | 300 | Seconds the cluster robustness audit will wait between corrective actions. | Yes |
| `cluster.audit.timers.resched_label_time` | 30 | Seconds the cluster robustness audit will leave a pod labeled for avoidance during reschedule corrective actions. | Yes |
| `cluster.audit.slaveMovementMode` | reschedule | Controls how slaves are moved away from masters when found co-located: (reschedule\|reconfigure).  Should only be changed in specific situations where pods cannot be rescheduled to different nodes. | Yes |
| `cluster.masterRestartDelay` | 10 | Seconds a previous master will delay restarting when server persistence is disabled to avoid coming up as master with an empty database. [Disabling Persistence](./oam_disabling_persistence.md) | Yes |

## Redis Services Parameters

| **Parameter** | **Default** | **Description** | **Update Allowed** |
|:---------------------|:------------|:----------------|:----------------------|
| `services.redis.type` | `ClusterIP` | Either ClusterIP or NodePort - depending on if the DB should be accessible only within the cluster or exposed externally, respectively | No |
| services.redis.nodePort<p>services.redis.nodePortReadOnly</p> | *(empty)*<b>*(empty)*</p> | If services.redis.type is set to NodePort, the specific node port to be used can be specified here for both the Master redis service as well as the read-only service | No |
| `services.redis.tlsPort` | *(empty)* | ==NEW IN 9.0.0== The Port for accessing the primary Redis database Service when TLS Enabled.  Defaults to 6379 if unset. | Yes |
| `services.redis.nonTlsPort` | *(empty)* | ==NEW IN 9.0.0== The Port for accessing the primary Redis database Service via non-TLS when TLS not Enabled.  If set while TLS Enabled, it allows for simultaneous non-TLS access to the database.  Defaults to 6379 if unset. | Yes |

## Hook Parameters

| **Parameter** | **Default** | **Description** | **Update Allowed** |
|:---------------------|:------------|:----------------|:----------------------|
| `hooks.deletePolicy` | hook-succeeded,before-hook-creation | The deletion policy to use for Kubernetes Jobs. By default, the jobs will be deleted upon success. | Yes |
| hooks.preInstallJob.enabled<p>hooks.preInstallJob.name</p><p>hooks.preInstallJob.containerName</p><p>hooks.preInstallJob.timeout</p> | true<p>pre-install</p><p>pre-install-admin</p><p>120</p> |  Set **enabled** to `false` to disable running of the pre-install-job. Set **name** to change the job pod name.  Set `containerName` to change the default job pod container name. Set **timeout** to change the job timeout (in seconds).| Yes |
| hooks.postInstallJob.enabled<p>hooks.postInstallJob.name</p><p>hooks.postInstallJob.containerName</p><p>hooks.postInstallJob.timeout</p> | true<p>post-install</p><p>post-install-admin</p><p>900</p> | Set **enabled** to `false` to disable running of the post-install-job. Set **name** to change the job pod name.  Set `containerName` to change the default job pod container name. Set **timeout** to change the job timeout (in seconds).| Yes |
| hooks.preUpgradeJob.enabled<p>hooks.preUpgradeJob.name</p><p>hooks.preUpgradeJob.containerName</p><p>hooks.preUpgradeJob.timeout</p> | true<p>pre-upgrade</p><p>pre-upgrade-admin</p><p>1800</p> | Set **enabled** to `false` to disable running of the pre-upgrade-job. Set **name** to change the job pod name.  Set `containerName` to change the default job pod container name. Set **timeout** to change the job timeout (in seconds).| Yes |
| hooks.postUpgradeJob.enabled<p>hooks.postUpgradeJob.name</p><p>hooks.postUpgradeJob.containerName</p><p>hooks.postUpgradeJob.timeout</p> | true<p>post-upgrade</p><p>post-upgrade-admin</p><p>1800</p> | Set **enabled** to `false` to disable running of the post-upgrade-job. Set **name** to change the job pod name.  Set `containerName` to change the default job pod container name. Set **timeout** to change the job timeout (in seconds).| Yes |
| hooks.preRollbackJob.enabled<p>hooks.preRollbackJob.name</p><p>hooks.preRollbackJob.containerName</p><p>hooks.preRollbackJob.timeout</p> | true<p>pre-rollback</p><p>pre-rollback-admin</p><p>1800</p> | Set **enabled** to `false` to disable running of the pre-rollback-job. Set **name** to change the job pod name.  Set `containerName` to change the default job pod container name. Set **timeout** to change the job timeout (in seconds).| Yes |
| hooks.postRollbackJob.enabled<p>hooks.postRollbackJob.name</p><p>hooks.postRollbackJob.containerName</p><p>hooks.postRollbackJob.timeout</p> | true<p>post-rollback</p><p>post-rollback-admin</p><p>1800</p> | Set **enabled** to `false` to disable running of the post-rollback-job. Set **name** to change the job pod name.  Set `containerName` to change the default job pod container name. Set **timeout** to change the job timeout (in seconds).| Yes |
| hooks.preDeleteJob.enabled<p>hooks.preDeleteJob.name</p><p>hooks.preDeleteJob.containerName</p><p>hooks.preDeleteJob.timeout</p> | true<p>pre-delete</p><p>pre-delete-admin</p><p>120</p> | Set **enabled** to `false` to disable running of the pre-delete-job. Set **name** to change the job pod name.  Set `containerName` to change the default job pod container name. Set **timeout** to change the job timeout (in seconds).| Yes |
| hooks.postDeleteJob.enabled<p>hooks.postDeleteJob.name</p><p>hooks.postDeleteJob.containerName</p><p>hooks.postDeleteJob.timeout</p> | true<p>post-delete</p><p>post-delete-admin</p><p>180</p> | Set **enabled** to `false` to disable running of the post-delete-job. Set **name** to change the job pod name.  Set `containerName` to change the default job pod container name. Set **timeout** to change the job timeout (in seconds).| Yes |
| hooks.preRestoreJob.name<p>hooks.preRestoreJob.containerName</p><p>hooks.preRestoreJob.timeout</p> | pre-restore<p>pre-restore-admin</p><p>180</p> | Set **name** to change the job pod name.  Set `containerName` to change the default job pod container name. Set **timeout** to change the job timeout (in seconds).| Yes |
| hooks.postRestoreJob.name<p>hooks.postRestoreJob.containerName</p><p>hooks.postRestoreJob.timeout</p> | post-restore<p>post-restore-admin</p><p>180</p> | Set **name** to change the job pod name.  Set `containerName` to change the default job pod container name. Set **timeout** to change the job timeout (in seconds).| Yes |

## Data-in-Flight Encryption (TLS/SSL) Parameters

### TLS root level parameters

| **Parameter** | **Default** | **Description** | **Update Allowed** |
|:---------------------|:------------|:----------------|:----------------------|
| `tls.enabled` | `false` | Specifies whether TLS will be enabled on the Redis database. | **Yes_** |
| `tls.authClients` | `true` | If tls.enabled, specifies whether client connections will require TLS and certificates validated by the Redis database. | **Yes_** |
| `tls.certificates.threshold` | 7 | The number of days before a certificates expires that an alarm will be issued warning of the expiration. A zero value will disable the alarms. | **Yes_** |
| `tls.certificates.server.rolloutWait` | 3600 | If a certificate is replaced without restarting the service pods, (a la cmgr), a rollout will be started rolloutWait seconds after the update to get redis servers to reload the certs. A zero value will disable the rollout, but the application must take other steps to get the new certificate loaded. The rollout condition is only checked once an hour in certificate alarm loop, so disabling certificate alarms using the threshold parameter also disables the rollout. | **Yes_** |

### TLS server workload parameters

| **Parameter** | **Default** | **Description** | **Update Allowed** |
|:---------------------|:------------|:----------------|:----------------------|
| `server.tls.enabled` | `false` | Overrides tls.enabled. Specifies whether TLS will be enabled on the Redis database server workload. | No |
| server.tls.secretRef.name<p>server.tls.secretRef.keyNames.caCrt</p><p>server.tls.secretRef.keyNames.tlsKey</p><p>server.tls.secretRef.keyNames.tlsCrt</p> | <p>*(empty)*</p><p>ca.crt</p><p>tls.key</p><p>tls.crt</p> | The certificate Secret to use for the server-side of encryption. The secret name provides the Secret Name. The caCrt, tlsCrt, and tlsKey sub-Values indicate the data items within the Secret, respectively. | No |
| server.certificate.duration<p>server.certificate.renewBefore</p> | 8760h<p>360h</p> | Certificate default duration and renewal (See [cert-manager documentation](https://cert-manager.io/docs/usage/certificate/#creating-certificate-resources) | No
| `server.certificate.commonName` | <fullname>.<namespace>.svc.<clusterDomain> | Common Name to be used on the certificate (See [cert-manager documentation](https://cert-manager.io/docs/usage/certificate/#creating-certificate-resources) | No |
| server.certificate.caIssuer.name<p>server.certificate.caIssuer.kind</p><p>server.certificate.caIssuer.group</p> | ncms-ca-issuer<p>ClusterIssuer</p><p>cert-manager.io</p> | The CA Issuer details (See [cert-manager documentation](https://cert-manager.io/docs/usage/certificate/#creating-certificate-resources) | No |
| `server.certificate.dnsNames` | [<fullname>.<namespace>.svc.<clusterDomain>] | List of DNS Names to include in the Certificate (See [cert-manager documentation](https://cert-manager.io/docs/usage/certificate/#creating-certificate-resources) | No |
| `server.certificate.ipAddresses` | [*(empty)*] | List of IP Addresses to include in the Certificate (See [cert-manager documentation](https://cert-manager.io/docs/usage/certificate/#creating-certificate-resources) | No |
| `server.certificate.uris` | [*(empty)*] | List of URIs to include in the Certificate (See [cert-manager documentation](https://cert-manager.io/docs/usage/certificate/#creating-certificate-resources) | No |
| `server.certificate.subject` | [*(empty)*] | Subject to use in the Certificate (See [cert-manager documentation](https://cert-manager.io/docs/usage/certificate/#creating-certificate-resources) | No |
| server.certificate.privateKey.algorithm/encoding/size/rotationPolicy | [*(empty)*]<p>[*(empty)*]</p><p>[*(empty)*]</p><p>Always</p> | PrivateKey to include in the Certificate (See [cert-manager documentation](https://cert-manager.io/docs/usage/certificate/#creating-certificate-resources) | No |

### TLS sentinel workload parameters

| **Parameter** | **Default** | **Description** | **Update Allowed** |
|:---------------------|:------------|:----------------|:----------------------|
| `sentinel.tls.enabled` | `false` | Overrides tls.enabled. Specifies whether TLS will be enabled on the sentinel workload. | No |
| sentinel.tls.secretRef.name<p>sentinel.tls.secretRef.keyNames.caCrt</p><p>sentinel.tls.secretRef.keyNames.tlsKey</p><p>sentinel.tls.secretRef.keyNames.tlsCrt</p> | <p>*(empty)*</p><p>ca.crt</p><p>tls.key</p><p>tls.crt</p> | The certificate Secret to use for the server-side of encryption. The secret name provides the Secret Name. The caCrt, tlsCrt, and tlsKey sub-Values indicate the data items within the Secret, respectively. | No |
| sentinel.certificate.duration<p>server.certificate.renewBefore</p> | 8760h<p>360h</p> | Certificate default duration and renewal (See [cert-manager documentation](https://cert-manager.io/docs/usage/certificate/#creating-certificate-resources) | No
| `sentinel.certificate.commonName` | <fullname>.<namespace>.svc.<clusterDomain> | Common Name to be used on the certificate (See [cert-manager documentation](https://cert-manager.io/docs/usage/certificate/#creating-certificate-resources) | No |
| sentinel.certificate.caIssuer.name<p>server.certificate.caIssuer.kind</p><p>server.certificate.caIssuer.group</p> | ncms-ca-issuer<p>ClusterIssuer</p><p>cert-manager.io</p> | The CA Issuer details (See [cert-manager documentation](https://cert-manager.io/docs/usage/certificate/#creating-certificate-resources) | No |
| `sentinel.certificate.dnsNames` | [<fullname>.<namespace>.svc.<clusterDomain>] | List of DNS Names to include in the Certificate (See [cert-manager documentation](https://cert-manager.io/docs/usage/certificate/#creating-certificate-resources) | No |
| `sentinel.certificate.ipAddresses` | [*(empty)*] | List of IP Addresses to include in the Certificate (See [cert-manager documentation](https://cert-manager.io/docs/usage/certificate/#creating-certificate-resources) | No |
| `sentinel.certificate.uris` | [*(empty)*] | List of URIs to include in the Certificate (See [cert-manager documentation](https://cert-manager.io/docs/usage/certificate/#creating-certificate-resources) | No |
| `sentinel.certificate.subject` | [*(empty)*] | Subject to use in the Certificate (See [cert-manager documentation](https://cert-manager.io/docs/usage/certificate/#creating-certificate-resources) | No |
| sentinel.certificate.privateKey.algorithm<p>sentinel.certificate.privateKey.algorithm.encoding</p><p>sentinel.certificate.privateKey.algorithm.size</p><p>sentinel.certificate.privateKey.algorithm.rotationPolicy</p> | [*(empty)*]<p>[*(empty)*]</p><p>[*(empty)*]</p><p>Always</p> | PrivateKey to include in the Certificate (See [cert-manager documentation](https://cert-manager.io/docs/usage/certificate/#creating-certificate-resources) | No |

### TLS client workload parameters

| **Parameter** | **Default** | **Description** | **Update Allowed** |
|:---------------------|:------------|:----------------|:----------------------|
| `clients.internal.tls.enabled` | `false` | Overrides tls.enabled. Specifies whether TLS will be enabled for internal client workloads. | No |
| clients.internal.tls.secretRef.name<p>clients.internal.tls.secretRef.keyNames.caCrt</p><p>clients.internal.tls.secretRef.keyNames.tlsKey</p><p>clients.internal.tls.secretRef.keyNames.tlsCrt</p> | <p>*(empty)*</p><p>ca.crt</p><p>tls.key</p><p>tls.crt</p> | The certificate Secret to use for the server-side of encryption. The secret name provides the Secret Name. The caCrt, tlsCrt, and tlsKey sub-Values indicate the data items within the Secret, respectively. | No |
| clients.internal.certificate.duration<p>server.certificate.renewBefore</p> | 8760h<p>360h</p> | Certificate default duration and renewal (See [cert-manager documentation](https://cert-manager.io/docs/usage/certificate/#creating-certificate-resources) | No
| `clients.internal.certificate.commonName` | <fullname>.<namespace>.svc.<clusterDomain> | Common Name to be used on the certificate (See [cert-manager documentation](https://cert-manager.io/docs/usage/certificate/#creating-certificate-resources) | No |
| clients.internal.certificate.caIssuer.name<p>server.certificate.caIssuer.kind</p><p>server.certificate.caIssuer.group</p> | ncms-ca-issuer<p>ClusterIssuer</p><p>cert-manager.io</p> | The CA Issuer details (See [cert-manager documentation](https://cert-manager.io/docs/usage/certificate/#creating-certificate-resources) | No |
| `clients.internal.certificate.dnsNames` | [<fullname>.<namespace>.svc.<clusterDomain>] | List of DNS Names to include in the Certificate (See [cert-manager documentation](https://cert-manager.io/docs/usage/certificate/#creating-certificate-resources) | No |
| `clients.internal.certificate.ipAddresses` | [*(empty)*] | List of IP Addresses to include in the Certificate (See [cert-manager documentation](https://cert-manager.io/docs/usage/certificate/#creating-certificate-resources) | No |
| `clients.internal.certificate.uris` | [*(empty)*] | List of URIs to include in the Certificate (See [cert-manager documentation](https://cert-manager.io/docs/usage/certificate/#creating-certificate-resources) | No |
| `clients.internal.certificate.subject` | [*(empty)*] | Subject to use in the Certificate (See [cert-manager documentation](https://cert-manager.io/docs/usage/certificate/#creating-certificate-resources) | No |
| clients.internal.certificate.privateKey.algorithm<p>clients.internal.certificate.privateKey.encoding</p><p>clients.internal.certificate.privateKey.size</p><p>clients.internal.certificate.privateKey.rotationPolicy</p> | [*(empty)*]<p>[*(empty)*]</p><p>[*(empty)*]</p><p>Always</p> | PrivateKey to include in the Certificate (See [cert-manager documentation](https://cert-manager.io/docs/usage/certificate/#creating-certificate-resources) | No |

## Helm Tests Parameters

| **Parameter** | **Default** | **Description** | **Update Allowed** |
|:---------------------|:------------|:----------------|:----------------------|
| tests.resources.requests.memory<p>tests.resources.requests.cpu</p><p>tests.resources.requests.ephemeral-storage</p> | 64Mi<p>100m</p><p>64Mi</p> | The Kubernetes Memory, CPU, and ephemeral resource requests for the Helm Test pods (See [K8s documentation]( https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#how-pods-with-resource-requests-are-scheduled)) | Yes |
| tests.resources.limits.memory<p>tests.resources.limits.cpu</p><p>tests.resources.limits.ephemeral-storage</p> | 64Mi<p>100m</p><p>64Mi</p> | The Kubernetes Memory, CPU, and ephemeral resource limits for the Helm Test pods (See [K8s documentation]( https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#how-pods-with-resource-requests-are-scheduled)) | Yes |


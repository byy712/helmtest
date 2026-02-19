## Indexmgr
Indexmgr helps you curate, or manage, your Indexsearch indices and snapshots by:
1. Obtaining the full list of indices (or snapshots) from the cluster, as the actionable list
2. Iterate through a list of user-defined filters to progressively remove indices (or snapshots) from this actionable list as needed.
3. Perform various actions on the items which remain in the actionable list.

### Pre Requisites:
1. Kubernetes 1.12+
2. Helm 3.0-beta3+

### Installing the Chart

To install the chart with the release name `my-release` in `logging` namespace
```
helm install my-release <chart-path> --namespace logging
```
Note: If the helm v3 client binary is named differently in the kubernetes cluster, replace "helm" with the actual name in all helm commands below. For ex. If it is named as helm3, the command would be:
```
helm3 install my-release <chart-path> --namespace logging
```

The command deploys Indexmgr on the Kubernetes cluster in the default configuration. The Parameters section lists the parameters that can be configured during installation.
> **Tip**: List all releases using `helm list -A`

### Uninstalling the Chart:
To uninstall/delete the `my-release` deployment:
```
helm delete my-release --namespace logging
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Pod Security Standards
Helm chart can be installed in namespace with `restricted` Pod Security Standards profile.

### Special cases
#### Installation with Istio-CNI disabled
In this case, Helm chart must be installed in namespace with `privileged` Pod Security Standards profile as Istio sidecar container requires the following privileges which is out of restricted`profile.

`values.yaml` parameters required to enable this case
```yaml
istio:
  enabled: true
  cni:
    enabled: false
rbac:
  enabled: true
  psp:
    create: false
```

With such a configuration istio sidecar containers will be injected into all pods in this helm chart. Istio sidecar container requires the following privileges, which extending `restricted` profile:
```yaml
spec:
  containers:
    - securityContext:
        capabilities:
          add: [ "NET_ADMIN", "NET_RAW" ]
```

##### Mapping to gatekeeper constraints 
Open source Gatekeeper `K8sPSPCapabilities` (see: [capabilities](https://github.com/open-policy-agent/gatekeeper-library/blob/master/library/pod-security-policy/capabilities)) constraint need to be relaxed to allow the following additional privileges:
```yaml
capabilities:
  add: [ "NET_ADMIN", "NET_RAW" ]
```

### Parameters:
The following table lists the configurable parameters of the Indexmgr chart and their default values.

| Parameter |Description               | Default                   |
| --|--------------------------| ------------------------- |
|`global.registry`|Global container image registry for all images |`csf-docker-delivered.repo.cci.nokia.net`|
|`global.flatRegistry` |Enable this flag to read image registries with a flat structure. It is disabled by default. |`false`|
|`global.enableDefaultCpuLimits` |Enable this flag to set pod CPU resources limit for all containers. It is disabled by default. |`false`|
| `global.seccompAllowedProfileNames` | Annotation that specifies which values are allowed for the pod seccomp annotations   |`docker/default` |
| `global.seccompDefaultProfileName` | Annotation that specifies the default seccomp profile to apply to containers     | `docker/default` |
|`global.podNamePrefix` | Prefix to be added for pods and jobs names      | `null` |
|`global.disablePodNamePrefixRestrictions` |  Enable if podNamePrefix need to be added to the pod name without any restrictions. It is disabled by default.  | `false`  |
|`global.certManager.enabled` | Enable cert-Manager feature using this flag. It is enabled by default.|`true`|
|`global.containerNamePrefix` | Prefix to be added for pod containers and job container names  | `null` |
|`global.priorityClassName` | priorityClassName for indexmgr pods, set at global level | `null` |
|`global.imagePullSecrets` | imagePullSecrets configured at global level. | `null` |
|`global.annotations` | Annotations configured at global level. These will be added at both pod level and the cronjob level for indexmgr.  | `null` |
|`global.labels` | Labels configured at global level. These will be added at both pod level and the cronjob level for indexmgr. |`null` |
|`global.istio.cni.enabled`| Whether istio cni is enabled in the environment: true/false |`true`|
|`global.imageFlavor`| Set imageFlavor at global level. | `null` |
|`global.imageFlavorPolicy`| Set imageFlavorPolicy at global level. Accepted values: Strict or BestMatch(Default) |`null`|
|`global.timeZoneEnv` | To specify global timezone value | `UTC` |
|`global.unifiedLogging.extension` | list of extended fields that component can use to enrich the log event | `null` |
|`global.unifiedLogging.syslog.enabled` | Enable sending logs to syslog   | `null(false)` |
|`global.unifiedLogging.syslog.facility`| Syslog facility   | `null` |
|`global.unifiedLogging.syslog.host` | Syslog server host name to connect to  | `null` |
|`global.unifiedLogging.syslog.port` | Syslog server port to connect to  | `null` |
|`global.unifiedLogging.syslog.protocol` | Protocol to connect to syslog server. Ex. TCP | `null` |
|`global.unifiedLogging.syslog.caCrt.secretName` | Name of secret containing syslog CA certificate | `null` |
|`global.unifiedLogging.syslog.caCrt.key` | Key in secret containing syslog CA certificate | `null` |
|`global.unifiedLogging.syslog.tls.secretRef.name` | Name of secret containing syslog CA certificate.  It takes higher precedence over syslog.caCrt.secretName. | `null` |
|`global.unifiedLogging.syslog.tls.secretRef.keyNames.caCrt` | Key in secret containing syslog CA certificate.  It takes higher precedence over syslog.caCrt.key. | `ca.crt` |
|`rbac.enabled` | Enable/disable rbac. When rbac.enabled is set to true, chart would create its own rbac related resources; If false, an external serviceAccountName set in values will be used. | `true` |
|`rbac.psp.create`| If set to true, then chart creates its own PSPs only if required; If set to false, then chart do not create PSPs.     | `false` | 
|`rbac.psp.annotations` | Annotation to be set when 'containerSecurityContext.seccompProfile.type' is configured or if required only       | `seccomp.security.alpha.kubernetes.io/allowedProfileNames: '*'` |
|`rbac.scc.create` | If set to true, then chart creates its own SCCs only if required; If set to false, then chart do not create SCCs.   | `false` |
|`rbac.scc.annotations` | To set annotations for SCCs only if required; | `null` |
|`serviceAccountName` | Pre-created SeriveAccountName when rbac.enabled is set to false | `null` |
|`customResourceNames.resourceNameLimit` | Character limit for resource names to be truncated    | `63` |
|`customResourceNames.indexmgrCronJobPod.indexmgrContainerName` | Name for indexmgr cronjob pod's container       | `null` |
|`customResourceNames.indexmgrCronJobPod.indexmgrInitContainerName` | Name for indexmgr cronjob pod's init container    | `null` |
|`customResourceNames.indexmgrCronJobPod.unifiedLoggingContainerName:` | Name for Unified Logging pod's container      | `null` |
|`customResourceNames.deleteJob.name` | Name for indexmgr delete job   | `null` |
|`customResourceNames.deleteJob.deleteJobContainerName` | Name for indexmgr delete job's container | `null` |
|`customResourceNames.helmTestPod.name` | Name for helm test pod    | `null` |
|`customResourceNames.helmTestPod.helmTestContainerName` | Name for helm test pod's container      | `null` |
|`disablePodNamePrefixRestrictions` |   disablePodNamePrefixRestrictions configured at root level. It takes higher precedence over disablePodNamePrefixRestrictions configured at global level  | `false`  |
|`nameOverride` | Use this to override name for indexmgr cronjob kubernetes object. When it is set, the name would be ReleaseName-nameOverride     | `null` |
|`fullnameOverride` | Use this to configure custom-name for indexmgr cronjob kubernetes object.  If both nameOverride and fullnameOverride are specified, fullnameOverride would take the precedence. | `null` |
|`enableDefaultCpuLimits` |Enable this flag to set pod CPU resources limit for all containers. It has no value set by default. |`null`|
|`affinity`| Set affinity to have pod scheduling preferences     |`{}`|
|`crossClusterReplication.stopReplicationFollowerIndices`| Stop replication for the follower Indices when CCR enabled |`false`|
|`nodeSelector`| node labels for pod assignment            |`{}`|
|`tolerations`| List of node taints to tolerate            |`[]`|
| `partOf` | Use this to configure common lables for k8s objects. Set to configure label app.kubernetes.io/part-of:     | `null` |
|`timezone.timeZoneEnv` | To specify timezone value and this will have higer precedence over global.timeZoneEnv  | `UTC` |
|`imagePullSecrets`| Indexmgr imagePullSecrets configured at root level. It takes higher precedence over imagePullSecrets configured at global level |`null`|
|`imageFlavor`| Indexmgr imageFlavor configured at root value. It takes higher precedence over imageFlavor configured at global level | `null` |
|`imageFlavorPolicy`| Indexmgr imageFlavor policy configured at root value. It takes higher precedence over imageFlavor policy configured at global level. Accepted values: Strict or BestMatch(Default) |`null`|
|`indexmgr.image.repo` |Indexmgr image name. |`bssc-indexmgr`|
| `indexmgr.image.tag`  | Indexmgr image tag. Accepted values are 5.8.4-2311.0.1 or 5.8.4-rocky8-jre11-2311.0.1 or 5.8.4-rocky8-jre17-2311.0.1  | `5.8.4-2311.0.1` |
| `indexmgr.image.flavor` | Image flavor name for indexmgr main and init container. | `null` |
| `indexmgr.image.flavorPolicy` | Image flavor policy for indexmgr container. Accepted values: Strict or BestMatch(Default) |`null`|
| `indexmgr.image.initRepo`| Indexmgr init container image repo name. | `bssc-init` |
| `indexmgr.image.initTag` | Indexmgr init container image tag. Accepted values are 1.0.0-2311.0.1 or 1.0.0-rocky8-jre11-2311.0.1 or 1.0.0-rocky8-jre17-2311.0.1 | `1.0.0-2311.0.1` |
| `indexmgr.imageFlavor` | Image flavor name for indexmgr workload. | `null` |
| `indexmgr.imageFlavorPolicy` | Image flavor policy for indexmgr workload. Accepted values: Strict or BestMatch(Default) |`null`|
| `indexmgr.ImagePullPolicy` | Indexmgr  image pull policy             | `IfNotPresent` |
| `indexmgr.init_resources` | CPU/Memory/ephemeral-storage resource requests/limits for Indexmgr initContainer    | `limits:       cpu: ""(100m if enableDefaultCpuLimits is true)       memory: "100Mi" ephemeral-storage: "30Mi"     requests:       cpu: "50m"       memory: "50Mi" ephemeral-storage: "30Mi"` |
| `indexmgr.resources` | CPU/Memory/ephemeral-storage resource requests/limits for Indexmgr pod   | `limits:       cpu: ""(120m if enableDefaultCpuLimits is true)       memory: "120Mi" ephemeral-storage: "100Mi"     requests:       cpu: "100m"       memory: "100Mi" ephemeral-storage: "100Mi"` |
| `indexmgr.unifiedLogging.enabled` | enable/disable unified logging for curator     | `true` |
| `indexmgr.unifiedLogging.imageRepo` | Unified logging fluentd sidecar image repo name. | `bssc-fluentd` |
| `indexmgr.unifiedLogging.imageTag`  | Unified Logging fluentd sidecar image tag. Accepted values are 1.16.2-2311.0.1 or 1.16.2-rocky8-jre11-2311.0.1 or 1.16.2-rocky8-jre17-2311.0.1  | `1.16.2-2311.0.1` |
| `indexmgr.unifiedLogging.ImagePullPolicy`       | image pull policy for fluentd sidecar  | `IfNotPresent` |
| `indexmgr.unifiedLogging.imageFlavor` | Image flavor name for fluentd sidecar container. | `null` |
| `indexmgr.unifiedLogging.imageFlavorPolicy` | Image flavor policy for fluentd sidecar container. Accepted values: Strict or BestMatch(Default) |`null`|
| `indexmgr.unifiedLogging.resources` | CPU/Memory/ephemeral-storage resource requests/limits for fluentd sidecar         | `limits:       cpu: ""(50m if enableDefaultCpuLimits is true)       memory: "100Mi" ephemeral-storage: "100Mi"     requests:       cpu: "20m"       memory: "80Mi" ephemeral-storage: "100Mi"` |
| `indexmgr.unifiedLogging.fluentdTerminationDelay` | Delay (in seconds) to terminate fluentd sidecar process after curator process gets completed     | `150` |
|`indexmgr.unifiedLogging.syslog.enabled` | Enable sending logs to syslog. Takes precedence over global.unifiedLogging.syslog.enabled | `null(false)` |
|`indexmgr.unifiedLogging.syslog.facility` | Syslog facility   | `null` |
|`indexmgr.unifiedLogging.syslog.host` | Syslog server host name to connect to  | `null` |
|`indexmgr.unifiedLogging.syslog.port` | Syslog server port to connect to  | `null` |
|`indexmgr.unifiedLogging.syslog.protocol` | Protocol to connect to syslog server. Ex. TCP | `null` |
|`indexmgr.unifiedLogging.syslog.caCrt.secretName` | Name of secret containing syslog CA certificate | `null` |
|`indexmgr.unifiedLogging.syslog.caCrt.key` | Key in secret containing syslog CA certificate | `null` |
|`indexmgr.unifiedLogging.syslog.tls.secretRef.name` | Name of secret containing syslog CA certificate.  It takes higher precedence over syslog.caCrt.secretName. | `null` |
|`indexmgr.unifiedLogging.syslog.tls.secretRef.keyNames.caCrt` | Key in secret containing syslog CA certificate.  It takes higher precedence over syslog.caCrt.key. | `ca.crt` |
|`indexmgr.unifiedLogging.syslog.appLogBufferSize` | Size of buffer for application logs sent to syslog | `50MB` |
|`indexmgr.unifiedLogging.syslog.sidecarLogBufferSize` | Size of buffer for fluentd sidecar logs sent to syslog | `20MB` |
|`indexmgr.unifiedLogging.extension` | list of extended fields that component can use to enrich the log event | `null` |
|`indexmgr.priorityClassName` | Indexmgr pod priority class name. When this is set, it takes precedence over priorityClassName set at global level                                                      |`null`|
|`indexmgr.imagePullSecrets` | Indexmgr imagePullSecrets configured at workload level. It takes higher precedence over imagePullSecrets configured at root or global levels |`null`|
|`indexmgr.securityContext.enabled`| To enable/disable security context     |`true`|
|`indexmgr.securityContext.runAsUser`| UID with which the container will be run     |`1000`|
| `indexmgr.securityContext.fsGroup` | Group ID that is assigned for the volumemounts mounted to the pod      | `1000` |
| `indexmgr.securityContext.supplementalGroups` | The supplementalGroups ID applies to shared storage volumes   | `commented out by default` |
| `indexmgr.securityContext.seLinuxOptions` | SELinux label to a container  | `commented out by default` |
|`indexmgr.containerSecurityContext.seccompProfile.type`| Provision to configure  seccompProfile for indexmanager containers   |`RuntimeDefault`|
| `indexmgr.custom.cronjob.annotations` | Indexmgr cronjob specific annotations  | `null` |
| `indexmgr.custom.cronjob.labels` | Indexmgr cronjob specific labels  | `null` |
| `indexmgr.custom.pod.annotations` | Indexmgr pod specific annotations    | `null` |
| `indexmgr.custom.pod.labels` | Indexmgr pod specific labels   | `null` |
| `indexmgr.custom.hookJobs.job.annotations` | Indexmgr helm hook jobs specific annotations   | `null` |
| `indexmgr.custom.hookJobs.job.labels` | Indexmgr helm hook jobs specific labels    | `null` |
| `indexmgr.custom.hookJobs.pod.annotations` | Indexmgr helm hook & test pods specific annotations   | `null` |
| `indexmgr.custom.hookJobs.pod.labels` | Indexmgr helm hook & test pods specific labels       | `null` |
| `indexmgr.schedule` | Indexmgr cronjob schedule  | `0 1 * * *` |
| `indexmgr.jobSpec.successfulJobsHistoryLimit` | Number of successful CronJob executions that are saved    | `Even though the value is commented, K8S default value is 3` |
| `indexmgr.jobSpec.failedJobsHistoryLimit` | Number of failed CronJob executions that are saved     | `Even though the value is commented, K8S default value is 1` |
| `indexmgr.jobSpec.concurrencyPolicy` | Specifies how to treat concurrent executions of a Job created by the CronJob controller   | `Even though the value is commented, K8S default value is Allow` |
| `indexmgr.jobTemplateSpec.activeDeadlineSeconds` | Duration of the job, no matter how many Pods are created. Once a Job reaches activeDeadlineSeconds, all of its running Pods are terminated                              | `default value is commented out` |
| `indexmgr.jobTemplateSpec.backoffLimit` | Specifies the number of retries before considering a Job as failed    | `default value is commented out` |
| `indexmgr.configMaps.preCreatedConfigmap` | Name of pre-created configmap. The configmap must contain the files actions.yml, indexmgr.yml. When the value is set, the chart doesn't create indexmgr configmap.      | `null` |
| `indexmgr.configMaps.action_file_yml` | It is a YAML configuration file. The root key must be actions, after which there can be any number of actions, nested underneath numbers |  `delete indices older than 7 days using age filter` |
| `indexmgr.configMaps.config_yml` | The configuration file contains client connection and settings for logging    | `connects to indexsearch service on 9200 port via http` |
|`indexmgr.certificate.enabled` | If cert manager is enabled, certificate will be created as per it's configured in this section | `true` |
|`indexmgr.certificate.issuerRef.name`| Name of certificate issuer | `null` |
|`indexmgr.certificate.issuerRef.kind` | Kind of Issuer | `null` | 
|`indexmgr.certificate.issuerRef.group` | Certificate Issuer Group Name | `null` | 
|`indexmgr.certificate.duration`| How long certificate will be valid |`null` |
|`indexmgr.certificate.renewBefore` | When to renew the certificate before it gets expired |`null` |
|`indexmgr.certificate.secretName` | Name of the secret in which this cert would be added| `null` |
|`indexmgr.certificate.subject`| Certificate subject | `null`|
|`indexmgr.certificate.commonName` | CN of certificate | `null` |
|`indexmgr.certificate.usages ` | Certificate usage | `null` |
|`indexmgr.certificate.dnsNames ` | DNSNames is a list of DNS subjectAltNames to be set on the Certificate.| `null` |
|`indexmgr.certificate.uris` | URIs is a list of URI subjectAltNames to be set on the Certificate.| `null`|
|`indexmgr.certificate.ipAddresses`| IPAddresses is a list of IP address subjectAltNames to be set on the Certificate.|`null`|
|`indexmgr.certificate.privateKey.algorithm`| Algorithm is the private key algorithm of the corresponding private key for this certificate | `null`|
|`indexmgr.certificate.privateKey.encoding`| The private key cryptography standards (PKCS) encoding for this certificate’s private key | `null`|
|`indexmgr.certificate.privateKey.size`| Size is the key bit size of the corresponding private key for this certificate. | `null` |
|`indexmgr.certificate.privateKey.rotationPolicy`| Rotation of a key pair, when certificate is refreshed is recommended from a security point of view | `Always` |
|`kubectl.image.repo`| Kubectl image name    |`tools/kubectl`|
|`kubectl.image.tag` | Kubectl image tag. Accepted values: 1.26.11-20231124 or 1.26.11-rocky8-nano-20231124 |`1.26.11-20231124`|
|`kubectl.image.flavor` | To provide imageFlavor for jobs and helm test pod | `null` |
|`kubectl.image.flavorPolicy` | To provide imageFlavor policy for jobs and helm test pod. Accepted values: Strict or BestMatch(Default) |`null`|
|`jobs.affinity`| To provide affinity for jobs and helm test pods             |`null`|
|`jobs.nodeSelector`| To provide nodeSelector for jobs and helm test pods     |`null`|
|`jobs.tolerations`| To provide tolerations for jobs and helm test pods       |`null`|
|`jobs.hookJobs.resources.requests` | CPU/Memory/ephemeral-storage resource requests for hook jobs and helm test pods  | `requests:       cpu: "100m"       memory: "100Mi"       ephemeral-storage: "50Mi"` |
|`jobs.hookJobs.resources.limits` | CPU/Memory/ephemeral-storage resource limits for hook jobs and helm test pods    | `limits:       cpu: ""(120mif enableDefaultCpuLimits is true)       memory: "120Mi"        ephemeral-storage: "50Mi"` |
| `istio.enabled` | Enable istio using this flag | `false` |
|`istio.envoy.healthCheckPort`| Health check port of istio envoy proxy. Set value to 15020 for istio versions <1.6 and 15021 for version >=1.6      |`15021`|
| `istio.envoy.waitTimeout` | Time in seconds to wait for istio envoy proxy to load required configurations before starting indexmgr process   | `60` |
|`istio.envoy.stopPort`| Port used to terminate istio envoy sidecar using /quitquitquit endpoint   |`15000`|
|`istio.cni.enabled`| Whether istio cni is enabled in the environment: true/false      |`null`|
|`certManager.enabled` |Enable cert-Manager feature using this flag when security is enabled. It is disabled by default.It takes higher precedence over certManager.enabled at global level.|`null`|
| `security.enable` | Enable security using this flag. Enable security means to enable SensitiveInfoInSecret    | `false` |
| `security.sensitiveInfoInSecret.enabled` | Enable this to read sensitive data from secret. It reads the same value as security.enable by default.  |`{{ .Values.security.enable }}` |
| `security.sensitiveInfoInSecret.credentialName` | Name of the pre-created secret which contains sensitive information.  | `null` |
| `security.sensitiveInfoInSecret.indexmgrIsUsername` | Key name in precreated secret that stores indexsearch username in its value.  | `null` |
| `security.sensitiveInfoInSecret.indexmgrIsPassword` | Key name in precreated secret that stores indexsearch password in its value. | `null` |
| `security.sensitiveInfoInSecret.ca_certificate` | Key name in precreated secret that stores indexsearch root ca certificate in its value.   | `null` |
|`security.certManager.enabled` |Enable cert-Manager feature using this flag when security is enabled. By default, it reads same value as configured in certManager.enabled (root level). It takes higher precedence over certManager.enabled at root and global levels|`{{ Values.certManager.enabled }}`|
|`security.certManager.apiVersion` | Api version of the cert-manager.io  | `cert-manager.io/v1alpha3`|
|`security.certManager.duration` | How long certificate will be valid |`8760h`|
|`security.certManager.renewBefore` | When to renew the certificate before it gets expired  |`360h`|
|`security.certManager.issuerRef.name` | Issuer Name  | `ncms-ca-issuer` |
|`security.certManager.issuerRef.kind` | CRD Name  | `ClusterIssuer` |
|`security.certManager.issuerRef.group` | Certificate Issuer Group | `cert-manager.io` |
|`emptyDirSizeLimit.dryrunLogs`|Configure the sizeLimit of dryrun-logs emptyDir|`10Mi`|
|`emptyDirSizeLimit.indexmgrLogs`|Configure the sizeLimit of indexmgr-logs emptyDir|`100Mi`|
|`emptyDirSizeLimit.sharedVolume`|Configure the sizeLimit of shared-volume emptyDir|`10Mi`|

Specify parameters using `--set key=value[,key=value]` argument to `helm install`
```
helm install my-release --set istio.enabled=true <chart-path> --namespace logging
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,
```
helm install my-release -f values.yaml <chart-path> --version <version> --namespace logging
```

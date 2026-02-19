# Indexsearch

Indexsearch allows to store, search, and analyze huge volumes of data quickly in real-time and give back answers in milliseconds. It stores data in term of Opensearch index , index is a collection of documents. it comes with extensive REST APIs for storing and searching the data.

## Pre Requisites:

1. Kubernetes 1.12+
2. Helm 3.0-beta3+
3. PV provisioner support in the underlying infrastructure

## Installing the Chart

To install the chart with the release name `my-release` in `logging` namespace
```
helm install my-release <chart-path> --namespace logging
```

Note: If the helm v3 client binary is named differently in the kubernetes cluster, replace "helm" with the actual name in all helm commands below. For ex. If it is named as helm3, the command would be:
```
helm3 install my-release <chart-path> --namespace logging
```

The command deploys indexsearch on the Kubernetes cluster in the default configuration. The Parameters section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list -A`

## Uninstalling the Chart:
To uninstall/delete the `my-release` deployment:
```
helm delete my-release --namespace logging

```
The command removes all the kubernetes components associated with the chart and deletes the release.

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

#### Mapping to gatekeeper constraints
Open source Gatekeeper `K8sPSPCapabilities` (see: [capabilities](https://github.com/open-policy-agent/gatekeeper-library/blob/master/library/pod-security-policy/capabilities)) constraint needs to be relaxed to allow the following additional privileges:
```yaml
capabilities:
  add: [ "NET_ADMIN", "NET_RAW" ]
```

## Parameters:
The following table lists the configurable parameters of the Indexsearch chart and their default values.

| Parameter              | Description                                   | Default                            |
| ---------------------- | ----------------------------------------------| ---------------------------------------------------------- |
|`global.registry`|Global container image registry for all images |`csf-docker-delivered.repo.cci.nokia.net`|
|`global.flatRegistry` |Enable this flag to read image registries with a flat structure. It is disabled by default. |`false`|
|`global.enableDefaultCpuLimits` |Enable this flag to set pod CPU resources limit for all containers. It is disabled by default. |`false`|
|`global.preheal`|To trigger preheal job hooks|`0`|
|`global.postheal`|To trigger postheal job hooks|`0`|
|`global.seccompAllowedProfileNames`|Annotation that specifies which values are allowed for the pod seccomp annotations|`docker/default`|
|`global.seccompDefaultProfileName`|Annotation that specifies the default seccomp profile to apply to containers|`docker/default`|
|`global.podNamePrefix` | Prefix to be added for pods and jobs names       | `null` |
|`global.disablePodNamePrefixRestrictions` |  Enable if podNamePrefix need to be added to the pod name without any restrictions  | `false`  |
|`global.certManager.enabled` |Enable cert-Manager feature using this flag. It is enabled by default.|`true`|
|`global.containerNamePrefix` | Prefix to be added for pod containers and job container names | `null` |
|`global.priorityClassName` | priorityClassName for indexsearch pods, set at global level | `null` |
|`global.imagePullSecrets` | imagePullSecrets configured at global level.   | `null` |
|`global.annotations` | Annotations configured at global level. These will be added at both pod level and the workload(statefulset/deployment) level for indexsearch. | `null` |
|`global.labels` | Labels configured at global level. These will be added at both pod level and the workload(statefulset/deployment) level for indexsearch. | `null` |
|`global.istio.version`|Istio version defined at global level. Accepts version in numeric X.Y format. |`1.7`|
|`global.istio.cni.enabled`|Whether istio cni is enabled in the environment: true/false |`true`|
|`global.timeZoneEnv` | To specify global timezone value              | `UTC` |
|`global.ipFamilyPolicy` | ipFamilyPolicy for dual-stack support configured at global scope | `null` |
|`global.ipFamilies` | ipFamilies for dual-stack support configured at global scope | `null` |
|`global.hpa.enabled` | Enable/Disable HPA | `null(false)` |
|`global.unifiedLogging.extension` | list of extended fields that component can use to enrich the log event | `null` |
|`global.unifiedLogging.syslog.enabled` | Enable sending logs to syslog   | `null(false)` |
|`global.unifiedLogging.syslog.facility` | Syslog facility   | `null` |
|`global.unifiedLogging.syslog.host` | Syslog server host name to connect to  | `null` |
|`global.unifiedLogging.syslog.port` | Syslog server port to connect to  | `null` |
|`global.unifiedLogging.syslog.protocol` | Protocol to connect to syslog server. Ex. TCP | `null` |
|`global.unifiedLogging.syslog.caCrt.secretName` | Name of secret containing syslog CA certificate | `null` |
|`global.unifiedLogging.syslog.caCrt.key` | Key in secret containing syslog CA certificate | `null` |
|`global.unifiedLogging.syslog.tls.secretRef.name` | Name of secret containing syslog CA certificate.  It takes higher precedence over syslog.caCrt.secretName. | `null` |
|`global.unifiedLogging.syslog.tls.secretRef.keyNames.caCrt` | Key in secret containing syslog CA certificate.  It takes higher precedence over syslog.caCrt.key. | `ca.crt` |
|`global.unifiedLogging.syslog.tls.secretRef.keyNames.tlsCrt` | Key in secret containing TLS certificate of client to syslog. | `null` |
|`global.unifiedLogging.syslog.tls.secretRef.keyNames.tlsKey` | Key in secret containing TLS key of client to syslog. | `null` |
|`global.imageFlavor`| set imageFlavor at global level |`null`|
|`global.imageFlavorPolicy`| set imageFlavorPolicy at global level. Accepted Values: Strict or BestMatch |`null`|
|`rbac.enabled`|Enable/disable rbac. When rbac.enabled is set to true, charts would create its own rbac related resources; If false, an external serviceAccountName set in values will be used. |`true`|
|`serviceAccountName`|Pre-created ServiceAccount specifically for indexsearch chart.|`null`|
|`rbac.psp.create` | If set to true, then chart creates its own PSPs only if required; If set to false, then chart do not create PSPs. | `false` |
|`rbac.psp.annotations` | Annotation to be set when 'containerSecurityContext.seccompProfile.type' is configured or if required only | `seccomp.security.alpha.kubernetes.io/allowedProfileNames: '*'` |
|`rbac.scc.create` | If set to true, then chart creates its own SCCs only if required; If set to false, then chart do not create SCCs. | `false` |
|`rbac.scc.annotations` | To set annotations for SCCs only if required;   | `null` |
|`customResourceNames.resourceNameLimit` | Character limit for resource names to be truncated      | `63` |
|`customResourceNames.managerPod.managerContainerName` | Name for indexsearch manager pod's container            | `null` |
|`customResourceNames.dataPod.dataContainerName` | Name for indexsearch data pod's container               | `null` |
|`customResourceNames.clientPod.clientContainerName` | Name for indexsearch client pod's container             | `null` |
|`customResourceNames.initContainerName` | Name for indexsearch init container | `null`|
|`customResourceNames.unifiedLoggingContainerName` | Name for indexsearch pod's unified logging container     | `null` |
|`customResourceNames.postScaleInJob.name` | Name for post-scalein job                    | `null` |
|`customResourceNames.postScaleInJob.postScaleInContainerName` | Name for post-scalein job's container                   | `null` |
|`customResourceNames.preUpgradeSecJob.name` | Name for pre-upgradeSecurity job                    | `null` |
|`customResourceNames.preUpgradeSecJob.preUpgradeSecContainerName` | Name for pre-upgradeSecurity job's container            | `null` |
|`customResourceNames.upgradeJob.name` | Name for upgrade job                    | `null` |
|`customResourceNames.upgradeJob.upgradeContainerName` | Name for upgrade job's container                   | `null` |
|`customResourceNames.preRollbackJob.name` | Name for pre-rollback job                    | `null` |
|`customResourceNames.preRollbackJob.preRollbackContainerName` | Name for pre-rollback job's container                   | `null` |
|`customResourceNames.preHealJob.name` | Name for pre-heal job                    | `null` |
|`customResourceNames.preHealJob.preHealContainerName` | Name for  pre-heal job's container                   | `null` |
|`customResourceNames.postDeleteCleanupJob.name` | Name for post-deleteCleanup job                    | `null` |
|`customResourceNames.postDeleteCleanupJob.postDeleteCleanupContainerName` | Name for post-deleteCleanup job's container             | `null` |
|`customResourceNames.postDeletePvcJob.name` | Name for post-deletePvc job                    | `null` |
|`customResourceNames.postDeletePvcJob.postDeletePvcContainerName` | Name for post-deletePvc job's container                 | `null` |
|`customResourceNames.helmTestPod.name` | Name for helm test pod                    | `null` |
|`customResourceNames.helmTestPod.helmTestContainerName` | Name for helm test pod's container                   | `null` |
|`customResourceNames.helmTestPostApiPod.name` | Name for helm test post-setup-api job pod                    | `null` |
|`customResourceNames.helmTestPostApiPod.helmTestPostApiContainerName` | Name for helm test post-setup-api job pod's container                   | `null` |
|`customResourceNames.secAdminJob.name` | Name of job which runs security admin script during install/rollback operations | `null` |
|`customResourceNames.secAdminJob.secAdminContainerName` | Name of job's container which runs security admin script during install/rollback operations | `null` |
|`disablePodNamePrefixRestrictions` |   disablePodNamePrefixRestrictions configured at root level. It takes higher precedence over disablePodNamePrefixRestrictions configured at global level  | `true`  |
|`nameOverride`       | Use this to override name for indexsearch deployment/sts kubernetes object. When it is set, the name would be ReleaseName-nameOverride | `null` |
|`fullnameOverride`       | Use this to configure custom-name for indexsearch deployment/sts kubernetes object.  If both nameOverride and fullnameOverride are specified, fullnameOverride would take the precedence. | `null` |
|`enableDefaultCpuLimits` |Enable this flag to set pod CPU resources limit for all containers. It has no value set by default. |`null`|
| `partOf` | Use this to configure common lables for k8s objects. Set to configure label app.kubernetes.io/part-of: | `null` |
|`timezone.timeZoneEnv` | To specify timezone value and this will have higer precedence over global.timeZoneEnv | `UTC` |
|`securityContext.enabled`|To configure parameters under securityContext for pods and containers. If set to false, securityContext will be set as {}|`true`|
|`securityContext.runAsUser`|UID with which the containers will be run. Set to auto if using random userids in openshift environment. |`1000`|
|`securityContext.fsGroup`|Group ID assigned for the volumemounts mounted to the pod|`1000`|
|`securityContext.supplementalGroups`|SupplementalGroups ID applies to shared storage volumes|`default value is commented out`|
|`securityContext.seLinuxOptions`|provision to configure selinuxoptions for indexsearch container|`default value is commented out`|
|`containerSecurityContext.seccompProfile.type`|Provision to configure  seccompProfile for Indexsearch containers |`RuntimeDefault`|
|`upgrade.autoMigratePV`| Due to asset name changes, both manager and data PV has to be migrated to retain old data. Use this flag if upgrading from BELK 22.06. For subsequent upgrades(like update configuration) the value has to be false | `false`|
|`autoRollback`| If this is set to true, then the chart itself will handle all the necessary pre/post rollback steps. #Note: #1. This needs the chart to have higher rbac permissions to delete PVCs. #2. The ReclaimPolicy of the storageclass must be 'Delete' for automatic rollback to work. If this is set to false, while downgrading to lower opensearch versions, user must manually scale down all the Indexsearch Manager and Data pods to zero and delete PVCs before helm rollback and execute rollback script file after rollback. |`true`|
|`imageFlavor`| set imageFlavor at root level |`null`|
|`imageFlavorPolicy`| set imageFlavorPolicy at root level. Allowed Values: Strict or BestMatch |`null`|
|`custom.manager.statefulSet.annotations`|Indexsearch manager statefulset specific annotations|`null`|
|`custom.manager.statefulSet.labels`|Indexsearch manager statefulset specific labels|`null`|
|`custom.manager.pod.annotations`|Indexsearch manager pod specific annotations|`null`|
|`custom.manager.pod.labels`|Indexsearch manager pod specific labels|`null`|
|`custom.data.statefulSet.annotations`|Indexsearch data statefulset specific annotations|`null`|
|`custom.data.statefulSet.labels`|Indexsearch data statefulset specific labels|`null`|
|`custom.data.pod.annotations`|Indexsearch data pod specific annotations|`null`|
|`custom.data.pod.labels`|Indexsearch data pod specific labels|`null`|
|`custom.client.deployment.annotations`|Indexsearch client deployment specific annotations|`null`|
|`custom.client.deployment.labels`|Indexsearch client deployment specific labels|`null`|
|`custom.client.pod.annotations`|Indexsearch client pod specific annotations|`null`|
|`custom.client.pod.labels`|Indexsearch client pod specific labels|`null`|
|`custom.hookJobs.job.annotations`|Indexsearch helm hook jobs specific annotations|`null`|
|`custom.hookJobs.job.labels`|Indexsearch helm hook jobs specific labels|`null`|
|`custom.hookJobs.pod.annotations`|Indexsearch helm hook & test pods specific annotations|`null`|
|`custom.hookJobs.pod.labels`|Indexsearch helm hook & test pods specific labels|`null`
|`istio.enabled`|Enable istio for Indexsearch using the flag|`false`|
|`istio.version`|Istio version specified at chart level. If defined here,it takes precedence over global level. Accepts istio version in numeric X.Y format. Ex. 1.7|`null`|
|`istio.cni.enabled`|Whether istio cni is enabled in the environment: true/false |`null`|
|`istio.envoy.healthCheckPort`|Health check port of istio envoy proxy. Set value to 15020 for istio versions <1.6 and 15021 for version >=1.6 |`15021`|
|`istio.envoy.stopPort`|Port used to terminate istio envoy sidecar using /quitquitquit endpoint |`15000`|
|`istio.createDrForClient`| This optional flag should only be used when application was installed in istio-injection=enabled namespace, but was configured with istio.enabled=false, thus istio sidecar could not be injected into this application | `false`|
|`istio.customDrSpecForClient` | This configurations will be used for configuring spec of DestinationRule  when createDrForClient flag is enabled | `mode: DISABLE`|
|`service.type`|Kubernetes service type|`ClusterIP`|
|`service.client_port`|Indexsearch service port|`9200`|
|`service.manager_port`|Indexsearch service port for internal pod communication|`9300`|
|`service.client_nodeport`|Indexsearch port when deployed with nodeport|`30932`|
|`service.manager_nodeport`|Indexsearch tcp port when deployed with nodeport|`30933`|
|`service.name`|Kubernetes service name for indexsearch|`indexsearch`|
|`service.prometheus_metrics.enabled`|Scrape metrics from indexsearch when set to true|`false`|
|`service.prometheus_metrics.pro_annotation_https_scrape`|Prometheus annotation to scrape metrics from elaticsearch https endpoints|`prometheus.io/scrape_is`|
|`ipFamilyPolicy`|ipFamilyPolicy for dual-stack support configured at chart level. Allowed values: SingleStack, PreferDualStack,RequireDualStack |`null`|
|`ipFamilies`|ipFamilies for dual-stack support configured at chart level. Allowed values: ["IPv4"], ["IPv6"], ["IPv4","IPv6"], ["IPv6","IPv4"] |`null`|
|`network_host`|Configure based on network interface added to cluster nodes i.e ipv4 interface or ipv6 interface.For ipv4 interface value can be set to "\_site\_".For ipv6 interface values can be set to "\_global:ipv6\_" or "\_eth0:ipv6\_". For dual stack environment, this can be set to "0.0.0.0"|`"_site_"`|
|`postscalein`|To trigger postscale job hooks|`0`|
|`upgrade.hookDelPolicy`|Configure delete policy of pre/post-upgrade jobs to modify the job retention|`before-hook-creation, hook-succeeded`|
|`imagePullSecrets`| Indexsearch imagePullSecrets configured at root level. It takes higher precedence over imagePullSecrets configured at global level |`null`|
|`env`| Additional environmental variables to be added to all indexsearch pods |`null`|
|`unifiedLogging.extension` | list of extended fields that component can use to enrich the log event for indexsearch pods | `null` |
|`unifiedLogging.syslog.enabled` | Enable sending logs to syslog. Takes precedence over global.unifiedLogging.syslog.enabled | `null(false)` |
|`unifiedLogging.syslog.sendLogsViaLog4j` | Set sendLogsViaLog4j to true if sending logs to syslog using log4j. If this flag is enabled, additional fluentd sidecar for unified logging will not be injected. | `true`|
|`unifiedLogging.syslog.facility` | Syslog facility   | `null` |
|`unifiedLogging.syslog.host`    | Syslog server host name to connect to  | `null` |
|`unifiedLogging.syslog.port`    | Syslog server port to connect to  | `null` |
|`unifiedLogging.syslog.protocol` | Protocol to connect to syslog server. Ex. TCP | `null` |
|`unifiedLogging.syslog.caCrt.secretName` | Name of secret containing syslog CA certificate | `null` |
|`unifiedLogging.syslog.caCrt.key` | Key in secret containing syslog CA certificate | `null` |
|`unifiedLogging.syslog.tls.secretRef.name` | Name of secret containing syslog CA certificate.  It takes higher precedence over syslog.caCrt.secretName. | `null` |
|`unifiedLogging.syslog.tls.secretRef.keyNames.caCrt` | Key in secret containing syslog CA certificate.  It takes higher precedence over syslog.caCrt.key. | `ca.crt` |
|`unifiedLogging.syslog.tls.secretRef.keyNames.tlsCrt` | Key in secret containing TLS certificate of client to syslog. | `null` |
|`unifiedLogging.syslog.tls.secretRef.keyNames.tlsKey` | Key in secret containing TLS key of client to syslog. | `null` |
|`unifiedLogging.syslog.appLogBufferSize` | Size of buffer for application logs sent to syslog | `50MB` |
|`unifiedLogging.syslog.sidecarLogBufferSize` | Size of buffer for fluentd sidecar logs sent to syslog | `20MB` |
|`unifiedLogging.imageRepo` | image repo for the fluentd sidecar used in indexsearch pod to send logs to syslog server. | `bssc-fluentd` |
|`unifiedLogging.imageTag` | image tag for fluentd sidecar. Accepted values are 1.16.2-2311.0.1, 1.16.2-rocky8-jre11-2311.0.1 or 1.16.2-rocky8-jre17-2311.0.1 | `1.16.2-2311.0.1` |
|`unifiedLogging.imageFlavor`| set imageFlavor at container level for fluentd sidecar |`null`|
|`unifiedLogging.imageFlavorPolicy`| set imageFlavorPolicy at container level for fluentd sidecar. Accepted Values: Strict or BestMatch |`null`|
|`unifiedLogging.imagePullPolicy` | image pull policy for fluentd sidecar | `IfNotPresent`|
|`unifiedLogging.resources` | CPU/Memory/ephemeral-storage resource requests/limits for fluentd sidecar |`limits: CPU/Mem/ephemeral-storage (50m if enableDefaultCpuLimits is true)/100Mi/200Mi , requests: CPU/Mem/ephemeral-storage 20m/80Mi/200Mi`|
|`indexsearch.externalClientCertificates.dashboards.certificate.enabled` | If clientcert_auth_domain is enabled and cert manager is enabled, certificate will be created as per it's configured in this section | `false` |
|`indexsearch.externalClientCertificates.dashboards.certificate.issuerRef.name`| Name of certificate issuer   | `ncms-ca-issuer` |
|`indexsearch.externalClientCertificates.dashboards.certificate.secretName` | Name of dashboards client certificate which is used for authorization of dashboards backend server with opensearch | `{{ .Release.Name }}-bssc-ifd-cert-for-dashboards` |
|`indexsearch.externalClientCertificates.dashboards.certificate.issuerRef.kind` | Kind of Issuer | `ClusterIssuer` | 
|`indexsearch.externalClientCertificates.dashboards.certificate.issuerRef.group` | Certificate Issuer Group Name | `cert-manager.io` | 
|`indexsearch.externalClientCertificates.dashboards.certificate.duration`| How long certificate will be valid|`8760h` |
|`indexsearch.externalClientCertificates.dashboards.certificate.renewBefore` |When to renew the certificate before it gets expired|`360h` |
|`indexsearch.externalClientCertificates.dashboards.certificate.subject`| Certificate subject | `null`|
|`indexsearch.externalClientCertificates.dashboards.certificate.commonName` | CN of certificate | `dashboards` |
|`indexsearch.externalClientCertificates.dashboards.certificate.usages ` | Certificate usage | `client auth` |
|`indexsearch.externalClientCertificates.dashboards.certificate.dnsNames ` | DNSNames is a list of DNS subjectAltNames to be set on the Certificate. If ssl passthrough is used on the Ingress object, then dnsNames should be set to external DNS names. | `null` |
|`indexsearch.externalClientCertificates.dashboards.certificate.uris` | URIs is a list of URI subjectAltNames to be set on the Certificate. | `null`|
|`indexsearch.externalClientCertificates.dashboards.certificate.ipAddresses`| IPAddresses is a list of IP address subjectAltNames to be set on the Certificate. | `null` |
|`indexsearch.externalClientCertificates.dashboards.certificate.privateKey.algorithm`| Algorithm is the private key algorithm of the corresponding private key for this certificate. | `null`|
|`indexsearch.externalClientCertificates.dashboards.certificate.privateKey.encoding`| The private key cryptography standards (PKCS) encoding for this certificate’s private key to be encoded in. | `null`|
|`indexsearch.externalClientCertificates.dashboards.certificate.privateKey.size`| Size is the key bit size of the corresponding private key for this certificate. | `null` |
|`indexsearch.externalClientCertificates.dashboards.certificate.privateKey.rotationPolicy`| Rotation of a key pair, when certificate is refreshed is recommended from a security point of view | `Always` |
|`indexsearch.adminCrt.certificate.enabled` | If cert manager is enabled, certificate will be created as per it's configured in this section | `true` |
|`indexsearch.adminCrt.certificate.issuerRef.name`| Name of certificate issuer   | `null`|
|`indexsearch.adminCrt.certificate.issuerRef.kind` | Kind of Issuer | `null` |
|`indexsearch.adminCrt.certificate.issuerRef.group` | Certificate Issuer Group Name | `null` |
|`indexsearch.adminCrt.certificate.duration`| How long certificate will be valid| `null` |
|`indexsearch.adminCrt.certificate.renewBefore` |When to renew the certificate before it gets expired| `null` |
|`indexsearch.adminCrt.certificate.secretName` | Name of the secret in which this cert would be added | `null` |
|`indexsearch.adminCrt.certificate.subject`| Certificate subject | `null` |   
|`indexsearch.adminCrt.certificate.commonName` | CN of certificate | `null` |
|`indexsearch.adminCrt.certificate.usages ` | Certificate usage | `null` |                             
|`indexsearch.adminCrt.certificate.dnsNames ` | DNSNames is a list of DNS subjectAltNames to be set on the Certificate. | `null` |
|`indexsearch.adminCrt.certificate.uris` | URIs is a list of URI subjectAltNames to be set on the Certificate. | `null`  |
|`indexsearch.adminCrt.certificate.ipAddresses`| IPAddresses is a list of IP address subjectAltNames to be set on the Certificate. | `null` |
|`indexsearch.adminCrt.certificate.privateKey.algorithm`| Algorithm is the private key algorithm of the corresponding private key for this certificate. | `null`  |
|`indexsearch.adminCrt.certificate.privateKey.encoding`| The private key cryptography standards (PKCS) encoding for this certificate’s private key to be encoded in. | `null`  |
|`indexsearch.adminCrt.certificate.privateKey.size`| Size is the key bit size of the corresponding private key for this certificate. | `null` |
|`indexsearch.adminCrt.certificate.privateKey.rotationPolicy`| Rotation of a key pair, when certificate is refreshed is recommended from a security point of view | `Always` |
|`indexsearch.nodeCrt.certificate.enabled` | If cert manager is enabled, node certificate will be created as per it's configured in this section | `true` |
|`indexsearch.nodeCrt.certificate.issuerRef.name`| Name of certificate issuer | `null` |
|`indexsearch.nodeCrt.certificate.issuerRef.kind` | Kind of Issuer | `null` |
|`indexsearch.nodeCrt.certificate.issuerRef.group` | Certificate Issuer Group Name | `null`| 
|`indexsearch.nodeCrt.certificate.duration`| How long certificate will be valid | `null` |
|`indexsearch.nodeCrt.certificate.renewBefore` | When to renew the certificate before it gets expired | `null`|
|`indexsearch.nodeCrt.certificate.secretName` | Name of the secret in which this cert would be added| `null` |
|`indexsearch.nodeCrt.certificate.subject`| Certificate subject | `null`|
|`indexsearch.nodeCrt.certificate.commonName` | CN of certificate | `null`|
|`indexsearch.nodeCrt.certificate.usages ` | Certificate usage | `null`|
|`indexsearch.nodeCrt.certificate.dnsNames ` | DNSNames is a list of DNS subjectAltNames to be set on the Certificate.| `null`|
|`indexsearch.nodeCrt.certificate.uris` | URIs is a list of URI subjectAltNames to be set on the Certificate.| `null`|
|`indexsearch.nodeCrt.certificate.ipAddresses`| IPAddresses is a list of IP address subjectAltNames to be set on the Certificate.| `null`|
|`indexsearch.nodeCrt.certificate.privateKey.algorithm`| Algorithm is the private key algorithm of the corresponding private key for this certificate| `null`|
|`indexsearch.nodeCrt.certificate.privateKey.encoding`| The private key cryptography standards (PKCS) encoding for this certificate’s private key | `null`|
|`indexsearch.nodeCrt.certificate.privateKey.size`| Size is the key bit size of the corresponding private key for this certificate. | `null`|
|`indexsearch.nodeCrt.certificate.privateKey.rotationPolicy`| Rotation of a key pair, when certificate is refreshed is recommended from a security point of view | `Always`|
|`unifiedLogging.env` | ENV parameters to be added in fluentd sidecar container | `null` |
|`manager.name`|Indexsearch manager role name|`manager`|
|`manager.replica`|Desired number of indexsearch manager node replicas|`3`|
|`manager.image.repo`|Indexsearch image repo name. |`bssc-indexsearch`|
|`manager.image.tag`|Indexsearch image tag. Accepted values are 2.11.0-rocky8-jre11-2311.0.1 or 2.11.0-rocky8-jre17-2311.0.1|`2.11.0-rocky8-jre11-2311.0.1`|
|`manager.image.flavor`| set imageFlavor for indexsearch container in all manager,data and client pods |`null`|
|`manager.image.flavorPolicy`| set imageFlavorPolicy for indexsearch container in all manager,data and client pods. Allowed Values: Strict or BestMatch |`null`|
|`manager.ImagePullPolicy`|Indexsearch image pull policy|`IfNotPresent`|
|`manager.imageFlavor`| set imageFlavor at workload level |`null`|
|`manager.imageFlavorPolicy`| set imageFlavorPolicy at workload level. Accepted values: Strict or BestMatch |`null`|
|`manager.resources`|CPU/Memory resource requests/limits/ephemeral-storage for manager pod|`limits:       cpu: ""(1 if enableDefaultCpuLimits is true)      memory: "2Gi" ephemeral-storage: "500Mi"    requests:       cpu: "500m"       memory: "1.5Gi" ephemeral-storage: "200Mi"`|
|`manager.java_opts`|Environment variable for setting up JVM options|` Xms1g  Xmx1g`|
|`manager.podAntiAffinity.ruleDefinition`|Manager pod anti-affinity policy|`soft`|
|`manager.podAntiAffinity.customDefinition`|Manager pod anti-affinity policy (custom rule)|`{}`|
|`manager.podAffinity`|Manager pod affinity (in addition to manager.antiAffinity when set)|`{}`|
|`manager.nodeAffinity`|Manager node affinity (in addition to manager.antiAffinity when set)|`{}`|
|`manager.nodeSelector`|manager node labels for pod assignment|`{}`|
|`manager.tolerations`|List of node taints to tolerate for (manager)|`[]`|
|`manager.topologySpreadConstraints`|topologySpreadConstraints for manager |`{}`|
|`manager.podManagementPolicy`|Manager statefulset parallel pod management policy |`Parallel`|
|`manager.updateStrategy.type`|Manager statefulset update strategy policy|`RollingUpdate`|
|`manager.livenessProbe.initialDelaySeconds`|Delay before liveness probe is initiated (manager)|`30`|
|`manager.livenessProbe.periodSeconds`|How often to perform the probe (manager)|`10`|
|`manager.livenessProbe.timeoutSeconds`|When the probe times out (manager)|`1`|
|`manager.livenessProbe.successThreshold`|Minimum consecutive successes for the probe (manager)|`1`|
|`manager.livenessProbe.failureThreshold`|Minimum consecutive failures for the probe (manager)|`3`|
|`manager.readinessProbe.initialDelaySeconds`|Delay before readiness probe is initiated (manager)|`30`|
|`manager.readinessProbe.periodSeconds`|How often to perform the probe (manager)|`10`|
|`manager.readinessProbe.timeoutSeconds`|When the probe times out (manager)|`1`|
|`manager.readinessProbe.successThreshold`|Minimum consecutive successes for the probe (manager)|`1`|
|`manager.readinessProbe.failureThreshold`|Minimum consecutive failures for the probe (manager)|`3`|
|`manager.priorityClassName` |Indexsearch manager pod priority class name. When this is set, it takes precedence over priorityClassName set at global level |`null`|
|`manager.syslogSidecar.enabled` |Enable/Disable sending manager logs to syslog. Takes precedence over global.unifiedLogging.syslog.enabled and unifiedLogging.syslog.enabled | `true` |
|`manager.pdb.enabled` | To enable Pod Disruption budget for indexsearch manager pods | `true` |
|`manager.pdb.minAvailable` | Minimum number of indexsearch manager pods must still be available when disruption happens |  `null` |
|`manager.pdb.maxUnavailable` | Maximum number for manager pods that can be unavailable when disruption happens. If num of replicas of manager pods is n, there should be minumum (n/2 +1) manager pods always up in the cluster for indexsearch to work properly so, set the maxUnavailable value accordingly. As the default num of replica for manager pods is 3, maxUnavailable is set to 1 by default which ensures n/2+1 condition is met. |  `1` |
|`manager.hostAliases` | Additional dns entries can be added to pod's /etc/hosts for dns resolution by configuring hostaliases for indexsearch manager pods | `null`|
|`data.name`|Indexsearch data role name|`data`|
|`data.replicas`|Desired number of indexsearch data node replicas|`2`|
|`data.resources`|CPU/Memory resource requests/limits/ephemeral-storage for data pod|`limits:       cpu: ""(1 if enableDefaultCpuLimits is true)       memory: "4Gi"  ephemeral-storage: "500Mi"    requests:       cpu: "500m"       memory: "3Gi" ephemeral-storage: "200Mi"`|
|`data.java_opts`|Environment variable for setting up JVM options|` Xms2g  Xmx2g`|
|`data.podManagementPolicy`|Data statefulset parallel pod management policy |`Parallel`|
|`data.updateStrategy.type`|Data statefulset update strategy policy|`RollingUpdate`|
|`data.podAntiAffinity.ruleDefinition`|Data pod anti-affinity policy|`soft`|
|`data.podAntiAffinity.customDefinition`|Data pod anti-affinity policy (custom rule)|`{}`|
|`data.podAffinity`|Data pod affinity (in addition to data.antiAffinity when set)|`{}`|
|`data.nodeAffinity`|Data node affinity (in addition to data.antiAffinity when set)|`{}`|
|`data.nodeSelector`|Data node labels for pod assignment|`{}`|
|`data.tolerations`|List of node taints to tolerate for (data)|`[]`|
|`data.topologySpreadConstraints`|topologySpreadConstraints for data |`{}`|
|`data.livenessProbe.initialDelaySeconds`|Delay before liveness probe is initiated (data)|`30`|
|`data.livenessProbe.periodSeconds`|How often to perform the probe (data)|`10`|
|`data.livenessProbe.timeoutSeconds`|When the probe times out (data)|`1`|
|`data.livenessProbe.successThreshold`|Minimum consecutive successes for the probe (data)|`1`|
|`data.livenessProbe.failureThreshold`|Minimum consecutive failures for the probe (data)|`3`|
|`data.readinessProbe.initialDelaySeconds`|Delay before readiness probe is initiated (data)|`30`|
|`data.readinessProbe.periodSeconds`|How often to perform the probe (data)|`10`|
|`data.readinessProbe.timeoutSeconds`|When the probe times out (data)|`1`|
|`data.readinessProbe.successThreshold`|Minimum consecutive successes for the probe (data)|`1`|
|`data.readinessProbe.failureThreshold`|Minimum consecutive failures for the probe (data)|`3`|
|`data.pdb.enabled` | To enable Pod Disruption budget for indexsearch data pods | `true` |
|`data.pdb.minAvailable` | Minimum number of data pods must still be available when disruption happens |  `null` |
|`data.pdb.maxUnavailable` | Maximum number for data pods that can be unavailable when disruption happens. Default indexsearch shard replication is 1, so primary and replica shards will be distributed across any two data pods. If more than 1 data pod goes down, it can lead to data loss. So maxUnavailable value should be 1 unless the indexsearch shard replication has been increased. Its recommended to atleast have two data pods (to ensure green cluster health) up and running, but if the num of replica for data pods has been reduced to 1, the value of maxUnavailable should be empty and value of minAvailable needs to be set to 1 because the default value of maxUnavailable i.e. 1 will drain the node and this would lead to data loss. |  `1` |
|`data.priorityClassName` |Indexsearch data pod priority class name. When this is set, it takes precedence over priorityClassName set at global level |`null`|
|`data.syslogSidecar.enabled` |Enable/Disable sending data logs to syslog. Takes precedence over global.unifiedLogging.syslog.enabled and unifiedLogging.syslog.enabled | `true` |
|`data.hostAliases` | Additional dns entries can be added to pod's /etc/hosts for dns resolution by configuring hostaliases for indexsearch data pods | `null`|
|`client.name`|Indexsearch client role name|`client`|
|`client.replicas`|Desired number of indexsearch client node replicas|`3`|
|`client.resources`|CPU/Memory resource requests/limits/ephemeral-storage for client pod|`limits:       cpu: ""(1 if enableDefaultCpuLimits is true)       memory: "4Gi"  ephemeral-storage: "500Mi"   requests:       cpu: "500m"       memory: "3Gi" ephemeral-storage: "200Mi"`|
|`client.updateStrategy.type`|Client deployment update strategy policy|`RollingUpdate`|
|`client.java_opts`|Environment variable for setting up JVM options|` Xms2g  Xmx2g`|
|`client.podAntiAffinity.ruleDefinition`|Client pod anti-affinity policy|`soft`|
|`client.podAntiAffinity.customDefinition`|Client pod anti-affinity policy (custom rule)|`{}`|
|`client.podAffinity`|Client pod affinity (in addition to client.antiAffinity when set)|`{}`|
|`client.nodeAffinity`|Client node affinity (in addition to client.antiAffinity when set)|`{}`|
|`client.nodeSelector`|Client node labels for pod assignment|`{}`|
|`client.tolerations`|List of node taints to tolerate for (client)|`[]`|
|`client.topologySpreadConstraints`|topologySpreadConstraints for client |`{}`|
|`client.livenessProbe.initialDelaySeconds`|Delay before liveness probe is initiated (client)|`90`|
|`client.livenessProbe.periodSeconds`|How often to perform the probe (client)|`20`|
|`client.livenessProbe.timeoutSeconds`|When the probe times out (client)|`1`|
|`client.livenessProbe.successThreshold`|Minimum consecutive successes for the probe (client)|`1`|
|`client.livenessProbe.failureThreshold`|Minimum consecutive failures for the probe (client)|`3`|
|`client.readinessProbe.initialDelaySeconds`|Delay before readiness probe is initiated (client)|`90`|
|`client.readinessProbe.periodSeconds`|How often to perform the probe (client)|`20`|
|`client.readinessProbe.timeoutSeconds`|When the probe times out (client)|`1`|
|`client.readinessProbe.successThreshold`|Minimum consecutive successes for the probe (client)|`1`|
|`client.readinessProbe.failureThreshold`|Minimum consecutive failures for the probe (client)|`3`|
|`client.replicasManagedByHpa`| Depending on the value replicas will be managed by either HPA or deployment | `false` |
|`client.hpa.enabled`| Enable/Disable HorizonatlPodAutpscaler | `null(false)`|
|`client.hpa.minReplicas` | Minimum replica count to which HPA can scale down | `3` |
|`client.hpa.maxReplicas` | Maximum replica count to which HPA can scale up | `5` |
|`client.hpa.predefinedMetrics.enabled` | Enable/Disable default memory/cpu metrics monitoring on HPA | `true` |
|`client.hpa.averageCPUThreshold` | HPA keeps the average cpu utilization of all the pods below the value set | `85` |
|`client.hpa.averageMemoryThreshold` | HPA keeps the average memory utilization of all the pods below the value set | `85` |
|`client.hpa.behavior` | Additional behavior to be set here | `empty` |
|`client.hpa.metrics` | Additional metrics to monitor can be set here | `empty` |
|`client.pdb.enabled` | To enable Pod Disruption budget for indexsearch client pods | `true` |
|`client.pdb.minAvailable` | Minimum number of indexsearch client pods must still be available when disruption happens. Atleast 50% of the client pods are recommended to be up to handle the incoming traffic towards indexsearch. The minAvailable value can be changed based on need and incoming load. As the default num of client pods is 3, having minAvailable as 50% will ensure atleast 2 pods are always running for the incoming load. |  `50%` |
|`client.pdb.maxUnavailable` | Maximum number for IS client pods that can be unavailable when disruption happens |  `null` |
|`client.priorityClassName` |Indexsearch client pod priority class name. When this is set, it takes precedence over priorityClassName set at global level |`null`|
|`client.syslogSidecar.enabled` |Enable/Disable sending client logs to syslog. Takes precedence over global.unifiedLogging.syslog.enabled and unifiedLogging.syslog.enabled | `true` |
|`client.hostAliases` | Additional dns entries can be added to pod's /etc/hosts for dns resolution by configuring hostaliases | `null`|
|`initContainer.repo`|Indexsearch init container image repo name. |`bssc-init`|
|`initContainer.tag`|Indexsearch init container image tag. Accepted values are 1.0.0-2311.0.1, 1.0.0-rocky8-jre11-2311.0.1 or 1.0.0-rocky8-jre17-2311.0.1|`1.0.0-2311.0.1` |
|`initContainer.imageFlavor`| set imageFlavor at container level for initContainer.|`null`|
|`initContainer.imageFlavorPolicy`| set imageFlavorPolicy at container level for initContainer. Accepted values: Strict or Bestmatch |`null`|
|`initContainer.resources` |CPU/Memory resource requests/limits/ephemeral-storage for init-container |`limits:       cpu: ""(100m if enableDefaultCpuLimits is true)      memory: "100Mi" ephemeral-storage: "30Mi"    requests:       cpu: "50m"       memory: "50Mi" ephemeral-storage: "30Mi"`|
|`persistence.storageClassName`|Persistent Volume Storage Class name. indexsearch chart support "local-storage","cinder","hostpath". When configured as "" picks the default storage class configured in the BCMT cluster.|`null`|
|`persistence.accessMode`|Persistent Volume Access Modes|`ReadWriteOnce`|
|`persistence.size`|Persistent Volume Size given to data pods for storage|`25Gi`|
|`persistence.managerStorage`|Persistent storage size for cluster manager pod to persist cluster state|`1Gi`|
|`persistence.auto_delete`|Persistent volumes auto deletion along with deletion of chart when set to true|`false`|
|`backup_restore.storageClassName`|Storage class used for backup restore, not for indexsearch data storage purpose. The storage class should be shared with ReadWriteMany option. |`glusterfs-storageclass`|
|`backup_restore.size`|Size of the PersistentVolume used for backup restore|`40Gi`|
|`backup_restore.restoreSystemIndices` | Set it to true to restore system indices( .opendistro_security, kibana index, multitenancy indices) | `false` |
|`backup_restore.path`|This is mount path of B/R PV inside data pods.|`indexsearch-backup`|
|`cbur.enabled`|Enable cbur for backup and restore operation|`false`|
|`cbur.brOption`|Backup is for a stateful set, CBUR will apply the rule specified by the brOption. Recommended value of brOption for BSSC is 0.|`0`|
|`cbur.maxCopy`|Maxcopy of backup files to be stored|`5`|
|`cbur.backendMode`|Configure the mode of backup. Available options are local","NETBKUP","AVAMAR","CEPHS3","AWSS3"|`local`|
|`cbur.cronJob`|Cronjob frequency|`0 23 * * *`|
|`cbur.autoEnableCron`|AutoEnable Cron to take backup as per configured cronjob |`false`|
|`cbur.autoUpdateCron`|AutoUpdate cron to update cron job schedule|`false`|
|`cbur.cbur_restore_parameters`|It is a Configmap which accepts parameters to customize the restore behaviour of the indices.|`CBUR_RESTORE_SUFFIX: "-restored"    CBUR_RESTORE_SUFFIX_WITHDATE: true   CBUR_RESTORE_INDICES_OVERWRITE: false   CBUR_RESTORE_DELETE_INDICES_NOTPARTOF_RESTORE_SNAPSHOT: false`|
|`cbura.imageRepo`|Cbura image used for backup and restore|`cbur/cbura`|
|`cbura.imageTag`|Cbura image tag|`1.1.0-6419`|
|`cbura.imageFlavor`| set imageFlavor for cbura.|`null`|
|`cbura.imageFlavorPolicy`| set imageFlavorPolicy for cbura. Accepted values: Strict or BestMatch |`null`|
|`cbura.supportedImageFlavor` | list of imageFlavor supported by Cbura |`["alpine"]`|
|`cbura.imagePullPolicy`|Cbura image pull policy|`IfNotPresent`|
|`cbura.useImageTagAsIs`| set the useImageTagAsIs to true if you want to use imageTag for cbura as it is. If the useImageTagAsIs is set to false, we must specify the cbura supported image flavor in supportedImageFlavor list.|`false`|
|`cbura.resources`|CPU/Memory/ephemeral-storage resource requests/limits for cbura pod|`limits:       cpu: ""(1 if enableDefaultCpuLimits is true)       memory: "2Gi"         ephemeral-storage: "50Mi"   requests:       cpu: "500m"       memory: "1Gi"        ephemeral-storage: "50Mi"`|
|`cbura.tmp_size`|Volume mount size of /tmp directory for cbur-sidecar.The value should be around double the size of backup_restore.size|`80Gi`|
|`kubectl.image.repo`|Kubectl image name|`tools/kubectl`|
|`kubectl.image.tag`|Kubectl image tag. Accepted Values are 1.26.11-20231124 or 1.26.11-rocky8-nano-20231124 |`1.26.11-20231124`|
|`kubectl.image.flavor`| set imageFlavor for kubectl |`null`|
|`kubectl.image.flavorPolicy`| set imageFlavorPolicy for kubectl. Accepted values: Strict or BestMatch |`null`|
|`kubectl.image.supportedImageFlavor`| List of imageFlavor Supported by Kubectl |`["rocky8-nano"]`| 
|`jobs.affinity`|To provide affinity for jobs and helm test pods|`null`|
|`jobs.nodeSelector`|To provide nodeSelector for jobs and helm test pods|`null`|
|`jobs.tolerations`|To provide tolerations for jobs and helm test pods|`null`|
|`jobs.hookJobs.resources.requests`| CPU/Memory/ephemeral-storage resource requests for job and helm test pods | `requests:       cpu: "100m"       memory: "100Mi"        ephemeral-storage: "50Mi"` |
|`jobs.hookJobs.resources.limits` | CPU/Memory/ephemeral-storage resource limits for job and helm test pods | `limits:       cpu: ""(120m if enableDefaultCpuLimits is true)       memory: "120Mi"        ephemeral-storage: "50Mi"` |
|`jobs.secAdminUpgradeJob.resources.requests` | CPU/Memory/ephemeral-storage resource requests for secAdmin and upgrade job | `requests:       cpu: "200m"       memory: "200Mi" ephemeral-storage: "150Mi"` |
|`jobs.secAdminUpgradeJob.resources.limits` | CPU/Memory resource limits for secAdmin and upgrade job | `limits:       cpu: ""(500m if enableDefaultCpuLimits is true)       memory: "500Mi" ephemeral-storage: "150Mi"` |
|`crossClusterReplication.leader.enabled`|Enable Leader cluster for CCR|`null`|
|`crossClusterReplication.leader.followerDNs`|DNs of certitificates of the follower cluster for the leader to trust|`null`|
|`crossClusterReplication.leader.ingressTcpConfigmap.enabled`|Enable TCP port to be exposed outside via CITM Ingress tcp-services-configmap|`false`|
|`crossClusterReplication.leader.ingressTcpConfigmap.tcpServicesConfigmapName`|Name of the tcp-services-configmap prefix used by the CITM ingress Chart.|`null`|
|`crossClusterReplication.leader.ingressTcpConfigmap.ingressTcpPort`|port number that will be exposed for the TCP service of indexsearch by CITM Ingress|`9300`|
|`crossClusterReplication.follower.enabled`|Enable Follower cluster for CCR|`null`|
|`crossClusterReplication.follower.connectionName`|Name of the cross-cluster-replication connection|`null`|
|`crossClusterReplication.follower.replicateIndices`|Configure the replication rule name and indexPattern|`null`|
|`crossClusterReplication.follower.leaderURL`|Set the proxy Address which contains the IP/DNS and the port of the leader cluster|`null`|
|`restApi.enabled`|Enable the flag to provide rest API commands to be run for the helm release|`false`|
|`restApi.restApiArguments`|Configure all the REST API commands to be run by the helm release|`false`|
|`certManager.enabled` |Enable cert-Manager feature using this flag when security is enabled. It is disabled by default.It takes higher precedence over certManager.enabled at global level.|`null`|
|`security.enable`|Enable security using this flag|`false`|
|`security.sensitiveInfoInSecret.enabled` | Enable this to take sensitive data from secret. When this flag is enabled user has to pre create the secret which are required for chart deployment | `false`|
|`security.sensitiveInfoInSecret.credentialName` | Pre-created secret name which contains sensitive information | `No value is set as default` |
|`security.sensitiveInfoInSecret.additionalInternalUsers` | Add additional users with credential name, username and password in form of a list. | `null` |
|`security.sensitiveInfoInSecret.secInternalUserYml` | Key name in precreated secret that stores the content of internal_users.yml file | `null`|
|`security.sensitiveInfoInSecret.keystoreJks` | Key name in precreated secret that stores indexsearch keystore jks | `null`|
|`security.sensitiveInfoInSecret.truststoreJks` | Key name in precreated secret that stores indexsearch truststore jks | `null`|
|`security.sensitiveInfoInSecret.clientKeystoreJks` | Key name in precreated secret that stores indexsearch client keystore jks | `null`|
|`security.sensitiveInfoInSecret.keyPass` | Key name in precreated secret that stores indexsearch keystore password | `null`|
|`security.sensitiveInfoInSecret.trustPass` | Key name in precreated secret that stores indexsearch truststore password | `null`|
|`security.sensitiveInfoInSecret.clientCrtPem` | Key name in precreated secret that stores the indexsearch client certificate in pem format | `null`|
|`security.sensitiveInfoInSecret.clientKeyPem` | Key name in precreated secret that stores indexsearch client key in pem format | `null`|
|`security.sensitiveInfoInSecret.authAdminIdentity` | Key name in precreated secret that stores the DN of the admin (client) certificate | `null`|
|`security.sensitiveInfoInSecret.nodesDn` | Key name in precreated secret that stores the DN of the node(indexsearch) certificate (required if the certificate does not contain an OID in its SAN) | `null`|
|`security.sensitiveInfoInSecret.kibanaServerUserPwd` | Key name in precreated secret that stores password of kibanaserver user | `null`|
|`security.sensitiveInfoInSecret.adminUserName` | Key name in precreated secret that stores admin username. This has to be configured if secInternalUserYml is not present in pre-created secret | `null`|
|`security.sensitiveInfoInSecret.adminPassword` |   Key name in precreated secret that stores admin password. This has to be configured if secInternalUserYml is not present in pre-created secret | `null`|
|`security.sensitiveInfoInSecret.keycloakRootCaPem` | Key name in precreated secret that stores keycloak rootCA in pem format | `null`|
|`security.certManager.enabled` |Enable cert-Manager feature using this flag when security is enabled. By default, it reads same value as configured in certManager.enabled (root level). It takes higher precedence over certManager.enabled at root and global levels|`{{ Values.certManager.enabled }}`|
|`security.certManager.duration` |How long certificate will be valid|`8760h`
|`security.certManager.renewBefore` |When to renew the certificate before it gets expired|`360h`
|`security.certManager.apiVersion` |Api version of the cert-manager.io | `cert-manager.io/v1alpha3`
|`security.certManager.storePasswordCredentialName` |Secret name which contains the key of storePassword| `null`
|`security.certManager.storePasswordKey` | Key name in secret which stores the keystore password| `null`
|`security.certManager.dnsNames` |DNS used in certificate | `null`
|`security.certManager.issuerRef.name` |Issuer Name | `ncms-ca-issuer`
|`security.certManager.issuerRef.kind` | Kind of Issuer | `ClusterIssuer`
|`security.certManager.issuerRef.group` |Certificate Issuer Group Name | `cert-manager.io`
|`security.nodeCrt.tls.secretRef.name`|Name of the secret having user supplied certificates for opensearch node certificates |`""`|
|`security.nodeCrt.tls.secretRef.keyNames.caCrt`|Name of the secret key containing CA certificate |`null`|
|`security.nodeCrt.tls.secretRef.keyNames.tlsKey`|Name of the secret key containing TLS key |`null`|
|`security.nodeCrt.tls.secretRef.keyNames.tlsCrt`|Name of the secret key containing TLS server certificate |`null`|
|`security.adminCrt.tls.secretRef.name`|Name of the secret having user supplied certificates for opensearch admin certificates |`""`|
|`security.adminCrt.tls.secretRef.keyNames.caCrt`|Name of the secret key containing CA certificate |`null`|
|`security.adminCrt.tls.secretRef.keyNames.tlsKey`|Name of the secret key containing TLS key |`null`|
|`security.adminCrt.tls.secretRef.keyNames.tlsCrt`|Name of the secret key containing TLS certificate |`null`|
|`security.keycloak_auth`|Enable authentication required via keycloak|`false`|
|`security.istio.extCkeyHostname`|FQDN of ckey hostname that is externally accessible from browser|`"ckey.io"`|
|`security.istio.extCkeyLocation`|Location of ckey internal/external to the istio mesh .Accepted values are MESH_INTERNAL, MESH_EXTERNAL|`MESH_INTERNAL`|
|`security.istio.extCkeyIP`|IP to be used for DNS resolution of ckey hostname from the cluster.Required only when ckey is external to istio mesh and ckey hostname is not resolvable from the cluster|`null`|
|`security.ciphers`|Cipher suites are cryptographic algorithms used to provide security  for HTTPS traffic.Example: TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256" "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384"|`null`|
|`extraConfig`|Section to add extra indexsearch configurations. To override opensearch.yml properties, uncomment config_yml and add desired configurations under it|`null`| 
|`jvm_options`|Section to override default jvm.options file|`null`|
|`log4j2_properties`| Section to override default log4j2.properties file|`null`|
|`security.sec_configmap.action_groups_yml`|Action groups are named collection of permissions.Using action groups is the preferred way of assigning permissions to a role.|`Refer values.yaml file or user guide for more details`|
|`security.sec_configmap.config_yml`|Configure Authentication and authorization settings for users|`Refer values.yaml file or user guide for more details`|
|`security.sec_configmap.roles_yml`|Configure security roles defining access permissions to indexsearch indices|`Refer values.yaml file or user guide for more details`|
|`security.sec_configmap.roles_mapping_yml`|Configure security roles that are assigned to users|`Refer values.yaml file or  user guide for more details`|
|`security.sec_configmap.allowlist_yml`|Configure allowlist of REST APIs that can be accessed by all users other than admin-certificate.|`Refer values.yaml file or user guide for more details`|
|`security.sec_configmap.whitelist_yml`|Configure whitelist of REST APIs that can be accessed by all users other than admin-certificate.|`Refer values.yaml file or user guide for more details`|
|`security.sec_configmap.audit_yml`|Audit logging related configuration|`Refer values.yaml file or user guide for more details`|
|`security.sec_configmap.nodes_dn_yml`|Configure DNs of nodes of cross-cluster nodes dynamically| `Refer values.yaml file or user guide for more details`|
|`security.sec_configmap.tenants_yml`| Define additional tenants (other than global & private) for kibana multitenancy.| `Refer values.yaml file or user guide for more details`|
|`emptyDirSizeLimit.extensionsTmp`|Configure the sizeLimit of extensions-tmp emptyDir| `100Mi`|
|`emptyDirSizeLimit.tmp`|Configure the sizeLimit of tmp emptyDir| `200Mi`|
|`emptyDirSizeLimit.isConfig`|Configure the sizeLimit of is-config emptyDir| `10Mi`|
|`emptyDirSizeLimit.datadir`|Configure the sizeLimit of datadir emptyDir for client pods| `10Mi`|
|`emptyDirSizeLimit.sharedVolume`|Configure the sizeLimit of shared-volume emptyDir| `10Mi`|
|`emptyDirSizeLimit.securityconfWithSensitiveinfo`|Configure the sizeLimit of securityconf-with-sensitiveinfo emptyDir| `10Mi`|
|`emptyDirSizeLimit.secAdminJobTmp`|Configure the sizeLimit of tmp emptyDir used in jobs running secadmin| `150Mi`|
|`emptyDirSizeLimit.postSetupApiJobTmp`|Configure the sizeLimit of tmp emptyDir used in post-setup-api-job| `5Mi`|

Specify parameters using `--set key=value[,key=value]` argument to `helm install`

```
helm install my-release --set istio.enabled=true <chart-path> --namespace logging
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```
helm install my-release -f values.yaml <chart-path> --version <version> --namespace logging
```

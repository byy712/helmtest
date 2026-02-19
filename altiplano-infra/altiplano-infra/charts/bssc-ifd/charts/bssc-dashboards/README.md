# Dashboards

_Dashboards_ is an open source frontend application, providing search and data visualization capabilities for data indexed in Indexsearch.

## Pre Requisites:

1. Kubernetes 1.12+
2. Helm 3.0-beta3+

## Installing the Chart

To install the chart with the release name `my-release` in `logging` namespace
```
helm install my-release <chart-path> --namespace logging
```

Note: If the helm v3 client binary is named differently in the kubernetes cluster, replace "helm" with the actual name in all helm commands below. For ex. If it is named as helm3, the command would be:
```
helm3 install my-release <chart-path> --namespace logging
```

The command deploys Dashboards on the Kubernetes cluster in the default configuration. The Parameters section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list -A`

## Uninstalling the Chart:
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
Open source Gatekeeper `K8sPSPCapabilities` (see: [capabilities](https://github.com/open-policy-agent/gatekeeper-library/blob/master/library/pod-security-policy/capabilities)) constraint needs to be relaxed to allow the following additional privileges:

```yaml
capabilities:
  add: [ "NET_ADMIN", "NET_RAW" ]
```

## Parameters:
The following table lists the configurable parameters of the Dashboards chart and their default values.

|   Parameter             |Description                               |Default                      |
|----------------|-------------------------------|----------------------------|
|`global.registry`|Global container image registry for all images |`csf-docker-delivered.repo.cci.nokia.net`|
|`global.flatRegistry`   |Enable this flag to read image registries with a flat structure. It is disabled by default. |`false`|
|`global.enableDefaultCpuLimits`   |Enable this flag to set pod CPU resources limit for all containers. It is disabled by default. |`false`|
|`global.seccompAllowedProfileNames`|Annotation that specifies which values are allowed for the pod seccomp annotations|`docker/default`|
|`global.seccompDefaultProfileName`|Annotation that specifies the default seccomp profile to apply to containers|`docker/default`|
|`global.podNamePrefix`  | Prefix to be added for pods and jobs names    | `null` |
|`global.disablePodNamePrefixRestrictions` |  Enable if podNamePrefix need to be added to the pod name without any restrictions. It is disabled by default.  | `false`  |
|`global.certManager.enabled` |Enable cert-Manager feature using this flag. It is enabled by default.|`true`|
|`global.containerNamePrefix` | Prefix to be added for pod containers and job container names   | `null` |
|`global.priorityClassName`  | priorityClassName for Dashboards pods, set at global level | `null` |
|`global.imagePullSecrets`  | imagePullSecrets configured at global level. | `null` |
|`global.annotations`  | Annotations configured at global level. These will be added at both pod level and the deployment level for Dashboards.   | `null` |
|`global.labels`  | Labels configured at global level. These will be added at both pod level and the deployment level for Dashboards.   | `null` |
|`global.istio.version`|Istio version defined at global level. Accepts version in numeric X.Y format. |`1.7`|
|`global.istio.cni.enabled`|Whether istio cni is enabled in the environment: true/false |`true`|
|`global.imageFlavor`| Set imageFlavor at global level. | `null` |
|`global.imageFlavorPolicy`| Set imageFlavorPolicy at global level. Accepted values: Strict or BestMatch(Default) |`null`|
|`global.timeZoneEnv`        | To specify global timezone value           | `UTC` |
|`global.ipFamilyPolicy`     | ipFamilyPolicy for dual-stack support configured at global scope | `null` |
|`global.ipFamilies`      | ipFamilies for dual-stack support configured at global scope | `null` |
|`global.hpa.enabled` | Enable/Disable HPA | `null(false)` |
|`global.unifiedLogging.extension` | list of extended fields that component can use to enrich the log event | `null` |
|`global.unifiedLogging.syslog.enabled`      | Enable sending logs to syslog   | `null(false)` |
|`global.unifiedLogging.syslog.facility`      | Syslog facility   | `null` |
|`global.unifiedLogging.syslog.host`      | Syslog server host name to connect to | `null` |
|`global.unifiedLogging.syslog.port`      | Syslog server port to connect to | `null` |
|`global.unifiedLogging.syslog.protocol`      | Protocol to connect to syslog server. Ex. TCP | `null` |
|`global.unifiedLogging.syslog.caCrt.secretName`      | Name of secret containing syslog CA certificate | `null` |
|`global.unifiedLogging.syslog.caCrt.key`      | Key in secret containing syslog CA certificate | `null` |
|`global.unifiedLogging.syslog.tls.secretRef.name`      | Name of secret containing syslog CA certificate.  It takes higher precedence over syslog.caCrt.secretName. | `null` |
|`global.unifiedLogging.syslog.tls.secretRef.keyNames.caCrt`     | Key in secret containing syslog CA certificate.  It takes higher precedence over syslog.caCrt.key. | `ca.crt` |
|`rbac.enabled`|Enable/disable rbac. When rbac.enabled is set to true, charts would create its own rbac related resources; If false, an external serviceAccountName set in values will be used. |`true`|
|`serviceAccountName`|Pre-created ServiceAccount specifically for Dashboards chart.|`null`|
|`rbac.psp.create`    | If set to true, then chart creates its own PSPs only if required; If set to false, then chart do not create PSPs. | `false` |
|`rbac.psp.annotations`  | Annotation to be set when 'containerSecurityContext.seccompProfile.type' is configured or if required only | `seccomp.security.alpha.kubernetes.io/allowedProfileNames: '*'` |
|`rbac.scc.create`    | If set to true, then chart creates its own SCCs only if required; If set to false, then chart do not create SCCs. | `false` |
|`rbac.scc.annotations`    | To set annotations for SCCs only if required; | `null` |
|`customResourceNames.resourceNameLimit`      | Character limit for resource names to be truncated               | `63` |
|`customResourceNames.dboPod.dboContainerName`    | Name for Dashboards pod's container             | `null` |
|`customResourceNames.dboPod.initContainerName` | Name of init container | `null` |
|`customResourceNames.dboPod.unifiedLoggingContainerName` | Name of UnifiedLoggingContainer | `null` |
|`customResourceNames.dboPod.dboPluginsInitContainerName` | Name of dbo-plugins-init Container Name | `null` |
|`customResourceNames.helmTestPod.name`       | Name for helm test pod                | `null` |
|`customResourceNames.helmTestPod.helmTestContainerName`    | Name for helm test pod's container     | `null` |
|`customResourceNames.deleteJob.name` | Name for Dashboards delete job | `null` |
|`customResourceNames.deleteJob.deleteJobContainerName` | Name for Dashboards delete job's container | `null`|
|`customResourceNames.preUpgradeJob.name` | Name for Dashboards pre upgrade job | `null`|
|`customResourceNames.preUpgradeJob.preUpgradeContainerName` | Name for Dashboards pre upgrade job's container | `null`|
|`disablePodNamePrefixRestrictions` |   disablePodNamePrefixRestrictions configured at root level. It takes higher precedence over disablePodNamePrefixRestrictions configured at global level  | `false`  |
|`nameOverride`         | Use this to override name for Dashboards deployment kubernetes object. When it is set, the name would be ReleaseName-nameOverride              | `null` |
|`fullnameOverride`        | Use this to configure custom-name for Dashboards deployment kubernetes object.  If both nameOverride and fullnameOverride are specified, fullnameOverride would take the precedence.               | `null` |
|`enableDefaultCpuLimits`   |Enable this flag to set pod CPU resources limit for all containers. It has no value set by default. |`null`|
| `partOf`  | Use this to configure common lables for k8s objects. Set to configure label app.kubernetes.io/part-of: | `null` |
|`timezone.timeZoneEnv`        | To specify timezone value and this will have higer precedence over global.timeZoneEnv         | `UTC` |
|`kubectl.image.repo`|Kubectl image name|`tools/kubectl`|
|`kubectl.image.tag`|Kubectl image tag. Accepted Values: 1.26.11-20231124 or 1.26.11-rocky8-nano-20231124 |`1.26.11-20231124`|
|`kubectl.image.flavor`|To provide imageFlavor for jobs and helm test pod | `null` |
|`kubectl.image.flavorPolicy`|To provide imageFlavor policy for jobs and helm test pod. Accepted values: Strict or BestMatch(Default) |`null`|
|`jobs.affinity`|To provide affinity for jobs and helm test pod |`null`|
|`jobs.nodeSelector`|To provide nodeSelector for jobs and helm test pod |`null`|
|`jobs.tolerations`|To provide tolerations for jobs and helm test pod |`null`|
|`jobs.hookJobs.resources.requests`                    | CPU/Memory/ephemeral-storage resource requests for job and helm test pod         | `requests:       cpu: "100m"       memory: "100Mi"        ephemeral-storage: "50Mi"` |
|`jobs.hookJobs.resources.limits`                      | CPU/Memory/ephemeral-storage resource limits for job and helm test pod           | `limits:       cpu: ""(120m  if enableDefaultCpuLimits is true)       memory: "120Mi"        ephemeral-storage: "50Mi"` |
|`service.type`|Kubernetes service type|`ClusterIP`|
|`service.annotations`|custom service annotations |`{}`|
|`service.name`|Kubernetes service name of Dashboards|`default value is commented out`|
|`ipFamilyPolicy`|ipFamilyPolicy for dual-stack support configured at chart level. Allowed values: SingleStack, PreferDualStack,RequireDualStack |`null`|
|`ipFamilies`|ipFamilies for dual-stack support configured at chart level. Allowed values: ["IPv4"], ["IPv6"], ["IPv4","IPv6"], ["IPv6","IPv4"] |`null`|
|`imagePullSecrets`| Dashboards imagePullSecrets configured at root level. It takes higher precedence over imagePullSecrets configured at global level |`null`|
|`imageFlavor`| Dashboards imageFlavor configured at root level. It takes higher precedence over imageFlavor configured at global level. | `null` |
|`imageFlavorPolicy`| Dashboards imageFlavor policy configured at root level. It takes higher precedence over imageFlavor policy configured at global level. Accepted values: Strict or BestMatch(Default) |`null`|
|`dashboards.replicas`|Desired number of Dashboards replicas|`1`|
|`dashboards.image.repo`|Dashboards image repo name. |`bssc-dashboards`|
|`dashboards.image.tag`|Dashboards image tag. Accepted values are 2.11.0-2311.0.1 or 2.11.0-rocky8-jre11-2311.0.1 or 2.11.0-rocky8-jre17-2311.0.1|`2.11.0-2311.0.1`|
|`dashboards.image.flavor`| Image flavor name for dashboards container. | `null` |
|`dashboards.image.flavorPolicy`| Image flavor policy for dashboards container.  Accepted values: Strict or BestMatch(Default) |`null`|
|`dashboards.ImagePullPolicy`|Dashboards image pull policy|`IfNotPresent`|
|`dashboards.imageFlavor`|  Image flavor name for dashboards workload. | `null` |
|`dashboards.imageFlavorPolicy`|  Image flavor policy for dashboards workload. Accepted values: Strict or BestMatch(Default) |`null`|
|`dashboards.resources`|CPU/Memory/ephemeral-storage resource requests/limits for Dashboards pod | `limits: CPU/Mem/ephemeral (1000m if enableDefaultCpuLimits is true)/2Gi/1Gi , requests: CPU/Mem/ephemeral 500m/1Gi/200Mi`|
|`dashboards.k8sSvcPort`|  It should be the port used by kubernetes service | `443` |
|`dashboards.port`|Dashboards is served by a back end server. This setting specifies the port to use.|`5601`|
|`dashboards.securityContext.enabled`|To enable/disable security context |`true`|
|`dashboards.securityContext.runAsUser`|UID with which the container will be run|`1000`|
|`dashboards.securityContext.fsGroup`|Group ID that is assigned for the volumemounts mounted to the pod|`1000`|
|`dashboards.securityContext.supplementalGroups`|The supplementalGroups ID applies to shared storage volumes|`default value is commented out`|
|`dashboards.securityContext.seLinuxOptions`|Provision to configure selinuxoptions for Dashboards container |`default value is commented`|
|`dashboards.containerSecurityContext.seccompProfile.type`|Provision to configure  seccompProfile for Dashboards containers |`RuntimeDefault`|
|`dashboards.custom.deployment.annotations`|Dashboards deployment specific annotations|`{}`|
|`dashboards.custom.deployment.labels`|Dashboards deployment specific labels|`{}`|
|`dashboards.custom.pod.annotations`|Dashboards pod specific annotations|`{}`|
|`dashboards.custom.pod.labels`|Dashboards pod specific labels|`{}`|
|`dashboards.custom.hookJobs.job.annotations`|Dashboards helm hook jobs specific annotations|`{}`|
|`dashboards.custom.hookJobs.job.labels`|Dashboards helm hook jobs specific labels|`{}`|
|`dashboards.custom.hookJobs.pod.annotations`|Dashboards helm hook & test pods specific annotations|`{}`|
|`dashboards.custom.hookJobs.pod.labels`|Dashboards helm hook & test pods specific labels|`{}`|
|`dashboards.node_port`|This setting specifies the node_port to use when service type is NodePort|`30601`|
|`dashboards.ImagePullPolicy`|Dashboards image pull policy|`IfNotPresent`|
|`dashboards.livenessProbe.initialDelaySeconds `|Delay before liveness probe is initiated (Dashboards)|`150`|
|`dashboards.livenessProbe.probecheck`|Configuration of Liveness check (Dashboards)|`empty`|
|`dashboards.livenessProbe.periodSeconds`|How often to perform the probe (Dashboards)|`30`|
|`dashboards.livenessProbe.timeoutSeconds`|When the probe times out (Dashboards)|`1`|
|`dashboards.livenessProbe.successThreshold`|Minimum consecutive successes for the probe (Dashboards)|`1`|
|`dashboards.livenessProbe.failureThreshold`|Minimum consecutive failures for the probe (Dashboards)|`6`|
|`dashboards.readinessProbe.initialDelaySeconds`|Delay before readiness probe is initiated (Dashboards)|`150`|
|`dashboards.readinessProbe.probecheck`|Configuration of Readiness check (Dashboards)|`empty`|
|`dashboards.readinessProbe.periodSeconds`|How often to perform the probe (Dashboards)|`15`|
|`dashboards.readinessProbe.timeoutSeconds`|When the probe times out (Dashboards)           |`1`|
|`dashboards.readinessProbe.successThreshold`|Minimum consecutive successes for the probe (Dashboards)|`1`|
|`dashboards.priorityClassName`|Dashboards pod priority class name. When this is set, it takes precedence over priorityClassName set at global level |`null`|
|`dashboards.imagePullSecrets`| Dashboards imagePullSecrets configured at workload level. It takes higher precedence over imagePullSecrets configured at root or global levels |`null`|
|`dashboards.pdb.enabled` | To enable Pod Disruption budget for Dashboards pods |`true`|
|`dashboards.pdb.minAvailable` | Minimum number of Dashboards pods must still be available when disruption happens. Atleast 50% of the Dashboards pods are recommended to be up to handle the incoming traffic. The minAvailable value can be changed based on need and incoming load. As default replica of Dashboards is 1 and pdb.minAvailable is 50%, it will not allow to drain the node and service will not get interrupted. If user still wants to drain the node: option 1: If service outage is not acceptable - increase the num of replicas for Dashboards so that the PDB conditions are met. option 2: If service outage is acceptable -  either disable PDB or set minAvailable to empty and maxUnavailable to 1 so that node can be drained|`50%`|
|`dashboards.pdb.maxUnavailable` | Maximum number for Dashboards pods that can be unavailable when disruption happens|`null`|
|`dashboards.readinessProbe.failureThreshold`|Minimum consecutive failures for the probe (Dashboards)|`6`|
|`dashboards.replicasManagedByHpa`| Depending on the value replicas will be managed by either HPA or deployment | `false` |
|`dashboards.hpa.enabled`| Enable/Disable HorizontalPodAutoscaler | `null(false)` |
|`dashboards.hpa.minReplicas` | Minimum replica count to which HPA can scale down | `1` |
|`dashboards.hpa.maxReplicas` | Maximum replica count to which HPA can scale up | `3` |
|`dashboards.hpa.predefinedMetrics.enabled` | Enable/Disable default memory/cpu metrics monitoring on HPA | `true` |
|`dashboards.hpa.averageCPUThreshold` | HPA keeps the average cpu utilization of all the pods below the value set | `85` |
|`dashboards.hpa.averageMemoryThreshold` | HPA keeps the average memory utilization of all the pods below the value set | `85` |
|`dashboards.hpa.behavior` | Additional behavior to be set here | `empty` |
|`dashboards.hpa.metrics` | Additional metrics to monitor can be set here | `empty` |
|`dashboards.hostAliases` | Additional dns entries can be added to pod's /etc/hosts for dns resolution by configuring hostaliases | `null` |
|`dashboards.unifiedLogging.enabled` | enable/disable unified logging for Dashboards logs. | `true` |
|`dashboards.unifiedLogging.imageRepo` | image repo for fluentd sidecar used in Dashboards pod to convert Dashboards logs into unified-logging format. | `bssc-fluentd` |
|`dashboards.unifiedLogging.imageTag` | image tag for fluentd sidecar. Accepted values are 1.16.2-2311.0.1 or 1.16.2-rocky8-jre11-2311.0.1 or 1.16.2-rocky8-jre17-2311.0.1  | `1.16.2-2311.0.1` |
|`dashboards.unifiedLogging.imagePullPolicy` | image pull policy for fluentd sidecar | `IfNotPresent`|
|`dashboards.unifiedLogging.imageFlavor`| Image flavor name for fluentd sidecar container. | `null` |
|`dashboards.unifiedLogging.imageFlavorPolicy`| Image flavor policy for fluentd sidecar container. Accepted values: Strict or BestMatch(Default) |`null`|
|`dashboards.unifiedLogging.resources` | CPU/Memory/ephemeral-storage resource requests/limits for fluentd sidecar |`limits: CPU/Mem/ephemeral-storage (50m if enableDefaultCpuLimits is true)/100Mi/200Mi , requests: CPU/Mem/ephemeral-storage 20m/80Mi/200Mi`|
|`dashboards.unifiedLogging.syslog.enabled`      | Enable sending logs to syslog. Takes precedence over global.unifiedLogging.syslog.enabled | `null(false)` |
|`dashboards.unifiedLogging.syslog.facility`      | Syslog facility   | `null` |
|`dashboards.unifiedLogging.syslog.host`      | Syslog server host name to connect to | `null` |
|`dashboards.unifiedLogging.syslog.port`      | Syslog server port to connect to | `null` |
|`dashboards.unifiedLogging.syslog.protocol`      | Protocol to connect to syslog server. Ex. TCP | `null` |
|`dashboards.unifiedLogging.syslog.caCrt.secretName`      | Name of secret containing syslog CA certificate | `null` |
|`dashboards.unifiedLogging.syslog.caCrt.key`      | Key in secret containing syslog CA certificate | `null` |
|`dashboards.unifiedLogging.syslog.tls.secretRef.name`      | Name of secret containing syslog CA certificate.  It takes higher precedence over syslog.caCrt.secretName. | `null` |
|`dashboards.unifiedLogging.syslog.tls.secretRef.keyNames.caCrt`     | Key in secret containing syslog CA certificate.  It takes higher precedence over syslog.caCrt.key. | `ca.crt` |
|`dashboards.unifiedLogging.syslog.appLogBufferSize`      | Size of buffer for application logs sent to syslog | `50MB` |
|`dashboards.unifiedLogging.syslog.sidecarLogBufferSize`      | Size of buffer for fluentd sidecar logs sent to syslog | `20MB` |
|`dashboards.unifiedLogging.env` | ENV parameters to be added in fluentd sidecar container | `null`|
|`dashboards.unifiedLogging.extension` | list of extended fields that component can use to enrich the log event | `null` |
|`dashboards.indexsearch.credentialName.name`| When clientcert_auth_domain in indexsearch chart and cert manager is enabled, configure secret name same as configured in indexsearch chart's indexsearch.externalClientCertificates.dashboards.certificate.secretName | `{{ .Release.Name }}-bssc-ifd-cert-for-dashboards` |
|`dashboards.configMaps.dashboards_configmap_yml.server.name`|A human-readable display name that identifies this Dashboards instance|`kibana`|
|`dashboards.configMaps.dashboards_configmap_yml.server.customResponseHeaders`|Header names and values to send on all responses to the client from the Dashboards server|`{ "X-Frame-Options": "DENY" }  `|
|`dashboards.configMaps.dashboards_configmap_yml.server.ssl.supportedProtocols`|Supported protocols with versions. Valid protocols: TLSv1, TLSv1.1, TLSv1.2. Enable server.ssl.supportedProtocols when security is enabled.|`Even though the value is commented, default values are TLSv1.1, TLSv1.2`|
|`dashboards.configMaps.dashboards_configmap_yml.opensearch_security.multitenancy.enabled `|Enable multitenancy in dashboards|`false`| 
|`dashboards.configMaps.dashboards_configmap_yml.opensearch.requestHeadersAllowlist `|Dashboards client-side headers to send to indexsearch|`Even though the value is commented, default value is autorization`|
|`dashboards.configMaps.dashboards_configmap_yml.opensearch_security.auth.unauthenticated_routes `|Disable authentication on /api/status route |`['/api/status']`|
|`dashboards.configMaps.dashboards_configmap_yml.opensearch_security.auth.type`|If openid/ckey authentication is required, then uncomment and set this parameter to openid, Also uncomment and configure the other openid.* parameters accordingly. |`default value is basicauth when security is enabled.`|
|`dashboards.configMaps.dashboards_configmap_yml.opensearch_security.openid.connect_url `|The URL where the IdP publishes the OpenID metadata.|`null`|
|`dashboards.configMaps.dashboards_configmap_yml.opensearch_security.openid.client_id`|The ID of the OpenID client configured in your IdP|`null`|
|`dashboards.configMaps.dashboards_configmap_yml.opensearch_security.openid.client_secret`|The client secret of the OpenID client configured in your IdP|`null`|
|`dashboards.configMaps.dashboards_configmap_yml.opensearch_security.openid.header`|HTTP header name of the JWT token|`null`|
|`dashboards.configMaps.dashboards_configmap_yml.opensearch_security.openid.base_redirect_url`|The URL where the IdP redirects to after successful authentication|`null`|
|`dashboards.configMaps.dashboards_configmap_yml.opensearch_security.openid.root_ca`|Path to the root CA of your IdP|`null`|
|`dashboards.configMaps.dashboards_configmap_yml.csan.enabled `|To enable/disable CSAN-Dashboards integration. If csan is enabled, then uncomment and set other opendistro_security.auth.unauthenticated_routes,csan.* parameters accordingly|`null`|
|`dashboards.configMaps.dashboards_configmap_yml.csan.ssoproxy.url`|This is CSAN SSOProxy service URL|`null`|
|`dashboards.configMaps.dashboards_configmap_yml.opendistro_security.auth.unauthenticated_routes`|CSAN plugin routes need to be excluded from opendistro security authentication model|`null`|
|`dashboards.configMaps.dashboards_configmap_yml.csp.strict `|Dashboards uses a Content Security Policy to help prevent the browser from allowing unsafe scripting|`true`|
|`dashboards.configMaps.dashboards_configmap_yml.csan.sco.url`|This is system credential orchestrator service URL|`null`|
|`dashboards.configMaps.dashboards_configmap_yml.csan.sco.keycloak_entity`|This is keycloak entity name name|`null`|
|`dashboards.configMaps.dashboards_configmap_yml.csan.sco.keycloak_classifier`|This is Keyclock realm-admin and this is required to connect with keycloak|`null`|
|`dashboards.configMaps.dashboards_configmap_yml.csan.sco.sane_entity `|SANE entity name|`null`|
|`dashboards.configMaps.dashboards_configmap_yml.csan.sco.sane_plugin_name `|Name of CSAN-Dashboards credential plugin|`null`|
|`dashboards.configMaps.dashboards_configmap_yml.csan.auth_type `|Authentication type for dynamic password for CSAN users|`null`|
|`dashboards.env.OPENSEARCH_HOSTS`| The URLs of the indexsearch instances to use for all your queries. When security is enabled use protocol as https                                                |`http://indexsearch:9200`|
|`dashboards.env.SERVER_SSL_ENABLED`|When istio is enabled then uncomment SERVER_SSL_ENABLED and set it to false and If security is enabled uncomment SERVER_SSL_ENABLED|               `"default value is commented out"`|
|`dashboards.affinity`|Dashboards affinity (in addition to dashboards.antiAffinity when set)|`{}`|
|`dashboards.nodeSelector`|Dashboards node labels for pod assignment|`{}`|
|`dashboards.tolerations`|List of node taints to tolerate (Dashboards)|`[]`|
|`dashboards.topologySpreadConstraints`|topologySpreadConstraints for dashboards |`{}`|
|`dashboards.certificate.enabled` | If cert manager is enabled, certificate will be created as per it's configured in this section | `true` |
|`dashboards.certificate.issuerRef.name`| Name of certificate issuer | `null` |
|`dashboards.certificate.issuerRef.kind` | Kind of Issuer | `null` | 
|`dashboards.certificate.issuerRef.group` | Certificate Issuer Group Name | `null` | 
|`dashboards.certificate.duration`| How long certificate will be valid |`null` |
|`dashboards.certificate.renewBefore` | When to renew the certificate before it gets expired |`null` |
|`dashboards.certificate.secretName` | Name of the secret in which this cert would be added| `null` |
|`dashboards.certificate.subject`| Certificate subject | `null`|
|`dashboards.certificate.commonName` | CN of certificate | `null` |
|`dashboards.certificate.usages ` | Certificate usage | `null` |
|`dashboards.certificate.dnsNames ` | DNSNames is a list of DNS subjectAltNames to be set on the Certificate.| `null` |
|`dashboards.certificate.uris` | URIs is a list of URI subjectAltNames to be set on the Certificate.| `null`|
|`dashboards.certificate.ipAddresses`| IPAddresses is a list of IP address subjectAltNames to be set on the Certificate. |`null`|
|`dashboards.certificate.privateKey.algorithm`| Algorithm is the private key algorithm of the corresponding private key for this certificate | `null`|
|`dashboards.certificate.privateKey.encoding`| The private key cryptography standards (PKCS) encoding for this certificate’s private key | `null`|
|`dashboards.certificate.privateKey.size`| Size is the key bit size of the corresponding private key for this certificate. | `null` |
|`dashboards.certificate.privateKey.rotationPolicy`| Rotation of a key pair, when certificate is refreshed is recommended from a security point of view | `Always` |
|`dbobaseurl.url`|Baseurl configured for Dashboards when Dashboards service is with ClusterIP|`/logviewer`|
|`dbobaseurl.cg`|Do not change cg(capture group) parameter below unless you want to change/modify nginx rewrite-target for Dashboards ingress|`/?(.*)`|
|`cbur.enabled`|Enable cbur to take backup & restore the data|`false`|
|`cbur.maxCopy`|max copy of backupdata stored in cbur|`5`|
|`cbur.backendMode`|Configure the mode of backup. Available options are local","NETBKUP","AVAMAR","CEPHS3","AWSS3"|`local`|
|`cbur.cronJob`|cronjob frequency|`0 23 * * *`|
|`cbur.autoEnableCron`|To auto enable cron job |`false`|
|`cbur.autoUpdateCron`|To delete/update cronjob automatically based on autoEnableCron|`false`|
|`ingress.enabled`|Enable to access Dashboards svc via citm-ingress|`true`|
|`ingress.annotations`|Ingress annotations (evaluated as a template)|`{}`|
|`ingress.host`|Hosts configured for ingress|`*`|
|`ingress.tls`|TLS configured for ingress |`[]`|
|`ingress.pathType`|Path type configured for ingress|`Prefix`|
|`istio.enabled`|Enabled istio for Dashboards when running in istio enabled namespace|`false`|
|`istio.version`|Istio version specified at chart level. If defined here,it takes precedence over global level. Accepts istio version in numeric X.Y format. Ex. 1.7|`null`|
|`istio.cni.enabled`|Whether istio cni is enabled in the environment: true/false |`null`|
|`istio.envoy.healthCheckPort`|Health check port of istio envoy proxy. Set value to 15020 for istio versions <1.6 and 15021 for version >=1.6 |`15021`|
|`istio.envoy.waitTimeout`| Time in seconds to wait for istio envoy proxy to load required configurations | `60` |
|`istio.envoy.stopPort`|Port used to terminate istio envoy sidecar using /quitquitquit endpoint |`15000`|
|`istio.createDrForClient`| This optional flag should only be used when application was installed in istio-injection=enabled namespace, but was configured with istio.enabled=false, thus istio sidecar could not be injected into this application |`false`|
|`istio.customDrSpecForClient` | This configurations will be used for configuring spec of DestinationRule  when createDrForClient flag is enabled | `mode: DISABLE`|
|`istio.virtual_svc.hosts`|VirtualService defines a set of traffic routing rules to apply when a host is addressed|`*`|
|`istio.virtual_svc.exportTo`|Defines in which all namespaces virtual service is exported to |`*`|
|`istio.virtual_svc.gateways` | existing gateways for Dashboards Virtual Service to bind to. If shared gateway is available, Dashboards VirtualService will only use shared gateway | `dashboards-gw`|
|`istio.sharedHttpGateway`|Istio ingressgateway name if existing gateway should be used|`null`|
|`istio.sharedHttpGateway.namespace` | Namespace where the existing gateway object exists. | `null` |
|`istio.sharedHttpGateway.name` | Name of the shared gateway object | `null` |
|`istio.gateways` | An optional array of gateways which can be added if needed. These gateways will be created fresh in your install | `dashboards-gw` |
|`istio.gateways.dashboards-gw.enabled` | enable/disable gateway creation. When sharedHttpGateway is used this parameter has to be disabled | `true` |
|`istio.gateways.dashboards-gw.labels` | Optional labels to be added to gateway object | `null`|
|`istio.gateways.dashboards-gw.annotations` | Optional annotations to be added to the gateway object | `null`|
|`istio.gateways.dashboards-gw.ingressPodSelector.istio`|This should be the label of the istio ingressgateway pod which you want your gateway to attach to |`ingressgateway`|
|`istio.gateways.dashboards-gw.port`|Port number used for istio gateway|`80`|
|`istio.gateways.dashboards-gw.protocol`|Protocol used for istio gateway|`HTTP  `|
|`istio.gateways.dashboards-gw.host`|Hosts configured for istio gateway. By default chart will use '*' |`null`|
|`istio.gateways.dashboards-gw.tls`| TLS settings for your gateway. This section is mandatory if protocol is TLS/HTTPS. |`null`|
|`istio.gateways.dashboards-gw-tls.redirect` | This optional flag is only applicable for an HTTP port to force a redirection to HTTPS. | `false`|
|`istio.gateways.dashboards-gw.tls.mode` | Mode can be SIMPLE / MUTUAL / PASSTHROUGH/ ISTIO_MUTUAL and it is exactly as per ISTIO documentation | `null`|
|`istio.gateways.dashboards-gw.tls.credentialName` | The name of the kubernetes secret, in the namespace to be used for TLS traffic | `null`|
|`istio.gateways.dashboards-gw.tls.custom` | Istio TLS has many other attributes and configurations. If for some reason none of the above fits your needs , then use this section to configure as per istio docs. Anything under here will be directly moved under TLS section of gateway definition | `null` |
|`initContainer.repo`|Dashboards init container image name. |`bssc-init`|
|`initContainer.tag`|Dashboards init container image tag. Accepted values are 1.0.0-2311.0.1 or 1.0.0-rocky8-jre11-2311.0.1 or 1.0.0-rocky8-jre17-2311.0.1|`1.0.0-2311.0.1` |
|`initContainer.imageFlavor`|Image flavor name for init container. | `null` |
|`initContainer.imageFlavorPolicy`|Image flavor policy for init container. Accepted values: Strict or BestMatch(Default) |`null`|
|`initContainer.resources`   |CPU/Memory resource requests/limits/ephemeral-storage for init-container |`limits:       cpu: ""(100m if enableDefaultCpuLimits is true)      memory: "100Mi" ephemeral-storage: "30Mi"    requests:       cpu: "50m"       memory: "50Mi" ephemeral-storage: "30Mi"`|
|`dboPluginsInit.repo`|Dashboards plugins init container image name. |`bssc-dboplugins`|
|`dboPluginsInit.tag`|Dashboards plugins init container image tag. Accepted values: 2.11.0-2311.0.1 or 2.11.0-rocky8-2311.0.1 |`2.11.0-2311.0.1` |
|`dboPluginsInit.imageFlavor`|Image flavor name for dbo-plugins container. | `null` |
|`dboPluginsInit.imageFlavorPolicy`|Image flavor policy for dbo-plugins container. Accepted values: Strict or BestMatch(Default) |`null`|
|`dboPluginsInit.resources`   |CPU/Memory resource requests/limits/ephemeral-storage for dbo plugins init-container |`limits:       cpu: ""(50m if enableDefaultCpuLimits is true)      memory: "100Mi" ephemeral-storage: "1Gi"    requests:       cpu: "20m"       memory: "80Mi" ephemeral-storage: "1Gi"`|
|`certManager.enabled` |Enable cert-Manager feature using this flag when security is enabled. It is disabled by default.It takes higher precedence over certManager.enabled at global level.|`null`|
|`security.enable `|Enable tag for Security|`false `|
|`security.certManager.enabled` |Enable cert-Manager feature using this flag when security is enabled. By default, it reads same value as configured in certManager.enabled (root level). It takes higher precedence over certManager.enabled at root and global levels|`null`|
|`security.certManager.apiVersion` |Api version of the cert-manager.io | `cert-manager.io/v1alpha3`
|`security.certManager.duration` |How long certificate will be valid|`8760h`
|`security.certManager.renewBefore` |When to renew the certificate before it gets expired|`360h`
|`security.certManager.dnsNames` |DNS used in certificate | `null`
|`security.certManager.issuerRef.name` |Issuer Name | `ncms-ca-issuer`
|`security.certManager.issuerRef.kind` |CRD Name | `ClusterIssuer`
|`security.certManager.issuerRef.group` |Certificate Issuer Group Name | `cert-manager.io`
|`security.sensitiveInfoInSecret.enabled` | SensitiveInfo flag is enabled by default when security is enabled. User has to pre create the secret which are required for chart deployment | `false`|
|`security.sensitiveInfoInSecret.credentialName` | Pre-created secret name which contains secret information | `No values are set as default` |
|`security.sensitiveInfoInSecret.dboServerCrt` | secret key for Dashboards server certificate from pre-created secret | `No value is set as default`|
|`security.sensitiveInfoInSecret.dboServerKey` | secret key for Dashboards server key from pre-created secret| `No value is set as default`|
|`security.sensitiveInfoInSecret.dboIsPassword` | secret key for Dashboards indexsearch password from pre-created secret | `No value is set as default` |
|`security.sensitiveInfoInSecret.IsRootCaPem` | secret key for IS RootCA pem from pre-created secret | `No value is set as default`|
|`security.sensitiveInfoInSecret.keycloakRootCaPem` | secret key for keycloak rootCA pem from pre-created secret | `No value is set as default` |
|`security.sensitiveInfoInSecret.keycloakClientId` | secret key for keycloak ClientId from pre-created secret | `No value is set as default` |
|`security.sensitiveInfoInSecret.keycloakClientSecret` | secret key for keycloak Client secret from pre-created secret | `No value is set as default` |
|`security.sensitiveInfoInSecret.sane.keycloak_admin_user_name` | secret key for keycloak admin username when sane is enabled | `Default value is commented out` |
|`security.sensitiveInfoInSecret.sane.keycloak_admin_password` | secret key for keycloak admin password when sane is enabled | `Default value is commented out` |
|`security.sensitiveInfoInSecret.sane.keycloak_sane_user_password` | secret key for keycloak sane user password when sane is enabled | `Default value is commented out` |
|`security.tls.secretRef.name`|Name of the secret having user supplied certificates for opensearch dashboards server certificates |`""`|
|`security.tls.secretRef.keyNames.caCrt`|Name of the secret key containing CA certificate |`null`|
|`security.tls.secretRef.keyNames.tlsKey`|Name of the secret key containing TLS key |`null`|
|`security.tls.secretRef.keyNames.tlsCrt`|Name of the secret key containing TLS server certificate |`null`|
|`security.keycloak_auth`|enable authentication required via keycloak|`false`|
|`security.istio.extCkeyLocation`|Location of ckey internal/external to the istio mesh. Accepted values: MESH_INTERNAL, MESH_EXTERNAL |`MESH_INTERNAL`|
|`security.istio.extCkeyIP`|IP to be used for DNS resolution of ckey hostname, Required only when ckey is external to istio mesh and ckey hostname is not resolvable from the cluster. |`null`|
|`security.istio.extCkeyPort`|Port on which ckey is externally accessible|`null`|
|`security.istio.extCkeyProtocol`|Protocol on which ckey is externally accessible|`null`|
|`security.istio.ckeyK8sSvcName`|FQDN of ckey k8s service name internally accessible within k8s cluster|`null`|
|`security.istio.ckeyK8sSvcPort`|Port on which ckey k8s service is accessible|`null`|
|`security.dashboards.is_ssl_verification_mode`|Controls verification of the indexsearch server certificate that Dashboards receives when contacting indexsearch|`certificate`|
|`emptyDirSizeLimit.dboPluginsVolume`|Configure the sizeLimit of dbo-plugins-volume emptyDir|`1Gi`|
|`emptyDirSizeLimit.dashboardsData`|Configure the sizeLimit of dashboards-data emptyDir|`10Mi`|
|`emptyDirSizeLimit.dashboardsLogs`|Configure the sizeLimit of dashboards-logs emptyDir|`200Mi`|
|`emptyDirSizeLimit.dashboardsEmptydirconf`|Configure the sizeLimit of dashboards-emptydirconf emptyDir|`10Mi`|
|`emptyDirSizeLimit.sharedVolume`|Configure the sizeLimit of shared-volume emptyDir|`10Mi`|

Specify parameters using `--set key=value[,key=value]` argument to `helm install`

```
helm install my-release --set istio.enabled=true <chart-path> --namespace logging
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```
helm install my-release -f values.yaml <chart-path> --version <version> --namespace logging

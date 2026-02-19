## bssc-ifd chart
BSSC is a Blueprint for Indexsearch, Fluentd , Dashboards and Indexmgr . It gives you the power of real-time data insights, with the ability to perform super-fast data extractions from virtually all structured or unstructured data sources.
IFD chart consists of below components.
-   Indexsearch : Indexsearch allows to store, search, and analyze huge volumes of data quickly in real-time and give back answers in milliseconds.
-   Fluentd : Fluentd is a data collector for unified logging layer. It allows you to unify data collection and consumption for a better use and understanding of data.
-  Dashboards : Dashboards provides search and data visualization capabilities for data indexed in Open.
-  Indexmgr : helps you curate, or manage, your Indexsearch indices and snapshots.

### Pre Requisites:

1. Kubernetes 1.12+
2. Helm 3.0-beta3+
3. PV provisioner support in the underlying infrastructure

### Installing the Chart

To install the chart with the release name `my-release` in `logging` namespace
```
helm install my-release <chart-repo> --namespace logging
```

Note: If the helm v3 client binary is named differently in the kubernetes cluster, replace "helm" with the actual name in all helm commands below. For ex. If it is named as helm3, the command would be:
```
helm3 install my-release <chart-path> --namespace logging
```

The command deploys bssc chart on the Kubernetes cluster in the default configuration. The Parameters section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list -A`

### Uninstalling the Chart:
To uninstall/delete the `my-release` deployment:
```
helm delete my-release --namespace logging
```
The command removes all the kubernetes components associated with the chart and deletes the release.

### Pod Security Standards
Helm chart can be installed in namespace with `restricted` Pod Security Standards profile only when Fluentd enable_root_privilege is false i.e, Fluentd won't be able to read container logs.

`values.yaml` parameters required to enable this case.
```yaml
bssc-fluentd:
  rbac:
    enabled: true
    psp:
      create: false

  fluentd:
    enable_root_privilege: false
    volume_mount_enable: false
    containerSecurityContext:
      runAsNonRoot: true
```
### Special cases

#### Installation with Istio-CNI disabled
In this case, Helm chart must be installed in namespace with `privileged` Pod Security Standards profile as Istio sidecar container requires the following privileges which is out of `restricted` profile.

`values.yaml` parameters required to enable this case
```yaml
global:
  istio:
    cni:
     enabled: false

bssc-fluentd:
  istio:
    enabled: true
  rbac:
    enabled: true
    psp:
      create: false

bssc-indexsearch:
  istio:
    enabled: true
  rbac:
    enabled: true
    psp:
      create: false

bssc-dashboards:
  istio:
    enabled: true
  rbac:
    enabled: true
    psp:
      create: false

bssc-indexmgr:
  istio:
    enabled: true
  rbac:
    enabled: true
    psp:
      create: false
```

With such a configuration istio sidecar containers will be injected into all pods in this helm chart. Istio sidecar container requires the following privileges, which extends `restricted` profile:
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

#### Installation with Fluentd Root Privilege Enabled 
For this case,
1. Install Indexsearch, Dashboards and IndexManager in a namespace with `restricted` Pod Security Standards profile, by configuring following `values.yaml` parameters:
```yaml
tags:
  bssc-fluentd: false
  bssc-indexsearch: true
  bssc-dashboards: true
  bssc-indexmgr: true
```

2. Install Fluentd in a different namespace with `privileged` Pod Security Standards profile as Fluentd requires 'HostPath' volume and containers run as root user which is out of `restricted` profile.

`values.yaml` parameters required to enable this case (i.e, to read container logs):
```yaml
tags:
  bssc-fluentd: true
  bssc-indexsearch: false
  bssc-dashboards: false
  bssc-indexmgr: false

bssc-fluentd:
  rbac:
    enabled: true
    psp:
      create: false
  fluentd:
    enable_root_privilege: true
    volume_mount_enable: true
```

> **Note**: Since Fluentd is installed in a different namespace make sure to configure fluentd_config to connect to indexsearch which is in the other namespace. For ex: host indexsearch.namespace_name

##### Mapping to gatekeeper constraints
1. Open source Gatekeeper `k8spsphostfilesystem` (see: [host-filesystem](https://github.com/open-policy-agent/gatekeeper-library/tree/master/library/pod-security-policy/host-filesystem)) constraint needs to be relaxed to allow the following additional privileges:
```yaml
allowedHostPaths:
- pathPrefix: /var/log
```

2. Open source Gatekeeper `k8spspallowedusers` (see: [users](https://github.com/open-policy-agent/gatekeeper-library/tree/master/library/pod-security-policy/users)) constraint needs to be relaxed to allow the following additional privileges:
```yaml
#To run fluentd container as root
runAsUser: 0
```

### Parameters:
The following table lists the configurable parameters of the BSSC charts and their default values.

| Parameter                           | Description                                   | Default                            |
| ----------------------------------- | ----------------------------------------------| ---------------------------------------------------------- |
|`global.registry`|Global Container image registry for bssc image|`csf-docker-delivered.repo.cci.nokia.net`|
|`global.flatRegistry`|Enable this flag to read image registries with a flat structure. It is disabled by default. |`false`|
|`global.enableDefaultCpuLimits`   |Enable this flag to set pod CPU resources limit for all containers. It is disabled by default. |`false`|
|`global.seccompAllowedProfileNames`|Annotation that specifies which values are allowed for the pod seccomp annotations|`docker/default`|
|`global.seccompDefaultProfileName`|Annotation that specifies the default seccomp profile to apply to containers|`docker/default`|
|`global.podNamePrefix`  | Prefix to be added for pods and jobs names       | `null` |
|`global.containerNamePrefix`  | Prefix to be added for pod containers and job container names        | `null` |
|`global.disablePodNamePrefixRestrictions` |  Enable if podNamePrefix need to be added to the pod name without any restrictions. It is disabled by default.  | `false`  |
|`global.priorityClassName`  | priorityClassName for bssc pods, set at global level  | `null` |
|`global.imagePullSecrets`  | imagePullSecrets configured at global level. | `null` |
|`global.annotations`  | Annotations configured at global level. These will be added at both pod level and the worload(statefulset/deployment/cronjob/daemonset) level.       | `null` |
|`global.labels`  | Labels configured at global level. These will be added at both pod level and the worload(statefulset/deployment/cronjob/daemonset) level.       | `null` |
|`global.istio.version`|Version of Istio available in the environment. Accepts version in string "X.Y" format. Quote is important, otherwise value is treated as a float value |`"1.7"`|
|`global.istio.cni.enabled`|Whether istio cni is enabled in the environment: true/false |`true`|
|`global.timeZoneEnv`         | To specify global timezone value              | `UTC` |
|`global.ipFamilyPolicy`      | ipFamilyPolicy for dual-stack support configured at global scope   | `null` |
|`global.ipFamilies`      | ipFamilies for dual-stack support configured at global scope   | `null` |
|`global.certManager.enabled` |Enable cert-Manager feature using this flag. It is enabled by default.|`true`|
|`global.hpa.enabled` | Enable/Disable HPA | `null(false)` |
|`global.unifiedLogging.extension` | list of extended fields that component can use to enrich the log event | `null` |
|`global.unifiedLogging.syslog.enabled`      | Enable sending logs to syslog   | `null(false)` |
|`global.unifiedLogging.syslog.facility`      | Syslog facility   | `null` |
|`global.unifiedLogging.syslog.host`      | Syslog server host name to connect to  | `null` |
|`global.unifiedLogging.syslog.port`      | Syslog server port to connect to  | `null` |
|`global.unifiedLogging.syslog.protocol`      | Protocol to connect to syslog server. Ex. TCP | `null` |
|`global.unifiedLogging.syslog.caCrt.secretName`      | Name of secret containing syslog CA certificate | `null` |
|`global.unifiedLogging.syslog.caCrt.key`      | Key in secret containing syslog CA certificate | `null` |
|`global.unifiedLogging.syslog.tls.secretRef.name`      | Name of secret containing syslog CA certificate.  It takes higher precedence over syslog.caCrt.secretName. | `null` |
|`global.unifiedLogging.syslog.tls.secretRef.keyNames.caCrt`     | Key in secret containing syslog CA certificate.  It takes higher precedence over syslog.caCrt.key. | `ca.crt` |
|`global.unifiedLogging.syslog.tls.secretRef.keyNames.tlsCrt` | Key in secret containing TLS certificate of client to syslog. | `null` |
|`global.unifiedLogging.syslog.tls.secretRef.keyNames.tlsKey` | Key in secret containing TLS key of client to syslog. | `null` |
|`global.imageFlavor`| set imageFlavor at global level |`null`|
|`global.imageFlavorPolicy`| set imageFlavorPolicy at global level. Accepted values: Strict or BestMatch |`null`|
|`tags.bssc-fluentd`|Enable/disable fluentd components of umbrella chart |`true`|
|`tags.bssc-indexsearch`|Enable/disable indexsearch components of umbrella chart |`true`|
|`tags.bssc-dashboards`|Enable/disable dashboards components of umbrella chart |`true`|
|`tags.bssc-indexmgr`|Enable/disable indexmgr components of umbrella chart |`true`|
|`bssc-fluentd.disablePodNamePrefixRestrictions` |   disablePodNamePrefixRestrictions configured at root level. It takes higher precedence over disablePodNamePrefixRestrictions configured at global level  | `false`  |
|`bssc-fluentd.fluentd.image.repo`|Fluentd image repo name. |`bssc-fluentd`|
|`bssc-fluentd.fluentd.image.flavor`| set flavor at container level for main container & init container |`null`|
|`bssc-fluentd.fluentd.image.flavorPolicy`| set flavorPolicy at container level for main container & init container. Allowed Values: Strict or BestMatch |`null`|
|`bssc-fluentd.fluentd.imageFlavor`| set imageFlavor at workload level |`null`|
|`bssc-fluentd.fluentd.imageFlavorPolicy`| set imageFlavorPolicy at workload level. Accepted values: Strict or BestMatch |`null`|
|`bssc-fluentd.fluentd.resources`| CPU/Memory resource requests/limits/ephemeral-storage for fluentd pod    |`resources:  limits:  cpu: ""(1 if enableDefaultCpuLimits is true)  memory: "1Gi" ephemeral-storage: "500Mi" requests:  cpu: "600m" memory: "500Mi" ephemeral-storage: "200Mi"`|
|`bssc-fluentd.fluentd.EnvVars.system`|Configure system name for non-container log messages|`BCMT`|
|`bssc-fluentd.fluentd.EnvVars.systemId`|Configure system id for non-container log messages|`BCMT ID`|
|`bssc-fluentd.fluentd.env`|Configure additional desired environment variables|`{}`|
|`bssc-fluentd.fluentd.enable_root_privilege`|Enable root privilege to read container, journal logs|`true`|
|`bssc-fluentd.fluentd.pdb.enabled` |  To enable/disable creation of Pod Disruption budget for fluentd pods. If kind is daemonset (default), this section is not applicable and PDB is not created. If kind is statefulset/deployment, PDB can be enabled.| `false` |
|`bssc-fluentd.fluentd.pdb.minAvailable` |  Minimum number of fluentd pods that must be available when disruption happens. Atleast 50% of the fluentd pods are recommended to be up to handle the incoming traffic. The minAvailable value can be changed based on need and incoming load. As default replica of fluentd is 1 and pdb.minAvailable is 50% when kind is configured as Deployment/statefulset, it will not allow to drain the node and service will not get interrupted. If user still wants to drain the node: option 1: If service outage is not acceptable - increase the num of replicas for fluentd so that the PDB conditions are met. option 2: If service outage is acceptable -  either disable PDB or set minAvailable to empty and maxUnavailable to 1 so that node can be drained.|`50%`|
|`bssc-fluentd.fluentd.pdb.maxUnavailable` | Maximum number for fluentd pods that can be unavailable when disruption happens |`null`|
|`bssc-fluentd.certManager.enabled` |Enable cert-Manager feature using this flag when security is enabled. It is disabled by default.It takes higher precedence over certManager.enabled at global level.|`null`|
|`bssc-fluentd.imageFlavor`| set imageFlavor at root level |`null`|
|`bssc-fluentd.imageFlavorPolicy`| set imageFlavorPolicy at root level. Allowed values : Strict or BestMatch |`null`|
|`bssc-fluentd.fluentd.kind`       |Configure fluentd kind like Deployment,DaemonSet,Statefulset          |`DaemonSet`|
|`bssc-fluentd.fluentd.replicas`       |Desired number of fluentd replicas when the kind is Deployment or Statefulset         |`1`|
|`bssc-fluentd.fluentd.priorityClassName`  |Fluentd pod priority class name. When this is set, it takes precedence over priorityClassName set at global level |`null`|
|`bssc-fluentd.fluentd.imagePullSecrets`| Fluentd imagePullSecrets configured at workload level. It takes higher precedence over imagePullSecrets configured at root or global levels  |`null`|
|`bssc-fluentd.fluentd.securityContext.enabled` | To enable/disable security context for fluentd. | `true`|
|`bssc-fluentd.fluentd.securityContext.runAsUser` | UID with which the containers will be run. Set to auto if using random userids in openshift environment. |`1000`|
|`bssc-fluentd.fluentd.securityContext.privileged`       |set privileged as true when docker_selinux is enabled on BCMT to read /var/log/messages|`false`|
|`bssc-fluentd.fluentd.securityContext.fsGroup` |Group ID for the container|`998`|
|`bssc-fluentd.fluentd.securityContext.supplementalGroups`       |SupplementalGroups ID applies to shared storage volumes          |`998`|
|`bssc-fluentd.fluentd.securityContext.seLinuxOptions`       |provision to configure selinuxoptions for fluentd container |`default value is commented`|
|`bssc-fluentd.fluentd.containerSecurityContext.runAsNonRoot` | Set this to True to run containers as a non-root user. When enable_root_privilege is set to 'true', fluentd containers will run as root user (runAsNonRoot: false) irrespective of value configured in runAsNonRoot.  |`true`|
|`bssc-fluentd.fluentd.containerSecurityContext.seccompProfile.type`| Provision to configure  seccompProfile for Fluentd containers |`RuntimeDefault`|
|`bssc-fluentd.fluentd.custom.k8sKind.annotations`       |Fluentd workload (daemonset/statefulset/deployment) specific annotations          |`{}`|
|`bssc-fluentd.fluentd.custom.k8sKind.labels`       |Fluentd workload (daemonset/statefulset/deployment) specific labels          |`{}`|
|`bssc-fluentd.fluentd.custom.pod.annotations`       |Fluentd pod specific annotations          |`{}`|
|`bssc-fluentd.fluentd.custom.pod.labels`       |Fluentd pod specific labels         |`{}`|
|`bssc-fluentd.fluentd.custom.hookJobs.job.annotations`       |Fluentd helm hook jobs specific annotations          |`{}`|
|`bssc-fluentd.fluentd.custom.hookJobs.job.labels`       |Fluentd helm hook jobs specific labels          |`{}`|
|`bssc-fluentd.fluentd.custom.hookJobs.pod.annotations`       |Fluentd helm hook & test pods specific annotations          |`{}`|
|`bssc-fluentd.fluentd.custom.hookJobs.pod.labels`       |Fluentd helm hook & test pods specific labels          |`{}`|
| `bssc-fluentd.fluentd.sensitiveInfoInSecret.enabled`             | Enable this to take sensitive data from secret             | `false`  |
| `bssc-fluentd.fluentd.sensitiveInfoInSecret.credentialName`             | Name of the pre-created secret which contains sensitive information.              | `null`  |
| `bssc-fluentd.fluentd.sensitiveInfoInSecret.secretData`             | List of all the sensitive data required in key:val format.              | `null`  |
| `bssc-fluentd.fluentd.serverCerts`             | List of server certificates supplied by user via Kubernetes Secret            | `[]` |
|`bssc-fluentd.fluentd.certManager.enabled` | Enable cert-Manager feature using this flag when security is enabled. By default, it reads same value as configured in bssc-fluentd.certManager.enabled (root level). It takes higher precedence over certManager.enabled at root and global levels|`{{ Values.certManager.enabled }} |`null`|
|`bssc-fluentd.fluentd.certManager.apiVersion` |Api version of the cert-manager.io | `cert-manager.io/v1alpha3`
|`bssc-fluentd.security.certManager.duration` |How long certificate will be valid|`8760h`
|`bssc-fluentd.security.certManager.renewBefore` |When to renew the certificate before it gets expired|`360h`
|`bssc-fluentd.fluentd.certManager.issuerRef.name` |Issuer Name | `ncms-ca-issuer`
|`bssc-fluentd.fluentd.certManager.issuerRef.kind` |CRD Name | `ClusterIssuer`
|`bssc-fluentd.fluentd.service.enabled`|Enable fluentd service|`false`|
|`bssc-fluentd.fluentd.service.custom_name`|Configure fluentd custom service name |`null`|
|`bssc-fluentd.fluentd.service.type`|Kubernetes service type|`ClusterIP`|
|`bssc-fluentd.fluentd.service.metricsPort`|fluentd-prometheus-plugin port|`24231`|
|`bssc-fluentd.fluentd.service.annotations`|fluentd service annotations|`{}`|
|`bssc-fluentd.fluentd.service.protocol`|Fluentd service protocol|`TCP`|
|`bssc-fluentd.fluentd.service.appProtocol`|Fluentd service app protocol|`tcp`|
|`bssc-fluentd.fluentd.forward_service.enabled`|Enable fluentd forward service|`false`|
|`bssc-fluentd.fluentd.forward_service.custom_name`|Configure fluentd custom forwarder service name|`null`|
|`bssc-fluentd.fluentd.forward_service.port`|Fluentd forward service port|`24224`|
|`bssc-fluentd.fluentd.forward_service.protocol`|Fluentd forward service protocol|`TCP`|
|`bssc-fluentd.fluentd.forward_service.appProtocol`|Fluentd forward service application protocol|`tcp`|
|`bssc-fluentd.fluentd.forward_service.type`|Kubernetes service type|`ClusterIP`|
|`bssc-fluentd.fluentd.forward_service.annotations`|fluentd forward service annotations|`{}`|
|`bssc-fluentd.fluentd.volume_mount_enable`|Enable volume mount for fluentd pod. When fluentd is running as non-root user disable the flag|`true`|
|`bssc-fluentd.fluentd.volumes`|Mount volume  for fluentd pods|`/var/log and /data0/docker volumes of hostpath are mounted`|
|`bssc-fluentd.fluentd.volumeMounts`|Location to mount the above volumes inside the container| `Above volumes are mounted to /var/log and /data0/docker locations inside the container`|
|`bssc-fluentd.fluentd.allowedHostPathsInPSP`|List of hostpath location to be allowed in PSP | ` /var/log and /data0/docker locations are allowed`|
|`bssc-fluentd.fluentd.nodeSelector`|Node labels for fluentd pod assignment|`{}`|
|`bssc-fluentd.fluentd.tolerations`|List of node taints to tolerate (fluentd pods)|`Toleration for NoExecute taint`|
|`bssc-fluentd.fluentd.affinity`|Fluentd pod anti-affinity policy|`{}`|
|`bssc-fluentd.fluentd.topologySpreadConstraints`|topologySpreadConstraints for fluentd |`{}`|
|`bssc-fluentd.fluentd.livenessProbe.initialDelaySeconds`|Delay before liveness probe is initiated|`30`|
|`bssc-fluentd.fluentd.livenessProbe.periodSeconds`|How often to perform the probe|`10`|
|`bssc-fluentd.fluentd.readinessProbe.initialDelaySeconds`|Delay before readiness probe is initiated|`30`|
|`bssc-fluentd.fluentd.readinessProbe.periodSeconds`|How often to perform the probe|`10`|
|`bssc-fluentd.fluentd.replicasManagedByHpa`| Depending on the value replicas will be managed by either HPA or deployment | `false` |
|`bssc-fluentd.fluentd.hpa.enabled`| Enable/Disable HorizontalPodAutoscaler. Supported only for the kind Deployment  | `null(false)` |
|`bssc-fluentd.fluentd.hpa.minReplicas` | Minimum replica count to which HPA can scale down | `1` |
|`bssc-fluentd.fluentd.hpa.maxReplicas` | Maximum replica count to which HPA can scale up | `3` |
|`bssc-fluentd.fluentd.hpa.predefinedMetrics.enabled` | Enable/Disable default memory/cpu metrics monitoring on HPA | `true` |
|`bssc-fluentd.fluentd.hpa.averageCPUThreshold` | HPA keeps the average cpu utilization of all the pods below the value set | `85` |
|`bssc-fluentd.fluentd.hpa.averageMemoryThreshold` | HPA keeps the average memory utilization of all the pods below the value set | `85` |
|`bssc-fluentd.fluentd.hpa.behavior` | Additional behavior to be set here | `empty` |
|`bssc-fluentd.fluentd.hpa.metrics` | Additional metrics to monitor can be set here | `empty` |
|`bssc-fluentd.fluentd.persistence.storageClassName`|Persistent Volume Storage Class for fluentd persistence. Applicable only when kind is StatefulSet. When configured as "" , it picks the default storage class configured in the BCMT cluster.|`null`|
|`bssc-fluentd.fluentd.persistence.accessMode`|Persistent Volume Access Modes|`ReadWriteOnce`|
|`bssc-fluentd.fluentd.persistence.size`|Persistent Volume Size|`10Gi`|
|`bssc-fluentd.fluentd.persistence.pvc_auto_delete`|Persistent Volume auto delete when chart is deleted |`false`|
|`bssc-fluentd.fluentd.unifiedLogging.enabled` | enable/disable unified logging for fluentd logs. | `true` |
|`bssc-fluentd.fluentd.unifiedLogging.imageRepo` | image repo for fluentd sidecar used in fluentd pod to convert fluentd logs into unified-logging format. | `bssc-fluentd` |
|`bssc-fluentd.fluentd.unifiedLogging.imageFlavor` | set imageFlavor for fluentd sidecar |`null`|
|`bssc-fluentd.fluentd.unifiedLogging.imageFlavorPolicy`| set imageFlavorPolicy for fluentd sidecar. Accepted values: Strict or BestMatch |`null`|
|`bssc-fluentd.fluentd.unifiedLogging.extension` | list of extended fields that component can use to enrich the log event | `null` |
|`bssc-fluentd.fluentd.unifiedLogging.syslog.enabled`      | Enable sending logs to syslog. Takes precedence over global.unifiedLogging.syslog.enabled | `null(false)` |
|`bssc-fluentd.fluentd.unifiedLogging.syslog.facility`      | Syslog facility   | `null` |
|`bssc-fluentd.fluentd.unifiedLogging.syslog.host`      | Syslog server host name to connect to  | `null` |
|`bssc-fluentd.fluentd.unifiedLogging.syslog.port`      | Syslog server port to connect to  | `null` |
|`bssc-fluentd.fluentd.unifiedLogging.syslog.protocol`      | Protocol to connect to syslog server. Ex. TCP | `null` |
|`bssc-fluentd.fluentd.unifiedLogging.syslog.caCrt.secretName`      | Name of secret containing syslog CA certificate | `null` |
|`bssc-fluentd.fluentd.unifiedLogging.syslog.caCrt.key`      | Key in secret containing syslog CA certificate | `null` |
|`bssc-fluentd.fluentd.unifiedLogging.syslog.tls.secretRef.name`      | Name of secret containing syslog CA certificate.  It takes higher precedence over syslog.caCrt.secretName. | `null` |
|`bssc-fluentd.fluentd.unifiedLogging.syslog.tls.secretRef.keyNames.caCrt`     | Key in secret containing syslog CA certificate.  It takes higher precedence over syslog.caCrt.key. | `ca.crt` |
|`bssc-fluentd.upgrade.autoMigratePV`|Due to asset name changes, fluentd PV has to be migrated to retain old data. Use this flag if upgrading from BELK 22.06. For subsequent upgrades(like update configuration) the value has to be false|`false`|
|`bssc-fluentd.fluentd.fluentd_config`|Fluentd configuration to read data. Configurable values are bssc, clog-json,clog-journal,custom-value|`bssc`|
|`bssc-fluentd.fluentd.configFile`|`If own configuration for fluentd other than provided by bssc/clog then set fluentd_config: custom-value and provide the configuration here'| `null`|
|`bssc-fluentd.fluentd.certificate.enabled` | If cert manager is enabled, certificate will be created as per it's configured in this section | `true` |
|`bssc-fluentd.fluentd.certificate.issuerRef.name`| Name of certificate issuer | `null` |
|`bssc-fluentd.fluentd.certificate.issuerRef.kind` | Kind of Issuer | `null` |
|`bssc-fluentd.fluentd.certificate.issuerRef.group` | Certificate Issuer Group Name | `null` |
|`bssc-fluentd.fluentd.certificate.duration`| How long certificate will be valid |`null` |
|`bssc-fluentd.fluentd.certificate.renewBefore` | When to renew the certificate before it gets expired |`null` |
|`bssc-fluentd.fluentd.certificate.secretName` | Name of the secret in which this cert would be added| `null` |
|`bssc-fluentd.fluentd.certificate.subject`| Certificate subject | `null`|
|`bssc-fluentd.fluentd.certificate.commonName` | CN of certificate | `null` |
|`bssc-fluentd.fluentd.certificate.usages ` | Certificate usage | `null` |
|`bssc-fluentd.fluentd.certificate.dnsNames ` | DNSNames is a list of DNS subjectAltNames to be set on the Certificate.| `null` |
|`bssc-fluentd.fluentd.certificate.uris` | URIs is a list of URI subjectAltNames to be set on the Certificate.| `null`|
|`bssc-fluentd.fluentd.certificate.ipAddresses`| IPAddresses is a list of IP address subjectAltNames to be set on the Certificate.|`null`|
|`bssc-fluentd.fluentd.certificate.privateKey.algorithm`| Algorithm is the private key algorithm of the corresponding private key for this certificate | `null`|
|`bssc-fluentd.fluentd.certificate.privateKey.encoding`| The private key cryptography standards (PKCS) encoding for this certificate’s private key | `null`|
|`bssc-fluentd.fluentd.certificate.privateKey.size`| Size is the key bit size of the corresponding private key for this certificate. | `null` |
|`bssc-fluentd.fluentd.certificate.privateKey.rotationPolicy`| Rotation of a key pair, when certificate is refreshed is recommended from a security point of view | `Always` |
|`bssc-fluentd.cbur.enabled`|Enable cbur for backup and restore operation|`true`|
|`bssc-fluentd.cbur.maxcopy`|Maxcopy of backup files to be stored|`5`|
|`bssc-fluentd.cbur.backendMode`|Configure the mode of backup. Available options are local","NETBKUP","AVAMAR","CEPHS3","AWSS3"|`local`|
|`bssc-fluentd.cbur.cronJob`|Configure cronjob timings to take backup|`0 23 * * *`|
|`bssc-fluentd.cbur.autoEnableCron`|AutoEnable Cron property to take backup as per configured cronjob|`true`|
|`bssc-fluentd.cbur.autoUpdateCron`|AutoUpdate cron to update cron job timings|`false`|
|`bssc-fluentd.istio.enabled`|Enable istio using this flag|`false`|
|`bssc-fluentd.istio.version`|Istio version specified at chart level. If defined here,it takes precedence over global level. Accepts istio version in string "X.Y" format. Ex. "1.7"|`null`|
|`bssc-fluentd.istio.cni.enabled`|Whether istio cni is enabled in the environment: true/false |`null`|
|`bssc-fluentd.istio.createDrForClient`| This optional flag should only be used when application was installed in istio-injection=enabled namespace, but was configured with istio.enabled=false, thus istio sidecar could not be injected into this application |`false`|
|`bssc-fluentd.istio.customDrSpecForClientPrometheusSvc` | This configurations will be used for configuring spec of DestinationRule  when createDrForClient flag is enabled | `mode: DISABLE`|
|`bssc-fluentd.istio.customDrSpecForClientForwarderSvc` | This configurations will be used for configuring spec of DestinationRule  when createDrForClient flag is enabled | `mode: DISABLE`|
|`bssc-fluentd.rbac.enabled`|Enable/disable rbac. When rbac.enabled is set to true, charts would create its own rbac related resources; If false, an external serviceAccountName set in values will be used. |`true`|
|`bssc-fluentd.rbac.psp.create`    | If set to true, then chart creates its own PSPs only if required; If set to false, then chart do not create PSPs.  | `true` |
|`bssc-fluentd.rbac.psp.annotations`  | Annotation to be set when 'fluentd.containerSecurityContext.seccompProfile.type' is configured or if required only | `seccomp.security.alpha.kubernetes.io/allowedProfileNames: '*'` |
|`bssc-fluentd.rbac.scc.create`    | If set to true, then chart creates its own SCCs only if required; If set to false, then chart do not create SCCs.  | `false` |
|`bssc-fluentd.rbac.scc.annotations`    | To set annotations for SCCs only if required;   | `null` |
|`bssc-fluentd.serviceAccountName`| Pre-created ServiceAccount specifically for fluentd chart.                    | `null` |
|`bssc-fluentd.customResourceNames.resourceNameLimit`         | Character limit for resource names to be truncated                    | `63` |
|`bssc-fluentd.customResourceNames.fluentdPod.fluentdContainerName`         | Name for fluentd pod's container                    | `null` |
|`bssc-fluentd.customResourceNames.fluentdPod.fluentdInitContainerName`         | Name for fluentd pod's init container                    | `null` |
|`bssc-fluentd.customResourceNames.fluentdPod.unifiedLoggingContainerName`         | Name for fluentd pod's unified logging container                    | `null` |
|`bssc-fluentd.customResourceNames.scaleinJob.name`         | Name for fluentd scalein job                    | `null` |
|`bssc-fluentd.customResourceNames.scaleinJob.postscaleinContainerName`         | Name for fluentd scalein job's container                   | `null` |
|`bssc-fluentd.customResourceNames.deletePvcJob.name`         | Name for fluentd delete PVC job                    | `null` |
|`bssc-fluentd.customResourceNames.deletePvcJob.deletePvcContainerName`         | Name for fluentd delete pvc job's container                   | `null` |
|`bssc-fluentd.customResourceNames.helmTestPod.name`         | Name for fluentd helm test pod                    | `null` |
|`bssc-fluentd.customResourceNames.helmTestPod.helmTestContainerName`         | Name for fluentd helm test pod's container                   | `null` |
|`bssc-fluentd.customResourceNames.deleteJob.name` | Name for fluentd delete job | `null`|
|`bssc-fluentd.customResourceNames.deleteJob.deleteJobContainerName` | Name for fluentd delete job's container | `null`|
|`bssc-fluentd.customResourceNames.preUpgradePvMigrateJob.name` | Name for fluentd preUpgradePvMigrate job | `null`|
|`bssc-fluentd.customResourceNames.preUpgradePvMigrateJob.preUpgradePvMigrateContainerName` | Name for fluentd preUpgradePvMigrate job's container | `null`|
|`bssc-fluentd.nameOverride`         | Use this to override name for fluentd deployment/sts/deamonset kubernetes object. When it is set, the name would be ReleaseName-nameOverride                 | `null` |
|`bssc-fluentd.fullnameOverride`         | Use this to configure custom-name for fluentd deployment/sts/deamonset kubernetes object.  If both nameOverride and fullnameOverride are specified, fullnameOverride would take the precedence.                  | `null` |
|`bssc-fluentd.enableDefaultCpuLimits`   |Enable this flag to set pod CPU resources limit for all fluentd containers. It has no value set by default. |`null`|
|`bssc-fluentd.partOf` | Use this to configure common lables for k8s objects. Set to configure label app.kubernetes.io/part-of: | `bssc-ifd` |
|`bssc-fluentd.timezone.timeZoneEnv`         | To specify timezone value and this will have higer precedence over global.timeZoneEnv              | `null` |
|`bssc-fluentd.jobs.affinity`|To provide affinity for jobs and helm test pods |`null`|
|`bssc-fluentd.jobs.nodeSelector`|To provide nodeSelector for jobs and helm test pods |`null`|
|`bssc-fluentd.jobs.tolerations`|To provide tolerations for jobs and helm test pods |`null`|
|`bssc-fluentd.imagePullSecrets`| Fluentd imagePullSecrets configured at root level. It takes higher precedence over imagePullSecrets configured at global level |`null`|
|`bssc-fluentd.ipFamilyPolicy`|ipFamilyPolicy for dual-stack support configured at fluentd level. Allowed values: SingleStack, PreferDualStack,RequireDualStack |`null`|
|`bssc-fluentd.ipFamilies`|ipFamilies for dual-stack support configured at fluentd level. Allowed values: ["IPv4"], ["IPv6"], ["IPv4","IPv6"], ["IPv6","IPv4"]  |`null`|
|`bssc-fluentd.emptyDirSizeLimit.tmp`|Configure the sizeLimit of tmp emptyDir| `500Mi`|
|`bssc-fluentd.emptyDirSizeLimit.sensitiveConfig`|Configure the sizeLimit of sensitive-config emptyDir| `10Mi`|
|`bssc-fluentd.emptyDirSizeLimit.sharedVolume`|Configure the sizeLimit of shared-volume emptyDir| `10Mi`|
|`bssc-indexsearch.disablePodNamePrefixRestrictions` |   disablePodNamePrefixRestrictions configured at root level. It takes higher precedence over disablePodNamePrefixRestrictions configured at global level. Default value is set to true in indexsearch to avoid breaking upgrades.  | `true`  |
|`bssc-indexsearch.imageFlavor`| set imageFlavor at root level |`null`|
|`bssc-indexsearch.imageFlavorPolicy`| set imageFlavorPolicy at root level. Allowed Values: Strict or BestMatch |`null`|
|`bssc-indexsearch.manager.image.repo`|Indexsearch image repo name. |`bssc-indexsearch`|
|`bssc-indexsearch.manager.image.flavor`| set imageFlavor for indexsearch container in all manager,data and client pods |`null`|
|`bssc-indexsearch.manager.image.flavorPolicy`| set imageFlavorPolicy for indexsearch container in all manager,data and client pods. Allowed Values: Strict or BestMatch |`null`|
|`bssc-indexsearch.manager.imageFlavor`| set imageFlavor at workload level |`null`|
|`bssc-indexsearch.manager.imageFlavorPolicy`| set imageFlavorPolicy at workload level. Accepted values: Strict or BestMatch |`null`|
|`bssc-indexsearch.manager.replica`|Desired number of indexsearch manager node replicas|`3`|
|`bssc-indexsearch.manager.resources`| CPU/Memory resource requests/limits/ephemeral-storage for manager pod    |`limits:       cpu: ""(1 if enableDefaultCpuLimits is true)   memory: "2Gi" ephemeral-storage: "500Mi"    requests:       cpu: "500m"       memory: "1.5Gi" ephemeral-storage: "200Mi"`|
|`bssc-indexsearch.manager.java_opts`|Environment variable for setting up JVM options|` Xms1g  Xmx1g`|
|`bssc-indexsearch.manager.podAntiAffinity.ruleDefinition`|Manager pod anti-affinity policy|`soft`|
|`bssc-indexsearch.manager.podAntiAffinity.customDefinition`|Manager pod anti-affinity policy (custom rule)|`{}`|
|`bssc-indexsearch.manager.podAffinity`|Manager pod affinity (in addition to manager.antiAffinity when set)|`{}`|
|`bssc-indexsearch.manager.nodeAffinity`|Manager node affinity (in addition to manager.antiAffinity when set)|`{}`|
|`bssc-indexsearch.manager.nodeSelector`|manager node labels for pod assignment|`{}`|
|`bssc-indexsearch.manager.tolerations`|List of node taints to tolerate for (manager)|`[]`|
|`bssc-indexsearch.manager.topologySpreadConstraints`|topologySpreadConstraints for manager |`{}`|
|`bssc-indexsearch.manager.livenessProbe.initialDelaySeconds`|Delay before liveness probe is initiated (manager)|`30`|
|`bssc-indexsearch.manager.livenessProbe.periodSeconds`|How often to perform the probe (manager)|`10`|
|`bssc-indexsearch.manager.readinessProbe.initialDelaySeconds`|Delay before readiness probe is initiated (manager)|`30`|
|`bssc-indexsearch.manager.readinessProbe.periodSeconds`|How often to perform the probe (manager)|`10`|
|`bssc-indexsearch.manager.pdb.enabled` | To enable Pod Disruption budget for indexsearch manager pods | `true` |
|`bssc-indexsearch.manager.pdb.minAvailable` | Minimum number of indexsearch manager pods must still be available when disruption happens |  `null` |
|`bssc-indexsearch.manager.pdb.maxUnavailable` | Maximum number for indexsearch manager pods that can be unavailable when disruption happens. If num of replicas of manager pods is n, there should be minumum (n/2 +1) manager pods always up in the cluster for indexsearch to work properly so, set the maxUnavailable value accordingly. As the default num of replica for manager pods is 3, maxUnavailable is set to 1 by default which ensures n/2+1 condition is met. |  `1` |
|`bssc-indexsearch.manager.podManagementPolicy`|Manager statefulset parallel pod management policy |`Parallel`|
|`bssc-indexsearch.manager.updateStrategy.type`|Manager statefulset update strategy policy|`RollingUpdate`|
|`bssc-indexsearch.manager.priorityClassName`  |Indexsearch manager pod priority class name. When this is set, it takes precedence over priorityClassName set at global level |`null`|
|`bssc-indexsearch.manager.hostAliases` | Additional dns entries can be added to pod's /etc/hosts for dns resolution by configuring hostaliases for indexsearch manager pods | `null`|
|`bssc-indexsearch.client.updateStrategy.type`|Client deployment update strategy policy|`RollingUpdate`|
|`bssc-indexsearch.client.replicas`|Desired number of indexsearch client node replicas|`3`|
|`bssc-indexsearch.client.resources`|  CPU/Memory resource requests/limits/ephemeral-storage for client pod   |`limits:       cpu: ""(1 if enableDefaultCpuLimits is true)       memory: "4Gi"  ephemeral-storage: "500Mi"   requests:       cpu: "500m"   memory: "3Gi" ephemeral-storage: "200Mi"`|
|`bssc-indexsearch.client.java_opts`|Environment variable for setting up JVM options|` Xms2g  Xmx2g`|
|`bssc-indexsearch.client.podAntiAffinity.ruleDefinition`|Client pod anti-affinity policy|`soft`|
|`bssc-indexsearch.client.podAntiAffinity.customDefinition`|Client pod anti-affinity policy (custom rule)|`{}`|
|`bssc-indexsearch.client.podAffinity`|Client pod affinity (in addition to client.antiAffinity when set)|`{}`|
|`bssc-indexsearch.client.nodeAffinity`|Client node affinity (in addition to client.antiAffinity when set)|`{}`|
|`bssc-indexsearch.client.nodeSelector`|Client node labels for pod assignment|`{}`|
|`bssc-indexsearch.client.tolerations`|List of node taints to tolerate for (client)|`[]`|
|`bssc-indexsearch.client.topologySpreadConstraints`|topologySpreadConstraints for client |`{}`|
|`bssc-indexsearch.client.livenessProbe.initialDelaySeconds`|Delay before liveness probe is initiated (client)|`90`|
|`bssc-indexsearch.client.livenessProbe.periodSeconds`|How often to perform the probe (client)|`20`|
|`bssc-indexsearch.client.readinessProbe.initialDelaySeconds`|Delay before readiness probe is initiated (client)|`90`|
|`bssc-indexsearch.client.readinessProbe.periodSeconds`|How often to perform the probe (client)|`20`|
|`bssc-indexsearch.client.replicasManagedByHpa`| Depending on the value replicas will be managed by either HPA or deployment | `false` |
|`bssc-indexsearch.client.hpa.enabled`| Enable/Disable HorizontalPodAutoscaler | `null(false)`|
|`bssc-indexsearch.client.hpa.minReplicas` | Minimum replica count to which HPA can scale down | `3` |
|`bssc-indexsearch.client.hpa.maxReplicas` | Maximum replica count to which HPA can scale up | `5` |
|`bssc-indexsearch.client.hpa.predefinedMetrics.enabled` | Enable/Disable default memory/cpu metrics monitoring on HPA | `true` |
|`bssc-indexsearch.client.hpa.averageCPUThreshold` | HPA keeps the average cpu utilization of all the pods below the value set | `85` |
|`bssc-indexsearch.client.hpa.averageMemoryThreshold` | HPA keeps the average memory utilization of all the pods below the value set | `85` |
|`bssc-indexsearch.client.hpa.behavior` | Additional behavior to be set here | `empty` |
|`bssc-indexsearch.client.hpa.metrics` | Additional metrics to monitor can be set here | `empty` |
|`bssc-indexsearch.client.pdb.enabled` | To enable Pod Disruption budget for indexsearch client pods | `true` |
|`bssc-indexsearch.client.pdb.minAvailable` | Minimum number of client pods must still be available when disruption happens. Atleast 50% of the client pods are recommended to be up to handle the incoming traffic towards indexsearch. The minAvailable value can be changed based on need and incoming load. As the default num of client pods is 3, having minAvailable as 50% will ensure atleast 2 pods are always running for the incoming load. |  `50%` |
|`bssc-indexsearch.client.pdb.maxUnavailable` | Maximum number for os client pods that can be unavailable when disruption happens |  `null` |
|`bssc-indexsearch.client.hostAliases` | Additional dns entries can be added to pod's /etc/hosts for dns resolution by configuring hostaliases for indexsearch client pods | `null`|
|`bssc-indexsearch.client.priorityClassName`  |Indexsearch client pod priority class name. When this is set, it takes precedence over priorityClassName set at global level |`null`|
|`bssc-indexsearch.data.replicas`|Desired number of indexsearch data node replicas|`2`|
|`bssc-indexsearch.data.resources`| CPU/Memory resource requests/limits/ephemeral-storage for data pod  |`limits:       cpu: ""(1 if enableDefaultCpuLimits is true)       memory: "4Gi"  ephemeral-storage: "500Mi"    requests:       cpu: "500m"       memory: "3Gi" ephemeral-storage: "200Mi"`|
|`bssc-indexsearch.data.java_opts`|Environment variable for setting up JVM options|` Xms2g  Xmx2g`|
|`bssc-indexsearch.data.podManagementPolicy`|Data statefulset parallel pod management policy |`Parallel`|
|`bssc-indexsearch.data.updateStrategy.type`|Data statefulset update strategy policy|`RollingUpdate`|
|`bssc-indexsearch.data.podAntiAffinity.ruleDefinition`|Data pod anti-affinity policy|`soft`|
|`bssc-indexsearch.data.podAntiAffinity.customDefinition`|Data pod anti-affinity policy (custom rule)|`{}`|
|`bssc-indexsearch.data.podAffinity`|Data pod affinity (in addition to data.antiAffinity when set)|`{}`|
|`bssc-indexsearch.data.nodeAffinity`|Data node affinity (in addition to data.antiAffinity when set)|`{}`|
|`bssc-indexsearch.data.nodeSelector`|Data node labels for pod assignment|`{}`|
|`bssc-indexsearch.data.tolerations`|List of node taints to tolerate for (data)|`[]`|
|`bssc-indexsearch.data.topologySpreadConstraints`|topologySpreadConstraints for data |`{}`|
|`bssc-indexsearch.data.livenessProbe.initialDelaySeconds`|Delay before liveness probe is initiated (data)|`30`|
|`bssc-indexsearch.data.livenessProbe.periodSeconds`|How often to perform the probe (data)|`10`|
|`bssc-indexsearch.data.readinessProbe.initialDelaySeconds`|Delay before readiness probe is initiated (data)|`30`|
|`bssc-indexsearch.data.readinessProbe.periodSeconds`|How often to perform the probe (data)|`10`|
|`bssc-indexsearch.data.pdb.enabled` | To enable Pod Disruption budget for indexsearch data pods | `true` |
|`bssc-indexsearch.data.pdb.minAvailable` | Minimum number of data pods must still be available when disruption happens |  `null` |
|`bssc-indexsearch.data.pdb.maxUnavailable` | Maximum number for data pods that can be unavailable when disruption happens. Default indexsearch shard replication is 1, so primary and replica shards will be distributed across any two data pods. If more than 1 data pod goes down, it can lead to data loss. So maxUnavailable value should be 1 unless the indexsearch shard replication has been increased. Its recommended to atleast have two data pods (to ensure green cluster health) up and running, but if the num of replica for data pods has been reduced to 1, the value of maxUnavailable should be empty and value of minAvailable needs to be set to 1 because the default value of maxUnavailable i.e. 1 will drain the node and this would lead to data loss. |  `1` |
|`bssc-indexsearch.data.priorityClassName` |Indexsearch data pod priority class name. When this is set, it takes precedence over priorityClassName set at global level |`null`|
|`bssc-indexsearch.data.hostAliases` | Additional dns entries can be added to pod's /etc/hosts for dns resolution by configuring hostaliases for indexsearch data pods | `null`|
|`bssc-indexsearch.indexsearch.externalClientCertificates.dashboards.certificate.enabled` | If clientcert_auth_domain is enabled and cert manager is enabled, certificate will be created as per it's configured in this section | `false` |
|`bssc-indexsearch.indexsearch.externalClientCertificates.dashboards.certificate.issuerRef.name`| Name of certificate issuer   | `ncms-ca-issuer` |
|`bssc-indexsearch.indexsearch.externalClientCertificates.dashboards.certificate.secretName` | Name of dashboards client certificate which is used for authorization of dashboards backend server with opensearch | `{{ .Release.Name }}-bssc-ifd-cert-for-dashboards` |
|`bssc-indexsearch.indexsearch.externalClientCertificates.dashboards.certificate.issuerRef.kind` | Kind of Issuer | `ClusterIssuer` | 
|`bssc-indexsearch.indexsearch.externalClientCertificates.dashboards.certificate.issuerRef.group` | Certificate Issuer Group Name | `cert-manager.io` | 
|`bssc-indexsearch.indexsearch.externalClientCertificates.dashboards.certificate.duration`| How long certificate will be valid|`8760h` |
|`bssc-indexsearch.indexsearch.externalClientCertificates.dashboards.certificate.renewBefore` |When to renew the certificate before it gets expired|`360h` |
|`bssc-indexsearch.indexsearch.externalClientCertificates.dashboards.certificate.subject`| Certificate subject | `null`|
|`bssc-indexsearch.indexsearch.externalClientCertificates.dashboards.certificate.commonName` | CN of certificate | `dashboards` |
|`bssc-indexsearch.indexsearch.externalClientCertificates.dashboards.certificate.usages ` | Certificate usage | `client auth` |
|`bssc-indexsearch.indexsearch.externalClientCertificates.dashboards.certificate.dnsNames ` | DNSNames is a list of DNS subjectAltNames to be set on the Certificate. If ssl passthrough is used on the Ingress object, then dnsNames should be set to external DNS names. | `null` |
|`bssc-indexsearch.indexsearch.externalClientCertificates.dashboards.certificate.uris` | URIs is a list of URI subjectAltNames to be set on the Certificate. | `null`|
|`bssc-indexsearch.indexsearch.externalClientCertificates.dashboards.certificate.ipAddresses`| IPAddresses is a list of IP address subjectAltNames to be set on the Certificate. | `null` |
|`bssc-indexsearch.indexsearch.externalClientCertificates.dashboards.certificate.privateKey.algorithm`| Algorithm is the private key algorithm of the corresponding private key for this certificate. | `null`|
|`bssc-indexsearch.indexsearch.externalClientCertificates.dashboards.certificate.privateKey.encoding`| The private key cryptography standards (PKCS) encoding for this certificate’s private key to be encoded in. | `null`|
|`bssc-indexsearch.indexsearch.externalClientCertificates.dashboards.certificate.privateKey.size`| Size is the key bit size of the corresponding private key for this certificate. | `null` |
|`bssc-indexsearch.indexsearch.externalClientCertificates.dashboards.certificate.privateKey.rotationPolicy`| Rotation of a key pair, when certificate is refreshed is recommended from a security point of view | `Always` |
|`bssc-indexsearch.indexsearch.adminCrt.certificate.enabled` | If cert manager is enabled, certificate will be created as per it's configured in this section | `true` |
|`bssc-indexsearch.indexsearch.adminCrt.certificate.issuerRef.name`| Name of certificate issuer   | `null`|
|`bssc-indexsearch.indexsearch.adminCrt.certificate.issuerRef.kind` | Kind of Issuer | `null` |
|`bssc-indexsearch.indexsearch.adminCrt.certificate.issuerRef.group` | Certificate Issuer Group Name | `null` |
|`bssc-indexsearch.indexsearch.adminCrt.certificate.duration`| How long certificate will be valid| `null` |
|`bssc-indexsearch.indexsearch.adminCrt.certificate.renewBefore` |When to renew the certificate before it gets expired| `null` |
|`bssc-indexsearch.indexsearch.adminCrt.certificate.secretName` | Name of the secret in which this cert would be added | `null` |
|`bssc-indexsearch.indexsearch.adminCrt.certificate.subject`| Certificate subject | `null` |
|`bssc-indexsearch.indexsearch.adminCrt.certificate.commonName` | CN of certificate | `null` |
|`bssc-indexsearch.indexsearch.adminCrt.certificate.usages ` | Certificate usage | `null` |
|`bssc-indexsearch.indexsearch.adminCrt.certificate.dnsNames ` | DNSNames is a list of DNS subjectAltNames to be set on the Certificate. | `null` |
|`bssc-indexsearch.indexsearch.adminCrt.certificate.uris` | URIs is a list of URI subjectAltNames to be set on the Certificate. | `null`  |
|`bssc-indexsearch.indexsearch.adminCrt.certificate.ipAddresses`| IPAddresses is a list of IP address subjectAltNames to be set on the Certificate. | `null` |
|`bssc-indexsearch.indexsearch.adminCrt.certificate.privateKey.algorithm`| Algorithm is the private key algorithm of the corresponding private key for this certificate. | `null`  |
|`bssc-indexsearch.indexsearch.adminCrt.certificate.privateKey.encoding`| The private key cryptography standards (PKCS) encoding for this certificate’s private key to be encoded in. | `null`  |
|`bssc-indexsearch.indexsearch.adminCrt.certificate.privateKey.size`| Size is the key bit size of the corresponding private key for this certificate. | `null` |
|`bssc-indexsearch.indexsearch.adminCrt.certificate.privateKey.rotationPolicy`| Rotation of a key pair, when certificate is refreshed is recommended from a security point of view | `Always` |
|`bssc-indexsearch.indexsearch.nodeCrt.certificate.enabled` | If cert manager is enabled, node certificate will be created as per it's configured in this section | `true` |
|`bssc-indexsearch.indexsearch.nodeCrt.certificate.issuerRef.name`| Name of certificate issuer | `null` |
|`bssc-indexsearch.indexsearch.nodeCrt.certificate.issuerRef.kind` | Kind of Issuer | `null` |
|`bssc-indexsearch.indexsearch.nodeCrt.certificate.issuerRef.group` | Certificate Issuer Group Name | `null`|
|`bssc-indexsearch.indexsearch.nodeCrt.certificate.duration`| How long certificate will be valid | `null` |
|`bssc-indexsearch.indexsearch.nodeCrt.certificate.renewBefore` | When to renew the certificate before it gets expired | `null`|
|`bssc-indexsearch.indexsearch.nodeCrt.certificate.secretName` | Name of the secret in which this cert would be added| `null` |
|`bssc-indexsearch.indexsearch.nodeCrt.certificate.subject`| Certificate subject | `null`|
|`bssc-indexsearch.indexsearch.nodeCrt.certificate.commonName` | CN of certificate | `null`|
|`bssc-indexsearch.indexsearch.nodeCrt.certificate.usages ` | Certificate usage | `null`|
|`bssc-indexsearch.indexsearch.nodeCrt.certificate.dnsNames ` | DNSNames is a list of DNS subjectAltNames to be set on the Certificate.| `null`|
|`bssc-indexsearch.indexsearch.nodeCrt.certificate.uris` | URIs is a list of URI subjectAltNames to be set on the Certificate.| `null`|
|`bssc-indexsearch.indexsearch.nodeCrt.certificate.ipAddresses`| IPAddresses is a list of IP address subjectAltNames to be set on the Certificate.| `null`|
|`bssc-indexsearch.indexsearch.nodeCrt.certificate.privateKey.algorithm`| Algorithm is the private key algorithm of the corresponding private key for this certificate| `null`|
|`bssc-indexsearch.indexsearch.nodeCrt.certificate.privateKey.encoding`| The private key cryptography standards (PKCS) encoding for this certificate’s private key | `null`|
|`bssc-indexsearch.indexsearch.nodeCrt.certificate.privateKey.size`| Size is the key bit size of the corresponding private key for this certificate. | `null`|
|`bssc-indexsearch.indexsearch.nodeCrt.certificate.privateKey.rotationPolicy`| Rotation of a key pair, when certificate is refreshed is recommended from a security point of view | `Always`|
|`bssc-indexsearch.crossClusterReplication.leader.enabled`|Enable Leader cluster for CCR|`null`|
|`bssc-indexsearch.crossClusterReplication.leader.followerDNs`|DNs of certitificates of the follower cluster for the leader to trust|`null`|
|`bssc-indexsearch.crossClusterReplication.leader.ingressTcpConfigmap.enabled`|Enable TCP port to be exposed outside via CITM Ingress tcp-services-configmap|`false`|
|`bssc-indexsearch.crossClusterReplication.leader.ingressTcpConfigmap.tcpServicesConfigmapName`|Name of the tcp-services-configmap prefix used by the CITM ingress Chart.|`null`|
|`bssc-indexsearch.crossClusterReplication.leader.ingressTcpConfigmap.ingressTcpPort`|port number that will be exposed for the TCP service of indexsearch by CITM Ingress|`9300`|
|`bssc-indexsearch.crossClusterReplication.follower.enabled`|Enable Follower cluster for CCR|`null`|
|`bssc-indexsearch.crossClusterReplication.follower.connectionName`|Name of the cross-cluster-replication connection|`null`|
|`bssc-indexsearch.crossClusterReplication.follower.replicateIndices`|Configure the replication rule name and indexPattern|`null`|
|`bssc-indexsearch.crossClusterReplication.follower.leaderURL`|Set the proxy Address which contains the IP/DNS and the port of the leader cluster|`null`|
|`bssc-indexsearch.restApi.enabled`|Enable the flag to provide rest API commands to be run for the helm release|`false`|
|`bssc-indexsearch.restApi.restApiArguments`|Configure all the REST API commands to be run by the helm release|`false`|
|`bssc-indexsearch.rbac.enabled`|Enable/disable rbac. When rbac.enabled is set to true, charts would create its own rbac related resources; If false, an external serviceAccountName set in values will be used. |`true`|
|`bssc-indexsearch.rbac.psp.create`    | If set to true, then chart creates its own PSPs only if required; If set to false, then chart do not create  PSPs.  | `false` |
|`bssc-indexsearch.rbac.psp.annotations`  | Annotation to be set when Indexsearch 'containerSecurityContext.seccompProfile.type' is configured or if required only | `seccomp.security.alpha.kubernetes.io/allowedProfileNames: '*'` |
|`bssc-indexsearch.rbac.scc.create`    | If set to true, then chart creates its own SCCs only if required; If set to false, then chart do not create  SCCs.  | `false` |
|`bssc-indexsearch.rbac.scc.annotations`    | To set annotations for SCCs only if required;   | `null` |
|`bssc-indexsearch.serviceAccountName`|Pre-created ServiceAccount specifically for indexsearch chart.|`null`|
|`bssc-indexsearch.unifiedLogging.extension` | list of extended fields that component can use to enrich the log event | `null` |
|`bssc-indexsearch.unifiedLogging.syslog.enabled`      | Enable sending logs to syslog. Takes precedence over global.unifiedLogging.syslog.enabled | `null(false)` |
|`bssc-indexsearch.unifiedLogging.syslog.sendLogsViaLog4j` | Set sendLogsViaLog4j to true if sending logs to syslog using log4j. If this flag is enabled, additional fluentd sidecar for unified logging will not be injected. | `true`|
|`bssc-indexsearch.unifiedLogging.syslog.facility`      | Syslog facility   | `null` |
|`bssc-indexsearch.unifiedLogging.syslog.host`      | Syslog server host name to connect to  | `null` |
|`bssc-indexsearch.unifiedLogging.syslog.port`      | Syslog server port to connect to  | `null` |
|`bssc-indexsearch.unifiedLogging.syslog.protocol`      | Protocol to connect to syslog server. Ex. TCP | `null` |
|`bssc-indexsearch.unifiedLogging.syslog.caCrt.secretName`      | Name of secret containing syslog CA certificate | `null` |
|`bssc-indexsearch.unifiedLogging.syslog.caCrt.key`      | Key in secret containing syslog CA certificate | `null` |
|`bssc-indexsearch.unifiedLogging.syslog.tls.secretRef.name`      | Name of secret containing syslog CA certificate.  It takes higher precedence over syslog.caCrt.secretName. | `null` |
|`bssc-indexsearch.unifiedLogging.syslog.tls.secretRef.keyNames.caCrt`     | Key in secret containing syslog CA certificate.  It takes higher precedence over syslog.caCrt.key. | `ca.crt` |
|`bssc-indexsearch.unifiedLogging.syslog.tls.secretRef.keyNames.tlsCrt` | Key in secret containing TLS certificate of client to syslog. | `null` |
|`bssc-indexsearch.unifiedLogging.syslog.tls.secretRef.keyNames.tlsKey` | Key in secret containing TLS key of client to syslog. | `null` |
|`bssc-indexsearch.unifiedLogging.imageRepo` | image repo for fluentd sidecar used in indexsearch pod to send logs to syslog server. | `bssc-fluentd` |
|`bssc-indexsearch.unifiedLogging.imageFlavor`| set imageFlavor at container level for fluentd sidecar |`null`|
|`bssc-indexsearch.unifiedLogging.imageFlavorPolicy`| set imageFlavorPolicy at container level for fluentd sidecar. Accepted Values: Strict or BestMatch |`null`|
|`bssc-indexsearch.customResourceNames.resourceNameLimit`         | Character limit for resource names to be truncated                    | `63` |
|`bssc-indexsearch.customResourceNames.managerPod.managerContainerName`         | Name for indexsearch manager pod's container                    | `null` |
|`bssc-indexsearch.customResourceNames.dataPod.dataContainerName`         | Name for indexsearch data pod's container                    | `null` |
|`bssc-indexsearch.customResourceNames.clientPod.clientContainerName`         | Name for indexsearch client pod's container                    | `null` |
|`bssc-indexsearch.customResourceNames.initContainerName` | Name for indexsearch init container | `null`|
|`bssc-indexsearch.customResourceNames.unifiedLoggingContainerName` | Name for indexsearch's unified logging container | `null`|
|`bssc-indexsearch.customResourceNames.postScaleInJob.name`         | Name for is post-scalein job                    | `null` |
|`bssc-indexsearch.customResourceNames.postScaleInJob.postScaleInContainerName`         | Name for is post-scalein job's container                   | `null` |
|`bssc-indexsearch.customResourceNames.preUpgradeSecJob.name`         | Name for is pre-upgradeSecurity job                    | `null` |
|`bssc-indexsearch.customResourceNames.preUpgradeSecJob.preUpgradeSecContainerName`         | Name for is pre-upgradeSecurity job's container                   | `null` |
|`bssc-indexsearch.customResourceNames.upgradeJob.name`         | Name for is upgrade job                    | `null` |
|`bssc-indexsearch.customResourceNames.upgradeJob.upgradeContainerName`         | Name for is upgrade job's container                   | `null` |
|`bssc-indexsearch.customResourceNames.preRollbackJob.name`         | Name for is pre-rollback job                    | `null` |
|`bssc-indexsearch.customResourceNames.preRollbackJob.preRollbackContainerName`         | Name for is pre-rollback job's container                   | `null` |
|`bssc-indexsearch.customResourceNames.preHealJob.name`         | Name for is pre-heal job                    | `null` |
|`bssc-indexsearch.customResourceNames.preHealJob.preHealContainerName`         | Name for is pre-heal job's container                   | `null` |
|`bssc-indexsearch.customResourceNames.postDeleteCleanupJob.name`         | Name for is post-deleteCleanup job                    | `null` |
|`bssc-indexsearch.customResourceNames.postDeleteCleanupJob.postDeleteCleanupContainerName`         | Name for is post-deleteCleanup job's container                   | `null` |
|`bssc-indexsearch.customResourceNames.postDeletePvcJob.name`         | Name for is post-deletePvc job                    | `null` |
|`bssc-indexsearch.customResourceNames.postDeletePvcJob.postDeletePvcContainerName`         | Name for is post-deletePvc job's container                   | `null` |
|`bssc-indexsearch.customResourceNames.helmTestPod.name`         | Name for indexsearch helm test pod                    | `null` |
|`bssc-indexsearch.customResourceNames.helmTestPod.helmTestContainerName`         | Name for indexsearch helm test pod's container                   | `null` |
|`bssc-indexsearch.customResourceNames.helmTestPostApiPod.name` | Name for helm test post-setup-api job pod                    | `null` |
|`bssc-indexsearch.customResourceNames.helmTestPostApiPod.helmTestPostApiContainerName` | Name for helm test post-setup-api job pod's container                   | `null` |
|`bssc-indexsearch.customResourceNames.secAdminJob.name` | Name of job which runs security admin script during install/rollback operations | `null` |
|`bssc-indexsearch.customResourceNames.secAdminJob.secAdminContainerName` | Name of job's container which runs security admin script during install/rollback operations | `null` |
|`bssc-indexsearch.customResourceNames.preUpgradePvMigrateJob.name`         | Name for is pre-upgrade Pv Migrate job                    | `null` |
|`bssc-indexsearch.customResourceNames.preUpgradePvMigrateJob.preUpgradePvMigrateContainerName`         | Name for is pre-upgrade Pv Migrate job's container                   | `null` |
|`bssc-indexsearch.nameOverride`         | Use this to override name for indexsearch deployment/sts kubernetes object. When it is set, the name would be ReleaseName-nameOverride                 | `null` |
|`bssc-indexsearch.fullnameOverride`         | Use this to configure custom-name for indexsearch deployment/sts kubernetes object.  If both nameOverride and fullnameOverride are specified, fullnameOverride would take the precedence. | `null` |
|`bssc-indexsearch.enableDefaultCpuLimits`   |Enable this flag to set pod CPU resources limit for all indexsearch containers. It has no value set by default. |`null`|
|`bssc-indexsearch.partOf` | Use this to configure common lables for k8s objects. Set to configure label app.kubernetes.io/part-of: | `bssc-ifd` |
|`bssc-indexsearch.timezone.timeZoneEnv`         | To specify timezone value and this will have higer precedence over global.timeZoneEnv              | `null` |
|`bssc-indexsearch.jobs.affinity`|To provide affinity for jobs and helm test pods |`null`|
|`bssc-indexsearch.jobs.nodeSelector`|To provide nodeSelector for jobs and helm test pods |`null`|
|`bssc-indexsearch.jobs.tolerations`|To provide tolerations for jobs and helm test pods |`null`|
|`bssc-indexsearch.imagePullSecrets`| Indexsearch imagePullSecrets configured at root level. It takes higher precedence over imagePullSecrets configured at global level |`null`|
|`bssc-indexsearch.env`| Additional environmental variables to be added to all indexsearch pods |`null`|
|`bssc-indexsearch.securityContext.enabled`|To configure parameters under securityContext for pods and containers. If set to false, securityContext will be set as {}|`true`|
|`bssc-indexsearch.securityContext.runAsUser`|UID with which the containers will be run. Set to auto if using random userids in openshift environment. |`1000`|
|`bssc-indexsearch.securityContext.fsGroup`|Group ID assigned for the volumemounts mounted to the pod|`1000`|
|`bssc-indexsearch.securityContext.supplementalGroups`|SupplementalGroups ID applies to shared storage volumes|`default value is commented out`|
|`bssc-indexsearch.securityContext.seLinuxOptions`|provision to configure selinuxoptions for indexsearch container|`default value is commented out`|
|`bssc-indexsearch.containerSecurityContext.seccompProfile.type`|Provision to configure  seccompProfile for Indexsearch containers |`RuntimeDefault`|
|`bssc-indexsearch.custom.manager.statefulSet.annotations`|Indexsearch manager statefulset specific annotations|`null`|
|`bssc-indexsearch.custom.manager.statefulSet.labels`|Indexsearch manager statefulset specific labels|`null`|
|`bssc-indexsearch.custom.manager.pod.annotations`|Indexsearch manager pod specific annotations|`null`|
|`bssc-indexsearch.custom.manager.pod.labels`|Indexsearch manager pod specific labels|`null`|
|`bssc-indexsearch.custom.data.statefulSet.annotations`|Indexsearch data statefulset specific annotations|`null`|
|`bssc-indexsearch.custom.data.statefulSet.labels`|Indexsearch data statefulset specific labels|`null`|
|`bssc-indexsearch.custom.data.pod.annotations`|Indexsearch data pod specific annotations|`null`|
|`bssc-indexsearch.custom.data.pod.labels`|Indexsearch data pod specific labels|`null`|
|`bssc-indexsearch.custom.client.deployment.annotations`|Indexsearch client deployment specific annotations|`null`|
|`bssc-indexsearch.custom.client.deployment.labels`|Indexsearch client deployment specific labels|`null`|
|`bssc-indexsearch.custom.client.pod.annotations`|Indexsearch client pod specific annotations|`null`|
|`bssc-indexsearch.custom.client.pod.labels`|Indexsearch client pod specific labels|`null`|
|`bssc-indexsearch.custom.hookJobs.job.annotations`|Indexsearch helm hook jobs specific annotations|`null`|
|`bssc-indexsearch.custom.hookJobs.job.labels`|Indexsearch helm hook jobs specific labels|`null`|
|`bssc-indexsearch.custom.hookJobs.pod.annotations`|Indexsearch helm hook & test pods specific annotations|`null`|
|`bssc-indexsearch.custom.hookJobs.pod.labels`|Indexsearch helm hook & test pods specific labels|`null`|
|`bssc-indexsearch.upgrade.hookDelPolicy`|Configure delete policy of pre/post-upgrade jobs to modify the job retention|`before-hook-creation, hook-succeeded`|
|`bssc-indexsearch.upgrade.autoMigratePV`| Due to asset name changes, both manager and data PV has to be migrated to retain old data. Use this flag if upgrading from BELK 22.06. For subsequent upgrades(like update configuration) the value has to be false | `false`|
|`bssc-indexsearch.autoRollback`| If this is set to true, then the chart itself will handle all the necessary pre/post rollback steps. #Note: #1. This needs the chart to have higher rbac permissions to delete PVCs. #2. The ReclaimPolicy of the storageclass must be 'Delete' for automatic rollback to work. If this is set to false, while downgrading to lower opensearch versions, user must manually scale down all the Indexsearch Manager and Data pods to zero and delete PVCs before helm rollback and execute rollback script file after rollback. |`true`|
|`bssc-indexsearch.persistence.enabled`|Enable persistent storage class for bssc indexsearch chart|`true`|
|`bssc-indexsearch.persistence.storageClassName`|Persistent Volume Storage Class name. Bssc indexsearch chart support "local-storage","cinder","hostpath". When configured as "" picks the default storage class configured in the BCMT cluster.|`null`|
|`bssc-indexsearch.persistence.accessMode`|Persistent Volume Access Modes|`ReadWriteOnce`|
|`bssc-indexsearch.persistence.size`|Persistent Volume Size given to data pods for storage|`50Gi`|
|`bssc-indexsearch.persistence.managerStorage`|Persistent storage size for manager pod to persist cluster state|`1Gi`|
|`bssc-indexsearch.persistence.auto_delete`|Persistent volumes auto deletion along with deletion of chart when set to true|`false`|
|`bssc-indexsearch.ipFamilyPolicy`|ipFamilyPolicy for dual-stack support configured at indexsearch level. Allowed values: SingleStack, PreferDualStack,RequireDualStack |`null`|
|`bssc-indexsearch.ipFamilies`|ipFamilies for dual-stack support configured at indexsearch level. Allowed values: ["IPv4"], ["IPv6"], ["IPv4","IPv6"], ["IPv6","IPv4"]  |`null`|
|`bssc-indexsearch.network_host`|Configure based on network interface added to cluster nodes i.e ipv4 interface or ipv6 interface.For ipv4 interface value can be set to "\_site\_".For ipv6 interface values can be set to "\_global:ipv6\_" or "\_eth0:ipv6\_". For dual stack environment, this can be set to "0.0.0.0" |`"_site_"`|
|`bssc-indexsearch.backup_restore.size`|Size of the PersistentVolume used for backup restore|`25Gi`|
|`bssc-indexsearch.backup_restore.restoreSystemIndices` | Set it to true to restore system indices( .opendistro_security, kibana index, multitenancy indices) | `false` |
|`bssc-indexsearch.backup_restore.storageClassName`|name of the storage class which the cluster should use for backup and restore. The storage class should be shared with ReadWriteMany option.|`glusterfs-storageclass`|
|`bssc-indexsearch.cbur.enabled`|Enable cbur for backup and restore operation|`false`|
|`bssc-indexsearch.cbur.brOption`|Backup is for a stateful set, CBUR will apply the rule specified by the brOption. Recommended value of brOption for BSSC is 0.|`0`|
|`bssc-indexsearch.cbur.maxCopy`|Maxcopy of backup files to be stored|`5`|
|`bssc-indexsearch.cbur.backendMode`|Configure the mode of backup. Available options are local","NETBKUP","AVAMAR","CEPHS3","AWSS3"|`local`|
|`bssc-indexsearch.cbur.cronJob`|Cronjob frequency|`0 23 * * *`|
|`bssc-indexsearch.cbur.autoEnableCron`|AutoEnable Cron to take backup as per configured cronjob |`false`|
|`bssc-indexsearch.cbur.autoUpdateCron`|AutoUpdate cron to update cron job schedule|`false`|
|`bssc-indexsearch.cbur.cbur_restore_parameters`|It is a Configmap which accepts parameters to customize the restore behaviour of the indices.|`CBUR_RESTORE_SUFFIX: "-restored"    CBUR_RESTORE_SUFFIX_WITHDATE: true   CBUR_RESTORE_INDICES_OVERWRITE: false   CBUR_RESTORE_DELETE_INDICES_NOTPARTOF_RESTORE_SNAPSHOT: false`|
|`bssc-indexsearch.cbur.cbura.imageRepo`|cbur-agent image used for backup and restore|`cbur/cbur-agent`|
|`bssc-indexsearch.cbur.cbura.imageTag`|cbur-agent image tag|`1.1.0-6419`|
|`bssc-indexsearch.cbur.cbura.imageFlavor`| set imageFlavor for cbura.|`null`|
|`bssc-indexsearch.cbur.cbura.imageFlavorPolicy`| set imageFlavorPolicy for cbura. Accepted values: Strict or BestMatch |`null`|
|`bssc-indexsearch.cbur.cbura.useImageTagAsIs`| set the useImageTagAsIs to true if you want to use imageTag for cbura as it is. If the useImageTagAsIs is set to false, we must specify the cbura supported image flavor in supportedImageFlavor list.|`false`|
|`bssc-indexsearch.cbur.cbura.supportedImageFlavor` | list of imageFlavor supported by Cbura |`["alpine"]`|
|`bssc-indexsearch.cbur.cbura.imagePullPolicy`|cbur-agent image pull policy|`IfNotPresent`|
|`bssc-indexsearch.cbur.cbura.resources`|CPU/Memory resource requests/limits for cbur-agent pod|`limits:       cpu: ""(1 if enableDefaultCpuLimits is true)        memory: "2Gi"         ephemeral-storage: "50Mi"        requests:       cpu: "500m"       memory: "1Gi"        ephemeral-storage: "50Mi"`|
|`bssc-indexsearch.cbur.cbura.tmp_size`|Volume mount size of /tmp directory for cbur-sidecar.The value should be around double the size of backup_restore.size|`50Gi`|
|`bssc-indexsearch.service.name`|Kubernetes service name for indexsearch|`indexsearch`|
|`bssc-indexsearch.service.client_port`|Indexsearch service port|`9200`|
|`bssc-indexsearch.service.manager_port`|Indexsearch service port for internal pod communication|`9300`|
|`bssc-indexsearch.service.prometheus_metrics.enabled`|Scrape metrics from indexsearch when set to true|`false`|
|`bssc-indexsearch.service.prometheus_metrics.pro_annotation_https_scrape`|Prometheus annotation to scrape metrics from indexsearch https endpoints|`prometheus.io/scrape_is`|
|`bssc-indexsearch.istio.enabled`|Enable istio for indexsearch using the flag|`false`|
|`bssc-indexsearch.istio.envoy.healthCheckPort`|Health check port of istio envoy proxy. Set value to 15020 for istio versions <1.6 and 15021 for version >=1.6 |`15021`|
|`bssc-indexsearch.istio.envoy.stopPort`|Port used to terminate istio envoy sidecar using /quitquitquit endpoint |`15000`|
|`bssc-indexsearch.istio.version`|Istio version specified at chart level. If defined here,it takes precedence over global level. Accepts istio version in string "X.Y" format. Ex. "1.7"|`null`|
|`bssc-indexsearch.istio.cni.enabled`|Whether istio cni is enabled in the environment: true/false |`null`|
|`bssc-indexsearch.istio.createDrForClient`| This optional flag should only be used when application was installed in istio-injection=enabled namespace, but was configured with istio.enabled=false, thus istio sidecar could not be injected into this application | `false`|
|`bssc-indexsearch.istio.customDrSpecForClient` | This configurations will be used for configuring spec of DestinationRule  when createDrForClient flag is enabled | `mode: DISABLE`|
|`bssc-indexsearch.certManager.enabled` |Enable cert-Manager feature using this flag when security is enabled. It is disabled by default.It takes higher precedence over certManager.enabled at global level.|`null`|
|`bssc-indexsearch.security.enable`|Enable security using this flag|`false`|
|`bssc-indexsearch.security.sensitiveInfoInSecret.enabled` | Enable this to take sensitive data from secret. When this flag is enabled user has to pre create the secret which are required for chart deployment | `false`|
|`bssc-indexsearch.security.sensitiveInfoInSecret.credentialName` | Pre-created secret name which contains sensitive information | `No value is set as default` |
|`bssc-indexsearch.security.sensitiveInfoInSecret.additionalInternalUsers` | Add additional users with credential name, username and password in form of a list. | `null` |
|`bssc-indexsearch.security.sensitiveInfoInSecret.secInternalUserYml` | Key name in precreated secret that stores the content of internal_users.yml file | `null`|
|`bssc-indexsearch.security.sensitiveInfoInSecret.keystoreJks` | Key name in precreated secret that stores indexsearch keystore jks | `null`|
|`bssc-indexsearch.security.sensitiveInfoInSecret.truststoreJks` | Key name in precreated secret that stores indexsearch truststore jks | `null`|
|`bssc-indexsearch.security.sensitiveInfoInSecret.clientKeystoreJks` | Key name in precreated secret that stores indexsearch client keystore jks  | `null`|
|`bssc-indexsearch.security.sensitiveInfoInSecret.keyPass` | Key name in precreated secret that stores indexsearch keystore password | `null`|
|`bssc-indexsearch.security.sensitiveInfoInSecret.trustPass` | Key name in precreated secret that stores indexsearch truststore password | `null`|
|`bssc-indexsearch.security.sensitiveInfoInSecret.clientCrtPem` | Key name in precreated secret that stores the indexsearch client certificate in pem format | `null`|
|`bssc-indexsearch.security.sensitiveInfoInSecret.clientKeyPem` | Key name in precreated secret that stores indexsearch client key in pem format | `null`|
|`bssc-indexsearch.security.sensitiveInfoInSecret.authAdminIdentity` | Key name in precreated secret that stores the DN of the admin (client) certificate | `null`|
|`bssc-indexsearch.security.sensitiveInfoInSecret.nodesDn` | Key name in precreated secret that stores the DN of the node(indexsearch) certificate (required if the certificate does not contain an OID in its SAN) | `null`|
|`bssc-indexsearch.security.sensitiveInfoInSecret.kibanaServerUserPwd` | Key name in precreated secret that stores password of kibanaserver user | `null`|
|`bssc-indexsearch.security.sensitiveInfoInSecret.adminUserName` | Key name in precreated secret that stores admin username. This has to be configured if secInternalUserYml is not present in pre-created secret | `null`|
|`bssc-indexsearch.security.sensitiveInfoInSecret.adminPassword` | Key name in precreated secret that stores admin password. This has to be configured if secInternalUserYml is not present in pre-created secret | `null`|
|`bssc-indexsearch.security.sensitiveInfoInSecret.keycloakRootCaPem` | Key name in precreated secret that stores keycloak rootCA in pem format | `null`|
|`bssc-indexsearch.security.certManager.enabled` | Enable cert-Manager feature using this flag when security is enabled. Bydefault, it reads same value as configured in bssc-indexsearch.security.certManager.enabled (root level). It takes higher precedence over certManager.enabled at root and global levels|`{{ Values.certManager.enabled }}`|
|`bssc-indexsearch.security.certManager.duration` |How long certificate will be valid|`8760h`
|`bssc-indexsearch.security.certManager.renewBefore` |When to renew the certificate before it gets expired|`360h`
|`bssc-indexsearch.security.certManager.apiVersion` |Api version of the cert-manager.io | `cert-manager.io/v1alpha3`
|`bssc-indexsearch.security.certManager.storePasswordCredentialName` |Secret name which contains the key of storePassword| `null`
|`bssc-indexsearch.security.certManager.storePasswordKey` | Key name in secret which stores the keystore password| `null`
|`bssc-indexsearch.security.certManager.dnsNames` |DNS used in certificate | `null`
|`bssc-indexsearch.security.certManager.issuerRef.name` |Issuer Name | `ncms-ca-issuer`
|`bssc-indexsearch.security.certManager.issuerRef.kind` |Kind of Issuer | `ClusterIssuer`
|`bssc-indexsearch.security.nodeCrt.tls.secretRef.name`|Name of the secret having user supplied certificates for opensearch node certificates |`""`|
|`bssc-indexsearch.security.nodeCrt.tls.secretRef.keyNames.caCrt`|Name of the secret key containing CA certificate |`null`|
|`bssc-indexsearch.security.nodeCrt.tls.secretRef.keyNames.tlsKey`|Name of the secret key containing TLS key |`null`|
|`bssc-indexsearch.security.nodeCrt.tls.secretRef.keyNames.tlsCrt`|Name of the secret key containing TLS server certificate |`null`|
|`bssc-indexsearch.security.adminCrt.tls.secretRef.name`|Name of the secret having user supplied certificates for opensearch admin certificates |`""`|
|`bssc-indexsearch.security.adminCrt.tls.secretRef.keyNames.caCrt`|Name of the secret key containing CA certificate |`null`|
|`bssc-indexsearch.security.adminCrt.tls.secretRef.keyNames.tlsKey`|Name of the secret key containing TLS key |`null`|
|`bssc-indexsearch.security.adminCrt.tls.secretRef.keyNames.tlsCrt`|Name of the secret key containing TLS certificate |`null`|
|`bssc-indexsearch.security.keycloak_auth`|Enable authentication via keycloak|`false`|
|`bssc-indexsearch.security.istio.extCkeyHostname`|FQDN of ckey hostname that is externally accessible from browser|`"ckey.io"`|
|`bssc-indexsearch.security.istio.extCkeyLocation`|Location of ckey internal/external to the istio mesh. Accepted values are MESH_INTERNAL, MESH_EXTERNAL|`MESH_INTERNAL`|
|`bssc-indexsearch.security.ciphers`|Cipher suites are cryptographic algorithms used to provide security  for HTTPS traffic.Example: TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256" "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384"|`null`|
|`bssc-indexsearch.extraConfig`|Section to add extra indexsearch configurations. To override opensearch.yml properties, uncomment esConfig_yml and add desired configurations under it|`null`|
|`bssc-indexsearch.jvm_options`|Section to modify jvm.options for indexsearch|default values provided by indexsearch|
|`bssc-indexsearch.security.sec_configmap.action_groups_yml`|Action groups are named collection of permissions.Using action groups is the preferred way of assigning permissions to a role.|`Refer values.yaml file or BSSC user guide for more details`|
|`bssc-indexsearch.security.sec_configmap.config_yml`|Configure Authentication and authorization settings for users|`Refer values.yaml file or BSSC user guide for more details`|
|`bssc-indexsearch.security.sec_configmap.roles_yml`|Configure security roles defining access permissions to indexsearch indices|`Refer values.yaml file or BSSC user guide for more details`|
|`bssc-indexsearch.security.sec_configmap.roles_mapping_yml`|Configure security roles that are assigned to users|`Refer values.yaml file or BSSC user guide for more details`|
|`bssc-indexsearch.security.sec_configmap.tenants_yml`| Define additional tenants (other than global & private) for dashboards multitenancy.| `Refer values.yaml file or BSSC user guide for more details`|
|`bssc-indexsearch.jvm_options`|Section to override default jvm.options file|`null`|
|`bssc-indexsearch.log4j2_properties`| Section to override default log4j2.properties file|`null`|
|`bssc-indexsearch.emptyDirSizeLimit.extensionsTmp`|Configure the sizeLimit of extensions-tmp emptyDir| `100Mi`|
|`bssc-indexsearch.emptyDirSizeLimit.tmp`|Configure the sizeLimit of tmp emptyDir| `200Mi`|
|`bssc-indexsearch.emptyDirSizeLimit.isConfig`|Configure the sizeLimit of is-config emptyDir| `10Mi`|
|`bssc-indexsearch.emptyDirSizeLimit.datadir`|Configure the sizeLimit of datadir emptyDir| `10Mi`|
|`bssc-indexsearch.emptyDirSizeLimit.sharedVolume`|Configure the sizeLimit of shared-volume emptyDir| `10Mi`|
|`bssc-indexsearch.emptyDirSizeLimit.securityconfWithSensitiveinfo`|Configure the sizeLimit of securityconf-with-sensitiveinfo emptyDir| `10Mi`|
|`bssc-indexsearch.emptyDirSizeLimit.secAdminJobTmp`|Configure the sizeLimit of sec-admin-job tmp emptyDir| `150Mi`|
|`bssc-indexsearch.emptyDirSizeLimit.postSetupApiJobTmp`|Configure the sizeLimit of post-setup-api-job tmp emptyDir| `5Mi`|
|`bssc-dashboards.disablePodNamePrefixRestrictions` |   disablePodNamePrefixRestrictions configured at root level. It takes higher precedence over disablePodNamePrefixRestrictions configured at global level  | `false`  |
|`bssc-dashboards.certManager.enabled` |Enable cert-Manager feature using this flag when security is enabled. It is disabled by default.It takes higher precedence over certManager.enabled at global level.|`null`|
|`bssc-dashboards.security.enable `|Enable tag for Security|`false `|
|`bssc-dashboards.security.keycloak_auth`|enable authentication required via keycloak|`false`|
|`bssc-dashboards.security.istio.extCkeyHostname`|FQDN of ckey hostname that is externally accessible from browser|`"ckey.io"`|
|`bssc-dashboards.security.istio.extCkeyLocation`|Location of ckey internal/external to the istio mesh. Accepted values: MESH_INTERNAL, MESH_EXTERNAL |`MESH_INTERNAL`|
|`bssc-dashboards.security.istio.extCkeyPort`|Port on which ckey is externally accessible|`null`|
|`bssc-dashboards.security.istio.extCkeyProtocol`|Protocol on which ckey is externally accessible|`null`|
|`bssc-dashboards.security.istio.ckeyK8sSvcName`|FQDN of ckey k8s service name internally accessible within k8s cluster|`null`|
|`bssc-dashboards.security.istio.ckeyK8sSvcPort`|Port on which ckey k8s service is accessible|`null`|
|`bssc-dashboards.security.dashboards.is_ssl_verification_mode`|Controls verification of the indexsearch server certificate that dashboards receives when contacting indexsearch|`certificate`|
|`bssc-dashboards.security.certManager.enabled` |Enable cert-Manager feature using this flag when security is enabled. By default, it reads same value as configured in bssc-dashboards.security.certManager.enabled (root level). It takes higher precedence over certManager.enabled at root and global levels|`{{ Values.certManager.enabled }}`|
|`bssc-dashboards.security.certManager.apiVersion` |Api version of the cert-manager.io | `cert-manager.io/v1alpha3`
|`bssc-dashboards.security.certManager.duration` |How long certificate will be valid|`8760h`
|`bssc-dashboards.security.certManager.renewBefore` |When to renew the certificate before it gets expired|`360h`
|`bssc-dashboards.security.certManager.dnsNames` |DNS used in certificate | `null`
|`bssc-dashboards.security.certManager.issuerRef.name` |Issuer Name | `ncms-ca-issuer`
|`bssc-dashboards.security.certManager.issuerRef.kind` |CRD Name | `ClusterIssuer`
|`bssc-dashboards.security.sensitiveInfoInSecret.enabled` | SensitiveInfo flag is enabled by default when security is enabled. User has to pre create the secret which are required for chart deployment | `false`|
|`bssc-dashboards.security.sensitiveInfoInSecret.credentialName` | Pre-created secret name which contains secret information | `No values are set as default` |
|`bssc-dashboards.security.sensitiveInfoInSecret.dboServerCrt` | secret key for dashboards server certificate from pre-created secret | `No value is set as default`|
|`bssc-dashboards.security.sensitiveInfoInSecret.dboServerKey` | secret key for dashboards server key from pre-created secret| `No value is set as default`|
|`bssc-dashboards.security.sensitiveInfoInSecret.dboIsPassword` | secret key storing password of kibanaserver user from pre-created secret | `No value is set as default` |
|`bssc-dashboards.security.sensitiveInfoInSecret.IsRootCaPem` | secret key for IS RootCA pem from pre-created secret | `No value is set as default`|
|`bssc-dashboards.security.sensitiveInfoInSecret.keycloakRootCaPem` | secret key for keycloak rootCA pem from pre-created secret | `No value is set as default` |
|`bssc-dashboards.security.sensitiveInfoInSecret.keycloakClientId` | secret key for keycloak ClientId from pre-created secret | `No value is set as default` |
|`bssc-dashboards.security.sensitiveInfoInSecret.keycloakClientSecret` | secret key for keycloak Client secret from pre-created secret | `No value is set as default` |
|`bssc-dashboards.security.sensitiveInfoInSecret.sane.keycloak_admin_user_name` | secret key for keycloak admin username when sane is enabled | `Default value is commented out` |
|`bssc-dashboards.security.sensitiveInfoInSecret.sane.keycloak_admin_password` | secret key for keycloak admin password when sane is enabled | `Default value is commented out` |
|`bssc-dashboards.security.sensitiveInfoInSecret.sane.keycloak_sane_user_password` | secret key for keycloak sane user password when sane is enabled | `Default value is commented out` |
|`bssc-dashboards.security.tls.secretRef.name`|Name of the secret having user supplied certificates for opensearch dashboards server certificates |`""`|
|`bssc-dashboards.security.tls.secretRef.keyNames.caCrt`|Name of the secret key containing CA certificate |`null`|
|`bssc-dashboards.security.tls.secretRef.keyNames.tlsKey`|Name of the secret key containing TLS key |`null`|
|`bssc-dashboards.security.tls.secretRef.keyNames.tlsCrt`|Name of the secret key containing TLS server certificate |`null`|
|`bssc-dashboards.imageFlavor`| Dashboards imageFlavor configured at root level. It takes higher precedence over imageFlavor configured at global level. | `null` |
|`bssc-dashboards.imageFlavorPolicy`| Dashboards imageFlavor policy configured at root level. It takes higher precedence over imageFlavor policy configured at global level. Accepted values: Strict or BestMatch(Default) |`null`|
|`bssc-dashboards.dashboards.image.repo`|dashboards image repo name. |`bssc-dashboards`|
|`bssc-dashboards.dashboards.image.flavor`| Image flavor name for dashboards container. | `null` |
|`bssc-dashboards.dashboards.image.flavorPolicy`| Image flavor policy for dashboards container.  Accepted values: Strict or BestMatch(Default) |`null`|
|`bssc-dashboards.dashboards.imageFlavor`|  Image flavor name for dashboards workload. | `null` |
|`bssc-dashboards.dashboards.imageFlavorPolicy`|  Image flavor policy for dashboards workload. Accepted values: Strict or BestMatch(Default) |`null`|
|`bssc-dashboards.dashboards.replicas`|Desired number of dashboards replicas|`1`|
|`bssc-dashboards.dashboards.resources`| CPU/Memory/ephemeral-storage resource requests/limits for Dashboards pod | `limits: CPU/Mem/ephemeral (1000m if enableDefaultCpuLimits is true)/2Gi/1Gi , requests: CPU/Mem/ephemeral 500m/1Gi/200Mi`|
|`bssc-dashboards.dashboards.k8sSvcPort`|  It should be the port used by kubernetes service | `443` |
|`bssc-dashboards.dashboards.port`|dashboards is served by a back end server. This setting specifies the port to use.|`5601`|
|`bssc-dashboards.dashboards.node_port`|This setting specifies the node_port to use when service type is NodePort|`30601`|
|`bssc-dashboards.dashboards.livenessProbe.initialDelaySeconds `|Delay before liveness probe is initiated (dashboards)|`150`|
|`bssc-dashboards.dashboards.livenessProbe.probecheck`|Configuration of Liveness check (Dashboards)|`empty`|
|`bssc-dashboards.dashboards.livenessProbe.periodSeconds`|How often to perform the probe (dashboards)|`30`|
|`bssc-dashboards.dashboards.livenessProbe.failureThreshold`|Minimum consecutive failures for the probe (dashboards)|`6`|
|`bssc-dashboards.dashboards.readinessProbe.initialDelaySeconds`|Delay before readiness probe is initiated (dashboards)|`150`|
|`bssc-dashboards.dashboards.readinessProbe.probecheck`|Configuration of Readiness check (Dashboards)|`empty`|
|`bssc-dashboards.dashboards.readinessProbe.periodSeconds`|How often to perform the probe (dashboards)|`30`|
|`bssc-dashboards.dashboards.readinessProbe.failureThreshold`|Minimum consecutive failures for the probe (dashboards)|`6`|
|`bssc-dashboards.dashboards.replicasManagedByHpa`| Depending on the value replicas will be managed by either HPA or deployment | `false` |
|`bssc-dashboards.dashboards.hpa.enabled`| Enable/Disable HorizontalPodAutoscaler | `null(false)` |
|`bssc-dashboards.dashboards.hpa.minReplicas` | Minimum replica count to which HPA can scale down | `1` |
|`bssc-dashboards.dashboards.hpa.maxReplicas` | Maximum replica count to which HPA can scale up | `3` |
|`bssc-dashboards.dashboards.hpa.predefinedMetrics.enabled` | Enable/Disable default memory/cpu metrics monitoring on HPA | `true` |
|`bssc-dashboards.dashboards.hpa.averageCPUThreshold` | HPA keeps the average cpu utilization of all the pods below the value set | `85` |
|`bssc-dashboards.dashboards.hpa.averageMemoryThreshold` | HPA keeps the average memory utilization of all the pods below the value set | `85` |
|`bssc-dashboards.dashboards.hpa.behavior` | Additional behavior to be set here | `empty` |
|`bssc-dashboards.dashboards.hpa.metrics` | Additional metrics to monitor can be set here | `empty` |
|`bssc-dashboards.dashboards.pdb.enabled` | To enable Pod Disruption budget for dashboards pods |`true`|
|`bssc-dashboards.dashboards.pdb.minAvailable` | Minimum number of dashboards pods must still be available when disruption happens. Atleast 50% of the dashboards pods are recommended to be up to handle the incoming traffic. The minAvailable value can be changed based on need and incoming load. As default replica of dashboards is 1 and pdb.minAvailable is 50%, it will not allow to drain the node and service will not get interrupted. If user still wants to drain the node: option 1: If service outage is not acceptable - increase the num of replicas for dashboards so that the PDB conditions are met. option 2: If service outage is acceptable -  either disable PDB or set minAvailable to empty and maxUnavailable to 1 so that node can be drained|`50%`|
|`bssc-dashboards.dashboards.pdb.maxUnavailable` | Maximum number for dashboards pods that can be unavailable when disruption happens|`null`|
|`bssc-dashboards.dashboards.hostAliases` | Additional dns entries can be added to pod's /etc/hosts for dns resolution by configuring hostaliases | `null` |
|`bssc-dashboards.dashboards.priorityClassName`|dashboards pod priority class name. When this is set, it takes precedence over priorityClassName set at global level |`null`|
|`bssc-dashboards.dashboards.imagePullSecrets`| Dashboards imagePullSecrets configured at workload level. It takes higher precedence over imagePullSecrets configured at root or global levels |`null`|
|`bssc-dashboards.dashboards.securityContext.enabled`|To enable/disable security context for dashboards |`true`|
|`bssc-dashboards.dashboards.securityContext.runAsUser`|UID with which the container will be run|`1000`|
|`bssc-dashboards.dashboards.securityContext.fsGroup`|Group ID that is assigned for the volumemounts mounted to the pod|`1000`|
|`bssc-dashboards.dashboards.securityContext.supplementalGroups`|The supplementalGroups ID applies to shared storage volumes|`default value is commented out`|
|`bssc-dashboards.dashboards.securityContext.seLinuxOptions`|provision to configure selinuxoptions for dashboards container|`default value is commented`|
|`bssc-dashboards.dashboards.containerSecurityContext.seccompProfile.type`|Provision to configure  seccompProfile for Dashboards containers |`RuntimeDefault`|
|`bssc-dashboards.dashboards.custom.deployment.annotations`|Dashboards deployment specific annotations|`{}`|
|`bssc-dashboards.dashboards.custom.deployment.labels`|Dashboards deployment specific labels|`{}`|
|`bssc-dashboards.dashboards.custom.pod.annotations`|Dashboards pod specific annotations|`{}`|
|`bssc-dashboards.dashboards.custom.pod.labels`|Dashboards pod specific labels|`{}`|
|`bssc-dashboards.dashboards.custom.hookJobs.job.annotations`|Dashboards helm hook jobs specific annotations|`{}`|
|`bssc-dashboards.dashboards.custom.hookJobs.job.labels`|Dashboards helm hook jobs specific labels|`{}`|
|`bssc-dashboards.dashboards.custom.hookJobs.pod.annotations`|Dashboards helm hook & test pods specific annotations|`{}`|
|`bssc-dashboards.dashboards.custom.hookJobs.pod.labels`|Dashboards helm hook & test pods specific labels|`{}`|
|`bssc-dashboards.dashboards.unifiedLogging.enabled` | enable/disable harmonized logging for dashboards logs. | `true` |
|`bssc-dashboards.dashboards.unifiedLogging.imageRepo` | image repo for fluentd sidecar used in dashboards pod to convert dashboards logs into harmonized-logging format. | `bssc-fluentd`|
|`bssc-dashboards.dashboards.unifiedLogging.imageFlavor`| Image flavor name for fluentd sidecar container. | `null` |
|`bssc-dashboards.dashboards.unifiedLogging.imageFlavorPolicy`| Image flavor policy for fluentd sidecar container. Accepted values: Strict or BestMatch(Default) |`null`|
|`bssc-dashboards.dashboards.unifiedLogging.syslog.enabled`      | Enable sending logs to syslog. Takes precedence over global.unifiedLogging.syslog.enabled | `null(false)` |
|`bssc-dashboards.dashboards.unifiedLogging.syslog.facility`      | Syslog facility   | `null` |
|`bssc-dashboards.dashboards.unifiedLogging.syslog.host`      | Syslog server host name to connect to  | `null` |
|`bssc-dashboards.dashboards.unifiedLogging.syslog.port`      | Syslog server port to connect to  | `null` |
|`bssc-dashboards.dashboards.unifiedLogging.syslog.protocol`      | Protocol to connect to syslog server. Ex. TCP | `null` |
|`bssc-dashboards.dashboards.unifiedLogging.syslog.caCrt.secretName`      | Name of secret containing syslog CA certificate | `null` |
|`bssc-dashboards.dashboards.unifiedLogging.syslog.caCrt.key`      | Key in secret containing syslog CA certificate | `null` |
|`bssc-dashboards.dashboards.unifiedLogging.syslog.tls.secretRef.name`      | Name of secret containing syslog CA certificate.  It takes higher precedence over syslog.caCrt.secretName. | `null` |
|`bssc-dashboards.dashboards.unifiedLogging.syslog.tls.secretRef.keyNames.caCrt`     | Key in secret containing syslog CA certificate.  It takes higher precedence over syslog.caCrt.key. | `ca.crt` |
|`bssc-dashboards.dashboards.unifiedLogging.extension` | list of extended fields that component can use to enrich the log event | `null` |
|`bssc-dashboards.dashboards.configMaps.dashboards_configmap_yml.server.name`|A human-readable display name that identifies this dashboards instance|`dashboards`|
|`bssc-dashboards.dashboards.configMaps.dashboards_configmap_yml.server.customResponseHeaders`|Header names and values to send on all responses to the client from the dashboards server|`{ "X-Frame-Options": "DENY" }  `|
|`bssc-dashboards.dashboards.configMaps.dashboards_configmap_yml.csp.strict `|dashboards uses a Content Security Policy to help prevent the browser from allowing unsafe scripting|`true`|
|`bssc-dashboards.dashboards.configMaps.dashboards_configmap_yml.server.ssl.supportedProtocols`|Supported protocols with versions. Valid protocols: TLSv1, TLSv1.1, TLSv1.2. Enable server.ssl.supportedProtocols when security is enabled.|`Even though the value is commented, default values are TLSv1.1, TLSv1.2`|
|`bssc-dashboards.dashboards.configMaps.dashboards_configmap_yml.opensearch_security.cookie.secure`| Indexsearch security cookie can be secured by setting the below parameter to true. Uncomment it when Security is enabled.|`true`|
|`bssc-dashboards.dashboards.configMaps.dashboards_configmap_yml.opensearch_security.multitenancy.enabled `|Enable multitenancy in dashboards|`false`| 
|`bssc-dashboards.dashboards.configMaps.dashboards_configmap_yml.opensearch.requestHeadersAllowlist `|dashboards client-side headers to send to indexsearch|`Even though the value is commented, default value is autorization`|
|`bssc-dashboards.dashboards.configMaps.dashboards_configmap_yml.opensearch_security.auth.unauthenticated_routes `|Disable authentication on /api/status route |`['/api/status']`|
|`bssc-dashboards.dashboards.configMaps.dashboards_configmap_yml.opensearch_security.auth.type`|If openid/ckey authentication is required, then uncomment and set this parameter to openid, Also uncomment and configure the other openid.* parameters accordingly. |`default value is basicauth when security is enabled.`|
|`bssc-dashboards.dashboards.configMaps.dashboards_configmap_yml.opensearch_security.openid.connect_url `|The URL where the IdP publishes the OpenID metadata.|`null`|
|`bssc-dashboards.dashboards.configMaps.dashboards_configmap_yml.opensearch_security.openid.client_id`|The ID of the OpenID client configured in your IdP|`null`|
|`bssc-dashboards.dashboards.configMaps.dashboards_configmap_yml.opensearch_security.openid.client_secret`|The client secret of the OpenID client configured in your IdP|`null`|
|`bssc-dashboards.dashboards.configMaps.dashboards_configmap_yml.opensearch_security.openid.header`|HTTP header name of the JWT token|`null`|
|`bssc-dashboards.dashboards.configMaps.dashboards_configmap_yml.opensearch_security.openid.base_redirect_url`|The URL where the IdP redirects to after successful authentication|`null`|
|`bssc-dashboards.dashboards.configMaps.dashboards_configmap_yml.opensearch_security.openid.root_ca`|Path to the root CA of your IdP|`null`|
|`bssc-dashboards.dashboards.configMaps.dashboards_configmap_yml.csan.enabled `|To enable/disable CSAN-dashboards integration. If csan is enabled, then uncomment and set other opendistro_security.auth.unauthenticated_routes,csan.* parameters accordingly|`null`|
|`bssc-dashboards.dashboards.configMaps.dashboards_configmap_yml.csan.ssoproxy.url`|This is CSAN SSOProxy service URL|`null`|
|`bssc-dashboards.dashboards.configMaps.dashboards_configmap_yml.opendistro_security.auth.unauthenticated_routes`|CSAN plugin routes need to be excluded from opendistro security authentication model|`null`|
|`bssc-dashboards.dashboards.configMaps.dashboards_configmap_yml.csan.sco.url`|This is system credential orchestrator service URL|`null`|
|`bssc-dashboards.dashboards.configMaps.dashboards_configmap_yml.csan.sco.keycloak_entity`|This is keycloak entity name name|`null`|
|`bssc-dashboards.dashboards.configMaps.dashboards_configmap_yml.csan.sco.keycloak_classifier`|This is Keyclock realm-admin and this is required to connect with keycloak|`null`|
|`bssc-dashboards.dashboards.configMaps.dashboards_configmap_yml.csan.sco.sane_entity `|SANE entity name|`null`|
|`bssc-dashboards.dashboards.configMaps.dashboards_configmap_yml.csan.sco.sane_plugin_name `|Name of CSAN-dashboards credential plugin|`null`|
|`bssc-dashboards.dashboards.configMaps.dashboards_configmap_yml.csan.auth_type `|Authentication type for dynamic password for CSAN users|`null`|
|`bssc-dashboards.dashboards.env.OPENSEARCH_HOSTS`| The URLs of the Indexsearch instances to use for all your queries. When security is enabled use protocol as https                               |`http://indexsearch:9200`|
|`bssc-dashboards.dashboards.env.SERVER_SSL_ENABLED`|When istio is enabled then uncomment SERVER_SSL_ENABLED and set it to false and If security is enabled uncomment SERVER_SSL_ENABLED|               `"default value is commented out"`|
|`bssc-dashboards.dashboards.nodeSelector`|dashboards node labels for pod assignment|`{}`|
|`bssc-dashboards.dashboards.tolerations`|List of node taints to tolerate (dashboards)|`[]`|
|`bssc-dashboards.dashboards.topologySpreadConstraints`|topologySpreadConstraints for dashboards |`{}`|
|`bssc-dashboards.dashboards.affinity`|dashboards affinity (in addition to dashboards.antiAffinity when set)|`{}`|
|`bssc-dashboards.dashboards.certificate.enabled` | If cert manager is enabled, certificate will be created as per it's configured in this section | `true` |
|`bssc-dashboards.dashboards.certificate.issuerRef.name`| Name of certificate issuer | `null` |
|`bssc-dashboards.dashboards.certificate.issuerRef.kind` | Kind of Issuer | `null` |
|`bssc-dashboards.dashboards.certificate.issuerRef.group` | Certificate Issuer Group Name | `null` |
|`bssc-dashboards.dashboards.certificate.duration`| How long certificate will be valid |`null` |
|`bssc-dashboards.dashboards.certificate.renewBefore` | When to renew the certificate before it gets expired |`null` |
|`bssc-dashboards.dashboards.certificate.secretName` | Name of the secret in which this cert would be added| `null` |
|`bssc-dashboards.dashboards.certificate.subject`| Certificate subject | `null`|
|`bssc-dashboards.dashboards.certificate.commonName` | CN of certificate | `null` |
|`bssc-dashboards.dashboards.certificate.usages ` | Certificate usage | `null` |
|`bssc-dashboards.dashboards.certificate.dnsNames ` | DNSNames is a list of DNS subjectAltNames to be set on the Certificate.| `null` |
|`bssc-dashboards.dashboards.certificate.uris` | URIs is a list of URI subjectAltNames to be set on the Certificate.| `null`|
|`bssc-dashboards.dashboards.certificate.ipAddresses`| IPAddresses is a list of IP address subjectAltNames to be set on the Certificate. |`null`|
|`bssc-dashboards.dashboards.certificate.privateKey.algorithm`| Algorithm is the private key algorithm of the corresponding private key for this certificate | `null`|
|`bssc-dashboards.dashboards.certificate.privateKey.encoding`| The private key cryptography standards (PKCS) encoding for this certificate’s private key | `null`|
|`bssc-dashboards.dashboards.certificate.privateKey.size`| Size is the key bit size of the corresponding private key for this certificate. | `null` |
|`bssc-dashboards.dashboards.certificate.privateKey.rotationPolicy`| Rotation of a key pair, when certificate is refreshed is recommended from a security point of view | `Always` |
|`bssc-dashboards.dashboards.indexsearch.credentialName.name`| When clientcert_auth_domain in indexsearch chart and cert manager is enabled, configure secret name same as configured in indexsearch chart's indexsearch.externalClientCertificates.dashboards.certificate.secretName | `{{ .Release.Name }}-bssc-ifd-cert-for-dashboards` |
|`bssc-dashboards.rbac.enabled`|Enable/disable rbac. When rbac.enabled is set to true, charts would create its own rbac related resources; If false, an external serviceAccountName set in values will be used. |`true`|
|`bssc-dashboards.rbac.psp.create`    | If set to true, then chart creates its own PSPs only if required; If set to false, then chart do not create PSPs.  | `false` |
|`bssc-dashboards.rbac.psp.annotations`  | Annotation to be set when 'dashboards.containerSecurityContext.seccompProfile.type' is configured or if required only | `seccomp.security.alpha.kubernetes.io/allowedProfileNames: '*'` |
|`bssc-dashboards.rbac.scc.create`    | If set to true, then chart creates its own SCCs only if required; If set to false, then chart do not create SCCs.  | `false` |
|`bssc-dashboards.rbac.scc.annotations`    | To set annotations for SCCs only if required;   | `null` |
|`bssc-dashboards.serviceAccountName`|Pre-created ServiceAccount specifically for dashboards chart.|`null`|
|`bssc-dashboards.customResourceNames.resourceNameLimit`         | Character limit for resource names to be truncated                    | `63` |
|`bssc-dashboards.customResourceNames.dboPod.dboContainerName`         | Name for dashboards pod's container                  | `null` |
|`bssc-dashboards.customResourceNames.dboPod.initContainerName` | Name of init container | `null` |
|`bssc-dashboards.customResourceNames.dboPod.unifiedLoggingContainerName` | Name of unified-logging sidecar container | `null` |
|`bssc-dashboards.customResourceNames.dboPod.dboPluginsInitContainerName` | Name of dbo-plugins-init Container Name | `null` |
|`bssc-dashboards.customResourceNames.helmTestPod.name`         | Name for dashboards helm test pod                    | `null` |
|`bssc-dashboards.customResourceNames.helmTestPod.helmTestContainerName`         | Name for dashboards helm test pod's container                   | `null` |
|`bssc-dashboards.customResourceNames.deleteJob.name` | Name for dashboards delete job | `null` |
|`bssc-dashboards.customResourceNames.deleteJob.deleteJobContainerName` | Name for dashboards delete job's container | `null`|
|`bssc-dashboards.nameOverride`         | Use this to override name for dashboards deployment kubernetes object. When it is set, the name would be ReleaseName-nameOverride                 | `null` |
|`bssc-dashboards.fullnameOverride`         | Use this to configure custom-name for dashboards deployment kubernetes object.  If both nameOverride and fullnameOverride are specified, fullnameOverride would take the precedence.                  | `null` |
|`bssc-dashboards.enableDefaultCpuLimits`   |Enable this flag to set pod CPU resources limit for all dashboards containers. It has no value set by default. |`null`|
|`bssc-dashboards.partOf` | Use this to configure common lables for k8s objects. Set to configure label app.kubernetes.io/part-of: | `bssc-ifd` |
|`bssc-dashboards.timezone.timeZoneEnv`         | To specify timezone value  and this will have higer precedence over global.timeZoneEnv             | `null` |
|`bssc-dashboards.jobs.affinity`|To provide affinity for jobs and helm test pods |`null`|
|`bssc-dashboards.jobs.nodeSelector`|To provide nodeSelector for jobs and helm test pods |`null`|
|`bssc-dashboards.jobs.tolerations`|To provide tolerations for jobs and helm test pods |`null`|
|`bssc-dashboards.imagePullSecrets`| Dashboards imagePullSecrets configured at root level. It takes higher precedence over imagePullSecrets configured at global level |`null`|
|`bssc-dashboards.ingress.enabled`|Enable to access dashboards svc via citm-ingress|`true`|
|`bssc-dashboards.ingress.name`|Kubernetes ingress name for dashboards|`null`|
|`bssc-dashboards.ingress.annotations`|Ingress annotations (evaluated as a template)|`{}`|
|`bssc-dashboards.ingress.host`|Hosts configured for ingress|`*`|
|`bssc-dashboards.ingress.tls`|TLS configured for ingress |`[]`|
|`bssc-dashboards.ingress.pathType`|Path type configured for ingress |`Prefix`|
|`bssc-dashboards.service.name`|Kubernetes service name of dashboards.|`dashboards`|
|`bssc-dashboards.service.type`|Kubernetes service type|`ClusterIP`|
|`bssc-dashboards.service.annotations`|custom service annotations |`{}`|
|`bssc-dashboards.ipFamilyPolicy`|ipFamilyPolicy for dual-stack support configured at dashboards level. Allowed values: SingleStack, PreferDualStack,RequireDualStack |`null`|
|`bssc-dashboards.ipFamilies`|ipFamilies for dual-stack support configured at dashboards level. Allowed values: ["IPv4"], ["IPv6"], ["IPv4","IPv6"], ["IPv6","IPv4"]  |`null`|
|`bssc-dashboards.dbobaseurl.url`|Baseurl configured for dashboards when dashboards service is with ClusterIP|`/logviewer`|
|`bssc-dashboards.dbobaseurl.cg`|Do not change cg(capture group) parameter below unless you want to change/modify nginx rewrite-target for dashboards ingress|`/?(.*)`|
|`bssc-dashboards.istio.enabled`|Enabled istio for dashboards when running in istio enabled namespace|`false`|
|`bssc-dashboards.istio.version`|Istio version specified at chart level. If defined here,it takes precedence over global level. Accepts istio version in string "X.Y" format. Ex. "1.7"|`null`|
|`bssc-dashboards.istio.cni.enabled`|Whether istio cni is enabled in the environment: true/false |`null`|
|`bssc-dashboards.istio.envoy.healthCheckPort`|Health check port of istio envoy proxy. Set value to 15020 for istio versions <1.6 and 15021 for version >=1.6 |`15021`|
|`bssc-dashboards.istio.envoy.waitTimeout`| Time in seconds to wait for istio envoy proxy to load required configurations | `60` |
|`bssc-dashboards.istio.envoy.stopPort`|Port used to terminate istio envoy sidecar using /quitquitquit endpoint |`15000`|
|`bssc-dashboards.istio.createDrForClient`| This optional flag should only be used when application was installed in istio-injection=enabled namespace, but was configured with istio.enabled=false, thus istio sidecar could not be injected into this application |`false`|
|`bssc-dashboards.istio.customDrSpecForClient` | This configurations will be used for configuring spec of DestinationRule  when createDrForClient flag is enabled | `mode: DISABLE`|
|`bssc-dashboards.istio.virtual_svc.hosts`|VirtualService defines a set of traffic routing rules to apply when a host is addressed|`*`|
|`bssc-dashboards.istio.virtual_svc.exportTo`|Defines in which all namespaces virtual service is exported to |`*`|
|`bssc-dashboards.istio.virtual_svc.gateways` | existing gateways for dashboards Virtual Service to bind to. If shared gateway is available, Dashboards VirtualService will only use shared gateway | `dashboards-gw`|
|`bssc-dashboards.istio.sharedHttpGateway`|Istio ingressgateway name if existing gateway should be used|`null`|
|`bssc-dashboards.istio.sharedHttpGateway.namespace` | Namespace where the existing gateway object exists. | `null` |
|`bssc-dashboards.istio.sharedHttpGateway.name` | Name of the shared gateway object | `null` |
|`bssc-dashboards.istio.gateways` | An optional array of gateways which can be added if needed. These gateways will be created fresh in your install | `dashboards-gw` |
|`bssc-dashboards.istio.gateways.dashboards-gw.enabled` | enable/disable gateway creation. When sharedHttpGateway is used this parameter has to be disabled | `true` |
|`bssc-dashboards.istio.gateways.dashboards-gw.labels` | Optional labels to be added to gateway object | `null`|
|`bssc-dashboards.istio.gateways.dashboards-gw.annotations` | Optional annotations to be added to the gateway object | `null`|
|`bssc-dashboards.istio.gateways.dashboards-gw.ingressPodSelector.istio`|This should be the label of the istio ingressgateway pod which you want your gateway to attach to |`ingressgateway`|
|`bssc-dashboards.istio.gateways.dashboards-gw.port`|Port number used for istio gateway|`80`|
|`bssc-dashboards.istio.gateways.dashboards-gw.protocol`|Protocol used for istio gateway|`HTTP  `|
|`bssc-dashboards.istio.gateways.dashboards-gw.host`|Hosts configured for istio gateway. By default chart will use '*' |`null`|
|`bssc-dashboards.istio.gateways.dashboards-gw.tls`| TLS settings for your gateway. This section is mandatory if protocol is TLS/HTTPS. |`null`|
|`bssc-dashboards.istio.gateways.dashboards-gw-tls.redirect` | This optional flag is only applicable for an HTTP port to force a redirection to HTTPS. | `false`|
|`bssc-dashboards.istio.gateways.dashboards-gw.tls.mode` | Mode can be SIMPLE / MUTUAL / PASSTHROUGH/ ISTIO_MUTUAL and it is exactly as per ISTIO documentation | `null`|
|`bssc-dashboards.istio.gateways.dashboards-gw.tls.credentialName` | The name of the kubernetes secret, in the namespace to be used for TLS traffic | `null`|
|`bssc-dashboards.istio.gateways.dashboards-gw.tls.custom` | Istio TLS has many other attributes and configurations. If for some reason none of the above fits your needs , then use this section to configure as per istio docs. Anything under here will be directly moved under TLS section of gateway definition | `null` |
|`bssc-dashboards.cbur.enabled`|Enable cbur to take backup & restore the data|`false`|
|`bssc-dashboards.cbur.maxCopy`|max copy of backupdata stored in cbur|`5`|
|`bssc-dashboards.cbur.backendMode`|Configure the mode of backup. Available options are local","NETBKUP","AVAMAR","CEPHS3","AWSS3"|`local`|
|`bssc-dashboards.cbur.cronJob`|cronjob frequency|`0 23 * * *`|
|`bssc-dashboards.cbur.autoEnableCron`|To auto enable cron job |`false`|
|`bssc-dashboards.cbur.autoUpdateCron`|To delete/update cronjob automatically based on autoEnableCron|`false`|
|`bssc-dashboards.emptyDirSizeLimit.dboPluginsVolume`|Configure the sizeLimit of dbo-plugins-volume emptyDir|`1Gi`|
|`bssc-dashboards.emptyDirSizeLimit.dashboardsData`|Configure the sizeLimit of dashboards-data emptyDir|`10Mi`|
|`bssc-dashboards.emptyDirSizeLimit.dashboardsLogs`|Configure the sizeLimit of dashboards-logs emptyDir|`200Mi`|
|`bssc-dashboards.emptyDirSizeLimit.dashboardsEmptydirconf`|Configure the sizeLimit of dashboards-emptydirconf emptyDir|`10Mi`|
|`bssc-dashboards.emptyDirSizeLimit.sharedVolume`|Configure the sizeLimit of shared-volume emptyDir|`10Mi`|
|`bssc-indexmgr.disablePodNamePrefixRestrictions` |   disablePodNamePrefixRestrictions configured at root level. It takes higher precedence over disablePodNamePrefixRestrictions configured at global level  | `false`  |
|`bssc-indexmgr.certManager.enabled` |Enable cert-Manager feature using this flag when security is enabled. It is disabled by default.It takes higher precedence over certManager.enabled at global level.|`null`|
|`bssc-indexmgr.security.enable`|Enable security for indexmgr using this flag|`false`|
| `bssc-indexmgr.security.sensitiveInfoInSecret.enabled` | Enable this to read sensitive data from secret. It reads the same value as bssc-indexmgr.security.enable by default. |`{{ .Values.security.enable }}`|
| `bssc-indexmgr.security.sensitiveInfoInSecret.credentialName`             | Name of the pre-created secret which contains sensitive information.              | `null`  |
| `bssc-indexmgr.security.sensitiveInfoInSecret.indexmgrIsUsername`             | Key name in precreated secret that stores indexsearch username in its value.              | `null`  |
| `bssc-indexmgr.security.sensitiveInfoInSecret.indexmgrIsPassword`             | Key name in precreated secret that stores indexsearch password in its value.             | `null`  |
| `bssc-indexmgr.security.sensitiveInfoInSecret.ca_certificate`             | Key name in precreated secret that stores indexsearch root ca certificate in its value.           | `null`  |
|`bssc-indexmgr.security.certManager.enabled` | Enable cert-Manager feature using this flag when security is enabled. By default, it reads same value as configured in bssc-indexmgr.security.certManager.enabled (root level). It takes higher precedence over certManager.enabled at root and global levels|`{{ Values.certManager.enabled }}`|
|`bssc-indexmgr.security.certManager.apiVersion` |Api version of the cert-manager.io | `cert-manager.io/v1alpha3`|
|`bssc-indexmgr.security.certManager.duration` |How long certificate will be valid|`8760h`|
|`bssc-indexmgr.security.certManager.renewBefore` |When to renew the certificate before it gets expired|`360h`|
|`bssc-indexmgr.security.certManager.issuerRef.name` |Issuer Name | `ncms-ca-issuer`|
|`bssc-indexmgr.security.certManager.issuerRef.kind` |CRD Name | `ClusterIssuer`|
|`bssc-indexmgr.istio.enabled`|Enable istio for indexmgr using the flag |`false`|
|`bssc-indexmgr.istio.envoy.healthCheckPort`|Health check port of istio envoy proxy. Set value to 15020 for istio versions <1.6 and 15021 for version >=1.6 |`15021`|
|`bssc-indexmgr.istio.envoy.waitTimeout`                   | Time in seconds to wait for istio envoy proxy to load required configurations before starting indexmgr process                                 | `60` |
|`bssc-indexmgr.istio.envoy.stopPort`|Port used to terminate istio envoy sidecar using /quitquitquit endpoint |`15000`|
|`bssc-indexmgr.istio.cni.enabled`|Whether istio cni is enabled in the environment: true/false |`null`|
|`bssc-indexmgr.rbac.enabled` | Enable/disable rbac. When rbac.enabled is set to true, chart would create its own rbac related resources; If false, an external serviceAccountName set in values will be used. | `true`  |
|`bssc-indexmgr.rbac.psp.create`    | If set to true, then chart creates its own PSPs only if required; If set to false, then chart do not create PSPs.  | `false` |
|`bssc-indexmgr.rbac.psp.annotations`  | Annotation to be set when 'indexmgr.containerSecurityContext.seccompProfile.type' is configured or if required only | `seccomp.security.alpha.kubernetes.io/allowedProfileNames: '*'` |
|`bssc-indexmgr.rbac.scc.create`    | If set to true, then chart creates its own SCCs only if required; If set to false, then chart do not create SCCs.  | `false` |
|`bssc-indexmgr.rbac.scc.annotations`    | To set annotations for SCCs only if required;   | `null` |
| `bssc-indexmgr.serviceAccountName` | Pre-created ServiceAccount specifically for indexmgr chart.  | `null` |
|`bssc-indexmgr.customResourceNames.resourceNameLimit`         | Character limit for resource names to be truncated                    | `63` |
|`bssc-indexmgr.customResourceNames.indexmgrCronJobPod.indexmgrContainerName`         | Name for indexmgr cronjob pod's container                    | `null` |
|`bssc-indexmgr.customResourceNames.indexmgrCronJobPod.indexmgrInitContainerName`         | Name for indexmgr cronjob pod's init container                    | `null` |
|`bssc-indexmgr.customResourceNames.indexmgrCronJobPod.unifiedLoggingContainerName`     | Name for Unified Logging pod's container                  | `null` |
|`bssc-indexmgr.customResourceNames.deleteJob.name`         | Name for indexmgr delete job                    | `null` |
|`bssc-indexmgr.customResourceNames.deleteJob.deleteJobContainerName`         | Name for indexmgr delete job's container                   | `null` |
|`bssc-indexmgr.nameOverride`         | Use this to override name for indexmgr cronjob kubernetes object. When it is set, the name would be ReleaseName-nameOverride                 | `null` |
|`bssc-indexmgr.affinity`| Set affinity to have pod scheduling preferences |`{}`|
|`bssc-indexmgr.nodeSelector`| node labels for pod assignment |`{}`|
|`bssc-indexmgr.tolerations`| List of node taints to tolerate |`[]`|
|`bssc-indexmgr.partOf` | Use this to configure common lables for k8s objects. Set to configure label app.kubernetes.io/part-of: | `bssc-ifd` |
|`bssc-indexmgr.timezone.timeZoneEnv`         | To specify timezone value and this will have higer precedence over global.timeZoneEnv              | `null` |
|`bssc-indexmgr.jobs.affinity`|To provide affinity for jobs and helm test pods |`null`|
|`bssc-indexmgr.jobs.nodeSelector`|To provide nodeSelector for jobs and helm test pods |`null`|
|`bssc-indexmgr.jobs.tolerations`|To provide tolerations for jobs and helm test pods |`null`|
|`bssc-indexmgr.imagePullSecrets`| Indexmgr imagePullSecrets configured at root level. It takes higher precedence over imagePullSecrets configured at global level |`null`|
|`bssc-indexmgr.customResourceNames.helmTestPod.name`         | Name for indexmgr helm test pod                    | `null` |
|`bssc-indexmgr.customResourceNames.helmTestPod.helmTestContainerName`         | Name for indexmgr helm test pod's container                   | `null` |
|`bssc-indexmgr.fullnameOverride`         | Use this to configure custom-name for indexmgr cronjob kubernetes object.  If both nameOverride and fullnameOverride are specified, fullnameOverride would take the precedence.                  | `null` |
|`bssc-indexmgr.enableDefaultCpuLimits`   |Enable this flag to set pod CPU resources limit for all indexmgr containers. It has no value set by default. |`null`|
|`bssc-indexmgr.crossClusterReplication.stopReplicationFollowerIndices`| Stop replication for the follower Indices when CCR enabled |`false`|
|`bssc-indexmgr.imageFlavor`| Indexmgr imageFlavor configured at root value. It takes higher precedence over imageFlavor configured at global level | `null` |
|`bssc-indexmgr.imageFlavorPolicy`| Indexmgr imageFlavor policy configured at root value. It takes higher precedence over imageFlavor policy configured at global level. Accepted values: Strict or BestMatch(Default) |`null`|
|`bssc-indexmgr.indexmgr.image.repo`| Indexmgr image repo name. | `bssc-indexmgr` |
|`bssc-indexmgr.indexmgr.image.flavor` | Image flavor name for indexmgr main and init container. | `null` |
|`bssc-indexmgr.indexmgr.image.flavorPolicy` | Image flavor policy for indexmgr container. Accepted values: Strict or BestMatch(Default) |`null`|
|`bssc-indexmgr.indexmgr.imageFlavor` | Image flavor name for indexmgr workload. | `null` |
|`bssc-indexmgr.indexmgr.imageFlavorPolicy` | Image flavor policy for indexmgr workload. Accepted values: Strict or BestMatch(Default) |`null`|
|`bssc-indexmgr.indexmgr.resources`| CPU/Memory/ephemeral-storage resource requests/limits for Indexmgr pod   | `limits:       cpu: ""(120m if enableDefaultCpuLimits is true)       memory: "120Mi" ephemeral-storage: "100Mi"     requests:       cpu: "100m"       memory: "100Mi" ephemeral-storage: "100Mi"` |
|`bssc-indexmgr.indexmgr.schedule`|Indexmgr cronjob schedule|`0 1 * * *`|
|`bssc-indexmgr.indexmgr.priorityClassName`  |Indexmgr pod priority class name. When this is set, it takes precedence over priorityClassName set at global level |`null`
|`bssc-indexmgr.indexmgr.imagePullSecrets` | Indexmgr imagePullSecrets configured at workload level. It takes higher precedence over imagePullSecrets configured at root or global levels |`null`|
|`bssc-indexmgr.indexmgr.securityContext.enabled`|To enable/disable security context |`true`|
|`bssc-indexmgr.indexmgr.securityContext.runAsUser`|UID with which the container will be run|`1000`|
|`bssc-indexmgr.indexmgr.securityContext.fsGroup`|Group ID that is assigned for the volumemounts mounted to the pod|`1000`|
|`bssc-indexmgr.indexmgr.securityContext.supplementalGroups`|     The supplementalGroups ID applies to shared storage volumes|`commented out by default`|
|`bssc-indexmgr.indexmgr.securityContext.seLinuxOptions`|SELinux label to a indexmgr container|`commented out by default`|
|`bssc-indexmgr.indexmgr.containerSecurityContext.seccompProfile.type`|Provision to configure  seccompProfile for IndexManager containers |`RuntimeDefault`|
| `bssc-indexmgr.indexmgr.custom.cronjob.annotations`        |  Indexmgr cronjob specific annotations                                                      | `null` |
| `bssc-indexmgr.indexmgr.custom.cronjob.labels`        |  Indexmgr cronjob specific labels                                                      | `null` |
| `bssc-indexmgr.indexmgr.custom.pod.annotations`        |  Indexmgr pod specific annotations                                                      | `null` |
| `bssc-indexmgr.indexmgr.custom.pod.labels`        |  Indexmgr pod specific labels                                                      | `null` |
| `bssc-indexmgr.indexmgr.custom.hookJobs.job.annotations`        |  Indexmgr helm hook jobs specific annotations                                               | `null` |
| `bssc-indexmgr.indexmgr.custom.hookJobs.job.labels`        |  Indexmgr helm hook jobs specific labels                                               | `null` |
| `bssc-indexmgr.indexmgr.custom.hookJobs.pod.annotations`        |  Indexmgr helm hook & test pods specific annotations | `null` |
| `bssc-indexmgr.indexmgr.custom.hookJobs.pod.labels`        |  Indexmgr helm hook & test pods specific labels                        | `null` |
|`bssc-indexmgr.indexmgr.unifiedLogging.enabled`              | enable/disable unified logging for Indexmgr pod                    | `true` |
|`bssc-indexmgr.indexmgr.unifiedLogging.imageRepo`              | Unified logging fluentd sidecar image repo name. | `bssc-fluentd` |
|`bssc-indexmgr.indexmgr.unifiedLogging.imageFlavor` | Image flavor name for fluentd sidecar container. | `null` |
|`bssc-indexmgr.indexmgr.unifiedLogging.imageFlavorPolicy` | Image flavor policy for fluentd sidecar container. Accepted values: Strict or BestMatch(Default) |`null`|
|`bssc-indexmgr.indexmgr.unifiedLogging.extension` | list of extended fields that component can use to enrich the log event | `null` |
|`bssc-indexmgr.indexmgr.unifiedLogging.syslog.enabled`      | Enable sending logs to syslog. Takes precedence over global.unifiedLogging.syslog.enabled | `null(false)` |
|`bssc-indexmgr.indexmgr.unifiedLogging.syslog.facility`      | Syslog facility   | `null` |
|`bssc-indexmgr.indexmgr.unifiedLogging.syslog.host`      | Syslog server host name to connect to  | `null` |
|`bssc-indexmgr.indexmgr.unifiedLogging.syslog.port`      | Syslog server port to connect to  | `null` |
|`bssc-indexmgr.indexmgr.unifiedLogging.syslog.protocol`      | Protocol to connect to syslog server. Ex. TCP | `null` |
|`bssc-indexmgr.indexmgr.unifiedLogging.syslog.caCrt.secretName`      | Name of secret containing syslog CA certificate | `null` |
|`bssc-indexmgr.indexmgr.unifiedLogging.syslog.caCrt.key`      | Key in secret containing syslog CA certificate | `null` |
|`bssc-indexmgr.indexmgr.unifiedLogging.syslog.tls.secretRef.name`      | Name of secret containing syslog CA certificate.  It takes higher precedence over syslog.caCrt.secretName. | `null` |
|`bssc-indexmgr.indexmgr.unifiedLogging.syslog.tls.secretRef.keyNames.caCrt`     | Key in secret containing syslog CA certificate.  It takes higher precedence over syslog.caCrt.key. | `ca.crt` |
|`bssc-indexmgr.indexmgr.jobSpec.successfulJobsHistoryLimit`|Number of successful CronJob executions that are saved|`Even though the value is commented, K8S default value is 5`|
|`bssc-indexmgr.indexmgr.jobSpec.failedJobsHistoryLimit`|Number of failed CronJob executions that are saved|`Even though the value is commented, K8S default value is 3`|
|`bssc-indexmgr.indexmgr.jobSpec.concurrencyPolicy`|Specifies how to treat concurrent executions of a Job created by the CronJob controller|`Even though the value is commented, K8S default value is Allow`|
|`bssc-indexmgr.indexmgr.jobTemplateSpec.backoffLimit`|Specifies the number of retries before considering a Job as failed|`default value is commented out`|
|`bssc-indexmgr.indexmgr.jobTemplateSpec.activeDeadlineSeconds`|Duration of the job, no matter how many Pods are created. Once a Job reaches  activeDeadlineSeconds, all of its running Pods are terminated|`default value is commented out`|
|`bssc-indexmgr.indexmgr.configMaps.preCreatedConfigmap`|Name of pre-created configmap. The configmap must contain the files actions.yml,  curator.yml. When the value is set, BSSC chart doesn’t create indexmgr configmap.|`null`|
|`bssc-indexmgr.indexmgr.configMaps.action_file_yml`|It is a YAML configuration file. The root key must be actions, after which there can be  any number of actions, nested underneath numbers|`delete indices older than 7 days using age filter`|
|`bssc-indexmgr.indexmgr.configMaps.config_yml`|The configuration file contains client connection and settings for logging|`connects to indexsearch service on 9200 port via http`|
|`bssc-indexmgr.indexmgr.certificate.enabled` | If cert manager is enabled, certificate will be created as per it's configured in this section | `true` |
|`bssc-indexmgr.indexmgr.certificate.issuerRef.name`| Name of certificate issuer | `null` |
|`bssc-indexmgr.indexmgr.certificate.issuerRef.kind` | Kind of Issuer | `null` |
|`bssc-indexmgr.indexmgr.certificate.issuerRef.group` | Certificate Issuer Group Name | `null` |
|`bssc-indexmgr.indexmgr.certificate.duration`| How long certificate will be valid |`null` |
|`bssc-indexmgr.indexmgr.certificate.renewBefore` | When to renew the certificate before it gets expired |`null` |
|`bssc-indexmgr.indexmgr.certificate.secretName` | Name of the secret in which this cert would be added| `null` |
|`bssc-indexmgr.indexmgr.certificate.subject`| Certificate subject | `null`|
|`bssc-indexmgr.indexmgr.certificate.commonName` | CN of certificate | `null` |
|`bssc-indexmgr.indexmgr.certificate.usages ` | Certificate usage | `null` |
|`bssc-indexmgr.indexmgr.certificate.dnsNames ` | DNSNames is a list of DNS subjectAltNames to be set on the Certificate.| `null` |
|`bssc-indexmgr.indexmgr.certificate.uris` | URIs is a list of URI subjectAltNames to be set on the Certificate.| `null`|
|`bssc-indexmgr.indexmgr.certificate.ipAddresses`| IPAddresses is a list of IP address subjectAltNames to be set on the Certificate.|`null`|
|`bssc-indexmgr.indexmgr.certificate.privateKey.algorithm`| Algorithm is the private key algorithm of the corresponding private key for this certificate | `null`|
|`bssc-indexmgr.indexmgr.certificate.privateKey.encoding`| The private key cryptography standards (PKCS) encoding for this certificate’s private key | `null`|
|`bssc-indexmgr.indexmgr.certificate.privateKey.size`| Size is the key bit size of the corresponding private key for this certificate. | `null` |
|`bssc-indexmgr.indexmgr.certificate.privateKey.rotationPolicy`| Rotation of a key pair, when certificate is refreshed is recommended from a security point of view | `Always` |
|`bssc-indexmgr.emptyDirSizeLimit.dryrunLogs`|Configure the sizeLimit of indexmgr-logs emptyDir|`10Mi`|
|`bssc-indexmgr.emptyDirSizeLimit.indexmgrLogs`|Configure the sizeLimit of indexmgr-logs emptyDir|`100Mi`|
|`bssc-indexmgr.emptyDirSizeLimit.sharedVolume`|Configure the sizeLimit of shared-volume emptyDir|`10Mi`|


Specify parameters using `--set key=value[,key=value]` argument to `helm install`

```
helm install my-release --set bssc-indexsearch.istio.enabled=true <chart-repo> --namespace logging
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```
helm install my-release -f values.yaml <chart-repo> --namespace logging

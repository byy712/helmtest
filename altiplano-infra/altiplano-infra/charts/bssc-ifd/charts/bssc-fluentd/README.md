# Fluentd

Fluentd is an open-source data collector for unified logging layer. It allows you to unify data collection and consumption for a better use and understanding of data.

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

The command deploys fluentd on the Kubernetes cluster in the default configuration. The Parameters section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list -A`

## Uninstalling the Chart:
To uninstall/delete the `my-release` deployment:
```
helm delete my-release --namespace logging
```
The command removes all the Kubernetes components associated with the chart and deletes the release.

## Pod Security Standards
Helm chart can be installed in namespace with `restricted` Pod Security Standards profile only when enable_root_privilege is false i.e, Fluentd won't be able to read container logs.

`values.yaml` parameters required to enable this case.
```yaml
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

#### Installation with Root Privilege Enabled 
In this case, Helm chart must be installed in namespace with `privileged` Pod Security Standards profile as Fluentd requires 'HostPath' volume which is out of `restricted` profile.

`values.yaml` parameters required to enable this case (i.e, to read container logs):
```yaml
rbac:
  enabled: true
  psp:
    create: false

fluentd:
  enable_root_privilege: true
  volume_mount_enable: true
  containerSecurityContext:
    runAsNonRoot: false
```

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
The following table lists the configurable parameters of the FluentD chart and their default values.

|   Parameter             |Description                                  |Default                              |
|----------------|-------------------------------|----------------------------|
|`global.registry`|Global container image registry for all images |`csf-docker-delivered.repo.cci.nokia.net`|
|`global.flatRegistry`   |Enable this flag to read image registries with a flat structure. It is disabled by default. |`false`|
|`global.enableDefaultCpuLimits`   |Enable this flag to set pod CPU resources limit for all containers. It is disabled by default. |`false`|
|`global.seccompAllowedProfileNames` | Annotation that specifies which values are allowed for the pod seccomp annotations |`docker/default` |
|`global.seccompDefaultProfileName`  | Annotation that specifies the default seccomp profile to apply to containers      | `docker/default` |
|`global.podNamePrefix`  | Prefix to be added for pods and jobs names      | `null` |
|`global.disablePodNamePrefixRestrictions` |  Enable if podNamePrefix need to be added to the pod name without any restrictions. It is disabled by default.| `false`  |
|`global.certManager.enabled` |Enable cert-Manager feature using this flag. It is enabled by default.|`true`|
|`global.containerNamePrefix`  | Prefix to be added for pod containers and job container names       | `null` |
|`global.priorityClassName`  | priorityClassName for fluentd pods, set at global level | `null` | 
|`global.imagePullSecrets`  | ImagePullSecrets configured at global level. | `null` |
|`global.annotations`  | Annotations configured at global level. These will be added at both pod level and the workload(daemonset/statefulset/deployment) level for fluentd | `null` |
|`global.label`  | Label configured at global level. These will be added at both pod level and the workload(daemonset/statefulset/deployment) level for fluentd | `null` |
|`global.istio.version`|Istio version defined at global level. Accepts version in numeric X.Y format. |`1.7`|
|`global.istio.cni.enabled`|Whether istio cni is enabled in the environment: true/false |`true`|
|`global.timeZoneEnv`         | To specify global timezone value             | `UTC` |
|`global.ipFamilyPolicy`      | ipFamilyPolicy for dual-stack support configured at global scope  | `null` |
|`global.ipFamilies`      | ipFamilies for dual-stack support configured at global scope  | `null` |
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
|`global.unifiedLogging.syslog.tls.secretRef.keyNames.caCrt`     | Key in secret containing syslog CA certificate.  It takes higher precedence over syslog.caCrt.key | `ca.crt` |
|`global.imageFlavor`| set imageFlavor at global level |`null`|
|`global.imageFlavorPolicy`| set imageFlavorPolicy at global level. Accepted values: Strict or BestMatch |`null`|
|`rbac.enabled`        |Enable/disable rbac. When rbac.enabled is set to true, charts would create its own rbac related resources; If false, an external serviceAccountName set in values will be used. |`true`|
|`rbac.psp.create`    | If set to true, then chart creates its own PSPs only if required; If set to false, then chart do not create PSPs. | `true` |
|`rbac.psp.annotations`  | Annotation to be set when 'containerSecurityContext.seccompProfile.type' is configured or if required only | `seccomp.security.alpha.kubernetes.io/allowedProfileNames: '*'` |
|`rbac.scc.create`    | If set to true, then chart creates its own SCCs only if required; If set to false, then chart do not create SCCs. | `false` |
|`rbac.scc.annotations`    | To set annotations for SCCs only if required;   | `null` |
|`serviceAccountName`         | Pre-created ServiceAccount specifically for fluentd chart.                    | `null` |
|`customResourceNames.resourceNameLimit`         | Character limit for resource names to be truncated                    | `63` |
|`customResourceNames.fluentdPod.fluentdContainerName`         | Name for fluentd pod's container                    | `null` |
|`customResourceNames.fluentdPod.fluentdInitContainerName`         | Name for fluentd pod's init container                    | `null` |
|`customResourceNames.fluentdPod.unifiedLoggingContainerName`         | Name for fluentd pod's unified logging container                    | `null` |
|`customResourceNames.scaleinJob.name`         | Name for fluentd scalein job                    | `null` |
|`customResourceNames.scaleinJob.postscaleinContainerName`         | Name for fluentd scalein job's container                   | `null` |
|`customResourceNames.deletePvcJob.name`         | Name for fluentd delete PVC job                    | `null` |
|`customResourceNames.deletePvcJob.deletePvcContainerName`         | Name for fluentd delete pvc job's container                   | `null` |
|`customResourceNames.helmTestPod.name`         | Name for helm test pod                    | `null` |
|`customResourceNames.helmTestPod.helmTestContainerName`         | Name for helm test pod's container         | `null` |
|`customResourceNames.deleteJob.name` | Name for fluentd delete job | `null`|
|`customResourceNames.deleteJob.deleteJobContainerName` | Name for fluentd delete job's container | `null`|
|`customResourceNames.preUpgradePvMigrateJob.name` | Name for fluentd preUpgradePvMigrate job | `null`|
|`customResourceNames.preUpgradePvMigrateJob.preUpgradePvMigrateContainerName` | Name for fluentd preUpgradePvMigrate job's container | `null`|
|`disablePodNamePrefixRestrictions` |   disablePodNamePrefixRestrictions configured at root level. It takes higher precedence over disablePodNamePrefixRestrictions configured at global level  | `false`  |
|`nameOverride`         | Use this to override name for fluentd deployment/sts/deamonset kubernetes object. When it is set, the name would be ReleaseName-nameOverride            | `null` |
|`fullnameOverride`         | Use this to configure custom-name for fluentd deployment/sts/deamonset kubernetes object.  If both nameOverride and fullnameOverride are specified, fullnameOverride would take the precedence.             | `null` |
|`enableDefaultCpuLimits`   |Enable this flag to set pod CPU resources limit for all containers. It has no value set by default. |`null`|
| `partOf`  | Use this to configure common lables for k8s objects. Set to configure label app.kubernetes.io/part-of: | `null` |
|`timezone.timeZoneEnv`         | To specify timezone value and this will have higer precedence over global.timeZoneEnv         | `UTC` |
|`global.postscalein`       |To trigger postscale job hooks          |`0`|
|`imagePullSecrets`| Fluentd imagePullSecrets configured at root level. It takes higher precedence over imagePullSecrets configured at global level |`null`|
|`ipFamilyPolicy`|ipFamilyPolicy for dual-stack support configured at chart level. Allowed values: SingleStack, PreferDualStack,RequireDualStack |`null`|
|`ipFamilies`|ipFamilies for dual-stack support configured at chart level. Allowed values: ["IPv4"], ["IPv6"], ["IPv4","IPv6"], ["IPv6","IPv4"] |`null`|
|`certManager.enabled` |Enable cert-Manager feature using this flag when security is enabled. It is disabled by default.It takes higher precedence over certManager.enabled at global level.|`null`|
|`imageFlavor`| set imageFlavor at root level |`null`|
|`imageFlavorPolicy`| set imageFlavorPolicy at root level. Allowed values : Strict or BestMatch |`null`|
|`fluentd.kind`       |Configure fluentd kind like Deployment,DaemonSet,Statefulset         |`DaemonSet`|
|`fluentd.image.repo`       |Fluentd image name.|`bssc-fluentd`|
|`fluentd.image.tag`       |Fluentd image tag. Accepted values are 1.16.2-2311.0.1, 1.16.2-rocky8-jre11-2311.0.1 or 1.16.2-rocky8-jre17-2311.0.1 |`1.16.2-2311.0.1`|
| `fluentd.image.initRepo`      | Fluentd init container image name. | `bssc-init` |
| `fluentd.image.initTag`                 | Fluentd init container image tag. Accepted values are 1.0.0-2311.0.1, 1.0.0-rocky8-jre11-2311.0.1 or 1.0.0-rocky8-jre17-2311.0.1 | `1.0.0-2311.0.1` |
|`fluentd.image.flavor`| set flavor at container level for main container & init container |`null`|
|`fluentd.image.flavorPolicy`| set flavorPolicy at container level for main container & init container. Allowed Values: Strict or BestMatch |`null`|
|`fluentd.ImagePullPolicy`       |Fluentd image pull policy         |`IfNotPresent`|
|`fluentd.imageFlavor`| set imageFlavor at workload level |`null`|
|`fluentd.imageFlavorPolicy`| set imageFlavorPolicy at workload level. Accepted values: Strict or BestMatch |`null`|
|`fluentd.init_resources`        | CPU/Memory resource requests/limits/ephemeral-storage for fluentd initContainer        |`resources:  limits:  cpu: "" (100m if enableDefaultCpuLimits is true)  memory: "100Mi"  ephemeral-storage: "30Mi" requests:  cpu: "50m" memory: "50Mi" ephemeral-storage: "30Mi"`|
|`fluentd.replicas`       |Desired number of fluentd replicas when the kind is Deployment or Statefulset        |`1`|
|`fluentd.podManagementPolicy`       |Fluentd pod management policy          |`Parallel`|
|`fluentd.updateStrategy.type`       |Fluentd pod update strategy policy         |`RollingUpdate`|
|`fluentd.statefulsetSuffix`       |Suffix for fluentd statefulset object name        |`statefulset`|
|`fluentd.daemonsetSuffix`       |Suffix for fluentd daemonset object name   |`daemonset`|
|`fluentd.priorityClassName`	  |Fluentd pod priority class name. When this is set, it takes precedence over priorityClassName set at global level |`null`|
|`fluentd.imagePullSecrets`| Fluentd imagePullSecrets configured at workload level. It takes higher precedence over imagePullSecrets configured at root or global levels  |`null`|
|`fluentd.securityContext.enabled` | To enable/disable security context for fluentd. | `true`| 
|`fluentd.securityContext.runAsUser` | UID with which the containers will be run. Set to auto if using random userids in openshift environment. |`1000`|
|`fluentd.securityContext.fsGroup` |Group ID for the container|`998`|
|`fluentd.securityContext.supplementalGroups`       |SupplementalGroups ID applies to shared storage volumes         |`998`|
|`fluentd.securityContext.seLinuxOptions.level`       |Configure SELinux for fluentd container         |`s0:c23,c123`|
|`fluentd.securityContext.privileged`       |When docker_selinux is enabled on BCMT, to read /var/log/messages, set privileged as True in securityContext  and set this to True to read container logs on Openshift  |`false`|
|`fluentd.containerSecurityContext.runAsNonRoot` | Set this to True to run containers as a non-root user. When enable_root_privilege is set to 'true', fluentd containers will run as root user (runAsNonRoot: false) irrespective of value configured in runAsNonRoot. |`true`|
|`fluentd.containerSecurityContext.seccompProfile.type`| Provision to configure  seccompProfile for Fluentd containers |`RuntimeDefault`|
|`fluentd.custom.k8sKind.annotations`       |Fluentd workload (daemonset/statefulset/deployment) specific annotations         |`{}`|
|`fluentd.custom.k8sKind.labels`       |Fluentd workload (daemonset/statefulset/deployment) specific labels         |`{}`|
|`fluentd.custom.pod.annotations`       |Fluentd pod specific annotations         |`{}`|
|`fluentd.custom.pod.labels`       |Fluentd pod specific labels          |`{}`|
|`fluentd.custom.hookJobs.job.annotations`       |Fluentd helm hook jobs specific annotations         |`{}`|
|`fluentd.custom.hookJobs.job.labels`       |Fluentd helm hook jobs specific labels         |`{}`|
|`fluentd.custom.hookJobs.pod.labels`       |Fluentd helm hook & test pods specific labels         |`{}`|
|`fluentd.custom.hookJobs.pod.annotations`       |Fluentd helm hook & test pods specific annotations         |`{}`|
|`fluentd.resources`|CPU/Memory resource requests/limits/ephemeral-storage for fluentd pod|`resources:  limits:  cpu: ""(1 if enableDefaultCpuLimits is true)  memory: "1Gi" ephemeral-storage: "500Mi" requests:  cpu: "600m" memory: "500Mi" ephemeral-storage: "200Mi"`|
|`fluentd.EnvVars.system`|Configure system name for non-container log messages|`BCMT`|
|`fluentd.EnvVars.systemId`|Configure system id for non-container log messages|`BCMT ID`|
|`fluentd.env`|Configure additional desired environment variables|`{}`|
|`fluentd.enable_root_privilege`|Enable root privilege to read container, journal logs|`true`|
|`fluentd.pdb.enabled` |  To enable/disable creation of Pod Disruption budget for fluentd pods. If kind is daemonset (default), this section is not applicable and PDB is not created. If kind is statefulset/deployment, PDB can be enabled.| `false` |
|`fluentd.pdb.minAvailable` |  Minimum number of fluentd pods that must be available when disruption happens. Atleast 50% of the fluentd pods are recommended to be up to handle the incoming traffic. The minAvailable value can be changed based on need and incoming load. As default replica of fluentd is 1 and pdb.minAvailable is 50% when kind is configured as Deployment/statefulset, it will not allow to drain the node and service will not get interrupted. If user still wants to drain the node: option 1: If service outage is not acceptable - increase the num of replicas for fluentd so that the PDB conditions are met. option 2: If service outage is acceptable -  either disable PDB or set minAvailable to empty and maxUnavailable to 1 so that node can be drained.|`50%`|
|`fluentd.pdb.maxUnavailable` | Maximum number for fluentd pods that can be unavailable when disruption happens |`null`|
|`fluentd.mountSAToken`| Set this to true if service account token needs to be mounted inside fluentd pod i.e pod requires access to kubernetes api |`false`|
| `fluentd.sensitiveInfoInSecret.enabled`             | Enable this to take sensitive data from secret            | `false` |
| `fluentd.sensitiveInfoInSecret.credentialName`             | Name of the pre-created secret which contains sensitive information.             | `null` |
| `fluentd.sensitiveInfoInSecret.secretData`             | List of all the sensitive data required in key:val format.             | `null` |
| `fluentd.serverCerts`             | List of server certificates supplied by user via Kubernetes Secret            | `[]` |
|`fluentd.certManager.enabled` |Enable cert-Manager feature using this flag when security is enabled. By default, it reads same value as configured in certManager.enabled (root level). It takes higher precedence over certManager.enabled at root and global levels|`{{ Values.certManager.enabled }}`|
|`fluentd.certManager.apiVersion` |Api version of the cert-manager.io | `cert-manager.io/v1alpha3`
|`fluentd.certManager.duration` |How long certificate will be valid|`8760h`
|`fluentd.certManager.renewBefore` |When to renew the certificate before it gets expired|`360h`
|`fluentd.certManager.issuerRef.name` |Issuer Name | `ncms-ca-issuer`
|`fluentd.certManager.issuerRef.kind` |CRD Name | `ClusterIssuer`
|`fluentd.certManager.issuerRef.group` |Certificate Issuer Group Name| `cert-manager.io`
|`fluentd.fluentd_config`|Fluentd configuration to read data. Configurable values are bssc, bssc-cri, clog-json,clog-journal,custom-value|`bssc`|
|`fluentd.configFile`|`If own configuration for fluentd other than provided by bssc/clog then set fluentd_config: custom-value and provide the configuration here'| `null`|
|`fluentd.service.enabled`|Enable fluentd service|`false`|
|`fluentd.service.custom_name`|Configure fluentd custom service name |`null`|
|`fluentd.service.type`|Kubernetes service type|`ClusterIP`|
|`fluentd.service.metricsPort`|fluentd-prometheus-plugin port|`24231`|
|`fluentd.service.annotations`|fluentd service annotations|`{}`|
|`fluentd.service.protocol`|Fluentd service protocol|`TCP`|
|`fluentd.service.appProtocol`|Fluentd service app protocol|`tcp`|
|`fluentd.forward_service.enabled`|Enable fluentd forward service|`false`|
|`fluentd.forward_service.custom_name`|Configure fluentd custom forwarder service name|`null`|
|`fluentd.forward_service.port`|Fluentd forward service port|`24224`|
|`fluentd.forward_service.protocol`|Fluentd forward service protocol|`TCP`|
|`fluentd.forward_service.appProtocol`|Fluentd forward service application protocol|`tcp`|
|`fluentd.forward_service.type`|Kubernetes service type|`ClusterIP`|
|`fluentd.forward_service.annotations`|fluentd forward service annotations|`{}`|
|`fluentd.volume_mount_enable`|Enable volume mount for fluentd pod. When fluentd is running as non-root user disable the flag|`true`|
|`fluentd.volumes`|Mount volume  for fluentd pods|`/var/log and /data0/docker volumes of hostpath are mounted`|
|`fluentd.volumeMounts`|Location to mount the above volumes inside the container| `Above volumes are mounted to /var/log and /data0/docker locations inside the container`|
|`fluentd.allowedHostPathsInPSP`|List of hostpath location to be allowed in PSP | ` /var/log and /data0/docker locations are allowed`|
|`fluentd.nodeSelector`|Node labels for fluentd pod assignment|`{}`|
|`fluentd.tolerations`|List of node taints to tolerate (fluentd pods)|`Toleration for NoExecute taint`|
|`fluentd.livenessProbe.initialDelaySeconds`|Delay before liveness probe is initiated|`30`|
|`fluentd.livenessProbe.periodSeconds`|How often to perform the probe|`20`|
|`fluentd.livenessProbe.timeoutSeconds`|When the probe times out|`1`|
|`fluentd.livenessProbe.successThreshold`|Minimum consecutive successes for the probe|`1`|
|`fluentd.livenessProbe.failureThreshold`|Minimum consecutive failures for the probe|`3`|
|`fluentd.readinessProbe.initialDelaySeconds`|Delay before readiness probe is initiated|`30`|
|`fluentd.readinessProbe.periodSeconds`|How often to perform the probe|`10`|
|`fluentd.readinessProbe.timeoutSeconds`|When the probe times out|`1`|
|`fluentd.readinessProbe.successThreshold`|Minimum consecutive successes for the probe|`1`|
|`fluentd.readinessProbe.failureThreshold`|Minimum consecutive failures for the probe|`3`|
|`fluentd.replicasManagedByHpa`| Depending on the value replicas will be managed by either HPA or deployment | `false` |
|`fluentd.hpa.enabled`| Enable/Disable HorizontalPodAutoscaler. Supported only for the kind Deployment  | `null(false)` |
|`fluentd.hpa.minReplicas` | Minimum replica count to which HPA can scale down | `1` |
|`fluentd.hpa.maxReplicas` | Maximum replica count to which HPA can scale up | `3` |
|`fluentd.hpa.predefinedMetrics.enabled` | Enable/Disable default memory/cpu metrics monitoring on HPA | `true` |
|`fluentd.hpa.averageCPUThreshold` | HPA keeps the average cpu utilization of all the pods below the value set | `85` |
|`fluentd.hpa.averageMemoryThreshold` | HPA keeps the average memory utilization of all the pods below the value set | `85` |
|`fluentd.hpa.behavior` | Additional behavior to be set here | `empty` |
|`fluentd.hpa.metrics` | Additional metrics to monitor can be set here | `empty` |
|`fluentd.affinity`|Fluentd pod anti-affinity policy|`{}`|
|`fluentd.topologySpreadConstraints`|topologySpreadConstraints for fluentd |`{}`|
|`fluentd.persistence.storageClassName`|Persistent Volume Storage Class|`null`|
|`fluentd.persistence.accessMode`|Persistent Volume Access Modes|`ReadWriteOnce`|
|`fluentd.persistence.size`|Persistent Volume Size|`10Gi`|
|`fluentd.persistence.pvc_auto_delete`|Persistent Volume auto delete when chart is deleted |`false`|
|`fluentd.unifiedLogging.enabled` | enable/disable unified logging for fluentd logs. | `true` |
|`fluentd.unifiedLogging.imageRepo` | image repo for fluentd sidecar used in fluentd pod to convert fluentd logs into unified-logging format. | `bssc-fluentd` |
|`fluentd.unifiedLogging.imageTag` | image tag for fluentd sidecar. Accepted values are 1.16.2-2311.0.1, 1.16.2-rocky8-jre11-2311.0.1 or 1.16.2-rocky8-jre17-2311.0.1 | `1.16.2-2311.0.1` |
|`fluentd.unifiedLogging.imageFlavor` | set imageFlavor for fluentd sidecar |`null`|
|`fluentd.unifiedLogging.imageFlavorPolicy`| set imageFlavorPolicy for fluentd sidecar. Accepted values: Strict or BestMatch |`null`|
|`fluentd.unifiedLogging.imagePullPolicy` | image pull policy for fluentd sidecar | `IfNotPresent`|
|`fluentd.unifiedLogging.resources` | CPU/Memory/ephemeral-storage resource requests/limits for fluentd sidecar |`limits: CPU/Mem/ephemeral-storage (50m if enableDefaultCpuLimits is true)/100Mi/500Mi , requests: CPU/Mem/ephemeral-storage 20m/80Mi/200Mi`|
|`fluentd.unifiedLogging.syslog.enabled`      | Enable sending logs to syslog. Takes precedence over global.unifiedLogging.syslog.enabled | `null(false)` |
|`fluentd.unifiedLogging.syslog.facility`      | Syslog facility   | `null` |
|`fluentd.unifiedLogging.syslog.host`      | Syslog server host name to connect to  | `null` |
|`fluentd.unifiedLogging.syslog.port`      | Syslog server port to connect to  | `null` |
|`fluentd..unifiedLogging.syslog.protocol`      | Protocol to connect to syslog server. Ex. TCP | `null` |
|`fluentd..unifiedLogging.syslog.caCrt.secretName`      | Name of secret containing syslog CA certificate | `null` |
|`fluentd.unifiedLogging.syslog.caCrt.key`      | Key in secret containing syslog CA certificate | `null` |
|`fluentd.unifiedLogging.syslog.tls.secretRef.name`      | Name of secret containing syslog CA certificate.  It takes higher precedence over syslog.caCrt.secretName. | `null` |
|`fluentd.unifiedLogging.syslog.tls.secretRef.keyNames.caCrt`     | Key in secret containing syslog CA certificate.  It takes higher precedence over syslog.caCrt.key. | `ca.crt` |
|`fluentd.unifiedLogging.syslog.appLogBufferSize`      | Size of buffer for fluentd pod logs sent to syslog | `70MB` |
|`fluentd.unifiedLogging.extension` | list of extended fields that component can use to enrich the log event | `null` |
|`fluentd.unifiedLogging.env` | ENV parameters to be added in fluentd sidecar container | `null` |
|`fluentd.certificate.enabled` | If cert manager is enabled, certificate will be created as per it's configured in this section | `true` |
|`fluentd.certificate.issuerRef.name`| Name of certificate issuer | `null` |
|`fluentd.certificate.issuerRef.kind` | Kind of Issuer | `null` | 
|`fluentd.certificate.issuerRef.group` | Certificate Issuer Group Name | `null` | 
|`fluentd.certificate.duration`| How long certificate will be valid |`null` |
|`fluentd.certificate.renewBefore` | When to renew the certificate before it gets expired |`null` |
|`fluentd.certificate.secretName` | Name of the secret in which this cert would be added| `null` |
|`fluentd.certificate.subject`| Certificate subject | `null`|
|`fluentd.certificate.commonName` | CN of certificate | `null` |
|`fluentd.certificate.usages ` | Certificate usage | `null` |
|`fluentd.certificate.dnsNames ` | DNSNames is a list of DNS subjectAltNames to be set on the Certificate.| `null` |
|`fluentd.certificate.uris` | URIs is a list of URI subjectAltNames to be set on the Certificate.| `null`|
|`fluentd.certificate.ipAddresses`| IPAddresses is a list of IP address subjectAltNames to be set on the Certificate.|`null`|
|`fluentd.certificate.privateKey.algorithm`| Algorithm is the private key algorithm of the corresponding private key for this certificate | `null`|
|`fluentd.certificate.privateKey.encoding`| The private key cryptography standards (PKCS) encoding for this certificate’s private key | `null`|
|`fluentd.certificate.privateKey.size`| Size is the key bit size of the corresponding private key for this certificate. | `null` |
|`fluentd.certificate.privateKey.rotationPolicy`| Rotation of a key pair, when certificate is refreshed is recommended from a security point of view | `Always` |
|`upgrade.autoMigratePV`|Due to asset name changes, fluentd PV has to be migrated to retain old data. Use this flag if upgrading from BELK 22.06. For subsequent upgrades(like update configuration) the value has to be false|`false`|
|`cbur.enabled`|Enable cbur for backup and restore operation|`true`|
|`cbur.maxcopy`|Maxcopy of backup files to be stored|`5`|
|`cbur.backendMode`|Configure the mode of backup. Available options are local","NETBKUP","AVAMAR","CEPHS3","AWSS3"|`local`|
|`cbur.cronJob`|Configure cronjob timings to take backup|`0 23 * * *`|
|`cbur.autoEnableCron`|AutoEnable Cron property to take backup as per configured cronjob|`true`|
|`cbur.autoUpdateCron`|AutoUpdate cron to update cron job timings|`false`|
|`istio.enabled`|Enable istio using this flag|`false`|
|`istio.version`|Istio version specified at chart level. If defined here,it takes precedence over global level. Accepts istio version in numeric X.Y format. Ex. 1.7|`null`|
|`istio.cni.enabled`|Whether istio cni is enabled in the environment: true/false |`null`|
|`istio.createDrForClient`| This optional flag should only be used when application was installed in istio-injection=enabled namespace, but was configured with istio.enabled=false, thus istio sidecar could not be injected into this application |`false`|
|`istio.customDrSpecForClientPrometheusSvc` | This configurations will be used for configuring spec of DestinationRule  when createDrForClient flag is enabled | `mode: DISABLE`|
|`istio.customDrSpecForClientForwarderSvc` | This configurations will be used for configuring spec of DestinationRule  when createDrForClient flag is enabled | `mode: DISABLE`|
|`kubectl.image.repo`|kubectl image name|`tools/kubectl`|
|`kubectl.image.tag`| Kubectl image tag. Allowed Values: 1.26.11-20231124, 1.26.11-rocky8-nano-20231124 |`1.26.11-20231124`|
|`kubectl.image.flavor`| set imageFlavor for Kubectl |`null`|
|`kubectl.image.flavorPolicy`| set imageFlavorPolicy for Kubectl. Accepted values: Strict or BestMatch |`null`|
|`kubectl.image.supportedImageFlavor`| list of imageFlavor supported by kubectl |`["rocky8-nano"]`|
|`jobs.affinity`|To provide affinity for jobs and helm test pod |`null`|
|`jobs.nodeSelector`|To provide nodeSelector for jobs and helm test pod|`null`|
|`jobs.tolerations`|To provide tolerations for jobs and helm test pod|`null`|
|`jobs.hookJobs.resources.requests`                         | CPU/Memory/ephemeral-storage resource requests for job and helm test pod            | `requests:       cpu: "100m"       memory: "100Mi"       ephemeral-storage: "50Mi" ` |
|`jobs.hookJobs.resources.limits`                           | CPU/Memory/ephemeral-storage resource limits for job and helm test pod            | `limits:       cpu: ""(120m if enableDefaultCpuLimits is true)       memory: "120Mi        ephemeral-storage: "50Mi""` |
|`emptyDirSizeLimit.tmp`|Configure the sizeLimit of tmp emptyDir| `500Mi`|
|`emptyDirSizeLimit.sensitiveConfig`|Configure the sizeLimit of sensitive-config emptyDir| `10Mi`|
|`emptyDirSizeLimit.sharedVolume`|Configure the sizeLimit of shared-volume emptyDir| `10Mi`|

Specify parameters using `--set key=value[,key=value]` argument to `helm install`

```
helm install my-release --set istio.enabled=true <chart-path> --namespace logging
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```
helm install my-release -f values.yaml <chart-path> --version <version> --namespace logging
```

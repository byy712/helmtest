

# Prometheus

[Prometheus](https://prometheus.io/), a [Cloud Native Computing Foundation](https://cncf.io/) project, is a systems and service monitoring system. It collects metrics from configured targets at given intervals, evaluates rule expressions, displays the results, and can trigger alerts if some condition is observed to be true.

```console
$ helm install stable/prometheus
```
## Introduction

This chart bootstraps a [Prometheus](https://prometheus.io/) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.13+ with Beta APIs enabled

## Configuration for openshift
```console
WARNING! Usage of auto for runAsUser and fsGroup is deprecated. These are to be configured as below.
Do not configure runAsUser and fsGroup inside the securityContext. In the key-value pair, key should be present and value of it should be empty.

Current Configuration =>
securityContext:
   runAsUser: 65530
   fsGroup: 65530

Recommended Configuration =>
securityContext:
   runAsUser:
   fsGroup:

## Configure restrictedToNamespace as true
restrictedToNamespace: true
server:
  namespaceList: ['test1','test2','test3']
  nsToExcludeFromCommonJobs: ['test2']

__TPL_INCLUDE_NS__ will include all namespaces present in namespaceList except nsToExcludeFromCommonJobs and will be replaced in the scrape jobs wherever this label is present.
__TPL_INCLUDE_NS__ will render ['test1','test3'] in all jobs where this label is present.

```
## Configuration for dual stack

For a global scope user need to set: global.ipFamilyPolicy and global.ipFamilies
For a workload level scope user need to set: ipFamilyPolicy and ipFamilies
Workload level scope has precedence over the global scope.

**ipFamilyPolicy** can be one of the following values:

SingleStack: Single-stack service
PreferDualStack: Dual-stack service
RequireDualStack: Dual-stack service

**ipFamilies** can be set to any of the following array values:
["IPv4"] (single stack)
["IPv6"] (single stack)
["IPv4","IPv6"] (dual stack)
["IPv6","IPv4"] (dual stack)


## Pod Security Standards

In restricted, node-exporter must be disabled.

If these components are enabled, we need 'priviledged' Pod Security Standard profile

### Mapping to gatekeeper constraints



If node-exporter is enabled then below constaints needs to be relaxed.

Open source Gatekeeper `K8sPSPCapabilities` (see: [capabilities](https://github.com/open-policy-agent/gatekeeper-library/blob/master/library/pod-security-policy/capabilities)) constraint need to be relaxed to allow the following additional privileges:
```yaml
        capabilities:
          add: SYS_TIME
```

Open source Gatekeeper `K8sPSPHostNamespace` (see: [Host Namespaces] (https://github.com/open-policy-agent/gatekeeper-library/tree/master/library/pod-security-policy/host-namespaces)) constraint need to be relaxed.

Open source Gatekeeper `K8sPSPHostFilesystem` (see: [HostPath Volumes] (https://github.com/open-policy-agent/gatekeeper-library/tree/master/library/pod-security-policy/host-filesystem)) constraint need to be relaxed to allow the following additional privileges:
```yaml
          allowedHostPaths:
          - pathPrefix: /proc
            readOnly: true
          - pathPrefix: /sys
            readOnly: true
          - pathPrefix: /
            readOnly: true

```

Open source Gatekeeper `K8sPSPHostNetworkingPorts` (see: [Host Ports] (https://github.com/open-policy-agent/gatekeeper-library/tree/master/library/pod-security-policy/host-network-ports)) constraint need to be relaxed.
Allowed values: {"hostNetwork": true, "max": 9000, "min": 80}
Update Node-exporter port values in below configuration:
```yaml
nodeExporter:
  service:
    podContainerPort: 9100
    podHostPort: 9100
```


## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm install --name my-release stable/prometheus
```
The command deploys Prometheus on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```console
$ helm install stable/prometheus --name my-release \
    --set server.terminationGracePeriodSeconds=360
```
Alternatively, a YAML file that specifies the values for the above parameters can be provided while installing the chart. For example,

```console
$ helm install stable/prometheus --name my-release -f values.yaml
```

> **Tip**: You can use the default [values.yaml](values.yaml)

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm delete my-release --purge
```
The command removes all the Kubernetes components associated with the chart and deletes the release.

## Prometheus 2.x

Prometheus version 2.x has made changes to alertmanager, storage and recording rules. Check out the migration guide [here](https://prometheus.io/docs/prometheus/2.0/migration/)

Users of this chart will need to update their alerting rules to the new format before they can upgrade.

## Upgrading from previous chart versions.

As of version 5.0, this chart uses Prometheus 2.1. This version of prometheus introduces a new data format and is not compatible with prometheus 1.x. It is recommended to install this as a new release, as updating existing releases will not work. See the [prometheus docs](https://prometheus.io/docs/prometheus/latest/migration/#storage) for instructions on retaining your old data.

### Example migration

Assuming you have an existing release of the prometheus chart, named `prometheus-old`. In order to update to prometheus 2.1 while keeping your old data do the following:

1. Update the `prometheus-old` release. Disable scraping on every component besides the prometheus server, similar to the configuration below:

        ```
        alertmanager:
          enabled: false
        alertmanagerFiles:
          alertmanager.yml: ""
        kubeStateMetrics:
          enabled: false
        nodeExporter:
          enabled: false
        pushgateway:
          enabled: false
        server:
          extraArgs:
            storage.local.retention: 720h
        serverFiles:
          alerts: ""
          prometheus.yml: ""
          rules: ""
        ```

1. Deploy a new release of the chart with version 5.0+ using prometheus 2.x. In the values.yaml set the scrape config as usual, and also add the `prometheus-old` instance as a remote-read target.

   ```
          prometheus.yml:
            ...
            remote_read:
            - url: http://prometheus-old/api/v1/read
            ...
   ```

   Old data will be available when you query the new prometheus instance.

## Configuration

The following table lists the configurable parameters of the Prometheus chart and their default values.

## General Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`common_labels` | Whether to include common labels. It can take values either true or false | `false`
`managedBy` | This should be the tool name being used to manage the operation of an application | `""`
`partOf` | name of a higher level application this one is part of | `""`
`timeZoneEnvName` | set up timezone env into your pod. timeZoneName priority order is 1) timeZoneName 2) global.timeZoneName | ``
`timeZone.timeZoneEnv` | set up timezone env into your pod with timeZoneEnv. timeZoneEnv priority order is 1) timeZone.timeZoneEnv 2) global.timeZoneEnv | ``
`terminationMessagePath` | terminationMessagePath used in container. Default value will be /dev/termination-log | `"/dev/termination-log"`
`terminationMessagePolicy` | terminationMessagePolicy used in container. Default value will be "File" and also user can opt for other option "FallbackToLogsOnError""`
`clusterDomain` | name of local domain set in cluster | `cluster.local`
`ha.enabled` | If true, high availability feature will be enabled, and alertmanager and server could create 2 instances. If false, alertmanager and server could create only 1 instance | `false`
`restrictedToNamespace` | Prometheus needs to scrape only a particular Namespace | `false`
`serviceAccountName` |  ServiceAccount to be used for alertmanager, kubeStateMetrics, pushgateway, server, webhook4fluentd, restserver and migrate components |
`exportersServiceAccountName` | ServiceAccount to be used for  nodeExporter components |
`hooks.nodeSelector` | nodeSelectors for jobs assignment | `{}`
`hooks.tolerations` | node taints to tolerate for jobs (requires Kubernetes >=1.6) | `[]`
`hooks.affinity` | affinity for jobs | `{}`
`persistence.reservePvc` | If true, pvc of alertmanager and server will be reserved. It's only useful when ha.enabled is true | `false`
`progressDeadlineSeconds` | denotes the number of seconds the Deployment controller waits before indicating (in the Deployment status) that the Deployment progress has stalled. progressDeadlineSeconds at compenent level always takes precedence. For more information refer :https://kubernetes.io/docs/concepts/workloads/controllers/deployment/ | `600`
`networkPolicy.enabled` | Enable NetworkPolicy | `false`
`usePodNamePrefixAlways`       | Use podNamePrefix even in case of nameOverride or fullnameOverride. This parameter should not be changed during upgrade | `false`
`enableDefaultCpuLimits` | If enableDefaultCpuLimits set to true user can configure their own cpu limts | `false`
`disablePodNamePrefixRestrictions` | If disablePodNamePrefixRestrictions is true then there is no restriction limit for podnameprefix.(root level have more precedence than global level) | `""`

## Global Configuration

Global level annotations and labels are applicable to all resources.

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`global.registry` | If global.registry is provided then all container images need use this registry. It also supports <registry>/<repository path> | ``
`global.flatregistry` | If global.flatRegistry is set to true, then <repository path> in all container images will be skipped  | `false`
`global.annotations` | Annotations to be added for CPRO resources | `{}`
`global.labels` | Labels to be added for CPRO resources | `{}`
`global.containerNamePrefix` | field to provide custom prefix for container name and it's maximum length is 34 characters in cpro chart | `""`
`global.timeZoneName` | set up timezone env into your pod with timeZoneName. timeZoneName priority order is 1) timeZoneName 2) global.timeZoneName | `UTC`
`global.timeZoneEnv` | set up timezone env into your pod with timeZoneEnv. timeZoneEnv priority order is 1) timeZone.timeZoneEnv 2) global.timeZoneEnv | ``
`global.certManager.enabled` | Enable certmanager using this flag | `true`
`global.certmanager.enabled` | Enable certmanager using this flag | ``
`global.certManager.issuerRef.name`                          | Issuer Name. Self-signed issuer will be created if issuerRef name is empty at workload.certificate.issuerRef.name, certManager.issuerRef.name and global.certManager.issuerRef.name| |
`global.certManager.issuerRef.kind`                          | CRD Name | `Issuer` |
`global.certManager.issuerRef.group`                         | Api group Name |`cert-manager.io` |
`global.serviceAccountName` | Service Account to be used in CPRO components |
`global.imageFlavor` | Global level image Flavor for workloads. Workload level value takes precedence over the root level. Root level value takes precedence over the global level. 
`global.imageFlavorPolicy` | It takes BestMatch or Strict values. Default is Best match| `` 
`global.istioVersion` | Istio version of the cluster. Supported versions are 1.4/1.5/1.6/1.7 | `1.7`
`global.imagePullSecrets` | Optionally specify an array of imagePullSecrets. The imagePullSecrets in workload level is given precedence compared to global level when configured | ``
`global.postRestoreJobTimeout` | Timeout specified for post restore hook for prometheus server in seconds | `3600`
`global.priorityClassName` | Priority ClassName can be set Priority indicates the importance of a Pod relative to other Pods |
`global.ipFamilyPolicy` | ipFamilyPolicy indicates the settings for dual stack configurations possible values include: SingleStack  PreferDualStack  RequireDualStack |
`global.ipFamilies` | ipFamilyPolicy indicates the settings for dual stack configurations possible values include:["IPv4"] ["IPv6"] ["IPv4","IPv6"] ["IPv6","IPv4"] |
`global.ephemeralVolume.enabled` | Ephemeral Volumes shall be used if enabled | `""`
| `global.enableDefaultCpuLimits` | If enableDefaultCpulimits set to true, it should consider default container cpu limits value | `false` |
| `global.disablePodNamePrefixRestrictions` | If disablePodNamePrefixRestrictions is true then there is no restriction limit for podnameprefix.(root level have more precedence than global level) | `""` |
|`global.tls.enabled`| Enable TLS for cpro. Precedence  workload.tls.enabled -> tls.enabled -> global.tls.enabled | `true` |

## Unified Logging configurations is available at both global as well as workload level
## If syslog.enabled is true at workload level, then
## 1. Complete configuration will be rendered from workload. No values will be rendered from global. Workload will take priority over global configuration.
## 2. Global parameters will be read from global section if workload level syslog.enabled is  null.
| **Helm Parameter** | **Description** | **Default**
| `global.unifiedLogging.syslog.enabled`            | set to true when horminized logging is needed | `False`
|`global.unifiedLogging.syslog.facility`      | Syslog facility. grafana.unifiedLogging.syslog.facility has more priority than global.unifiedLogging.syslog.facility   | `null` |
|`global.unifiedLogging.syslog.host`      | Syslog server host name to connect to. grafana.unifiedLogging.syslog.host has more priority than global.unifiedLogging.syslog.host  | `null` |
|`global.unifiedLogging.syslog.port`      | Syslog server port to connect to. grafana.unifiedLogging.syslog.port has more priority than global.unifiedLogging.syslog.port  | `null` |
|`global.unifiedLogging.syslog.protocol`      | Protocol to connect to syslog server. Ex. TCP. grafana.unifiedLogging.syslog.protocol has more priority than global.unifiedLogging.syslog.protocol. ssl,tcp and udp are the supprted in protocol field. if protocol is ssl then please configure the secret and provide secret name under tls section| `null` |
|`global.unifiedLogging.syslog.tls.secretRef.name`      | Name of secret containing syslog CA certificate. workload level will have priority than global level | `null` |
|`global.unifiedLogging.syslog.tls.secretRef.keyNames.caCrt`      | Name of secret containing  CA certificate. workload level will have priority than global level | `ca.crt` |
|`global.unifiedLogging.extension`      | extension for the release or workload | `{}` |

## Image Repository Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`image.distro.repo` | Prometheus distroless image repository | `cpro/registry4/cpro-prometheus-metrics`
`image.distro.tag` | Prometheus distroless image tag | `3.0.1-3220`
`image.distro.imagePullPolicy`    | Image pull policy | `IfNotPresent`
`image.python.repo` | Prometheus python image repository | `cpro/registry4/cpro-prometheus-util`
`image.python.tag` | Prometheus python image tag | `3.0.1-3220`
`image.python.imagePullPolicy`    | Image pull policy | `IfNotPresent`
`image.pythonRocky.repo` | Prometheus Rocky python image repository | `cpro/registry4/prometheus-python-rocky`
`image.pythonRocky.tag` | Prometheus Rocky python image tag | `{{ .Values.image.python.tag }}`
`image.pythonRocky.imagePullPolicy`    | Image pull policy | `IfNotPresent`


## logrotate container configuration

| `logrotate.image.repo`            | Image repository for the logrotate | `char/char-logmanager`
| `logrotate.image.tag`            | Image tag for the logrotate | `8.2308.0-1.1`
| `logrotate.ImagePullPolicy`            |  imagepullpolicy for the logrotate | `IfNotPresent`
| `logrotate.resources.limits.memory` | Resource limits for Memory | `500Mi`
| `logrotate.resources.limits.ephemeral-storage` | Resource limits for ephemeral-storage | `1Gi`
| `logrotate.resources.requests.cpu` | Resource requests for CPU | `200m`
| `logrotate.resources.requests.memory` | Resource requests for Memory | `200Mi`
| `logrotate.resources.requests.ephemeral-storage` | Resource requests for ephemeral-storage | `200Mi`
| `logrotate.containerSecurityContext.capabilities.drop` | allowPrivilegeEscalation when set to false will make sure sub-process created by container will get more privilege than parent process  | `ALL`
| `logrotate.containerSecurityContext.allowPrivilegeEscalation` | allowPrivilegeEscalation when set to false will make sure sub-process created by container will get more privilege than parent process  | `false`
| `logrotate.containerSecurityContext.readOnlyRootFilesystem` | readOnlyRootFilesystem is a file attribute which only allows a user to view a file, restricting any writing to the file | `true`



## fluentd container configuration
| `fluentd.imageFlavor` | image flavor for fluentd - supported flavors are rocky8-jre17, rocky8-jre17| ``
| `fluentd.imageFlavorPolicy` | image flavor Policy for fluentd container | ``
| `fluentd.image.repo`            | Image repository for the fluentd | `bssc-fluentd`
| `fluentd.image.tag`            | Image tag for the fluentd | `1.16.2-2311.0.1`
| `fluentd.image.ImagePullPolicy`            |  imagepullpolicy for the fluentd | `IfNotPresent`
| `fluentd.resources.limits.memory` | Resource limits for Memory | `500Mi`
| `fluentd.resources.limits.ephemeral-storage` | Resource limits for ephemeral-storage | `1Gi`
| `fluentd.resources.requests.cpu` | Resource requests for CPU | `200m`
| `fluentd.resources.requests.memory` | Resource requests for Memory | `200Mi`
| `fluentd.resources.requests.ephemeral-storage` | Resource requests for ephemeral-storage | `200Mi`
| `fluentd.containerSecurityContext.capabilities.drop` | allowPrivilegeEscalation when set to false will make sure sub-process created by container will get more privilege than parent process  | `ALL`
| `fluentd.containerSecurityContext.runAsUser`                | fluentd containers will be run as the specified user. configure runAsUser other than 65534 | `65530`
| `fluentd.env`                | fluentd env variableds | `{"name:"SYSTEM","value":"BCMT","name":"SYSTEMID","value":BCMT_ID"}
| `fluentd.containerSecurityContext.readOnlyRootFilesystem` | readOnlyRootFilesystem is a file attribute which only allows a user to view a file, restricting any writing to the file | `true`
| `fluentd.containerSecurityContext.allowPrivilegeEscalation` | allowPrivilegeEscalation when set to false will make sure sub-process created by container will get more privilege than parent process  | `false`

## imageFlavor configuration

| `imageFlavor`            | image flavor for the workloads. workload level configured imageflavor will take precedence on root level. When root level imageFlavor is set ( i.e. .Values.imageFlavor) then it should be combination of OS(rocky8) and both python and java runtime as restserver workload uses both runtime which is python and java. Server and Alertmanager workload uses python runtime for monitoring container and cproUtil container. Distroless images doesnt have the imageFlavor variable. | `` |

## Custom Configuration

Custom level annotations and labels are available for psp and pod resources.
Add customized labels to some specific resources for Istio or other usages.

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`custom.cproSts.labels` | Custom labels that need to be added to cpro statefulset |
`custom.cproSts.annotations` | Custom annotations that need to be added to cpro statefulset |
`custom.cproDeployment.labels` | Custom labels that need to be added to cpro deployment |
`custom.cproDeployment.annotations` | Custom annotations that need to be added to cpro deployment |
`custom.alertManagerSts.labels` | Custom labels that need to be added to alertManagerStatefulset |
`custom.alertManagerSts.annotations` | Custom annotations that need to be added to cpro alertManagerStatefulset |
`custom.alertManagerDeployment.labels` | Custom labels that need to be added to alertmanager deployment |
`custom.alertManagerDeployment.annotations` | Custom annotations that need to be added to alertmanager deployment |
`custom.kubeStateMetricsDeployment.labels` | Custom labels that need to be added to kubeStateMetrics deployment |
`custom.kubeStateMetricsDeployment.annotations` | Custom annotations that need to be added to kubeStateMetrics deployment |
`custom.nodeExporterDaemonSet.labels` | Custom labels that need to be added to nodeExporter daemon set |
`custom.nodeExporterDaemonSet.annotaions` | Custom annotations that need to be added to nodeExporter daemon set |
`custom.pushGatewayDeployment.labels` | Custom labels that need to be added to pushGateway deployment |
`custom.pushGatewayDeployment.annotations` | Custom annotations that need to be added to pushGateway deployment |
`custom.restServerDeployment.labels` | Custom labels that need to be added to restServer deployment |
`custom.restServerDeployment.annotations` | Custom annotations that need to be added to restServer deployment |
`custom.webhook4FluentdDeployment.labels` | Custom labels that need to be added to webhook4Fluentd deployment |
`custom.webhook4FluentdDeployment.annotations` | Custom annotations that need to be added to webhook4Fluentd deployment |

## Workload Configuration

Workload level annotations and labels are available for all cpro workloads

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
| `alertmanager.labels`        | Labels that need to be added to alertmanager Workload | `{}`
| `alertmanager.annotations`   | Annotations that need to be added to alertmanager Workload | `{}`
| `server.labels`        | Labels that need to be added to cpro-server Workload | `{}`
| `server.annotations`   | Annotations that need to be added to cpro-server Workload | `{}`
| `kubeStateMetrics.labels`        | Labels that need to be added to kubeStateMetrics Workload | `{}`
| `kubeStateMetrics.annotations`   | Annotations that need to be added to kubeStateMetrics Workload | `{}`
| `nodeExporter.labels`        | Labels that need to be added to nodeExporter Workload | `{}`
| `nodeExporter.annotations`   | Annotations that need to be added to nodeExporter Workload | `{}`
| `pushgateway.labels`        | Labels that need to be added to pushgateway Workload | `{}`
| `pushgateway.annotations`   | Annotations that need to be added to pushgateway Workload | `{}`
| `webhook4fluentd.labels`        | Labels that need to be added to webhook4fluentd Workload | `{}`
| `webhook4fluentd.annotations`   | Annotations that need to be added to webhook4fluentd Workload | `{}`
| `restserver.labels`        | Labels that need to be added to restserver Workload | `{}`
| `restserver.annotations`   | Annotations that need to be added to restserver Workload | `{}`
|`server.imagePullSecrets` | Optionally specify an array of imagePullSecrets. The imagePullSecrets in workload level is given precedence compared to global level when configured | ``
|`alertmanager.imagePullSecrets` | Optionally specify an array of imagePullSecrets.The imagePullSecrets in workload level is given precedence compared to global level when configured | ``
|`kubeStateMetrics.imagePullSecrets` | Optionally specify an array of imagePullSecrets.The imagePullSecrets in workload level is given precedence compared to global level when configured | ``
|`restserver.imagePullSecrets` | Optionally specify an array of imagePullSecrets.The imagePullSecrets in workload level is given precedence compared to global level when configured | ``
|`pushgateway.imagePullSecrets` | Optionally specify an array of imagePullSecrets. The imagePullSecrets in workload level is given precedence compared to global level when configured | ``
|`nodeExporter.imagePullSecrets` | Optionally specify an array of imagePullSecrets. The imagePullSecrets in workload level is given precedence compared to global level when configured | ``
|`webhook4fluentd.imagePullSecrets` | Optionally specify an array of imagePullSecrets. The imagePullSecrets in workload level is given precedence compared to global level when configured  | ``

## SELinux Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`seLinuxOptions.enabled` | Selinux options in PSP and Security context  of POD | `false`
`seLinuxOptions.level` | Selinux level in PSP and Security context of POD | `""`
`seLinuxOptions.role` | Selinux role in PSP and Security Context of POD | `""`
`seLinuxOptions.type` | Selinux type in PSP and Security context of POD | `""`
`seLinuxOptions.user` | Selinux user in PSP and Security context of POD | `""`

## RBAC Configuration

Roles and RoleBindings resources will be created automatically for all the required cpro components.

To manually setup RBAC you need to set the parameter `rbac.enabled=false` and specify the service account to be used for each service by setting the parameters: `global.serviceAccountName`and `serviceAccountName` to the name of a pre-existing
service account for  alertmanager, kubeStateMetrics, pushgateway, server, webhook4fluentd, restserver and migrate componentsand It should have permission to delete the pod.
And for exporters components ( nodeExporter)  specify the service account to be used by setting the parameter `exportersServiceAccountName`

> **Tip**: You can refer to the default `*-*role.yaml` and `*-*rolebinding.yaml` files in [templates](templates/) to customize your own.

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`rbac.enabled` | If true, create and use RBAC resources | `true`
`rbac.pspUseAppArmor` | If true, enable apparmor annotations on PSPS and pods | `false`
`rbac.psp.create` | If set to true and rbac is enabled the required PSPS will be created | `true`
`rbac.scc.create` | In OpenShift environment, set psp create to false and scc create to true. This helm chart creates scc for node-exporter  when scc is set to true and rbac is enabled, and for other components restricted scc is sufficient.  when .Values.server.extraHostPathMounts is configured then scc will get create for the prometheus server . User who is deploying chart should have privileges to create the scc or to use existing scc | `false`
`rbac.psp.annotations` | PSP annotations that need to be added | `seccomp.security.alpha.kubernetes.io/allowedProfileNames: *,seccomp.security.alpha.kubernetes.io/defaultProfileName: runtime/default`

## Old Sensitive Data Configuration

Prometheus will be accepting all the sensitive information in the form of secrets enabled through the  parameter called sensitiveDataSecretName.
End user has to create secret/s with all required information before deploy/upgrade
End user is responsible of having proper secret content before/after LCM event.

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`sensitiveDataSecretName` | Name of secret with with sensitive data | `""`

## New Sensitivedata Configuration

The new way of configurating the sensitive data in prometheus enables the user to specify the secret and name of the keys used in when creating the secret.
The End user has to create the secret with the required information before deploy/upgrade and is responsible for having proper secret content before/after LCM event.

Following are the fields related to new ways of configuring the sensitive data secret.
| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`secretPathPrefix` | prefix to be used when mounting the root.externalCredentials or server.externalCredentials or nodeExporter.auth.credentialName | `"/secrets"`
`nodeExporter.auth.credentialName` | Name of the credential secret which has basic auth credentials of node exporter | `""`
`nodeExporter.auth.keyNames.username` | Name of the key used for username when creating the secret | `"username"`
`nodeExporter.auth.keyNames.password` | Name of the key used for password when creating the secret | `"password"`
`server.externalCredentials` | Map containing the details related to credential and keys that contain the sensitivedata to be consumed by prometheus server | `{}`
`externalCredentials` | Map containing the details related to credential and keys that contain the sensitivedata to be consumed by all the workloads | `{}`

#### Example usage of new way of configuring sensitive data:

Suppose the basic auth is enabled for the node exporter. In this case prometheus scrape job also needs to configure basic auth for node exporter job.
Let us assume that the node exporter username is `myadmin` and password is `mypassword`.

Now the user needs to configure the scrape job section for node exporter. Before that, the user needs to create a sensitive data secret containing the username and the password for scrape job. 

Below is the example on how the user can create a secret.

`kubectl create secret generic nxpsecret  --from-literal=nxpusername=myadmin --from-literal=nxppass=mypassword`

Once the secret is created, the end user needs to configure the `nodeExporter.auth` section in the values.yaml with the details related to the above created secret, so that it gets mounted in the container.

``` yaml
nodeExporter:
  auth:
    # give the name of the secrete created containing the sensitive data
    credentialName: "nxpsecret"
	# provide the name of the keys used when creating the secret which map to username and password. 
	# Note: if the user created the secret with the keys as "username" and "password", then the user need not  configure the below section. One can leave it empty "".
	keyNames:
	  username: "nxpusername"
	  password: "nxppass"
```
Next the user needs to configure the scrape job section under prometheus.yml for node exporter with basic auth configuration.

``` yaml
serverFiles:
  prometheus.yml:
    scrape_configs:
	  - job_name: 'prometheus-nodeexporter'
              honor_labels: true
              kubernetes_sd_configs:
                - role: endpoints
              basic_auth:
	## If .Values.nodeexporter.auth.credentialName is specified, then specify the username and password
              ## in the format $__expnd{nxp-auth/<value-of-the-keyName>}
                username: $__expnd{/nxp-auth/nxpusername}
                password: $__expnd{/nxp-auth/nxppass}
```

Similarly, if there anre any other other endpoints (from other namespaces or other applications) which are to be scraped with basic auth, then the user can configure it via the `.Values.server.externalCredentials` or `.Values.externalCredentials`. [Note: .Values.server.externalCredentials takes precedence over .Values.externalCredentials]

For example, there is target which emits metrices with basic auth configured and the end user needs to add it to prometheus scrape config.

First the user needs to create a sensitive data secret containing the basic auth username and password for cthe target.
`kubectl create secret generic extarget  --from-literal=extusername=myuser --from-literal=extpass=mypass`

Next, the user needs to configure the externalCredentials section (either root level or server level). For this example, we are configuring it at server level.

``` yaml
server:
  externalCredentials:
    #Provide a meaningful name as the name of the section below indicating what scrape job would use this credentials section.
	# Note: this section name will be used when creating volume and volume mounts in container
    exampletargetauth:
	  # name of the secret containing the sensitive data
      credentialName: "extarget"
	  # key names used when creating the above secret
	  keyNames:
	    key1: "extusername"
	    key2: "extpass"
```

Once the user has configured the externalCredentials section, the user needs to configure the scrape job to utilize the sensitve data
 
``` yaml
serverFiles:
  prometheus.yml:
    scrape_configs:
      - job_name: "example-job"
          static_configs:
            - targets: ["<endpoint>:<port>"]
      	basic_auth:
		  # If the externalCredentials section is configured(root or server level), the user can configure the username and password in the below format
		  # username: $__expnd{<section-name-under-externalCredentials>/<value-of-keyNames-used>}
		  # Here, `exampletarget` is the section name under externalCredentials
          username: $__expnd{exampletargetauth/extusername}
          password: $__expnd{exampletargetauth/extpass}
```

## tls configuration at root level

when tls is enabled in root level then webhook workload level tls will automatically configured. workload load level tls will have higher priority.
when external sercret is given in tls.extersecretRef.name is configured then external secret which is configured will be mounted and used.
when external secret is not configured then certManager.used needs to set to true and certmanager will create secrets and certicates and mounted inside the container on the secretMountPath configured in values.

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
|`tls.secretRef.name`      | Name of secret containing syslog CA certificate. workload level will have priority than root level | `null` |
|`tls.secretRef.keyNames.caCrt`      | Name of secret containing  CA certificate. workload level will have priority than root level | `ca.crt` |

## Helm Delete Image container Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`helmDeleteImage.imageFlavor` | kubectl container image flavor - supported Flavors are rocky8| ``
`helmDeleteImage.imageFlavorPolicy` | kubectl image flavor Policy | ``
`helmDeleteImage.imagerocky.imageRepo` | helmDeleteImage container image repository | `tools/kubectl`
`helmDeleteImage.imagerocky.imageTag` | helmDeleteImage container image tag | `1.26.10-20231027`
`helmDeleteImage.imagerocky.imagePullPolicy` | helmDeleteImage container image pull policy | `IfNotPresent`
`helmDeleteImage.activeDeadlineSeconds` |  Once a Job reaches activeDeadlineSeconds, all of its running Pods are terminated. Refer https://kubernetes.io/docs/concepts/workloads/controllers/job/#job-termination-and-cleanup for more details | `300`
`helmDeleteImage.containerSecurityContext.capabilities` |  Grant certain privileges to a process without granting all the privileges of the root user | ``
`helmDeleteImage.securityContext.runAsNonRoot` | Indicates that the container must run as a non-root user | `true`
`helmDeleteImage.securityContext.seccompProfile.type` | defines a pod/container's seccomp profile settings. Only one profile source may be set | `RuntimeDefault`
`helmDeleteImage.securityContext.runAsUser` | run as user in Alert Manager containers | `65530`
`helmDeleteImage.securityContext.fsGroup` | fsGroup id in Alert Manager containers | `65530`
`helmDeleteImage.resources.limits.memory` | helmDeleteImage pod resource limits of memory | `100Mi`
`helmDeleteImage.resources.limits.ephemeral-storage` | helmDeleteImage pod resource limits of ephemeral-storage | `1Gi`
`helmDeleteImage.resources.requests.cpu` | helmDeleteImage pod resource requests of cpu | `50m`
`helmDeleteImage.resources.requests.memory` | helmDeleteImage pod resource requests of memory | `32Mi`
`helmDeleteImage.resources.requests.ephemeral-storage` | helmDeleteImage pod resource requests of ephemeral-storage | `256Mi`

## CertManager Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`certManager.enabled` | Enable certmanager using this flag | ``
`certManager.duration` | How long certificate will be valid | `8760h`
`certManager.renewBefore` | When to renew the certificate before it gets expired | `360h`
`certManager.keySize` | Size of KEY | `2048`
`certManager.dnsNames` | DNS used in certificate  | `localhost`
`certManager.issuerRef.name` | Issuer Name. Self-signed issuer will be created if issuerRef name is empty at workload.certificate.issuerRef.name, certManager.issuerRef.name and global.certManager.issuerRef.name| 
`certManager.issuerRef.kind` | CRD Name for etcd| 
`certManager.issuerRef.group` | api group of the resource for etcd|
`certManagerConfig.duration` | How long certificate will be valid | `8760h`
`certManagerConfig.renewBefore` | When to renew the certificate before it gets expired | `360h`
`certManagerConfig.keySize` | Size of KEY | `2048`
`certManagerConfig.servername` | CN of the certificate |
`certManagerConfig.dnsNames` | DNS used in certificate | `localhost`
`certManagerConfig.ipAddress` | Alt Names used in certificate |
`certManagerConfig.issuerRef.name` | Issuer Name. If issuerRef.name is empty then Self-signed issuer configurations will be updated | ``
`certManagerConfig.issuerRef.kind` | CRD Name | ``
`certManagerConfig.issuerRef.group` | api group of the resource | ``
`certManagerConfig.wait4Certs2BeConsumed.enabled` | enable or disable waiting for certificates | `true`
`certManagerConfig.wait4Certs2BeConsumed.name` | name of the init container for file size validator | `file-validator`
`certManagerConfig.wait4Certs2BeConsumed.resources.requests.memory` | Gen3gppxml pod resource requests of memory | `32Mi`
`certManagerConfig.wait4Certs2BeConsumed.resources.requests.cpu` | Gen3gppxml pod resource requests of cpu | `10m`
`certManagerConfig.wait4Certs2BeConsumed.resources.requests.ephemeral-storage` | Gen3gppxml pod resource requests of ephemeral-storage | `256Mi`
`certManagerConfig.wait4Certs2BeConsumed.resources.limits.memory` | Gen3gppxml pod resource limits of memory | `32Mi`
`certManagerConfig.wait4Certs2BeConsumed.resources.limits.ephemeral-storage` | Gen3gppxml pod resource limits of ephemeral-storage | `1Gi`
`certManagerConfig.wait4Certs2BeConsumed.fileNames` | list of name of certificates in the certManagerConfig | `tls.crt ca.crt tls.key`
`certManagerConfig.wait4Certs2BeConsumed.loglevel` | log level of container | `info`
`certManagerConfig.wait4Certs2BeConsumed.logFmt` | log format of container | `logfmt`
`certManagerConfig.wait4Certs2BeConsumed.timeout` | wait time for init container to run | `3m`
`certManagerConfig.wait4Certs2BeConsumed.containerSecurityContext.capabilities` |  Grant certain privileges to a process without granting all the privileges of the root user | ``
`certManagerConfig.wait4Certs2BeConsumed.containerSecurityContext.readOnlyRootFilesystem` | redOnlyRootFilesystem is a file attribute which only allows a user to view a file, restricting any writing to the file | `true`
`certManagerConfig.wait4Certs2BeConsumed.containerSecurityContext.allowPrivilegeEscalation` |  allowPrivilegeEscalation when set to false will make sure sub-process created by container will get more privilege than parent process | `false`

## AlertManager Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`alertmanager.enabled` | If true, create alertmanager | `true`
`alertmanager.replicaCount` | When ha.enabled is false, replicaCount will be 1. When ha.enabled is true, replicaCount will be taken from here. If ha.enabled is false no need to change | `2`
`alertmanager.name` | alertmanager container name | `alertmanager`
`alertmanager.dnsConfig` | Custom DNS configuration to be added to alertmanager pods | `{}`
`alertmanager.antiAffinityMode` | soft means preferredDuringSchedulingIgnoredDuringExecution, hard means requiredDuringSchedulingIgnoredDuringExecution | `"soft"`
`alertmanager.podManagementPolicy` | Pod Management Policy used for statefulset. Allowed values are OrderedReady/Parallel. Refer more details in https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#pod-management-policies | `OrderedReady`
`alertmanager.extraArgs` | Additional alertmanager container arguments | `{}`
`alertmanager.prefixURL` | The prefix slug at which the server can be accessed | `""`
`alertmanager.baseURL` | The external url at which the server can be accessed | `""`
`alertmanager.extraEnv` | Additional alertmanager container environment variable,  If outboundTls is enabled and  certificate use only common name the following has to be added GODEBUG: x509ignoreCN=0 | `{}`
`alertmanager.configMapOverrideName` | Prometheus alertmanager ConfigMap override where full-name is `{{.Release.Name}}-{{.Values.alertmanager.configMapOverrideName}}` and setting this value will prevent the default alertmanager ConfigMap from being generated | `""`
`alertmanager.outboundTLS.enabled` | If true, configure TLS to access the outbound server, If outboundTls is enabled and generated certificate is using only common name, then following env variable has to be added GODEBUG="x509ignoreCN=0" under alertmanager.extraEnv , an example is provided in values.yaml | `true`
`alertmanager.outboundTLS.cert` | CA Root cert of the outbound server | `cert content encoded in base64`
`alertmanager.tolerations` | node taints to tolerate (requires Kubernetes >=1.6) | `[]`
`alertmanager.nodeSelector` | node labels for alertmanager pod assignment | `{}`
`alertmanager.affinity` | affinity for alertmanager pods | `{}`
`alertmanager.schedulerName` | alertmanager alternate scheduler name | `nil`
`alertmanager.progressDeadlineSeconds` | Alertmanager progressDeadlineSeconds for deployment. progressDeadlineSeconds at compenent level always takes precedence | `600`
`alertmanager.pdb` | Pod disruption budget for alertmanager will define minAvailable or maxUnavailable when there is disruption. User have to configure as per the requirement | `{enabled: false, minAvailable: 1 || maxUnavailable: 0 }`
`alertmanager.resources.limits.memory` | alertmanager pod resource limits of memory | `1Gi`
`alertmanager.resources.limits.ephemeral-storage` | alertmanager pod resource limits of ephemeral-storage | `1Gi`
`alertmanager.resources.requests.cpu` | alertmanager pod resource requests of cpu | `10m`
`alertmanager.resources.requests.memory` | alertmanager pod resource requests of memory | `32Mi`
`alertmanager.resources.requests.ephemeral-storage` | alertmanager pod resource requests of ephemeral-storage | `256Mi`
`alertmanager.configmapReload.resources.limits.memory` | user-defined alertmanager configmapReload resource limits of memory | `{{ .Values.configmapReload.resources.limits.memory }}`
`alertmanager.configmapReload.resources.limits.ephemeral-storage` | user-defined alertmanager configmapReload resource limits of ephemeral-storage | `1Gi`
`alertmanager.configmapReload.resources.requests.cpu` | user-defined alertmanager configmapReload resource requests of cpu | `{{ .Values.configmapReload.resources.requests.cpu }}`
`alertmanager.configmapReload.resources.requests.memory` | user-defined alertmanager configmapReload resource requests of memory | `{{ .Values.configmapReload.resources.requests.memory }}`
`alertmanager.configmapReload.resources.requests.ephemeral-storage` | user-defined alertmanager configmapReload resource requests of ephemeral-storage | `256Mi`

`alertmanager.cproUtil.resources.limits.memory` | user-defined alertmanager cproUtil resource limits of memory | `{{ .Values.cproUtil.resources.limits.memory }}`
`alertmanager.cproUtil.resources.limits.ephemeral-storage` | user-defined alertmanager cproUtil resource limits of ephemeral-storage | `1Gi`
`alertmanager.cproUtil.resources.requests.cpu` | user-defined alertmanager cproUtil resource requests of cpu | `{{ .Values.cproUtil.resources.requests.cpu }}`
`alertmanager.cproUtil.resources.requests.memory` | user-defined alertmanager cproUtil resource requests of memory | `{{ .Values.cproUtil.resources.requests.memory }}`
`alertmanager.cproUtil.resources.requests.ephemeral-storage` | user-defined alertmanager cproUtil resource requests of ephemeral-storage | `256Mi`
`alertmanager.retention.time` | Alertmanager retention time | `120h`
`alertmanager.podAnnotations` | annotations to be added to alertmanager pods | `{prometheus.io/port: "9093" prometheus.io/scrape: "true"}`
`alertmanager.priorityClassName` | Priority ClassName can be set Priority indicates the importance of a Pod relative to other Pods |
`alertmanager.ipFamilyPolicy` | ipFamilyPolicy indicates the settings for dual stack configurations possible values include: SingleStack  PreferDualStack  RequireDualStack |
`alertmanager.ipFamilies` | ipFamilyPolicy indicates the settings for dual stack configurations possible values include:["IPv4"] ["IPv6"] ["IPv4","IPv6"] ["IPv6","I
`alertmanager.topologySpreadConstraints | list | `[]` | if labelSelector key is omitted and autoGenerateLabelSelector is set to true in a constraint block then labelSelector is automatically generated otherwise labelSelector are taken from labelSelector key  |
| `alertmanager.imageFlavor`            | image flavor for the workloads. workload level configured imageflavor will take precedence on root level. Alertmanager uses util container which requires python runtime. Supported image flavor is rocky8-python3.8 (for Best Match) | `` |
| `alertmanager.imageFlavorPolicy`            |  alertmanager image flavor Policy | `` |


### Configurable/Random User in AlertManager(Openshift environment only)

Instead of providing values we can use the value “auto” for these feilds, which will automatically assign the values for the fields runAsUser and fsGroup. This is only applicable in openshift environment.

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`alertmanager.containerSecurityContext.capabilities` |  Grant certain privileges to a process without granting all the privileges of the root user | ``
`alertmanager.containerSecurityContext.capabilities` |  Grant certain privileges to a process without granting all the privileges of the root user | ``
`alertmanager.containerSecurityContext.readOnlyRootFilesystem` | redOnlyRootFilesystem is a file attribute which only allows a user to view a file, restricting any writing to the file | `true`
`alertmanager.containerSecurityContext.allowPrivilegeEscalation` |  allowPrivilegeEscalation when set to false will make sure sub-process created by container will get more privilege than parent process | `false`
`alertmanager.securityContext.runAsNonRoot` | Indicates that the container must run as a non-root user | `true`
`alertmanager.securityContext.seccompProfile.type` | defines a pod/container's seccomp profile settings. Only one profile source may be set | `RuntimeDefault`
`alertmanager.securityContext.runAsUser` | run as user in Alert Manager containers | `65534`
`alertmanager.securityContext.fsGroup` | fsGroup id in Alert Manager containers | `65534`
`alertmanager.securityContext.seLinuxOptions.level` | Selinux level in PSP and security context of POD | `""`
`alertmanager.securityContext.seLinuxOptions.role` | Selinux role in PSP and security Context of POD | `""`
`alertmanager.securityContext.seLinuxOptions.type` | Selinux type in PSP and security context of POD | `""`
`alertmanager.securityContext.seLinuxOptions.user` | Selinux user in PSP and security context of POD | `""`

### AlertManager Ingress Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`alertmanager.ingress.enabled` | If true, alertmanager Ingress will be created | `false`
`alertmanager.ingress.annotations` | alertmanager Ingress annotations | `{}`
`alertmanager.ingress.extraLabels` | alertmanager Ingress additional labels | `{}`
`alertmanager.ingress.hosts` | alertmanager Ingress hostnames | `[]`
`alertmanager.ingress.tls` | alertmanager Ingress TLS configuration (YAML) | `[]`
`alertmanager.ingress.pathType` | alertmanager Ingress pathType. All possible allowed values for pathType are "Prefix" OR "ImplementationSpecific" OR "Exact" | `"Prefix"`

###AlertManager Storage Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`alertmanager.persistentVolume.enabled` | If true, alertmanager will create a Persistent Volume Claim | `true`
`alertmanager.persistentVolume.accessModes` | alertmanager data Persistent Volume access modes | `[ReadWriteOnce]`
`alertmanager.persistentVolume.annotations` | Annotations for alertmanager Persistent Volume Claim | `{}`
`alertmanager.persistentVolume.existingClaim` | alertmanager data Persistent Volume existing claim name | `""`
`alertmanager.persistentVolume.mountPath` | alertmanager data Persistent Volume mount root path | `/data`
`alertmanager.persistentVolume.size` | alertmanager data Persistent Volume size | `2Gi`
`alertmanager.persistentVolume.storageClass` | alertmanager data Persistent Volume Storage Class | `unset`
`alertmanager.persistentVolume.subPath` | Subdirectory of alertmanager data Persistent Volume to mount | `""`

### AlertManager Service Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`alertmanager.service.annotationsForAlertmanagerCluster` | annotations for alertmanager cluster | `{}`
`alertmanager.service.annotationsForScrape` | Service Annotations of alertmanager service | `{prometheus.io/scrape: "true"}`
`alertmanager.service.annotations` | annotation for alertmanager service | `{}`
`alertmanager.service.labels` | labels for alertmanager service | `{}`
`alertmanager.service.clusterIP` | internal alertmanager cluster service IP | `""`
`alertmanager.service.externalIPs` | alertmanager service external IP addresses | `[]`
`alertmanager.service.loadBalancerIP` | IP address to assign to load balancer (if supported) | `""`
`alertmanager.service.loadBalancerSourceRanges` | list of IP CIDRs allowed access to load balancer (if supported) | `[]`
`alertmanager.service.servicePort` | alertmanager service port | `80`
`alertmanager.service.clusterPort` | alertmanager container target port if alertmanager.service.type is ClusterIP | `8001`
`alertmanager.service.webPort` | alertmanager container target port if alertmanager.service.webPort is application port | `9093`
`alertmanager.service.meshpeerPort` | alertmanager container mesh port for TCP | `9094`
`alertmanager.service.meshpeerPortUdp` | alertmanager container mesh port for UDP to support deployment in Openshift dualstack env with aspenmesh | `9094`
`alertmanager.service.nodePort` | alertmanager container node port if alertmanager.service.type is NodePort | `unset`
`alertmanager.service.type` | type of alertmanager service to create | `ClusterIP`

### AlertManager Probes Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`alertmanager.livenessProbe.initialDelaySeconds` | Alertmanager livenessProbe intialDelaySeconds | `0`
`alertmanager.livenessProbe.timeoutSeconds` | Alertmanager livenessProbe timeoutSeconds | `30`
`alertmanager.livenessProbe.failureThreshold` | Alertmanager livenessProbe failureThreshold | `3`
`alertmanager.livenessProbe.periodSeconds` | Alertmanager livenessProbe periodSeconds | `10`
`alertmanager.readinesProbe.initialDelaySeconds` | Alertmanager readinessProbe intialDelaySeconds | `0`
`alertmanager.readinessProbe.timeoutSeconds` | Alertmanager readinessProbe timeoutSeconds | `30`
`alertmanager.readinessProbe.failureThreshold` | Alertmanager readinessProbe failureThreshold | `3`
`alertmanager.readinessProbe.periodSeconds` | Alertmanager readinessProbe periodSeconds | `10`

### AlertManager TLS Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`alertmanager.tls_auth_config.secretForWebConfig` | Secret needs to created manually for configuration file | `
`alertmanager.tls_auth_config.tls.enabled` | If metrices from alertmanager needs to be scrapped in tls mode | `false`
`alertmanager.tls_auth_config.tls.externalSecret` | secretname of certificates if certmanger is not used | ``
`alertmanager.tls_auth_config.tls.dnsNames` | DNS used in certificate | `localhost`
`alertmanager.tls_auth_config.tls.ipAddress` | Alt Names used in certificate |
`alertmanager.tls_auth_config.insecureReload` | use insecure url for configmap reload | `false`

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`alertmanager.tls.enabled` | Enable TLS for AlertManager | ``
`alertmanager.tls.issuerRef.name` | Secret name, pointing to a Secret object. If empty then automatically generated secret with certificate will be used | ``
`alertmanager.tls.issuerRef.keyNames.caCrt` | Name of Secret key, which contains CA certificate | `"ca.crt"`
`alertmanager.tls.issuerRef.keyNames.tlsKey` | Name of Secret key, which contains TLS key | `"tls.key"`
`alertmanager.tls.issuerRef.keyNames.tlsCrt` | Name of Secret key, which contains TLS certificate | `"tls.crt"`
| `alertmanager.certificate.enabled` | Certificate object is created based on this parameter  | `true` |
| `alertmanager.certificate.issuerRef.name` | Issuer Name | |
| `alertmanager.certificate.issuerRef.kind` | CRD Name | |
| `alertmanager.certificate.issuerRef.group` | Api group Name | |
| `alertmanager.certificate.duration` | How long certificate will be valid | `8760h` |
| `alertmanager.certificate.renewBefore` | When to renew the certificate before it gets expired | `360h` |
| `alertmanager.certificate.subject` | Not needed in internal communication | |
| `alertmanager.certificate.commonName` | It has been deprecated since 2000 and is discouraged from being used for a server side certificates | |
| `alertmanager.certificate.usages` |Usages is the set of x509 usages that are requested for the certificate | |
| `alertmanager.certificate.dnsNames` | DNSNames is a list of DNS subjectAltNames to be set on the Certificate. |  |
| `alertmanager.certificate.uris` | URIs is a list of URI subjectAltNames to be set on the Certificate. | |
| `alertmanager.certificate.ipAddresses` | IPAddresses is a list of IP address subjectAltNames to be set on the Certificate. | |
| `alertmanager.certificate.privateKey.algorithm` | Algorithm used to encode key value pair | |
| `alertmanager.certificate.privateKey.encoding` | Encode the key pair value | |
| `alertmanager.certificate.privateKey.size` | size of the key pair  |
| `alertmanager.certificate.privateKey.rotationPolicy` | Rotation of a key pair, when certificate is refreshed is recommended from a security point of view | `Always` |

### AlertManager Istio Gateway Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`istio.gateways.cproAlertmanager.enabled`         | If the gateway is enabled or not. If False, gateway will not be created | `true`
`istio.gateways.cproAlertmanager.labels`         | The labels that need to be added to the gateway | `{}`
`istio.gateways.cproAlertmanager.annotations`         | The annotations that need to be added to the gateway | `{}`
`istio.gateways.cproAlertmanager.ingressPodSelector`         | Istio ingress gateway selector | `{istio: ingressgateway}`
`istio.gateways.cproAlertmanager.port`         | The port for the Gateway to connect to | `443`
`istio.gateways.cproAlertmanager.protocol`         | The protocol for the Gateway will use | `HTTPS`
`istio.gateways.cproAlertmanager.host`         | the host used to access the management GUI from istio ingress gateway. If empty default will be * | `[]`
`istio.gateways.cproAlertmanager.tls.redirect`         | Whether the request to be redirected from HTTP to HTTPS | `true`
`istio.gateways.cproAlertmanager.tls.mode`         | mode could be SIMPLE, MUTUAL, PASSTHROUGH, ISTIO_MUTUAL | `SIMPLE`
`istio.gateways.cproAlertmanager.tls.credentialName`         | Secret name for Istio Ingress | `"am-gateway"`
`istio.gateways.cproAlertmanager.tls.custom`         | Custom TLS configurations that needs to be added to the gateway | `{}`


## AlertManager ConfigMap Files Configuration

AlertManager is configured through [alertmanager.yml](https://prometheus.io/docs/alerting/configuration/). This file (and any others listed in `alertmanagerFiles`) will be mounted into the `alertmanager` pod.

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`alertmanagerWebhookFiles.alertmanager.yml` | this config is used when webhook4fluentd.enabled is true, and receivers: - name: cpro-webhook should not be changed to take the webhook configuration  `` |

## Configmap Reload Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`configmapReload.name` | configmap-reload container name | `configmap-reload`
`configmapReload.extraArgs` | Additional configmap-reload container arguments | `{}`
`configmapReload.extraConfigmapMounts` | Additional configmap-reload configMap mounts and configmapReload.extraConfigmapMounts.configMap can take templated string as input | `[]`
`configmapReload.resources.limits.memory` | configmapReload pod resource limits of memory | `32Mi`
`configmapReload.resources.limits.ephemeral-storage` | configmapReload pod resource limits of ephemeral-storage | `1Gi`
`configmapReload.resources.requests.cpu` | configmapReload pod resource requests of cpu | `10m`
`configmapReload.resources.requests.memory` | configmapReload pod resource requests of memory | `32Mi`
`configmapReload.resources.requests.ephemeral-storage` | configmapReload pod resource requests of ephemeral-storage | `256Mi`

## Tools Image Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`tools.containerSecurityContext.capabilities` |  Grant certain privileges to a process without granting all the privileges of the root user | ``
`tools.containerSecurityContext.readOnlyRootFilesystem` | redOnlyRootFilesystem is a file attribute which only allows a user to view a file, restricting any writing to the file | `true`
`tools.containerSecurityContext.allowPrivilegeEscalation` |  allowPrivilegeEscalation when set to false will make sure sub-process created by container will get more privilege than parent process | `false`
`tools.securityContext.runAsNonRoot` | Indicates that the container must run as a non-root user | `true`
`tools.securityContext.seccompProfile.type` | defines a pod/container's seccomp profile settings. Only one profile source may be set | `RuntimeDefault`
`tools.securityContext.runAsUser` | run as user in tools image containers | `65534`
`tools.securityContext.fsGroup` | fsGroup id in tools image containers | `65534`
`tools.securityContext.seLinuxOptions.level` | Selinux level in PSP and security context of POD | `""`
`tools.securityContext.seLinuxOptions.role` | Selinux role in PSP and security Context of POD | `""`
`tools.securityContext.seLinuxOptions.type` | Selinux type in PSP and security context of POD | `""`
`tools.securityContext.seLinuxOptions.user` | Selinux user in PSP and security context of POD | `""`

## Helm Test Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`helmtest.CPROconfigmapname` | CPRO configmap name used in helm test |
`helmtest.nodeExporter_prometheus_basic_auth.username` | Substitute key value of username, whose exact value is part of sensitive data. User need not configure this if new way of sensitive data is configured (`.Values.nodeExporter.auth.credentialName`)  | ``
`helmtest.nodeExporter_prometheus_basic_auth.password` | Substitute key value of password, whose exact value is part of sensitive data. User need not configure this if new way of sensitive data is configured (`.Values.nodeExporter.auth.credentialName`) | ``
`helmtest.resources.limits.memory` | helmtest pod resource limits of memory | `32Mi`
`helmtest.resources.limits.ephemeral-storage` | helmtest pod resource limits of ephemeral-storage | `1Gi`
`helmtest.resources.requests.cpu` | helm test pod resource requests of CPU | `10m`
`helmtest.resources.requests.memory` | helm test pod resource requests of memory | `32Mi`
`helmtest.resources.requests.ephemeral-storage` | helm test pod resource requests of ephemeral-storage | `256Mi`
`helmtest.timeout` | Ammount of time to wait before running the tests | `60`
`helmtest.priorityClassName` | Priority ClassName can be set Priority indicates the importance of a Pod relative to other Pods | ``
`helmtest.containerSecurityContext.capabilities` |  Grant certain privileges to a process without granting all the privileges of the root user | ``
`helmtest.containerSecurityContext.readOnlyRootFilesystem` | redOnlyRootFilesystem is a file attribute which only allows a user to view a file, restricting any writing to the file | `true`
`helmtest.containerSecurityContext.allowPrivilegeEscalation` |  allowPrivilegeEscalation when set to false will make sure sub-process created by container will get more privilege than parent process | `false`
`helmtest.securityContext.runAsNonRoot` | Indicates that the container must run as a non-root user | `true`
`helmtest.securityContext.seccompProfile.type` | defines a pod/container's seccomp profile settings. Only one profile source may be set | `RuntimeDefault`
`helmtest.securityContext.runAsUser` | run as user in pre and post delete  containers | `65534`
`helmtest.securityContext.fsGroup` | fsGroup id in pre and post delete containers | `65534`
`helmtest.imageFlavor` | image flavor for restapi-test and check-startup container - supported flavors are rocky8-python3.8| ``
`helmtest.imageFlavorPolicy` | image flavor Policy for helmtest container | ``

## Init Config File Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`initConfigFile.name` | init-config-file container name | `init-config-file`
`initConfigFile.imageFlavor` | init-config-file image flavor -supported Flavors are rocky8-python3.8| ``
`initConfigFile.imageFlavorPolicy` | init-config-file image flavor Policy | ``
`initConfigFile.resources.limits.memory` | init-config-file resource limits of memory | `32Mi`
`initConfigFile.resources.limits.ephemeral-storage` | init-config-file resource limits of ephemeral-storage | `1Gi`
`initConfigFile.resources.requests.cpu` | init-config-file resource requests of cpu | `10m`
`initConfigFile.resources.requests.memory` | init-config-file resource requests of memory | `32Mi`
`initConfigFile.resources.requests.ephemeral-storage` | init-config-file resource requests of ephemeral-storage | `256Mi`

## KubeStateMetrics Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`kubeStateMetrics.enabled` | If true, create kube-state-metrics | `true`
`kubeStateMetrics.name` | kube-state-metrics container name | `kube-state-metrics`
`kubeStateMetrics.imageFlavor` | kubeStateMetrics image flavor | ``
`kubeStateMetrics.imageFlavorPolicy` | kubeStateMetrics image flavor Policy | ``
`kubeStateMetrics.tolerations` | node taints to tolerate (requires Kubernetes >=1.6) | `[]`
`kubeStateMetrics.nodeSelector` | node labels for kube-state-metrics pod assignment | `{}`
`kubeStateMetrics.affinity` | affinity for pods | `{}`
`kubeStateMetrics.podAnnotations` | annotations to be added to kube-state-metrics pods | `{}`
`kubeStateMetrics.pdb` | Pod disruption budget for kube-state-metrics will define minAvailable or maxUnavailable when there is disruption. User have to configure as per the requirement | `{enabled: false, minAvailable: 1 || maxUnavailable: 0 }`
`kubeStateMetrics.pod.labels` | labels to be added to kube-state-metrics pods | `{}`
`kubeStateMetrics.replicaCount` | desired number of kube-state-metrics pods | `1`
`kubeStateMetrics.resources.limits.memory` | kube-state-metrics pod resource limits of memory | `200Mi`
`kubeStateMetrics.resources.limits.ephemeral-storage` | kube-state-metrics pod resource limits of ephemeral-storage | `1Gi`
`kubeStateMetrics.resources.requests.cpu` | kube-state-metrics pod resource requests of cpu | `10m`
`kubeStateMetrics.resources.requests.memory` | kube-state-metrics pod resource requests of memory | `32Mi`
`kubeStateMetrics.resources.requests.ephemeral-storage` | kube-state-metrics pod resource requests of ephemeral-storage | `256Mi`
`kubeStateMetrics.progressDeadlineSeconds` | kube-state-metrics  progressDeadlineSeconds for deployment. progressDeadlineSeconds at compenent level always takes precedence | `600`
`kubeStateMetrics.priorityClassName` | Priority ClassName can be set Priority indicates the importance of a Pod relative to other Pods |
`kubeStateMetrics.ipFamilyPolicy` | ipFamilyPolicy indicates the settings for dual stack configurations possible values include: SingleStack  PreferDualStack  RequireDualStack |
`kubeStateMetrics.ipFamilies` | ipFamilyPolicy indicates the settings for dual stack configurations possible values include:["IPv4"] ["IPv6"] ["IPv4","IPv6"] ["IPv6","IPv4"] |
`kubeStateMetrics.topologySpreadConstraints | list | `[]` | if labelSelector key is omitted and autoGenerateLabelSelector is set to true in a constraint block then labelSelector is automatically generated otherwise labelSelector are taken from labelSelector key  |

#  ## KubeStateMetrics Collectors/Resources Configuration

Configure the set of kubernetes objects that serviceaccount has to access by providing comma-separated list of collectors to be enabled.
Available collectors list: "configmaps,cronjobs,daemonsets,deployments,endpoints,horizontalpodautoscalers,jobs,limitranges,poddisruptionbudgets,pods,replicasets,replicationcontrollers,resourcequotas,secrets,services,statefulsets".
'collectors' flag is renamed with 'resources' in kubestatemetrics latest version (i.e from v2.0)

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`kubeStateMetrics.args.collectors` | list of collectors/resources to be enabled for kubestatemetrics | `{}`
`kubeStateMetrics.args.metricAllowlist` | list of metrics to be allowed | `[]`
`kubeStateMetrics.args.metricDenylist` | list of metrics to be excluded | `[]`
`kubeStateMetrics.args.metricLabelsAllowlist` | list of labels to be included for the given collector | `[]`
`kubeStateMetrics.args.metricAnnotationsAllowList` | metric annotations to be included | `[]`
`kubeStateMetrics.args.extraArgs` | extra ags for kube state metrics container | `[]`

### KubeStateMetrics Random User Configuration (Openshift environment only)

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`kubeStateNetrics.containerSecurityContext.capabilities` |  Grant certain privileges to a process without granting all the privileges of the root user | ``
`kubeStateMetrics.containerSecurityContext.readOnlyRootFilesystem` | redOnlyRootFilesystem is a file attribute which only allows a user to view a file, restricting any writing to the file | `true`
`kubeStateMetrics.containerSecurityContext.allowPrivilegeEscalation` |  allowPrivilegeEscalation when set to false will make sure sub-process created by container will get more privilege than parent process | `false`
`kubeStateMetrics.securityContext.runAsNonRoot` | Indicates that the container must run as a non-root user | `true`
`kubeStateMetrics.securityContext.seccompProfile.type` | defines a pod/container's seccomp profile settings. Only one profile source may be set | `RuntimeDefault`
`kubeStateMetrics.securityContext.runAsUser` | run as user in kube-state-metrics containers | `65530`
`kubeStateMetrics.securityContext.fsGroup` | fsGroup in kube-state-metrics containers | `65530`
`kubeStateMetrics.securityContext.seLinuxOptions.level` | Selinux level in PSP and security context of POD | `""`
`kubeStateMetrics.securityContext.seLinuxOptions.role` | Selinux role in PSP and security Context of POD | `""`
`kubeStateMetrics.securityContext.seLinuxOptions.type` | Selinux type in PSP and security context of POD | `""`
`kubeStateMetrics.securityContext.seLinuxOptions.user` | Selinux user in PSP and security context of POD | `""`

### KubeStateMetrics TLS Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`kubeStateMetrics.tls_auth_config.secretForWebConfig` | Secret needs to created manually for configuration file | `
`kubeStateMetrics.tls_auth_config.tls.enabled` | If metrices from kubeStateMetrics needs to be scrapped in tls mode | `false`
`kubeStateMetrics.tls_auth_config.tls.externalSecret` | secretname of certificates if certmanger is not used | ``
`kubeStateMetrics.tls_auth_config.tls.dnsNames` | DNS used in certificate | `localhost`
`kubeStateMetrics.tls_auth_config.tls.ipAddress` | Alt Names used in certificate |
| `kubeStateMetrics.certificate.enabled` | Certificate object is created based on this parameter  | `true` |
| `kubeStateMetrics.certificate.issuerRef.name` | Issuer Name | |
| `kubeStateMetrics.certificate.issuerRef.kind` | CRD Name | |
| `kubeStateMetrics.certificate.issuerRef.group` | Api group Name | |
| `kubeStateMetrics.certificate.duration` | How long certificate will be valid | `8760h` |
| `kubeStateMetrics.certificate.renewBefore` | When to renew the certificate before it gets expired | `360h` |
| `kubeStateMetrics.certificate.subject` | Not needed in internal communication | |
| `kubeStateMetrics.certificate.commonName` | It has been deprecated since 2000 and is discouraged from being used for a server side certificates | |
| `kubeStateMetrics.certificate.usages` |Usages is the set of x509 usages that are requested for the certificate | |
| `kubeStateMetrics.certificate.dnsNames` | DNSNames is a list of DNS subjectAltNames to be set on the Certificate. |  |
| `kubeStateMetrics.certificate.uris` | URIs is a list of URI subjectAltNames to be set on the Certificate. | |
| `kubeStateMetrics.certificate.ipAddresses` | IPAddresses is a list of IP address subjectAltNames to be set on the Certificate. | |
| `kubeStateMetrics.certificate.privateKey.algorithm` | Algorithm used to encode key value pair | |
| `kubeStateMetrics.certificate.privateKey.encoding` | Encode the key pair value | |
| `kubeStateMetrics.certificate.privateKey.size` | size of the key pair  |
| `kubeStateMetrics.certificate.privateKey.rotationPolicy` | Rotation of a key pair, when certificate is refreshed is recommended from a security point of view | `Always` 

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`kubeStateMetrics.tls.enabled` | Enable TLS for kubeStateMetrics | ``
`kubeStateMetrics.tls.issuerRef.name` | Secret name, pointing to a Secret object. If empty then automatically generated secret with certificate will be used | ``
`kubeStateMetrics.tls.issuerRef.keyNames.caCrt` | Name of Secret key, which contains CA certificate | `"ca.crt"`
`kubeStateMetrics.tls.issuerRef.keyNames.tlsKey` | Name of Secret key, which contains TLS key | `"tls.key"`
`kubeStateMetrics.tls.issuerRef.keyNames.tlsCrt` | Name of Secret key, which contains TLS certificate | `"tls.crt"`

### KubeStateMetrics Service Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`kubeStateMetrics.service.annotations` | annotation for kube-state-metrics service | `{prometheus.io/scrape: "true"}`
`kubeStateMetrics.service.annotationsForScrape` | annotation for kube-state-metrics service | `{prometheus.io/scrape: "true"}`
`kubeStateMetrics.service.clusterIP` | internal kube-state-metrics cluster service IP | `None`
`kubeStateMetrics.service.metricsPort` | kubestatemetrics application port | `8080`
`kubeStateMetrics.service.externalIPs` | kube-state-metrics service external IP addresses | `[]`
`kubeStateMetrics.service.loadBalancerIP` | IP address to assign to load balancer (if supported) | `""`
`kubeStateMetrics.service.loadBalancerSourceRanges` | list of IP CIDRs allowed access to load balancer (if supported) | `[]`
`kubeStateMetrics.service.servicePort` | kube-state-metrics service port | `80`
`kubeStateMetrics.service.type` | type of kube-state-metrics service to create | `ClusterIP`

### KubeStateMetrics Probes Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`kubeStateMetrics.livenessProbe.initialDelaySeconds` | Liveness Probe initial delay seconds | `0`
`kubeStateMetrics.livenessProbe.timeoutSeconds` | LivenessProbe timeoutSeconds | `30`
`kubeStateMetrics.livenessProbe.failureThreshold` | LivenessProbe failureThreshold | `3`
`kubeStateMetrics.livenessProbe.periodSeconds` | LivenessProbe periodSeconds | `10`
`kubeStateMetrics.readinesProbe.initialDelaySeconds` | ReadinessProbe initial delay seconds | `0`
`kubeStateMetrics.readinessProbe.timeoutSeconds` | ReadinessProbe timeoutSeconds | `30`
`kubeStateMetrics.readinessProbe.failureThreshold` | ReadinessProbe failureThreshold | `3`
`kubeStateMetrics.readinessProbe.periodSeconds` | ReadinessProbe periodSeconds | `10`

## NodeExporter Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`nodeExporter.enabled` | If true, create node-exporter | `true`
`nodeExporter.name` | node-exporter container name | `node-exporter`
`nodeExporter.imageFlavor` | nodeExporter image flavor | ``
`nodeExporter.imageFlavorPolicy` | nodeExporter image flavor Policy | ``
`nodeExporter.updateStrategy.type` | Custom Update Strategy | `RollingUpdate`
`nodeExporter.dnsPolicy` | These policies are specified in the dnsPolicy field of a Pod Spec- Default,ClusterFirt,ClusterFirstWithHostNet.  | ``
`nodeExporter.dnsConfig` | When a Pod's dnsPolicy is set to "None", the dnsConfig field has to be specified. It has nameservers, searches and options | ``
`nodeExporter.extraArgs` | Additional node-exporter container arguments | `{}`
`nodeExporter.priorityClassName` | priorityClassName for node exporter pods | ``
`nodeExporter.extraArgs.web.listen-address` | Additional node-exporter container argument, required when node-exporter is brought-up on different port and value should be same as  podHostPort & podContainerPort | `":9100"`
`nodeExporter.extraArgs.no-collector.timex` | Additional node-exporter container argument, required to disable the timex collector. when scc is set to false, please configure and to enabled the timex collector , please comment no-collector.timex argument | ``
`nodeExporter.extraHostPathMounts` | Additional node-exporter hostPath mounts | `[]`
`nodeExporter.extraConfigmapMounts` | Additional node-exporter configMap mounts | `[]`
`nodeExporter.tolerations` | node taints to tolerate (requires Kubernetes >=1.6) | `[]`
`nodeExporter.nodeSelector` | node labels for node-exporter pod assignment | `{}`
`nodeExporter.podAnnotations` | annotations to be added to node-exporter pods | `{}`
`nodeExporter.pod.labels` | labels to be added to node-exporter pods | `{}`
`nodeExporter.resources.limits.memory` | node-exporter pod resource limits of memory | `500Mi`
`nodeExporter.resources.limits.ephemeral-storage` | node-exporter pod resource limits of ephemeral-storage | `1Gi`
`nodeExporter.resources.requests.cpu` | node-exporter pod resource requests of cpu | `100m`
`nodeExporter.resources.requests.memory` | node-exporter pod resource requests of memory | `30Mi`
`nodeExporter.resources.requests.ephemeral-storage` | node-exporter pod resource requests of ephemeral-storage | `256Mi`
`nodeExporter.priorityClassName` | Priority ClassName can be set Priority indicates the importance of a Pod relative to other Pods |
`nodeExporter.ipFamilyPolicy` | ipFamilyPolicy indicates the settings for dual stack configurations possible values include: SingleStack  PreferDualStack  RequireDualStack |
`nodeExporter.ipFamilies` | ipFamilyPolicy indicates the settings for dual stack configurations possible values include:["IPv4"] ["IPv6"] ["IPv4","IPv6"] ["IPv6","IPv4"] |

### NodeExporter Random User Configuration (Openshift environment only)

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`nodeExporter.containerSecurityContext.capabilities` |  Grant certain privileges to a process without granting all the privileges of the root user | `SYS_TIME`
`nodeExporter.securityContext.runAsNonRoot` | Indicates that the container must run as a non-root user | `true`
`nodeExporter.securityContext.seccompProfile.type` | defines a pod/container's seccomp profile settings. Only one profile source may be set | `RuntimeDefault`
`nodeExporter.podSecurityContext.fsGroup` | fsGroup id in nodeExporter containers | `65530`
`nodeExporter.podSecurityContext.runAsUser` | run as user in nodeExporter containers | `65530`
`nodeExporter.podSecurityContext.seLinuxOptions.level` | Selinux level in PSP and security context of POD | `""`
`nodeExporter.podSecurityContext.seLinuxOptions.role` | Selinux role in PSP and security Context of POD | `""`
`nodeExporter.podSecurityContext.seLinuxOptions.type` | Selinux type in PSP and security context of POD | `""`
`nodeExporter.podSecurityContext.seLinuxOptions.user` | Selinux user in PSP and security context of POD | `""`

### NodeExporter TLS Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`nodeExporter.tls_auth_config.secretForWebConfig` | Secret needs to created manually for configuration file | `
`nodeExporter.tls_auth_config.basic_auth.enabled` | If metrices from node-exporter needs to be scrapped in tls mode | `false`
`nodeExporter.tls_auth_config.tls.enabled` | If metrices from node-exporter needs to be scrapped in tls mode | `false`
`nodeExporter.tls_auth_config.tls.externalSecret` | secretname of certificates if certmanger is not used | ``
`nodeExporter.tls_auth_config.tls.dnsNames` | DNS used in certificate | `localhost`
`nodeExporter.tls_auth_config.tls.ipAddress` | Alt Names used in certificate |

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`nodeExporter.tls.enabled` | Enable TLS for nodeExporter | ``
`nodeExporter.tls.issuerRef.name` | Secret name, pointing to a Secret object. If empty then automatically generated secret with certificate will be used | ``
`nodeExporter.tls.issuerRef.keyNames.caCrt` | Name of Secret key, which contains CA certificate | `"ca.crt"`
`nodeExporter.tls.issuerRef.keyNames.tlsKey` | Name of Secret key, which contains TLS key | `"tls.key"`
`nodeExporter.tls.issuerRef.keyNames.tlsCrt` | Name of Secret key, which contains TLS certificate | `"tls.crt"`
| `nodeExporter.certificate.enabled` | Certificate object is created based on this parameter  | `true` |
| `nodeExporter.certificate.issuerRef.name` | Issuer Name | |
| `nodeExporter.certificate.issuerRef.kind` | CRD Name | |
| `nodeExporter.certificate.issuerRef.group` | Api group Name | |
| `nodeExporter.certificate.duration` | How long certificate will be valid | `8760h` |
| `nodeExporter.certificate.renewBefore` | When to renew the certificate before it gets expired | `360h` |
| `nodeExporter.certificate.subject` | Not needed in internal communication | |
| `nodeExporter.certificate.commonName` | It has been deprecated since 2000 and is discouraged from being used for a server side certificates | |
| `nodeExporter.certificate.usages` |Usages is the set of x509 usages that are requested for the certificate | |
| `nodeExporter.certificate.dnsNames` | DNSNames is a list of DNS subjectAltNames to be set on the Certificate. |  |
| `nodeExporter.certificate.uris` | URIs is a list of URI subjectAltNames to be set on the Certificate. | |
| `nodeExporter.certificate.ipAddresses` | IPAddresses is a list of IP address subjectAltNames to be set on the Certificate. | |
| `nodeExporter.certificate.privateKey.algorithm` | Algorithm used to encode key value pair | |
| `nodeExporter.certificate.privateKey.encoding` | Encode the key pair value | |
| `nodeExporter.certificate.privateKey.size` | size of the key pair  |
| `nodeExporter.certificate.privateKey.rotationPolicy` | Rotation of a key pair, when certificate is refreshed is recommended from a security point of view | `Always` |

### NodeExporter Service Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`nodeExporter.service.annotations` | annotations for node-exporter service | `{prometheus.io/probe: "node-exporter"}`
`nodeExporter.service.labels` | labels to be added to node-exporter service | `{}`
`nodeExporter.service.clusterIP` | internal node-exporter cluster service IP | `None`
`nodeExporter.service.externalIPs` | node-exporter service external IP addresses | `[]`
`nodeExporter.service.loadBalancerIP` | IP address to assign to load balancer (if supported) | `""`
`nodeExporter.service.loadBalancerSourceRanges` | list of IP CIDRs allowed access to load balancer (if supported) | `[]`
`nodeExporter.service.servicePort` | node-exporter service port | `9100`
`nodeExporter.service.type` | type of node-exporter service to create | `ClusterIP`
`nodeExporter.service.podContainerPort` | node-exporter container target port | `9100`
`nodeExporter.service.podHostPort` | node-exporter container host port | `9100`

### NodeExporter Probe Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`nodeExporter.livenessProbe.initialDelaySeconds` | Liveness Probe initial delay seconds | `0`
`nodeExporter.livenessProbe.timeoutSeconds` | LivenessProbe timeoutSeconds | `30`
`nodeExporter.livenessProbe.failureThreshold` | LivenessProbe failureThreshold | `3`
`nodeExporter.livenessProbe.periodSeconds` | LivenessProbe periodSeconds | `10`
`nodeExporter.readinesProbe.initialDelaySeconds` | ReadinessProbe initial delay seconds | `0`
`nodeExporter.readinessProbe.timeoutSeconds` | ReadinessProbe timeoutSeconds | `30`
`nodeExporter.readinessProbe.failureThreshold` | ReadinessProbe failureThreshold | `3`
`nodeExporter.readinessProbe.periodSeconds` | ReadinessProbe periodSeconds | `10`


## CPRO Util Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`cproUtil.name` | Cpro Util container name | `cproUtil`
`cproUtil.resources.limits.memory` | cpro util resource limits of memory | `200Mi`
`cproUtil.resources.limits.ephemeral-storage` | cpro util resource limits of ephemeral-storage | `1Gi`
`cproUtil.resources.requests.cpu` | cpro util resource requests of cpu | `10m`
`cproUtil.resources.requests.memory` | cpro util resource request of memory | `32Mi`
`cproUtil.resources.requests.ephemeral-storage` | cpro util resource request of ephemeral-storage | `256Mi`
`cproUtil.imageFlavor` | cproUtil image flavor - Supported Flavors are rocky-python3.8 | ``
`cproUtil.imageFlavorPolicy` | cproUtil image flavor Policy | ``
## Prometheus Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`server.enabled` | Deploy prometheus server | `true
`server.name` | Prometheus server container name | `server`
`server.etcdCertMountPath` | Path where etcd certificates generated by cert-manager will be mounted | `/etc/etcd/ssl`
`server.nodeexporterCertMountPath` | Path where node exporter certificates will be mounted for scrapping metrices in tls mode | `/etc/etcd/tls-nodeexporter`
`server.kubeStateMetricsCertMountPath` | Path where kubeStateMetrics certificates will be mounted for scrapping metrices in tls mode | `/etc/ksm/tls-kubestatemetrics`
`server.antiAffinityMode` | soft means preferredDuringSchedulingIgnoredDuringExecution. hard means requiredDuringSchedulingIgnoredDuringExecution | `"soft"`
`server.podManagementPolicy` | Pod Management Policy used for statefulset. Allowed values are OrderedReady/Parallel. Refer more details in https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#pod-management-policies | `OrderedReady`
`server.prefixURL` | The prefix slug at which the server can be accessed | `""`
`server.baseURL` | The external url at which the server can be accessed | `""`
`server.enableAdminApi` |  If true, Prometheus administrative HTTP API will be enabled. Please note, that you should take care of administrative API access protection (ingress or some frontend Nginx with auth) before enabling it. | `false`
`server.namespaceList` | List of namespaces that need to be scrapped. works only when restrictedToNamespace is true | `unset`
`server.nsToExcludeFromCommonJobs` | List of namespaces that are not part of common jobs and are especially part of custom jobs. It works only when restrictedToNamespace is true | `unset`
`server.extraArgs` | Additional Prometheus server container arguments | `{}`
`server.extraKeys` | Additional Prometheus server container only key arguments | `[]`
`server.extraHostPathMounts` | Additional Prometheus server hostPath mounts | `[]`
`server.extraConfigmapMounts` | Additional Prometheus server configMap mounts and server.extraConfigmapMounts.configMap can take templated string as input | `[]`
`server.extraSecretMounts` | Additional Prometheus server Secret mounts and server.extraSecretMounts.secretName can take templated string as input | `[]`
`server.configMapOverrideName` | Prometheus server ConfigMap override where full-name is `{{.Release.Name}}-{{.Values.server.configMapOverrideName}}` and setting this value will prevent the default server ConfigMap from being generated | `""`
`server.progressDeadlineSeconds` | Prometheus progressDeadlineSeconds for deployment. progressDeadlineSeconds at compenent level always takes precedence | `600`
`server.pdb` | Pod disruption budget for prometheus server will define minAvailable or maxUnavailable when there is disruption. User have to configure as per the requirement | `{enabled: false, minAvailable: 1 || maxUnavailable: 0 }`
`server.tolerations` | node taints to tolerate (requires Kubernetes >=1.6) | `[]`
`server.nodeSelector` | node labels for Prometheus server pod assignment | `{}`
`server.affinity` | affinity for server pods | `{}`
`server.schedulerName` | Prometheus server alternate scheduler name | `nil`
`server.podAnnotations` | annotations to be added to Prometheus server pods | `{}`
`server.replicaCount` | When ha.enabled is false, replicaCount will be 1. When ha.enabled is true, replicaCount will be taken from here. If ha.enabled is false no need to change | `2`
`server.resources.limits.memory` | Prometheus server pod resource limits of memory | `4Gi`
`server.resources.limits.ephemeral-storage` | Prometheus server pod resource limits of ephemeral-storage | `1Gi`
`server.resources.requests.cpu` | Prometheus server pod resource requests of cpu | `500m`
`server.resources.requests.memory` | Prometheus server pod resource requests of memory | `512Mi`
`server.resources.requests.ephemeral-storage` | Prometheus server pod resource requests of ephemeral-storage | `256Mi`

`server.configmapReload.resources.limits.memory` | user-defined server configmapReload resource limits of memory | `{{ .Values.configmapReload.resources.limits.memory }}`
`server.configmapReload.resources.limits.ephemeral-storage` | user-defined server configmapReload resource limits of ephemeral-storage | `1Gi`
`server.configmapReload.resources.requests.cpu` | user-defined server configmapReload resource requests of cpu | `{{ .Values.configmapReload.resources.requests.cpu }}`
`server.configmapReload.resources.requests.memory` | user-defined server configmapReload resource requests of memory | `{{ .Values.configmapReload.resources.requests.memory }}`
`server.configmapReload.resources.requests.ephemeral-storage` | `256Mi`

`server.cproUtil.resources.limits.memory` | user-defined server cproUtil resource limits of memory | `{{ .Values.cproUtil.resources.limits.memory }}`
`server.cproUtil.resources.limits.ephemeral-storage` | user-defined server cproUtil resource limits of ephemeral-storage | `1Gi`
`server.cproUtil.resources.requests.cpu` | user-defined server cproUtil resource requests of cpu | `{{ .Values.cproUtil.resources.requests.cpu }}`
`server.cproUtil.resources.requests.memory` | user-defined server cproUtil resource requests of memory | `{{ .Values.cproUtil.resources.requests.memory }}`
`server.cproUtil.resources.requests.ephemeral-storage` | user-defined server cproUtil resource requests of ephemeral-storage | `256Mi`

`server.containerSecurityContext.capabilities` |  Grant certain privileges to a process without granting all the privileges of the root user | ``
`server.containerSecurityContext.readOnlyRootFilesystem` | redOnlyRootFilesystem is a file attribute which only allows a user to view a file, restricting any writing to the file | `true`
`server.containerSecurityContext.allowPrivilegeEscalation` |  allowPrivilegeEscalation when set to false will make sure sub-process created by container will get more privilege than parent process | `false`
`server.securityContext` | Custom [security context](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) for server containers | `{runAsUser: 65530, fsGroup: 65530}`
`server.securityContext.runAsNonRoot` | Indicates that the container must run as a non-root user | `true`
`server.securityContext.seccompProfile.type` | defines a pod/container's seccomp profile settings. Only one profile source may be set | `RuntimeDefault`
`server.securityContext.seLinuxOptions` | seLinux in PSP and security context of POD | `{level: "", role: "", type: "", user: ""}`
`server.terminationGracePeriodSeconds` | Prometheus server pod termination grace period | `10`
`server.retention` | Prometheus data retention period | `""`
`server.terminationGracePeriodSeconds` | Prometheus server Pod termination grace period | `300`
`server.retention` | (optional) Prometheus data retention | `""`
`server.priorityClassName` | Priority ClassName can be set Priority indicates the importance of a Pod relative to other Pods |
`server.ipFamilyPolicy` | ipFamilyPolicy indicates the settings for dual stack configurations possible values include: SingleStack  PreferDualStack  RequireDualStack |
`server.ipFamilies` | ipFamilyPolicy indicates the settings for dual stack configurations possible values include:["IPv4"] ["IPv6"] ["IPv4","IPv6"] ["IPv6","IPv4"] |
`server.topologySpreadConstraints | list | `[]` | if labelSelector key is omitted and autoGenerateLabelSelector is set to true in a constraint block then labelSelector is automatically generated otherwise labelSelector are taken from labelSelector key  |
`server.imageFlavor`            | image flavor for server workload - util container which requires python runtime. Supported image flavor is rocky8-python3.8 (for Best Match) | `` |
`server.imageFlavorPolicy`            | server image Flavor Policy | `` |

### Prometheus non-HA to HA Migration Configuration

Preserve data during  upgrading from non-ha mode to ha mode the data from the prometheus server pods.
Steps:
1. When deployed in non ha mode take a backup of the deployment.
```console
$helm3 backup -n <namespace> -t <release_name>
Once backup is successful check the backup file name using
$Kubectl -n <namespace> get <brpolicy> -oyaml <brpolices.cbur.bcmt.local>
```
2. Enable server.migrate.enable in values.yaml, and provide the name of the backup folder created in previous step
3. While upgrading to ha mode, and while upgrading change the mount path along with upgrade.
```console
helm3 upgrade <release_name> <chart_folder>
```
4. Restore the backup data.
```console
helm3 restore -t <prometheus_release> -b <backup_file_name>
```

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`server.migrate.enabled` | Enable this if previously deployed in non-HA (K8S Deployment) and want to migrate to HA (K8S Statefulset). It will migrate scraped data to new created PersistentVolumes mounted to each Statefulset pod | `false`
`server.migrate.name` | migrate related container name | `migrate`
`server.migrate.resources.requests.cpu` | migrate resource requests of cpu | `200m`
`server.migrate.resources.requests.memory` | migrate resource requests of memory | `128Mi`
`server.migrate.resources.requests.ephemeral-storage` | migrate resource requests of ephemeral-storage | `256Mi`
`server.migrate.resources.limits.memory` | migrate resource limits of memory | `64Mi`
`server.migrate.resources.limits.ephemeral-storage` | migrate resource limits of ephemeral-storage | `1Gi`
`server.migrate.folderName` | The folder name you backup in non-HA. This file will be copied to CBUR STATEFULSET folder so it could be restored when cpro is in HA mode | "20210506152708"`
`server.migrate.cbur.namespace` | Namespace where CBUR is running | `"ncms"`
`server.migrate.cbur.volumeType` | Read write many volumeType used in CBUR | `"glusterfs"`
`server.migrate.cbur.glusterfs.path` | when CBUR volume type is glusterfs, path of cbur glusterfs repo. By default it is mounted to BCMT control node | `"1.2.3.4:cbur-glusterfs-repo"`
`server.migrate.cbur.glusterfs.endpoint` | when CBUR volume type is glusterfs, endpoint of cbur glusterfs repo. By default it is mounted to BCMT control node | `"glusterfs-cluster"`
`server.migrate.cbur.otherpvc.claimName` | PVC claimName details when volumeType in CBUR is other than "glusterfs" | `"cbur-local-cbur-repo"`
`server.migrate.moveDuration` | Time(seconds) for migrating data from CBUR DEPLOYMENT to STATEFULSET | `30`
`server.migrate.securityContext` | Custom [security context](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) for migrate. This should be same as that of CBUR | `{runAsUser: 0, fsGroup: 2000}`

### Prometheus Monitoring Container Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`server.monitoringContainer.enabled` | If true , Monitoring container for WAL corruptions will be enabled | `false`
`server.monitoringContainer.name` | Name of the monitoring container | `monitoringContainer`
`server.monitoringContainer.resources.limits.memory` | monitoringContainer resource limits of memory | `512Mi`
`server.monitoringContainer.resources.limits.ephemeral-storage` | monitoringContainer resource limits of ephemeral-storage | `1Gi`
`server.monitoringContainer.resources.requests.cpu` | monitoringContainer resource requests of cpu | `200m`
`server.monitoringContainer.resources.requests.memory` | monitoringContainer resource requests of memory | `128Mi`
`server.monitoringContainer.resources.requests.ephemeral-storage` | monitoringContainer resource requests of ephemeral-storage | `256Mi`
`server.monitoringContainer.loglevel` | loglevel of monitoringContainer | `INFO/DEBUG/ERROR`
`server.monitoringContainer.removetmp.enabled` | enable the removal of .tmp directories | `true/false`
`server.monitoringContainer.deltatime` | deltatime, in minutes, of monitoringContainer for WAL compaction to happen | `53`
`server.monitoringContainer.checkwalfiles.enable` | enable the check for Checksum of WAL segments in WAL directory | `true/false`
`server.monitoringContainer.checkwalfiles.compareInterval` | Interval set for checking the WAL segments | `23`
`server.monitoringContainer.checkpoint.enable` | Enable the comparision of checkpoint frequency | `true/false`
`server.monitoringContainer.imageFlavor`            | image flavor for monitoring container. Supported image flavor is rocky8-python3.8  | `` |
`server.monitoringContainer.imageFlavorPolicy`            | server image Flavor Policy | `` |

### Prometheus MVNO Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`server.mvno.enable` | Feature flag to enable mvno feature | `false`
`server.mvno.labelName` | metric label name which application needs to use for sending mvno metrics | `enterprise`
`server.mvno.defaultLabelValue` |  Default label value added by prometheus server when application doesn't send value for mvno.labelName | `default`
`server.mvno.labelValueToBeReplaced` |  MVNO Enabled: When some value is set then configured label value will be replaced with mvno.defaultLabelValue for mvno.labelName. MVNO Disabled:  when some value is set then drop mvno.labelName | ``

### Configure Alerts Monitoring Prometheus

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`server.prometheusAlertThresholds.enable` | enables Alerts for monitoring prometheus | `true`
`server.prometheusAlertThresholds.PrometheusServerDiskThresholdReached` | Percentage of server disk space to be monitored as threshold | `70`
`server.prometheusAlertThresholds.PrometheusCburDiskThresholdReached` | Percentage of cbur disk space to be monitored as threshold | `70`

### Prometheus Backup and Restore(CBUR) Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`server.cbur.enabled` | If true, CBUR feature will be enabled for Prometheus server | `true`
`server.cbur.image.imageRepo` | cbur side-car container image repository | `cbur/cbur-agent`
`server.cbur.image.imageTag` | cbur side-car container image tag | `1.1.0-alpine-6419`
`server.cbur.image.imagePullPolicy` | cbur side-car container image pull policy | `IfNotPresent`
`server.cbur.resources.limits.memory` | cbur side-car resource limits of memory | `200Mi`
`server.cbur.resources.limits.ephemeral-storage` | cbur side-car resource limits of ephemeral-storage | `1Gi`
`server.cbur.resources.requests.cpu` | cbur side-car resource requests of cpu | `100m`
`server.cbur.resources.requests.memory` | cbur side-car resource requests of memory | `64Mi`
`server.cbur.resources.requests.ephemeral-storage` | cbur side-car resource requests of ephemeral-storage | `256Mi`
`server.cbur.ephemeralVolume.enabled` |  Ephemeral Volumes shall be used if enabled  | `""`
`server.cbur.ephemeralVolume.volumedata.storageClass` |  Ephemeral Volumes storage class name  | `""`
`server.cbur.ephemeralVolume.volumedata.accessmodes` | Ephemeral Volumes Access Modes  | `[ "ReadWriteOnce" ]`
`server.cbur.ephemeralVolume.volumedata.storageSize` | Ephemeral Volumes storage size shall we specified.It can be considered to use when component requires to store more data (>1BG) with higher IOPS. | `1Gi`
`server.cbur.backendMode` | CBUR backend mode | `"local"`
`server.cbur.autoEnableCron` | indicates that the cron job is immediately scheduled when the BrPolicy is created or not | `false`
`server.cbur.autoUpdateCron` |  cronjob must be updated via brpolicy update or not | `false`
`server.cbur.cronJob` | It is used for scheduled backup task. Empty string is allowed for no scheduled backup | `"*/5 * * * *"`
`server.cbur.brOption` | This value only applies to statefulset, when ha.enabled is true. The value can be 0,1 or 2 | `2`
`server.cbur.maxCopy` | Limit the number of copies that can be saved. Once it is reached, the newer backup will overwritten the oldest one | `5`
`server.cbur.waitPodStableSeconds` | The timer to wait for pods stable after backup / restore.If not set, CBUR will wait for default  1800 seconds. |
`server.cbur.ignoreFileChanged` | Whether to ignore the file change(s) or not when creating tar file in cbura sidecar |`true`
`server.cbur.dataEncryptionEnable` | This will indicate if the backup data should be encrypted or not | `true`
`server.cbur.dataEncryptionSecretName` | name of the secret to be used while encrypting data for backup file | ``
`server.cbur.containerSecurityContext.capabilities` |  Grant certain privileges to a process without granting all the privileges of the root user | ``
`server.cbur.containerSecurityContext.readOnlyRootFilesystem` | redOnlyRootFilesystem is a file attribute which only allows a user to view a file, restricting any writing to the file | `true`
`server.cbur.containerSecurityContext.allowPrivilegeEscalation` |  allowPrivilegeEscalation when set to false will make sure sub-process created by container will get more privilege than parent process | `false`

### Prometheus Ingress Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`server.ingress.enabled` | If true, Prometheus server Ingress will be created | `false`
`server.ingress.annotations` | Prometheus server Ingress annotations | `[]`
`server.ingress.extraLabels` | Prometheus server Ingress additional labels | `{}`
`server.ingress.hosts` | Prometheus server Ingress hostnames | `[]`
`server.ingress.tls` | Prometheus server Ingress TLS configuration (YAML) | `[]`
`server.ingress.pathType` | Prometheus server Ingress pathType. All possible allowed values for pathType are "Prefix" OR "ImplementationSpecific" OR "Exact" | `Prefix`

### Prometheus Storage Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`server.persistentVolume.accessModes` | Prometheus server data Persistent Volume access modes | `[ReadWriteOnce]`
`server.persistentVolume.annotations` | Prometheus server data Persistent Volume annotations | `{}`
`server.persistentVolume.existingClaim` | Prometheus server data Persistent Volume existing claim name | `""`
`server.persistentVolume.mountPath` | Prometheus server data Persistent Volume mount root path | `/data`
`server.persistentVolume.mountPath2` | Prometheus server storage.tsdb.path  | `/data`
`server.persistentVolume.size` | Prometheus server data Persistent Volume size | 16Gi`
`server.persistentVolume.storageClass` | Prometheus server data Persistent Volume Storage Class |  `unset`
`server.persistentVolume.subPath` | Subdirectory of Prometheus server data Persistent Volume to mount | `""`

### Prometheus Service Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`server.service.annotations` | annotations for Prometheus server service | `{prometheus.io/probe: "prometheus"}`
`server.service.annotationsForScrape` | annotations for Prometheus server service | `{prometheus.io/probe: "prometheus"}`
`server.service.labels` | labels for Prometheus server service | `{}`
`server.service.clusterIP` | internal Prometheus server cluster service IP | `""`
`server.service.externalIPs` | Prometheus server service external IP addresses | `[]`
`server.service.loadBalancerIP` | IP address to assign to load balancer (if supported) | `""`
`server.service.loadBalancerSourceRanges` | list of IP CIDRs allowed access to load balancer (if supported) | `[]`
`server.service.nodePort` | Port to be used as the service NodePort (ignored if `server.service.type` is not `NodePort`) | `0`
`server.service.servicePort` | Prometheus server service port | `80`
`server.service.webPort` | Prometheus server application port | `9090`
`server.service.type` | type of Prometheus server service to create | `ClusterIP`

### Prometheus Probes Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`server.startupProbe.initialDelaySeconds` | Prometheus startupProbe intialDelaySeconds                                                                                                                                                    | `0`
`server.startupProbe.timeoutSeconds` | Prometheus startupProbe timeoutSeconds                                                                                                                                                        | `30`
`server.startupProbe.failureThreshold` | Prometheus startupProbe failureThreshold                                                                                                                                                      | `120`
`server.startupProbe.periodSeconds` | Prometheus startupProbe periodSeconds                                                                                                                                                         | `10`
`server.livenessProbe.initialDelaySeconds` | Prometheus livenessProbe intialDelaySeconds                                                                                                                                                   | `0`
`server.livenessProbe.timeoutSeconds` | Prometheus livenessProbe timeoutSeconds                                                                                                                                                       | `30`
`server.livenessProbe.failureThreshold` | Prometheus livenessProbe failureThreshold                                                                                                                                                     | `3`
`server.livenessProbe.periodSeconds` | Prometheus livenessProbe periodSeconds                                                                                                                                                        | `10`
`server.readinesProbe.initialDelaySeconds` | Prometheus readinessProbe intialDelaySeconds                                                                                                                                                  | `0`
`server.readinessProbe.timeoutSeconds` | Prometheus readinessProbe timeoutSeconds                                                                                                                                                      | `30`
`server.readinessProbe.failureThreshold` | Prometheus readinessProbe failureThreshold                                                                                                                                                    | `3`
`server.readinessProbe.periodSeconds` | Prometheus readinessProbe periodSeconds                                                                                                                                                       | `10`
`server.useReadyInStartupProbe` | Use this option to enable restart of cpro-server by startupprobe (This uses ready endpoint in startupProbe) when it does not start up within the duration of failureThreshold * periodSeconds | `false`

## Prometheus Server TLS Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`server.tls_auth_config.secretForWebConfig` | Secret needs to created manually for configuration file | `
`server.tls_auth_config.tls.enabled` | If metrices from server needs to be scrapped in tls mode | `false`
`server.tls_auth_config.tls.externalSecret` | secretname of certificates if certmanger is not used | ``
`server.tls_auth_config.tls.dnsNames` | DNS used in certificate | `localhost`
`server.tls_auth_config.tls.ipAddress` | Alt Names used in certificate |
`server.tls_auth_config.insecureReload` | use insecure url for configmap reload | `false`


| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`server.tls.enabled` | Enable TLS for server | ``
`server.tls.issuerRef.name` | Secret name, pointing to a Secret object. If empty then automatically generated secret with certificate will be used | ``
`server.tls.issuerRef.keyNames.caCrt` | Name of Secret key, which contains CA certificate | `"ca.crt"`
`server.tls.issuerRef.keyNames.tlsKey` | Name of Secret key, which contains TLS key | `"tls.key"`
`server.tls.issuerRef.keyNames.tlsCrt` | Name of Secret key, which contains TLS certificate | `"tls.crt"`
| `server.certificate.enabled` | Certificate object is created based on this parameter  | `true` |
| `server.certificate.issuerRef.name` | Issuer Name | |
| `server.certificate.issuerRef.kind` | CRD Name | |
| `server.certificate.issuerRef.group` | Api group Name | |
| `server.certificate.duration` | How long certificate will be valid | `8760h` |
| `server.certificate.renewBefore` | When to renew the certificate before it gets expired | `360h` |
| `server.certificate.subject` | Not needed in internal communication | |
| `server.certificate.commonName` | It has been deprecated since 2000 and is discouraged from being used for a server side certificates | |
| `server.certificate.usages` |Usages is the set of x509 usages that are requested for the certificate | |
| `server.certificate.dnsNames` | DNSNames is a list of DNS subjectAltNames to be set on the Certificate. |  |
| `server.certificate.uris` | URIs is a list of URI subjectAltNames to be set on the Certificate. | |
| `server.certificate.ipAddresses` | IPAddresses is a list of IP address subjectAltNames to be set on the Certificate. | |
| `server.certificate.privateKey.algorithm` | Algorithm used to encode key value pair | |
| `server.certificate.privateKey.encoding` | Encode the key pair value | |
| `server.certificate.privateKey.size` | size of the key pair  |
| `server.certificate.privateKey.rotationPolicy` | Rotation of a key pair, when certificate is refreshed is recommended from a security point of view | `Always` |

## Prometheus Server Istio Gateway Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`istio.gateways.cproServer.enabled`         | If the gateway is enabled or not. If False, gateway will not be created | `true`
`istio.gateways.cproServer.labels`         | The labels that need to be added to the gateway | `{}`
`istio.gateways.cproServer.annotations`         | The annotations that need to be added to the gateway | `{}`
`istio.gateways.cproServer.ingressPodSelector`         | Istio ingress gateway selector | `{istio: ingressgateway}`
`istio.gateways.cproServer.port`         | The port for the Gateway to connect to | `443`
`istio.gateways.cproServer.protocol`         | The protocol for the Gateway will use | `HTTPS`
`istio.gateways.cproServer.host`         | the host used to access the management GUI from istio ingress gateway. If empty default will be * | `[]`
`istio.gateways.cproServer.tls.redirect`         | Whether the request to be redirected from HTTP to HTTPS | `true`
`istio.gateways.cproServer.tls.mode`         | mode could be SIMPLE, MUTUAL, PASSTHROUGH, ISTIO_MUTUAL | `SIMPLE`
`istio.gateways.cproServer.tls.credentialName`         | Secret name for Istio Ingress | `"am-gateway"`
`istio.gateways.cproServer.tls.custom`         | Custom TLS configurations that needs to be added to the gateway | `{}`

### Prometheus ConfigMap Files Configuration

Prometheus is configured through [prometheus.yml](https://prometheus.io/docs/operating/configuration/). This file (and any others listed in `serverFiles`) will be mounted into the `server` pod.

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`serverFiles.alerts` | Prometheus server configmap entries | `` |
`serverFiles.rules` | Rules to be added to Prometheus server configmap entries | `` |
`serverFiles.prometheus.yml` | Prometheus server configuration | `` |
`customScrapeJobs` | Define custom scrape job here for Prometheus. These jobs will be appended to prometheus.yml | `[]`

## PushGateway Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`pushgateway.enabled` | If true, create pushgateway | `true`
`pushgateway.name` | pushgateway container name | `pushgateway`
`pushgateway.imageFlavor` | pushgateway image flavor | ``
`pushgateway.imageFlavorPolicy` | pushgateway image flavor Policy | ``
`pushgateway.antiAffinityMode` | Affinity mode of push gateway pods. soft means preferredDuringSchedulingIgnoredDuringExecution, hard means requiredDuringSchedulingIgnoredDuringExecution | `"soft"`
`pushgateway.extraArgs` | Additional pushgateway container arguments | `{push.disable-consistency-check: ""}`
`pushgateway.extraArgs.persistence.file` | when persistence.file is used it will create a mount path, hence use a path that is not used in the container | `/opt/pushgateway/file.txt`
`pushgateway.baseURL` | External URL which can access pushgateway, when istio is enabled: baseURL path and Contextroot path should match | `""`
`pushgateway.prefixURL` | The URL prefix at which the container can be accessed. Useful in the case the '-web.external-url' includes a slug. so that the various internal URLs are still able to access as they are in the default case | `""`
`pushgateway.tolerations` | node taints to tolerate (requires Kubernetes >=1.6) | `[]`
`pushgateway.nodeSelector` | node labels for Pushgateway server pod assignment | `{}`
`pushgateway.affinity` | affinity for pushgateway pods | `{}`
`pushgateway.podAnnotations` | Pod annotations for pushgateway  | `{}`
`pushgateway.replicaCount` | Number of replicas of pushgateway | `1`
`pushgateway.resources.limits.memory` | Pushgateway pod resource limits of memory | `200Mi`
`pushgateway.resources.limits.ephemeral-storage` | Pushgateway pod resource limits of ephemeral-storage | `1Gi`
`pushgateway.resources.requests.cpu` | Pushgateway pod resource requests of cpu | `10m`
`pushgateway.resources.requests.memory` | Pushgateway  pod resource requests of memory | `32Mi`
`pushgateway.resources.requests.ephemeral-storage` | Pushgateway  pod resource requests of ephemeral-storage | `256Mi`
`pushgateway.progressDeadlineSeconds` | Pushgateway progressDeadlineSeconds for deployment. progressDeadlineSeconds at compenent level always takes precedence | `600`
`pushgateway.pdb` | Pod disruption budget for Pushgateway will define minAvailable or maxUnavailable when there is disruption. User have to configure as per the requirement | `{enabled: false, minAvailable: 1 || maxUnavailable: 0 }`
`pushgateway.priorityClassName` | Priority ClassName can be set Priority indicates the importance of a Pod relative to other Pods |
`pushgateway.ipFamilyPolicy` | ipFamilyPolicy indicates the settings for dual stack configurations possible values include: SingleStack  PreferDualStack  RequireDualStack |
`pushgateway.ipFamilies` | ipFamilyPolicy indicates the settings for dual stack configurations possible values include:["IPv4"] ["IPv6"] ["IPv4","IPv6"] ["IPv6","IPv4"] |
`pushgateway.topologySpreadConstraints | list | `[]` | if labelSelector key is omitted and autoGenerateLabelSelector is set to true in a constraint block then labelSelector is automatically generated otherwise labelSelector are taken from labelSelector key  |

### PushGateway Storage Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`pushgateway.persistentVolume.accessModes` | Prometheus server data Persistent Volume access modes | `[ReadWriteOnce]`
`pushgateway.persistentVolume.annotations` | Prometheus server data Persistent Volume annotations | `{}`
`pushgateway.persistentVolume.existingClaim` | Prometheus server data Persistent Volume existing claim name | `""`
`pushgateway.persistentVolume.mountPath` | Prometheus server data Persistent Volume mount root path | `/data`
`pushgateway.persistentVolume.mountPath2` | Prometheus server storage.tsdb.path  | `/data`
`pushgateway.persistentVolume.size` | Prometheus server data Persistent Volume size | `1Gi`
`pushgateway.persistentVolume.storageClass` | Prometheus server data Persistent Volume Storage Class |  `unset`
`pushgateway.persistentVolume.subPath` | Subdirectory of Prometheus server data Persistent Volume to mount | `""`

### PushGateway Ingress Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`pushgateway.ingress.enabled` | If true, pushgateway Ingress will be created | `false`
`pushgateway.ingress.annotations` | pushgateway Ingress annotations | `{}`
`pushgateway.ingress.hosts` | pushgateway Ingress hostnames | `[]`
`pushgateway.ingress.tls` | pushgateway Ingress TLS configuration (YAML) | `[]`
`pushgateway.ingress.pathType` | pushgateway Ingress pathType. All possible allowed values for pathType are "Prefix" OR "ImplementationSpecific" OR "Exact" | `"Prefix"`

### PushGateway Random User Configuration (Openshift environment only)

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`pushgateway.containerSecurityContext.capabilities` |  Grant certain privileges to a process without granting all the privileges of the root user | ``
`pushgateway.containerSecurityContext.readOnlyRootFilesystem` | redOnlyRootFilesystem is a file attribute which only allows a user to view a file, restricting any writing to the file | `true`
`pushgateway.containerSecurityContext.allowPrivilegeEscalation` |  allowPrivilegeEscalation when set to false will make sure sub-process created by container will get more privilege than parent process | `false`
`pushgateway.securityContext.runAsNonRoot` | Indicates that the container must run as a non-root user | `true`
`pushgateway.securityContext.seccompProfile.type` | defines a pod/container's seccomp profile settings. Only one profile source may be set | `RuntimeDefault`
`pushgateway.securityContext` | Security context of the Pushgateway pods | `{ runAsUser: 65530, fsGroup: 65530}`
`pushgateway.securityContext.seLinuxOptions` | seLinux in PSP and security context of POD | `{level: "", role: "", type: "", user: ""}`

### PushGateway Service Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`pushgateway.service.annotations` | Annotations for Pushgateway service | `{prometheus.io/probe: pushgateway}`
`pushgateway.service.labels` | Labels to be added to Pushgateway service | `{}`
`pushgateway.service.clusterIP` | Cluster ip in the service to be used |  `""`
`pushgateway.service.externalIPs` | List of IP addresses at which the pushgateway service is available | `[]`
`pushgateway.service.loadBalancerIP` | Load balancer ip in the pushgateway | `""`
`pushgateway.service.loadBalancerSourceRanges` | Load balancer source ranges in Service | `[]`
`pushgateway.service.servicePort` | Port at which service is available | `9091`
`pushgateway.service.type` | Type of the service | `ClusterIP`

### PushGateway Probes Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`pushgateway.livenessProbe.initialDelaySeconds` | Liveness Probe initial delay seconds | `0`
`pushgateway.livenessProbe.timeoutSeconds` | LivenessProbe timeoutSeconds | `30`
`pushgateway.livenessProbe.failureThreshold` | LivenessProbe failureThreshold | `3`
`pushgateway.livenessProbe.periodSeconds` | LivenessProbe periodSeconds | `10`
`pushgateway.readinesProbe.initialDelaySeconds` | ReadinessProbe initial delay seconds | `0`
`pushgateway.readinessProbe.timeoutSeconds` | ReadinessProbe timeoutSeconds | `30`
`pushgateway.readinessProbe.failureThreshold` | ReadinessProbe failureThreshold | `3`
`pushgateway.readinessProbe.periodSeconds` | ReadinessProbe periodSeconds | `10`

### PushGateway TLS Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`pushgateway.tls_auth_config.secretForWebConfig` | Secret needs to created manually for configuration file | `
`pushgateway.tls_auth_config.tls.enabled` | If metrices from pushgateway needs to be scrapped in tls mode | `false`
`pushgateway.tls_auth_config.tls.externalSecret` | secretname of certificates if certmanger is not used | ``
`pushgateway.tls_auth_config.tls.dnsNames` | DNS used in certificate | `localhost`
`pushgateway.tls_auth_config.tls.ipAddress` | Alt Names used in certificate |

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`pushgateway.tls.enabled` | Enable TLS for  pushgateway | ``
`pushgateway.tls.issuerRef.name` | Secret name, pointing to a Secret object. If empty then automatically generated secret with certificate will be used | ``
`pushgateway.tls.issuerRef.keyNames.caCrt` | Name of Secret key, which contains CA certificate | `"ca.crt"`
`pushgateway.tls.issuerRef.keyNames.tlsKey` | Name of Secret key, which contains TLS key | `"tls.key"`
`pushgateway.tls.issuerRef.keyNames.tlsCrt` | Name of Secret key, which contains TLS certificate | `"tls.crt"`
| `pushgateway.certificate.enabled` | Certificate object is created based on this parameter  | `true` |
| `pushgateway.certificate.issuerRef.name` | Issuer Name | |
| `pushgateway.certificate.issuerRef.kind` | CRD Name | |
| `pushgateway.certificate.issuerRef.group` | Api group Name | |
| `pushgateway.certificate.duration` | How long certificate will be valid | `8760h` |
| `pushgateway.certificate.renewBefore` | When to renew the certificate before it gets expired | `360h` |
| `pushgateway.certificate.subject` | Not needed in internal communication | |
| `pushgateway.certificate.commonName` | It has been deprecated since 2000 and is discouraged from being used for a server side certificates | |
| `pushgateway.certificate.usages` |Usages is the set of x509 usages that are requested for the certificate | |
| `pushgateway.certificate.dnsNames` | DNSNames is a list of DNS subjectAltNames to be set on the Certificate. |  |
| `pushgateway.certificate.uris` | URIs is a list of URI subjectAltNames to be set on the Certificate. | |
| `pushgateway.certificate.ipAddresses` | IPAddresses is a list of IP address subjectAltNames to be set on the Certificate. | |
| `pushgateway.certificate.privateKey.algorithm` | Algorithm used to encode key value pair | |
| `pushgateway.certificate.privateKey.encoding` | Encode the key pair value | |
| `pushgateway.certificate.privateKey.size` | size of the key pair  |
| `pushgateway.certificate.privateKey.rotationPolicy` | Rotation of a key pair, when certificate is refreshed is recommended from a security point of view | `Always` |
### PushGateway Istio Gateway Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`istio.gateways.cproPushgateway.enabled`         | If the gateway is enabled or not. If False, gateway will not be created | `true`
`istio.gateways.cproPushgateway.labels`         | The labels that need to be added to the gateway | `{}`
`istio.gateways.cproPushgateway.annotations`         | The annotations that need to be added to the gateway | `{}`
`istio.gateways.cproPushgateway.ingressPodSelector`         | Istio ingress gateway selector | `{istio: ingressgateway}`
`istio.gateways.cproPushgateway.port`         | The port for the Gateway to connect to | `443`
`istio.gateways.cproPushgateway.protocol`         | The protocol for the Gateway will use | `HTTPS`
`istio.gateways.cproPushgateway.host`         | the host used to access the management GUI from istio ingress gateway. If empty default will be * | `[]`
`istio.gateways.cproPushgateway.tls.redirect`         | Whether the request to be redirected from HTTP to HTTPS | `true`
`istio.gateways.cproPushgateway.tls.mode`         | mode could be SIMPLE, MUTUAL, PASSTHROUGH, ISTIO_MUTUAL | `SIMPLE`
`istio.gateways.cproPushgateway.tls.credentialName`         | Secret name for Istio Ingress | `"am-gateway"`
`istio.gateways.cproPushgateway.tls.custom`         | Custom TLS configurations that needs to be added to the gateway | `{}`

## Webhook4fluentd Configuration

Webhook4fluentd is a service to receive alerts messages from Alertmanager and sends it to CALM in Harmonized Logging Format.
> **Note**:In container deployment environment, it's strongly recommended to use CNOT as a replacement of Webhook to sends alerts out via SMS/EMAIL/SLACK/SNMP trap channels. CNOT is a common notification component which fully covers webhook4fluentd's function.

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`webhook4fluentd.enabled` | install webhook4fluentd as part of  this chart or not |  `false`
`webhook4fluentd.imageFlavor` | webhook4fluentd image flavor | ``
`webhook4fluentd.imageFlavorPolicy` | webhook4fluentd image flavor Policy | ``
`webhook4fluentd.fluentd.port` | fluentd port where fluentd listens |  `24224`
`webhook4fluentd.fluentd.svc` | fluentd svc to send the alerts from the webhook. service must be svc: < fluentd service name>.<namespace where fluentd is installed>.svc.<clusterDomain>. If either fluentd port or svc is not configured then alerts will get print on the webhook console logs |  ``
`webhook4fluentd.fluentd.tag` | This tag is an internal string that is used in a later stage by the Router to decide which Filter or match phase it must go through.  |  `nokia.logging.webhook4fluentd.alarm`
|`webhook4fluentd.tls.secretRef.name`      | Name of secret containing syslog CA certificate. workload level will have priority than root level | `null` |
|`webhook4fluentd.tls.secretRef.keyNames.caCrt`      | Name of secret containing  CA certificate. workload level will have priority than root level | `ca.crt` |
|`webhook4fluentd.secretMountPath`      | secrets mount path  | `/var/lib/webhook` |
|`webhook4fluentd.mintlsVersion`      | minimumtlsVersion is the Minimum TLS Version only allows HTTPS connections from visitors that support the selected TLS protocol version. Supported values are TLS10, TLS11,TL12,TLS13  | `TLS12` |
|`webhook4fluentd.unifiedLogging.extension`      | extension for the workload | `{}` |
`webhook4fluentd.name` | webhook4fluentd container name | `wehbook4fluentd`
`webhook4fluentd.antiAffinityMode` | Affinity mode for the wehbook4fluentd pods soft means preferredDuringSchedulingIgnoredDuringExecution, hard means requiredDuringSchedulingIgnoredDuringExecution| `"soft"`
`webhook4fluentd.tolerations` | node taints to tolerate (requires Kubernetes >=1.6) | `[]`
`webhook4fluentd.nodeSelector` | node labels for webhook4fluentd  pod assignment| `{}`
`webhook4fluentd.podAnnotations` | Pod annotations of webhook4fluentd | `{}`
`webhook4fluentd.replicaCount` | Number of replica of wehbook4fluentd | `2`
`webhook4fluentd.resources.limits.memory` | webhook4fluentd resource limits of memory|`200Mi`
`webhook4fluentd.resources.limits.ephemeral-storage` | webhook4fluentd resource limits of ephemeral-storage|`1Gi`
`webhook4fluentd.resources.requests.cpu` | webhook4fluentd resource request of cpu | `10m`
`webhook4fluentd.resources.requests.memory` |webhook4fluentd resource request of memory | `32Mi`
`webhook4fluentd.resources.requests.ephemeral-storage` |webhook4fluentd resource request of ephemeral-storage | `20Mi`
`webhook4fluentd.progressDeadlineSeconds` | webhook4fluentd progressDeadlineSeconds for deployment. progressDeadlineSeconds at compenent level always takes precedence | `600`
`webhook4fluentd.pdb` | Pod disruption budget for webhook4fluentd will define minAvailable or maxUnavailable when there is disruption. User have to configure as per the requirement | `{enabled: true, minAvailable: 1 || maxUnavailable: 50% }`
`webhook4fluentd.priorityClassName` | Priority ClassName can be set Priority indicates the importance of a Pod relative to other Pods |
`webhook4fluentd.ipFamilyPolicy` | ipFamilyPolicy indicates the settings for dual stack configurations possible values include: SingleStack  PreferDualStack  RequireDualStack |
`webhook4fluentd.ipFamilies` | ipFamilyPolicy indicates the settings for dual stack configurations possible values include:["IPv4"] ["IPv6"] ["IPv4","IPv6"] ["IPv6","IPv4"] |
`webhook4fluentd.topologySpreadConstraints | list | `[]` | if labelSelector key is omitted and autoGenerateLabelSelector is set to true in a constraint block then labelSelector is automatically generated otherwise labelSelector are taken from labelSelector key  |

### webhook4fluentd Random User Configuration (Openshift Environment only)

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`webhook4fluentd..containerSecurityContext.capabilities` |  Grant certain privileges to a process without granting all the privileges of the root user | ``
`webhook4fluentd.securityContext.runAsNonRoot` | Indicates that the container must run as a non-root user | `true`
`webhook4fluentd.securityContext.seccompProfile.type` | defines a pod/container's seccomp profile settings. Only one profile source may be set | `RuntimeDefault`
`webhook4fluentd.securityContext.runAsUser` | User with which webhook4fluentd container runs | `65534`
`webhook4fluentd.securityContext.fsGroup` | fs group with  which webhook4fluentd container runs | `65534`
`webhook4fluentd.securityContext.seLinuxOptions` | seLinux in PSP and security context of POD | `{level: "", role: "", type: "", user: ""}`

### webhook4fluentd Service Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`webhook4fluentd.service.annotations` | Service Annotations of webhook4fluentd | `{prometheus.io/scrape: "true"}`
`webhook4fluentd.service.annotationsForScrape` | Service Annotations of webhook4fluentd | `{prometheus.io/scrape: "true"}`
`webhook4fluentd.service.labels` | Service labels to be added for webhook4fluentd | `{}`
`webhook4fluentd.service.receiverPort` | Port at which webhook4fluentd  is available| `8004`
`webhook4fluentd.service.servicePort` | Port at which webhook4fluentd service is available| `8005`
`webhook4fluentd.service.type` | Service type of webhook4fluentd | `ClusterIP`

### webhook4fluentd Probes Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`webhook4fluentd.livenessProbe.initialDelaySeconds` | Liveness Probe initial delay seconds | `0`
`webhook4fluentd.livenessProbe.timeoutSeconds` | LivenessProbe timeoutSeconds | `30`
`webhook4fluentd.livenessProbe.failureThreshold` | LivenessProbe failureThreshold | `3`
`webhook4fluentd.livenessProbe.periodSeconds` | LivenessProbe periodSeconds | `10`
`webhook4fluentd.readinesProbe.initialDelaySeconds` | ReadinessProbe initial delay seconds | `0`
`webhook4fluentd.readinessProbe.timeoutSeconds` | ReadinessProbe timeoutSeconds | `30`
`webhook4fluentd.readinessProbe.failureThreshold` | ReadinessProbe failureThreshold | `3`
`webhook4fluentd.readinessProbe.periodSeconds` | ReadinessProbe periodSeconds | `10`

### webhook4fluentd certificate Configuration
| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
| `webhook4fluentd.certificate.enabled` | Certificate object is created based on this parameter  | `true` |
| `webhook4fluentd.certificate.issuerRef.name` | Issuer Name | |
| `webhook4fluentd.certificate.issuerRef.kind` | CRD Name | |
| `webhook4fluentd.certificate.issuerRef.group` | Api group Name | |
| `webhook4fluentd.certificate.duration` | How long certificate will be valid | `8760h` |
| `webhook4fluentd.certificate.renewBefore` | When to renew the certificate before it gets expired | `360h` |
| `webhook4fluentd.certificate.subject` | Not needed in internal communication | |
| `webhook4fluentd.certificate.commonName` | It has been deprecated since 2000 and is discouraged from being used for a server side certificates | |
| `webhook4fluentd.certificate.usages` |Usages is the set of x509 usages that are requested for the certificate | |
| `webhook4fluentd.certificate.dnsNames` | DNSNames is a list of DNS subjectAltNames to be set on the Certificate. |  |
| `webhook4fluentd.certificate.uris` | URIs is a list of URI subjectAltNames to be set on the Certificate. | |
| `webhook4fluentd.certificate.ipAddresses` | IPAddresses is a list of IP address subjectAltNames to be set on the Certificate. | |
| `webhook4fluentd.certificate.privateKey.algorithm` | Algorithm used to encode key value pair | |
| `webhook4fluentd.certificate.privateKey.encoding` | Encode the key pair value | |
| `webhook4fluentd.certificate.privateKey.size` | size of the key pair  |
| `webhook4fluentd.certificate.privateKey.rotationPolicy` | Rotation of a key pair, when certificate is refreshed is recommended from a security point of view | `Always` |
###  Configuration

Prometheus is configured through [prometheus.yml](https://prometheus.io/docs/operating/configuration/). This file (and any others listed in `serverFiles`) will be mounted into the `server` pod.

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`serverFiles.alerts` | Prometheus server configmap entries | `` |
`serverFiles.rules` | Rules to be added to Prometheus server configmap entries | `` |
`serverFiles.prometheus.yml` | Prometheus server configuration | `` |
`customScrapeJobs` | Define custom scrape job here for Prometheus. These jobs will be appended to prometheus.yml | `[]`

## RestServer Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`restserver.enabled` | If true, create restserver| `true`
`restserver.name` | restserver container name | `restserver`
`restserver.podAnnotations` | Annotations to be added to restserver pod | `{}`
`restserver.env` | set environment variable for restserver | `{}`
`restserver.BCMT.serverURL` | BCMT URL that is needed for accessing API server | `https://kubernetes.default.svc:443`
`restserver.antiAffinityMode` | Affinity Mode  for restserver pods. soft means preferredDuringSchedulingIgnoredDuringExecution. hard means requiredDuringSchedulingIgnoredDuringExecution | `"soft"`
`restserver.useJDK17Image` | By default Rocky8 JDK11 image is used for restapi. set useJDK17Image to true in order to use Rocky8 JDK17 image | `false`
`restserver.image.imageRepo` | restserver container image repository | `cpro/registry4/cpro-restapi`
`restserver.image.imageTag` | restserver container image tag | `5.0.1-4.1.0-3220`
`restserver.image.imagePullPolicy` | restserver container image pull policy | `IfNotPresent`
`restserver.restapirocky.imageRepo` | restserver container rocky image repository | `cpro/registry4/prometheus-restapi-rocky`
`restserver.restapirocky.imageTag` | restserver container rocky image tag | `{{ .Values.restserver.image.restapi.imageTag }}`
`restserver.restapirocky.imagePullPolicy` | restserver container rocky image pull policy | `IfNotPresent`
`restserver.restapijdk17rocky.imageRepo` | restserver container JDK17 rocky image repository | `cpro/registry4/prometheus-restapi-jdk17-rocky`
`restserver.restapijdk17rocky.imageTag` | restserver container JDK17 rocky image tag | `{{ .Values.restserver.image.restapi.imageTag }}`
`restserver.restapijdk17rocky.imagePullPolicy` | restserver container JDK17 rocky image pull policy | `IfNotPresent`
`restserver.replicaCount` | restserver replica count | `1`
`restserver.certificateSecret` | secret which contains the certificates for restsever when used in https mode | ``
`restserver.resources.limits.memory` | restserver pod resource limits of memory | `500Mi`
`restserver.resources.limits.ephemeral-storage` | restserver pod resource limits of ephemeral-storage | `1Gi`
`restserver.resources.requests.cpu` | restserver pod resource requests of cpu | `100m`
`restserver.resources.requests.memory` | restserver pod resource requests of memory | `128Mi`
`restserver.resources.requests.ephemeral-storage` | restserver pod resource requests of ephemeral-storage | `256Mi`

`restserver.configmapReload.resources.limits.memory` | user-defined restserver configmapReload resource limits of memory | `{{ .Values.configmapReload.resources.limits.memory }}`
`restserver.configmapReload.resources.limits.ephemeral-storage` | user-defined restserver configmapReload resource limits of ephemeral-storage | `1Gi`
`restserver.configmapReload.resources.requests.cpu` | user-defined restserver configmapReload resource requests of cpu | `{{ .Values.configmapReload.resources.requests.cpu }}`
`restserver.configmapReload.resources.requests.memory` | user-defined restserver configmapReload resource requests of memory | `{{ .Values.configmapReload.resources.requests.memory }}`
`restserver.configmapReload.resources.requests.ephemeral-storage` | user-defined restserver configmapReload resource requests of ephemeral-storage | `256Mi`
`restserver.nodeSelector` | node labels for restserver pod assignment | `{}`
`restserver.tolerations` | Tolerations of RestAPI server | `[]`
`restserver.loglevel` | Log Level: DEBUG < INFO < WARN < ERROR < FATAL < OFF | `INFO`
`restserver.progressDeadlineSeconds` | restserver  progressDeadlineSeconds for deployment. progressDeadlineSeconds at compenent level always takes precedence | `600`
`restserver.pdb` | Pod disruption budget for restserver will define minAvailable or maxUnavailable when there is disruption. User have to configure as per the requirement | `{enabled: false, minAvailable: 1 || maxUnavailable: 0 }`
`restserver.contextRoot` | Context root that is used to distinguish services. | `restserver`
`restserver.priorityClassName` | Priority ClassName can be set Priority indicates the importance of a Pod relative to other Pods |
`restserver.ipFamilyPolicy` | ipFamilyPolicy indicates the settings for dual stack configurations possible values include: SingleStack  PreferDualStack  RequireDualStack |
`restserver.ipFamilies` | ipFamilyPolicy indicates the settings for dual stack configurations possible values include:["IPv4"] ["IPv6"] ["IPv4","IPv6"] ["IPv6","IPv4"] |
`restserver.imageFlavor`            | image flavor for the workloads. workload level configured imageflavor will take precedence on root level. restserver initContainer requires python runtime and main restapi continer requires java runtime, so imageflavor under restserver should be combination of OS, java runtime and python runtime. Supported image flavors are rocky8-python3.8-jre17 (for best Match)  | `` |
`restserver.imageFlavorPolicy`| Image Flavor Policy for restserver  | `` |


### RestServer Service Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`restserver.service.type` | type of restserver service to create | `ClusterIP`
`restserver.service.servicePort` | restserver service port | `8888`
`restserver.service.nodePort` | restserver service node port | `32766`

### RestServer Ingress Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`restserver.ingress.enabled` | If true, restserver Ingress will be created | `false`
`restserver.ingress.annotations` | restserver Ingress annotations | `{}`
`restserver.ingress.hosts` | restserver Ingress hostnames | `[]`
`restserver.ingress.tls` | restserver Ingress TLS configuration (YAML) | `[]`
`restserver.ingress.pathType` | restserver Ingress pathType. All possible allowed values for pathType are "Prefix" OR "ImplementationSpecific" OR "Exact" | `"Prefix"`

### RestServer Random User Configuration (Openshift environment only)

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`restserver.containerSecurityContext.capabilities` |  Grant certain privileges to a process without granting all the privileges of the root user | ``
`restserver.containerSecurityContext.readOnlyRootFilesystem` | redOnlyRootFilesystem is a file attribute which only allows a user to view a file, restricting any writing to the file | `true`
`restserver.containerSecurityContext.allowPrivilegeEscalation` |  allowPrivilegeEscalation when set to false will make sure sub-process created by container will get more privilege than parent process | `false`
`restserver.securityContext.runAsNonRoot` | Indicates that the container must run as a non-root user | `true`
`restserver.securityContext.seccompProfile.type` | defines a pod/container's seccomp profile settings. Only one profile source may be set | `RuntimeDefault`
`restserver.securityContext.runAsUser` | restserver run as  user | `1999`
`restserver.securityContext.fsGroup` | restserver use fsGroup | `1999`
`restserver.securityContext.seLinuxOptions` | seLinux in PSP and security context of POD | `{level: "", role: "", type: "", user: ""}`
`restserver.topologySpreadConstraints | list | `[]` | if labelSelector key is omitted and autoGenerateLabelSelector is set to true in a constraint block then labelSelector is automatically generated otherwise labelSelector are taken from labelSelector key  |


### RestServer TLS Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`restserver.configs.httpsEnabled` | if https access enabled | `false`
`restserver.configs.httpPort` | restserver httpport | `8880`
`restserver.configs.min_version` | restserver TLS version can be set. Accepted values are TLS12 and TLS13 if no value is set it shall pick TLS12 as default value | `TLS12`
`restserver.configs.reloadPort` | restserver reload port | `9090`
`restserver.configs.restCACert` | restserver CACert | `content of restCACert`
`restserver.configs.restServerKey` | restserver private key | `content of restServerKey`
`restserver.configs.restServerCert` | restserver cert | `content of restServerCert`
`restserver.configs.restServerCert.tls_auth_config.tls.dnsNames` | DNS used in certificate |
`restserver.configs.restServerCert.tls_auth_config.tls.ipAddress` | Alt Names used in certificate |

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`restserver.tls.enabled` | Enable TLS for restserver | ``
`restserver.tls.issuerRef.name` | Secret name, pointing to a Secret object. If empty then automatically generated secret with certificate will be used | ``
`restserver.tls.issuerRef.keyNames.caCrt` | Name of Secret key, which contains CA certificate | `"ca.crt"`
`restserver.tls.issuerRef.keyNames.tlsKey` | Name of Secret key, which contains TLS key | `"tls.key"`
`restserver.tls.issuerRef.keyNames.tlsCrt` | Name of Secret key, which contains TLS certificate | `"tls.crt"`
| `restserver.certificate.enabled` | Certificate object is created based on this parameter  | `true` |
| `restserver.certificate.issuerRef.name` | Issuer Name | |
| `restserver.certificate.issuerRef.kind` | CRD Name | |
| `restserver.certificate.issuerRef.group` | Api group Name | |
| `restserver.certificate.duration` | How long certificate will be valid | `8760h` |
| `restserver.certificate.renewBefore` | When to renew the certificate before it gets expired | `360h` |
| `restserver.certificate.subject` | Not needed in internal communication | |
| `restserver.certificate.commonName` | It has been deprecated since 2000 and is discouraged from being used for a server side certificates | |
| `restserver.certificate.usages` |Usages is the set of x509 usages that are requested for the certificate | |
| `restserver.certificate.dnsNames` | DNSNames is a list of DNS subjectAltNames to be set on the Certificate. |  |
| `restserver.certificate.uris` | URIs is a list of URI subjectAltNames to be set on the Certificate. | |
| `restserver.certificate.ipAddresses` | IPAddresses is a list of IP address subjectAltNames to be set on the Certificate. | |
| `restserver.certificate.privateKey.algorithm` | Algorithm used to encode key value pair | |
| `restserver.certificate.privateKey.encoding` | Encode the key pair value | |
| `restserver.certificate.privateKey.size` | size of the key pair  |
| `restserver.certificate.privateKey.rotationPolicy` | Rotation of a key pair, when certificate is refreshed is recommended from a security point of view | `Always` |
Note: There are a few parameters specific for BCMT environment, they are NCM access login info.

### RestServer Probes Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`restserver.livenessProbe.initialDelaySeconds` | Liveness Probe initial delay seconds | `0`
`restserver.livenessProbe.timeoutSeconds` | LivenessProbe timeoutSeconds | `30`
`restserver.livenessProbe.failureThreshold` | LivenessProbe failureThreshold | `3`
`restserver.livenessProbe.periodSeconds` | LivenessProbe periodSeconds | `10`
`restserver.readinesProbe.initialDelaySeconds` | ReadinessProbe initial delay seconds | `0`
`restserver.readinessProbe.timeoutSeconds` | ReadinessProbe timeoutSeconds | `30`
`restserver.readinessProbe.failureThreshold` | ReadinessProbe failureThreshold | `3`
`restserver.readinessProbe.periodSeconds` | ReadinessProbe periodSeconds | `10`

### RestServer Istio Gateway Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`istio.gateways.cproRestServer.enabled`         | If the gateway is enabled or not. If False, gateway will not be created | `true`
`istio.gateways.cproRestServer.labels`         | The labels that need to be added to the gateway | `{}`
`istio.gateways.cproRestServer.annotations`         | The annotations that need to be added to the gateway | `{}`
`istio.gateways.cproRestServer.ingressPodSelector`         | Istio ingress gateway selector | `{istio: ingressgateway}`
`istio.gateways.cproRestServer.port`         | The port for the Gateway to connect to | `443`
`istio.gateways.cproRestServer.protocol`         | The protocol for the Gateway will use | `HTTPS`
`istio.gateways.cproRestServer.host`         | the host used to access the management GUI from istio ingress gateway. If empty default will be * | `[]`
`istio.gateways.cproRestServer.tls.redirect`         | Whether the request to be redirected from HTTP to HTTPS | `true`
`istio.gateways.cproRestServer.tls.mode`         | mode could be SIMPLE, MUTUAL, PASSTHROUGH, ISTIO_MUTUAL | `SIMPLE`
`istio.gateways.cproRestServer.tls.credentialName`         | Secret name for Istio Ingress | `"am-gateway"`
`istio.gateways.cproRestServer.tls.custom`         | Custom TLS configurations that needs to be added to the gateway | `{}`

## customResourceNames Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`customResourceNames.resourceNameLimit` | custom name limit for pod and container name | `63`
`customResourceNames.alertManagerPod.alertManagerContainer` | custom name for alertmanager container | `""`
`customResourceNames.alertManagerPod.configMapReloadContainer` | custom name for alertmanager configmap reload container | `""`
`customResourceNames.alertManagerPod.cproUtil` | custom name for alertmanager cpro Util container | `""`
`customResourceNames.restServerPod.restServerContainer` | custom name for restserver container | `""`
`customResourceNames.restServerPod.configMapReloadContainer` | custom name for restserver configreload container | `""`
`customResourceNames.restServerHelmTestPod.name` | custom name for restserver helm test pod | `""`
`customResourceNames.restServerHelmTestPod.testContainer` | custom name for restserver helm test container | `""`
`customResourceNames.toolsPod.initContainer` | custom name for restserver init container | `""`
`customResourceNames.serverPod.inCntInitConfigFile` | custom name for prometheus init-config-file-container | `""`
`customResourceNames.serverPod.configMapReloadContainer` | custom name for prometheus configreload container | `""`
`customResourceNames.serverPod.serverContainer` | custom name for prometheus container | `""`
`customResourceNames.serverPod.monitoringContainer` | custom name for prometheus monitoring container | `""`
`customResourceNames.serverPod.cproUtil` | custom name for prometheus cpro Util container | `""`
`customResourceNames.serverPod.cburaSidecarContainer` | custom name for prometheus cburs-sidecar container. it's name should end with cbura-sidecar | `""`
`customResourceNames.pushGatewayPod.pushGatewayContainer` | custom name for pushgateway container | `""`
`customResourceNames.kubeStateMetricsPod.kubeStateMetricsContainer` | custom name for kubeStateMetricsPod container | `""`
`customResourceNames.hooks.preDeleteJobName` | custom name for preDeleteJob  | `""`
`customResourceNames.hooks.preDeleteContainer` | custom name for preDeleteContainer  | `""`
`customResourceNames.hooks.postDeleteJobName` | custom name for postDeleteJob  | `""`
`customResourceNames.hooks.postDeleteContainer` | custom name for postDeleteContainer  | `""`
`customResourceNames.webhook4fluentd.webhookContainer` | custom name for webhook4fluentdContainer  | `""`
`customResourceNames.nodeExporter.nodeExporterContainer` | custom name for nodeExporterContainer | `""`
`customResourceNames.migrate.preUpgradePodName` | custom name for preUpgradePod | `""`
`customResourceNames.migrate.preUpgradeContainer` | custom name for preUpgradeContainer | `""`
`customResourceNames.migrate.postUpgradePodName` | custom name for postUpgradePod | `""`
`customResourceNames.migrate.postUpgradeContainer` | custom name for postUpgradeContainer | `""`
`customResourceNames.serverHelmTestPod.name` | custom name for server HelmTestPod  | `""`
`customResourceNames.serverHelmTestPod.testContainer` | custom name for server  testContainer | `""` |
`customResourceNames.postRestore.postRestoreJobName` | custom name for BrHook post restore Job | `""`
`customResourceNames.postRestore.postRestoreContainerName` | custom name for BrHook post restore container | `""` |
`customResourceNames.preBackup.preBackupJobName` | custom name for BrHook prebackup Job | `""`
`customResourceNames.preBackup.preBackupContainerName` | custom name for BrHook prebackup container | `""` |
`includeWorkloadInIstioMesh`              | This configuration allows the user to create the Headless SVC and normal SVC for the REGISTRYONLY environment in istio for making the cpro scrape the metrics  | `false` |

## Istio Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`istio.version`            | Version of istio available in the cluster | `1.11`
`istio.enabled`            | Istio feature is enabled or not | `false`
`istio.sidecar.healthCheckPort`            | Istio sidecar (Envoy) healthcheck port. If it is not set, then the default value is 15021, and 15020 for Istio versions prior to 1.6. | `15021` for istio version 1.6 and above. `15020` for istio version less than 1.6
`istio.sidecar.stopPort`            | Istio sidecar (Envoy) admin port on which `quitquitquit` endpoint can be used to stop sidecar container. | `15000`
`istio.mtls.enabled`       | Istio Mutual TLS is enabled or not. These will be taken into account based on istio.enabled | `true`
`istio.cni.enabled`        | CNI is enabled or not | `true`
`istio.permissive`         | Should allow mutual TLS as well as clear text for your deployment true or false | `true`
`istio.createDrForClient`  | This optional flag should only be used when application was installed in istio-injection=enabled namespace, but was configured with istio.enabled=false, thus istio sidecar could not be injected into this application. Client then would need destinationRule for accessing this application True or False | `true`
`istio.sharedHttpGateway.namespace`         | The namespace in which the sharedHttpGateway is created | `istio-system`
`istio.sharedHttpGateway.name`         | The name of the sharedHttpGateway | `single-gateway-in-istio-system`
Refer section [Prometheus Server Istio Gateway Configuration](#prometheus-server-istio-gateway-configuration)
Refer section [AlertManager Istio Gateway Configuration](#alertmanager-istio-gateway-configuration)
Refer section [PushGateway Istio Gateway Configuration](#pushgateway-istio-gateway-configuration)
Refer section [RestServer Istio Gateway Configuration](#restserver-istio-gateway-configuration)

## Ingress TLS
If your cluster allows automatic creation/retrieval of TLS certificates (e.g. [kube-lego](https://github.com/jetstack/kube-lego)), please refer to the documentation for that mechanism.

To manually configure TLS, first create/retrieve a key & certificate pair for the address(es) you wish to protect. Then create a TLS secret in the namespace:

## Ephemeral volumes
Disabling of persistentVolumeClaim could not happen in production environment, therefore it should not be converted into Ephemeral volumes.
ZombieExporter is in the process of deprication, user can enable console level loging.

```console
kubectl create secret tls prometheus-server-tls --cert=path/to/tls.cert --key=path/to/tls.key
```

Include the secret's name, along with the desired hostnames, in the alertmanager/server Ingress TLS section of your custom `values.yaml` file:

```yaml
server:
  ## The URL prefix at which the container can be accessed.
  ## (Optional)
  ## prefixURL: "prometheus"
  prefixURL: ""

  ingress:
    ## If true, Prometheus server Ingress will be created
    ##
    enabled: true
        ## All possible allowed values for pathType is Prefix,ImplementationSpecific, Exact
    pathType: "Prefix"
    ## Prometheus server Ingress hostnames with optional path (when using common hostname and different path for each component ingresses.)
    ## Must be provided if Ingress is enabled
    ## If prefixURL is set ,the same needs appended to the hostname
    hosts:
      - prometheus.domain.com/<prefixURL>


    ## Prometheus server Ingress TLS configuration
    ## Secrets must be manually created in the namespace
    ##
    tls:
      - secretName: prometheus-server-tls
        hosts:
          - prometheus.domain.com
```
## NetworkPolicy

Enabling Network Policy for Prometheus will secure connections to Alert Manager
and Kube State Metrics by only accepting connections from Prometheus Server.
All inbound connections to Prometheus Server are still allowed.

To enable network policy for Prometheus, install a networking plugin that
implements the Kubernetes NetworkPolicy spec, and set `networkPolicy.enabled` to true.

If NetworkPolicy is enabled for Prometheus' scrape targets, you may also need
to manually create a networkpolicy which allows it.


## Helm upgrade consideration as per HBP 3.0.0

nameoverride, fullnameoverride , prefix and suffix cannot be changed during upgradation.

The following fields (related to labels/annotations) were identified as immutable:
spec.selector.matchLabels in the StatefulSets
spec.volumeClaimTemplates[].metadata.labels in the StatefulSets
spec.volumeClaimTemplates[].metadata.annotations in the StatefulSets

The following fields (related to labels/annotations) were identified as a safe to change:
metadata.labels
metadata.annotations
spec.template.metadata.labels
spec.template.metadata.annotations


## CPU limits configuration as per HBP 3.4.0 [HBP_Kubernetes_Pod_res_3] & 3.6.0 [HBP_Kubernetes_Pod_res_5]

|         **buildin values.yaml**              |        **parameters provided by user**       | **templated manifests**             |
---------------------------------------------- | -------------------------------------------- | ----------------------------------- |
|...resources.limits.cpu|enableDefaultCpuLimits|...resources.limits.cpu|enableDefaultCpuLimits| pod spec ...resources.limits.cpu    |
| -------------------------------------------- | -------------------------------------------- | ----------------------------------- |
| <no value>            |  false               |      <no value>       |     <no value>       |       <no value>                    |
| <no value>            |  false               |       1               |     <no value>       |          1                          |
| <no value>            |  <no value>          |      <no value>       |        true          |500m(assuming that 500m is a default)|
| <no value>            |  <no value>          |       1               |        true          |          1                          |


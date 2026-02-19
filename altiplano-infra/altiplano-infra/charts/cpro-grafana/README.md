
# Grafana Helm Chart

* Installs the web dashboarding system [Grafana](http://grafana.org/)

```console
$ helm install stable/grafana
```

## Configuration for openshift
```console
WARNING! Usage of auto for runAsUser and fsGroup is deprecated. These are to be configured as below.
Do not configure runAsUser and fsGroup inside the securityContext. In the key-value pair, key should be present and value of it should be empty.

Current Configuration =>
securityContext:
   runAsUser: 65534
   fsGroup: 65534

Recommended Configuration =>
securityContext:
   runAsUser:
   fsGroup:

Configure restrictedToNamespace as true
restrictedToNamespace: true
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


## Installing the Chart

Following parameters needs to be configured before grafana is installed:
* Server certificate for grafana - through any of the below methods:
  * Enable certManager
  * Create secrets manually and place in extraSecretMount
  * Create the certificates manually and place appropriately.
* Similarly, If tls for CMDB  or keycloak is enabled, certificates needs to be placed through above methods.

To install the chart with the release name `my-release`:
```console
$ helm install --name my-release stable/cpro-grafana
```
## Uninstalling the Chart

To uninstall/delete the my-release deployment:

```console
$ helm delete my-release
```
The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

## General Configuration

| **Helm Parameter**                       | **Description** | **Default** |
|------------------------------------------| ------- | ------- |
| `name`                                   | Grafana Container name | `grafana`
| `appTitle`                               | Title to be used for Grafana Application | `"Performance Monitoring"`
| `replicas`                               | This is to be used when HA is enabled. Defines number of replicas in HA | `2`
| `updateStrategy.type`                    | This is used to configure Update Strategy | `RollingUpdate`
| `updateStrategy.rollingUpdate.partition` | This is used to configure rolling Updates | ``
| `dnsPolicy`                              | Type of the DNS Policy used | ` `
| `dnsConfig.nameservers`                  | A list of DNS name server IP addresses | ` `
| `dnsConfig.options`                      | A list of DNS resolver options. This will be merged with the base options generated from DNSPolicy | ` `
| `dnsConfig.searches`                     | A list of DNS search domains for host-name lookup | ` `
| `HA.enabled`                             | Enable this flag to enable HA for Grafana pods | `false`
| `deployOnCompass`                        | Set to true when need to deploy on ComPaaS, false when deploy on BCMT(or other K8S) | `false`
| `deploymentStrategy`                     | Strategy to create the pods by terminating old version and releasing new one | `Recreate`
| `usePodNamePrefixAlways`                 | Use podNamePrefix even in case of nameOverride or fullnameOverride. This parameter should not be changed during upgrade | `false`
| `disablePodNamePrefixRestrictions` | If disablePodNamePrefixRestrictions is true then there is no restriction limit for podnameprefix.(root level have more precedence than global level) | `""` 
| `timezone.useHostPath`                   | Whether time zone is taken from the host machine | `false`
| `timezone.hostPath`                      | hostPath for timezone information. PSP should be configured with this hostpath | `/etc/localtime`
| `timeZoneName`                           | set up timezone env into your pod. timeZoneName priority order is 1) timeZoneName 2) global.timeZoneName | ``
| `timeZone.timeZoneEnv`                   | set up timezone env into your pod with timeZoneEnv. timeZoneEnv priority order is 1) timeZone.timeZoneEnv 2) global.timeZoneEnv | ``
| `grafana.name`                           | grafana workload name | `grafana`
| `grafana.imagePullSecrets`               | Optionally specify an array of imagePullSecrets in workload level. The imagePullSecrets in workload level is given precedence compared to global level when configured | ``
| `partOf`                                 | name of a higher level application this one is part of | `""`
| `managedBy`                              | This should be the tool name being used to manage the operation of an application | `""`
| `nameOverride`                           | This should be the override name of an application (it should not be changed during upgrade) | `""`
| `clusterDomain`                          | name of local domain set in cluster | `cluster.local`
| `readOnlyRootFilesystem`                 | readOnlyRootFilesystem when set to true will make all the containers root file system read only | `true`
| `allowPrivilegeEscalation`               | allowPrivilegeEscalation when set to false will make sure sub-process created by container will get more privilege than parent process  | `false`
| `resources.limits.memory`                | Memory Resource limit for Grafana Pod | `1Gi`
| `resources.limits.ephemeral-storage`     | ephemeral-storage Resource limit for Grafana Pod | `1Gi`
| `resources.requests.cpu`                 | CPU Resource Requests for Grafana Pod | `100m`
| `resources.requests.memory`              | Memory Resource Requests for Grafana Pod | `128Mi`
| `resources.requests.ephemeral-storage`   | ephemeral-storage Resource requests for Grafana Pod | `250MMi`
| `nodeSelector`                           | Node labels for pod assignment. ref: https://kubernetes.io/docs/user-guide/node-selection/ | `{}`
| `tolerations`                            | Toleration labels for pod assignment. ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ | `[]`
| `affinity`                               | Affinity settings for pod assignment. ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity | `{}`
| `nodeAntiAffinity`                       | Antiaffinity for Pod Assignments | `hard`
| `persistence.enabled`                    | Use persistent volume to store data. ref: http://kubernetes.io/docs/user-guide/persistent-volumes/ | `false`
| `persistence.size`                       | Size of persistent volume claim | `10Gi`
| `persistence.existingClaim`              | Use an existing PVC to persist data | `nil`
| `persistence.storageClassName`           | Type of persistent volume claim | `nil`
| `persistence.accessModes`                | Persistence access modes | `[]`
| `persistence.subPath`                    | Mount a sub directory of the persistent volume if set | `""`
| `persistence.annotations`                | Persistence Annotations | `{}`
| `adminUser`                              | Admin User name of Grafana UI | `admin`
| `schedulerName`                          | Alternate scheduler name | `nil`
| `env`                                    | Extra environment variables passed to pods | `{}`
| `envFromSecret`                          | The name of a Kubenretes secret (must be manually created in the same namespace) containing values to be added to the environment | `""`
| `extraSecretMounts`                      | Additional grafana server secret mounts | `[]`
| `extraArgs`                              | Additional grafana container arguments | `{}`
| `terminationMessagePath`                 | terminationMessagePath used in container. Default value will be /dev/termination-log | `"/dev/termination-log"`
| `terminationMessagePolicy`               | terminationMessagePolicy used in container. Default value will be "File" and also user can opt for other option "FallbackToLogsOnError | `""`
| `priorityClassName`                      | Priority ClassName can be set Priority indicates the importance of a Pod relative to other Pods |
| `ipFamilyPolicy`                         | ipFamilyPolicy indicates the settings for dual stack configurations possible values include: SingleStack  PreferDualStack  RequireDualStack |
| `ipFamilies`                             | ipFamilyPolicy indicates the settings for dual stack configurations possible values include:["IPv4"] ["IPv6"] ["IPv4","IPv6"] ["IPv6","IPv4"] |
| `hostAliases`                            | hostAliases Specifies the IP address, DNS host name with domain name suffix, or just the DNS host name | `[]`
| `imageFlavor`                            | imageFlavor that needs to used by the all the workloads present in the chart. supported imageFlavor to be configured are rocky8-python3.8, rocky8, rocky8-jre17. Worload level configured imageFlavor will take precedence than root level imageFlavor | `` |
|`.imageFlavorPolicy`      | imageFlavorPolicy can either take Best Match or Strict case | `` |
## Global Configuration
| `enableDefaultCpuLimits` | If enableDefaultCpuLimits set to true user can configure their own cpu limts | `false` |
Global level annotations and labels are applicable to all resources.

| **Helm Parameter**                                          | **Description** | **Default**
-------------------------------------------------------------| ----------- | -------
| `global.registry`                                           | If global.registry is provided then all container images need use this registry. It also supports <registry>/<repository path>| ``
| `global.flatregistry`                                       | If global.flatRegistry is set to true, then <repository path> in all container images will be skipped  | `false`
| `global.annotations`                                        | Annotations to be added for Grafana resources | `{}`
| `global.timeZoneName`                                       | set up timezone env into your pod with timeZoneName. timeZoneName priority order is 1) timeZoneName 2) global.timeZoneName | `UTC`
| `global.timeZoneEnv`                                        | set up timezone env into your pod with timeZoneEnv. timeZoneEnv priority order is 1) timeZone.timeZoneEnv 2) global.timeZoneEnv | ``
| `global.hpa.enabled`                                        | Enable/Disable HPA. <workload name>.hpa.enabled has precedence before global.hpa.enabled | `null(false)` |
| `global.labels`                                             | Labels to be added for Grafana resources | `{}`
| `global.serviceAccountName`                                 | Service Account to be used in Grafana components |
| `global.istioVersion`                                       | Istio version of the cluster. Supported versions are 1.4/1.5/1.6/1.7 | `1.11`
|`global.imageFlavor`      | imageFlavor that needs to used by the workload. supported imageFlavor to be configured are rocky8-python3.8, rocky8. rocky8-jre17 . Worload level configured imageFlavor will take precedence than root level imageFlavor | `` |
|`global.imageFlavorPolicy`      | imageFlavorPolicy can either take Best Match or Strict case. Default case is Best Match | `` |
| `includeWorkloadInIstioMesh`                                | This configuration allows the user to create the Headless SVC and normal SVC for the REGISTRYONLY environment in istio for making the cpro scrape the metrics  | `false`
| `includeWorkloadInIstioMesh`                                | This configuration allows the user to create the Headless SVC and normal SVC for the REGISTRYONLY environment in istio for making the cpro scrape the metrics  | `false`
| `includeWorkloadInIstioMesh`                                | This configuration allows the user to create the Headless SVC and normal SVC for the REGISTRYONLY environment in istio for making the cpro scrape the metrics  | `false`
| `global.podNamePrefix`                                      | Custom prefix for pod Name  | `""`
 `includeWorkloadInIstioMesh`                                | This configuration allows the user to create the Headless SVC and normal SVC for the REGISTRYONLY environment in istio for making the cpro scrape the metrics  | `false`
| `global.containerNamePrefix`                                | Custom prefix for container Name and it's maximum length is 34 characters | `""`
| `global.priorityClassName`                                  | Priority ClassName can be set Priority indicates the importance of a Pod relative to other Pods |
| `global.certManager.enabled`                                | Generate certificates to scrape metrics from etcd in BCMT. Worload level configured certificate will take precedence than root level and then followed by global level | "true"
|`global.certManager.issuerRef.name`                          | Issuer Name. Self-signed issuer will be created if issuerRef name is empty at grafana.certificate.issuerRef.name, certManager.issuerRef.name and global.certManager.issuerRef.name| |
|`global.certManager.issuerRef.kind`                          | CRD Name | `Issuer` |
|`global.certManager.issuerRef.group`                         | Api group Name |`cert-manager.io` |
| `global.ipFamilyPolicy`                                     | ipFamilyPolicy indicates the settings for dual stack configurations possible values include: SingleStack  PreferDualStack  RequireDualStack |
| `global.ipFamilies`                                         | ipFamilyPolicy indicates the settings for dual stack configurations possible values include:["IPv4"] ["IPv6"] ["IPv4","IPv6"] ["IPv6","IPv4"] |
| `global.ephemeralVolume.enabled`                            | Ephemeral Volumes shall be used if enabled | `""`
| `global.unifiedLogging.syslog.enabled`                      | set to true when horminized logging is needed | `False`
| `global.unifiedLogging.syslog.facility`                     | Syslog facility. grafana.unifiedLogging.syslog.facility has more priority than global.unifiedLogging.syslog.facility   | `null` |
| `global.unifiedLogging.syslog.host`                         | Syslog server host name to connect to. grafana.unifiedLogging.syslog.host has more priority than global.unifiedLogging.syslog.host  | `null` |
| `global.unifiedLogging.syslog.port`                         | Syslog server port to connect to. grafana.unifiedLogging.syslog.port has more priority than global.unifiedLogging.syslog.port  | `null` |
| `global.unifiedLogging.syslog.protocol`                     | Protocol to connect to syslog server. Ex. TCP. grafana.unifiedLogging.syslog.protocol has more priority than global.unifiedLogging.syslog.protocol. ssl,tcp and udp are the supprted in protocol field. if protocol is ssl then please configure the secret and provide secret name under tls section| `null` |
| `global.unifiedLogging.syslog.tls.secretRef.name`           | Name of secret containing syslog CA certificate. workload level will have priority than global level | `null` |
| `global.unifiedLogging.syslog.tls.secretRef.keyNames.caCrt` | Name of secret containing  CA certificate. workload level will have priority than global level | `ca.crt` |
| `global.unifiedLogging.extension`                           | extension for the release or workload | `{}` |
| `global.imagePullSecrets`                                   | Optionally specify an array of imagePullSecrets in global level . The imagePullSecrets in workload level is given precedence compared to global level when configured | ``
| `global.enableDefaultCpuLimits` | If enableDefaultCpulimits set to true, it should consider default container cpu limits value | `false` |
| `global.disablePodNamePrefixRestrictions` | If disablePodNamePrefixRestrictions is true then there is no restriction limit for podnameprefix.(root level have more precedence than global level) | `""` |


## Custom Configuration

Custom level annotations and labels are available for psp and pod resources.
Add customized labels to some specific resources for Istio or other usages.

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
| `custom.pod.annotations`   | Pod Annotations to be added | `seccomp.security.alpha.kubernetes.io/allowedProfileNames: runtime/default,seccomp.security.alpha.kubernetes.io/defaultProfileName: runtime/default`
| `custom.pod.apparmorAnnotations` | Apparmor annotations that need to be added to PSP | `apparmor.security.beta.kubernetes.io/allowedProfileNames: runtime/default, apparmor.security.beta.kubernetes.io/defaultProfileName: runtime/default`
| `custom.pod.labels`        | Custom labels that need to be added to Pod |
| `custom.grafanaSts.labels`        | Custom labels that need to be added to statefulset |
| `custom.grafanaSts.annotations`   | Custom annotations that need to be added to statefulset |

## Grafana Workload Labels & Annotations Configuration
| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
| `grafana.labels`        | Labels that need to be added to Grafana Workload | `{}`
| `grafana.replicasManagedByHpa`| When replicasManagedByHpa set to True then spec.replicas field will be ignored in Deployment/StatefulSet objects. spec.replicas in Deployment/StatefulSet and spec.minReplicas in the HorizontalPodAutoscaler can interfere during the upgrade. During the upgrade of helm release which has no HPA, spec.replicas in Deployment/StatefulSet needs equal spec.minReplicas in HPA  | `false`
| `grafana.hpa.enabled` | Enable/Disable HorizonatlPodAutpscaler for vminsert | `null(false)` |
| `grafana.hpa.minReplicas` | Minimum replica count to which HPA can scale down | `1` |
| `grafana.hpa.maxReplicas` | Maximum replica count to which HPA can scale up | `10` |
| `grafana.hpa.predefinedMetrics.enabled` | Enable/Disable default memory/cpu metrics monitoring on HPA | `true`
| `grafana.hpa.averageCPUThreshold` | HPA keeps the average cpu utilization of all the pods below the value set | `80` |
| `grafana.hpa.averageMemoryThreshold` |  HPA keeps the average memory utilization of all the pods below the value set | `80` |
| `grafana.hpa.behavior` | Additional behavior to be set here | `` |
| `grafana.hpa.metrics` | Additional metrics to monitor can be set here | `` |
| `grafana.annotations`   | Annotations that need to be added to Grafana Workload | `{}`
| `grafana.unifiedLogging.syslog.enabled`            | set to true when horminized logging is needed. grafana.unifiedLogging.syslog.enabled has more priority than global.unifiedLogging.syslog.enabled | ``
|`grafana.unifiedLogging.syslog.facility`      | Syslog facility. grafana.unifiedLogging.syslog.facility has more priority than global.unifiedLogging.syslog.facility   | `null` |
|`grafana.unifiedLogging.syslog.host`      | Syslog server host name to connect to. grafana.unifiedLogging.syslog.facility has more priority than global.unifiedLogging.syslog.facility  | `null` |
|`grafana.unifiedLogging.syslog.port`      | Syslog server port to connect to. grafana.unifiedLogging.syslog.port has more priority than global.unifiedLogging.syslog.port  | `null` |
|`grafana.unifiedLogging.syslog.protocol`      | Protocol to connect to syslog server. Ex. TCP. grafana.unifiedLogging.syslog.protocol has more priority than global.unifiedLogging.syslog.protocol. ssl,tcp and udp are the supprted in protocol field. if protocol is ssl then please configure the secret and provide secret name under tls section | `null` |
|`grafana.unifiedLogging.syslog.tls.secretRef.name`      | Name of secret containing syslog CA certificate. workload level will have priority than global level | `null` |
|`grafana.unifiedLogging.syslog.tls.secretRef.keyNames.caCrt`      | Name of secret containing  CA certificate. workload level will have priority than global level | `ca.crt` |
|`grafana.imageFlavor`      | imageFlavor that needs to used by the workload. supported imageFlavor to be configured are rocky8-python3.8, rocky8 . Worload level configured imageFlavor will take precedence than root level imageFlavor | `` |
|`grafana.imageFlavorPolicy`      | imageFlavorPolicy can either take Best Match or Strict case | `` |

## Security configurations

| `grafana.tls.enabled`     |Enable TLS for grafana. Precedence  grafana.tls.enabled -> tls.enabled -> global.tls.enabled | ``
| `tls.enabled`                            |Enable TLS for grafana. Precedence  grafana.tls.enabled -> tls.enabled -> global.tls.enabled | ``
| `global.tls.enabled`                   |Enable TLS for grafana. Precedence  grafana.tls.enabled -> tls.enabled -> global.tls.enabled | `true`
| `grafana.tls..secretRef.name`   | Secret name, pointing to a Secret object. If empty then automatically generated secret with certificate will be used | `""`
| `grafana.tls.secretRef.mountPath`  | Secret mount path | `/etc/grafana/ssl/`
| `grafana.tls.secretRef.keyNames.caCrt`  |  Name of Secret key, which contains CA certificate | `"ca.crt"`
| `grafana.tls.secretRef.keyNames.tlsKey`  | Name of Secret key, which contains TLS key | `"tls.key"`
| `grafana.tls.secretRef.keyNames.tlsCrt`  | Name of Secret key, which contains TLS certificate | `"tls.crt"`
| `grafana.certificate.enabled` | Certificate object is created based on this parameter  | `true` |
| `grafana.certificate.issuerRef.name` | Issuer Name. Self-signed issuer will be created if issuerRef name is empty at grafana.certificate.issuerRef.name, certManager.issuerRef.name and global.certManager.issuerRef.name| |
| `grafana.certificate.issuerRef.kind` | CRD Name | |
| `grafana.certificate.issuerRef.group` | Api group Name | |
| `grafana.certificate.duration` | How long certificate will be valid | `8760h` |
| `grafana.certificate.renewBefore` | When to renew the certificate before it gets expired | `360h` |
| `grafana.certificate.subject` | Not needed in internal communication | |
| `grafana.certificate.commonName` | It has been deprecated since 2000 and is discouraged from being used for a server side certificates | |
| `grafana.certificate.usages` |Usages is the set of x509 usages that are requested for the certificate | |
| `grafana.certificate.dnsNames` | DNSNames is a list of DNS subjectAltNames to be set on the Certificate. |  |
| `grafana.certificate.uris` | URIs is a list of URI subjectAltNames to be set on the Certificate. | |
| `grafana.certificate.ipAddresses` | IPAddresses is a list of IP address subjectAltNames to be set on the Certificate. | |
| `grafana.certificate.privateKey.algorithm` | Algorithm used to encode key value pair | |
| `grafana.certificate.privateKey.encoding` | Encode the key pair value | |
| `grafana.certificate.privateKey.size` | size of the key pair  |
| `grafana.certificate.privateKey.rotationPolicy` | Rotation of a key pair, when certificate is refreshed is recommended from a security point of view | `Always` |


## RBAC Configuration

Roles and RoleBindings resources will be created automatically for `grafana` service.

To manually setup RBAC you need to set the parameter `rbac.enabled=false` and specify the service account to be used for each service by setting the parameters: `global.serviceAccountName`and `serviceAccountName` to the name of a pre-existing service account

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
| `rbac.enabled`             | If true, create and use RBAC resources | `true` |
| `rbac.pspUseAppArmor`      | If true, enable apparmor annotations on PSPS and pods | `false`
| `rbac.psp.create`          | If set to true and rbac is enabled the required PSPS will be created | `false` |
| `rbac.psp.annotations`   | PSP annotations that need to be added | `seccomp.security.alpha.kubernetes.io/allowedProfileNames: *,seccomp.security.alpha.kubernetes.io/defaultProfileName: runtime/default`
| `serviceAccountName`       | ServiceAccount to be used for Grafana component |
| `restrictedToNamespace`     | Grafana to import dashboards from a single namespace. Through sidecar, if set to false clusterrole and clusterrolebinding will be created | `true`

## Pod Disruption Budget

Used to ensure that always have a certain number of pods available.Kubernetes provides this feature for users to runs  highly available application. Reference: https://kubernetes.io/docs/tasks/run-application/configure-pdb/
Specify only one of maxUnavailable and minAvailable in a single PodDisruptionBudget.
As per Helm Best Practices,if replica count is 1, pdb will be disabled by default. It can be enabled when required.

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
| `pdb.enabled`              | Enable this flag to enable PodDistuptionBudget for Grafana. | `false`
| `pdb.maxUnavailable`              | Specify the number of pods that can be unavailable after the eviction. It can be either an absolute number or a percentage. | `0`
| `pdb.minAvailable` | minimum number of pods from the set that must still be available after the eviction, even in the absence of the evicted pod. It can be either an absolute number or a percentage. | ``

## Legacy Sensitive Data Configuration

Grafana will be accepting all the sensitive information in the form of secrets.
End user has to create secret/s with all required information before deploy/upgrade
End user is responsible of having proper secret content before/after LCM event.
Every helm install/upgrade from now onwards needs secret/s. Without secret/s having proper information, installation/upgrade will fail.
Mounting extra secret, configmap, hostpath support is present in certain charts. End user is responsible for handling sensitive data in that.

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
| `sensitiveDataSecretName` | Name of secret with sensitive data | `""`
## New Sensitivedata Configuration

The new way of configurating the sensitive data in grafana enables the user to specify the secret and name of the keys used in when creating the secret.
The End user has to create the secret with the required information before deploy/upgrade and is responsible for having proper secret content before/after LCM event.

Following are the fields related to new ways of configuring the sensitive data secret.
| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
`secretPathPrefix` | prefix to be used when mounting the grafana.externalCredentials or cmdb.auth.credentialName or keycloak.auth.credentialName or grafana.security.credentialName | `"/secrets"`
`grafana.security.credentialName` | Name of the credential secret which has grafana's admin user and admin password credentials | `""`
`grafana.security.keyNames.username` | Name of the key used for admin user when creating the secret | `"username"`
`grafana.security.keyNames.password` | Name of the key used for admin password when creating the secret | `"password"`
`grafana.externalCredentials` | Map containing the details related to credential and keys that contain the sensitivedata to be consumed by grafana container | `{}`
`cmdb.auth.credentialName` | Name of the credential secret which has cmdb's credentials like user,name and password | `""`
`cmdb.auth.keyNames.username` | Name of the key used for cmdb user when creating the secret | `"username"`
`cmdb.auth.keyNames.password` | Name of the key used for cmdb password when creating the secret | `"password"`
`keycloak.auth.credentialName` | Name of the credential secret which has keycloak's credentials like clientId and clientSecret | `""`
`keycloak.auth.keyNames.clientId` | Name of the key used for clientId when creating the secret | `"clientId"`
`keycloak.auth.keyNames.clientSecret` | Name of the key used for clientSecret when creating the secret | `"clientSecret"`


#### Example usage of new way of configuring sensitive data:

Suppose the cmdb is enabled and grafana is to be configured with cmdb database. In this case a user can provide the sensitive data related to cmdb like `user`, `password` and `name` using the new sensitive data described as below.

Firstly, the user needs to create a secret containing the sensitive data. Below is a example on how the user can create the secret.
`kubectl create secret generic cmdbsecret  --from-literal=cmdbusername=myadmin --from-literal=cmdbpassword=mypassword --from-literal=cmddbname=mydb`

Once the secret is created, the user needs to fill in the `cmdb.auth` section in the Values.yaml with the details as below example

``` yaml
cmdb:
  auth:
    # give the name of the secrete created containing the sensitive data
    credentialName: "cmdbsecret"
	# provide the name of the keys used when creating the secret which map to username and password. 
	# Note: if the user created the secret with the keys as "username" and "password", then the user need not  configure the below section. One can leave it empty "".
    keyNames:
      username: "cmdbusername"
      password: "cmdbpassword"


```

Once the above section is filled in, the chart will take care to update the grafana_ini's Database section with user,password and name in Grafana's fileProvider format. (Example `user = $__file{/secrets/cmdb-auth/cmdbusername}`)

Similarly, the user can update the `keycloak.auth` and `grafana.security` sections as per the above explaination and the chart will update the grafana_ini's `auth.generic_oauth` and `security` sections with Grafana's FileProvider pattern accordingly.

Note: If `grafana.security.credentialName` is set, then the user need to uncomment the `grafana_ini.security.admin_user` and `grafana_ini.security.admin_password` fields.

Furthermore, if the user needs to treat any other fields under grafana_ini as sensitive data, the user can configure the `grafana.externalCredentials` section as explained below.

Suppose the user needs to treat database host as sensitive data, then firstly a secret has to be created containing the credential.
(Example : `kubectl create secret generic dbhostcred  --from-literal=dbhost=mysqlserver.example.com:3306`)

Next, configure the `grafana.externalCredentials` as below
``` yaml

grafana:
  externalCredentials:
    db:
      credentialName: "dbhostcred"
      keyNames:
        key: "dbhost"

```

Next, the user needs to update the `grafana_ini.database.host` section with the Grafana's file provider patterns as below
``` yaml

grafana_ini:
  database:
    ## Example (host: $__file{<.Values.secretPathPrefix>/<name-of-externalCredentials-section>/<name-of-the-key-used>})
    host: $__file{/secrets/db/dbhost}

```

## SELinux Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
| `seLinuxOptions.enabled`   | Selinux options in PSP and Security context  of POD | `false`
| `seLinuxOptions.level`     | Selinux level in PSP and Security context of POD | `""`
| `seLinuxOptions.role`      | Selinux role in PSP and Security Context of POD | `""`
| `seLinuxOptions.type`      | Selinux type in PSP and Security context of POD | `""`
| `seLinuxOptions.user`      | Selinux user in PSP and Security context of POD | `""`

## Image Repository Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
| `image.distro.imageRepo`          | Image repository of grafana distro | `cpro/grafana-registry1/cpro-grafana`
| `image.distro.imageTag`           | Image tag of grafana distro | `2.0.4-10.2.1-163`
| `image.distro.imagePullPolicy`    | Image pull policy | `IfNotPresent`
| `image.utility.imageRepo`          | Image repository of grafana utility | `cpro/grafana-registry1/cpro-grafana-util`
| `image.utility.imageTag`           | Image tag of grafana utility | `3.0.4-163`
| `image.utility.imagePullPolicy`    | Image pull policy | `IfNotPresent`
| `image.python.imageRepo`          | Image repository of grafana python | `cpro/grafana-registry1/cpro-grafana-kiwigrid`
| `image.python.imageTag`           | Image tag of grafana python | `3.0.4-1.25.2-163`
| `image.python.imagePullPolicy`    | Image pull policy | `IfNotPresent`
| `image.utilityRocky.imageRepo`          | Image repository of grafana utility rocky image | `cpro/grafana-registry1/grafana-utility-rocky`
| `image.utilityRocky.imageTag`           | Image tag of grafana utility rocky | `"{{ .Values.image.utility.imageTag }}"`
| `image.utilityRocky.imagePullPolicy`    | Image pull policy | `IfNotPresent`
| `image.pythonRocky.imageRepo`          | Image repository of grafana python rocky | `cpro/grafana-registry1/csf-grafana-kiwigrid-rocky`
| `image.pythonRocky.imageTag`           | Image tag of grafana python rocky | `"{{ .Values.image.python.imageTag }}"`
| `image.pythonRocky.imagePullPolicy`    | Image pull policy | `IfNotPresent`

## Kubectl Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
| `helmDeleteImage.imagerocky.imageRepo` | Image repo of kubectl | `tools/kubectl`
| `helmDeleteImage.imagerocky.imageTag` | Image tag of kubectl | `1.28.7-nano-20240301`
| `helmDeleteImage.imagerocky.imagePullPolicy` | Image pull policy | `"{{ .Values.image.utility.imagePullPolicy }}"`
| `helmDeleteImage.activeDeadlineSeconds` | Once a Job reaches activeDeadlineSeconds, all of its running Pods are terminated. Refer https://kubernetes.io/docs/concepts/workloads/controllers/job/#job-termination-and-cleanup for more details | `300`
| `helmDeleteImage.resources.limits.memory` | Kubectl pod resource limits for memory | `100Mi`
| `helmDeleteImage.resources.limits.ephemeral-storage` | Kubectl pod resource limits for ephemeral-storage | `1Gi`
| `helmDeleteImage.resources.requests.cpu` | Kubectl pod resource requests for cpu | `50m`
| `helmDeleteImage.resources.requests.memory` | Kubectl pod resource requests for memory | `32Mi`
| `helmDeleteImage.resources.requests.ephemeral-storage` | Kubectl pod resource requests for ephemeral-storage | `250Mi`
| `helmDeleteImage.hookWeight` | Hooks can be weighted and specify a deletion policy for the resources after they have run | `-9`
| `helmDeleteImage.containerSecurityContext.readOnlyRootFilesystem` | readOnlyRootFilesystem when set to true will make all the containers root file system read only | `true`
| `helmDeleteImage.containerSecurityContext.allowPrivilegeEscalation` | Grafana containers seccompProfile type | `false`
| `helmDeleteImage.containerSecurityContext.capabilities.drop` | allowPrivilegeEscalation when set to false will make sure sub-process created by container will get more privilege than parent process  | `ALL`


## Grafana Helm Test Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
| `helmTest.resources.requests.memory` | Memory resources for helmtest | `64Mi`
| `helmTest.resources.requests.cpu` | cpu resource for helmtest | `50m`
| `helmTest.resources.requests.ephemeral-storage` | cpu resource for helmtest | `250Mi`
| `helmTest.resources.limits.memory` | memory limit for helm test | `128Mi`
| `helmTest.resources.limits.ephemeral-storage` | cpu limit for helm test | `1Gi`
| `helmTest.podAnnotations` | pod annotations for helm test | `{}`
| `helmTest.tolerations` | Toleration labels for pod assignment | `[]`
| `helmTest.nodeSelector` | Node labels for pod assignment | `{}`
| `helmTest.priorityClassName` | Priority ClassName can be set Priority indicates the importance of a Pod relative to other Pods |
| `helmTest.hookWeight` | Hooks can be weighted and specify a test-success policy for the resources after they have run | `1`
| `helmTest.containerSecurityContext.readOnlyRootFilesystem` | readOnlyRootFilesystem when set to true will make all the containers root file system read only | `true`
| `helmTest.containerSecurityContext.allowPrivilegeEscalation` | Grafana containers seccompProfile type | `false`
| `helmTest.containerSecurityContext.capabilities.drop` | allowPrivilegeEscalation when set to false will make sure sub-process created by container will get more privilege than parent process  | `ALL`

## Grafana LCM Hook Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
| `hookImage.resources.limits.memory` | Grafana LCM Hook pod resource limits for memory | `1Gi`
| `hookImage.resources.limits.ephemeral-storage` | Grafana LCM Hook pod resource limits for ephemeral-storage | `1Gi`
| `hookImage.resources.requests.cpu` | Grafana LCM Hook pod resource requests for cpu | `100m`
| `hookImage.resources.requests.memory` | Grafana LCM Hook pod resource requests for memory | `128Mi`
| `hookImage.resources.requests.ephemeral-storage` | Grafana LCM Hook pod resource requests for ephemeral-storage | `250Mi`
| `hookImage.imageFlavor`                            | Supported Image Flavors are rocky8 | `` |
|`hookImage.imageFlavorPolicy`      | imageFlavorPolicy can either take Best Match or Strict case | `` |

## Grafana MDB Tool Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
| `mdbToolImage.activeDeadlineSeconds` | Once a Job reaches activeDeadlineSeconds, all of its running Pods are terminated. Refer https://kubernetes.io/docs/concepts/workloads/controllers/job/#job-termination-and-cleanup for more details | `300`
| `mdbToolImage.resources.limits.memory` | Grafana MDB Tool pod resource limits for memory | `1Gi`
| `mdbToolImage.resources.limits.ephemeral-storage` | Grafana MDB Tool pod resource limits for ephemeral-storage | `1Gi`
| `mdbToolImage.resources.requests.cpu` | Grafana MDB tool pod resource requests for cpu | `100m`
| `mdbToolImage.resources.requests.memory` | Grafana MDB Tool pod resource requests for memory | `128Mi`
| `mdbToolImage.resources.requests.ephemeral-storage` | Grafana MDB Tool pod resource requests for ephemeral-storage | `250Mi`
| `mdbToolImage.containerSecurityContext.readOnlyRootFilesystem` | readOnlyRootFilesystem when set to true will make all the containers root file system read only | `true`
| `mdbToolImage.containerSecurityContext.allowPrivilegeEscalation` | Grafana containers seccompProfile type | `false`
| `mdbToolImage.containerSecurityContext.capabilities.drop` | allowPrivilegeEscalation when set to false will make sure sub-process created by container will get more privilege than parent process  | `ALL`
| `mdbToolImage.imageFlavor`                            | Supported Image Flavors are rocky8 | `` |
|`mdbToolImage.imageFlavorPolicy`      | imageFlavorPolicy can either take Best Match or Strict case | `` |

## Grafana FileMerge Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
| `grafanaFileMerge.name`  | container name of Grafana File Merger. This init container is used to merge sensitive data which is provided in secret with grafana.ini when senstive feature is enabled  | `file-merge`
| `grafanaFileMerge.resources.limits.memory` | Grafana File Merge pod resource limits for memory | `200Mi`
| `grafanaFileMerge.resources.limits.ephemeral-storage` | Grafana File Merge pod resource limits for ephemeral-storage | `1Gi`
| `grafanaFileMerge.resources.requests.cpu` | Grafana File Merge pod resource requests for cpu | `10m`
| `grafanaFileMerge.resources.requests.memory` | Grafana File Merge pod resource requests for memory | `32Mi`
| `grafanaFileMerge.resources.requests.ephemeral-storage` | Grafana File Merge pod resource requests for ephemeral-storage | `250Mi`
| `grafanaFileMerge.containerSecurityContext.readOnlyRootFilesystem` | readOnlyRootFilesystem when set to true will make all the containers root file system read only | `true`
| `grafanaFileMerge.containerSecurityContext.allowPrivilegeEscalation` | Grafana containers seccompProfile type | `false`
| `grafanaFileMerge.containerSecurityContext.capabilities.drop` | allowPrivilegeEscalation when set to false will make sure sub-process created by container will get more privilege than parent process  | `ALL`
| `grafanaFileMerge.imageFlavor`                            | Supported Image Flavors are distroless | `` |
|`grafanaFileMerge.imageFlavorPolicy`      | imageFlavorPolicy can either take Best Match or Strict case | `` |
## Grafana Util (Debug) Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
| `grafanaUtil.name`  | container name of Grafana debug container. This init container is used as debug container as grafana main container is distroless when senstive feature is enabled  | `utils`
| `grafanaUtil.resources.limits.memory` | Grafana util pod resource limits for memory | `200Mi`
| `grafanaUtil.resources.limits.ephemeral-storage` | Grafana util pod resource limits for ephemeral-storage | `1Gi`
| `grafanaUtil.resources.requests.cpu` | Grafana util pod resource requests for cpu | `10m`
| `grafanaUtil.resources.requests.memory` | Grafana util pod resource requests for memory | `32Mi`
| `grafanaUtil.resources.requests.ephemeral-storage` | Grafana util pod resource requests for ephemeral-storage | `250Mi`
| `grafanaUtil.containerSecurityContext.readOnlyRootFilesystem` | readOnlyRootFilesystem when set to true will make all the containers root file system read only | `true`
| `grafanaUtil.containerSecurityContext.allowPrivilegeEscalation` | Grafana containers seccompProfile type | `false`
| `grafanaUtil.containerSecurityContext.capabilities.drop` | allowPrivilegeEscalation when set to false will make sure sub-process created by container will get more privilege than parent process  | `ALL`
| `grafanaUtil.imageFlavor`                            | Supported Image Flavors are rocky8 | `` |
|`grafanaUtil.imageFlavorPolicy`      | imageFlavorPolicy can either take Best Match or Strict case | `` |

## Download Dashboards Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
| `downloadDashboardsImage.enabled` | Image for Downloading dashboards | `false`
| `downloadDashboardsImage.containerSecurityContext.readOnlyRootFilesystem` | readOnlyRootFilesystem when set to true will make all the containers root file system read only | `true`
| `downloadDashboardsImage.containerSecurityContext.allowPrivilegeEscalation` | Grafana containers seccompProfile type | `false`
| `downloadDashboardsImage.containerSecurityContext.capabilities.drop` | allowPrivilegeEscalation when set to false will make sure sub-process created by container will get more privilege than parent process  | `ALL`
| `downloadDashboardsImage.imageFlavor`                            | Supported Image Flavors are rocky8 | `` |
|`downloadDashboardsImage.imageFlavorPolicy`      | imageFlavorPolicy can either take Best Match or Strict case | `` |

## Add Grafana Plugins

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
| `pluginsSideCar.enabled`  | If true, will install Alertmanager datasource plugin | `true`
| `pluginsSideCar.resources.limits.memory` | Grafana plugins pod resource limits for memory | `1Gi`
| `pluginsSideCar.resources.limits.ephemeral-storage` | Grafana plugins pod resource limits for ephemeral-storage | `1Gi`
| `pluginsSideCar.resources.requests.cpu` | Grafana plugins pod resource requests for cpu | `100m`
| `pluginsSideCar.resources.requests.memory` | Grafana plugins pod resource requests for memory | `128Mi`
| `pluginsSideCar.resources.requests.ephemeral-storage` | Grafana plugins pod resource requests for ephemeral-storage | `250Mi`
| `pluginsSideCar.containerSecurityContext.readOnlyRootFilesystem` | readOnlyRootFilesystem when set to true will make all the containers root file system read only | `true`
| `pluginsSideCar.containerSecurityContext.allowPrivilegeEscalation` | Grafana containers seccompProfile type | `false`
| `pluginsSideCar.containerSecurityContext.capabilities.drop` | allowPrivilegeEscalation when set to false will make sure sub-process created by container will get more privilege than parent process  | `ALL`
| `pluginsSideCar.imageFlavor`                            | Supported Image Flavors are rocky8 | `` |
|`pluginsSideCar.imageFlavorPolicy`      | imageFlavorPolicy can either take Best Match or Strict case | `` |
| `pluginsSideCar.curlOptions.connect_timeout | connect timeout limits the time curl will spend trying to connect to the host |  `5`
| `pluginsSideCar.curlOptions.max_time | maximum time, in seconds, that you allow the command line to spend before curl exits with a timeout error |  `30`
| `pluginsSideCar.curlOptions.retry_count |  retry count tell curl to retry certain failed transfers |  `10`

## Extra Grafana Plugins Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
| `plugins`                  | Pass the plugins you want installed as a comma separated list. | `""`
| `pluginUrls`               | Pass the plugin urls as the list.<br/> The file should be downloadble in tar.gz format.<br/> No authentication,proxy or certs are needed to download these | `[]`

## Grafana Datasource Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
| `SetDatasource.enabled`    | If true, an initial Grafana Datasource will be set | `true`
| `SetDatasource.activeDeadlineSeconds` | Once a Job reaches activeDeadlineSeconds, all of its running Pods are terminated. Refer https://kubernetes.io/docs/concepts/workloads/controllers/job/#job-termination-and-cleanup for more details | `300`
| `SetDatasource.resources.requests.cpu` | Resource requests for CPU | `100m`
| `SetDatasource.resources.requests.memory` | Resource requests for memory | `64Mi`
| `SetDatasource.resources.requests.ephemeral-storage` | Resource requests for ephemeral-storage | `250Mi`
| `SetDatasource.resources.limits.memory` |  Resource limits for memory | `128Mi`
| `SetDatasource.resources.limits.memory` |  Resource limits for memory | `1Gi`
| `SetDatasource.datasource.name` | The datasource name. | `prometheus`
| `SetDatasource.datasource.type` | Datasource type | `prometheus`
| `SetDatasource.datasource.url` | The url of the datasource. To set correctly you need to know the right datasource name and its port ahead. Check kubernetes dashboard or describe the service should fulfill the requirements. Synatx like `http://<release name>-<server name>:<port number> | `"http://prometheus-cpro-server"`
| `SetDatasource.datasource.jsonData.timeInterval` | Lowest interval/step value that should be used for this data source | `60s`
| `SetDatasource.datasource.proxy` | Specify if Grafana has to go thru proxy to reach datasource | `proxy`
| `SetDatasource.datasource.isDefault` | Specify should Grafana use this datasource as default | `true`
| `SetDatasource.restartPolicy` | Specify the job restart policy | `OnFailure`
| `SetDatasource.containerSecurityContext.readOnlyRootFilesystem` | readOnlyRootFilesystem when set to true will make all the containers root file system read only | `true`
| `SetDatasource.containerSecurityContext.allowPrivilegeEscalation` | Grafana containers seccompProfile type | `false`
| `SetDatasource.containerSecurityContext.capabilities.drop` | allowPrivilegeEscalation when set to false will make sure sub-process created by container will get more privilege than parent process  | `ALL`


## Grafana Dashboard Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
| `SetDashboard.enabled` | enable to import the initial set of dashboards  | `true`
| `SetDashboard.backoffLimit` | Dashboard limit | `10`
| `SetDashboard.activeDeadlineSeconds` | Once a Job reaches activeDeadlineSeconds, all of its running Pods are terminated. Refer https://kubernetes.io/docs/concepts/workloads/controllers/job/#job-termination-and-cleanup for more details | `900`
| `SetDashboard.overwrite` | When upgrade if overwrite = true, dashboards in old release will be overwrited by dashboards in new chart | `true`
| `SetDashboard.resourcesTinytools.limits.memory` | Memory Resource limits | `128Mi`
| `SetDashboard.resourcesTinytools.limits.ephemeral-storage` | ephemeral-storage Resource limits | `1Gi`
| `SetDashboard.resourcesTinytools.requests.cpu` | Resource requests CPU | `100m`
| `SetDashboard.resourcesTinytools.requests.memory` | Resource requests for memory | `64Mi`
| `SetDashboard.resourcesTinytools.requests.ephemeral-storage` | Resource requests for ephemeral-storage | `250Mi`
| `SetDashboard.containerSecurityContext.readOnlyRootFilesystem` | readOnlyRootFilesystem when set to true will make all the containers root file system read only | `true`
| `SetDashboard.containerSecurityContext.allowPrivilegeEscalation` | Grafana containers seccompProfile type | `false`
| `SetDashboard.containerSecurityContext.capabilities.drop` | allowPrivilegeEscalation when set to false will make sure sub-process created by container will get more privilege than parent process  | `ALL`


## Provisioning Dashboards

Configure grafana dashboard providers and dashboards to import

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
| `dashboardProviders` | Configure grafana dashboard providers. ref: http://docs.grafana.org/administration/provisioning/#dashboards | `{}`
| `dashboards` | Configure grafana dashboard to import. NOTE: To use dashboards you must also enable/configure dashboardProviders ref: https://grafana.com/dashboards | `{}`

## Pod Annotations Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
| `podAnnotations.prometheus.io/port` | Pod Annotations for Port | `3000`
| `podAnnotations.prometheus.io/scrape` | Pod Annotation for Scrape | `true`

## Service Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
| `service.nameOverride`             | Kubernetes custom service name | `nameOverride`
| `service.type`             | Kubernetes service type | `ClusterIP`
| `service.port`             | Kubernetes port where service is exposed| `80`
| `service.annotations`      | Service annotations | `{}`
| `service.annotationsForScrape` | promethues scrape needs to be enabled or not. Actual value of scheme will be internally fetched from .Values.scheme | `prometheus.io/scrape: "true"`
| `service.labels`           | Custom labels                       | `{}`

## Ingress Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
| `ingress.enabled`          | Enables Ingress | `false`
| `ingress.annotations`      | Ingress annotations | `{}`
| `ingress.labels`           | Custom labels                       | `{}`
| `ingress.hosts`            | Ingress accepted hostnames | `[]`
| `ingress.path`             | Ingress path | `/grafana/?(.*)`
| `ingress.tls`              | Ingress TLS configuration | `[]`
| `ingress.pathType`         | Ingress pathType. All possible allowed values for pathType are "Prefix" OR "ImplementationSpecific" OR "Exact"  | `"Prefix"`
## Backup and Restore Policy (CBUR) Configuration

By default, the data backed up by CBUR is always encrypted. Set `cbur.dataEncryptionEnable` to false, in order to backup and restore without encrtyption. If encryption with customised passphrase is needed then secret should be created with passphrase and secret name has to be set in `cbur.dataEncryptionSecretName`. Restore can be performed from encrypted backedup data provided passphrase is same during both backup and restore.

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
| `cbur.enabled`  | If true, will install cbur  | `true`
| `cbur.image.imageRepo`  |  Image repo for cbur  | `cbur/cbur-agent`
| `cbur.image.imageTag`  |  Image tag for cbur  |  `1.1.1-alpine-6578`
| `cbur.image.imagePullPolicy`  | Image pull policy for cbur  |  `"IfNotPresent"`
| `cbur.resource.limits.memory`  | cbur pod resource limits for memory  |  `500Mi`
| `cbur.resource.limits.ephemeral-storage`  | cbur pod resource limits for ephemeral-storage  |  `1Gi`
| `cbur.resources.requests.cpu`  | cbur pod resource requests for cpu  |  `100m`
| `cbur.resources.requests.memory`  |  cbur pod resource requests for memory  |  `128Mi`
| `cbur.resources.requests.ephemeral-storage`  |  cbur pod resource requests for ephemeral-storage  |  `250Mi`
| `cbur.backendMode`  | For "local" backend, CBUR will sync with the data in /CBUR_REPO |  `local`
| `cbur.autoEnableCron`  |  If BrPolicy contains spec.cronspec that is not empty, autoEnableCron = true indicates that the cron job is immediately scheduled when the BrPolicy is created, while autoEnableCron = false indicates that scheduling of the cron job should be done on a subsequent backup request. This option only works when k8swatcher.enabled is true |  `false`
| `cbur.autoUpdateCron`  |  Idicate if subsequent update of cronjob will be done via brpoilicy update. true means cronjob must be updated via brpolicy update, false means cronjob must be updated via manual "helm backup -t app -a enable/disable" command. |  `false`
| `cbur.cronJob`  |  cronjob frequency, here means very 5 minutes of every day  |  `*/5 * * * *`
| `cbur.maxCopy`  | the maximum copy you want to saved  | `5`
| `cbur.waitPodStableSeconds`  | The timer to wait for pods stable after backup / restore.If not set, CBUR will wait for default  800 seconds. |
| `cbur.ignoreFileChanged`  | Whether to ignore the file change(s) or not when creating tar file in cbura sidecar |  `true`
| `cbur.dataEncryptionEnable`  | data Encryption needs to be done on backed up data or not | `true`
| `cbur.dataEncryptionSecretName`  | Secret name having customised passphrase for encrypt/decrypt backup | ``
| `cbur.containerSecurityContext.readOnlyRootFilesystem` | readOnlyRootFilesystem when set to true will make all the containers root file system read only | `true`
| `cbur.containerSecurityContext.allowPrivilegeEscalation` | Grafana containers seccompProfile type | `false`
| `cbur.containerSecurityContext.capabilities.drop` | allowPrivilegeEscalation when set to false will make sure sub-process created by container will get more privilege than parent process | `ALL`
| `cbur.ephemeralVolume.enabled` |  Ephemeral Volumes shall be used if enabled  | `""`
| `cbur.ephemeralVolume.volumedata.storageClass` |  Ephemeral Volumes storage class name  | `""`
| `cbur.ephemeralVolume.volumedata.accessmodes` | Ephemeral Volumes Access Modes  | `[ "ReadWriteOnce" ]`
| `cbur.ephemeralVolume.volumedata.storageSize` | Ephemeral Volumes storage size shall we specified.It can be considered to use when component requires to store more data (>1BG) with higher IOPS. | `1Gi`
## Custom name configuration for pod and container names

Pod and container name should be unique

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
| `customResourceNames.resourceNameLimit` |  providing limit to the custom name created | `63`
| `customResourceNames.grafanaPod` | section to provide grafana pod specific configuration names | `{}`
| `customResourceNames.grafanaPod.inCntChangeDbSchema` | field to customize changedbschema init-container name in grafana pod | `""`
| `customResourceNames.grafanaPod.inCntChangeMariadbSchema` | field to customize changeMariadbSchema init-container name in grafana pod | `""`
| `customResourceNames.grafanaPod.inCntWaitforMariadb` | field to customize waitforMariadb init-container name in grafana pod  | `""`
| `customResourceNames.grafanaPod.inCntDownloadDashboard` | field to customize downloaddashboard init-container name in grafana pod | `""`
| `customResourceNames.grafanaPod.pluginsidecar` | field to customize pluginsidecar container name in grafana pod | `""`
| `customResourceNames.grafanaPod.grafanaSidecarDashboard` | field to customize grafanaSidecarDashboard container name in grafana pod | `""`
| `customResourceNames.grafanaPod.grafanaSaneAuthproxy` | field to customize grafanaSaneAuthproxy container name in grafana pod | `""`
| `customResourceNames.grafanaPod.grafanaMdbtool` | field to customize grafanaMdbtool container name in grafana pod | `""`
| `customResourceNames.grafanaPod.grafanaDatasource` | field to customize grafanaDatasource container name in grafana pod | `""`
| `customResourceNames.grafanaPod.grafanaContainer` | field to customize grafanaContainer container name in grafana pod | `""`
| `customResourceNames.grafanaPod.grafanaUtil` | field to customize grafanaUtil container name in grafana pod | `""`
| `customResourceNames.grafanaPod.inCntWait4Certs2BeConsumed` | field to customize inCntWait4Certs2BeConsumed container name in grafana pod | `""`
| `customResourceNames.grafanaPod.cburaSidecarContainer` | field to customize cburaSidecarContainer container name in grafana pod. it's name should end with cbura-sidecar | `""`
| `customResourceNames.deleteDatasourceJobPod` | section to provide deleteDatasourcejobPod  customized  pod and container  names | `{}`
| `customResourceNames.deleteDatasourceJobPod.name` | the name field which is under the section deleteDatasourcejobPod used for customizing pod name | `""`
| `customResourceNames.deleteDatasourceJobPod.deleteDatasourceContainer` | the deleteDatasourceContainer field which is under the section deleteDatasourcejobPod used for customizing container name in deleteDatasourcejobPod | `""`
| `customResourceNames.setDatasourceJobPod` | section to provide setDatasourcejobPod  customized  pod and container  names | `{}`
| `customResourceNames.setDatasourceJobPod.name` |  the name field which is under the section setDatasourcejobPod used for customizing pod name | `""`
| `customResourceNames.setDatasourceJobPod.setDatasourceContainer` | the setDatasourceContainer field which is under the section setDatasourcejobPod used for customizing container name in setDatasourcejobPod| `""`
| `customResourceNames.postUpgradeJobPod` | section to provide postUpgradejobPod  customized  pod and container  names | `{}`
| `customResourceNames.postUpgradeJobPod.name` |  the name field which is under the section postUpgradejobPod used for customizing pod name | `""`
| `customResourceNames.postUpgradeJobPod.postUpgradeJobContainer` | the postUpgradejobContainer field which is under the section postUpgradejobPod used for customizing container name in postUpgradejobPod| `""`
| `customResourceNames.postDeleteJobPod` | section to provide postDeletejobPod  customized  pod and container names | `{}`
| `customResourceNames.postDeleteJobPod.name` |  the name field which is under the section postDeletejobPod used for customizing pod name | `""`
| `customResourceNames.postDeleteJobPod.deletedbContainer` | the deletedbContainer field which is under the section postDeletejobPod used for customizing container name in postDeletejobPod | `""`
| `customResourceNames.postDeleteSecretJobPod` | section to provide postDeleteSecretDeletejobPod  customized  pod and container names | `{}`
| `customResourceNames.postDeleteSecretJobPod.name` |  the name field which is under the section postDeleteSecretDeletejobPod used for customizing pod name | `""`
| `customResourceNames.postDeleteSecretJobPod.deletesecretsContainer` | the deletesecretsContainer field which is under the section postDeleteSecretDeletejobPod used for customizing container name in postDeleteSecretDeletejobPod | `""`
| `customResourceNames.importDashboardjobPod` | section to provide importDashboardjobPod  customized  pod and container names | `{}`
| `customResourceNames.importDashboardjobPod.name` |  the name field which is under the section postDeletejobPod used for customizing pod name | `""`
| `customResourceNames.importDashboardJobPod.importDashboardjobContainer` | the importDashboardjobContainer field which is under the section importDashboardjobPod used for customizing container name in importDashboardjobPod | `""`| `customResourceNames.grafanaTestPod.name` | Used for customizing grafana test pod name | `""`
| `customResourceNames.grafanaTestPod.grafanaTestContainer` | used for customizing container name | `""`

## CMDB Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
| `cmdb.enabled`  | If true, Mariadb will be installed |  `false`
| `cmdb.retain_data`  |   If retain_data is true, will retain grafana data in mariadb when deleting grafana instance.  retain_data should be set to true if grafana is expected to communicate with cmdb which is installed as part of same umbrella chart. Anyway if complete umbrella chart is deleted then compelte cmdb is also deleted. No need to explicitly delete specific to grafana.  | `false`
| `cmdb.certsecret` | CMDB secret name, it's value can be precreated secret, "" or certmanager. Following example command to pre create secret:
kubectl create secret generic cmdbsec1 --from-file=client.key="tls.key" --from-file=client.crt="tls.crt" --from-file=ca.crt="ca.crt" -n <namespace> | ""
| `image.imagePullPolicy`    | Image pull policy | `"IfNotPresent"`

## Grafana DB structure and Data Migration Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
| `need_dbupdate`           | Enable if DB structure has changed between the from version and to version of the upgrade| `false`
| `sqlitetomdb`             | Enable to do data migration from SQLite DB to MariaDB | `false`

## Grafana CKEY Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
| `keycloak.url`  |  Update ckeyUrl with the deployed keyclock baseurl, ex: 10.76.84.192:32443, ckey.example.com, ckeyistio.example.com:31390i(istio ingress), 10.76.84.192/ckey (ingress)  |  `10.76.84.192:32443`
| `keycloak.protocol`  | Protocol used  |  `https`
| `keycloak.contextPath`  | Ckey url context path |  `auth`
| `keycloak.realm`  ||  `cpro`
| `keycloak.secret`  |  Secret used in keycloak  |  ``
| `keycloak.cert`  |  if secret is null, then keycloak use cert. If secret is not null and it is a existing secret name, then use secret Certificate |  ``

## Istio Configuration

Configuration for all istio level parameters.

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
| `istio.version`            | Version of istio available in the cluster | `1.11`
`istio.sidecar.healthCheckPort`            | Istio sidecar (Envoy) healthcheck port. If it is not set, then the default value is 15021, and 15020 for Istio versions prior to 1.6. | `15021` for istio version 1.6 and above. `15020` for istio version less than 1.6
`istio.sidecar.stopPort`            | Istio sidecar (Envoy) admin port on which `quitquitquit` endpoint can be used to stop sidecar container. | `15000` 
| `istio.enabled`            | Istio feature is enabled or not | `false`
| `istio.mtls.enabled`       | Istio Mutual TLS is enabled or not. These will be taken into account based on istio.enabled | `true`
| `istio.cni.enabled`        | CNI is enabled or not | `true`
| `istio.permissive`         | Should allow mutual TLS as well as clear text for your deployment true or false | `true`
| `istio.createDrForClient`  | This optional flag should only be used when application was installed in istio-injection=enabled namespace, but was configured with istio.enabled=false, thus istio sidecar could not be injected into this application. Client then would need destinationRule for accessing this application True or False | `true`
| `includeWorkloadInIstioMesh`              | This configuration allows the user to create the Headless SVC and normal SVC for the REGISTRYONLY environment in istio for making the cpro scrape the metrics  | `false`
| `istio.sharedHttpGateway.namespace`         | The namespace in which the sharedHttpGateway is created | `istio-system`
| `istio.sharedHttpGateway.name`         | The name of the sharedHttpGateway | `single-gateway-in-istio-system`
| `istio.gateways.cproGrafana.enabled`         | If the gateway is enabled or not. If False, gateway will not be created | `true`
| `istio.gateways.cproGrafana.labels`         | The labels that need to be added to the gateway | `{}`
| `istio.gateways.cproGrafana.annotations`         | The annotations that need to be added to the gateway | `{}`
| `istio.gateways.cproGrafana.ingressPodSelector`         | Istio ingress gateway selector | `{istio: ingressgateway}`
| `istio.gateways.cproGrafana.port`         | The port for the Gateway to connect to | `443`
| `istio.gateways.cproGrafana.protocol`         | The protocol for the Gateway will use | `HTTPS`
| `istio.gateways.cproGrafana.host`         | the host used to access the management GUI from istio ingress gateway. If empty default will be * | `[]`
| `istio.gateways.cproGrafana.tls.redirect`         | Whether the request to be redirected from HTTP to HTTPS | `true`
| `istio.gateways.cproGrafana.tls.mode`         | mode could be SIMPLE, MUTUAL, PASSTHROUGH, ISTIO_MUTUAL | `SIMPLE`
| `istio.gateways.cproGrafana.tls.credentialName`         | Secret name for Istio Ingress | `"am-gateway"`
| `istio.gateways.cproGrafana.tls.custom`         | Custom TLS configurations that needs to be added to the gateway | `{}`
| `istio.createKeycloakServiceEntry.enabled` | Enable this flag to create a Service Entry for KeyCloak | `false`
| `istio.createKeycloakServiceEntry.extCkeyHostname` | Hostname with which CKEY is accessible from outside Ex. extCkeyHostname: "ckey.io" | `""`
| `istio.createKeycloakServiceEntry.extCkeyPort` | Port on which ckey is externally accessible. Ex. extCkeyPort: 31390 | `""`
| `istio.createKeycloakServiceEntry.extCkeyProtocol` | Protocol on which ckey is externally accessible. accepted values: HTTP, HTTPS | `""`
| `istio.createKeycloakServiceEntry.ckeyK8sSvcName` | FQDN of ckey k8s service name internally accessible within k8s cluster. Ex. keycloak-ckey.default.svc.cluster.local | `""`
| `istio.createKeycloakServiceEntry.ckeyK8sSvcPort` | Port on which ckey k8s service is accessible. Ex. ckeyK8sSvcPort: 8443 | `""`
| `istio.createKeycloakServiceEntry.hostAlias` | If the host name of ckey is not resolvable then edge node ip has to be given here | `""`
| `istio.createKeycloakServiceEntry.location` | Location specifies whether the service is part of Istio mesh or outside the mesh Ex. MESH_EXTERNAL/MESH_INTERNAL | `"MESH_INTERNAL"`

## fluentd container configuration

| `fluentd.image.repo`            | Image repository for the fluentd | `bssc-fluentd`
| `fluentd.image.tag`            | Image tag for the fluentd | `1.16.2-rocky8-jre17-2311.0.1`
| `fluentd.image.ImagePullPolicy`            |  imagepullpolicy for the fluentd | `IfNotPresent`
| `fluentd.resources.limits.memory` | Resource limits for Memory | `500Mi`
| `fluentd.resources.limits.ephemeral-storage` | Resource limits for ephemeral-storage | `1Gi`
| `fluentd.resources.requests.cpu` | Resource requests for CPU | `200m`
| `fluentd.resources.requests.memory` | Resource requests for Memory | `200Mi`
| `fluentd.resources.requests.ephemeral-storage` | Resource requests for ephemeral-storage | `200Mi`
| `fluentd.containerSecurityContext.capabilities.drop` | allowPrivilegeEscalation when set to false will make sure sub-process created by container will get more privilege than parent process  | `ALL`
| `fluentd.containerSecurityContext.runAsUser`                | fluentd containers will be run as the specified user. configure runAsUser other than 65534 | `65530`
| `fluentd.env`                | fluentd env variableds | `{"name:"SYSTEM","value":"BCMT","name":"SYSTEMID","value":BCMT_ID"} `
| `fluentd.containerSecurityContext.readOnlyRootFilesystem` | readOnlyRootFilesystem is a file attribute which only allows a user to view a file, restricting any writing to the file | `true`
| `fluentd.containerSecurityContext.allowPrivilegeEscalation` | allowPrivilegeEscalation when set to false will make sure sub-process created by container will get more privilege than parent process  | `false`



## logrotate container configuration

| `logrotate.image.repo`            | Image repository for the logrotate | `char/char-logmanager`
| `logrotate.image.tag`            | Image tag for the logrotate | `8.2310.0-1.0`
| `logrotate.ImagePullPolicy`            |  imagepullpolicy for the logrotate | `IfNotPresent`
| `logrotate.resources.limits.memory` | Resource limits for Memory | `500Mi`
| `logrotate.resources.limits.ephemeral-storage` | Resource limits for ephemeral-storage | `1Gi`
| `logrotate.resources.requests.cpu` | Resource requests for CPU | `200m`
| `logrotate.resources.requests.memory` | Resource requests for Memory | `200Mi`
| `logrotate.resources.requests.ephemeral-storage` | Resource requests for ephemeral-storage | `200Mi`
| `logrotate.containerSecurityContext.capabilities.drop` | allowPrivilegeEscalation when set to false will make sure sub-process created by container will get more privilege than parent process  | `ALL`
| `logrotate.containerSecurityContext.allowPrivilegeEscalation` | allowPrivilegeEscalation when set to false will make sure sub-process created by container will get more privilege than parent process  | `false`
| `logrotate.containerSecurityContext.readOnlyRootFilesystem` | readOnlyRootFilesystem is a file attribute which only allows a user to view a file, restricting any writing to the file | `true`

## Probes Configuration

Configurations about  probes for Grafana including livenessProbe and readinessProbe

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
| `livenessProbe.initialDelaySeconds` | Liveness Probe initial delay seconds | `60`
| `livenessProbe.timeoutSeconds` | Time out seconds | `1`
| `livenessProbe.failureThreshold` | Failure threshold | `10`
| `livenessProbe.periodSeconds` | Period in seconds | `3`
| `livenessProbe.scheme` | Grafana Scheme | `HTTPS`
| `readinessProbe.initialDelaySeconds` | Liveness Probe initial delay seconds | `60`
| `readinessProbe.timeoutSeconds` | Time out seconds | `30`
| `readinessProbe.failureThreshold` | Failure threshold | `10`
| `readinessProbe.periodSeconds` | Period in seconds | `10`
| `readinessProbe.scheme` | Grafana Scheme | `HTTPS`

## Grafana TLS (Access Grafana in HTTPS)

Grafana itself supports both HTTP and HTTPS. Refer to http://docs.grafana.org/installation/configuration/#server there are parameters to enable HTTPS.

User can only choose one - either HTTP, or HTTPS.

Certifcate are required to enable HTTPS. To provide these, CPRO-Grafana generated a self-signed certificate by default. Users can overide the server certifcate and key in values.yaml.Refer [Generate certificate for Grafana TLS](#generate-certificate-for-grafana-tls)

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
| `livenessProbe.scheme` | Grafana Scheme | `HTTPS`
| `readinessProbe.scheme` | Grafana Scheme | `HTTPS`
| `grafana_ini.server.protocol` |  | `https`
| `grafana_ini.server.cert_file` |  | `/etc/grafana/ssl/server.crt`
| `grafana_ini.cert_key` |  | `/etc/grafana/ssl/server.key`

## Grafana Primary Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
| `grafana_ini.auth.basic.enabled` | To enable basic authentication of Grafana and disable it for bypassing Authentication | `true`
| `grafana_ini.auth.proxy.enabled` | To enable proxy user for Grafana | `false`
| `grafana_ini.auth.proxy.header_name` | HTTP Header name that will contain the username or email | `X-WEBAUTH-USER`
| `grafana_ini.auth.basic.header_property` | HTTP Header property, defaults to `username` but can also be `email` | `username`
| `grafana_ini.auth.basic.auto_sign_up` | Set to `true` to enable auto sign up of users who do not exist in Grafana DB. Defaults to `true` | `true`
| `grafana_ini.auth.basic.sync_ttl` | If combined with Grafana LDAP integration it is also the sync interval | `60`
| `grafana_ini.auth.basic.enable_login_token` |  Check out docs on this for more details on the below setting | `false`
| `grafana_ini.paths.data` | Grafana primary configuration. NOTE: values in map will be converted to ini format. ref: http://docs.grafana.org/installation/configuration/ | `/var/lib/grafana/data`
| `grafana_ini.paths.logs` | Path where grafana logs get stored | `/var/log/grafana`
| `grafana_ini.paths.plugins`| Plugins | `/var/lib/grafana/plugins`
| `grafana_ini.paths.provisioning`| Provisioning  | `/etc/grafana/provisioning`
| `grafana_ini.analytics.check_for_updates` |  | `false`
| `grafana_ini.analytics.reporting_enabled` |  | `false`
| `grafana_ini.log.mode`    |   | `console`
| `grafana_ini.log.level`    |   | `INFO`
| `grafana_ini.grafana_net.url` |  | `https://grafana.net`
| `grafana_ini.server.protocol` |  | `https`
| `grafana_ini.server.min_tls_version` | Grafana TLS version can be set. Accepted values are TLS1.2 and TLS1.3, if no value is set it shall pick TLS1.2 as default value | `TLS1.2`
| `grafana_ini.server.root_url` | when istio is enabled: root_url path and Contextroot path should match  | `""`
| `grafana_ini.server.cert_file` |  | `/etc/grafana/ssl/server.crt`
| `grafana_ini.smtp.user` | set to $(smtp_user) when sensitive data enabled | `$(smtp_user)`
| `grafana_ini.smtp.passwrod` | set to $(smtp_password) when sensitive data enabled | `$(smtp_password)`
| `grafana_ini.cert_key` |  | `/etc/grafana/ssl/server.key`
| `grafana_ini.serve_from_sub_path` | set to true when istio is enabled | `true`
| `grafana_ini.security.admin_user` | uncomment when sensitive data enabled. value to be passed in Values.adminUser section | `$file{/etc/secrets/username}`
| `grafana_ini.security.admin_password` |  uncomment when sensitive data enabled. value to be passed in Values.adminPassword section | `$file{/etc/secrets/password}`
| `grafana_ini.security.cookie_secure` | Set to true if you host Grafana behind HTTPS. Default is false | `false`
| `grafana_ini.users.allow_sign_up` |   | `true`
| `grafana_ini.users.allow_org_create` |   | `true`
| `grafana_ini.users.auto_assign_org` |   | `true`
| `grafana_ini.users.auto_assign_org_role` |  | `Viewer`
| `grafana_ini.auth.disable_login_form` |  | `false`
| `grafana_ini.auth.disable_signout_menu` |  | `false`
| `grafana_ini.auth.oauth_state_cookie_max_age` | OAuth state max age cookie duration. Defaults to 600 seconds | `600`
| `grafana_ini.auth.login_maximum_inactive_lifetime_duration` | The maximum lifetime (duration) an authenticated user can be inactive before being required to login at next visit. Default is 7 days (7d). This setting should be expressed as a duration, e.g. 5m (minutes), 6h (hours), 10d (days), 2w (weeks), 1M (month). | `7d`
| `grafana_ini.auth.login_maximum_lifetime_duration` | The maximum lifetime (duration) an authenticated user can be logged in since login time before being required to login. Default is 30 days (30d). This setting should be expressed as a duration, e.g. 5m (minutes), 6h (hours), 10d (days), 2w (weeks), 1M (month). | `30d`
| `grafana_ini.auth.token_rotation_interval_minutes` | How often should auth tokens be rotated for authenticated users when being active. The default is each 10 minutes. login_maximum_inactive_lifetime_duration parameter value should be greater than token_rotation_interval_minutes value. | `10`
| `grafana_ini.auth.signout_redirect_url` |  | `"{{ .Values.keycloak.protocol }}://{{ .Values.keycloak.url }}/auth/realms/{{ .Values.keycloak.realm }}/protocol/openid-connect/logout?post_logout_redirect_uri={{ .Values.grafana_ini.server.root_url }}"`
| `grafana_ini.auth.generic_oauth.enabled` |  | `false`
| `grafana_ini.auth.generic_oauth.name`    |  | `"{{ .Values.keycloak.realm }}"`
| `grafana_ini.auth.generic_oauth.client_id` |  | `grafana`
| `grafana_ini.auth.generic_oauth.client_secret` |  | `1a1a7188-b5b7-4c19-8459-c45c32a64437`
| `grafana_ini.auth.generic_oauth.scopes` |  | `openid`
| `grafana_ini.auth.generic_oauth.auth_url` |  | `"{{ .Values.keycloak.protocol }}://{{ .Values.keycloak.url }}/auth/realms/{{ .Values.keycloak.realm }}/protocol/openid-connect/auth"`
| `grafana_ini.auth.generic_oauth.token_url` |  | `"{{ .Values.keycloak.protocol }}://{{ .Values.keycloak.url }}/auth/realms/{{ .Values.keycloak.realm }}/protocol/openid-connect/token"`
| `grafana_ini.auth.generic_oauth.api_url` |  | `"{{ .Values.keycloak.protocol }}://{{ .Values.keycloak.url }}/auth/realms/{{ .Values.keycloak.realm }}/protocol/openid-connect/userinfo"`
| `grafana_ini.auth.generic_oauth.introspect_url` |  | `"{{ .Values.keycloak.protocol }}://{{ .Values.keycloak.url }}/auth/realms/{{ .Values.keycloak.realm }}/protocol/openid-connect/token/introspect"`
| `grafana_ini.allow_sign_up` |  | `true`
| `grafana_ini.tls_client_ca` |  | `/etc/grafana/keycloak/keycloak.crt`
| `grafana_ini.tls_skip_verify_insecure` |  | `false`
| `grafana_ini.role_attribute_path` | role_attribute_path is only available from Grafana v6.5+. | ``
| `grafana_ini.database.type` |  | `sqlite3`
| `grafana_ini.database.host` |  | `grafanadb-cmdb-mysql:3306`
| `grafana_ini.database.name` |  | `grafana`
| `grafana_ini.database.user` |  | `grafana`
| `grafana_ini.database.password` |  | `grafana`
| `grafana_ini.ssl_mode` |  | `true`
| `grafana_ini.ca_cert_path` |  | `/etc/grafana/cmdbtls/ca.crt`
| `grafana_ini.client_key_path` |  | `/etc/grafana/cmdbtls/client.key`
| `grafana_ini.server_cert_name` |  | `grafanadb-cmdb-mysql.default.svc.cluster.local`

## LDAP configuration

To enable LDAP the grafana.ini must be configured with auth.ldap.enabled.

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
| `ldap.existingSecret` | Reference to an existing secret containing the ldap configuration | `""`
| `ldap.config` | `config` is the content of `ldap.toml` that will be stored in the created secret | `""`

## SMTP configuration

To enable, grafana.ini must be configured with smtp.enabled .Ref: http://docs.grafana.org/installation/configuration/#smtp

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
| `smtp.existingSecret` | Reference to an existing secret containing the smtp configuration | `""`

## Dynamic addition of multiple dashboards and datasources in Grafana

Sidecars that collect the configmaps with specified label and stores the included files them into the respective folders
Requires at least Grafana 5 to work and can't be used together with parameters dashboardProviders, datasources and dashboards

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
| `sidecar.skipTlsVerify` | Set to true to skip tls verification for kube api calls | `false`
| `sidecar.enableUniqueFilenames` | Sets the csf-grafana-kiwigrid UNIQUE_FILENAMES environment variable | `false`
| `sidecar.resources.limits.memory` | Resource limits for Memory | `100Mi`
| `sidecar.resources.limits.ephemeral-storage` | Resource limits for ephemeral-storage | `1Gi`
| `sidecar.resources.requests.cpu` | Resource requests for CPU | `50m`
| `sidecar.resources.requests.memory` | Resource requests for Memory | `50Mi`
| `sidecar.resources.requests.ephemeral-storage` | Resource requests for ephemeral-storage | `250Mi`
| `sidecar.containerSecurityContext.readOnlyRootFilesystem` | readOnlyRootFilesystem when set to true will make all the containers root file system read only | `true`
| `sidecar.containerSecurityContext.allowPrivilegeEscalation` | Grafana containers seccompProfile type | `false`
| `sidecar.containerSecurityContext.capabilities.drop` | allowPrivilegeEscalation when set to false will make sure sub-process created by container will get more privilege than parent process  | `ALL`
| `sidecar.imageFlavor`                            | Supported Image Flavors are rocky8-python3.8 | `` |
|`sidecar.imageFlavorPolicy`      | imageFlavorPolicy can either take Best Match or Strict case | `` |

### Dynamic addition of multiple dashboards

If the parameter `sidecar.dashboards.enabled` is set, a sidecar container is deployed in the grafana pod. This container watches all config maps in the cluster and filters out the ones with a label as defined in `sidecar.dashboards.label`. The files defined in those configmaps are written to a folder and accessed by grafana. Changes to the configmaps are monitored and the imported dashboards are deleted/updated. A recommendation is to use one configmap per dashboard, as an reduction of multiple dashboards inside one configmap is currently not properly mirrored in grafana.
Example dashboard config:
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: sample-grafana-dashboard
  labels:
     grafana_dashboard: 1
data:
  k8s-dashboard.json: |-
  [...]
```
| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
| `sidecar.dashboards.enabled`            | Enabled the cluster wide search for dashboards and adds/updates/deletes them in grafana | `false`
| `sidecar.dashboards.folder` | folder in the pod that should hold the collected dashboards | `/home/dashboards`
| `sidecar.dashboards.folderAnnotation` | Annotation to be used in configmap to link folder location with component(s) dashboards | `grafana_folderpath`
| `sidecar.dashboards.label`            | Label that config maps with dashboards should have to be added | `false`
| `sidecar.dashboards.resource`            | resource can be set as secret, configmap or both | `"both"`
| `sidecar.dashboards.namespace`            | If specified, the sidecar will search for config-maps inside this namespace | `""`
| `sidecar.dashboards.level`            | Set the logging level(DEBUG, INFO, WARN, ERROR, CRITICAL) | `INFO`
| `sidecar.dashboards.provider.name`            | Unique name of the grafana provider | `sidecarProvider`
| `sidecar.dashboards.provider.orgid`            | Id of the organisation, to which the dashboards should be added | `1`
| `sidecar.dashboards.provider.folder`            | Logical folder in which grafana groups dashboards | `""`
| `sidecar.dashboards.provider.type`            | Provider type | `file`
| `sidecar.dashboards.provider.disableDelete`            | Activate to avoid the deletion of imported dashboards | `false`
| `sidecar.dashboards.provider.allowUiUpdates`            | Allow updating provisioned dashboards from the UI | `false`
| `sidecar.dashboards.provider.foldersFromFilesStructure`  |Allow Grafana to replicate dashboard structure from filesystem | `false`

### Dynamic addition of multiple datasources

If the parameter `sidecar.datasource.enabled` is set, a sidecar container is deployed in the grafana pod. This container watches all config maps in the cluster and filters out the ones with a label as defined in `sidecar.datasources.label`. The files defined in those configmaps are written to a folder and accessed by grafana on startup. Using these yaml files, the data sources in grafana can be modified.

Example datasource config adapted from [Grafana](http://docs.grafana.org/administration/provisioning/#example-datasource-config-file):
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: sample-grafana-datasource
  labels:
     grafana_datasource: 1
data:
        datasource.yaml: |-
                # config file version
                apiVersion: 1

                # list of datasources that should be deleted from the database
                deleteDatasources:
                  - name: Graphite
                    orgId: 1

                # list of datasources to insert/update depending
                # whats available in the database
                datasources:
                  # <string, required> name of the datasource. Required
                - name: Graphite
                  # <string, required> datasource type. Required
                  type: graphite
                  # <string, required> access mode. proxy or direct (Server or Browser in the UI). Required
                  access: proxy
                  # <int> org id. will default to orgId 1 if not specified
                  orgId: 1
                  # <string> url
                  url: http://localhost:8080
                  # <string> database password, if used
                  password:
                  # <string> database user, if used
                  user:
                  # <string> database name, if used
                  database:
                  # <bool> enable/disable basic auth
                  basicAuth:
                  # <string> basic auth username
                  basicAuthUser:
                  # <string> basic auth password
                  basicAuthPassword:
                  # <bool> enable/disable with credentials headers
                  withCredentials:
                  # <bool> mark as default datasource. Max one per org
                  isDefault:
                  # <map> fields that will be converted to json and stored in json_data
                  jsonData:
                     graphiteVersion: "1.1"
                     tlsAuth: true
                     tlsAuthWithCACert: true
                  # <string> json object of data that will be encrypted.
                  secureJsonData:
                    tlsCACert: "..."
                    tlsClientCert: "..."
                    tlsClientKey: "..."
                  version: 1
                  # <bool> allow users to edit datasources from the UI.
                  editable: false

```
| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
| `sidecar.datasources.enabled`            | Enabled the cluster wide search for datasources and adds/updates/deletes them in grafana | `false`
| `sidecar.datasources.label`            | Label that config maps with datasources should have to be added | `false`
| `sidecar.datasources.level`            | Set the logging level(DEBUG, INFO, WARN, ERROR, CRITICAL) | `INFO`

## Cert-Manager Certificate Configuration

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
| `certManager.enabled` | Generate certificates to scrape metrics from etcd in BCMT | ``
| `certManager.duration` | How long certificate will be valid | `8760h`
| `certManager.renewBefore` | When to renew the certificate before it gets expired | `360h`
| `certManager.keySize` | Size of KEY | `2048`
| `certManager.mountPath` | Certificates for grafana is mounted | `/etc/grafana/ssl`
| `certManager.servername` | CN of the certificate |
| `certManager.dnsNames` | DNS used in certificate | `localhost`
| `certManager.domain` | Domain name used in certificate |
| `certManager.ipAddress` | Alt Names used in certificate |
| `certManager.issuerRef.name` | Issuer Name. Self-signed issuer will be created if issuerRef name is empty at grafana.certificate.issuerRef.name, certManager.issuerRef.name and global.certManager.issuerRef.name |
| `certManager.issuerRef.kind` | CRD Name | 
| `certManager.issuerRef.group` | Api group Name |
| `certManager.wait4Certs2BeConsumed.enabled` | enable or disable waiting for certificates | `true`
| `certManager.wait4Certs2BeConsumed.resources.requests.memory` | Grafana pod resource requests of memory | `32Mi`
| `certManager.wait4Certs2BeConsumed.resources.requests.cpu` | Grafana pod resource requests of cpu | `10m`
| `certManager.wait4Certs2BeConsumed.resources.requests.ephemeral-storage` | Grafana pod resource requests of ephemeral-storage | `250Mi`
| `certManager.wait4Certs2BeConsumed.resources.limits.memory` | Grafana pod resource limits of memory | `32Mi`
| `certManager.wait4Certs2BeConsumed.resources.limits.ephemeral-storage` | Grafana pod resource limits of ephemeral-storage | `1Gi`
| `certManager.wait4Certs2BeConsumed.file` | list of name of certificates in the certManager | `tls.crt ca.crt tls.key`
| `certManager.wait4Certs2BeConsumed.loglevel` | log level valid values are debug, info, error, warn | `info`
| `certManager.wait4Certs2BeConsumed.logFmt` | logformat of the application. Default is logfmt. Supported values are logfmt, json | `logfmt`
| `certManager.wait4Certs2BeConsumed.timeout` | wait time for init container to run | `3m`
| `certManager.containerSecurityContext.readOnlyRootFilesystem` | readOnlyRootFilesystem when set to true will make all the containers root file system read only | `true`
| `certManager.containerSecurityContext.allowPrivilegeEscalation` | Grafana containers seccompProfile type | `false`
| `certManager.containerSecurityContext.capabilities.drop` | allowPrivilegeEscalation when set to false will make sure sub-process created by container will get more privilege than parent process  | `ALL`
| `certManager.imageFlavor`                            | Supported Image Flavors are distroless | `` |
|`certManager.imageFlavorPolicy`      | imageFlavorPolicy can either take Best Match or Strict case | `` |

## Support for configurable/random system users (Openshift environment only)

CPRO-Grafana supports random generated values as system user for its components, the security context for pods and container can be configured by the user.
Instead of providing values we can use the value “auto” for these fields, which will automatically assign the values for the fields runAsUser and fsGroup. This is only applicable in openshift environment.

| **Helm Parameter** | **Description** | **Default**
--------- | ----------- | -------
| `securityContext.runAsNonRoot`                | Grafana containers will be run as runAsNonRoot user | `true`
| `securityContext.runAsUser`                | Grafana containers will be run as the specified user | `65534`
| `securityContext.fsGroup`                  | fsGroup of Grafana container | `65534`
| `securityContext.supplementalGroups`       | Supplemental security groups of Grafana Container | `1904`
| `securityContext.seLinuxOptions.level` | Selinux level in PSP and security context of POD | `""`
| `securityContext.seLinuxOptions.role` | Selinux role in PSP and security Context of POD | `""`
| `securityContext.seLinuxOptions.type` | Selinux type in PSP and security context of POD | `""`
| `securityContext.seLinuxOptions.user` | Selinux user in PSP and security context of POD | `""`
| `securityContext.seccompProfile.type` | Grafana containers seccompProfile type | `RuntimeDefault`
| `containerSecurityContext.readOnlyRootFilesystem` | readOnlyRootFilesystem when set to true will make all the containers root file system read only | `true`
| `containerSecurityContext.allowPrivilegeEscalation` | Grafana containers seccompProfile type | `false`
| `containerSecurityContext.capabilities.drop` | allowPrivilegeEscalation when set to false will make sure sub-process created by container will get more privilege than parent process  | `ALL`
| `ephemeralVolume.enabled` |  Ephemeral Volumes shall be used if enabled  | `""`
| `ephemeralVolume.volumedata.storageClass` |  Ephemeral Volumes storage class name  | `""`
| `ephemeralVolume.volumedata.accessmodes` | Ephemeral Volumes Access Modes  | `[ "ReadWriteOnce" ]`
| `ephemeralVolume.volumedata.storageSize` | Ephemeral Volumes storage size shall we specified.It can be considered to use when component requires to store more data (>1BG) with higher IOPS.  | `1Gi`

## Dashboard zip file

* Dashboards can be zipped into a single file with the name (dashboards.zip) in the dashboards folder. All those files will be extracted.
* Features supported : only json files, single zip, combination of both.

## Generate certificate for Grafana TLS

```console
$ openssl genrsa -des3 -out server.key 1024
$ openssl req -new -key server.key -out server.csr
$ cp server.key server.key.org
$ openssl rsa -in server.key.org -out server.key
$ openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt
```

# API Changes

## Added

## Modified

## Deprecated

## Deleted

| **Helm Parameter** | **Reason** 
-------------------- | ----------|
| `cmdb.cacert`  |  As per HBP plain text certificates are not supported |
| `cmdb.clientcert` | As per HBP plain text certificates are not supported |
| `cmdb.clientkey` | As per HBP plain text certificates are not supported |
| `grafana.server_cert` | As per HBP plain text certificates are not supported |
| `grafana.server_key` | As per HBP plain text certificates are not supported |
| `adminUser` | As per HBP sensitive data shall not be taken in plain text |
| `adminPassword` | As per HBP sensitive data shall not be taken in plain text |

# CMDB Helm Chart Requirements

The CMDB helm chart provides a framework for deploying a MariaDB database in a kubernetes based environment.  This section will detail the operation conditions expected by the CMDB helm chart as well as details on helm chart configuration.

## Pod Security Standards

The CMDB helm chart can be installed in namespace with **restricted** Pod Security Standards profile.  See [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/).

### Special cases

None.

#### Istio enabled with disabled CNI

When installing the CMDB helm chart in an Istio environment with CNI disabled, it must be installed in a namespace with **privileged** Pod Security Standards profile.

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

# Helm configuration

The CMDB Helm chart or operator provides the packaging to deploy a [MariaDB](https://mariadb.org) database instance in one of the supported deployment configurations (simplex or Master/Slave). MariaDB is developed as an open source software and, as a relational database, provides an SQL interface for accessing data.

There is a large set of configuration parameters that can be specified as input values when deploying or upgrading the CMDB Helm chart or operator. Default and input values are passed in a YAML file, or can be passed via command-line `\--set argument` using the YAML object reference equivalent. The following values can be provided to override the defaults specified in the chart or CR.

<!--Q: Like what?
Note that there are additional values defined in the chart `values.yaml` file which are not listed on this page. Most of these are necessary for compliance to Helm's best practices. Do not change or reset any values not specifically listed in the tables below.-->

The following parameter groups are provided in this section for configuring the resource group:

- [Common and cluster-level parameters](#helm-common)
- [Unified Logging Parameters](#logging)
- [CMDB User Parameters](#helm-users)
- [CMDB Services Parameters](#helm-services)
- [MariaDB Clients Certificate Parameters](#helm-client-certs)
- [MariaDB Database Parameters](#helm-mariadb)
- [MaxScale proxy parameters](#helm-maxscale)
- [Administrative Parameters](#helm-admin)
- [Geo-Redundancy Parameters](#helm-geo-redundancy)
- [Hooks parameters](#helm-hooks)
- [Backup/Restore Policy (CBUR) Parameters](#helm-cbur)
- [Cert-Manager Certificate Parameters](#helm-certs)

## Common and cluster-level parameters
<a name="helm-common"></a>

| **Helm Parameter** | **Default** | **Description** | **Update Allowed**[^†^](#common_fn) |
|:----------|:----------|:----------------|:------------------------------------|
| `global.registry` | *(empty)*  | The registry URL used to pull CSF CMDB delivered container images, but can be preceded by internalRegistry. Also used for CBUR, OSDB, metrics, auth and exporter container images. | [Yes^1^](#"common_fn1") |
| `global._registry` | csf-docker-delivered.repo.cci.nokia.net | The default value for global.registry if empty. | [Yes^1^](#"common_fn1") |
| `global.registry1` | registry1-docker-io.repo.cci.nokia.net | ==REMOVED 9.0.0== The registry URL used to pull docker-io mirrored container images | [Yes^1^](#"common_fn1") |
| `global.registry2` | csf-docker-delivered.repo.cci.nokia.net | ==REMOVED 9.0.0==The registry URL used to pull CSF non-CMDB delivered container images (eg, CBUR, OSDB) | [Yes^1^](#"common_fn1") |
| `global.flatRegistry` | `false` | ==NEW 9.0.0== If set to `true`, the <repository path> in all container images will be skipped. | [Yes^1^](#"common_fn1") |
| `global.imageFlavor` | rocky8 | ==NEW 9.1.1== Default image flavor for all docker container.  Can be set to centos7 or rocky8 (or custom to use provided **image.tag** as-is. | Yes |
| `imageFlavor` | rocky8 | Default image flavor for all docker container.  Can be set to centos7 or rocky8 (or custom to use provided **image.tag** as-is. This takes precedence over the global.imageFlavor | Yes |
| `global.imageFlavorPolicy` | `BestMatch` | ==NEW 9.1.1== The policy which container image flavor should be based on. Options are: (Strict/BestMatch), with default BestMatch. | Yes |
| `imageFlavorPolicy` | `BestMatch` | ==NEW 9.1.1== The policy which container image flavor should be based on. Options are: (Strict/BestMatch), with default BestMatch. This takes precedence over the global.imageFlavorPolicy | Yes |
| `internalRegistry` | *(empty)* | ==NEW 9.0.0== The registry used for CMDB container images, takes precedence over global.registry. | [Yes^1^](#"common_fn1") |
| _internalRegistry | csf-docker-delivered.repo.cci.nokia.net | ==NEW 9.0.0== The default value for internalRegistry if empty. | [Yes^1^](#"common_fn1") |
| `global.imagePullSecrets` | *(omitted)* | Specify the Secrets to be passed to every pod and used for pulling registry images from a global secured registry.  | Yes |
| `global.podNamePrefix` | *(omitted)* | Prefix name to be prepended to every pod for both statefulsets pods and job pods. The prefix name will prepend the normal pod name which is made up of the release name and the pod name.  The pod prefix is *not* part of the relesae name and thus does not affect other created resources (eg, configmaps, services, etc.).  If it is desired to have a dash between the prefix and the release name which make up the normal pod name, then make sure you end the podNamePrefix with a dash. | No |
| `global.containerNamePrefix` | *(omitted)* | Container name to be prepended to every created container for both statefulset pod containers and job pod containers. If it is desired to have a dash between the prefix and the container name, then make sure you end the containerNamePrefix with a dash. | Yes |
| `global.disablePodNamePrefixRestrictions` | *(empty)* | ==NEW 9.0.0== If set to `true`, the length of podNamePrefix is not limited and "-" is not automatically appended. Default is `false` | Yes |
| `disablePodNamePrefixRestrictions` | *(empty)* | ==NEW 9.1.1== If set to `true`, the length of podNamePrefix is not limited and "-" is not automatically appended. Default is `false`. This takes takes precedence over the global.disablePodNamePrefixRestrictions | Yes |
| `global.hpa.enabled` | `false` | Specifies if Horizontal Pod Autoscaling (HPA) should be enabled for for all statefulsets which support it.  HPA can be enabled/disabled at the maxscale/mariadb statefulset level. | Yes |
| `global.priorityClassName` | *(omitted)* | The kubernetes Pod priority and preemption class name. Ref: [kubernetes.io Pod Priority Preemption](https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/) | No |
| `global.timeZoneEnv` | *(omitted)* | Specify the global TZ environment variable in all statefulset containers. (Example: America/Chicago or GST-6) | No |
| `global.labels` | *(empty)* | Specify the global labels. | No |
| `global.annotations` | *(empty)* | Specify the global annotations. | No |
| `global.enableDefaultCpuLimits` | `false` | ==NEW 9.0.0== Root level enableDefaultCpuLimits takes precedence over this value. If set to `true`, all containers limits.cpu will be set to default value. But the specific cpu configuration takes precedence over this feature. | Yes |
| `global.istio.sidecar.healthCheckPort` | *(empty)* | ==NEW 9.0.0== Istio sidecar/envoy healthcheck port. If not set, the default value is 15021 and 15020 for istio version prior to 1.6. | Yes |
| `global.istio.sidecar.stopPort` | 15000 | ==NEW 9.0.0== Istio sidecar/envoy admin port on which 'quitquitquit' endpoint can be used to stop sidecar container. | Yes |
| `global.unifiedLogging.*` | *(empty)* | ==UPDATED 9.2.0== Sets [Unified Logging Parameters](#logging) at the global level | Yes |
| custom.<kind>.labels | *(empty)* | Specify the customized labels to assign to every created <kind> resource (eg, pod, or podsecuritypolicy).  The **kind** is the resource kind name (eg, statefulset, pod, configmap) for the resource to assign custom labels for. | Yes |
| custom.<kind>.annotations | *(empty)* | Specify the customized annotations to assign to any created <kind> resource.  The **kind** is the resource kind name (eg, statefulset, pod, configmap) for the resource to assign annotations labels for. | No |
| `custom.mariadbSts.selectors` | *(empty)* | Specify the customized selector labels to assign to the mariadb StatefulSet. | No |
| `custom.maxscaleSts.selectors` | *(empty)* | Specify the customized selector labels to assign to the maxscale StatefulSet. | No |
| `rbac.enabled` | `true` | Specifies whether Role-Based Access Control (RBAC) is enabled in the underlying kubernetes environment. | No |
| `rbac.psp.create` | `true` | Specifies whether PodSecurityPolicy(psp) is created in the underlying kubernetes environment. Should be `false` for OpenShift.  Only used in Istio (non-CNI) environment. | No |
| `rbac.scc.create` | `false` | Specifies whether SecurityContextConstraints(scc) is created in the underlying OpenShift environment.  Only used in Istio (non-CNI) environment. | No |
| `istio.enabled` | `false` | Indicates if the deployment is being performed in an istio-enabled namespace.  Also make sure that **istio.version** is set appropriately for the base kubernetes platform.  | No |
| `istio.version` | 1.6 | The istio version installed on the platform being used to install CMDB in the istio environment. Only used if istio.enabled is `true`. | No |
| `istio.cni.enabled` | `false` | Indicates if the Istio CNI plugin is installed. | No |
| `istio.mtls.enabled` | `true` | ==NEW 9.2.0== Defines peerauthentication/policy MTLS connection configuration togehter with istio.permissive.enabled. Refer: https://istio.io/latest/docs/reference/config/security/peer_authentication/. If mtls.enabled is true and permissive is false, set mtls mode to STRICT. If mtls.enabled is true and permissive is true, set mtls mode to PERMISSIVE. If mtls.enabled is false(not recommended), set mtls mode to UNSET. | No |
| `istio.permissive.enabled` | `false` | ==NEW 9.2.0== Indicates the connection is plaintext or mTLS tunnel, work together with istio.mtls.enabled. | No |
| `istio.gateway.enabled` | `false` | Indicates if an Istio  Gateway and Virtual Service should be created for geo-redundant ingress traffic support. | No |
| `istio.gateway.name` | <Chart Release\> | The name of the Istio Gateway created when istio.gateway.enabled is True.  The Virtual Service will be named <istio.gateway.name\>-vs | No |
| `istio.gateway.ingressPodSelector` | {'istio': 'ingressgateway'\} | Selector for ingressgateway pod which you want your gateway to attach to. | No |
| `istio.gateway.hosts` | ["\*"\] | Hosts exposed by this gateway.  Defaults to all hosts. | No |
| `istio.gateway.tls.mode` | `ISTIO_MUTUAL` | Istio TLS mode for connections to gateway ports. | No |
| `istio.gateway.tls.credentialName` | *(omitted)* | The name of the secret holding the TLS certificates, incluiding the CA certificates.  Secret keys must be **cert**, **key** and **cacert**.  Required for certiain TLS modes. | No |
| `istio.gateway.tls.custom` | {\} | Additional configuration to be added as-is to the TLS section of the gateway. Ref: [TLSSettings](https://istio.io/latest/docs/reference/config/networking/gateway/#ServerTLSSettings). | No |
| `istio.serviceEntry.create` | `false` | Defines whether or not ServiceEntry resources will be created for egress traffic to remote services in a geo-redundant istio environment. | No |
| `istio.destinationRule.tls.mode` | `ISTIO_MUTUAL` | ==NEW 9.2.0== Defines Istio DestinationRule's TLS connection mode with allowed values: DISABLE, SIMPLE, MUTUAL, ISTIO_MUTUAL. | Yes |
| `serviceAccountName` | *(omitted)* | Service Account to use instead of a generated one (Also disables generation of Roles/Rolebindings). See [RBAC Rules](./oam_rbac_rules.md) | No |
| `timeZoneEnv` | *(omitted)* | Set as TZ environment variable in all statefulset containers.  (Example: America/Chicago or GST-6) | [Yes^1^](#"common_fn1") |
| `enableDefaultCpuLimits` | *(empty)* | ==NEW 9.0.0== Take precedence over global.enableDefaultCpuLimits. If set to `true`, all containers limits.cpu will be set to default value. But the specific cpu configuration takes precedence over this feature. | Yes |
| `unifiedLogging.*` | *(empty)* | ==UPDATED 9.2.0== Sets [Unified Logging Parameters](#logging) at the site level. Take precedence over global.unifiedLogging.*  | Yes |
| `auth.enabled` | `false` | Set to `true` to enable zt-proxy metrics authentication sidecar in all statefulsets. | Yes |
| `auth.secretRef.name` | *(empty)* | The OpenID Connect (OIDC) secret name required if OIDC authentication to be enabled. Set here to use same OIDC secret for all statefulsets. See [Zero Trust Overview](#zt_overview). | Yes |
| `auth.skipVerifyInsecure` | `true` | Skip certificate verification with authentication server (insecure mode). | Yes |
| `auth.tls.secretRef.name` | *(omitted)* | If prometheus is configured to use TLS for scrape, then the certificates used to authenticate the scrape request must be provided ion this secret.  The secret resource containing all the certificate files must be pre-populated before CMDB deployment. | Yes |
| auth.tls.secretRef.server_ca_cert<p>auth.tls.secretRef.server_cert</p><p>auth.tls.secretRef.server_key </p>| prom-server-ca-cert.pem<p>prom-server-cert.pem</p><p>prom-server-key.pem </p>| The specific server certificate file names defined in the **auth.tls.secretRef.name**. | Yes |
| `clusterDomain` | `cluster.local` | Cluster domain used in raw k8s installs | No |
| `cluster_name` | <Chart Release\> | Passed into the CMDB containers as CLUSTER_NAME (See [Docker Configuration](./oam_configure_docker.md)) | No |
| `cluster_type` | master-slave | Passed into the CMDB containers as CLUSTER_TYPE (See [Docker Configuration](./oam_configure_docker.md)).  This value can now be changed during helm upgrade to perform a topology morph (see [Update Allowed^2^](#"common_fn2")). | [Yes^2^](#"common_fn2") |
| `max_node_wait` | 15 | Time (in minutes) maximum to wait for all pods to come up. Passed into the CMDB containers as MAX_NODE_WAIT (See [Docker Configuration](./oam_configure_docker.md)). | Yes |
| `quorum_node_wait` | 120 | Time (in seconds) maximum to wait for additional pods to come up after a quorum (50% + 1) is reached before continuing. Passed into the CMDB containers as QUORUM_NODE_WAIT (See [Docker Configuration](./oam_configure_docker.md)). | Yes |
| `deployRequires` | all | The number of pods required to consider deployment successful.  One of *all* = all pods must be available, *quorum* = a quorum of pods must be available, or *any* = at least one pod must be available (USE WITH CAUTION). | No |
| `nodeAntiAffinity` | hard | Specifies the type of anti-affinity for scheduling pods to nodes *(hard\|soft)* | No |
| `displayPasswords` | if-generated | Specifies if passwords should be displayed by the helm NOTES, which are displayed when helm install completes.  Options are never, if-generated, always | No |
| partOf | cmdb | Specifies the parent chart that this CMDB helm chart is a part of if CMDB chart is being used in an umbrella chart | Yes^1^ |
| `podSecurityContext` | {\} | Override for pods default securityContext settings, if set will be used for all pods created. Further refinement of the securityContexts can be set in the various subsystems (e.g., mariadb, maxscale, admin, etc.) | No |
| `podSecurityContext.disabled` | *(omitted)* | To disable all pod securityContext settings (i.e. OpenShift environment), podSecurityContext.disabled should be set to `true` | No |
| `containerSecurityContext` | {\} | Override for containers default securityContext settings, if set will be used for all containers created. Further refinement of the securityContexts can be set in the various subsystems (e.g., mariadb, maxscale, admin, etc.) | No |
| `containerSecurityContext.disabled` | *(omitted)* | To disable all container securityContext settings (i.e. OpenShift environment), containerSecurityContext.disabled should be set to `true` | [No](#"common_fn1") |
| `ipFamilyPolicy` | *(empty)* | Represents the dual-stack-ness requested or required by all services.  Ref: [IPv4/IPv6 dual-stack](https://kubernetes.io/docs/concepts/services-networking/dual-stack/). | No |
| `ipFamilies` | *(empty)* | List of IP families (eg, IPv4, IPv6) assigned to all services.  Ref: [IPv4/IPv6 dual-stack](https://kubernetes.io/docs/concepts/services-networking/dual-stack/). | No |
| `global.certManager.enabled` | *(omitted)* | Define the enablement of the certManager for Automatically generated certificates. If omitted, it is enabled. To disable set it to `false`. | No |
| `global.certManager.apiVersion` | *(empty)* | Defines the versioned schema of this representation of an object.  | No |
| `global.certManager.issuerRef.name` | *(empty)* | ==NEW 9.2.0== Defines the issuer name.| No |
| `global.certManager.issuerRef.kind` | *(empty)* | ==NEW 9.2.0== The supported issuer kinds are ClusterIssuer and Issuer.| No |
| `global.certManager.issuerRef.group` | *(empty)* | ==NEW 9.2.0== Defines the issuer group.| No |
| `certManager.enabled` | *(omitted)* | Define the enablement of the certManager for Automatically generated certificates. If omitted, it is enabled. To disable set it to `false`. This root level dictates enablement or disablement.  | No |
| `certManager.apiVersion` | cert-manager.io/v1 | Defines the versioned schema of this representation of an object.  | No |
| `certManager.issuerRef.name` | *(empty)* | ==NEW 9.2.0== Defines the issuer name.| No |
| `certManager.issuerRef.kind` | *(empty)* | ==NEW 9.2.0== The supported issuer kinds are ClusterIssuer and Issuer.| No |
| `certManager.issuerRef.group` | *(empty)* | ==NEW 9.2.0== Defines the issuer group.| No |
| `global.tls.enabled` | *(omitted)* | ==NEW 9.1.1== Define the enablement of the TLS.  If omitted, it is enabled. To disable set it to `false`. | No |
| `tls.enabled` | *(omitted)* | ==NEW 9.1.1== Define the enablement of the TLS. If omitted, it is enabled. To disable set it to `false`. This root level dictates enablement or disablement over the global level, while the workload has priority over both.  | No |

<a name="common_fn"></a>^†^ - There is no mechanism to prevent updating any values listed on an existing chart release. Therefore, an attempt to change any marked with an Update Allowed of No will not be prevented, but it will most likely result in the existing release of the chart being rendered unusable.
<a name="common_fn1"></a>^1^ - Updating this value on an existing chart will cause a rolling update of the pods. These values should be updated carefully and with the expectation that service will be impacted. **For values that impact the MaxScale pod, updating this value will cause a service outage while the MaxScale pod is restarted.**
<a name="common_fn2"></a>^2^ - Updating this value triggers a topology morph action.  See [Helm Topology Upgrade](./oam_management_lcm_events_helm.md#helm_topology_upgrade) section for discussion on changing this value.

## Unified Logging Parameters
<a name="logging"></a>

| **Helm Parameter** | **Default** | **Description** | **Update Allowed**[^†^](#common_fn) |
|:----------|:----------|:----------------|:------------------------------------|
| `unifiedLogging.logLevel` | None | ==NEW 9.2.0== Take precedence over global.unifiedLogging.logLevel.  Allowed values are: "OFF", "FATAL ", "ERROR", "WARN", "INFO", "DEBUG", "TRACE", "ALL" | No |
| `unifiedLogging.extension` | None | Map of key/value messages added to each unified log message.<p>Example:</p><p> extension:</p><p>    key1: "val1"</p><p>    key2: "val2"</p> | Yes |
| `unifiedLogging.syslog.enabled` | False | Enable logging to syslog (console logging is always enabled) | [**Yes_**^2^](#logging_fn) |
| `unifiedLogging.syslog.facility` | None | The facility used to send syslog messages | Yes |
| `unifiedLogging.syslog.host` | None | hostname/IP of the syslog server | Yes |
| `unifiedLogging.syslog.port` | None | Listening port of the syslog server | Yes |
| `unifiedLogging.syslog.protocol` | UDP | UDP, TCP or SSL are supported.<p>NOTE: All keyStore/trustStore values must be provided if specifying SSL.</p> | **Yes_** |
| `unifiedLogging.syslog.timeout` | 1000 | SSL connection / handshake timeout (milliseconds)<p>Only valid when protocol is SSL.</p> | Yes |
| `unifiedLogging.syslog.closeReqType` | `GNUTLS_SHUT_RDWR` | SSL close request type (GNUTLS_SHUT_RDWR or GNUTLS_SHUT_WR)<p>*GNUTLS_SHUT_RDWR*: Waits for response before terminating TLS connection. Not supported by all syslog servers.</p><p>*GNUTLS_SHUT_WR*: Client does not wait for response from server when termination TLS connection to syslog server. Can be used in cases where "TLS bye" errors are seen.</p><p>Only valid when protocol is SSL.</p> | Yes |
| `unifiedLogging.syslog.keyStore.secretName` | None | Name of secret containing the keyStore file (PCKS12 format)<p>This secret should be pre-created.</p> | **Yes_** |
| `unifiedLogging.syslog.keyStore.key` | None | Name of key within secret containing the keyStore file (PCKS12 format) | **Yes_** |
| `unifiedLogging.syslog.keyStorePassword.secretName` | None | Name of secret containing the keyStore password<p>This secret should be pre-created.</p> | **Yes_** |
| `unifiedLogging.syslog.keyStorePassword.key` | None | Name of key within secret containing the keyStore password | **Yes_** |
| `unifiedLogging.syslog.trustyStore.secretName` | None | Name of secret containing the trustStore file (PCKS12 format)<p>This secret should be pre-created.</p> | **Yes_** |
| `unifiedLogging.syslog.trustStore.key` | None | Name of key within secret containing the trustStore file (PCKS12 format) | **Yes_** |
| `unifiedLogging.syslog.trustStorePassword.secretName` | None | Name of secret containing the trustStore password<p>This secret should be pre-created.</p> | **Yes_** |
| `unifiedLogging.syslog.trustStorePassword.key` | None | Name of key within secret containing the trustStore password | **Yes_** |
| `unifiedLogging.syslog.rfc.enabled` | None | ==NEW 9.2.0== Enable/disable rfc syslog feature | Yes |
| `unifiedLogging.syslog.rfc.appName` | None | ==NEW 9.2.0== log4j.appender.${APPENDER_ID}.layout.appName | Yes |
| `unifiedLogging.syslog.rfc.procId` | None | ==NEW 9.2.0== log4j.appender.${APPENDER_ID}.layout.procId | Yes |
| `unifiedLogging.syslog.rfc.msgId` | None | ==NEW 9.2.0== log4j.appender.${APPENDER_ID}.layout.msgId | Yes |
| `unifiedLogging.syslog.rfc.version` | None | ==NEW 9.2.0== log4j.appender.${APPENDER_ID}.layout.version | Yes |
| `unifiedLogging.syslog.tls.secretRef.name` | None | ==NEW 9.2.0== Defines the secret name, pointing to a secret object.  The session unifiedLogging.syslog.tls* is replacement for keyStore/keyStorePassword/trustStore/trustStorePassword.  | Yes |
| `unifiedLogging.syslog.tls.keyNames.caCrt` | "ca.crt" for site config, else None | ==NEW 9.2.0== Name of Secret key, which contains CA certificate | Yes |
| `unifiedLogging.syslog.tls.keyNames.tlsKey` | "tls.key" for site config, else None | ==NEW 9.2.0== Name of Secret key, which contains TLS key | Yes |
| `unifiedLogging.syslog.tls.keyNames.tlsCrt` | "tls.crt" for site config, else None | ==NEW 9.2.0== Name of Secret key, which contains TLS certificate | Yes |


<a name="logging_fn"></a>Footnotes:
^2^ - Remote logging for init containers may not be possible when istio is enabled.


## CMDB User Parameters
<a name="helm-users"></a>

Changing these parameters enables you to specify credentials for every built-in CMDB user. For each user, either a `.credentialName` or a `.username` and `.password` can be provided.  All `.password` entries must be base64 encoded.

If a `.credentialName` is provided, the `.username` and `.password.` will be ignored. `.credentialName`s must provide both `username` and `password` keys.

| **Helm Parameter** | **Default** | **Description** | **Update Allowed**[^†^](#common_fn) |
|:----------|:----------|:----------------|:------------------------------------|
| `users.root.credentialName` | *(omitted)* | Secret name in same namespace as chart deployment which provides the **root** user credentials.  The secret must contain the **password** key with the password to assign to the root user. | No |
| `users.root.password` | <Generated\> | The MySQL root user database password to configure (base64 encoded) | No |
| `users.root.allowExternal` | `false` | Boolean. Indicates if root user should be allowed to connect from external hosts (e.g., \'%\') | No |
| `users.replication.credentialName` | *(omitted)* | Secret name in same namespace as chart deployment which provides the **replication** user credentials.  The secret must contain both the **username** and **password** key with the username and password to assign to the replication user, respectively. | No/[Yes^1^](#user_fn) |
| `users.replication.username` | repl@b.c | The MySQL replication user to configure. | No |
| `users.replication.password` | <Generated\> | The MySQL replication user database password to configure (base64 encoded)<p>*Note: The same password must be used at both sites, if geo-redundant* </p>| No/[Yes^1^](#user_fn) |
| `users.mariadbMetrics.credentialName` | *(omitted)* | Secret name in same namespace as chart deployment which provides the `mariadbMetrics` user credentials.  The secret must contain both the **username** and **password** key with the username and password to assign to the mariadb metrics user, respectively. | No |
| `users.mariadbMetrics.username` | exporter | The MySQL metrics user to configure. | No |
| `users.mariadbMetrics.password` | <Generated\> | The MySQL metrics user password to configure (base64 encoded). | No |
| `users.maxscale.credentialName` | *(omitted)* | Secret name in same namespace as chart deployment which provides the **maxscale** user credentials.  The secret must contain both the **username** and **password** key with the username and password to assign to the maxscale user, respectively. | No/[Yes^1^](#user_fn) |
| `users.maxscale.username` | maxscale | The MySQL maxscale user to configure. | No |
| `users.maxscale.password` | <Generated\> | The MySQL maxscale user database password to configure (base64 encoded)<p>*Note: The same password must be used at both sites, if geo-redundant* </p>| No/[Yes^1^](#user_fn) |
| `users.maxscaleMetrics.credentialName` | *(omitted)* | Secret name in same namespace as chart deployment which provides the `maxscaleMetrics` user credentials.  The secret must contain both the **username** and **password** key with the username and password to assign to the maxscale metrics user, respectively. | No |
| `users.maxscaleMetrics.username` | exporter | The MaxScale metrics user to configure. | No |
| `users.maxscaleMetrics.password` | <Generated\> | The MaxScale metrics user password to configure (base64 encoded). | No |

<a name="user_fn"></a>^1^ - Specification of either `credentialName` or definition of a base64 encoded **password** is required for geo-redundant deployment of CMDB.
<a name="oper_fn"></a>^2^ - For operator, username and password must be provided via credentialName.  Specification in spec is not supported.

## CMDB Services Parameters
<a name="helm-services"></a>

| **Helm Parameter** | **Default** | **Description** | **Update Allowed**[^†^](#cmdb_fn) |
|:----------|:----------|:----------------|:----------------------------------|
| `services.mysql.name` | <Chart Release\>-mysql | The name of the Kubernetes Service where Mysql clients can access the database | No |
| `services.mysql.type` | `ClusterIP` | Either ClusterIP or NodePort - depending on if the DB should be accessible only within the cluster or exposed externally, respectively | No |
| services.mysql.rwSplit.enabled<p>services.mysql.rwSplit.tlsPort</p><p>services.mysql.rwSplit.nonTlsPort</p><p>services.mysql.rwSplit.nodePort </p>| true<p>3306</p><p>*(empty)*</p><p>*(empty)* </p>| ==NEW 9.1.1== Enable Read-Write-Split service which will send all write requests to Master node and split read requests to Slave nodes.  Not that this will not ensure attomic-read-write, ie, read after write may return stale data until all slaves updated. `tlsPort` is the TLS enabled port to assign.  If TLS is enabled, `nonTlsPort` can also be provided to support both TLS and non-TLS access simoultaneously. If service.mysql.type is set to NodePort, you can optionally set a specific nodePort to use instead of having on assigned by kubernetes. If not specified, then kubernetes will assign a random port from the nodePort range. | Yes |
| services.mysql.readOnly.enabled<p>services.mysql.readOnly.tlsPort</p><p>services.mysql.readOnly.nonTlsPort</p><p>services.mysql.readOnly.nodePort </p>| false<p>3307</p><p>*(empty)*</p><p>*(empty)* </p>| ==NEW 9.1.1== Enable Read-Only service which will send allow only read requests to Slave nodes. `tlsPort` is the TLS enabled port to assign.  If TLS is enabled, `nonTlsPort` can also be provided to support both TLS and non-TLS access simoultaneously. If service.mysql.type is set to NodePort, you can optionally set a specific nodePort to use instead of having on assigned by kubernetes. If not specified, then kubernetes will assign a random port from the nodePort range. | Yes |
| services.mysql.masterOnly.enabled<p>services.mysql.masterOnly.tlsPort</p><p>services.mysql.masterOnly.nonTlsPort</p><p>services.mysql.masterOnly.nodePort </p>| false<p>3308</p><p>*(empty)*</p><p>*(empty)* </p>| ==NEW 9.1.1== Enable Master-Only service which will send write/read requests only to Master node.  This service will ensure atomic-write-read on all requests. `tlsPort` is the TLS enabled port to assign.  If TLS is enabled, `nonTlsPort` can also be provided to support both TLS and non-TLS access simoultaneously. If service.mysql.type is set to NodePort, you can optionally set a specific nodePort to use instead of having on assigned by kubernetes. If not specified, then kubernetes will assign a random port from the nodePort range. | Yes |
| `services.mysql.ipFamilyPolicy` | *(empty)* | Represents the dual-stack-ness requested or required by the mysql service.  Ref: [IPv4/IPv6 dual-stack](https://kubernetes.io/docs/concepts/services-networking/dual-stack/). | No |
| `services.mysql.ipFamilies` | *(empty)* | List of IP families (eg, IPv4, IPv6) assigned to the mysql service.  Ref: [IPv4/IPv6 dual-stack](https://kubernetes.io/docs/concepts/services-networking/dual-stack/). | No |
| services.mysql.sessionAffinity.enabled<p>services.mysql.sessionAffinity.timeout </p>| false<p>*(omitted)* </p>| Enable mysql service session affinity to ClientIP to ensure that connections from a particular client are passed to the same Pod each time.  A session affinity timeout value (in seconds) can also be provided (defaults to 10800 by kubernetes). | Yes |
| `services.mariadb.enabled` | `false` | Enable per-pod mariadb service for inter-pod communication.  If Istio is enabled, per-pod service is enabled by default and this has no effect. | No |
| `services.mariadb.name` | <Chart Release\>-mariadb-<N> | If Istio is enabled, the name of the Kubernetes Service for the Istio per-pod service. | No |
| `services.mariadb.ipFamilyPolicy` | *(empty)* | Represents the dual-stack-ness requested or required by the mariadb per-pod service.  Ref: [IPv4/IPv6 dual-stack](https://kubernetes.io/docs/concepts/services-networking/dual-stack/). | No |
| `services.mariadb.ipFamilies` | *(empty)* | List of IP families (eg, IPv4, IPv6) assigned to the mariadb per-pod service.  Ref: [IPv4/IPv6 dual-stack](https://kubernetes.io/docs/concepts/services-networking/dual-stack/). | No |
| `services.mariadb.exporter.name` | <Chart Release\>-mariadb-metrics | If mariadb.metrics.enabled is set to `true`, this overrides the Kubernetes Service name be used for metrics collection. | No |
| `services.mariadb.exporter.ipFamilyPolicy` | *(empty)* | Represents the dual-stack-ness requested or required by the mariadb metrics service.  Ref: [IPv4/IPv6 dual-stack](https://kubernetes.io/docs/concepts/services-networking/dual-stack/). | No |
| `services.mariadb.exporter.ipFamilies` | *(empty)* | List of IP families (eg, IPv4, IPv6) assigned to the mariadb metrics service.  Ref: [IPv4/IPv6 dual-stack](https://kubernetes.io/docs/concepts/services-networking/dual-stack/). | No |
| `services.mariadb.exporter.headless.name` | <services.mariadb.exporter.name\>-headless | If mariadb.metrics.enabled is set to `true`, and chart is being installed in an istio environment, this overrides the Kubernetes Headless Service name be used for metrics collection in an istio environment. | No |
| `services.mariadb.exporter.port` | 9104 | If mariadb.metrics.enabled is set to `true`, this port can be configured to define the port which mysqld_exporter will listen to for metrics collection.<p>**NOTE: Renamed from services.mariadb.exporter_port** </p>| Yes |
| `services.maxscale.name` | <Chart Release\>-maxscale | The name of the Kubernetes Service pointing to the leader MaxScale Pod. *(Only relevant in Master-Slave clusters with MaxScale)* | No |
| `services.maxscale.type` | `ClusterIP` | One of ClusterIP, NodePort, IngressConfigMap, or TransportIngress - depending on if the maxctrl interface should be accessible only within the cluster or exposed externally. *(Only relevant in Master-Slave clusters with MaxScale)*. See [Service Exposure](./oam_service_exposure.md) for details. | No |
| `services.maxscale.port` | 8989 | The port for the Kubernetes maxctrl Service. *(Only relevant in clusters with MaxScale and if services.maxscale.enabled is `true`)* | No |
| `services.maxscale.ipFamilyPolicy` | *(empty)* | Represents the dual-stack-ness requested or required by the maxscale service.  Ref: [IPv4/IPv6 dual-stack](https://kubernetes.io/docs/concepts/services-networking/dual-stack/). | No |
| `services.maxscale.ipFamilies` | *(empty)* | List of IP families (eg, IPv4, IPv6) assigned to the maxscale service.  Ref: [IPv4/IPv6 dual-stack](https://kubernetes.io/docs/concepts/services-networking/dual-stack/). | No |
| `services.maxscale.nodePort` | *(omitted)* | If service.maxscale.type is set to NodePort, you can optionally set a specific nodePort to use instead of having on assigned by kubernetes. If not specified, then kubernetes will assign a random port from the nodePort range.  For operator, this also sets the IngressConfigMap or TransportIngress port number. | No |
| `services.maxscale.citmIngress.configMapName` | *(omitted)* | If service.maxscale.type is set to IngressConfigMap, this sets the prefix name of the ConfigMap so that it can be found by CITM (or an equivalent ingress controller). The ConfigMap name suffix is services.maxscale.name. Required if services.maxscale.type is IngressConfigMap.  See [Service Exposure](./oam_service_exposure.md) for details | Yes |
| `services.maxscale.citmIngress.port` | *(omitted)* | If service.maxscale.type is set to IngressConfigMap, this sets the ingress port for the service on the Edge node(s). Required if services.maxscale.type is IngressConfigMap.  See [Service Exposure](./oam_service_exposure.md) for details | Yes |
| `services.maxscale.citmIngress.keywords` | *(omitted)* | If service.maxscale.type is set to IngressConfigMap, this sets the keywords to add for TCP ingress configuration. For example, to add support for TLS termination at the stream level, set keywords to "STREAM-SSL". | Yes |
| `services.maxscale.csfTransportIngress.name` | <Same as services.maxscale.name\> | If service.maxscale.type is set to TransportIngress, this sets the name of the TransportIngress. Optional, and only applicable if services.maxscale.type is TransportIngress.  See [Service Exposure](./oam_service_exposure.md) for details | Yes |
| `services.maxscale.csfTransportIngress.port` | *(omitted)* | If service.maxscale.type is set to TransportIngress, this sets the ingress port for the service on the Edge node(s). Required if services.maxscale.type is TransportIngress.  See [Service Exposure](./oam_service_exposure.md) for details | Yes |
| `services.maxscale.exporter.name` | <Chart Release\>-maxscale-metrics | If maxscale.metrics.enabled is set to `true`, this overrides the Kubernetes Service name be used for metrics collection. | No |
| `services.maxscale.exporter.ipFamilyPolicy` | *(empty)* | Represents the dual-stack-ness requested or required by the maxscale metrics service.  Ref: [IPv4/IPv6 dual-stack](https://kubernetes.io/docs/concepts/services-networking/dual-stack/). | No |
| `services.maxscale.ipFamilies` | *(empty)* | List of IP families (eg, IPv4, IPv6) assigned to the maxscale metrics service.  Ref: [IPv4/IPv6 dual-stack](https://kubernetes.io/docs/concepts/services-networking/dual-stack/). | No |
| `services.maxscale.exporter.headless.name` | <services.maxscale.exporter.name>-headless | If maxscale.metrics.enabled is set to `true`, and chart is being installed in an istio environment, this overrides the Kubernetes Headless Service name be used for metrics collection in an istio environment. | No |
| `services.maxscale.exporter.port` | 9195 | If maxscale.metrics.enabled is set to `true`, this port can be configured to define the port which maxscale_exporter will listen to for metrics collection.<p>**NOTE: Renamed from services.maxscale.exporter_port** </p>| Yes |
| `services.mariadb_master.name` | <Chart Release\>-mariadb-master | The name of the Kubernetes Service pointing to the Master Pod. *(Only relevant in Master-Slave clusters with MaxScale)* | No |
| `services.mariadb_master.type` | `NodePort` | One of ClusterIP, NodePort, IngressConfigMap, or TransportIngress - depending on the type of service exposure being used. *(Only relevant in Master-Slave clusters with MaxScale)*. See [Service Exposure](./oam_service_exposure.md) for details. | No |
| `services.mariadb_master.port` | 3306 | The port for the Kubernetes Service pointing to the Master Pod. *(Only relevant in clusters with MaxScale and if services.maxscale.enabled is `true`)* | No |
| `services.mariadb_master.ipFamilyPolicy` | *(empty)* | Represents the dual-stack-ness requested or required by the mariadb master service.  Ref: [IPv4/IPv6 dual-stack](https://kubernetes.io/docs/concepts/services-networking/dual-stack/). | No |
| `services.mariadb_master.ipFamilies` | *(empty)* | List of IP families (eg, IPv4, IPv6) assigned to the mariadb master service.  Ref: [IPv4/IPv6 dual-stack](https://kubernetes.io/docs/concepts/services-networking/dual-stack/). | No |
| `services.mariadb_master.nodePort` | *(omitted)* | Can optionally set a specific nodePort to use instead of having on assigned by kubernetes. If not specified, then kubernetes will assign a random port from the nodePort range.  For operator, this also sets the IngressConfigMap or TransportIngress port number. | No |
| `services.mariadb_master.citmIngress.configMapName` | *(omitted)* | If service.mariadb_master.type is set to IngressConfigMap, this sets the prefix name of the ConfigMap so that it can be found by CITM (or an equivalent ingress controller). The ConfigMap name suffix is services.mariadb_master.name. Required if services.mariadb_master.type is IngressConfigMap.  See [Service Exposure](./oam_service_exposure.md) for details | Yes |
| `services.mariadb_master.citmIngress.port` | *(omitted)* | If service.mariadb_master.type is set to IngressConfigMap, this sets the ingress port for the service on the Edge node(s). Required if services.mariadb_master.type is IngressConfigMap.  See [Service Exposure](./oam_service_exposure.md) for details | Yes |
| `services.mariadb_master.citmIngress.keywords` | *(omitted)* | If service.mariadb_master.type is set to IngressConfigMap, this sets the keywords to add for TCP ingress configuration. For example, to add support for TLS termination at the stream level, set keywords to "STREAM-SSL". | Yes |
| `services.mariadb_master.csfTransportIngress.name` | <Same as services.mariadb_master.name\> | If service.mariadb_master.type is set to TransportIngress, this sets the name of the TransportIngress. Optional, and only applicable if services.mariadb_master.type is TransportIngress.  See [Service Exposure](./oam_service_exposure.md) for details | Yes |
| `services.mariadb_master.csfTransportIngress.port` | *(omitted)* | If service.mariadb_master.type is set to TransportIngress, this sets the ingress port for the service on the Edge node(s). Required if services.mariadb_master.type is TransportIngress.  See [Service Exposure](./oam_service_exposure.md) for details | Yes |
| `services.admin.name` | <Chart Release\>-admin | The name of the Kubernetes Service pointing to the Admin Pod. *(Not relevant in simplex deployments).* | No |
| `services.admin.type` | `ClusterIP` | Either ClusterIP or NodePort - depending on if the Admin container should be accessible only within the cluster or exposed externally, respectively. Should not need to change this from ClusterIP. *(Not relevant in simplex deployments).* | No |
| `services.admin.ipFamilyPolicy` | *(empty)* | Represents the dual-stack-ness requested or required by the admin service.  Ref: [IPv4/IPv6 dual-stack](https://kubernetes.io/docs/concepts/services-networking/dual-stack/). | No |
| `services.admin.ipFamilies` | *(empty)* | List of IP families (eg, IPv4, IPv6) assigned to the admin service.  Ref: [IPv4/IPv6 dual-stack](https://kubernetes.io/docs/concepts/services-networking/dual-stack/). | No |

<a name="cmdb_fn"></a>^†^ - There is no mechanism to prevent updating any values listed on an existing chart release. Therefore, an attempt to change any marked with an Update Allowed of No will not be prevented, but it will most likely result in the existing release of the chart being rendered unusable.

## MariaDB Clients Certificate Parameters
<a name="helm-client-certs"></a>

| **Helm Parameter** | **Default** | **Description** | **Update Allowed**[^†^](#mariadb_fn) |
|:----------|:----------|:----------------|:-------------------------------------|
| `clients.mariadb.tls.secretRef.name` | *(omitted)* | Two interfaces are supported as specified by the clients.mariadb.tls.secretRef.name value, which must be one of these values:<br>1. none (or empty) = No certificates or Automatically generated certificates by cmgr when certManager.enabled and mariadb.certificate.enabled are `true` <br>2. <secret\> = Manually supplied certificates. This is the name of the kubernetes <secret\> which contains the six CA certificate files provided in the clients.mariadb.tls.secretRef.keyNames and mariadb.tls.secretRef.keyNames sections <br> The secret value may be a 'go template' string that resolves to the name of the kubernetes secret. | No |
| clients.mariadb.tls.secretRef.keyNames.caCrt<p>clients.mariadb.tls.secretRef.keyNames.tlsCrt</p><p>clients.mariadb.tls.secretRef.keyNames.tlsKey </p>| "ca.crt"<p>"tls.crt"</p><p>"tls.key" </p>| The specific client certificate keys in the secret, either from the manually created secret given in clients.mariadb.tls.secretRef.name (should be the created file names), or via CMGR (defaults). | No |
| `clients.mariadb.tls.secretRef.polling` | 3600 | This parameter defines the number of seconds the certificate is checked by the mariadb monitor. The mariadb monitor is scheduled to run every 10 seconds, which is the smallest this param can be. The value of 3600 seconds (once an hour) is the default rate. | Yes |
| `clients.mariadb.tls.secretRef.threshold` | 7 | If greater than zero, a Minor alarm is generated if the certificate is about to expire in the specified number of days (default 7). A Major alarm is generated when the certificate is expired. The zero value disables certificate alarming.  | Yes |

## MariaDB Database Parameters
<a name="helm-mariadb"></a>

| **Helm Parameter** | **Default** | **Description** | **Update Allowed**[^†^](#mariadb_fn) |
|:----------|:----------|:----------------|:-------------------------------------|
| `mariadb.image.registry` | global.registry | The registry (global.registry override) to use for pulling the MariaDB container image. | [Yes^1^](#mariadb_fn1) |
| `mariadb.image.name` | cmdb/mariadb | The docker image to use for the MariaDB containers | [Yes^1^](#mariadb_fn1) |
| `mariadb.image.tag` | <Version\> | The docker image tag to use for the MariaDB containers | [Yes^1^](#mariadb_fn1) |
| `mariadb.image.flavor` | imageFlavor | The image flavor (rocky, centos7) to use for the MariaDB containers. This takes precedence over imageFlavor and global.imageFlavor | [Yes^1^](#mariadb_fn1) |
| `mariadb.image.flavorPolicy` | `BestMatch` | ==NEW 9.1.1== The policy which container image flavor should be based on. Options are: (Strict/BestMatch), with default BestMatch. This takes precedence over imageFlavorPolicy and global.imageFlavorPolicy | [Yes^1^](#mariadb_fn1) |
| `mariadb.image.pullPolicy` | IfNotPresent | The policy used to determine when to pull a new image from the docker registry | [Yes^1^](#mariadb_fn1) |
| `mariadb.imagePullSecrets` | *(omitted)* | Specify the Secrets for the MariaDB pod to be used for pulling registry images from a secured registry. | Yes |
| `mariadb.labels` | *(empty)* | Specify the customized labels to assign to every created mariadb resource. | Yes |
| `mariadb.annotations` | *(empty)* | Specify the customized annotations to assign to every created mariadb resource. | No |
| `mariadb.podSecurityContext` | runAsUser: 1771<p>runAsGroup: 1771</p><p>fsGroup: 1771 </p>| securityContext override for mariadb pods. The default values will be used to set pod securityContext unless "podSecurityContext.disabled" is set to `true` | No |
| `mariadb.containerSecurityContext` | runAsUser: 1771<p>runAsGroup: 1771</p><p>readdOnlyRootFilesystem: true </p>| securityContext override for mariadb and init containers. The default values will be used to set container securityContext unless "containerSecurityContext.disabled" is set to `true`. | No |
| `mariadb.count` | 3 | The number of MariaDB pods to create if **mariadb.hpa.enabled**=false. Depends on `cluster_type` (See [Docker Configuration](./oam_configure_docker.md)) | [Yes^1,2^](#mariadb_fn1) |
| `mariadb.hpa.enabled` | `false` | Specifies Horizontal Pod Autoscaling (HPA) should be enabled for mariadb statefulset. If HPA to be enabled, mariadb.count/replicas will be ignored and minimum and maximum number of replicase should be set. (see below). Ref: [HorizontalPodAutoscaler Walkthrough](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/) | Yes |
| `mariadb.hpa.minReplicas` | 3 | Specifies the minimum number of pods that HPA will be allowed to scale-down to. | Yes |
| `mariadb.hpa.maxReplicas` | 9 | Specifies the maximum number of pods that HPA will be allowed to scale-up to. | Yes |
| `mariadb.hpa.predefinedMetrics.enabled` | `true` | Specifies if pre-defined metrics should be enabled for mariadb pods. Pre-defined metrics provides a simple specification for average CPU/memory utiliczation across all containers in a pod. | Yes |
| `mariadb.hpa.predefinedMetrics.averageCPUThreshold` | 80 | Specifies the pre-defined average CPU utilization metric. | Yes |
| `mariadb.hpa.predefinedMetrics.averageMemoryThreshold` | 80 | Specifies the pre-defined average memory utilization metric. | Yes |
| `mariadb.hpa.metrics` | *(empty)* | Specifies the metrics to be used for auto-scaling.  Ref: [Support for resource metrics](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#support-for-resource-metrics). | Yes |
| mariadb.hpa.behavior.scaleDown.stabilizationWindowSeconds<p>mariadb.hpa.behavior.scaleDown.selectPolicy</p><p>mariadb.hpa.behavior.policies </p>| 300<p>*(kubernetes default)*</p><p>2 Pods / 30 seconds </p>| Specifies the scale-down behavior.  See [Configurable scaling behavior](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#configurable-scaling-behavior) for descriptions and kubernetes default values. | Yes |
| mariadb.hpa.behavior.scaleUp.stabilizationWindowSeconds<p>mariadb.hpa.behavior.scaleUp.selectPolicy</p><p>mariadb.hpa.behavior.policies </p>| 30<p>*(kubernetes default)*</p><p>2 Pods / 300 seconds </p>| Specifies the scale-down behavior.  See [Configurable scaling behavior](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#configurable-scaling-behavior) for descriptions and kubernetes default values. | Yes |
| `mariadb.pdb.enabled` | `true` | Indicates if the PodDisruptionBudget (PDB) is enabled for the pods in the mariadb statefulset.  Ref: [kubernetes.io Specifying a Disruption Budget for your Application](https://kubernetes.io/docs/tasks/run-application/configure-pdb/). | Yes |
| `mariadb.pdb.minAvailable` | 50% | The number of pods from that set that must still be available after the eviction, even in the absence of the evicted pod. minAvailable can be either an absolute number or a percentage.  Ref: [kubernetes.io Specifying a Disruption Budget for your Application](https://kubernetes.io/docs/tasks/run-application/configure-pdb/). Only used if mariadb.pdb.enabled=true.  | Yes |
| `mariadb.pdb.maxUnavailable` | *(omitted)* | The number of pods from that set that can be unavailable after the eviction. It can be either an absolute number or a percentage.  Ref: [kubernetes.io Specifying a Disruption Budget for your Application](https://kubernetes.io/docs/tasks/run-application/configure-pdb/). Only used if mariadb.pdb.enabled=true.  | Yes |
| `mariadb.heuristic_recover` | none<p>rollback (galera) </p>| Indicates the type of tc-heurisic-recover that should take place automatically on pod restarts. Valid values are rollback (default), commit, and none (disable automatic heuristic recovery).<p>Defaults to rollback for non-simplex deployments, defaults to none for simplex deployments. </p>| Yes |
| `mariadb.clean_log_interval` | 3600 | Defines the interval (in seconds) that the Master of a replication cluster will clean-up old binlog files. | Yes |
| `mariadb.mysqldOpts` | *(omitted)* | Additional command line arguments to feed to mysqld (mariadb) process.  See [mysqld Options](https://mariadb.com/kb/en/mysqld-options/) for full list of mysqld options. | [Yes^1^](#mariadb_fn1) |
| `mariadb.mysqld_site_conf` | \[myslqd\]<p>userstat = on </p>| Additional configuration contents to place in a mysql site configuration file on the MariaDB containers.  See [Server System Variables](https://mariadb.com/kb/en/server-system-variables/) for full list of MariaDB system variables that can be configured.  | Yes |
| `mariadb.serverIdPrefix` | *(omitted)* | Defines a standard prefix to use for assignment of server_id for each local mariadb pod.  The server_id uniquely identifies the server instance in the community of replication partners, which includes both local and geo-redundant remote data center servers.  If not defined, a random unsigned integer will be assigned to each server. | No |
| `mariadb.audit_logging.enabled` | `true` | Boolean. Indicates if server audit logging should be enabled by default. | Yes |
| `mariadb.audit_logging.events` | CONNECT,QUERY_DCL,QUERY_DDL | Indicates the server events that will be logged if audit_logging is enabled. See [MariaDB Audit Plugin - Log Settings](https://mariadb.com/kb/en/library/mariadb-audit-plugin-log-settings/) for details on logging events that can be set. | Yes |
| `mariadb.tls.enabled` | *(omitted)* | Indicates if TLS/SSL is to be configured to encrypt data in flight to clients as well as enable/disable SSL for replication traffic. If omitted, it is enabled. ==If upgrading from old release where TLS is not enabled, this should be set to `false`==. Setting this to `true` will automatically add the ssl_cipher TLSv1.2/TLS1.3 to mariadb configuration and will automatically add REQUIRE SSL to all user grants. | [Yes^7^](#mariadb_upd)<p> </p>|
| `mariadb.tls.secretRef.name` | *(omitted)* | Two interfaces are supported as specified by the mariadb.tls.secretRef.name value, which must be one of these values:<br>1. none (or empty) = No certificates or Automatically generated certificates by cmgr when certManager.enabled and mariadb.certificate.enabled are `true` <br>2. <secret\> = Manually supplied certificates. This is the name of the kubernetes <secret\> which contains the six CA certificate files provided in the clients.mariadb.tls.secretRef.keyNames and mariadb.tls.secretRef.keyNames sections <br> The secret value may be a 'go template' string that resolves to the name of the kubernetes secret. | [Procedure^3^](#mariadb_fn3) |
| mariadb.tls.secretRef.keyNames.caCrt<p>mariadb.tls.secretRef.keyNames.tlsCrt</p><p>mariadb.tls.secretRef.keyNames.tlsKey </p>| "ca.crt"<p>"tls.crt"</p><p>"tls.key" </p>| The specific server certificate keys in the secret, either from the manually created secret given in mariadb.tls.secretRef.name (should be the created file names), or via CMGR (defaults). | [Procedure^3^](#mariadb_fn3) |
| `mariadb.encryption.enabled` | `false` | Boolean. Indicates whether data-at-rest encryption should be configured in the database nodes. | No |
| `mariadb.encryption.secret` | *(omitted)* | Specifies the name of the secret that holds the keyfile and the keyfile key. See [Data-At-Rest Encryption](./oam_data_at_rest_encrypt.md) for details. | No |
| `mariadb.encryption.KeyFile` | *(omitted)* | Specifies the name of the Key File stored in the kube secret. This value is used to encrypt/decrypt the database. | No |
| `mariadb.encryption.KeyFileKey` | *(omitted)* | Specifies the name of the file that holds the key to decrypt the keyfile. This is required only if the keyfile is encrypted. This value is not required if the keyFile is plain-text. | No |
| `mariadb.encryption.keyFileId` | 1 | Specifies a particular key in the Key File. If not present, then assume keyid "1". | No |
| `mariadb.persistence.size` | `20Gi` | The size of the volume to attach to the MariaDB pods (database storage size) | No |
| `mariadb.persistence.storageClass` | *(omitted)* | The Kubernetes Storage Class for the database persistent volume. Default is to use the kubernetes default storage class. | No |
| `mariadb.persistence.accessMode` | `ReadWriteOnce` | The Kubernetes Access Mode for the mariadb data persistent volume. By default, the volume is mounted as read-write by a single node. | No |
| `mariadb.persistence.preserve_pvc` | `false` | Boolean. Indicates if the Persistent Volumes for database should be preserved when the chart is deleted. | Yes |
| `mariadb.persistence.nearFullPercent` | 85 | Specify a major alarm threshold which indicates the database data disk is near full. | [Yes^6^](#mariadb_fn4) |
| `mariadb.persistence.fullPercent` | 95 | Specify a critical alarm threshold which indicates the database data disk is full. | [Yes^6^](#mariadb_fn4) |
| `mariadb.persistence.denyWritePercent` | 98 | ==NEW 9.3.0== Specify a threshold when MaxScale will remove Master status (thus denying writes) from a Master server, or places a Slave server in Maintenance state. | [Yes^8^](#maxscale_fn1) |
| `mariadb.persistence.backup.enabled` | `true` | Boolean. Indicates whether separate \"backup\" volume should be attached to the MariaDB pods. This should be enabled when CBUR is enabled to perform backup/restore operations. All other variables in the mariadb.persistence.backup section will be ignored unless this is set to `true`. | No |
| `mariadb.persistence.backup.size` | `20Gi` | The size of the backup volume to attach to the MariaDB pods. As a general rule, backup volume size should be the same as the mariadb data volume size (mariabackup copies files from data dir into backup dir). | No |
| `mariadb.persistence.backup.storageClass` | *(omitted)* | The Kubernetes Storage Class for the backup persistent volume. Default is to use the kubernetes default storage class. | No |
| `mariadb.persistence.backup.accessMode` | `ReadWriteOnce` | The Kubernetes Access Mode for the mariadb backup persistent volume. By default, the volume is mounted as read-write by a single node. | No |
| `mariadb.persistence.backup.dir` | /mariadb/backup | The directory to use for backup/restore local to the pod. | Yes |
| `mariadb.persistence.temp.enabled` | `false` | Boolean. Indicates whether separate \"temp\" volume should be attached to the MariaDB pods. This is used for mariadb temp file system space and will automatically configure the [tmpdir](https://mariadb.com/kb/en/server-system-variables/#tmpdir) config variable to point to this mount. This is needed when applications perform certain actions (eg. complicated ALTER table) which require large amount of temp file system space. All other variables in the mariadb.persistence.temp section will be ignored unless this is set to `true`. | No |
| `mariadb.persistence.temp.size` | `5Gi` | The size of the temp volume to attach to the MariaDB pods.  Size requirements are application dependent. | No |
| `mariadb.persistence.temp.storageClass` | *(omitted)* | The Kubernetes Storage Class for the temp persistent volume. Default is to use the kubernetes default storage class. | No |
| `mariadb.persistence.temp.accessMode` | `ReadWriteOnce` | The Kubernetes Access Mode for the mariadb temp persistent volume. By default, the volume is mounted as read-write by a single node. | No |
| `mariadb.persistence.temp.dir` | /mariadb/tmp | The mount directory for the temp persistent volume. The [tmpdir](https://mariadb.com/kb/en/server-system-variables/#tmpdir) config variable will be set to this value. | No |
| `mariadb.persistence.shared.enabled` | `false` | Boolean. **Use at your own risk.** Indicates whether a user supplied shared storage PVC should be mounted on *all* mariadb pod(s). It is the applications responsibility to ensure that the storage type being used is capable of being attached to multiple pods.  If not, then only one pod will successfully start.  All other variables in the mariadb.persistence.shared section will be ignored unless this is set to `true`. | No |
| `mariadb.persistence.shared.name` | *(omitted)* | The kubernetes Persistent Volume Claim (PVC) name for the resource to be mounted as shared storage. The PVC should be in the same namespace as the pods it will be mounted on. | No |
| `mariadb.persistence.shared.dir` | /mariadb/shared | The mount directory for the shared PVC. | No |
| `mariadb.initdbConfigMap` | *(omitted)* | ConfigMap which will be mounted to /import/initdb.d on mariadb pod container, allowing for import of user-defined shell and SQL to be injected on initial database creation. | No |
| mariadb.databases<p>mariadb.databases\[\*\].name</p><p>mariadb.databases\[\*\].character_set</p><p>mariadb.databases\[\*\].collate </p>| <None\> | A list of databases to create. .name is required; .character_set and .collate are optional. Example:<p>mariadb:</p><p>  databases:</p><p>    -name: mydb</p><p>    -name: anotherdb</p><p>    character_set: keybcs2 </p>| No |
| mariadb.users<p>mariadb.users\[\*\].credentialName</p><p>mariadb.users\[\*\].name</p><p>mariadb.users\[\*\].password</p><p>mariadb.users\[\*\].host</p><p>mariadb.users\[\*\].privilege</p><p>mariadb.users\[\*\].object</p><p>mariadb.users\[\*\].requires</p><p>mariadb.users\[\*\].with </p>| <None\> | A list of users to create. Either **.credentialName** or user **.name**/**.password** must be provided.<p>If **.credentialName** is provided, it must reference a secret in the same namespace as the chart being installed which contains all the user attributes.<p>If a  **.password** is provided, it must be base64 encoded. The value may be either an encoded password string, or a 'go template' string that resolves to an encoded password. An example 'go template' string is "{{ .Values.global.clustername \| b64enc }}". When using a 'go template' string, the quotes are required. <p>Note: **.with** is used to construct a GRANT SQL statement to grant permissions to the new user. See [MariaDB GRANT Syntax](https://mariadb.com/kb/en/library/grant/) for details. Operator only supports credentialName. | No |
| mariadb.resources.requests.cpu<p>mariadb.resources.requests.memory</p><p>mariadb.resources.requests.ephemeral-storage </p>| cpu=250m, memory=256Mi, ephemeral-storage=1Gi | The Kubernetes Memory and CPU resource requests for the MariaDB pods (See [K8s documentation](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#how-pods-with-resource-requests-are-scheduled)) | [Yes^1^](#mariadb_fn1) |
| mariadb.resources.limits._cpu ==NEW 9.0.0== <p>mariadb.resources.limits.cpu</p><p>mariadb.resources.limits.memory</p><p>mariadb.resources.limits.ephemeral-storage </p>| _cpu=1,cpu=, memory=768Mi, ephemeral-storage=1Gi | The Kubernetes Memory and CPU resource limits for the MariaDB pods (See [K8s documentation](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#how-pods-with-resource-requests-are-scheduled)) | [Yes^1^](#mariadb_fn1) |
| mariadb.startupProbe.initialDelaySeconds<p>mariadb.startupProbe.periodSeconds</p><p>mariadb.startupProbe.timeoutSeconds</p><p>mariadb.startupProbe.failureThreshold</p><p>mariadb.startupProbe.successThreshold </p>| 1<p>5</p><p>1</p><p>60</p><p>1 </p>| The Kubernetes startup probe configuration for the MariaDB container (See [K8s documentation](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes)) | [Yes^1^](#mariadb_fn1) |
| mariadb.livenessProbe.initialDelaySeconds<p>mariadb.livenessProbe.periodSeconds</p><p>mariadb.livenessProbe.timeoutSeconds</p><p>mariadb.livenessProbe.failureThreshold</p><p>mariadb.livenessProbe.successThreshold </p>| 120<p>10</p><p>5</p><p>6</p><p>1 </p>| The Kubernetes liveness probe configuration for the MariaDB container (See [K8s documentation](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes)). | [Yes^1^](#mariadb_fn1) |
| mariadb.readinessProbe.initialDelaySeconds<p>mariadb.readinessProbe.periodSeconds</p><p>mariadb.readinessProbe.timeoutSeconds</p><p>mariadb.readinessProbe.failureThreshold</p><p>mariadb.readinessProbe.successThreshold </p>| 10<p>15</p><p>1</p><p>3</p><p>1 </p>| The Kubernetes readiness probe configuration for the MariaDB container (See [K8s documentation](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes)). | [Yes^1^](#mariadb_fn1) |
| `mariadb.terminationGracePeriodSeconds` | 60 | Defines the grace period for termination of mariadb pods. | Yes |
| `mariadb.tolerations` | *(empty)* | Node tolerations for mariadb scheduling to nodes with taints. Ref: [kubernetes.io Taints and Tolerations](https://kubernetes.io/docs/concepts/configuration/taint-and-tolerations/). Use with caution. | No |
| `mariadb.nodeSelector` | *(empty)* | Node labels for mariadb pod assignment. Ref: [kubernetes.io Node Selector](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/\#nodeselector) Use with caution.<p>**`Note`**: This option is mutually exclusive with mariadb.nodeAffinity. </p>| No |
| `mariadb.topologySpreadConstraints` | *(empty)* | topologySpreadConstraints allow control of how Pods are spread across cluster among failure-domains such as regions, zones, nodes, and other user-defined topology domains. This can help to achieve high availability as well as efficient resource utilization.  Ref: [kubernetes.io Pod Topology Spread Constraints](https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/).<p>**`Note`**: Do not specify `labelSelector` as it will be automatically set by chart to correctly select all mariadb pods for the cluster.  </p>| No |
| mariadb.nodeAffinity.enabled<p>mariadb.nodeAffinity.key</p><p>mariadb.nodeAffinity.value </p>| true<p>is_worker</p><p>true </p>| Node affinity key in BCMT for the mariadb pods. This should not be changed and will bind the mariadb databases pods to the worker nodes.<p>mariadb.nodeAffinity.enable was added to allow the user to disable this feature.</p><p>**`Note`**: This option is mutually exclusive with mariadb.nodeSelector. </p>| No |
| `mariadb.podAntiAffinity.zone.type` | *(omitted)* | ==NEW 9.2.0== Specify pod anti-affinity zone type, allowed values: soft, hard, none | Yes |
| `mariadb.podAntiAffinity.zone.topologyKey` | `topology.kubernetes.io/zone` | ==NEW 9.2.0== Specify pod anti-affinity zone topologyKey | Yes |
| `mariadb.podAntiAffinity.node.type` | *(omitted)* | ==NEW 9.2.0== Specify pod anti-affinity node type, allowed values: soft, hard, none  | Yes |
| `mariadb.podAntiAffinity.node.topologyKey` | `kubernetes.io/hostname` |==NEW 9.2.0== Specify pod anti-affinity node topologyKey | Yes |
| `mariadb.podAntiAffinity.customRules` | *(omitted)* | ==NEW 9.2.0== Specify the set of customized rules for pod anti-affinity | Yes |
| `mariadb.priorityClassName` | global.priorityClassName | The kubernetes Pod priority and preemption class name. Ref: [kubernetes.io Pod Priority Preemption](https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/) | No |
| mariadb.initContainers.resources.requests.cpu<p>mariadb.initContainers.resources.requests.memory</p><p>mariadb.initContainers.resources.requests.ephemeral-storage </p>| cpu=100m, memory=64Mi, ephemeral-storage=64Mi | The Kubernetes Memory and CPU resource requests for the mariadb pod initContainer container (See [K8s documentation](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#how-pods-with-resource-requests-are-scheduled)) | [Yes^1^](#mariadb_fn1) |
| mariadb.initContainers.resources.limits._cpu ==NEW 9.0.0== <p>mariadb.initContainers.resources.limits.cpu</p><p>mariadb.initContainers.resources.limits.memory</p><p>mariadb.initContainers.resources.limits.ephemeral-storage </p>| <Equal to Requests\> except '_cpu=100m,cpu=' | The Kubernetes Memory and CPU resource limits for the mariadb pod metrics container (See [K8s documentation](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#how-pods-with-resource-requests-are-scheduled)) | [Yes^1^](#mariadb_fn1) |
| `mariadb.metrics.enabled` | `false` | Boolean. Indicates if the mariadb metrics sidecar container should be enabled. | [Yes^1^](#mariadb_fn1)[^,7^](#mariadb_upd) |
| `mariadb.metrics.image.registry` | <global.registry1\> | The registry (global.registry1 override) to use for pulling the MariaDB metrics container image. | [Yes^1^](#mariadb_fn1) |
| `mariadb.metrics.image.name` | cmdb/mysqld-exporter | The docker image to use for the mariadb metrics containers.  CMDB now releases the mysqld-exporter docker image. | [Yes^1^](#mariadb_fn1) |
| `mariadb.metrics.image.tag` | 0.13.0-5.181.el7 | The docker image tag to use for the mariadb metrics containers | [Yes^1^](#mariadb_fn1) |
| `mariadb.metrics.image.flavor` | imageFlavor | The image flavor (rocky, centos7) to use for the MariaDB metrics container | [Yes^1^](#mariadb_fn1) |
| `mariadb.metrics.image.pullPolicy` | IfNotPresent | The policy used to determine when to pull a new image from the docker registry | [Yes^1^](#mariadb_fn1) |
| `mariadb.metrics.containerSecurityContext` | runAsUser: 1773<p>runAsGroup: 1773</p><p>readOnlyRootFileSystem: true</p><p>allowPrivilegeEscalation: false </p>| securityContext override for metrics container in mariadb pods. The default values will be used to set container securityContext unless "containerSecurityContext.disabled" is set to `true`. Added support for read-only root filesystem (e.g., Amazon EKS). | No |
| mariadb.metrics.resources.requests.cpu<p>mariadb.metrics.resources.requests.memory</p><p>mariadb.meterics.resources.requests.ephemeral-storage </p>| cpu=250m, memory=256Mi, ephemeral-storage=128Mi | The Kubernetes Memory and CPU resource requests for the mariadb pod metrics container (See [K8s documentation](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#how-pods-with-resource-requests-are-scheduled)) | [Yes^1^](#mariadb_fn1) |
| mariadb.metrics.resources.limits._cpu ==NEW 9.0.0== <p>mariadb.metrics.resources.limits.cpu</p><p>mariadb.metrics.resources.limits.memory</p><p>mariadb.metrics.resources.limits.ephemeral-storage </p>| <Equal to Requests\> except '_cpu=250m,cpu=' | The Kubernetes Memory and CPU resource limits for the mariadb pod metrics container (See [K8s documentation](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#how-pods-with-resource-requests-are-scheduled)) | [Yes^1^](#mariadb_fn1) |
| `mariadb.auth.enabled` | `false` | Set to `true` to enable zt-proxy metrics authentication sidecar in the mariadb statefulset. | Yes |
| `mariadb.auth.image.registry` | <global.registry\> | The registry (global.registry override) to use for pulling the mariadb auth container image. | [Yes^1^](#mariadb_fn1) |
| `mariadb.auth.image.name` | osdb/csfdb-zt-proxy | The docker image to use for the mariadb auth containers | [Yes^1^](#mariadb_fn1) |
| `mariadb.auth.image.tag` | 1.0-1-8 | The docker image tag to use for the mariadb auth containers | [Yes^1^](#mariadb_fn1) |
| `mariadb.auth.image.flavor` | rocky8 | The image flavor to use for the WoRKLOaD auth containers | [Yes^1^](#mariadb_fn1) |
| `mariadb.auth.image.pullPolicy` | IfNotPresent | The policy used to determine when to pull a new image from the docker registry | [Yes^1^](#mariadb_fn1) |
| `mariadb.auth.containerSecurityContext` | runAsUser: 1771<p>runAsGroup: 1771</p><p>readOnlyRootFilesystem: true</p><p>allowPrivilegeEscalation: false </p>| securityContext override for auth container in mariadb pods. The default values will be used to set container securityContext unless "containerSecurityContext.disabled" is set to `true`. | No |
| mariadb.auth.resources.requests.cpu<p>mariadb.auth.resources.requests.memory</p><p>mariadb.auth.resources.requests.ephemeral-storage </p>| cpu=250m, memory=256Mi, ephemeral-storage=128Mi | The Kubernetes Memory and CPU resource requests for the mariadb pod auth container (See [K8s documentation](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#how-pods-with-resource-requests-are-scheduled)) | [Yes^1^](#mariadb_fn1) |
| mariadb.auth.resources.limits._cpu ==NEW 9.0.0== <p>mariadb.auth.resources.limits.cpu</p><p>mariadb.auth.resources.limits.memory</p><p>mariadb.auth.resources.limits.ephemeral-storage </p>| <Equal to Requests\> except '_cpu=250m, cpu=' | The Kubernetes Memory and CPU resource limits for the mariadb pod auth container (See [K8s documentation](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#how-pods-with-resource-requests-are-scheduled)) | [Yes^1^](#mariadb_fn1) |
| `mariadb.auth.secretRef.name` | *(empty)* | The OpenID Connect (OIDC) secret name required if OIDC authentication to be enabled. | Yes |
| `mariadb.auth.skipVerifyInsecure` | `true` | Skip certificate verification with authentication server (insecure mode) | Yes |
| `mariadb.auth.tls.secretRef.name` | *(omitted)* | If prometheus is configured to use TLS for scrape, then the certificates used to authenticate the scrape request must be provided in this secret.  The secret resource containing all the certificate files must be pre-populated before CMDB deployment. | Yes |
| mariadb.auth.tls.secretRef.server_ca_cert<p>mariadb.auth.tls.secretRef.server_cert</p><p>mariadb.auth.tls.secretRef.server_key </p>| prom-server-ca-cert.pem<p>prom-server-cert.pem</p><p>prom-server-key.pem </p>| The specific server certificate file names defined in the **mariadb.auth.tls.secretRef.name**. | Yes |
| `mariadb.dashboard.enabled` | `false` | Boolean. Indicates if the mariadb Grafana dashboard should be enabled. This will create a configmap containing the MySQL dashboard(s) to be added to Grafana. | [Yes^1^](#mariadb_fn1) |
| `mariadb.backupRestore.parallel` | 2 | Number of threads to use for copy data files during backup and restore. | Yes |
| `mariadb.backupRestore.UseMemory` | `512MB` | The memory allocated for preparing a backup during restore. If you have enough available memory, 1GB to 2GB is a good recommended values. Multiples are supported providing the unit (e.g. 1MB, 1M, 1GB, 1G). | Yes |
| `mariadb.backupRestore.fullBackupInterval` | 1 | Interval(in days) to allow for full backup since the previous full backup is completed. If 0, perform full backup all the time without any incremental backup. | Yes |
| `mariadb.backupRestore.preserve` | `false` | ==NEW 9.0.0== Preserve replicated tables during restore. Used for restore between datacenters. | Yes |
| `mariadb.unifiedLogging.*` | *(empty)* | ==NEW 9.2.0== Mariadb statefulset [Unified Logging Parameters](#logging) and [unifiedLogging syslog certficate](#workload-certificate) | Yes |

<a name="mariadb_fn"></a>^†^ - There is no mechanism to prevent updating any values listed on an existing chart release. Therefore, an attempt to change any marked with an Update Allowed of No will not be prevented, but it will most likely result in the existing release of the chart being rendered unusable.
<a name="mariadb_fn1"></a>^1^ - Updating this value on an existing chart will cause a rolling update of the pods. These values should be updated carefully and with the expectation that service will be impacted. **For values that impact the MaxScale pod, updating this value will cause a service outage while the MaxScale pod is restarted.**
<a name="mariadb_fn2"></a>^2^ - Updating this value on an existing chart will result in a Scale lifecycle event being performed.
<a name="mariadb_fn3"></a>^3^ - Updating this value requires coordination with the applications using the client certificates.
<a name="mariadb_oper_fn"></a>^4^ - For operator, mount point inside container is fixed.
<a name="mariadb_oper_fn2"></a>^5^ - Operator does not support shared storage.
<a name="mariadb_fn4"></a>^6^ - Updating this value requires the Mariadb pod restarting to take effect.
<a name="mariadb_upd"></a>^7^ - Upgrading this values must be performed independently of other updates (ie, chart or other values).
<a name="maxscale_fn1"></a>^8^ - Updating this value requires the Maxscale pod restarting to take effect.

## MaxScale proxy parameters
<a name="helm-maxscale"></a>

| **Helm Parameter** | **Default** | **Description** | **Update Allowed**[^†^](#maxscale_fn) |
|:----------|:----------|:----------------|:--------------------------------------|
| `maxscale.image.registry` | <global.registry\> | The registry (global.registry override) to use for pulling the MaxScale container image. | [Yes^1^](#maxscale_fn1) |
| `maxscale.image.name` | cmdb/maxscale | The docker image to use for the MaxScale container | [Yes^1^](#maxscale_fn1) |
| `maxscale.image.tag` | <Version\> | The docker image tag to use for the MaxScale container | [Yes^1^](#maxscale_fn1) |
| `maxscale.image.flavor` | imageFlavor | The image flavor (rocky, centos7) to use for the MaxScale containers. This takes precedence over imageFlavor and global.imageFlavor | [Yes^1^](#maxscale_fn1) |
| `maxscale.image.flavorPolicy` | `BestMatch` | ==NEW 9.1.1== The policy which container image flavor should be based on. Options are: (Strict/BestMatch), with default BestMatch. This takes precedence over imageFlavorPolicy and global.imageFlavorPolicy | [Yes^1^](#maxscale_fn1) |
| `maxscale.image.pullPolicy` | IfNotPresent | The policy used to determine when to pull a new image from the docker registry | [Yes^1^](#maxscale_fn1) |
| `maxscale.imagePullSecrets` | *(omitted)* | Specify the Secrets for the maxscale pod to be used for pulling registry images from a secured registry. | Yes |
| `maxscale.labels` | *(empty)* | Specify the customized labels to assign to every created maxscale resource. | Yes |
| `maxscale.annotations` | *(empty)* | Specify the customized annotations to assign to every created maxscale resource. | No |
| `maxscale.podSecurityContext` | runAsUser: 1772<p>runAsGroup: 1772 </p>| securityContext override for maxscale pods. The default values will be used to set pod securityContext unless "podSecurityContext.disabled" is set to `true` | No |
| `maxscale.containerSecurityContext` | runAsUser: 1772<p>runAsGroup: 1772</p><p>readOnlyRootFilesystem: true</p><p>allowPrivilegeEscalation: false </p>| securityContext override for maxscale container in maxscale pods. The default values will be used to set container securityContext unless "containerSecurityContext.disabled" is set to `true`. | No |
| `maxscale.count` | 0 | The number of MaxScale pods to create if **maxscale.hpa.enabled**=false. Set to 0 for no MaxScale, 1 for simplex MaxScale, >1 for HA MaxScale. | Yes |
| `maxscale.hpa.enabled` | `false` | Specifies Horizontal Pod Autoscaling (HPA) should be enabled for maxscale statefulset. If HPA to be enabled, maxscale.count/replicas will be ignored and minimum and maximum number of replicase should be set. (see below). Ref: [HorizontalPodAutoscaler Walkthrough](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/) | Yes |
| `maxscale.hpa.minReplicas` | 2 | Specifies the minimum number of pods that HPA will be allowed to scale-down to. | Yes |
| `maxscale.hpa.maxReplicas` | 3 | Specifies the maximum number of pods that HPA will be allowed to scale-up to. | Yes |
| `maxscale.hpa.predefinedMetrics.enabled` | `true` | Specifies if pre-defined metrics should be enabled for maxscale pods. Pre-defined metrics provides a simple specification for average CPU/memory utiliczation across all containers in a pod. | Yes |
| `maxscale.hpa.predefinedMetrics.averageCPUThreshold` | 80 | Specifies the pre-defined average CPU utilization metric. | Yes |
| `maxscale.hpa.predefinedMetrics.averageMemoryThreshold` | 80 | Specifies the pre-defined average memory utilization metric. | Yes |
| `maxscale.hpa.metrics` | *(empty)* | Specifies the metrics to be used for auto-scaling.  Ref: [Support for resource metrics](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#support-for-resource-metrics). | Yes |
| maxscale.hpa.behavior.scaleDown.stabilizationWindowSeconds<p>maxscale.hpa.behavior.scaleDown.selectPolicy</p><p>maxscale.hpa.behavior.policies </p>| 120<p>*(kubernetes default)*</p><p>*(kubernetes default)* </p>| Specifies the scale-down behavior.  See [Configurable scaling behavior](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#configurable-scaling-behavior) for descriptions and kubernetes default values. | Yes |
| maxscale.hpa.behavior.scaleUp.stabilizationWindowSeconds<p>maxscale.hpa.behavior.scaleUp.selectPolicy</p><p>maxscale.hpa.behavior.policies </p>| 15<p>*(kubernetes default)*</p><p>*(kubernetes default)* </p>| Specifies the scale-down behavior.  See [Configurable scaling behavior](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#configurable-scaling-behavior) for descriptions and kubernetes default values. | Yes |
| `maxscale.pdb.enabled` | `true` | Indicates if the PodDisruptionBudget (PDB) is enabled for the pods in the maxscale statefulset.  Ref: [kubernetes.io Specifying a Disruption Budget for your Application](https://kubernetes.io/docs/tasks/run-application/configure-pdb/). | Yes |
| `maxscale.pdb.minAvailable` | *(omitted)* | The number of pods from that set that must still be available after the eviction, even in the absence of the evicted pod. minAvailable can be either an absolute number or a percentage.  Ref: [kubernetes.io Specifying a Disruption Budget for your Application](https://kubernetes.io/docs/tasks/run-application/configure-pdb/). Only used if maxscale.pdb.enabled=true.  | Yes |
| `maxscale.pdb.maxUnavailable` | 1 | The number of pods from that set that can be unavailable after the eviction. It can be either an absolute number or a percentage.  Ref: [kubernetes.io Specifying a Disruption Budget for your Application](https://kubernetes.io/docs/tasks/run-application/configure-pdb/). Only used if maxscale.pdb.enabled=true.  | Yes |
| `maxscale.masterSwitchoverTimeout` | 30 | The time (in seconds) to allow the master switchover to attempt to switch master when the master pod is deleted. | No |
| `maxscale.keystorePullTimeout` | 300 | The time (in seconds) to allow the maxscale pod to pull the keystore from one of the mariadb pods. | [Yes^1^](#maxscale_fn1) |
| `maxscale.tls.enabled` | *(omitted)* | Set to `true` to require that all traffic on the maxscale admin interface use TLS encryption. If omitted, it is enabled. ==If upgrading from old release where TLS is not enabled, this should be set to `false`==.  All calls to the maxctrl API must use secure option and the maxscale REST API will require HTTPS. | No |
| `maxscale.tls.secretRef.name` | *(omitted)* | Two interfaces are supported as specified by the maxscale.tls.secretRef.name value, which must be one of these values:<br>1. none (or empty) = Automatically generated certificates by cmgr<br>2. <secret\> = Manually supplied certificates. This is the name of the kubernetes <secret\> which contains the three CA certificate files provided in the maxscale.tls.secretRef.keyNames section<br> The secret value may be a 'go template' string that resolves to the name of the kubernetes secret. | No |
| maxscale.tls.secretRef.keyNames.caCrt<p>maxscale.tls.secretRef.keyNames.tlsCrt</p><p>maxscale.tls.secretRef.keyNames.tlsKey </p>| "ca.crt"<p>"tls.crt"</p><p>"tls.key" </p>| The specific server certificate keys in the secret, either from the manually created secret given in maxscale.tls.secretRef.name (should be the created file names), or via CMGR (defaults). | No |
| `maxscale.certificates.use_common_name` | `false` | Use Common Name (legacy) to specify local host in the certificates as opposed to using SANs.  Newer certificates would generally use SANs. | No |
| `maxscale.maxscale_site_conf` | \[maxscale\]<p>threads = 2</p><p>query_retries = 2</p><p>query_retry_timeout = 10 </p>| Additional configuration contents to place in a maxscale site configuration file on the MaxScale containers. See [MariaDB MaxScale 22.08](https://mariadb.com/kb/en/mariadb-maxscale-2208/) for details on various configuration options for MaxScale. | Yes |
| `maxscale.logrotate_site_conf` | \[maxscale\]<p>maxsize = 2097152</p><p>rotate = 5</p><p>compress = no </p>| Customized maxscale logrotate configuration parameters. | Yes |
| `maxscale.semiSyncReplication` | `true` | Use semi-synchronous replication for internal database replication.  Use of semi-sync replication is HIGHLY recommended when using maxscale for automated database failover.  If this is disabled, then it is very likely that master failover will not function properly and the failed Master will not correctly rejoin as Slave.<p>With semiSyncReplication enabled, the following will be added automatically:</p><p>- Addition of the rpl_semi_sync_% variables to **mariadb.mysqld_site_conf**,</p><p>- Addition of the management of the rpl_semi_sync_% variables to **maxscale.sql.promotion** and **maxscale.sql.deomotion** </p>| Yes |
| `maxscale.sql.promotion` | <None\> | List of SQL to inject on the Master MariaDB node after promotion | Yes |
| `maxscale.sql.demotion` | <None\> | List of SQL to inject on the Slave MariaDB node after demotion | Yes |
| maxscale.resources.requests.cpu<p>maxscale.resources.requests.memory</p><p>maxscale.resources.requests.ephemeral-storage </p>| cpu=250m, memory=256Mi, ephemeral-storage=1Gi | The Kubernetes Memory and CPU resource requests for the MaxScale pod (See [K8s documentation](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#how-pods-with-resource-requests-are-scheduled)) | [Yes^1^](#maxscale_fn1) |
| maxscale.resources.limits._cpu ==NEW 9.0.0== <p>maxscale.resources.limits.cpu</p><p>maxscale.resources.limits.memory</p><p>maxscale.resources.limits.ephemeral-storage </p>| _cpu=500m, cpu=, memory=512Mi, ephemeral-storage=1Gi | The Kubernetes Memory and CPU resource limits for the MaxScale pod (See [K8s documentation](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#how-pods-with-resource-requests-are-scheduled)) | [Yes^1^](#maxscale_fn1) |
| maxscale.startupProbe.initialDelaySeconds<p>maxscale.startupProbe.periodSeconds</p><p>maxscale.startupProbe.timeoutSeconds</p><p>maxscale.startupProbe.failureThreshold</p><p>maxscale.startupProbe.successThreshold </p>| 1<p>5</p><p>1</p><p>60</p><p>1 </p>| The Kubernetes startup probe configuration for the MaxScale container (See [K8s documentation](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes)) | [Yes^1^](#maxscale_fn1) |
| maxscale.livenessProbe.initialDelaySeconds<p>maxscale.livenessProbe.periodSeconds</p><p>maxscale.livenessProbe.timeoutSeconds</p><p>maxscale.livenessProbe.failureThreshold</p><p>maxscale.livenessProbe.successThreshold </p>| 120<p>10</p><p>5</p><p>6</p><p>1 </p>| The Kubernetes liveness probe configuration for the MaxScale container (See [K8s documentation](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes)). | [Yes^1^](#maxscale_fn1) |
| maxscale.readinessProbe.initialDelaySeconds<p>maxscale.readinessProbe.periodSeconds</p><p>maxscale.readinessProbe.timeoutSeconds</p><p>maxscale.readinessProbe.failureThreshold</p><p>maxscale.readinessProbe.successThreshold </p>| 10<p>10</p><p>1</p><p>4</p><p>1 </p>| The Kubernetes readiness probe configuration for the MaxScale container (See [K8s documentation](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes)). | [Yes^1^](#maxscale_fn1) |
| `maxscale.terminationGracePeriodSeconds` | 30 | Defines the grace period for termination of maxscale pods. | Yes |
| `maxscale.tolerations` | key: 'is_edge'<br>operator: 'Equal'<br>value: 'true'<br>effect: 'NoExecute' | Node tolerations for maxscale scheduling to nodes with taints. Ref: [kubernetes.io Taints and Tolerations](https://kubernetes.io/docs/concepts/configuration/taint-and-tolerations/). **WARNING**: Change with caution. | No |
| `maxscale.nodeSelector` | *(empty)* | Node labels for maxscale pod assignment. Ref: [kubernetes.io Node Selector](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector). Use with caution.<p>**`Note`**: This option is mutually exclusive with maxscale.nodeAffinity. </p>| No |
| `maxscale.topologySpreadConstraints` | *(empty)* | topologySpreadConstraints allow control of how Pods are spread across cluster among failure-domains such as regions, zones, nodes, and other user-defined topology domains. This can help to achieve high availability as well as efficient resource utilization.  Ref: [kubernetes.io Pod Topology Spread Constraints](https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/).<p>**`Note`**: Do not specify `labelSelector` as it will be automatically set by chart to correctly select all maxscale pods for the cluster. </p>| No |
| maxscale.nodeAffinity.enabled<p>maxscale.nodeAffinity.key</p><p>maxscale.nodeAffinity.value </p>| true<p>is_edge</p><p>true </p>| Node affinity key in BCMT for the maxscale pods. This will, by default, bind the maxscale proxy pods to the edge nodes.<p>maxscale.nodeAffinity.enable was added to allow the user to disable this feature.</p><p>**`Note`**: This option is mutually exclusive with maxscale.nodeSelector. </p>| No |
| `maxscale.podAntiAffinity.zone.type` | *(omitted)* | ==NEW 9.2.0== Specify pod anti-affinity zone type, allowed values: soft, hard, none | Yes |
| `maxscale.podAntiAffinity.zone.topologyKey` | `topology.kubernetes.io/zone` | ==NEW 9.2.0== Specify pod anti-affinity zone topologyKey | Yes |
| `maxscale.podAntiAffinity.node.type` | *(omitted)* | ==NEW 9.2.0== Specify pod anti-affinity node type, allowed values: soft, hard, none  | Yes |
| `maxscale.podAntiAffinity.node.topologyKey` | `kubernetes.io/hostname` |==NEW 9.2.0== Specify pod anti-affinity node topologyKey | Yes |
| `maxscale.podAntiAffinity.customRules` | *(omitted)* | ==NEW 9.2.0== Specify the set of customized rules for pod anti-affinity | Yes |
| `maxscale.priorityClassName` | *(omitted)* | The kubernetes Pod priority and preemption class name. Ref: [kubernetes.io Pod Priority Preemption](https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/) | No |
| maxscale.initContainers.resources.requests.cpu<p>maxscale.initContainers.resources.requests.memory</p><p>maxscale.initContainers.resources.requests.ephemeral-storage </p>| cpu=100m, memory=64Mi, ephemeral-storage=64Mi | The Kubernetes Memory and CPU resource requests for the mariadb pod initContainer container (See [K8s documentation](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#how-pods-with-resource-requests-are-scheduled)) | [Yes^1^](#mariadb_fn1) |
HERE
| maxscale.initContainers.resources.limits._cpu ==NEW 9.0.0== <p>maxscale.initContainers.resources.limits.cpu</p><p>maxscale.initContainers.resources.limits.memory</p><p>maxscale.initContainers.resources.limits.ephemeral-storage </p>| <Equal to Requests\> except '_cpu=100m,cpu='. The maxscale.initContainers.resources.limits.cpu is omitted per the HBP 3.4.0, but need to be configured when deploying on NCS tenant namespace | The Kubernetes Memory and CPU resource limits for the mariadb pod metrics container (See [K8s documentation](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#how-pods-with-resource-requests-are-scheduled)) | [Yes^1^](#mariadb_fn1) |
| `maxscale.metrics.enabled` | `false` | Boolean. Indicates if the maxscale metrics sidecar container should be enabled. | [Yes^1^](#maxscale_fn1)[^,2^](#maxscale_upd) |
| `maxscale.metrics.image.registry` | <global.registry\> | The registry (global.registry override) to use for pulling the maxscale metrics container image. | [Yes^1^](#maxscale_fn1) |
| `maxscale.metrics.image.name` | cmdb/maxctrl-exporter | The docker image to use for the maxscale metrics containers | [Yes^1^](#maxscale_fn1) |
| `maxscale.metrics.image.tag` | 0.1.0-7.181.el7 | The docker image tag to use for the maxscale metrics containers | [Yes^1^](#maxscale_fn1) |
| `maxscale.metrics.image.flavor` | imageFlavor | The image flavor (rocky, centos7) to use for the MaxScale metrics containers | [Yes^1^](#maxscale_fn1) |
| `maxscale.metrics.image.pullPolicy` | IfNotPresent | The policy used to determine when to pull a new image from the docker registry | [Yes^1^](#maxscale_fn1) |
| `maxscale.metrics.containerSecurityContext` | runAsUser: 1773<p>runAsGroup: 1773</p><p>readOnlyRootFilesystem: true</p><p>allowPrivilegeEscalation: false </p>| securityContext override for metrics container in maxscale pods. The default values will be used to set container securityContext unless "containerSecurityContext.disabled" is set to `true`. Added support for read-only root filesystem (e.g., Amazon EKS). | No |
| maxscale.metrics.resources.requests.cpu<p>maxscale.metrics.resources.requests.memory</p><p>maxscale.metrics.resources.requests.ephemeral-storage </p>| cpu=250m, memory=256Mi, ephemeral-storage=128Mi | The Kubernetes Memory and CPU resource requests for the maxscale pod metrics container (See [K8s documentation](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#how-pods-with-resource-requests-are-scheduled)) | [Yes^1^](#maxscale_fn1) |
| maxscale.metrics.resources.limits._cpu ==NEW 9.0.0== <p>maxscale.metrics.resources.limits.cpu</p><p>maxscale.metrics.resources.limits.memory</p><p>maxscale.metrics.resources.limits.ephemeral-storage </p>| <Equal to Requests\> except '_cpu=250m,cpu=' | The Kubernetes Memory and CPU resource limits for the maxscale pod metrics container (See [K8s documentation](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#how-pods-with-resource-requests-are-scheduled)) | [Yes^1^](#maxscale_fn1) |
| `maxscale.auth.enabled` | `false` | Set to `true` to enable zt-proxy metrics authentication sidecar in the maxscale statefulset. | Yes |
| `maxscale.auth.image.registry` | <global.registry\> | The registry (global.registry override) to use for pulling the maxscale auth container image. | [Yes^1^](#maxscale_fn1) |
| `maxscale.auth.image.name` | osdb/csfdb-zt-proxy | The docker image to use for the maxscale auth containers | [Yes^1^](#maxscale_fn1) |
| `maxscale.auth.image.tag` | 1.0-1-8 | The docker image tag to use for the maxscale auth containers | [Yes^1^](#maxscale_fn1) |
| `maxscale.auth.image.flavor` | rocky8 | The image flavor to use for the WoRKLOaD auth containers | [Yes^1^](#maxscale_fn1) |
| `maxscale.auth.image.pullPolicy` | IfNotPresent | The policy used to determine when to pull a new image from the docker registry | [Yes^1^](#maxscale_fn1) |
| `maxscale.auth.containerSecurityContext` | runAsUser: 1772<p>runAsGroup: 1772</p><p>readOnlyRootFilesystem: true</p><p>allowPrivilegeEscalation: false </p>| securityContext override for auth container in maxscale pods. The default values will be used to set container securityContext unless "containerSecurityContext.disabled" is set to `true`. | No |
| maxscale.auth.resources.requests.cpu<p>maxscale.auth.resources.requests.memory</p><p>maxscale.auth.resources.requests.ephemeral-storage </p>| cpu=250m, memory=256Mi, ephemeral-storage=128Mi | The Kubernetes Memory and CPU resource requests for the maxscale pod auth container (See [K8s documentation](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#how-pods-with-resource-requests-are-scheduled)) | [Yes^1^](#maxscale_fn1) |
| maxscale.auth.resources.limits._cpu ==NEW 9.0.0== <p>maxscale.auth.resources.limits.cpu</p><p>maxscale.auth.resources.limits.memory</p><p>maxscale.auth.resources.limits.ephemeral-storage </p>| <Equal to Requests\> except '_cpu=250m, cpu=' | The Kubernetes Memory and CPU resource limits for the maxscale pod auth container (See [K8s documentation](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#how-pods-with-resource-requests-are-scheduled)) | [Yes^1^](#maxscale_fn1) |
| `maxscale.auth.secretRef.name` | *(empty)* | The OpenID Connect (OIDC) secret name required if OIDC authentication to be enabled. | Yes |
| `maxscale.auth.skipVerifyInsecure` | `true` | Skip certificate verification with authentication server (insecure mode) | Yes |
| `maxscale.auth.tls.secretRef.name` | *(omitted)* | If prometheus is configured to use TLS for scrape, then the certificates used to authenticate the scrape request must be provided in this secret.  The secret resource containing all the certificate files must be pre-populated before CMDB deployment. | Yes |
| maxscale.auth.tls.secretRef.server_ca_cert<p>maxscale.auth.tls.secretRef.server_cert</p><p>maxscale.auth.tls.secretRef.server_key </p>| prom-server-ca-cert.pem<p>prom-server-cert.pem</p><p>prom-server-key.pem </p>| The specific server certificate file names defined in the **auth.tls.secretRef.name**. | Yes |
| `maxscale.unifiedLogging.*` | *(empty)* | ==NEW 9.2.0== Maxscale statefulset [Unified Logging Parameters](#logging) and [unifiedLogging syslog certficate](#workload-certificate) | Yes |

<a name="maxscale_fn"></a>^†^ - There is no mechanism to prevent updating any values listed on an existing chart release. Therefore, an attempt to change any marked with an Update Allowed of No will not be prevented, but it will most likely result in the existing release of the chart being rendered unusable.
<a name="maxscale_fn1"></a>^1^ - Updating this value on an existing chart will cause a rolling update of the pods. These values should be updated carefully and with the expectation that service will be impacted. **For values that impact the MaxScale pod, updating this value will cause a service outage while the MaxScale pod is restarted.**
<a name="maxscale_upd"></a>^2^ - Upgrading this values must be performed independently of other updates (ie, chart or other values).

## Administrative Parameters
<a name="helm-admin"></a>

| **Helm Parameter** | **Default** | **Description** | **Update Allowed**[^†^](#admin_fn) |
|:----------|:----------|:----------------|:-----------------------------------|
| `admin.image.registry` | <global.registry\> | The registry (global.registry override) to use for pulling the Admin container image. | [Yes^1^](#admin_fn1) |
| `admin.image.name` | cmdb/admin | The docker image to use for the Admin container(s) (Jobs) | [Yes^1^](#admin_fn1) |
| `admin.image.tag` | <Version\> | The docker image tag to use for the Admin container | [Yes^1^](#admin_fn1) |
| `admin.image.flavor` | imageFlavor | The image flavor (rocky, centos7) to use for the Admin containers | [Yes^1^](#admin_fn1) |
| `admin.image.flavorPolicy` | `BestMatch` | ==NEW 9.1.1== The policy which container image flavor should be based on. Options are: (Strict/BestMatch), with default BestMatch. This takes precedence over imageFlavorPolicy and global.imageFlavorPolicy | [Yes^1^](#admin_fn1) |
| `admin.image.pullPolicy` | IfNotPresent | The policy used to determine when to pull a new image from the docker registry | [Yes^1^](#admin_fn1) |
| `admin.imagePullSecrets` | *(omitted)* | Specify the Secrets for the admin pod to be used for pulling registry images from a secured registry. | Yes |
| `admin.labels` | *(empty)* | Specify the customized labels to assign to every created admin resource. | Yes |
| `admin.annotations` | *(empty)* | Specify the customized annotations to assign to every created admin resource. | No |
| `admin.podSecurityContext` | runAsUser: 1773<p>runAsGroup: 1773</p><p>fsGroup: 1773 </p>| securityContext override for admin pod. The default values will be used to set pod securityContext unless "podSecurityContext.disabled" is set to `true` | No |
| `admin.containerSecurityContext` | runAsUser: 1773<p>runAsGroup: 1773</p><p>readOnlyRootFilesystem: true</p><p>allowPrivilegeEscalation: false </p>| securityContext override for admin container in admin pod. The default values will be used to set container securityContext unless "containerSecurityContext.disabled" is set to `true`. Added support for read-only root filesystem (e.g., Amazon EKS). | No |
| `admin.pdb.enabled` | `false` | Indicates if the PodDisruptionBudget (PDB) is enabled for the pods in the admin statefulset.  Ref: [kubernetes.io Specifying a Disruption Budget for your Application](https://kubernetes.io/docs/tasks/run-application/configure-pdb/). | Yes |
| `admin.pdb.minAvailable` | *(omitted)*) | The number of pods from that set that must still be available after the eviction, even in the absence of the evicted pod. minAvailable can be either an absolute number or a percentage.  Ref: [kubernetes.io Specifying a Disruption Budget for your Application](https://kubernetes.io/docs/tasks/run-application/configure-pdb/). Only used if admin.pdb.enabled=true.  | Yes |
| `admin.pdb.maxUnavailable` | 100% | The number of pods from that set that can be unavailable after the eviction. It can be either an absolute number or a percentage.  Ref: [kubernetes.io Specifying a Disruption Budget for your Application](https://kubernetes.io/docs/tasks/run-application/configure-pdb/). Only used if admin.pdb.enabled=true.  | Yes |
| `admin.recovery` | <None\> | A database recovery indicator used for Healing. When this value is changed in the chart release, a Heal will be performed on the database nodes. If this value includes a colon-index (e.g., xxx:1), the Heal will be limited to that node (node 1); otherwise the entire cluster will perform a Heal. | [Yes^2^](#admin_fn2) |
| `admin.configAnnotation` | `false` | If set to `true`, an annotation will be added to the mariadb and maxscale statefulsets to restart pods on a configuration change (normal k8s behavior). If set to `false` (default), pods will not be restarted on configuration changes, however the new configuration will be injected into the running pods and the services will be restarted. | [Yes^1^](#admin_fn1) |
| `admin.autoHeal.enabled` | `true` | Set to `true` to enable Galera cluster auto-heal capability. | Yes |
| `admin.autoHeal.pauseDelay` | 900 | Time (in seconds) after deploy or heal operation to wait before re-enabling auto-heal (if auto-heal is enabled). Be careful setting to too small a value, if no pods are ready yet after deploy/heal and the audit triggers, an auto-heal may be initiated. | Yes |
| `admin.rebuildSlave.enabled` | `true` | Set to `true` to enable MaxScale cluster auto-rebuild of failed Master server. | Yes |
| `admin.rebuildSlave.mode` | safe | Auto-rebuild mode:<p>**failed-master** = only auto-rebuild failed master if it failed to come back as slave.</p><p>**safe** = auto-rebuild failed slave as long as a quorum of healthy nodes exist.</p><p>**aggressive** = auto-rebuild failed slave as long as at least one healthy node exists. </p>| Yes |
| `admin.rebuildSlave.onErrorsIO` | 1236 | List of replication errors occurring on IO thread which will trigger auto-rebuild of Slave.  Can set to 'all' to trigger on all IO errors, or 'none' to not auto-rebuild on any IO errors.  Also can exclude certain errors by specifying 'all-X-Y' to exclude errors X and Y. | Yes |
| `admin.rebuildSlave.onErrorsSQL` | all | List of replication errors occurring on all thread which will trigger auto-rebuild of Slave.  Can set to 'all' to trigger on all all errors, or 'none' to not auto-rebuild on any all errors.  Also can exclude certain errors by specifying 'all-X-Y' to exclude errors X and Y. | Yes |
| `admin.rebuildSlave.preferredDonor` | slave | Preferred donor (master or slave) to use for auto-rebuild of failed Master server. | Yes |
| `admin.rebuildSlave.allowMasterDonor` | `true` | Allow Master server to be used as Donor server? | Yes |
| `admin.rebuildSlave.method` | mariabackup | Method to use for rebuild process:<p>**mariabackup** = use mariabackup utility to perform backup/restore</p><p>**tar** = use directory tar method (useful for large databases). </p>| Yes |
| `admin.rebuildSlave.timeout` | 300 | Time (in seconds) to allow for rebuild of slave to complete before aborting. | Yes |
| `admin.rebuildSlave.retries` | 1 | Number of retries allowed for failed rebuild before giving up. | Yes |
| `admin.rebuildSlave.failRetryInterval` | 86400 (24 hours) | Interval (seconds) between attempts to retry a failed rebuild which has exceeded retry attempts.  Set to 'never' to disable fail retries. | Yes |
| `admin.rebuildSlave.parallel` | 2 | Number of donor threads to use for rebuild. | Yes |
| `admin.rebuildSlave.useMemory` | `256M` | Amount of memory to use for joining server. *(Do not set to more than half of resources.limits.memory)* | Yes |
| `admin.rebuildSlave.joinerBind` | `[::],pf=ip6` | ==NEW 9.2.0== IP address for rebuild Joiner to bind to.  Defaults to all IPv4/IPv6 addresses. | Yes |
| `admin.restoreServer.enabled` | `false` | ==NEW 9.0.0== Set to `true` to enable major upgrade restore server deployment. See [Helm Chart Upgrade - Major Release](./upgrade_via_helm.md#helm_major_upgrade) for discussion on enabling and configuring this capability. | Yes |
| `admin.restoreServer.joinCluster` | `false` | ==NEW 9.0.0== Set to `true` to have restore server pod join new release cluster to keep all new release transactions in sync with restore server pod. See [Helm Chart Upgrade - Major Release](./upgrade_via_helm.md#helm_major_upgrade). | Yes |
| `admin.restoreServer.annotations` | *(empty)* | ==NEW 9.0.0== Specify the customized annotations to add to all created restore server resources (statefulset, pods, services). | Yes |
| `admin.restoreServer.labels` | *(empty)* | ==NEW 9.0.0== Specify the customized labels to add to all created restore server resources (statefulset, pods, services). | Yes |
| `admin.restoreServer.deletePolicy` | config-update,chart-upgrade | ==NEW 9.0.0== Specify the delete policy for the restore server deployment.  See [Helm Chart Upgrade - Major Release](./upgrade_via_helm.md#helm_major_upgrade). | Yes |
| `admin.pwchangeTimeout` | 900 | Time (in seconds) to allow for automatic password change job to complete before aborting. | Yes |
| `admin.quickInstall` | \"\" | Set to \"yes\" to perform quick install of CMDB chart. A quick install will bypass waiting for all database pods to come up. Using quick install may result in pod failures not being detected during the installation process. | No |
| `admin.debug` | `false` | If true, the Admin container(s) will include more verbose output on stdout | Yes |
| `admin.pwChangeSecret` | <None\> | The name of a Kubernetes secret which defines a set of password change data items. Used to change passwords for users via helm. | No |
| admin.resources.requests.cpu<p>admin.resources.requests.memory</p><p>admin.resources.requests.ephemeral-storage </p>| cpu=250m, memory=256Mi, ephemeral-storage=1Gi | The Kubernetes Memory and CPU resource requests for the Admin pod (See [K8s documentation](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#how-pods-with-resource-requests-are-scheduled)) | [Yes^1^](#admin_fn1) |
| admin.resources.limits._cpu ==NEW 9.0.0== <p>admin.resources.limits.cpu</p><p>admin.resources.limits.memory</p><p>admin.resources.limits.ephemeral-storage </p>| _cpu=500m,cpu=, memory=512Mi, ephemeral-storage=1Gi | The Kubernetes Memory and CPU resource limits for the Admin pod (See [K8s documentation](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#how-pods-with-resource-requests-are-scheduled)) | [Yes^1^](#admin_fn1) |
| admin.startupProbe.initialDelaySeconds<p>admin.startupProbe.periodSeconds</p><p>admin.startupProbe.timeoutSeconds</p><p>admin.startupProbe.failureThreshold</p><p>admin.startupProbe.successThreshold </p>| 1<p>5</p><p>1</p><p>60</p><p>1 </p>| The Kubernetes startup probe configuration for the Admin container (See [K8s documentation](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes)) | [Yes^1^](#admin_fn1) |
| admin.livenessProbe.initialDelaySeconds<p>admin.livenessProbe.periodSeconds</p><p>admin.livenessProbe.timeoutSeconds</p><p>admin.livenessProbe.failureThreshold</p><p>admin.livenessProbe.successThreshold </p>| 120<p>10</p><p>5</p><p>6</p><p>1 </p>| The Kubernetes liveness probe configuration for the Admin container (See [K8s documentation](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes)). | [Yes^1^](#admin_fn1) |
| admin.readinessProbe.initialDelaySeconds<p>admin.readinessProbe.periodSeconds</p><p>admin.readinessProbe.timeoutSeconds</p><p>admin.readinessProbe.failureThreshold</p><p>admin.readinessProbe.successThreshold </p>| 10<p>10</p><p>1</p><p>3</p><p>1 </p>| The Kubernetes readiness probe configuration for the Admin container (See [K8s documentation](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes)). | [Yes^1^](#admin_fn1) |
| `admin.terminationGracePeriodSeconds` | 0 | Defines the grace period for termination of admin pod. **WARNING: Changing may cause delayed recovery from hosting node failure.**. | Yes |
| `admin.tolerations` | *(empty)* | Node tolerations for admin scheduling to nodes with taints. Ref: [kubernetes.io Taints and Tolerations](https://kubernetes.io/docs/concepts/configuration/taint-and-tolerations/) Use with caution. | No |
| `admin.nodeSelector` | *(empty)* | Node labels for admin pod assignment. Ref: [kubernetes.io Node Selector](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector). Use with caution.<p>**`Note`**: This option is mutually exclusive with admin.nodeAffinity. </p>| No |
| `admin.topologySpreadConstraints` | *(empty)* | topologySpreadConstraints allow control of how Pods are spread across cluster among failure-domains such as regions, zones, nodes, and other user-defined topology domains. This can help to achieve high availability as well as efficient resource utilization.  Ref: [kubernetes.io Pod Topology Spread Constraints](https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/).<p>**`Note`**: Do not specify `labelSelector` as it will be automatically set by chart to correctly select all admin pods for the cluster.  </p>| No |
| admin.nodeAffinity.enabled<p>admin.nodeAffinity.key</p><p>admin.nodeAffinity.value </p>| true<p>is_worker</p><p>true </p>| Node affinity key in BCMT for the admin pod. This should not be changed and will bind the admin pod to the worker nodes.<p>**`Note`**: This option is mutually exclusive with admin.nodeSelector. </p>| No |
| `admin.priorityClassName` | *(omitted)* | The kubernetes Pod priority and preemption class name. Ref: [kubernetes.io Pod Priority Preemption](https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/) | No |
| `admin.unifiedLogging.*` | *(empty)* | ==NEW 9.2.0== Admin deployment [Unified Logging Parameters](#logging) and [unifiedLogging syslog certficate](#workload-certificate) | Yes |

<a name="admin_fn"></a>^†^ - There is no mechanism to prevent updating any values listed on an existing chart release. Therefore, an attempt to change any marked with an Update Allowed of No will not be prevented, but it will most likely result in the existing release of the chart being rendered unusable.
<a name="admin_fn1"></a>^1^ - Updating this value on an existing chart will cause a rolling update of the pods. These values should be updated carefully and with the expectation that service will be impacted. **For values that impact the MaxScale pod, updating this value will cause a service outage while the MaxScale pod is restarted.**
<a name="admin_fn2"></a>^2^ - Updating this value on an existing chart will result in a Heal lifecycle event being performed.

## Geo-Redundancy Parameters
<a name="helm-geo-redundancy"></a>

| **Helm Parameter** | **Default** | **Description** | **Update Allowed**[^†^](#geored_fn) |
|:----------|:----------|:----------------|:------------------------------------|
| `mariadb.serverIdPrefix` | *(omitted)* | Defines a standard prefix to use for assignment of server_id for each local mariadb pod.  The server_id uniquely identifies the server instance in the community of replication partners, which includes both local and geo-redundant remote data center servers.  If not defined, a random unsigned integer will be assigned to each server. | No |
| `mariadb.clean_log_interval` | 3600 | Defines the interval (in seconds) that the Master of a replication cluster will clean-up old binlog files. | Yes |
| `geo_redundancy.slave_purge_interval` | 60 | Passed into the MaxScale container as DATACENTER_SLAVE_PURGE_INTERVAL (See [Docker Configuration](./oam_configure_docker.md)) | No |
| `geo_redundancy.enabled` | `false` | Boolean. Indicates if Geo-Redundancy should be configured between 2 clusters (Datacenters)<p>When set to `true`, the following will automatically be set independent of the user setting:</p><p>services.maxscale.enabled = true</p><p>service.maxscale.type = NodePort </p>| Yes |
| `geo_redundancy.site_index` | 1 | The (1-based) index for this site used for determining conflict-avoiding auto-increment settings. Each site must have a different index [1..4] Up to 4 datacenters supported. | Yes |
| `geo_redundancy.lag_threshold` | 30 | Passed into the MaxScale container as DATACENTER_LAG_THRESHOLD (See [Docker Configuration](./oam_configure_docker.md)) | No |
| `geo_redundancy.slave_skip_errors` | *(empty)* | List of errors to skip when applying replication transactions on a Slave.  See [slave_skip_error](https://mariadb.com/kb/en/replication-and-binary-log-system-variables/#slave_skip_errors).  When geo-redundancy is enabled, this will be automatically set to skip the ER_DUP_ENTRY (1062) error, unless explicitly set to 'none' (skip no errors). | Yes |
| `geo_redundancy.autoSiteReconnect` | `false` | Enable automatic reconnection of Slave to alternate datacenter Master server when IO thread error 1236 is detected.  All automatic replication resets are logged to docker stdout and to the following /var/log/maxscale/replication_recovery.log log file.<p>**IMPORTANT NOTE:**  Enabling autoSiteReconnect may cause loss of data or future SQL errors on the Slave datacenter since it is possible that transactions have been skipped in order to successfully re-establish replication. </p>| Yes |
| `geo_redundancy.directConnect` | `false` | Enable direct connection to remoteService IP:PORT (provided for each remote datacenter in the remoteSties section below) vs through a locally created Service/Endpoint.  Default of false is the original behavior. | No |
| `geo_redundancy.preferredIpFamily` | IPv6 | Specify the preferred IP family when enabling directConnect. Default of IPv6 is the original behavior if omitted. Value must be one of the following values: IPv6 IPv4 | Yes |
| geo_redundancy.remoteSites<p>geo_redundancy.remoteSites\[\*\].name</p><p>geo_redundancy.remoteSites\[\*\].maxscale.remoteService</p><p>geo_redundancy.remoteSites\[\*\].maxscale.serviceName</p><p>geo_redundancy.remoteSites\[\*\].maxscale.ipFamilyPolicy</p><p>geo_redundancy.remoteSites\[\*\].maxscale.ipFamilies</p><p>geo_redundancy.remoteSites\[\*\].master.remoteService</p><p>geo_redundancy.remoteSites\[\*\].master.serviceName</p><p>geo_redundancy.remoteSites\[\*\].master.serviceIP</p><p>geo_redundancy.remoteSites\[\*\].master.ipFamilyPolicy</p><p>geo_redundancy.remoteSites\[\*\].master.ipFamilies</p><p>geo_redundancy.remoteSites\[\*\].replication.ssl  </p>| <None\> | A list of remote datacenter sites which this local site will connect to.  **.name** is required; **.maxscale** provides the attributes for the maxscale service on the remote datacenter.  **.master** provides the attributes for the mariadb-master service on the remote datacenter.  The following service/endpoint attributes can be defined:<br>`remoteService` - IP:Port of the remote datacenter maxscale/mariadb-master service. Typically the IP/VIP of the Edge Node(s) and NodePort of the maxscale/mariadb-master Kubernetes Service<br>`serviceName`  - Optional full name to be given to the local service associated with the remote datacenter.  Defaults to: <release\>-{master\|maxscale}-<name\><p>`serviceIP` - (*master* only) Optional fixed IP address to be assigned to the *release*-mariadb-master-remote-*datacentername* service which will be created to allow for replication from the remote datacenter(s). Since replication now uses FQDN (not IP) for cross-datacenter replication, this parameter should no longer be required.</p><p>`ipFamilyPolicy` - Represents the dual-stack-ness requested or required by the remote maxscale/mariadb-master service.  Ref: [IPv4/IPv6 dual-stack](https://kubernetes.io/docs/concepts/services-networking/dual-stack/).</p><p>`ipFamilies` - List of IP families (eg, IPv4, IPv6) assigned to the admin service.</p><p>See the [Install via Helm](./install_via_helm.md) section for how to set up remote sites. **.replication.ssl indicates whether SSL should be used for replication from the remote datacenter.  Defaults to **mariadb.tls.enabled** (certificates must be present). </p>| Yes |

<a name="geored_fn"></a>^†^ - There is no mechanism to prevent updating any values listed on an existing chart release. Therefore, an attempt to change any marked with an Update Allowed of No will not be prevented, but it will most likely result in the existing release of the chart being rendered unusable.

## Hooks parameters
<a name="helm-hooks"></a>

| **Helm Parameter** | **Default** | **Description** | **Update Allowed**[^†^](#hooks_fn) |
|:----------|:----------|:----------------|:-----------------------------------|
| `hooks.deletePolicy` | hook-succeeded,before-hook-creation | The deletion policy to use for kubernetes Jobs. By default, the jobs will be deleted upon success, or prior to job creation. | Yes |
| <mark style="background-color: lightblue">*Helm Job Configuration*</mark> ||||
| `*Helm` Job Common Parameters* ||||
| hooks.\*.enabled | true | Set to enable/disable running of the given job. | Yes |
| hooks.\*.weight | 0 | Helm hook weight. | Yes |
| hooks.\*.deletePolicy | **hooks.deletePolicy** | The deletion policy to use for the given job.  Defaults to global **hooks.deletePolicy**. | Yes |
| hooks.\*.activeDeadlineSeconds | 120 (pre-upgrade)<p>*none* (others)</p>| Set activeDeadlineSeconds to define the total duration to allow for the running job.  By default, this is only set for the pre-upgrade job hook. | Yes |
| hooks.\*.backoffLimit | 3 | Define the backoffLimit for the given Job. | Yes |
| hooks.\*.restartPolicy | Never | Define the restartPolicy for the given Job. | Yes |
| hooks.resources.requests.cpu<p>hooks.resources.requests.memory</p><p>hooks.resources.requests.ephemeral-storage </p>| cpu=250m, memory=256Mi, ephemeral-storage=128Mi | The Kubernetes Memory and CPU resource requests for each job container (See [K8s documentation](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#how-pods-with-resource-requests-are-scheduled)) | [Yes^1^](#admin_fn1) |
| hooks.resources.limits._cpu ==NEW 9.0.0== <p>hooks.resources.limits.cpu</p><p>hooks.resources.limits.memory</p><p>hooks.resources.limits.ephemeral-storage </p>| <Equal to Requests\>except '_cpu=250m,cpu=' | The Kubernetes Memory and CPU resource limits for each job container (See [K8s documentation](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#how-pods-with-resource-requests-are-scheduled)) | [Yes^1^](#admin_fn1) |
| `*Helm` Job Specific Parameters* ||||
| hooks.preInstallJob.name<p>hooks.preInstallJob.containerName</p><p>hooks.preInstallJob.timeout</p><p>hooks.preInstallJob.backoffLimit </p>| pre-install<p>pre-install-admin</p><p>120</p><p>3 </p>| Set **name** to change the job pod name. Set `containerName` to change the default job pod container name. Set **timeout** to change the job timeout (in seconds). Set `backoffLimit` to set the number of retries before job is considered failed. | Yes |
| hooks.postInstallJob.name<p>hooks.postInstallJob.containerName</p><p>hooks.postInstallJob.timeout</p><p>hooks.postInstallJob.backoffLimit </p>| post-install<p>post-install-admin</p><p>900</p><p>3 </p>| Set **name** to change the job pod name.  Set `containerName` to change the default job pod container name. Set **timeout** to change the job timeout (in seconds). Set `backoffLimit` to set the number of retries before job is considered failed. | Yes |
| hooks.preUpgradeJob.name<p>hooks.preUpgradeJob.containerName</p><p>hooks.preUpgradeJob.timeout</p><p>hooks.preUpgradeJob.backoffLimit</p><p>hooks.preUpgradeJob.activeDeadlineSeconds </p>| pre-upgrade<p>pre-upgrade-admin</p><p>180</p><p>3</p><p>120 </p>| Set **name** to change the job pod name.  Set `containerName` to change the default job pod container name. Set **timeout** to change the job timeout (in seconds).  Set `activeDeadlineSeconds` to change the default job pod duration. Set `backoffLimit` to set the number of retries before job is considered failed. | Yes |
| hooks.postUpgradeJob.name<p>hooks.postUpgradeJob.containerName</p><p>hooks.postUpgradeJob.timeout</p><p>hooks.postUpgradeJob.backoffLimit </p>| post-upgrade<p>post-upgrade-admin</p><p>1800</p><p>3 </p>| Set **name** to change the job pod name.  Set `containerName` to change the default job pod container name. Set **timeout** to change the job timeout (in seconds). Set `backoffLimit` to set the number of retries before job is considered failed. | Yes |
| hooks.preRollbackJob.name<p>hooks.preRollbackJob.containerName</p><p>hooks.preRollbackJob.time.timeout</p><p>hooks.preRollbackJob.backoffLimit </p>| pre-rollback<p>pre-rollback-admin</p><p>180</p><p>3 </p>| Set **name** to change the job pod name.  Set `containerName` to change the default job pod container name. Set **timeout** to change the job timeout (in seconds). Set `backoffLimit` to set the number of retries before job is considered failed. | Yes |
| hooks.postRollbackJob.name<p>hooks.postRollbackJob.containerName</p><p>hooks.postRollbackJob.timeout</p><p>hooks.preRollbackJob.backoffLimit </p>| post-rollback<p>post-rollback-admin</p><p>300</p><p>3 </p>| Set **name** to change the job pod name.  Set `containerName` to change the default job pod container name. Set **timeout** to change the job timeout (in seconds). Set `backoffLimit` to set the number of retries before job is considered failed. | Yes |
| hooks.preDeleteJob.name<p>hooks.preDeleteJob.containerName</p><p>hooks.preDeleteJob.timeout</p><p>hooks.preDeleteJob.backoffLimit </p>| pre-delete<p>pre-delete-admin</p><p>120</p><p>3 </p>| Set **name** to change the job pod name.  Set `containerName` to change the default job pod container name. Set **timeout** to change the job timeout (in seconds). Set `backoffLimit` to set the number of retries before job is considered failed. | Yes |
| hooks.postDeleteJob.name<p>hooks.postDeleteJob.containerName</p><p>hooks.postDeleteJob.timeout</p><p>hooks.postDeleteJob.backoffLimit </p>| post-delete<p>post-delete-admin</p><p>180</p><p>3 </p>| Set **name** to change the job pod name.  Set `containerName` to change the default job pod container name. Set **timeout** to change the job timeout (in seconds). Set `backoffLimit` to set the number of retries before job is considered failed. | Yes |
| hooks.testJob.name<p>hooks.testJob.containerName</p><p>hooks.testJob.timeout</p><p>hooks.postDeleteJob.backoffLimit </p>| test<p>test-admin</p><p>300</p><p>0 </p>| Set **name** to change the job pod name.  Set `containerName` to change the default job pod container name. Set **timeout** to change the job timeout (in seconds). Set `backoffLimit` to set the number of retries before job is considered failed. | Yes |
| hooks.testJob.skipTests | *(empty)* | ==NEW 9.3.0== Comma-separated list of helm tests to skip. | Yes |
| <mark style="background-color: lightblue">*NCMS Hook Job Configuration*</mark> ||||
| `*NCMS` Job Common Parameters* ||||
| hooks.\*.activeDeadlineSeconds | *none* | Set activeDeadlineSeconds to define the total duration to allow for the running job. | Yes |
| hooks.\*.backoffLimit | 3 | Define the backoffLimit for the given Job. | Yes |
| hooks.\*.restartPolicy | Never | Define the restartPolicy for the given Job. | Yes |
| `*NCMS` Job Specific Parameters* ||||
| hooks.postHealJob.name<p>hooks.postHealJob.containerName</p><p>hooks.postHealJob.timeout </p>| post-heal<p>post-heal-admin</p><p>180 </p>| Set **name** to change the job pod name.  Set `containerName` to change the default job pod container name. Set **timeout** to change the job timeout (in seconds).| Yes |
| hooks.preRestoreJob.name<p>hooks.preRestoreJob.containerName</p><p>hooks.preRestoreJob.timeout </p>| pre-restore<p>pre-restore-admin</p><p>180 </p>| Set **name** to change the job pod name.  Set `containerName` to change the default job pod container name. Set **timeout** to change the job timeout (in seconds).| Yes |
| hooks.postRestoreJob.name<p>hooks.postRestoreJob.containerName</p><p>hooks.postRestoreJob.timeout </p>| post-restore<p>post-restore-admin</p><p>180 </p>| Set **name** to change the job pod name.  Set `containerName` to change the default job pod container name. Set **timeout** to change the job timeout (in seconds).| Yes |

<a name="hooks_fn"></a>^†^ - There is no mechanism to prevent updating any values listed on an existing chart release. Therefore, an attempt to change any marked with an Update Allowed of No will not be prevented, but it will most likely result in the existing release of the chart being rendered unusable.

## **Backup/Restore Policy (CBUR) Parameters**
<a name="helm-cbur"></a>

| **Helm Parameter** | **Default** | **Description** | **Update Allowed**[^†^](#cbur_fn) |
|:----------|:----------|:----------------|:----------------------------------|
| `cbur.enabled` | `true` | Enables the deployment to use backup/restore policy (BrPolicy). Requires cbur-master deployment. Set to `false` if cbur-master is not deployed in kubernetes cluster. | No |
| `cbur.apiVersion` | cbur.csf.nokia.com/v1 | The CBUR api-version used for brPolicy, use configured apiVersion if specified, otherwise, automatically determined based on available capabilities. | [Yes^1^](#cbur_fn1) |
| `cbur.image.registry` | <global.registry2\> | The registry (global.registry2 override) to use for pulling the CBUR container image. | [Yes^1^](#cbur_fn1) |
| `cbur.image.name` | cmdb/admin | The docker image to use for the CBUR container(s) (Jobs) | [Yes^1^](#cbur_fn1) |
| `cbur.image.tag` | <Version\> | The docker image tag to use for the CBUR container | [Yes^1^](#cbur_fn1) |
| `cbur.image.pullPolicy` | `IfNotPresent` | The policy used to determine when to pull a new image from the docker registry | [Yes^1^](#cbur_fn1) |
| `cbur.containerSecurityContext` | runAsUser: 1771<p>runAsGroup: 1771</p><p>readOnlyRootFilesystem: true</p><p>allowPrivilegeEscalation: false </p>| securityContext override for cbur container in mariadb pods. The default values will be used to set container securityContext unless "containerSecurityContext.disabled" is set to `true`. | No |
| `cbur.backendMode` | local | Defines the backup storage options (ie. local, NetBackup, S3, Avamar) | Yes |
| `cbur.autoEnableCron` | `false` | Specifies if the backup scheduling cron job should be automatically enabled. | Yes |
| `cbur.autoUpdateCron` | `false` | Specifies cron update will be triggered automatically by BrPolicy update. | Yes |
| `cbur.cronSpec` | 0 0 \* \* \* | Allows user to schedule backups. | Yes |
| `cbur.maxiCopy` | 5 | Defines how many backup copies should be saved. | Yes |
| `cbur.dataEncryption` | `true` | When cbur.enabled is `true`, this dictates whether cbur will encrypt the backup in the CBUR repo. Disabling encryption will remove the encryption key dependency on the release name and allow CMDB to be restored from a backup taken at a geo-redundant site. | Yes |
| `cbur.ignoreFileChanged` | `false` | Interface to BrPolicy to ignore file changes during building tarball for target app volumes | Yes |
| `cbur.selectPod` | `true` | ==UPDATED 9.1.1== Use the label(cbur=backup) to select the pod to run backup. If true, select the latest slave pod if available, otherwise, select the master pod. | Yes |
| `cbur.tablesPreserve` | `false` | Define the tables to be preserved without replication coordination. | Yes |
| `cbur.brhookType` | brpolicy | Specifies the targetType (brpolicy\|release) of a specific BrHook API. | Yes |
| `cbur.brhookWeight` | 0 | Specifies the weight (integer) to control sequencing of multiple BrHook APIs. | Yes |
| `cbur.brhookEnable` | `true` | Specifies the boolean enable (true\|false) to enable/disable a specific BrHook API. | Yes |
| `cbur.brhookTimeout` | 600 | Specifies the timeout (seconds) for maximum wait time of a specific BrHook API. | Yes |
| `cbur.persistence.cburtmp.enabled` | `false` | Boolean. Indicates whether a separate "/tmp" volume should be attached to the MariaDB cbura-sidecar container. This may be enabled to give CBUR more temporary space to perform backup/restore operations. This must be set to `true` in Amazon EKS environment. All other variables in the cbur.persistence.cburtmp section will be ignored unless this is set to `true`. | No |
| `cbur.persistence.cburtmp.size` | 20Gi | The size of the cburtmp volume to attach to the MariaDB cbura-sidecar container. Size requirements are application dependent. | No |
| `cbur.persistence.cburtmp.storageClass` | *(omitted)* | The Kubernetes Storage Class for the cburtmp persistent volume. Default is to use the kubernetes default storage class. | No |
| `cbur.persistence.cburtmp.accessMode` | `ReadWriteOnce` | The Kubernetes Access Mode for the cburtmp persistent volume. By default, the volume is mounted as read-write by a single node. | No |
| `cbur.persistence.cburtmp.dir` | /tmp | The directory to use for backup/restore local to the MariaDB cbura-sidecar container. | No |
| `cbur.emptyDir.sizeLimit` | `40Gi` | ==NEW 9.0.0== The emptyDir volume size to be used if cbur.persistence.cbur.tmp.enabled is `false`. Should be twice of the data storage size | No |
| `cbur.volumeBackupType` | `volume` | ==NEW 9.2.0== The supported types are volume and snapshot. The volume type is the traditional backup/restore procedure based on mariabackup. The snapshot type is taking volumesnapshot of the datadir pvc during backup and a new datadir pvc will be recreated based on the volumesnapshot during restore. | No |
| `cbur.volumeSnapshotClassName` | `cinder-csi-snapclass` | ==NEW 9.2.0== Specify the name of the VolumeSnapshotClass. | No |
| `cbur.saveVolumeContentToBackend` | `true` | ==NEW 9.2.0== Specify if CBUR will save the contents of the volumesnapshot to backend or not. | No |
| `cbur.createVolumeOnly` | `false` | ==NEW 9.2.0== Only applies to restore. Specify if CBUR will only re-creates the pvc or takes charge of deleting and re-attaching pvc as well. | No |
| `cbur.keepLocalSnapshotIfSaveToBackend` | `false` | ==NEW 9.2.0== Only applies to backup. Specify if CBUR will keep the volume snapshot in cloud provided storage after saving volume content to backend. | No |
| `cbur.retrieveVolumeContentFromBackend` | `true` | ==NEW 9.2.0== Only applies to backup. Specify if CBUR will always retrieve volume content from backend regardless snapshot exists in cloud provided storage. | No |
| `cbur.pvcName` | None | ==NEW 9.2.0== The target PVC list which will be backed up/restored via volume snapshot. By default, it's the pvc with startname "datadir-<podprefix>" of the selected pod. | No |
| `cbur.snapshotWaitDisk` | `60` | ==NEW 9.2.0== The wait duration in seconds for filesystem flushed to the disk to be ready for snapshot. | No |
| cbur.resources.requests.cpu<p>cbur.resources.requests.memory</p><p>cbur.resources.requests.ephemeral-storage </p>| cpu=250m, memory=256Mi, ephemeral-storage=128Mi | The Kubernetes Memory and CPU resource requests for the CBUR container (See [K8s documentation](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#how-pods-with-resource-requests-are-scheduled)) | [Yes^1^](#admin_fn1) |
| cbur.resources.limits._cpu ==NEW 9.0.0== <p>cbur.resources.limits.cpu</p><p>cbur.resources.limits.memory</p><p>cbur.resources.limits.ephemeral-storage </p>| <Equal to Requests\> except '_cpu=250m, cpu=' | The Kubernetes Memory and CPU resource limits for the CBUR container (See [K8s documentation](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#how-pods-with-resource-requests-are-scheduled)) | [Yes^1^](#admin_fn1) |
| `cbur.prebackup_mariabackup_args` | *(omitted)* | Specifies additional arguments for the mariabackup backup operation. | na[^2^](#cbur_fn2) |
| `cbur.postrestore_mariabackup_args` | *(omitted)* | Specifies additional arguments for the mariabackup restore operation. | na[^2^](#cbur_fn2) |
| cbur.preBackupHook.name<p>cbur.preBackupHook.containerName</p><p>cbur.preBackupHook.timeout </p>| prebackup-brhook<p>brhook-prebackup-admin</p><p>180 </p>| Set **name** to change the brhook job pod name.  Set `containerName` to change the default brhook job pod container name. Set **timeout** to change the brhook job timeout (in seconds).| Yes |
| cbur.postBackupHook.name<p>cbur.postBackupHook.containerName</p><p>cbur.postBackupHook.timeout </p>| postbackup-brhook<p>brhook-postbackup-admin</p><p>120 </p>| Set **name** to change the brhook job pod name.  Set `containerName` to change the default brhook job pod container name. Set **timeout** to change the brhook job timeout (in seconds).| Yes |
| cbur.preRestoreHook.name<p>cbur.preRestoreHook.containerName</p><p>cbur.preRestoreHook.timeout </p>| prerestore-brhook<p>brhook-prerestore-admin</p><p>240 </p>| Set **name** to change the brhook job pod name.  Set `containerName` to change the default brhook job pod container name. Set **timeout** to change the brhook job timeout (in seconds).| Yes |
| cbur.postRestoreHook.name<p>cbur.postRestoreHook.containerName</p><p>cbur.postRestoreHook.timeout </p>| postrestore-brhook<p>brhook-postrestore-admin</p><p>900 </p>| Set **name** to change the brhook job pod name.  Set `containerName` to change the default brhook job pod container name. Set **timeout** to change the brhook job timeout (in seconds).| Yes |
| cbur.backup.upgrade<p>cbur.backup.timeout </p>| false<p>900 </p>| Perform automatic backup on (before) upgrade.<p>Triggered during pre-upgrade, only when Server image or count change detected (Values changed: server.image. or server.count)</p><p>Note: User must ensure admin.preUpgradeTimeout and helm timeout sufficient to perform backup AND upgrade, or timeout failures will occur.</p><p>Timeout for performing backup (sec) </p>| Yes |
| cbur.service.namespace<p>cbur.service.name</p><p>cbur.service.protocol </p>| ncms<p>cbur-master-cbur</p><p>http </p>| CBUR Master Service access info used to initiate backup via CBUR API, e.g., when cbur.backup.upgrade: true.<p>The **namespace** where the CBUR Master Service (ignored if url set)</p><p>The Service **name** of the CBUR Master Service (ignored if url set) for performing backup (sec)</p><p>The **protocol** to use for CBUR API (http/https) </p>| Yes |
| `cbur.service.url` | *(omitted)* | If unset, will be automatically constructed from cbur.service.name, cbur.service.namespace, and clusterDomain. Can be used to set a custom URL | Yes |
| `cbur.service.authSecret` | *(omitted)* | The secret from CBUR copied into our namespace providing username/password for accessing the CBUR Master Service. Necessary when CBUR basic-auth is enabled | Yes |

<a name="cbur_fn"></a>^†^ - There is no mechanism to prevent updating any values listed on an existing chart release. Therefore, an attempt to change any marked with an Update Allowed of No will not be prevented, but it will most likely result in the existing release of the chart being rendered unusable.
<a name="cbur_fn1"></a>^1^ - Updating this value on an existing chart will cause a rolling update of the pods. These values should be updated carefully and with the expectation that service will be impacted. **For values that impact the MaxScale pod, updating this value will cause a service outage while the MaxScale pod is restarted.**
<a name="cbur_fn2"></a>^2^ - Beware: "helm backup" will NOT automatically pick up changes to the "X_mariabackup_args" parameters when changed after installation. In this case, use "kubectl edit BrPolicy <cmdb-fullname>-mariadb" to manually reflect any changes.

## Cert-Manager Certificate Parameters used by all [CMDB workloads](#workload-certificate).
<a name="helm-certs"></a>

<a name="certificate-parameters"></a>

| **Helm Parameter** | **Default** | **Description** | **Update Allowed** |
|:----------|:----------|:----------------|:----------------------------------|
| `certificate.enabled` | `true` | Certificate enablement for certManager | No |
| `certificate.nameSuffix` | None | Name suffix for unifiedLogging certs. N/A for others. | No |
| `certificate.duration` | `8760h` | certificate default Duration. | No |
| `certificate.renewBefore` | `360h` | certificate renew before expiration duration. | No |
| `certificate.commonName` | None | A common name to be used for the certificate. Deprecated and not recommended for use.  | No |
| `certificate.usages` | None | certficate usage, if not specified, "server auth" and "client auther" will be used. | No |
| `certificate.issuerRef.name` | None | The issuer name. | No |
| `certificate.issuerRef.kind` |  None | The supported issuer kinds are ClusterIssuer and Issuer. | No |
| `certificate.issuerRef.group` | None | The issuer group. | No |
| `certificate.dnsNames` | None | List of DNS Names to include in the Certificate (See [cert-manager documentation](https://cert-manager.io/docs/usage/certificate/#creating-certificate-resources)) | No |
| `certificate.ipAddresses` |  None | List of IP Addresses for MariaDB to include in the Certificate (See [cert-manager documentation](https://cert-manager.io/docs/usage/certificate/#creating-certificate-resources))| No |
| `certificate.uris` | None |  List of URIs to include in the Certificate (See [cert-manager documentation](https://cert-manager.io/docs/usage/certificate/#creating-certificate-resources)) | No |
| `certificate.subject` | None |  Subject to use in the Certificate (See [cert-manager documentation](https://cert-manager.io/docs/usage/certificate/#creating-certificate-resources)) | No |
| `certificate.privateKey.algorithm` | None | privateKey algorithm in the Certificate. Supported algorithm "RSA" (See [cert-manager documentation](https://cert-manager.io/docs/usage/certificate/#creating-certificate-resources)) | No |
| `certificate.privateKey.encoding` | None | privateKey encoding in the Certificate. When omitted, the default is "PKCS1" (See [cert-manager documentation](https://cert-manager.io/docs/usage/certificate/#creating-certificate-resources)) | No |
| `certificate.privateKey.size` | None | privateKey size in the Certificate. When omitted, the default is 2048 (See [cert-manager documentation](https://cert-manager.io/docs/usage/certificate/#creating-certificate-resources)) | No |
| `certificate.privateKey.rotationPolicy` | [Always^1^](#cert_fn1) | privateKey rotationPolicy in the Certificate. When omitted, the default is "Always" (See [cert-manager documentation](https://cert-manager.io/docs/usage/certificate/#creating-certificate-resources)) | No |

<a name="cert_fn1"></a>^1^ - Note: The value of "certificate.privateKey.rotationPolicy" is changed from "Never" to "Always" starting 9.3.0.


## CMDB workload Certificate
<a name="workload-certificate"></a>

| **Helm Parameter** | **Default** | **Description** | **Update Allowed** |
|:----------|:----------|:----------------|:----------------------------------|
| `clients.mariadb.certificate.*` | *(empty)* | MariaDB client [certificate parameters](#certificate-parameters)  | No |
| `mariadb.certificate.*` | *(empty)* | MariaDB server [certificate parameters](#certificate-parameters) | No |
| `maxscale.certificate.*` | *(empty)* | Maxscale server [certificate parameters](#certificate-parameters) | No |
| `mariadb.unifiedLogging.nameSuffix` | "mariadb-syslog" | ==NEW 9.2.0== Name suffix for Mariadb unifiedLogging syslog certificate. | No |
| `mariadb.unifiedLogging.syslog.certificate.*` | *(empty)* | ==NEW 9.2.0== Mariadb statefulset unifiedLogging syslog [certificate parameters](#certificate-parameters) | No |
| `admin.unifiedLogging.nameSuffix` | "admin-syslog" | ==NEW 9.2.0== Name suffix for Admin unifiedLogging syslog certificate. | No |
| `admin.unifiedLogging.syslog.certificate.*` | *(empty)* | ==NEW 9.2.0== Admin deployment unifiedLogging syslog [certificate parameters](#certificate-parameters) | No |
| `maxscale.unifiedLogging.nameSuffix` | "maxscale-syslog" | ==NEW 9.2.0== Name suffix for Maxscale unifiedLogging syslog certificate. | No |
| `maxscale.unifiedLogging.syslog.certificate.*` | *(empty)* | ==NEW 9.2.0== Maxscale statefulset unifiedLogging syslog [certificate parameters](#certificate-parameters) | No |



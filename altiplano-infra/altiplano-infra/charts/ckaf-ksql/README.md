# KSQL Server Helm Chart

This chart bootstraps a deployment of a Confluent KSQL Server.
This is an example deployment which runs KSQL Server in non-interactivemode.
The included queries file `queries.sql` is a stub provided to illustrate one possible approach to mounting queries in the server container via ConfigMap.

## Prerequisites

* Kubernetes 1.9.2+
* Helm 2.8.2+
* A healthy and accessible Kafka Cluster

## Installing the Chart

### Install with specific name and an existing kafka and schema-registry release

```console
helm install --name my-ksql --set kafka.bootstrapServers="kf-my-kafka.default.svc.local:9092",schema-registry.url="schema-my-schema:8081" csf-repo/ckaf-ksql
```

## Configuration

You can specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```console
helm install --name my-ksql-server -f my-values.yaml ./ksql-server
```

> **Tip**: A default [values.yaml](values.yaml) is provided

### Parameters

The configuration parameters in this section control the resources requested and utilized by the ckaf-ksql chart.

| Parameter                                          | Description                                                          | Default Value                                       |
| -------------------------------------------------- | -------------------------------------------------------------------- | --------------------------------------------------- |
| global.registry                                    | Used for ksql-server container image                                 | csf-docker-delivered.repo.cci.nokia.net |
| global.registry1                                   | Used for jmx-exporter container image                                | csf-docker-delivered.repo.cci.nokia.net |
| global.registry2                                   | Reserved for cbur container image                                    | csf-docker-delivered.repo.cci.nokia.net |
| global.registry3                                   | Used for pre/post hook container image                               | csf-docker-delivered.repo.cci.nokia.net |
| global.registry4                                   | Used for init container image                                        | csf-docker-delivered.repo.cci.nokia.net |
| global.seccompAllowedProfileNames                  | Secure Computing Mode Allowed for these profiles                     | runtime/default      |
| global.seccompDefaultProfileName                   | Secure Computing Default Profile                                     | runtime/default      |
| global.annotations                                 | Map of custom annotations to attach to the deployment.               | nil                  |
| global.labels                                      | Map of custom labels to attach to the deployment.                    | nil                  |
| global.common_labels                               | Flag to enable/disable common labels.                                | nil                  |
| global.rbac.enabled                                | Enables Role based Access control Authorization                      | TRUE                 |
| global.preheal                                     | ksql preheal job will spawns during install if value is greater than 0 | 0                  |  
| global.postheal                                    | ksql postheal job will spawns during install if value is greater than 0| 0                  |
| global.clog.enabled                                | CSF Logging Solution On/Off                                          | TRUE                 |
| global.istio.version                               | Supports istio version > 1.4                                         | 1.6                  |
| global.istio.enabled                               | "enabled true" injects istio proxy side cars to the ksql pods        | FALSE                |
| global.istio.createDrForClient                     | Creates a destination rule for ksql workload with tls mode as "DISABLE" | FALSE             |
| global.istio.cni.enabled                           | Whether istio cni is enabled in the environment                      | TRUE                 |
| global.istio.mtls.enabled                          | Is strict MTLS enabled in the environment                            | TRUE                 |
| global.istio.permissive                            | Should allow mutual TLS as well as clear text for your deployment    | FALSE                |
| global.certManager.enabled                         | Enable to use certmanager created certificates                        | 
TRUE                 |
| global.priorityClassName                           | Set a priority for a Pod using the PriorityClass |                                            |
| global.enableDefaultCpuLimits                      | If enableDefaultCpuLimits set to true user can configure their own cpu limts | false
| global.podNamePrefix                               | string                                                                | `""`
| global.disablePodNamePrefixRestrictions            | If disablePodNamePrefixRestrictions is true then there is no restriction limit for podnameprefix.(root level have more precedence than global level) | false 
| <workload>.priorityClassName                       | Workload level PriorityClass takes higher predence than global.priorityClassName|                                           |
| timezone.mountHostLocaltime                        | To ensure that data & logs are in sync among pods & hosted components| TRUE                 |
| clusterDomain                                      | Kubernetes cluster domain name                                       | cluster.local        |
| certManager.enabled                                | Root level certmanager takes higher predence than global             | 
nil                 |
| custom.ksqlDeploymentset.annotations               | Workload level annotations                                           | nil                  |
| custom.ksqlDeploymentset.labels                    | Workload level labels                                                | nil                  |
| custom.ksqlPodLevel.annotations                    | Pod level annotations                                                | nil                  |
| custom.ksqlPodLevel.labels                         | Pod level labels                                                     | nil                  |
| loadPluginsFromInitContainer                       | Enable to load ksql custom plugins via init container                | FALSE                |
| pluginsInitContainerResources.requests.cpu         | Init container cpu resource request                                  | 200m                 |
| pluginsInitContainerResources.requests.memory      | Init container memory resource request                               | 1Gi                  |
| pluginsInitContainerResources.limits.cpu           | Init container cpu resource limit                                    | ""                   |
| pluginsInitContainerResources.limits.memory        | Init container memory resource limit                                 | 1Gi                  |
| pluginsInitContainerImageName                      | Init container image name                                            | ""                   |
| pluginsInitContainerImageTag                       | Init container image tag                                             | ""                   |
| pluginsInitContainerImagePullPolicy                | Init container image pull policy                                     | "IfNotPresent"       |
| pluginsBasePath                                    | Basepath in the init docker image consisting of custome ksql plugin jars | ""               |
| replicaCount                                       | Number of ksql-server pods                                           | 1                    |
| minAvailable                                       | Specify number of pods that must be available after the eviction     | nil                  |
| servicePort                                        | KSQL server port                                                     | 8088                 |
| LogLevel                                           | Log level                                                            | "INFO"               |
| MaxFileSize                                        | Max log file size                                                    | 50MB                 |
| MaxBackupIndex                                     | Max backup index                                                     | 10                   |
| gcLog.enabled                                      | Enable ksql garbage collector logs                                   | FALSE                |
| gcLog.ksqlGcLogOpts                                | GC log options                                                       | "-Xlog:gc*:file=/var/log/ksql/ksql-test.log:time,tags:filecount=10,filesize=102400" |
| security.enabled                                   | Security Enable Switch                                               | TRUE                 |
| security.runAsUser                                 | Run As this User ID which will run withing the pod                   | 999                  |
| security.fsGroup                                   | User Group for ksql                                                  | 998                  |
| resources.requests.cpu                             | CPU for ksql-server container                                        | 500m                 |
| resources.requests.memory                          | Memory for ksql-server container                                     | 2Gi                  |
| resources.limits.cpu                               | Upper Limit for CPU that can be assigned                             | ""                   |
| resources.limits.memory                            | Upper Limit for memory that can be assigned                          | 4Gi                  |
| jobResources.requests.cpu                          | CPU requested for job                                                | 200m                 |
| jobResources.requests.memory                       | memory requested for job                                             | 1Gi                  |
| jobResources.limits.cpu                            | Max CPU that can be requested for job                                | ""                   |
| jobResources.limits.memory                         | Max memory that can be requested for job                             | 4Gi                  |
| initContainerResources.requests.cpu                | CPU requested for initContainer                                      | 100m                 |
| initContainerResources.requests.memory             | memory requested for initContainer                                   | 128Mi                |
| initContainerResources.limits.cpu                  | Max CPU that can be requested for initContainer                      | ""                   |
| initContainerResources.limits.memory               | Max memory that can be requested for initContainer                   | 256Mi                |
| helmTestResources.limits.cpu                       | helm test resources limits cpu                                       | 0.5                  |
| helmTestResources.limits.memory                    | helm test resources limits memory                                    | 256Mi                |
| helmTestResources.limits.ephemeral-storage         | helm test resources limits ephemeral-storage                         | 200M                 |
| helmTestResources.requests.cpu                     | helm test resources requests cpu                                     | 0.25                 |
| helmTestResources.requests.memory                  | helm test resources requests memory                                  | 128Mi                |
| helmTestResources.requests.ephemeral-storage       | helm test resources requests ephemeral-storage                       | 200M                 |
| podAnnotations                                     | Custom pod annotations                                               | {}                   |
| liveness.initialDelaySeconds                       | Liveness Probe Initial Delay                                         | 10                   |
| liveness.periodSeconds                             | Perform a liveness probe after every                                 | 15                   |
| readiness.initialDelaySeconds                      | Readiness Probe Initial Delay                                        | 10                   |
| readiness.periodSeconds                            | Perform a liveness probe after every                                 | 15                   |
| ksqlNodeSelector.enable                            | Enable to use node label feature                                     | FALSE                |
| ksqlNodeSelector.nodeLabel                         | Put a "key1" "value1" under this , if user defined labels are desired| nil                  |
| tolerationsForTaints.enable                        | Enable/Disable switch                                                | FALSE                |
| tolerationsForTaints.tolerations                   | Multiple tolerations can be added , an example is below              | nil                  |
| tolerationsForTaints.tolerations.key               | Label                                                                | <"key1">             |
| tolerationsForTaints.tolerations.operator          | Operators                                                            | <"Equal">            |
| tolerationsForTaints.tolerations.value             | Value for operator and key                                           | <"val1">             |
| tolerationsForTaints.tolerations.effect            | Which Toleration Effect should occure                                | <"NoSchedule">       |
| JmxExporter.enabled                                | Enable jmx exporter container                                        | TRUE                 |
| JmxExporter.imageRepo                              | Image Repository path to be added after the jmx registry             | "cpro/jmx-exporter"  |
| JmxExporter.imageTag                               | Image version                                                        | "v2.4.0"             |
| JmxExporter.imagePullPolicy                        | Image Pull Policy                                                    | "IfNotPresent"       |
| JmxExporter.port                                   | Port Number                                                          | 5556                 |
| JmxExporter.jmxResources.resources.requests.cpu    | CPU requested for JmxExporter                                        | 100m                 |
| JmxExporter.jmxResources.resources.requests.memory | memory requested for JmxExporter                                     | 1Gi                  |
| JmxExporter.jmxResources.resources.limits.cpu      | Max CPU that can be requested for JmxExporter                        | ""                   |
| JmxExporter.jmxResources.resources.limits.memory   | Max memory that can be requested for JmxExporter                     | 4Gi                  |
| ksql.headless                                      | Enable ksql headless mode                                            | FALSE                |
| ksql.ksqlQueriesConfigMapName                      | Configmap for queries file                                           | nil                  |
| ksql.queriesFileKey                                | Queries file key                                                     | nil                  |
| kafka.bootstrapServers                             | Kafka Bootstrap servers connection url with all brokers(comma seperated) | ""               |
| schema-registry.url                                | Schema-Registry connection url                                       | ""                   |
| configurationOverrides                             | KSQL configuration options                                           |                      |
| KafkaKsql.security.kafka.sasl.enabled              | Kafka SASL enabled                                                   | FALSE                |
| KafkaKsql.security.kafka.sasl.mechanism            | Kafka SASL mechanism                                                 | "GSSAPI"             |
| KafkaKsql.security.kafka.ssl.enabled               | Kafka SSL enabled                                                    | FALSE                |
| KafkaKsql.security.schema.ssl.enabled              | Schema-Registry SSL enabled                                          | FALSE                |
| KafkaKsql.security.schema.basicAuth.saslInheritAuthentication | With basic auth enabled use SASL_INHERIT as credential source | FALSE            |
| KafkaKsql.security.rest.ssl.enabled                | KSQL rest SSL enable                                                 | FALSE                |
| KafkaKsql.sasl.krb.krbConfigmapName                | Provide the krb5.conf as a configmap                                 | nil                  |
| KafkaKsql.sasl.krb.KrbConfKeyName                  | krb5.conf key name                                                   | nil                  |
| KafkaKsql.sasl.krb.kafka.krbSecretName             | Secret name containing principal-name and keytab                     | nil                  |
| KafkaKsql.sasl.krb.kafka.krbPrincipalKeyName       | Krb principal key name                                               | nil                  |
| KafkaKsql.sasl.krb.kafka.krbKeytabKeyName          | Krb keytab key name                                                  | nil                  |
| KafkaKsql.sasl.krb.kafka.krbSaslKerberosServiceName| Kerberos service name                                                | nil                  |
| KafkaKsql.sasl.plain.kafka.secretName              | Ckey secret name                                                     | nil                  |
| KafkaKsql.sasl.plain.kafka.usernameKey             | Ckey username key                                                    | nil                  |
| KafkaKsql.sasl.plain.kafka.passwordKey             | Ckey password key                                                    | nil                  |
| KafkaKsql.ssl.kafkarestssl.sslSecretName           | Put secret name configured according to kubernetes                   | <user-generated>     |
| KafkaKsql.ssl.kafkarestssl.sslKeyStoreLocationKey  | Key store Key                                                        | <user-generated>     |
| KafkaKsql.ssl.kafkarestssl.sslTrustStoreLocationKey| Truststore Key                                                       | <user-generated>     |
| KafkaKsql.ssl.kafkarestssl.sslKeyStorePassKey      | Keystore Password Key                                                | <user-generated>     |
| KafkaKsql.ssl.kafkarestssl.sslTrustStorePassKey    | Truststore Password Key                                              | <user-generated>     |
| KafkaKsql.ssl.kafkarestssl.sslKeyPassKey           | Keystore Key Password Key                                            | <user-generated>     |
| KafkaKsql.ssl.kafkarestssl.sslBasePath             | Base path for ssl certificates                                       | /etc/ksql/ssl/kafka  |
| KafkaKsql.ssl.kafkarestssl.clientAuth              | Client authentication is required                                    | FALSE                |
| KafkaKsql.ssl.schema.sslSecretName                 | Schema-Registry ssl secret name                                      | nil                  |
| KafkaKsql.ssl.schema.sslKeyStoreLocationKey        | KeyStore key                                                         | <user-generated>     |
| KafkaKsql.ssl.schema.sslTrustStoreLocationKey      | TrustStore key                                                       | <user-generated>     |
| KafkaKsql.ssl.schema.sslKeyStorePassKey            | KeyStore password key                                                | <user-generated>     |
| KafkaKsql.ssl.schema.sslTrustStorePassKey          | TrustStore password key                                              | <user-generated>     |
| KafkaKsql.ssl.schema.sslKeyPassKey                 | KeyStore key password key                                            | <user-generated>     |
| KafkaKsql.ssl.schema.sslBasePath                   | Base path for ssl certificates                                       | /etc/ksql/ssl/schema |
| enableDefaultCpuLimits                             | If enableDefaultCpuLimits set to true user can configure their own cpu limts | nil          |
| disablePodNamePrefixRestrictions                   | If disablePodNamePrefixRestrictions is true then there is no restriction limit for podnameprefix. Root level have more precedence than global level | nil
| installWithNewResourceNameConvention               | Enable this flag to set resource name with new HBP 3.7 convention. If the flag is set to true during upgrade, there can be data loss due to name change  | false 
| imageFlavor                                        | value needs to be mapped to the real container image repository/tag. | nil                  |
| imageFlavorPolicy                                  | container image flavor should be determined based on imageFlavorPolicy | BestMatch          |
| KafkaKsql.certificate.issuerRef.name  | issuer name for certificate object created by cert manager | ncms-ca-issuer |
| KafkaKsql.certificate.issuerRef.kind  | issuer kind for certificate object created by cert manager | ClusterIssuer |
| KafkaKsql.certificate.issuerRef.group  | issuer group for certificate object created by cert manager | cert-manager.io |
| KafkaKsql.certificate.duration  | duration for certificate object created by cert manager | 8760h |
| KafkaKsql.certificate.renewBefore  | renewBefore duration for certificate object created by cert manager | 360h |
| KafkaKsql.certificate.secretName  | secret name for certificate object created by cert manager | "" |
| KafkaKsql.certificate.subject  | subject name for certificate object created by cert manager | "" |
| KafkaKsql.certificate.commonName  | deprecated since 2000 and is discouraged from being used for a server side certificates | "" |
| KafkaKsql.certificate.usages  | set of x509 usages that are requested for the certificate | [] |
| KafkaKsql.certificate.dnsNames  | list of DNS subjectAltNames to be set on the Certificate. | [] |
| KafkaKsql.certificate.uris  | list of URI subjectAltNames to be set on the Certificate | [] |
| KafkaKsql.certificate.ipAddresses  | list of IP address subjectAltNames to be set on the Certificate | [] |
| KafkaKsql.certificate.keystores.jks.passwordSecretRef.name  | password for the keystore file to be provided as a secret. | "" |
| KafkaKsql.certificate.keystores.jks.passwordSecretRef.key  | password key in secret for the keystore file to be provided as a secret. | "" |
| KafkaKsql.certificate.keystores.jks.create  | add keystore password credentials in certificate object created by cert manager | true |
| KafkaKsql.certificate.privateKey.algorithm  | private key algorithm for certificate object created by cert manager. | "RSA" |
| KafkaKsql.certificate.privateKey.encoding  | private key encoding for certificate object created by cert manager. | "PKCS1" |
| KafkaKsql.certificate.privateKey.size  | private key size for certificate object created by cert manager. | "2048" |
| KafkaKsql.certificate.privateKey.rotationPolicy  | private key rotationPolicy for certificate object created by cert manager. | "Always" |
| podAntiAffinity.zone.type                 | zone level pod anti-affinity type            | ""                                         |
| podAntiAffinity.zone.topologyKey          | zone level pod anti-affinity topolog         | "topology.kubernetes.io/zone"              |
| podAntiAffinity.node.type                 | node level pod anti-affinity type            | ""                                         |
| podAntiAffinity.node.topologyKey          | node level pod anti-affinity topologyKey     | "kubernetes.io/hostname                    |
| podAntiAffinity.customRules               | list of objects with parameters defined for custom rule for pod anti affinity      | nil  |

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


### flatRegistry

Helm chart must support container registries with a flat structure.
global:
  flatRegistry: false

Example with flatRegistry false:
global:
  registry: csf-docker-delivered.repo.cci.nokia.net
  flatRegistry: false
image:
  imageRepo: ckaf/ckaf-ksql
  imageName: ckaf-ksql
  imageTag: 8.6.0-rocky8-jre17-7.4.1-8073

output: csf-docker-delivered.repo.cci.nokia.net/ckaf/ckaf-ksql:8.6.0-rocky8-jre17-7.4.1-8073

Example with flatRegistry true:
global:
  registry: <user-provided-registry>
  flatRegistry: true
image:
  imageRepo: ckaf/ckaf-ksql
  imageName: ckaf-ksql
  imageTag: 8.6.0-rocky8-jre17-7.4.1-8073

output: <user-provided-registry>/ckaf-ksql:8.6.0-rocky8-jre17-7.4.1-8073

# Deprecated variables from values.yaml
1) "init.imageName"
    Instead use "init.imageRepo"
2) "kubectlImageName"
    Instead use "kubectlImageRepo"
3) "imagename"
    Instead use "imageRepo"

If the user prefers to use deprecated varibales it is allowed to use by uncommenting the same from values.yaml.
Deprecated variables will be removed from values.yaml in future releases.

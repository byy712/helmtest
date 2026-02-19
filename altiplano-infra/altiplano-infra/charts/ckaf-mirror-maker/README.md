#MirrorMaker 2.0

Please refer to :

1. https://cwiki.apache.org/confluence/display/KAFKA/KIP-382%3A+MirrorMaker+2.0

### Parameters

The configuration parameters for the ckaf-mirror-maker chart.

| Parameter                                 | Description                                  | Default Value                              |
| ----------------------------------------  | -------------------------------------------- | ------------------------------------------ |
| podAntiAffinity.zone.type                 | zone level pod anti-affinity type            | ""                                         |
| podAntiAffinity.zone.topologyKey          | zone level pod anti-affinity topolog         | "topology.kubernetes.io/zone"              |
| podAntiAffinity.node.type                 | node level pod anti-affinity type            | ""                                         |
| podAntiAffinity.node.topologyKey          | node level pod anti-affinity topologyKey     | "kubernetes.io/hostname                    |
| podAntiAffinity.customRules               | list of objects with parameters defined for custom rule for pod anti affinity      | nil  |
| ipFamilyPolicy                            | ipFamilyPolicy configuration for dual-stack  | ""                                         |
| ipFamilies                                | ipFamilies configuration for dual-stack      | ""                                         |

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
  imageRepo: ckaf/ckaf-mirror-maker
  imageName: ckaf-mirror-maker
  imageTag: 8.6.0-rocky8-jre17-3.6.0-8073 

output: csf-docker-delivered.repo.cci.nokia.net/ckaf/ckaf-mirror-maker:8.6.0-rocky8-jre17-3.6.0-8073

Example with flatRegistry true:
global:
  registry: <user-provided-registry>
  flatRegistry: true
image:
  imageRepo: ckaf/ckaf-mirror-maker
  imageName: ckaf-mirror-maker
  imageTag: 8.6.0-rocky8-jre17-3.6.0-8073

output: <user-provided-registry>/ckaf-mirror-maker:8.6.0-rocky8-jre17-3.6.0-8073

# Deprecated variables from values.yaml
1) "init.imageName"
    Instead use "init.imageRepo"
2) "kubectlImageName"
    Instead use "kubectlImageRepo"
3) "image.name"
    Instead use "image.repository"

If the user prefers to use deprecated varibales it is allowed to use by uncommenting the same from values.yaml.
Deprecated variables will be removed from values.yaml in future releases.


# Install from charts

On orchestrated environment (BCMT or other), CITM ingress controller needs a default backend, when a request on a resource can't be resolved.

The default backend is a service which handles all URL paths and hosts the CITM nginx ingress controller doesn't understand (i.e., all the requests that are not mapped with an Ingress).

Basically a default backend exposes two URLs:

- /healthz that returns 200
- / that returns 404

CITM provides such default backend, with the ability to have a per application customization and rendering

## Introduction

This chart bootstraps an default404 deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.


## Pod Security Standards
Helm chart can be installed in namespace with `restricted` Pod Security Standards profile.

### Case with istio
Helm chart can be installed with istio-CNI enabled in the environment in namespace with `restricted` Pod Security Standards profile.

## Installing the Chart
To install the chart with the release name `my-release`:

```console
$ helm install --name my-release default404
**NOTE**: Release name cannot exceed 43 characters.
```

The command deploys default404 on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm delete my-release --purge
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following tables lists the configurable parameters of the default404 chart and their default values.

Parameter | Description | Default
------ | --------- | ---------------------------------------
backend.name | name of the default backend component | default404
backend.page.title | page title | 404 - Not found
backend.page.body | page body | The requested page was not found
backend.page.copyright | copyright | Nokia. All rights reserved
backend.page.productFamilyName | Product Family Name| CITM
backend.page.productName | Product name| Default backend
backend.page.productRelease | Product release | 4.0.4-6
backend.page.toolbarTitle | toolbar title | View more ...
backend.page.imageBanner | Image logo| Nokia_logo_white.svg
backend.page.port | listening port | 8080
backend.debug | activate debug log | false

See default [rendering](docker-default404.md#rendering)

You can also adapt following kubernetes parameters

Parameter | Description | Default
------ | --------- | ---------------------------------------
global.registry | default backend container image repository | csf-docker-delivered.repo.cci.nokia.net
global.disablePodNamePrefixRestrictions | disable pod name prefix restriction of chars limit 30 | false
global.podNamePrefix | ability to prefix ALL pod names with prefixes. Note that release-name can be truncated up to 12 chars when podNamePrefix is used. Helm release name can be up to 43 chars and also first 12 chars should be meaningful. | ""
global.containerNamePrefix |ability to prefix ALL container names with prefixes | ""
global.priorityClassName | See https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/#priorityclass | ""
global.labels | option to provide the global custom labels | {}
global.enableDefaultCpuLimits | enable pod CPU resources limit in containers | false
global.podSecurityPolicy.userProvided | to provide the custom/existing psp enable this flag | false
global.podSecurityPolicy.pspName | custom/existing psp name to be used, both rbac and global.podSecurityPolicy.userProvided needs to true | ""
global.ipFamilyPolicy | set preferred behaviour among SingleStack, PreferDualStack and RequireDualStack | ""
global.ipFamilies | set preferred ip families | []
global.dualStack.enabled | [DEPRECATED] enable or disable dualstack for resources
global.dualStack.ipFamilyPolicy |[DEPRECATED]  set preferred behaviour among SingleStack, PreferDualStack and RequireDualStack. Use global.ipFamilyPolicy instead | ""
global.dualStack.ipFamilies | [DEPRECATED] set preferred ip families. Use global.ipFamilies instead. | []
global.securityContext.runAsUser | User ID used for running the processes. Setting it to "auto" will assign a random UID | 1000
global.securityContext.runAsGroup | Group to be used. Setting it "auto" will assign a random group | 1000
global.securityContext.fsGroup | fsGroup to be used. Setting it "auto" will assign a random fsgroup | 1000
global.containerSecurityContext.enabled | enable or disable container security context at global level | false
global.containerSecurityContext.dropCapabilities | set the capabilities the need to be dropped | ALL
global.containerSecurityContext.runAsNonRoot | Run the container as non root user | true
global.containerSecurityContext.seccompProfile.type | set the type of seccompProfile to use | RuntimeDefault
global.containerSecurityContext.seccompProfile.path | set the path of Localhost profile in case type is set to Localhost | ""
global.containerSecurityContext.privilegeEscalation | Choose whether privilege escalation is allowed or not  | false
global.containerSecurityContext.readOnlyRootFS | Set the container root file system to read only | true
global.containerSecurityContext.seLinuxOptions.enabled | enable or disable seLinux options | false
global.containerSecurityContext.seLinuxOptions.level | Set the level  for seLinuxOptions | ""
global.containerSecurityContext.seLinuxOptions.role | Set the role  for seLinuxOptions | ""
global.containerSecurityContext.seLinuxOptions.type | Set the type  for seLinuxOptions | ""
global.containerSecurityContext.seLinuxOptions.user | Set the user  for seLinuxOptions | ""
custom.deployment.annotations | A list of annotation to be added to the pod | ""
disablePodNamePrefixRestrictions | disable pod name prefix restriction of chars limit 30 | ""
component | current chart component | "MessagingAndProtocols"
managedBy | chart managed by tiller or helm | "helm"
partOf | chart is part of |"citm"
imageRepo | default backend container image repository | citm/citm-default-backend 
imageTag | default backend container image tag | 4.0.4-6
imagePullPolicy | default backend container image pull policy | IfNotPresent
nodeSelector | node labels for pod assignment.See runOnEdge for edge node selection | {}
priorityClassName | See https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/#priorityclass | ""
affinity | Node affinity. See https://kubernetes.io/docs/tasks/configure-pod-container/assign-pods-nodes-using-node-affinity/ |
runOnEdge | If true, add a nodeSelector label in order to run default backend only on edge node | false
tolerations | node taints to tolerate (requires Kubernetes >=1.6) | []
replicaCount | desired number of default backend pods | 1
enableDefaultCpuLimits | enable pod CPU resources limit in containers | true
resources | default backend pod resource requests & limits | {}
probe.startup.path | path to send probe requests | /healthz
probe.startup.delay | inital delay seconds | 10
probe.startup.period | probe request interval | 10
probe.startup.timeout | timeout interval in seconds | 3
probe.startup.maxfailure | max number  of pod failures | 6
probe.liveness.path | path to send probe requests | /healthz
probe.liveness.delay | initial delay seconds | 5
probe.liveness.period | probe request interval | 5
probe.liveness.timeout | timeout interval in seconds | 3
probe.liveness.maxfailure | max number of pod failures | 5
probe.readiness.path | path to send probe requests | /healthz
probe.readiness.delay | intial delay seconds | 3
probe.readiness.period | probe request interval | 5
probe.readiness.timeout | timeout interval in seconds | 3
probe.readiness.maxfailure | max number of pod failures | 5
service.clusterIP | internal default backend cluster service IP | ""
service.externalIPs | default backend service external IP addresses | []
service.servicePort | default backend service port to create | 8080
service.type | type of default backend service to create | ClusterIP
service.ipFamilyPolicy | set preferred behaviour among SingleStack, PreferDualStack and RequireDualStack | ""
service.ipFamilies | set preferred ip families | []
service.dualStack.enabled | [DEPRECATED] enable or disable dualstack for resources
service.dualStack.ipFamilyPolicy |[DEPRECATED]  set preferred behaviour among SingleStack, PreferDualStack and RequireDualStack. Use service.ipFamilyPolicy instead. | ""
service.dualStack.ipFamilies | [DEPRECATED] set preferred ip families. Use service.ipFamilies instead. | []
securityContext.runAsUser | User ID used for running the processes. Setting it to "auto" will assign a random UID | 1000
securityContext.runAsGroup | Group to be used. Setting it "auto" will assign a random group | 1000
securityContext.fsGroup | fsGroup to be used. Setting it "auto" will assign a random fsgroup | 1000
containerSecurityContext.enabled | enable or disable container security context at workload level. preference foes to global setting | true
containerSecurityContext.dropCapabilities | set the capabilities the need to be dropped | ALL
containerSecurityContext.runAsNonRoot | Run the container as non root user | true
containerSecurityContext.seccompProfile.type | set the type of seccompProfile to use | RuntimeDefault
containerSecurityContext.seccompProfile.path | set the path of Localhost profile in case type is set to Localhost | ""
containerSecurityContext.privilegeEscalation | Choose whether privilege escalation is allowed or not  | false
containerSecurityContext.readOnlyRootFS | Set the container root file system to read only | true
containerSecurityContext.seLinuxOptions.enabled | enable or disable seLinux options | false
containerSecurityContext.seLinuxOptions.level | Set the level  for seLinuxOptions | ""
containerSecurityContext.seLinuxOptions.role | Set the role  for seLinuxOptions | ""
containerSecurityContext.seLinuxOptions.type | Set the type  for seLinuxOptions | ""
containerSecurityContext.seLinuxOptions.user | Set the user  for seLinuxOptions | ""
rbac.enabled | If true, create & use RBAC resources | true
rbac.serviceAccountName | Use this service account when rbac.enabled=false | default
rbac.podSecurityPolicy.enabled | if enabled, psp will be created and will be used in role | true
rbac.podSecurityPolicy.annotations | set annotations required for psp | seccomp.security.alpha.kubernetes.io/allowedProfileNames: '*'
istio.enabled | If true, create & use Istio Policy and virtualservice | false
istio.version | Istio version available in the cluster. For release upper or equal to 1.5, you can keep 1.5. There is only specific setting for Istio 1.4 | 1.5
istio.permissive | Allow mutual TLS as well as clear text for deployment | true
istio.cni.enabled | Whether istio cni is enabled in the environment | true
test.skipTest | disable or enable helm tests | false
pdb.enabled | Pod disruption budget will define minAvailable or maxUnavailable when there is disruption. Enable this flag to enable PodDistuptionBudget. | true
pdb.minAvailable | Minimum number of pods from the set that must still be available after the eviction. It can be either an absolute number or a percentage. | 1
pdb.maxUnavailable | Specify the number of pods that can be unavailable after the eviction. It can be either an absolute number or a percentage. | 0
terminationMessagePath | Kubernetes retrieves termination messages from the termination message file specified in the terminationMessagePath field of a Container | /dev/termination-log
terminationMessagePolicy | Set the terminationMessagePolicy field of a Container for further customization of the error message. <br> This field defaults to "File" which means the termination messages are retrieved only from the termination message file.  <br> By setting the terminationMessagePolicy to "FallbackToLogsOnError", you can tell Kubernetes to use the last chunk of container log output if the termination message file is empty and the container exited with an error.| FallbackToLogsOnError
topologySpreadConstraints | allows control of how pods are spread across cluster among failure-domains such as regions, zones, nodes, and other user-defined topology domains. This can help to achieve high availability as well as efficient resource utilization. Ref: [kubernetes.io Pod Topology Spread Constraints](https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/) | []
clusterDomain | If needed to communicate with an IP address which is outside of the hosted Kubernetes cluster, then it's suggested the IP to be exposed using clusterDomain | cluster.local
labels | default404 custom labels | {}
podLabels | speicify pod labels to add to the pod container metadata | {}
evenPodSpreadEnabled | allows user to ensure that EvenPodSpread feature gate is enabled | false

Alternatively, a YAML file (my-values.yaml) that specifies the values for the parameters can be provided while installing the chart.

```console
$ helm install default404 --name my-release -f my-values.yaml
```

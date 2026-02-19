# Install from charts

This chart bootstraps a citm-ingress controller deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Installing the Chart

To install the chart with the release name `my-release`:

```
$ helm install --name my-release citm-ingress
```

The command deploys nginx-ingress on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

This deploy also a default backend. The [default backend configuration](#default404) section lists the parameters that can be configured during installation for default backend.

**NOTE**: If you're installing a release upper than 1.16.5 (1.16.5 included), make sure configmap ingress-controller-leader-nginx does not exist. If it's present, remove it before installing the chart

```
$ kubectl delete cm ingress-controller-leader-nginx
```
## Updating the Chart

```
$ helm upgrade my-release citm-ingress
```

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```
$ helm delete my-release --purge
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

### Ingress controller

The following tables lists the configurable parameters of the nginx-ingress chart and their default values.

Parameter | Description | Default 
--------- | ----------- | ------- 
global.registry | default ingress controller container image repository | csf-docker-delivered.repo.cci.nokia.net
global.registry1 | Placeholder / Reserved for future repositories | csf-docker-delivered.repo.cci.nokia.net
global.podNamePrefix | ability to prefix ALL pod names with prefixes | ""
global.containerNamePrefix |ability to prefix ALL container names with prefixes | ""
global.timeZoneEnv | Timezone Name to be used by the pods | ""
global.timeZoneName | Deprecated!! Use timeZoneEnv instead of this | ""
global.labels | option to provide the global custom labels | {} 
global.podSecurityPolicy.userProvided | to provide the custom/existing psp enable this flag | false
gloabl.podSecurityPolicy.pspName | Use the custom/existing PSP, need to set global.podSecurityPolicy.userProvided needs to true to use this | ""
global.ipFamilyPolicy | set the behaviour of dual stack among SingleStack, PreferDualStack and RequireDualStack | ''
global.ipFamilies | set the ip families to be assigned to resource | []
global.dualStack.enabled | [DEPRECATED] enable or disable dual stack | false
global.dualStack.ipFamilyPolicy | [DEPRECATED] set the behaviour of dual stack among SingleStack, PreferDualStack and RequireDualStack. Use global.ipFamilyPolicy instead | ''
global.dualStack.ipFamilies | [DEPRECATED] set the ip families to be assigned to resource. Use global.ipFamilies instead. | []
global.securityContext.runAsUser | userid to be used. A value of "auto" will let kubernetes assigning a userId to the container | 1000
global.securityContext.runAsGroup | user group to be used. A value of "auto" will let kubernetes assigning a groupid to the container(victor-job only) | 1000
global.securityContext.fsGroup | fsGroup to be used. A value of "auto" will let kubernetes assigning a fs group to the container | 1000
gloabl.hpa.enabled | enable or disable HPA at global level | false
global.ephemeralVolume.generic.enabled | Enable of disable generic ephemeral volumes in global level | ""
global.unifiedLogging.syslog.enabled | Enable/Disable syslog. Check Syslog Configurations(#syslog-configuration) for configuring | false
global.unifiedLogging.syslog.host | Remote host to which logs has to be forwarded | ""
global.unifiedLogging.syslog.port | Remote port to which logs has to be forwarded | ""
global.unifiedLogging.syslog.protocol | Remote protocol to which logs has to be forwarded | ""
global.unifiedLogging.syslog.tls.secretRef.name | tls-secret resource name with the client certs. Should contain ca.crt, tls.key and tls.crt | ""
global.unifiedLogging.syslog.tls.secretRef.keyNames.caCrt | tls secret ca.crt key name | "ca.crt"
global.unifiedLogging.syslog.tls.secretRef.keyNames.tlsKey | tls secret tls.key key name | "tls.key"
global.unifiedLogging.syslog.tls.secretRef.keyNames.tlsCrt | tls secret tls.crt key name | "tls.crt"
global.unifiedLogging.extension | extension that will be added to logs. Added ONLY when Harmonized logging is enabled | {}
registry | controller container image repository| csf-docker-delivered.repo.cci.nokia.net 
component | current chart component | "MessagingAndProtocols"
managedBy | chart managed by tiller or helm | "helm"
partOf | chart is part of |"citm"
controller.name | name of the controller component | controller 
controller.imageRepo | controller image repository name | citm/citm-nginx
controller.imageTag | controller container image tag | 1.20.1-1.5
controller.imagePullPolicy | controller container image pull policy | IfNotPresent
controller.terminationMessagePath | Kubernetes retrieves termination messages from the termination message file specified in the terminationMessagePath field of a Container | /nginx-config/termination-log
controller.terminationMessagePolicy | Set the terminationMessagePolicy field of a Container for further customization of the error message. <br> This field defaults to "File" which means the termination messages are retrieved only from the termination message file.  <br> By setting the terminationMessagePolicy to "FallbackToLogsOnError", you can tell Kubernetes to use the last chunk of container log output if the termination message file is empty and the container exited with an error.| FallbackToLogsOnError
controller.activeDeadlineSeconds | The activeDeadlineSeconds applies to the duration of the job, no matter how many Pods are created | 300
controller.timezone.mountHostLocaltime | Flag to mount the /etc/localtime to pods | false
controller.timezone.timeZoneEnv | Timezone Name to be used by the pods, set controller.timezone.mountHostLocaltime to false to use this | ""
controller.timezone.timeZoneNameEnv | Deprecated!! Use timeZoneEnv instead of this. Timezone Name to be used by the pods, set controller.timezone.mountHostLocaltime to false to use this | ""
controller.preStop.command | This command will be used as part of lifecycle preStop hook , `/bin/sh -c '<USER_COMMAND>'` | ""
[controller.config](#configmap) | nginx ConfigMap entries | none 
[controller.customTemplate.configMapName](#custom-template) | configMap containing a custom nginx template | none
[controller.customTemplate.configMapKey](#custom-template) | configMap key containing the nginx template | none
controller.bindAddress | Sets the addresses on which the server will accept requests instead of *.<br>See [bind-address](docker-ingress-configmap.md#bind-address)| none 
controller.hostNetwork | If the nginx deployment / daemonset should run on the host's network namespace | true
[controller.dnsPolicy](#dnsconfig) | by ingress controller use hostnetwork, so default set to ClusterFirstWithHostNet | ClusterFirstWithHostNet
[controller.dnsConfig](#dnsconfig) | The dnsConfig field is optional and it can work with any dnsPolicy settings. However, when a Pod's dnsPolicy is set to "None", the dnsConfig field has to be specified. | 
controller.reusePort | enable "reuseport" option of the "listen" directive for nginx.<br>See [reuse-port](docker-ingress-configmap.md#reuse-port)| true
controller.disableIvp4 | disable Ipv4  for nginx.<br>See [disable-ipv4](docker-ingress-configmap.md#disable-ipv4)| false
controller.disableIvp6 | disable Ipv6  for nginx.<br>See [disable-ipv6](docker-ingress-configmap.md#disable-ipv6)| false
controller.enableHttp2OnHttp | Set it to true is you want http2 on http plain text | false
controller.disableHttpPortListening | Set it to true is you want to disable listening on http port | false
controller.securityContextPrivileged | set securityContext to Privileged | false
controller.workerProcessAsRoot | Required to start nginx worker process as root (default nginx) | false
[controller.sysctlRules](#sysctl) | A set of sysctl to be set | ""
controller.httpRedirectCode | set http-redirect-code.<br>See [http-redirect-code](docker-ingress-configmap.md#http-redirect-code) | 308
controller.defaultBackendService | default 404 backend service; required only if defaultBackend.enabled = false | ""
[controller.defaultSSLCertificate](#default-certificate) |  Optionally specify the secret name for default SSL certificate. Must be namespace/secret_name. See also (#cert-manager) | ""
[controller.defaultStreamSSLCertificate](#default-stream-certificate) |  Optionally specify the secret name for default Stream SSL certificate. Must be namespace/secret_name. See also (#cert-manager) | ""
controller.allowCertificateNotFound | If a ingress certificate is not found, use default certificate. Set this to false if you want to respond with HTTP 403 (access denied) instead of using default certificate | true
controller.allowInvalidCertificate| If a ingress certificate is present but invalid, use default certificate. Set this to false if you want to respond with HTTP 403 (access denied) instead of using default certificate | true
httpsForAllServers | If set to true, we force https on all ingress resources. If no certificate is provided for an ingress resource, default certificate will be used. You can overwrite it using [default certificate](#default-certificate). Also, if you want for a specific ingress an access to http (no 308 redirect to https), you can add [ssl-redirect](docker-ingress-annotations.md#server-side-https-enforcement-through-redirect) annotation and set it to false| false
controller.UdpServiceConfigMapNoNamespace | set to true to have all config map starting with this name udp-services-configmap, whatever the namespace will be added | false
controller.TcpServiceConfigMapNoNamespace | set to true to have all config map starting with this name tcp-services-configmap, whatever the namespace will be added | false
[controller.CalicoVersion](#calico) | if you want to activate ddiscovery of ipv6 endpoints. Endpoints are retrieved using calico CNI network subsystem.<br>Supported values are not-used, v1 or v3)  | not-used
[controller.splitIpv4Ipv6StreamBackend](#calico) | By default, create only one stream for all backends.<br>NOTE: In case of transparent proxy activated, this property is not taken into account (aka: we'll generate two different streams) | false
controller.healthzPort |  port for healthz endpoint. Default is to use httpPort. Overwrite this if you want another port for checking.<br>See [--healthz-port](docker-ingress-cli-arguments.md) ingress controller argument | none
controller.httpPort |  Indicates the port to use for HTTP traffic (default 80).<br>See [--http-port](docker-ingress-cli-arguments.md) ingress controller argument| none
controller.httpsPort |  Indicates the port to use for HTTPS traffic (default 443).<br>See [--https-port](docker-ingress-cli-arguments.md) ingress controller argument | none
controller.disableOcspStapling | Indicates if OCSP stapling should be disabled. Default false | false
controller.sslProtocols | Indicates ssl protocols to be used. Default TLS 1.2 and TLS 1.3 | TLSv1.3 TLSv1.2
controller.sslCiphers | Indicates ssl cipher list to be activated | TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
[controller.sslPasstroughProxyPort](tls.md#ssl-passthrough) |  Default port to use internally for SSL when SSL Passthgough is enabled (default 442).<br>See [--ssl-passthrough-proxy-port](docker-ingress-cli-arguments.md) ingress controller argument  | 442
[controller.sslPasstroughSplitPortListening](tls.md#ssl-passthrough) |  Split flow when ssl passthrough is activated. HTTPS with TLS termination is reachable on controller.httpsPort and SSL passthrough is reachable on controller.sslPasstroughProxyPort  | false
controller.statusPort |  Indicates the TCP port to use for exposing the nginx status page (default 18080).<br>See [--status-port](docker-ingress-cli-arguments.md) ingress controller argument  | none
controller.statusBindAddress | Sets the addresses on which the server will accept requests for metrics and healthz check. Default is pod ip,127.0.0.1| env.POD_IP,127.0.0.1
[controller.forcePort](#forceport) |  force http & https port to default (see forcePortHttp, forcePortHttps) |false
[controller.forcePortHttp](#forceport) | http port when forcePort is activated | 80
[controller.forcePortHttps](#forceport) | https port when forcePort is activated | 443
controller.electionID | election ID to use for the status update. <br>See [--election-id](docker-ingress-cli-arguments.md) ingress controller argument | ingress-controller-leader
controller.ingressClass | name of the ingress class to route through this controller. <br>To be used when deprecated kubernetes.io/ingress.class annotation is provided in ingress resource <br>See [--ingress-class](docker-ingress-cli-arguments.md) ingress controller argument  | nginx
controller.watchIngressWithoutClass | Process Ingress objects without ingressClass annotation/ingressClassName field | true
controller.ingressClassByName |Process IngressClass per name (additionally as per spec.controller) | false
controller.ingressClassResource.enabled | To create ingressClass resource or not | false
controller.ingressClassResource.name | Name of the ingressClass to be created | nginx
controller.ingressClassResource.default | Mark the ingressClass Resource as default | false
controller.ingressClassResource.controllerValue | Reference to the citm-ingress controller | k8s.io/ingress-nginx 
controller.labels | ingress controller custom labels | {}
controller.podLabels | labels to add to the pod container metadata | none
controller.priorityClassName | See https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/#priorityclass | ""
controller.publishService.enabled | Allows customization of the external service | none
controller.publishService.pathOverride | Allows overriding of the publish service to bind to | false
[controller.scope.enabled](#scope) | limit the scope of the ingress controller | false (watch all namespaces)
[controller.scope.namespace](#scope) | namespace to watch for ingress | "" (use the release namespace)
[controller.etcd.enabled](#calico) | enable  Configuration of the location of your etcd cluster | false
[controller.etcd.etcd_endpoints](#calico) | etcd endpoints list | none
[controller.etcd.ETCD_CA_CERT](#calico) | etcd ca cert file path | /etc/etcd/ssl/ca.pem
[controller.etcd.ETCD_CLIENT_CERT](#calico) | etcd client cert file path | /etc/etcd/ssl/etcd-client.pem
[controller.etcd./etc/etcd/ssl/etcd-client-key.pem](#calico) | etcd client key file path | /etc/etcd/ssl/etcd-client-key.pem
[controller.blockCidrs](#block)|A comma-separated list of IP addresses (or subnets), requests from which have to be blocked globally|None
[controller.whiteListCidrs](#block)|A comma-separated list of IP addresses (or subnets), requests from which access will be granded. When activated, all ips which are not part of this will be blocked|None
[controller.blockUserAgents](#block)|A comma-separated list of User-Agent, requests from which have to be blocked globally.<br>It's possible to use here full strings and regular expressions.
[controller.blockReferers](#block)|A comma-separated list of Referers, requests from which have to be blocked globally.<br>It's possible to use here full strings and regular expressions
controller.logToJsonFormat | to format log in json format | true
controller.logFormats.logFormatUpstream | to format upstream info log | '{"type":"log","level":"INFO","facility":"23","time":"$time_iso8601","timezone":"$clog_tz","process":"nginx","system":"CITM Ingress Controller","systemid":"$clog_systemid","host":"$hostname","log":{"message":"[$remote_addr] - [$remote_user] [$request] $status $body_bytes_sent [$http_referer] [$http_user_agent] $request_length $request_time [$proxy_upstream_name] $upstream_addr $upstream_response_length $upstream_response_time $upstream_status $req_id"}}'
controller.logFormats.logFormatStream | to format log_stream log | '{"type":"log","level":"INFO","facility":"23","time":"$time_iso8601","timezone":"$clog_tz","process":"nginx","system":"CITM Ingress Controller","systemid":"$clog_systemid","host":"$hostname","log":{"message":"Streaming $protocol $status $bytes_sent $bytes_received $session_time $connection $remote_addr:$remote_port $upstream_addr"}}'
controller.unifiedLogging.syslog.enabled | Enable/Disable syslog. Check Syslog Configurations(#syslog-configuration) for configuring | false
controller.unifiedLogging.extension | extension that will be added to logs. Added ONLY when Harmonized logging is enabled | {}
[controller.mainSnippet](#global-snippet)| Adds custom configuration to the main section of the nginx configuration | ""
[controller.httpSnippet](#global-snippet) | Adds custom configuration to the http section of the nginx configuration | ""
[controller.serverSnippet](#global-snippet) | Adds custom configuration to all the servers in the nginx configuration | ""
[controller.locationSnippet](#global-snippet) | Adds custom configuration to all the locations in the nginx configuration | ""
[controller.streamSnippet](#global-snippet) | Adds custom configuration to the stream section of the nginx configuration | {"ssl_protocols": "TLSv1.3 TLSv1.2;","ssl_session_cache": "shared:StreamSSL:10m;","ssl_session_timeout": "10m;","ssl_session_tickets": "off;","ssl_ciphers": "TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384';","ssl_prefer_server_ciphers": "on;","ssl_ecdh_curve": "auto;"}
[controller.extraArgs](#extraargs) | Additional controller container [argument](docker-ingress-cli-arguments.md) | {}
controller.kind | install as Deployment or DaemonSet | DaemonSet
controller.tolerations | node taints to tolerate (requires Kubernetes >=1.6) | []
controller.runOnEdge | add a nodeSelector label in order to run only on edge node. Set this to false if you do not want only edge node | true
controller.nodeSelector | node labels for pod assignment. For is_edge label, considere setting runOnEdge | {}
controller.affinity | Node affinity. See https://kubernetes.io/docs/tasks/configure-pod-container/assign-pods-nodes-using-node-affinity/ | {}
controller.podAnnotations | annotations to be added to pods | {}
controller.replicaCount | desired number of controller pods | 1
controller.resources | controller pod resource requests & limits | {}
controller.ephemeralVolume.emptyDir.medium | emptyDir medium to use blank for disk storage and Memory for in memory, with size limit(set at resources.limits.ephemeral-storage)  beyond which pod eviction will happen(controller.ephemeralVolume should be disabled) | empty
controller.ephemeralVolume.generic.enabled| enable ephemeral volume instead of emptyDir | false
controller.ephemeralVolume.generic.storageClass| storage classs of the ephemeral volume | "vsphere"
controller.service.enabled | enable controller service | true
controller.service.annotations | annotations for controller service | {}
controller.service.clusterIP | internal controller cluster service IP | ""
controller.service.sessionAffinity | Session Affinity to make sure that connections from a particular client are passed to the same Pod each time. | Empty
controller.service.externalIPs | controller service external IP addresses | []
controller.service.loadBalancerIP | IP address to assign to load balancer (if supported) | ""
controller.service.loadBalancerSourceRanges | list of IP CIDRs allowed access to load balancer (if supported) | []
controller.service.targetPorts.http | Sets the targetPort that maps to the Ingress' port 80 | 80
controller.service.targetPorts.https | Sets the targetPort that maps to the Ingress' port 443 | 443
controller.service.ipFamilyPolicy | set the behaviour of dual stack among SingleStack, PreferDualStack and RequireDualStack | ''
controller.service.ipFamilies | set the ip families to be assigned to resource | []
controller.service.dualStack.enabled | [DEPRECATED] enable or disable dual stack | false
controller.service.dualStack.ipFamilyPolicy | [DEPRECATED] set the behaviour of dual stack among SingleStack, PreferDualStack and RequireDualStack. Use controller.service.ipFamilyPolicy instead | ''
controller.service.dualStack.ipFamilies | [DEPRECATED] set the ip families to be assigned to resource. Use controller.service.ipFamilies instead. | []
controller.service.type | type of controller service to create | ClusterIP
controller.service.nodePorts.http | If controller.service.type is NodePort and this is non-empty, it sets the nodePort that maps to the Ingress' port 80 | ""
controller.service.nodePorts.https | If controller.service.type is NodePort and this is non-empty, it sets the nodePort that maps to the Ingress' port 443 | ""
controller.service.allocateLoadBalancerNodePorts |  Optionally disable node port allocation for a service.type: LoadBalancer | true |
controller.serviceOnStream.enable | Defines if on UDP/TCP service, request are forwarded to k8s service instead of backends. Needed by Istio for stream. | false
[controller.dynamicUpdateServiceStream](#dynamicupdateservicestream) | Defines if on UDP/TCP service stream, services are dynamically updated. | false
[rbac.enabled](#rbac) | If true, create & use RBAC resources for ingress controller | true
[rbac.serviceAccountName](#rbac) | ServiceAccount to be used (ignored if rbac.enabled=true) | default
[rbac.podSecurityPolicy.enabled](#rbac) | Create a psp for hostNetwork (ports below 1024) and setcap (allowPrivilegeEscalation). Ignored  if rbac.enabled=false) | true
[controller.snippetNamespaceAllowed](#snippet-authorize) | Restrict usage of Lua code in Snippet annotation only for a subset of namespace. By default, all namespaces can use Lua code in snippet body | ""
[controller.deniedInSnippetCode](#snippet-authorize) | Set of pattern to check. If found in snippet body, annotation is ignored. Modify with care | "access_by_lua body_filter_by_lua content_by_lua header_filter_by_lua init_by_lua init_worker_by_lua log_by_lua rewrite_by_lua set_by_lua"
[controller.customLuaModules.enabled](#custom-lua) | enable possibility of providing ConfigMap with lua modules | false
[controller.customLuaModules.modules](#custom-lua) | list of custom lua modules. Each module consists of name (moduleName) and ConfigMap name with lua sources (sourcesConfigMapName) | none
[controller.modsecurity.enables](#mod-security) | Set this to true if you want to activate modsecurity globally | false
[controller.modsecurity.enableOwaspCrs](#mod-security) | Set this to true if you want to activate OWASP ModSecurity core rule set (CRS). See https://modsecurity.org/crs/ | false
|securityContext.runAsUser | userid to be used. A value of "auto" will let kubernetes assigning a userId to the container | 1000
|securityContext.runAsGroup | user group to be used. A value of "auto" will let kubernetes assigning a groupid to the container(victor-job only) | 1000 
|securityContext.fsGroup | fsGroup to be used. A value of "auto" will let kubernetes assigning a fs group to the container | 1000 
|securityContext.readOnlyRootFilesystem | set readOnlyRootFilesystem | true
[certManager.used](#cert-manager) | Use cert-manager service for generating default certificate | false
[certManager.duration](#cert-manager) | Duration of the generated certificate |   8760h # 365d
[certManager.renewBefore](#cert-manager) | Time before expiration for renewing the certificate | 360h # 15d
[certManager.keySize](#cert-manager) | certificate key size | 2048
[certManager.api](#cert-manager) | cert manager api version | v1
[certManager.organization](#cert-manager) | set of organization | Nokia
[certManager.servername](#cert-manager) | your server name (FQDN) |
[certManager.dnsNames](#cert-manager) | List of dns names to be associated with this certificate | Empty by default. Will also use value provided in security.servername
[certManager.ipAddresses](#cert-manager) | List of server ipAddresses |
[certManager.issuerRef.name](#cert-manager)      | Issuer name to be used by cert-manager                     |   ncms-ca-issuer                                   |
[certManager.issuerRef.kind](#cert-manager)      | Issuer kind to be used by cert-manager                     | ClusterIssuer                                     |
[certManager.issuerRef.group](#cert-manager)      | Issuer group to be used by cert-manager                     | cert-manager.io                                     |
istio.enabled | If true, create & use Istio Policy | false
istio.version | Istio version available in the cluster. For release upper or equal to 1.5, you can keep 1.5 or specify the exact version. There is only specific setting for Istio 1.4 | 1.11.4
istio.permissive | Allow mutual TLS as well as clear text for deployment | true
[tcp](#stream-backend) | TCP service key:value pairs | {}
forceTcp | Dummy TCP port and actual service key:value pairs  | {}
[udp](#stream-backend) | UDP service key:value pairs | {}
forceUdp | Dummy UDP port and actual service key:value pairs  | {}
[grafanaSecret](#grafana) | Name of the secret that contains the grafana credentials | {}
[grafanaURL](#grafana) |  URL and port of the grafana server, without 'http:// | {}
[grafanaProtocol](#grafana) | Protocol to be used with grafanaURL | "https"
[grafanaTools.overwriteDashboard](#grafana) | If exist, replace current CITM ingress controller dashboard | true

[metrics](#enable-metrics) |  Set this to true if you want metrics witout Grafana rendering | false

### default404
You can also adapt following parameters for default backend

Parameter | Description | Default
--------- | ----------- | ------- 
defaultBackend.enabled | If false, controller.defaultBackendService must be provided | true
[defaultBackend.serviceName](#nameOverride) | Provide name of the created default backend. Usefull when `nameOverride` or `fullnameOverride` is provided | Default is `Namespace`/`Name`-default404
[default404.rbac.enabled](#rbac) | If true, create & use RBAC resources for default backend | true
default404.nodeSelector | node labels for pod assignment. See default404.runOnEdge for edge node selection | {} 
default404.priorityClassName | See https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/#priorityclass | ""
default404.runOnEdge | If true, add a nodeSelector label in order to run default backend only on edge node | false
default404.tolerations | node taints to tolerate (requires Kubernetes >=1.6) | []
default404.affinity | Node affinity. See https://kubernetes.io/docs/tasks/configure-pod-container/assign-pods-nodes-using-node-affinity/ | {}
default404.replicaCount | desired number of default backend pods | 1 
default404.resources | default backend pod resource requests & limits | {}
default404.service.service.clusterIP | internal default backend cluster service IP | ""
default404.service.service.externalIPs | default backend service external IP addresses | []
default404.service.service.servicePort | default backend service port to create | 8080 
default404.service.service.type | type of default backend service to create | ClusterIP
default404.rbac.enabled | If true, create & use RBAC resources | true
default404.rbac.serviceAccountName | Use this service account when default404.rbac.enabled=false | default
default404.istio.enabled | If true, create & use Istio Policy and virtualservice | false
default404.istio.version | Istio version available in the cluster. For release upper or equal to 1.5, you can keep 1.5 or specify the exact version. There is only specific setting for Istio 1.4 | 1.11.4
default404.istio.permissive | Allow mutual TLS as well as clear text for deployment | true
default404.istio.cni.enabled | Whether istio cni is enabled in the environment | false
default404.backend.page.title | page title of default http backend | 404 - Not found
default404.backend.page.body | page body of default http backend | The requested page was not found
default404.backend.page.copyright | copyright of default http backend | Nokia. All rights reserved
default404.backend.page.productFamilyName | Product Family Name of default http backend| Nokia
default404.backend.page.productName | Product name of default http backend | 
default404.backend.page.productRelease | Product release of default http backend | 
default404.backend.page.toolbarTitle | toolbar title of default http backend | View more ...
default404.backend.page.imageBanner | Image logo of default http backend| Nokia_logo_white.svg
default404.backend.debug | activate debug log of default http backend | false

See default404 [rendering](docker-default404.md#rendering)

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```
$ helm install citm-ingress --name my-release -f values.yaml
```

## Run examples

### calico

If you want to retrieve ipv6 endpoints, using calico CNI release 3

```
$ helm install citm-ingress --set controller.etcd.enabled=true,controller.CalicoVersion=v3,controller.etcd.etcd_endpoints="https://192.168.1.2:2379"
```
### block
Hereafter, various ways to block incoming request, based on cidr, user-agent or referer.

#### blockCidrs

A comma-separated list of IP addresses (or subnets), request from which have to be blocked globally.

References: http://nginx.org/en/docs/http/ngx_http_access_module.html#deny

If you want to block 192.168.1.0/24 and 172.17.0.1 and 2001:0db8::/32

```
$ helm install citm-ingress --set controller.blockCidrs="192.168.1.0/24\,172.17.0.1\,2001:0db8::/32"
```

#### whiteListCidrs

A comma-separated list of IP addresses (or subnets), request will be granded. All ips which are not part of this will be blocked.

References: http://nginx.org/en/docs/http/ngx_http_access_module.html#deny

If you want to allow only 192.168.2.0/24 and 172.17.0.2 and 2002:0db8::/32

```
$ helm install citm-ingress --set controller.whiteListCidrs="192.168.2.0/24\,172.17.0.2\,2002:0db8::/32"
```

#### blockUserAgents
A comma-separated list of User-Agent, requestst from which have to be blocked globally. It's possible to use here full strings and regular expressions. 

More details about valid patterns can be found at map Nginx directive documentation.

References: http://nginx.org/en/docs/http/ngx_http_map_module.html#map

If you want to block curl/7.63.0 and Mozilla/5.0 user agent incoming request

```
$ helm install citm-ingress --set controller.blockUserAgents="curl/7.63.0\,~Mozilla/5.0"
```

#### blockReferers
A comma-separated list of Referers, requestst from which have to be blocked globally. It's possible to use here full strings and regular expressions. 

More details about valid patterns can be found at map Nginx directive documentation.

References: http://nginx.org/en/docs/http/ngx_http_map_module.html#map

If you want to block request having referrer security.com/ or www.example.org/galleries/ or something containing google
```
$ helm install citm-ingress --set controller.blockReferers="security.com/\,www.example.org/galleries/\,~\.google\."
```

### dnsconfig

See [https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/)

If you want to specify your own dns configuration for ingress controller pod, set dnsPolicy to `None`

```
$ cat input.yaml 
controller:
  dnsPolicy: "None"
  dnsConfig:
    nameservers:
      - 1.2.3.4
    searches:
      - ns1.svc.cluster-domain.example
      - my.dns.search.suffix
    options:
      - name: ndots
        value: "2"
      - name: edns0
```

```
$ helm install citm-ingress -f input.yaml
```
### Monitoring

#### enable-metrics
You can activate metrics on vhost and stream. 

Also, make sure `127.0.0.1` belongs to `statusBindAddress` (which is the case by default)

```
$ helm install citm-ingress --set metrics=true
```

Rendering is available at

* http://edge_ip:18080/nginx-console/status.html (this one integrate streamStatus and vhostStatus in the same page)
* http://edge_ip:18080/vhostStatus
* http://edge_ip:18080/streamStatus
* http://edge_ip:18080/nginx_status

* Prometheus metrics are available at http://edge_ip:9913/metrics

18080 is the default port for status page. See controller.statusPort

#### grafana
grafana secret is built using grafana helm release and -cpro-grafana. 

grafanaURL is the url of grafana service, or IP of pod. Port 3000 is the port for importing dashboard

Refer to CPRO user guide

```
$ helm install citm-ingress --set grafanaSecret=grafana-cpro-grafana,grafanaURL=192.168.2.54:3000
```

#### FIXME Rendering to be put here

### configmap
You can add any of supported [configmap attribute](docker-ingress-configmap.md) using controller.config

Example, to disable ipv6 listening, use http2 for ssl connection and set http2-max-field-size to 12345

```
$ helm install citm-ingress --set controller.config.disable-ipv6=true --set controller.config.http2-max-field-size=12345 --set controller.config.use-http2=true
```

To set log level at debug in nginx
```
$ helm install citm-ingress --set controller.config.error-log-level=debug
```

### Security

#### cert-manager
citm-ingress supports cert-manager. You can use cert-manager for specifying default ssl certificate and default-stream-ssl-certificate. This overwrite controller.defaultSSLCertificate and controller.defaultStreamSSLCertificate
```
$ helm install citm-ingress --set certManager.used=true,certManager.servername=foo.bar.com
```
or using an input file
```
$ cat input.yaml 
certManager:
  used: true
  servername: foo.bar.com
  ipAddresses: 
  - 127.0.0.1
  - 127.0.0.2 
  dnsNames: 
  - "*.foo.bar.com"
```

```
$ helm install --name citm-ab --namespace ab citm-ingress -f input.yaml
```
Content of generated secret
```
# kubectl -n ab describe secrets tls-citm-ab-citm-ingress 
Name:         tls-citm-ab-citm-ingress
Namespace:    ab
Labels:       <none>
Annotations:  cert-manager.io/alt-names: foo.bar.com
              cert-manager.io/certificate-name: tls-citm-ab-citm-ingress
              cert-manager.io/common-name: foo.bar.com
              cert-manager.io/ip-sans: 127.0.0.1,127.0.0.2
              cert-manager.io/issuer-kind: ClusterIssuer
              cert-manager.io/issuer-name: ncms-ca-issuer
              cert-manager.io/uri-sans: 

Type:  kubernetes.io/tls

Data
====
ca.crt:   1257 bytes
tls.crt:  1277 bytes
tls.key:  1679 bytes
```

#### default-certificate

By default, CITM ingress controller provide a default Fake certificate, self signed. You can use [cert manager](#cert-manager) or create your own certificate.

Hereafter, how to use a created certificate named mysecret

```
$ CERT_NAME=mysecret
$ KEY_FILE=/tmp/${CERT_NAME}.key
$ CERT_FILE=/tmp/${CERT_NAME}.crt
$ HOST=$(hostname -s)
$ openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ${KEY_FILE} -out ${CERT_FILE} -subj "/CN=${HOST}/O=Nokia"
$ kubectl create secret tls ${CERT_NAME} --key ${KEY_FILE} --cert ${CERT_FILE}
$ rm -f $KEY_FILE $CERT_FILE
$ kubectl get secret mysecret
NAME       TYPE                DATA      AGE
mysecret   kubernetes.io/tls   2         15s

$ kubectl describe secret mysecret
Name:         mysecret
Namespace:    default
Labels:       <none>
Annotations:  <none>

Type:  kubernetes.io/tls

Data
====
tls.crt:  1135 bytes
tls.key:  1704 bytes
```
Now, you can use it when deploying CITM ingress chart
```
$ helm install citm-ingress --set controller.defaultSSLCertificate=default/mysecret
```
Note that templating is supported, so something like this will be correctly expanded (using a values.yaml)
```
controller:
  defaultSSLCertificate: "{{ .Release.Namespace }}/mysecret"
```
```
$ helm install citm-ingress -f values.yaml
```

#### default-stream-certificate

By default, CITM ingress controller provide a default Fake certificate, self signed. You can use [cert manager](#cert-manager) or create your own certificate and pass the same(in the form of namespace/secret) for the defaultStreamSSLCertificate during installation.

```
helm install citm-ingress --set controller.defaultStreamSSLCertificate=default/mysecret
```


#### modsecurity
You may want to activate ModSecurity (WAF) globally. CITM ingress comes with a minimum set of rules.

OWASP ModSecurity Core Rule Set (CRS) can aslo be activated, thanks to enableOwaspCrs

```
$ helm install citm-ingress --namespace ab --set controller.modsecurity.enabled=true,controller.modsecurity.enableOwaspCrs=true
```

#### global-snippet
They allow to customize nginx.conf when this is not possible by using an annotation, ingress controller argument, and so on

This can be done at main/http/server/location levels.

See snippet [examples](snippet.md#global-snippet-code)

If you want to customize for a specific ingress, use [snippet annotation](ingress.md#snippet-code)

#### snippet-authorize
You can restrict usage of Lua code in Snippet annotation only for a subset of namespace. By default, check is not activated

To allow Snippet code with Lua code only in foo and bar namespaces, set controller.snippetNamespaceAllowed to "foo bar"

```
$ helm install citm-ingress --set controller.snippetNamespaceAllowed="foo bar"
```
You can also overwritte checked pattern which are denied by providing (controller.deniedInSnippetCode). 

Setting this parameter to something else than the default provided, ONLY if you know what you're doing.

### rbac
By default, RBAC is enabled for citm-ingress and default404. If for any reason, you want to disable, set rbac.enabled to false and default404.rbac.enabled false
You can provide your own ServiceAccount (`rbac.serviceAccountName`, `default404.rbac.serviceAccountName`). In that case, check [which ressources](rbac.md) are needed. 

### nameOverride

* fullnameOverride

```
$ helm install --namespace ab --name citm-ab ./citm-ingress --set fullnameOverride=kiki34,default404.fullnameOverride=kikid404,defaultBackend.serviceName=ab/kikid404  
$ kubectl -n ab get pods,svc -o wide
NAME                            READY   STATUS    RESTARTS   AGE     IP               NODE             NOMINATED NODE   READINESS GATES
pod/kiki34-5zhlc                1/1     Running   0          2m57s   172.16.2.8       bcmt-edge-02     <none>           <none>
pod/kiki34-jtn8v                1/1     Running   0          2m57s   172.16.2.7       bcmt-edge-01     <none>           <none>
pod/kikid404-6c7f855ffc-54ksg   1/1     Running   0          2m57s   192.168.56.155   bcmt-worker-02   <none>           <none>

NAME                     TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE     SELECTOR
service/kiki34           ClusterIP   None             <none>        8089/TCP,8087/TCP   2m57s   app=citm-ingress,component=controller,release=citm-ab
service/kikid404         ClusterIP   10.254.55.188    <none>        8080/TCP            2m57s   app=default404,component=default404,release=citm-ab
With nameOverride
```

* nameOverride

```
$ helm install --namespace ab --name citm-ab ./citm-ingress --set nameOverride=kiki34,default404.nameOverride=kikid404,defaultBackend.serviceName=ab/citm-ab-kikid404 
$ kubectl -n ab get pods,svc -o wide
NAME                                    READY   STATUS    RESTARTS   AGE   IP                NODE             NOMINATED NODE   READINESS GATES
pod/citm-ab-kiki34-gvpfq                1/1     Running   0          82s   172.16.2.7        bcmt-edge-01     <none>           <none>
pod/citm-ab-kiki34-q68h5                1/1     Running   0          82s   172.16.2.8        bcmt-edge-02     <none>           <none>
pod/citm-ab-kikid404-77c9568fcf-7crcx   1/1     Running   0          82s   192.168.137.132   bcmt-worker-01   <none>           <none>

NAME                       TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE   SELECTOR
service/citm-ab-kiki34     ClusterIP   None             <none>        8089/TCP,8087/TCP   82s   app=kiki34,component=controller,release=citm-ab
service/citm-ab-kikid404   ClusterIP   10.254.78.226    <none>        8080/TCP            82s   app=kikid404,component=default404,release=citm-ab
```

### sysctl

You may need to adapt low system setting when running on edge nodes. For example

```
controller: 
  sysctlRules:
    - "fs.file-max=100000"
    - "vm.swappiness=1"
    - "net.core.rmem_max=16777216"
    - "net.core.wmem_max=16777216"
```

Keep in mind that you may need to have root privilege, so activate `controller.securityContextPrivileged` if needed

For listening on VIP (non local address), you may need to provide also

```
controller: 
  sysctlRules:
    - "net.ipv4.ip_nonlocal_bind=1"
    - "net.ipv6.ip_nonlocal_bind=1"
```

See [How to bind to an ip that is nonlocal](faq.md#how-to-bind-to-an-ip-address-that-is-nonlocal)

### forceport

If you want to split incoming traffic (oam and internal, for example), you can achieve this by setting differents [bind address](docker-ingress-configmap.md#bind-address)

Since both ingress controller will listen on same port (but differents ips), you need to mislead kubernetes, telling him that I will runs on ports xxx and yyy, but in fact it will be 80 and 443

If you need to adapt 80 and 443, use forcePortHttp and forcePortHttps (in the sample hereafter, we'll use 92 and 449)

ingress controller 1, will listen http/92 and https/449 on 10.76.75.7

```
$ cat input.yaml 
controller:
  httpPort: 921
  httpsPort: 4491
  statusPort: 93
  bindAddress: 10.76.75.7
  forcePort: true
  forcePortHttp: 92
  forcePortHttps: 449
```
ingress controller 2, will listen http/92 and https/449 on 10.76.75.8

```
$ cat input2.yaml 
controller:
  httpPort: 922
  httpsPort: 4492
  statusPort: 94
  bindAddress: 10.76.75.8
  forcePort: true
  forcePortHttp: 92
  forcePortHttps: 449
```

Complete example [how to setup 2 ingress-controller both listening on same port on edge node](faq.md#how-to-setup-2-ingress-controller-both-listening-on-port-80-and-443-on-same-edge-node)

### scope
By default, CITM ingress controller track all namespaces (ClusterRole)

You can configure it to track only one namespace (Role). In that case, CITM ingress controller also needs to be deployed in this namespace. 

If controller.scope.namespace is not specified, the namespace associated with your release is used.

**NOTE**: If rbac is activated, Kubernetes roles and policies will be declared accordinglly.

```
$ helm install citm-ingress --namespace ab --set controller.scope.enabled=true,controller.scope.namespace=ab 
```

### serviceAccount

If you provide your own service account, the famous kiki34

```
$ helm install citm-ingress --set rbac.enabled=false,rbac.serviceAccountName=kiki34,default404.rbac.enabled=false,default404.rbac.serviceAccountName=kiki34
```

### stream-backend
Use this to provide description of TCP/UDP services to be exposed by CITM ingress controller. 

The syntax should follow a key,value pair

The key indicates the external port to be used. The value is a reference to a Service in the form "namespace/name:port", where "port" can either be a port number or name. 

TCP ports 80 and 443 (or controller.service.nodePorts.http[s]) are reserved by the controller for servicing HTTP[S] traffic

Example, to declare a TCP service tcpServer on port 2019 and another one on port 2018. Also, an UDP service on port 2020. Namespace is set to default

```
$ helm install citm-ingress --set tcp.2019=default/tcpServer:2019 --set tcp.2018=default/tcpServer:2018 --set udp.2020=default/udpServer:2020
```
Same using a values.yaml
```
tcp: 
  2018: default/tcpServer:2018
  2019: default/tcpServer:2019
udp:
  2020: default/udpServer:2020
```

```
$ helm install citm-ingress -f values.yaml
```
Note that templating is supported, so something like this will be correctly expanded
```
tcp: 
  2015: "{{ .Release.Namespace }}/{{ .Release.Name }}-tcpserver2018:2018"
```
Check [TCP/UDP services](tcp-udp.md#dynamic-configuration) for dynamic declaration of udp/tcp services 

### dynamicUpdateServiceStream

When using dynamic declaration of TCP/UDP backends, ports associated with their services need to be linked with CITM ingress controller. See [how to](tcp-udp.md#ingress-controller-service) for linking ports to CITM ingress controller service.

### custom-template

The NGINX template is located in the file /etc/nginx/template/nginx.tmpl.

It is possible to use a custom template. This can be achieved by using a Configmap as source of the template

!!! Warning "Please note the template is tied to the Go code"

- Do not change names in the variable $cfg."

- For more information about the template syntax please check the [go template package](https://golang.org/pkg/text/template/)

This being said, just create a config map containing your template

??? "nginx.tmpl template"

    ```
    --8<-- "samples/nginx.tmpl"
    ```

And create the config map

```
$ kubectl create -n ab cm nginx-tmpl --from-file nginx.tmpl
```

And use it when deploying the chart

```
$ helm install  --name citm-ab --namespace ab citm-ingress --set controller.customTemplate.configMapName=nginx-tmpl,controller.customTemplate.configMapKey=nginx.tmpl
```

### custom-lua
This allow you to separate lua library from snippet code using it.

Complete example:

- a config map description (`helloworldlua.yaml`) containing code of your lua module library
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: helloworldlua
data:
  helloworldlua.lua: |+
    hw = {}
    function hw.sayHello()
      ngx.say('Hello, world kiki!')
    end
    return hw
```

- An ingress resource (`ingress.yaml`) making reference to this lua library and using it. In the example, a tomcat server
```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/configuration-snippet: | 
      access_by_lua_block {
        local hw = require "helloworldlua"
        hw.sayHello()
      }
spec:
  rules:
  - http:
      paths:
      - path: /tomcat
        backend:
          serviceName: tomcat
          servicePort: 8080
...
```
- The `input.yaml` to be provided for loading this module in nginx
```
controller:
  customLuaModules:
    enabled: true
    modules:
      - moduleName: helloworldlua
        sourcesConfigMapName: helloworldlua
```
- Deploy the all things
```
$ kubectl -n ab create -f helloworldlua.yaml
$ kubectl -n ab create -f ingress.yaml
$ helm install --name citm-ab --namespace ab citm-ingress -f input.yaml
```
- Test it
```
$ kubectl -n ab get pods,svc,ing,cm -o wide
NAME                                            READY   STATUS      RESTARTS   AGE    IP                NODE                                     NOMINATED NODE   READINESS GATES
pod/citm-ab-citm-ingress-controller-74ndk       1/1     Running     0          16m    172.30.253.7      bcmt-sandbox1-3c7w2e-2003-s1-edge-01     <none>           <none>
pod/citm-ab-citm-ingress-controller-w9ms2       1/1     Running     0          16m    172.30.253.6      bcmt-sandbox1-3c7w2e-2003-s1-edge-02     <none>           <none>
pod/citm-ab-default404-5bc6dc7d99-94x28         1/1     Running     0          16m    192.168.133.93    bcmt-sandbox1-3c7w2e-2003-s1-worker-06   <none>           <none>
pod/tomcat-67ccb45b47-vrhfg                     1/1     Running     0          50m    192.168.133.120   bcmt-sandbox1-3c7w2e-2003-s1-worker-06   <none>           <none>

NAME                                      TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE    SELECTOR
service/citm-ab-citm-ingress-controller   ClusterIP   None             <none>        8089/TCP,8087/TCP   17m    app=citm-ingress,component=controller,release=citm-ab
service/citm-ab-default404                ClusterIP   10.254.63.95     <none>        8080/TCP            17m    app=default404,component=default404,release=citm-ab
service/tomcat                            ClusterIP   10.254.194.217   <none>        8080/TCP            50m    k8s-app=tomcat

NAME                                HOSTS   ADDRESS                      PORTS   AGE
ingress.extensions/webapp-ingress   *       10.76.184.122,10.76.184.73   80      50m

NAME                                        DATA   AGE
configmap/citm-ab-citm-ingress-controller   16     17m
configmap/citm-ab-citm-ingress-tcp          0      17m
configmap/citm-ab-citm-ingress-udp          0      17m
configmap/helloworldlua                     1      17m
configmap/ingress-controller-leader-nginx   0      17m
```

```
$ curl -k https://172.30.253.7:8087/tomcat
Hello, world kiki!
```

### extraargs
You can add any of supported [arguments](docker-ingress-cli-arguments.md) using controller.extraArgs

Example, to activate log debug in ingress controller (-v argument)

```
$ helm install citm-ingress --set controller.extraArgs.v=6
```

## Test
Steps to run a test suite on a release
```
$ helm test citm-ab --cleanup
RUNNING: citm-ab-controller-test-connection-d57mba
PASSED: citm-ab-controller-test-connection-d57mba
RUNNING: citm-ab-test-healthz-404-i7n6sa
PASSED: citm-ab-test-healthz-404-i7n6sa
```
## CITM ingress controller - kubernetes internal

See a [detailed description](ingress-controller-internal.md) of the internal workings of CITM ingress controller
## Syslog Configuration

Syslog Enabling will create a sidecar rsyslog client container which will read the CITM logs through file and send it over UDP/TCP/TCP+TLS.

### Following are the configurations

Under `unifiedLogging.syslog` is where the values can be configured

Parameter | Description | Default
--------- | ----------- | -------
enabled | Enable/Disable syslog. Check Syslog Configurations(#syslog-configuration) for configuring | empty
Rsyslogd Output/Actions Conf | |
host | Remote host to which logs has to be forwarded | ""
port | Remote port to which logs has to be forwarded | ""
protocol | Remote protocol to which logs has to be forwarded | ""
tls.secretRef.name | tls-secret resource name with the client certs. Should contain ca.crt, tls.key and tls.crt | ""
tls.secretRef.keyNames.caCrt | tls secret ca.crt key name | "ca.crt"
tls.secretRef.keyNames.tlsKey | tls secret tls.key key name | "tls.key"
tls.secretRef.keyNames.tlsCrt | tls secret tls.crt key name | "tls.crt"
logRunner.dir | Directory of the Logrunner | "/logRunner"
logRunner.file | CITM log file name | "logRunner.log"
logrotate.dir | Logrotate directory | "/logRotate"
logrotate.file | Logrotation configuration file name | "logrotate.conf"
logrotate.conf | How should the rotation should be done. NOTE : Atleast one conf should be with <logRunner.dir>/<logRunner.file> else logroation will NOT work | -
logrotate.cron.file | Crontab file name. Will be under logrotate.dir | "logrotate-cron.conf"
logrotate.cron.conf | How often should logrotation be done. Whole content of the crontab should be given. | Crontab for evry day is set
logrotate.supercronic.output_file | Crontab's output file | Pod Log ("/proc/1/fd/1")
logrotate.supercronic.error_file | Crontab's error file | Pod Log ("/proc/1/fd/1")

Under `unifiedLogging.syslog.rsyslog` configuration with respect to rsyslog client and sidecar container can be provided.

#### rsyslog client configuration

Parameter | Description | Default
--------- | ----------- | -------
Main Rsyslog Conf | |
dir | Directory of the rsyslog | "/rsyslog"
file | rsyslog's main configuration file | "rsyslog.conf"
Rsyslogd Input Conf | |
inputExtraArgs | Any extra configuration to be given for the input | Tag="citm-imfile"
inputCustomConfigs | Use your own input configuration | ""
Output/Actions with TLS Conf | |
rsyslogTLSExtraArgs | Any extra configuration to be given for the actions | '**'
Logging Format of logs | |
unifiedLoggingFormatExtraArgs | Any extra configuration to be given for the  unified logging. | ""
unifiedLoggingCustomConfigs | Use your own logging format | ""

#### Sidecar configurations

Parameter | Description | Default
--------- | ----------- | -------
imageRepo | Repo of the rsyslog client sidecar image | citm/citm-rsyslog-client
imageTag | Tag of the rsyslog client sidecar image | 1.0.0
timeZoneEnv | Timezone Name to be used by the ryslog client container | ""
extraArgs | To bring up rsyslogd with extra arguments | ""
securityContext.runAsUser | runAsUser | 1000
securityContext.readOnlyRootFilesystem | readOnlyRootFilesystem | true
resources | rsyslog client sidecar resource requests & limits | {}
ephemeralVolume.emptyDir.medium | emptyDir medium to use blank for disk storage and Memory for in memory, with size limit(set at emptyDir.sizeLimit)  beyond which pod eviction will happen(controller.ephemeralVolume should be disabled) | empty
ephemeralVolume.emptyDir.sizeLimit | Set the size limit for the emptry dir volume | "1Gi"
ephemeralVolume.generic.enabled| enable ephemeral volume instead of emptyDir | false
ephemeralVolume.generic.storageClass| storage classs of the ephemeral volume | "vsphere"
ephemeralVolume.generic.resources.requests.ephemeral-storage | set resource requests for the storge | "200Mi"
ephemeralVolume.generic.resources.limits.ephemeral-storage | set resource requests for the storge | "1Gi"
probe.enabled | enable or disable probe times | true
probe.startup.command | command to send probe requests | ["/bin/bash", "-c", "ps -ef | grep rsyslog"]
probe.startup.delay | inital delay seconds | 10
probe.startup.period | probe request interval | 10
probe.startup.timeout | timeout interval seconds | 3
probe.startup.maxfailure | max number  of pod failures | 6
probe.liveness.command | command to send probe requests | ["/bin/bash", "-c", "ps -ef | grep rsyslog"]
probe.liveness.delay | initial delay seconds | 10
probe.liveness.period | probe request interval | 10
probe.liveness.timeout | timeout interval seconds | 3
probe.liveness.maxfailure | max number of pod failures | 5
probe.readiness.command | command to send probe requests | ["/bin/bash", "-c", "ps -ef | grep rsyslog"]
probe.readiness.delay | intial delay seconds | 10
probe.readiness.period | probe request interval | 5
probe.readiness.timeout | timeout interval seconds | 3
probe.readiness.maxfailure | max number of pod failures | 5


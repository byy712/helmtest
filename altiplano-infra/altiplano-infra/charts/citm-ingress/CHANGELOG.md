# Changelog
All notable changes to chart **citm-ingress** are documented in this file,
which is effectively a **Release Note** and readable by customers.

Do take a minute to read how to format this file properly.
It is based on [Keep a Changelog](http://keepachangelog.com)
- Newer entries _above_ older entries.
- At minimum, every released (stable) version must have an entry.
- Pre-release or incubating versions may reuse `Unreleased` section.


## [3.0.1] - 2023-12-06
- 23.11.PP1 release

### Changed
- CSFAR:9719: remove dev tag and take up image from delivered repo                           | 3.0.1
- CSFAR-9739: Bug fix for handling templating of namespace for default secret                | 3.0.1-dev0.0.1
- CSFAR-9718: To update imageTag after the base image update for [24-11-2023]                | 3.0.1-dev0.1.0
- CSFAR-9726: Bug fix for UKTSR list template incompatible with helm version < v3.6          | 3.0.1-dev0.1.1

## [3.0.0] - 2023-11-17
- 23.11 release

### Changed
- CSFAR-9152: Chnage repo to delivered and remove dev tags                                   | 3.0.0 
- CSFAR-9667: UT update for certManager flags and readme file update                         | 3.0.0-dev0.19.1
- CSFAR-9084: Updated image tag with option to disable annotationValidation at ingress level | 3.0.0-dev0.19.0
- CSFAR-9667: Change in priority for certManager flags                                       | 3.0.0-dev0.18.1
- CSFAR-9582: Bug fix for certManager enabled flag checks                                    | 3.0.0-dev0.17.1
- CSFAR-9488: Bug fix and enhancement for certManager                                        | 3.0.0-dev0.16.1
- CSFAR:9057: Updated istio version and image tags                                           | 3.0.0-dev0.16.0
- CSFAR-9488: Bug fix for certManager and update images to latest                            | 3.0.0-dev0.13.1	
- CSFAR-9133: Updated tag to use 1.9.4 ingress-nginx and added annotationValidation flag     | 3.0.0-dev0.13.0
- CSFAR-9026: Image update to include UK_TSR8.5 - Alerts support image with addr:port        | 3.0.0-dev0.12.1
- CSFAR-9133: Updated image tag to use 1.9.3 ingress-nginx and updated livenessProbe         | 3.0.0-dev0.11.0
- CSFAR-9048: Updated image registry to use from candidates                                  | 3.0.0-dev0.2.1
- CSFAR-9193: Bug fix to handle helm test when disbaleHttpPortListening is set to true       | 3.0.0-dev0.1.1
- CSFAR-9198: updated grafana-job to remove jq from the args                                 | 3.0.0-dev0.1.0

### Added
- CSFAR-8891: Added flag to enable/disable UK_TSR 8.1/8.5 Alerts                             | 3.0.0-dev0.17.0
- CSFAR-9177: HBP 3.7.0 security_cert_8                                                      | 3.0.0-dev0.14.0
- CSFAR-9172: HBP 3.7.0 security_cert_5,6 and_7                                              | 3.0.0-dev0.12.0
- CSFAR-8891: UK_TSR8.5 - Alerts support image,                                              | 3.0.0-dev0.10.0
              UK_TSR8.1 - removed bindCapability,workerProcessAsRoot checks  
- CSFAR-8891: UK_TSR8.1 - Alerts support                                                     | 3.0.0-dev0.9.0
- CSFAR-9044: HBP 3.7.0 added disablePodNamePrefixRestrictions to root level                 | 3.0.0-dev0.8.0
- CSFAR-9169: HBP 3.7.0 certManager at global and root scope                                 | 3.0.0-dev0.7.0
- CSFAR-9020: HBP 3.7.0 added imageFlavorPolicy                                              | 3.0.0-dev0.6.0
- CSFAR-9168: HBP 3.7.0 support for HBP_Security_cert_2 - tls section                        | 3.0.0-dev0.5.0
- CSFAR-8968: To expose StatusPort with TLS using disableTlsForStatusPort flag               | 3.0.0-dev0.4.0
- CSFAR-9020: HBP 3.7.0 added imageFlavor at global level                                    | 3.0.0-dev0.3.0
- CSFAR-9048: Added statusPort to host ports section                                         | 3.0.0-dev0.2.0

## [2.6.0] - 2023-09-14
22.03.FP6 release

### Changed
- CSFAR-8956: Remove dev tags and use delivered images                           | 2.6.0
- CSFAR-8935: Updated default404 chart version                                   | 2.6.0-dev0.12.0
- CSFAR-8875: Bug fix for seccomp profile not getting rendered                   | 2.6.0-dev0.11.1
- CSFAR-8797: updated image tag post CCBI base image update                      | 2.6.0-dev0.11.0
- CSFAR-8826: Bug fix for bind capability in psp                                 | 2.6.0-dev0.10.2
- CSFAR-8780: Update image tag which fixes CSFAR-8778                            | 2.6.0-dev0.10.1
- CSFAR-8740: Update liveness probe to restart if nginx master is killed         | 2.6.0-dev0.10.0
- CSFAR-8770: Istio version bump to 1.17.3                                       | 2.6.0-dev0.9.1
- CSFAR-8729: Updated the rsyslog probes to check the supercronic process        | 2.6.0-dev0.9.0
- CSFAR-8311: updated image tags post golang version upgrade                     | 2.6.0-dev0.8.0
- CSFAR-8708: Bug fix for imageFlavor                                            | 2.6.0-dev0.7.1
- CSFAR-8310: Handle image repo with older values post flatRegistry changes      | 2.6.0-dev0.6.3
- CSFAR-8671: Bug fix for probe, exposing timeout in values.yaml                 | 2.6.0-dev0.6.2
- CSFAR-8284: Code change to handle old image tag along with flavor              | 2.6.0-dev0.6.1
- CSFAR-8314: updated image tag post CCBI base image update                      | 2.6.0-dev0.6.0
- CSFAR-8273: HBP-3.4.0 container naming changes for ingress chart               | 2.6.0-dev0.4.0
- CSFAR-8282: Pod naming for ingress according to HBP-3.4.0                      | 2.6.0-dev0.3.0
- CSFAR-8152: Update ingress-nginx image tag to use 1.8.1 controller             | 2.6.0-dev0.2.0
- CSFAR-8225: Remove nginx server name from 400 and 50x error page               | 2.6.0-dev0.1.0


### Added
- CSFAR-8311: Support for explicitly setting allowed TLSv1.3 ciphersuites        | 2.6.0-dev0.7.0
- CSFAR-8299: Support for disabling pod name prefix restriction                  | 3.0.0-dev0.3.0
- CSFID-4407: Support ASM based certificate management option in CITM            | 3.0.0-dev0.2.0
- CSFAR-8275: Support for container registries with a flat structure             | 3.0.0-dev0.1.0
- CSFAR-8258: HBP 3.5.0 support for image naming                                 | 2.6.0-dev0.5.0

## [2.5.0] - 2023-06-15
22.03.FP5 release

### Changed
- CSFAR-7852: Remove dev tag and image repo to delivered                          | 2.5.0
- CSFAR-7286: env for clog-service and enabling/disabling systemid in logs        | 2.5.0-dev0.11.0
- CSFAR-7725: updated istio version to 1.17.2 and image tag to 1.24.0-1.0.4-1.0.0-rocky8    | 2.5.0-dev0.10.0
- CSFAR-7731: updated pdb api version                                             | 2.5.0-dev0.9.1
- CSFAR-7750: updated image tag to 1.24.0-1.0.2-1.0.1-rocky8                      | 2.5.0-dev0.9.0
- CSFAR-7695: Reverted container naming changes from ingress chart                | 2.5.0-dev0.7.2
- CSFAR-7667: updated image tag to 1.24.0-1.0.2-1.0.0-rocky8                      | 2.5.0-dev0.7.1
- CSFAR-7506: container naming for citm-ingress chart                             | 2.5.0-dev0.7.0
- CSFAR-7316: [HBP] Align rsyslog to 3.5.0 requirements
- CSFAR-7296: updated image tag to 1.24.0-1.0.0-1.0.1-rocky8
- CSFAR-7304: updated image tag to 1.24.0-1.0.0-1.0.0-rocky8
- CSFAR-7303: fixed sysctl rules getting applied on all nodes
- CSFAR-7106: updated image tag to 1.22.1-1.4.0-1.0.0-rocky8
- CSFAR-7239: updated image tag to 1.22.1-1.4.1-1.0.0-rocky8
- CSFAR-7254: Fixed WARN/ERROR log when extension not enabled
- CSFAR-7264: updated image tag to 1.22.1-1.4.1-1.0.1-rocky8
- CSFAR-7286: including namespace in host field of logs

### Added
- CSFAR-7315: FIX to give priority to local params over global for rsyslog
- CSFAR-7296: FIX for NumCPU in cgroups2 and Support for custom cgroups2 path
- CSFAR-7264: Support for SSL as protocol for syslog
- CSFAR-7264: Support for service sessionAffinity
- CSFAR-7299: Added autoGenerateLabelSelctor parameter for topologySpreadConstraint as per HBP 3.3.0 Requirement
- CSFAR-7277: Added imagePullSecrets as per HBP 3.3.0 requirement
- CSFAR-7697: Added additionalSpec under service                     | 2.5.0-dev0.8.0

## [2.4.1] - 2023-03-16
- 22.03.FP4 Release

### Added
- CSFAR-6753: Add option to enable/disable allocateLoadBalancerNodePorts
- CSFAR-6760: Added option to input rsyslog global custom configs
- CSFAR-6547: Support the extensions for the unified logging
- CSFAR-6686: added pod security context for pause container and updated image tag
- CSFAR-6514: Updated empty labels field implementation
- CSFAR-6492: Support to use v1.3.1 image when k8s < 1.21  
- CSFAR-6488: Support for fullnameOverride in helm test   

### Changed
- CSFAR-6960: citm-ingress not compatible with exporter when sysctl defined
- CSFAR-6948: Removed the dev tag from chart, updated image tag and image repo to delivered
- CSFAR-6873: Minor enhancements in rsyslog configurations
- CSFAR-6854: remove redundant mapping key - clog-harmonized-enable
- CSFAR-6844: FIX: In istio env with cert manager enabled, secret delete job in notReady state
- CSFAR-6812: updated image tag to 1.22.1-1.3.0-1.0.2-rocky8 and rsyslog client to 1.0.5 and istio to 1.16.3
- CSFAR-6772: FIX http protocol support for grafana-dashboard-job
- CSFAR-6746: updated image tag to 1.22.1-1.3.0-1.0.0-rocky8 and rsyslog client to 1.0.4
- CSFAR-6723: Updated role to support openshift 4.12
- CSFAR-6618: Updated ingress image tag to 1.22.1-1.1.3-1.4.2-rocky8
- CSFAR-6521: FIX for CSFS-50395 CITM time zone value implementation
- CSFAR-4182: revert changes added as part of CSFAR-6492 in _helpers.tpl file
- CSFAR-6511: Updated ingress tag to 1.22.1-1.1.3-1.4.0-rocky8, rsyslog tag to 1.0.2
- CSFAR-6533: Replacing grafana image with ingress image
- CSFAR-6579: Probe bug fix 

## [2.3.0] - 2022-12-15
- 22.03.FP3 Release

### Added
- Support for global.loaclIpFamilyPolicy and global.loaclIpFamilies                   | 2.3.0-dev0.10.0
- support for the logrotation and syslogging                                          | 2.3.0-dev0.7.0
- resources for grafana dashboard container                                           | 2.3.0-dev0.6.0
- added post-upgrade hook to grafana job                                              | 2.3.0-dev0.6.0
- support for k8s 1.25 PSA                                                            | 2.3.0-dev0.5.0
- support for PSA securityContext                                                     | 2.3.0-dev0.9.0

### Changed
- removed the dev tag from chart and image repo to delivered
- rsylog client image updated to 1.0.1-rocky8, host, port and protocol mandatory      | 2.3.0-dev0.8.2 
- rsylog client image updated to 1.0.1, reopenOnTruncate="on" added in inputExtraArgs | 2.3.0-dev0.8.1
  ingress image updated to 1.22.1-1.1.2-1.3.2-rocky8
- updated psp logic to exclude psp parts of role and clusterrole when PSA is enabled  | 2.3.0-dev0.8.0
- updated image tag to 1.22.1-1.1.2-1.2.0-rocky8 (1.5.1 ingress-nginx)                | 2.3.0-dev0.4.0     
  and updated role/clusterrole config
- updated image tag to 1.22.1-1.1.2-1.1.2-rocky8                                      | 2.3.0-dev0.3.2
- updated image tag to 1.22.1-1.1.1-1.1.1-rocky8 and 404 chart version                | 2.3.0-dev0.3.1
- HBP 3.1.0 changes for HPA, ephemeral volumes and anti-affinity                      | 2.3.0-dev0.3.0
- updated image tag to 1.22.1-1.1.0-1.1.0-rocky8                                      | 2.3.0-dev0.2.0
- updated service template to use correct semver check - CSFS-48866                   | 2.3.0-dev0.1.1
- updated ingress image tag to  latest candidates image and grafana image tag         | 2.3.0-dev0.1.0

## [2.2.0] - 2022-09-29
- 22.03.FP2 Release

### Changed
- Updated image tag to 1.22.0-1.2.4-1.3.4-rocky8 | 2.2.0-dev0.4.3
- FIX for the gracefull shutdown | 2.2.0-dev0.4.2
- Updated default404 chart dependency version to 1.3.0-dev0.1.1 and image tag 1.22.0-1.2.3-1.3.3-rocky8 | 2.2.0-dev0.3.0
- Updated default404 chart dependency version | 2.2.0-dev0.2.0
- added curl extra options support for the ingress test  | 2.2.0-dev0.1.2
- conditional check for the "use" verb for psp resource in role and cluster role  | 2.2.0-dev0.1.1
- added the check for psp enabled for using the "use" verb | 2.2.0-dev0.1.0
- typo in "sysctlRules" parameter as "systctlRules" | 2.2.0-dev0.0.1

### Added 
- runtime update of cert-manager version | 2.2.0-dev0.4.1
- added support for HPA | 2.2.0-dev0.4.0
- added 2 new keyword support for stream context ie USE-SVC-IP and ZONE | 2.2.0-dev0.1.1
- authorization for lease resource in roles | 2.2.0-dev0.1.0
- victor job now does the lease clean up as well | 2.2.0-dev0.1.0


## [2.1.1] - 2022-07-11
- 22.03.FP1 release
### Changed
- Bug fix for skiptest

## [2.1.0] - 2022-07-04
### Changed
- removed dev tags and changed image repo to delivered
- updated garafana image tag

## [2.1.0-dev0.10.3] - 2022-06-30
### Changed
- added some comments to use disableIpv4 instead disableIvp4
- added sidecar injection annotation to test pod

## [2.1.0-dev0.10.2] - 2022-06-29
### Changed
-  fixed a typo in values.yaml

## [2.1.0-dev0.10.1] - 2022-06-29
### Changed
- updated def404 chart version 
- removed hard coding for psp api version

## [2.1.0-dev0.10.0] - 2022-06-20
### Changed
- commonlibs chart templates is used for handling common labels
- istio version to 1.13.4
- cpro image change to grafana-utility:1.0.2-39

## [2.1.0-dev0.9.1] - 2022-06-24
### Changed
- exposed probe values in values.yaml
- added skipTest to skip helm test in values.yaml
- updated ingress image to 1.22.0-1.0.3.0-rocky8

## [2.1.0-dev0.9.0] - 2022-06-22
### Changed
- Update image tag to use 1.2.1 ingress-nginx image
- Added disableRootAliasDirective flag

## [2.1.0-dev0.8.1] - 2022-06-10
### Changed
- ephemeral-storage request and limits added in corresponding resources section

### Added
- ephemeral volume can be used instead of emptyDir
- support for emptyDir Memory medium

## [2.1.0-dev0.8.0] - 2022-06-13
### Changed
- Changes for HBP 3.0  named templates, kubernetes versions and PDB
- Updated ingress image version to 1.22.0-1.0.1.0-rocky8
- Updated default404 chart version
- Changed order of dualstack.ipFamilies in values.yaml

## [2.1.0-dev0.7.0] - 2022-05-12
### Changed
- Support for random user id

## [2.1.0-dev0.6.0] - 2022-05-25
### Added
- Support for dual stack

## [2.1.0-dev0.5.0] - 2022-05-23
### Changed
- changed anti-affinity configuration

## [2.1.0-dev0.4.1] - 2022-05-12
### Changed
- nampespaces resources to list and watch in cluster role

## [2.1.0-dev0.4.0] - 2022-05-11
### Added
- added anti-affinity configuration

## [2.1.0-dev0.3.0] - 2022-04-12
### Added
- Support for certmanager v1 version
- dnsNames, servername, ipAddresses exposed in values.yaml

## [2.1.0-dev0.2.0] - 2022-04-29
### Changed
- updated new artifactory_url
- removed centos8 part

## [2.1.0-dev0.1.0] - 2022-04-06
### Changed
- dropped helm2 support

## [2.0.0] - 2022-03-30
- 22.03 Release
### Changed
- updated chart version and registry

## [2.0.0-dev1.5.0] - 2022-03-25
### Changed
- Removal of usePreviousRelease flag
- Update readme and description

## [2.0.0-dev1.4.2] - 2022-03-24
### Changed
- retry logic for test curl which helps when istio injection is enabled
- trunc the name of test pod 

## [2.0.0-dev1.4.1] - 2022-03-23
### Changed
- log-format-upstream and log-format-stream is now in values.yaml

## [2.0.0-dev1.4.0] - 2022-03-18
### Added
- priorityClassName to global scope

### Changed
- Updated docker image tag
- Updated istio version 1.12.1

## [2.0.0-dev1.3.2] - 2022-03-18
### Changed
- Fix http port addtion to svc,ds,dp and psp when disableHttpPortListening is disabled

## [2.0.0-dev1.3.1] - 2022-03-17
### Changed
- Fix tcp/udp port not getting added dynamically when dynamicUpdateServiceStream=true
- Handle controller.reusePort value properly

## [2.0.0-dev1.3.0] - 2022-03-16
### Changed
- Updated docker image tag for bug fixes

## [2.0.0-dev1.2.0] - 2022-03-08
### Changed
- For grafana tools tiny-tools image is now deprecated from CPRO, so using cpro/grafana-registry1/grafana-utility:1.0.0-219

### Added  
- Support for the default Stream SSL Certificate
- Support for the Stream Snippet

## [2.0.0-dev1.1.0] - 2022-03-07
### Changed
- updated the image tag to 1.20.2-3.4.0-rocky8

## [2.0.0-dev1.0.0] - 2022-03-02
### Added
- chart changes for 1.1.1 ingres-nginx integration

## [2.0.0-dev0.4.3] - 2022-02-23
### Changed
- fixed typo disableIpv4 and disableIp6

## [2.0.0-dev0.4.2] - 2022-02-18
### Changed
- updated the image tag to 1.20.1-5.1.0-rocky8


## [2.0.0-dev0.4.1] - 2022-02-16
### Changed
- fixed ingress controller configmap recreation during uninstallation issue.
- updated the image tag to 1.20.1-5.1-rocky8

## [2.0.0-dev0.4.0] - 2022-02-04
### Added
- Corrected maintainer name and email id

## [2.0.0-dev0.3.0] - 2022-01-07
### Added
- added support for multiple bindAddress IPs in helm test pod

## [2.0.0-dev0.2.0] - 2022-01-04
### Changed
- fixed sonarqube issue

## [2.0.0-dev0.1.0] - 2021-12-23
### Changed
- fixed semverCompare causing issue on pre-released k8s version

## [1.20.9] - 2021-12-16
- 21.08.FP1 Release
### Added
- updated chart version
- updated default404 dependency version

## [1.20.9-dev0.8.0] - 2021-12-10
### Added
- Support for forceTcp and forceUdp

## [1.20.9-dev0.7.0] - 2021-12-09
### Added
- New ingress image with modsecurity-3.0.6

## [1.20.9-dev0.6.0] - 2021-11-12
### Added
- Support to inject user provided PSP
- Custom PSP can be set only at global level and will be progated to sub charts

## Changed
- Istion version is now 1.11.4

## [1.20.9-dev0.5.0] - 2021-11-29
### Added
- Update new docker with centos-nano:7.9-20211129

## [1.20.9-dev0.4.0] - 2021-11-29
### Added
- rocky-8 docker image tag updated

## [1.20.9-dev0.3.1] - 2021-11-22

### Added
- Support for timezone as per HBP_Kubernetes_Time_1 (TZ env)

### Changed
- mounting the localtime to pods is disabled by default 


## [1.20.9-dev0.3.0] - 2021-11-04

### Added
- Support for pod topology spread constraints to ingress controller chart
- Added clusterDomain for accessing svc - HBP 2.9
- Added evenPodSpreadEnabled option to ensure the EvenPodSpread feature gate enabled on k8s 1.16 and 1.17

## [1.20.9-dev0.2.0] - 2021-10-27

### Added
- Support for pod disruption budget to ingress controller chart

## [1.20.9-dev0.1.1] - 2021-10-25

### Added
- Added the registry1 in values.yaml and used in grafana dashboard job
- Added terminationMessagePath and terminationMessagePolicy
- Added activeDeadlineSeconds for Jobs

## [1.20.9-dev0.1.0] - 2021-10-12

### Added
- Added support for the updateStrategy Ondelete in daemonset
- Added lifecycle prestop hook for graceful shutdown of ingress controller nginx
- Added gracefulShutdownSleepSeconds, terminationGracePeriodSeconds in values.yaml

## [1.20.8] - 2021-09-15
### Changed
- Add forcePortHttp/forcePortHttps in allowed hostPorts range
- new docker 1.20.1-1.5

### Added
- Make map_hash_max_size configurable from Charts

## [1.20.7] - 2021-09-06
### Changed
- new docker 1.20.1-1.4

## [1.20.6] - 2021-08-27
### Changed
- new ingress controller activated. 0.48.1
- for activating previous (0.20.0), use --set controller.usePreviousRelease=true

## [1.20.5] - 2021-08-26
### Changed
- new docker 1.20.1-1.3

## [1.20.4] - 2021-08-20
### Changed
- new docker 1.20.1-1.2

## [1.20.3] - 2021-08-12
### Changed
- new default404 chart 1.0.46

## [1.20.2] - 2021-08-05
### Changed
- certManager + resource for cleaning job

## [1.20.1] - 2021-08-04
### Changed
- new docker 1.20.1-1.1

## [1.18.23] - 2021-07-01
### Changed
- sysctlRules not provided by default when securityContextPrivileged is set

## [1.18.21] - 2021-05-27
### Added
- readOnlyRootFilesystem (default true)

### Changed
- new docker 1.18.0-4.5
- new default404 charts. 1.0.44

## [1.18.19] - 2021-05-18
### Changed
- tiny tools image for grafana dashboard import. Mobe to 1.11.0-1
- Fixed psp when forcePort activated

## [1.18.18] - 2021-05-07
### Changed
- new docker 1.18.0-4.3
- rollback random user
- do not use anymore kubectl docker for test. ingress-controller docker provides curl
- rework psp when port > 1024
- Fixed /nginx_status scrapping
- new default404 charts. 1.0.43

## [1.18.16] - 2021-04-20
### Added
- random user

### Changed
- new docker 1.18.0-4.1

## [1.18.15] - 2021-03-11
### Added
- statusBindAddress

### Changed
- new docker 1.18.0-3.6

## [1.18.14] - 2021-02-09
### Added
- commons labels
- controller.whiteListCidrs: global white list of ips
- Support of global blockCidrs and whiteListCidrs in TCP/UDP streams
- Provide an entry for sysctl (controller.systctlRules)
- Allow to customize forcePort (forcePortHttp, forcePortHttps)

### Changed
- new default404 charts 1.0.40
- new docker 1.18.0-3.4

## [1.18.12] - 2021-01-12
### Added
- controller.disableOcspStapling (Indicates if OCSP stapling should be disabled. Default false)

## [1.18.11] - 2020-11-18
### Added
- Global snippet

### Changed
- new default404 charts 1.0.39
- Fixed psp for istio
- rollback NCSDEV-42 modification. This is now under control of values (configurable)

## [1.18.10] - 2020-11-13
### Changed
- NCSDEV-42: Assign critical NCS Pods to proper priority classes (new default404 chart 1.0.35)

## [1.18.9] - 2020-11-09
- NCSDEV-42: Assign critical NCS Pods to proper priority classes

## [1.18.8] - 2020-10-09
### Changed
- new docker 1.18.0-2.2
- Update to rbac.authorization.k8s.io/v1

### Added
- controller.allowInvalidCertificate.  If a ingress certificate is present and invalid, use default certificate. Set this to false if you want to respond with HTTP 403 (access denied) instead of using default certificate
- rbac.podSecurityPolicy.enabled. Default set to true. Create a psp for hostNetwork (ports below 1024) and setcap (allowPrivilegeEscalation)

## [1.18.7] - 2020-10-05
### Changed
- new default404 chart 1.0.34

## [1.18.6] - 2020-09-10
### Added
- Sync .md from citm doc

## [1.18.5] - 2020-09-08
### Added
- Add support of dnsPolicy and dnsConfig (.Values.controller.dnsPolicy and .Values.controller.dnsConfig)

## [1.18.4] - 2020-09-07
### Added
- controller.affinity (.Values.controller.affinity)
- test.hook-delete-policy on helm test (.Values.test.hookDeletePolicy)

### Changed
- new default404 chart 1.0.33

## [1.18.3] - 2020-08-31
### Changed
- new default404 chart 1.0.32

### Added
- Support of istio.permissive (true/false)
- Support of fullnameOverride
- Support of global.podNamePrefix and global.containerNamePrefix

## [1.18.2] - 2020-07-02
### Changed
- new default404 chart 1.0.27

## [1.18.1] - 2020-06-29
### Changed
- new docker
- support of kubernetes 1.16, 1.17, 1.18
- new default404 chart 1.0.26
- rework ssl-passthrough
- Update kubectl image to v1.17.6-nano

### Added
- Support of custom template
- Ability to split HTTPS and PASSTHROUGH listening port

## [1.16.17] - 2020-04-27
### Changed
- new docker 1.16.1-28.2
- increase timer on wget for helm test
- new default404 chart 1.0.21
- prefix leader config map wihh namespace

### Added
- export HTTP listening port as variable
- Clean configmap ingress-controller-leader-nginx in post-delete helm hook
- Clean cert manager generated secret in post-delete helm hook

## [1.16.14] - 2020-04-02
### Changed
- new docker 1.16.1-25.2

## [1.16.13] - 2020-03-05
### Added
- Provide probe thresholds and delay
- Allow patch on role/clusterrole
- Provide update on the fly of TCP/UDP stream services. See controller.dynamicUpdateServiceStream
- Support NodePort for TCP/UDP stream services. NODE-PORT=xxxx in the config map
- Can respond HTTP 403 when ingress certificate not found
- Support of helm3

### Changed
- new docker 1.16.1-25.1
- new default404 chart 1.0.18
- [liveness|ready]Probe are now done on httpPort (80)

## [1.16.12] - 2020-03-02
### Changed
- new default404 chart 1.0.17

## [1.16.11] - 2020-02-27
### Added
- Add controller.serviceOnStream.enable: Defines if on UDP/TCP service, request are forwarded to k8s service instead of backends. Needed by Istio for stream. false by default
- Add support of cert-manager

### Changed
- new docker 1.16.1-23.8

## [1.16.10] - 2020-02-04
### Added 
- Add support of modsecurity
- Add controller.enableHttp2OnHttp. Set it to true is you want http2 on http plain text
- Add controller.disableIvp4. Set it to true is you do not want listening on ipv4 interfaces

### Changed
- new docker 1.16.1-23.1 

## [1.16.9] - 2019-12-06
### Added 
- Add support of templating on defaultSSLCertificate

## [1.16.8] - 2019-12-04
### Added
- templating on tcp/udp services configmap

## [1.16.7] - 2019-12-03
### Added
- possibility of providing ConfigMap with lua modules

### Changed
- new docker 1.16.1-17.1 

## [1.16.6] - 2019-11-21
### Changed
- new docker 1.16.1-16.3 (CentOS 8 inside)
- new default404 chart
- new kubectl docker for helm test
- Enhance stream backend information on access log
- Activate TLS 1.3 and TLS 1.2 by default

### Added
- sslProtocols and sslCiphers in values.yaml

## [1.16.5] - 2019-10-31
### Added
- Add runOnEdge for setting is_edge: true in nodeSelector. Default is true
- Allow rendering of Monitoring console (set metrics to true for activation)
- Create leader config map only during helm install
### Fixed
- Lua OIDC login error handling

### Changed
- Enhance doc for udp/tcp services
- new docker 1.16.1-7.1
- new kubectl docker for helm test
- new default404 chart

## [1.16.4] - 2019-09-26
### Changed
- new docker 1.16.1-2.2

## [1.16.3] - 2019-09-18
### Added

### Changed
- set runAsUser:0 when worker process needs to run as root
- new chart for default404
- new docker 1.16.1-2.1

## [1.16.2] - 2019-09-03
### Added
- Access control for lua in Snippet code. 

### Changed
- New docker 1.16.1-1.2

## [1.16.1] - 2019-07-31
### Changed
- Do not request ClusterRole when scope on namespace is activated
- New docker 1.16.0-3.1

## [1.16.0] - 2019-06-25
### Fixed
- Compaas cookie cleanup problem

### Changed
- Update docker to 1.16.0-2.1

## [1.14.34] - 2019-05-24
### Changed
- Update docker to 1.14.2-11.2

## [1.14.33] - 2019-04-19
### Changed
- Disabled CORS support for NCM API in compaas SSO
- Update docker to 1.14.2-10.2

## [1.14.32] - 2019-04-02

### Changed
- Update docker to 1.14.2-9.3

## [1.14.31] - 2019-03-29
### Fixed
- Compaas SSS interation with NCM API problem

### Added
- docker: no more need of root user. Add runAsUser (nginx/1000) and securityContext / capabilities 
- more helm test

### Changed
- Update docker to 1.14.2-9.2

## [1.14.30] - 2019-02-26
### Added
- Support of block[Cidrs | UserAgents | Referers]
### Changed
- Update docker to 1.14.2-4.1. CITM Ingress Controller 0.20 inside (dynamicConfiguration disabled)
- Update docker to 1.14.2-4.3. Compaas SSO support for Keycloak login page.

## [1.14.29] - 2019-02-14
### Added
- Support for incoming Bearer tokens in Compaas SSO

## [1.14.28] - 2019-01-30
### Changed
- uppdate docker 1.14.2-3.2
- update default404 requirements version
- Compaas SSO - modified operational log
- split flow for stream backend when transparent proxying is required. Can be also forced for all stream with splitIpv4Ipv6StreamBackend set to true
### Fixed
- SSO login issue
- when service.type = NodePort, clusterIP should not be provided
- Harmonized logging 
### Added
- Add chart test
### Removed
- controller.UseOnlyIpv6Endpoint (this is now automaticaly detected. See also splitIpv4Ipv6StreamBackend)

## [1.14.27] - 2018-12-20
### Added
- Harmonized logging support. (Can be disabled by setting logToJsonFormat to false)
### Changed
- Don't start pods before default TLS certificate secret is ready
- Refresh token a few seconds before expiration

## [1.14.26] - 2018-12-06
### Changed
- improve citm as server
- Compaas SSO improvements
- Grafana dashboard

## [1.14.25] - 2018-11-14
### Changed
- Update docker citm-nginx:1.14.0-11.5

## [1.14.23] - 2018-11-06
### Changed
- Do not use alias in requirements on default backend

## [1.14.22] - 2018-10-26
### Changed
- update to docker citm-nginx:1.14.0-11.4

## [1.14.21] - 2018-10-25
### Fixed
- SSO logout problems
### Changed
- update to docker citm-nginx:1.14.0-11.3

## [1.14.20] - 2018-10-24
### Added
- add forcePort value to force http & https port to default (80 & 443)
### Changed
- update to docker citm-nginx:1.14.0-11.2

## [1.14.19] - 2018-10-23
### Added
- add values for nginx conf to allow 2 nginx releases to run on the same host

## [1.14.18] - 2018-10-17
- Remove default ingress resource

## [1.14.17] - 2018-10-16
### Fixed
- Default-backend is now a requirement

## [1.14.16] - 2018-10-10
### Fixed
- SSO session cookie problems

## [1.14.15] - 2018-10-10
### Fixed
- resolved typo on httpServer-deployment to load correctly external nginx configMap

## [1.14.14] - 2018-10-05
### Added
- added first version of citm as simple server

## [1.14.13] - 2018-10-03
### Fixed
- set rbac.enabled to true by default
- add podsecuritypolicies:privileded in clusterrole

## [1.14.12] - 2018-09-21
### Changed
- Add values to Configure the location of your etcd cluster
- Add value to use-calico-cni-workload-endpoint
- Add value to use only ipV6 endpoint

## [1.14.11] - 2018-09-21
### Changed
- Update to new citm nginx binary for IPV6 support

## [1.14.10] - 2018-09-13
### Fixed
- Using pre-defined resty session secret

## [1.14.9] - 2018-09-07
### Fixed
- adding template fullname in tcp and udp configMap

## [1.14.8] - 2018-09-07
### Added
- SSO support in sites federation
### Fixed
- Problem with SSO session cookie name

## [1.14.7] - 2018-09-04
### Added
- Configure UDP/TCP services 
- Configuring transparent proxy for udp/tcp service
- Optionally specify the secret name for default SSL certificate
- Ingress Controller suppoort for listening external IPs (local or nonlocal binding)
- Using global scope for relocation
### Removed
- Deprecated proxyStreamBindTransparent
### Fixed
- Issue with LUA includes

## [1.14.6] - 2018-09-03
### Added
- CSF chart relocation rules enforced
- SSO logging in CLF 

## [1.14.5] - 2018-08-28
### Removed
- stats-exporter removed
### Fixed
- issue in image relocation

## [1.14.4] - 2018-08-03
### Added
- All future chart versions shall provide a change log summary

## [0.0.0] - YYYY-MM-DD
### Added | Changed | Deprecated | Removed | Fixed | Security
- your change summary, this is not a **git log**!


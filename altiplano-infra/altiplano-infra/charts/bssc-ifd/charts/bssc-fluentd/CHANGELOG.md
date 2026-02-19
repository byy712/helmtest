# Changelog
All notable changes to chart **bssc-fluentd** will be documented in this file
which may be read by customers.

## [Unreleased]

## [10.0.1] - 2023-11-29
### Added

### Changed

### Removed

### Fixed

### Security
- Updated base images to rocky-nano:8.9-20231124. Updated java base image (for java modules) to java_base/11/nano:11.0.21.0.9.rocky8.9-20231124 (rocky8 jdk11), java_base/17/nano:17.0.9.0.9.rocky8.9-20231124 (rocky8 jdk17).
- Updated kubectl image to 1.26.11-rocky8-nano-20231124

## [10.0.0] - 2023-11-24
### Added
- Upgraded from td-agent v4.5.0 to fluent-package v5.1.0, td-agent rpm is renamed to fluent-package.
- HBP: Support for reading user-supplied server certificates via kubernetes secret (alternative to sensitiveInfoInSecrets way)
- HBP: Added fluentd.certificate section at workload level to control configurations of cert-manager generated certificates (and has higher precedence over fluentd.certManager).
- HBP: Added imageFlavor and imageFlavorPolicy at container, workload, root and global levels.
- HBP: Added disablePodNamePrefixRestrictions flag at global and root level to configure PodNamePrefix restrictions.
- Included containerName field for unified logs.

### Changed
- HBP: global.certManager is enabled to true by default.
- File paths like /etc/td-agent and /var/log/td-agent are now changed to /etc/fluent and /var/log/fluent. Please update custom configs accordingly.

### Removed

### Fixed

### Security
- Compliant for UKTSR 8.1 and 8.5
- Updated base images to rocky-nano:8.8-20231016. Updated java base image (for java modules) to java_base/11/nano:11.0.21.0.9.rocky8.8-20231027 (rocky8 jdk11), java_base/17/nano:17.0.9.0.9.rocky8.8-20231027 (rocky8 jdk17).
- Updated kubectl image to 1.26.10-rocky8-nano-20231027

## [9.0.0] - 2023-09-29
### Added
- Upgraded to td-agent v4.5.0
- HBP: Added global.flatRegistry to support container registries with a flat structure.
- HBP: Added a newer section tls.secretRef under unifiedLogging.syslog to read syslog tls certificates.
- HBP: Added enableDefaultCpuLimits parameter at global and root levels to enable the pod CPU resources limit in all containers.
- HBP: sizeLimit is configured for all the emptyDirs of the container and made user-configurable in values.yaml file.
- HBP: certManager.enabled made user-configurable at root level in addition to existing flags under global and workload levels.

### Changed
- HBP: Changed the image repo and tag according to HBP_Containers_name_1 and HBP_Containers_name_2
- HBP: Common label helm.sh/chart to use nameoverride (if configured) instead of chart-name
- HBP: Default values of ephemeral storage requests and limits are modified.
- HBP: Length of Pod suffix for helm test pods not allowed to exceed 19 characters
- Assigned GID 1000 instead of root(0) to the default userid(1000) for the container.

### Removed
- HBP: global.registry1 is removed and global.registry is used for all images.
- Default limits for resources.cpu are removed from values.yaml for all containers.
- Support for accepting certificates and credentials in Base64 format in values.yaml is removed. 
- HBP: Helm v2 support is removed
- Support for centos7 is dropped.
- Parameter fluentd.useClusterAdminRole is removed and the chart would create required clusterrole (with min permissions) and not use cluster-admin.

### Fixed
- Added record_modifier filter in fluentd configuration to fix issues caused due to deprecation of dedot feature of kubernetes_metadata_filter

### Security
- Updated kubectl image to v1.26.8-rocky-nano-20230901 (rocky8)
- Updated base images to rocky-nano:8.8-20230901. Updated java base image (for java modules) to java_base/11/nano:11.0.20.0.8.rocky8.8-20230901 (rocky8 jdk11), java_base/17/nano:17.0.8.0.7.rocky8.8-20230901 (rocky8 jdk17).

## [8.3.0] - 2023-06-22
### Added
- Upgraded to td-agent v4.4.2
- HBP: TopologySpreadConstraints supported for fluentd pods (applicable only for kind: Deployment and Statefulset)
- Added ephemeral-storage request and limits to all helm hook jobs
- Reload of syslog tls secret supported through csf-reloader annotation

### Changed
- Docker image size reduced for fluentd
- HBP: Lengths of containerName prefix and containerName suffix not allowed to exceed 34 and 28 characters respectively
- HBP: Excluded seccompProfile from the pod-level securityContext for Openshift pre-4.11 environments
- HBP: certManager.enabled made user-configurable at global scope in addition to existing fluentd.certManager.enabled.
- HBP: imagePullSecrets made user-configurable at global and workload scope in addition to existing imagePullSecrets at root level.

### Removed

### Fixed

### Security
- Updated kubectl image to v1.25.10-nano-20230602 (centos7) & v1.26.5-rocky-nano-20230602 (rocky8)
- Updated base images to rocky-nano:8.8-20230602 and centos-nano:7.9-20230428. Updated java base image (for java modules) to java_base/11/nano:11.0.19.0.7.rocky8.8-20230602 (rocky8 jdk11), java_base/17/nano:17.0.7.0.7.rocky8.8-20230602 (rocky8 jdk17) and java_base/11/nano:11.0.19.0.7.centos7.9-20230428 (centos7).

## [8.2.0] - 2023-03-31
### Added
- HBP: HorizontalPodAutoscaler supported for fluentd pods (applicable only for kind: Deployment)
- HBP: Fluentd pod logs follow unified logging format. Enabled by default at fluentd.unifiedLogging.enabled.
- HBP: Unified logging "extension" parameters made configurable in values.yaml
- Support sending pod logs to syslog along with stdout. Can be configured under fluentd.unifiedLogging.syslog.
- Issuer group of the certificate created by CertManager made user configurable
- Environment variables are made user-configurable for fluentd container, and also allow referencing values.yaml parameters.

### Changed
- RBAC permissions in chart-created role minimized as required for the workload kind used for fluentd
- Fluentd config files updated with log settings under <system> section (to set the log format to json). This is mandatorily required when unifiedLogging is enabled.

### Removed

### Fixed
- CSFS-50634: Added quotes to all keys and values configured under custom labels and annotations
- CSFS-51472: Disabled fips in init container during the generation of secret keys used for encryption of sensitive information.
- CSFS-50418: Handling of allowPrivilegeEscalation in containerSecurityContext parameters.

### Security
- Updated kubectl image to v1.25.6-nano-20230130 (centos7), v1.24.10-rocky-nano-20230306 (rocky8)
- Updated base images to java_base/11/nano:11.0.18.0.10.centos7.9-20230130 (centos7), java_base/11/nano:11.0.18.0.10.rocky8.7-20230306 (rocky8 java 11) , java_base/17/nano:17.0.6.0.10.rocky8.7-20230306 (rocky8 java 17)


## [8.1.0] - 2022-12-16
### Added
- HBP: Added support for PodSecurityAdmission in Kubernetes 1.25 while continuing to support in lower versions with PSP/SCC.
- HBP: Annotations for PSP/SCC are made user configurable under rbac section
- HBP: Added containerSecurityContext parameter to inject securityContext for containers

### Changed
- HBP: securityContext parameter can be used to inject securityContext for pods
- HBP: PSP/SCC creation controlled on the basis of kubernetes versions
- seccompProfile is set to RuntimeDefault for all containers and the annotation 'seccomp.security.alpha.kubernetes.io/allowedProfileNames' is by default added to PSPs (if created). These are default values and configurable through values.yaml

### Removed
- CriticalPod Scheduler annotation (scheduler.alpha.kubernetes.io/critical-pod) has been removed from fluentd pods as it is non-functional starting k8s v1.16

### Fixed

### Security
- Updated kubectl image to v1.25.4-nano-20221125 (centos7), v1.25.4-rocky-nano-20221125 (rocky8)
- Updated base images to java_base/11/nano:11.0.17.0.8.centos7.9-20221031 (centos7), java_base/11/nano:11.0.17.0.8.rocky8.7-20221125 (rocky8 java 11) , java_base/17/nano:17.0.5.0.8.rocky8.7-20221125 (rocky8 java 17)


## [8.0.0] - 2022-09-30
### Added
- Support for OpenSearch v2.2.1
- Compliance with HBP v3.0.0
- Support added for java 17 for Rocky8
- HBP: global.annotations and global.labels are added for all k8s resources.

### Changed
- Helm chart name changes from belk-fluentd to bssc-fluentd to avoid elastic trademarks/wordmarks
- Rocky8 java 11 based image made default option. Provision to configure either of rocky8-java11, rocky8-java17 or centos7-java11 is provided.
- HBP: Common labels values changed as per HBP 3.0.0. They will be added by default for all resources.
- HBP: K8s Jobs and helm test pod names updated to include fullnameoverride and nameoverride 

### Removed
- common_labels option to enable/disable common labels is removed from values.yaml

### Fixed
- CSFS-46793: Istio CNI and Istio Version precedence issue fixed
- CSFS-46995: apiversion check for BrPolicy fixed

### Security
- Updated kubectl image to v1.24.3-nano-20220729 version
- Updated base images to java_base/11/nano:11.0.16.0.8.centos7.9-20220729 (centos7), java_base/11/nano:11.0.16.0.8.rocky8.6-20220826 (rocky8 java 11) , java_base/17/nano:17.0.4.0.8.rocky8.6-20220826 (rocky8 java 17)

## [7.0.0] - 2022-06-30
### Added
- Upgraded fluentd to version 1.14.6 (td-agent to version 4.3.1)
- NCS22 support: New fluentd configuration added (belk-fluentd/fluentd-config/belk-cri.conf) that supports reading containerd logs
- Support for rocky8 based image
- HBP: rbac.psp.create and rbac.scc.create added to control creation of PodSecurityPolicy and SecurityContextConstraints
- HBP: PodDisruptionBudget(PDB) feature is added
- HBP: Customized labels are added
- HBP: Pod PriorityClassName made user configurable
- HBP: Added appProtocol field to services
- Ephemeral storage/emptyDir request and limit values for containers are made user configurable
- Update-Strategy of fluentd deployment made user configurable
- Support for Dual-stack

### Changed
- Default value of fluentd.useClusterAdminRole is set to false - when rbac.enabled is set, the chart creates a cluster-role and PSP/SCC with minimum required permissions instead of using the existing 'cluster-admin' clusterrole
- HBP: sensitiveInfoInSecret.secretName is changed to sensitiveInfoInSecret.credentialName as per the naming convention
- HBP: fluentd.podLabels replaced by fluentd.custom.pod.labels
- HBP: Container name prefix will be added to all containers irrespective of fullnameOverride or nameOverride configuration
- HBP: Timezone can be configured using global.timeZoneEnv or timezone.timezoneEnv at chart scope
- HBP: automountServiceAccountToken set to false in all serviceAccount objects and set to true/false in all the pods based on need
- Chart made compatible with latest BrPolicy apiversion
- HBP: Custom annotation values are quoted

### Removed
- HBP: timezone.mountHostLocaltime.mountHostLocaltimePath is now removed
- HBP: Removed hook-failed annotation value from hook deletion policy

### Fixed
- Fluentd config reload issue with RPC endpoint with sensitiveInfo enabled
- Resource limits and requests of init container made user configurable
- Fluentd Service, Service Account names are limited to 63 characters

### Security
- Updated kubectl image to v1.24.0-nano-20220530 version
- Updated centos7 base image to 11.0.15.0.9.centos7.9-20220530


## [6.5.0] - 2022-03-04
### Added
- readOnlyRootFilesystem enabled in all containers
- Cert Manager feature enabled

### Changed
- updateStrategy for fluentd daemonset made user-configurable

### Removed

### Fixed

### Security
- Updated java base image to 11.0.14.1.1.centos7.9-20220301
- Updated kubectl image to v1.23.1-nano-20220301

## [6.4.0] - 2021-12-21
### Added
- HBP: CommonLabels to all kubernetes resources

### Changed
- HBP: istio.version value type changed from float to the string
- HBP: StorageClassName options for PVC

### Removed

### Fixed

### Security
- Updated java base image to 11.0.13.0.8.centos7.9-20211208
- Fixed vulnerabilities in td-agent
- Updated kubectl image to v1.22.1-nano-20211208

## [6.3.1] - 2021-11-25
### Added

### Changed

### Removed
- CSFS-40064: Removed default credentials from values.yaml

### Fixed
- CSFS-39180: Added fluent-plugin-cloudwatch-logs plugin

### Security
- Java base image to nano:11.0.13.0.8.centos7.9-20211029

## [6.3.0] - 2021-10-01
### Added

### Changed

### Removed

### Fixed

### Security
- Upgraded java base image to nano:11.0.12.0.7.centos7.9-20210923

## [6.2.0] - 2021-09-17
### Added
- Upgraded fluentd to version 1.13.3 (td-agent to version 4.2.0)
- HBP: custom annotations for helm hook jobs and test pods made user configurable
- HBP:imagePullSecrets (for pulling images from docker registries) made user-configurable.
- HBP createDrForClient flag added to allow client application (running on istio) to access BELK running without istio
- automountserviceaccounttoken parameter set to false in service account of job/pod which do not use kubectl/k8s api

### Changed
- RBAC changes: Separate Service accounts created for jobs/pods as per permissions required
- Made "allowedHostPaths" in PSP configurable

### Removed

### Fixed
- CSFS-34146: Created SA for fluentd when rbac.enabled: true,enable_root_privilege: false instead of using 'default' SA
- HBP: Removed chart.version from common labels for PVCs

### Security
- Upgraded kubectl image to v1.21.1-nano-20210702 to fix vulnerability

## [6.1.0] - 2021-06-11
### Added
- CSFID-3371: Support to run containers with configurable userid
- HBP: common_labels flag to inject common labels to all resources
- Affinity, tolerations and nodeSelector feature for jobs and helm test pods
- chunk_limit_size parameter added in buffer sections of clog config

### Changed
- Parameters rbac.enabled and serviceaccount are moved from global level to chart level as per HBP.
- Replaced kubectl.jobResources with jobs.hookJobs.resources
- Toleration for daemonset made user configurable with default tolerate value of NoExecute. This default toleration is applicable for all kinds of fluentd. STS/deployment kind fluentd users can remove it, if not required.
- Helm test pods cleaned up on deletion of release.
- HBP: NOTES.txt enhanced to provide more information to customers

### Removed

### Fixed
- Updated clog-journal.conf and clog-json.conf for kubelet/plugins parsing error.
- CSFS-37539: With sensitive info enabled, fluentd reads default configuration instead of confimap on container-only restart

## [6.0.0] - 2021-04-14
- Upgraded td-agent version to 4.1.0
- Replaced searchguard with security
- Added HBP k8s common labels
- Added HBP provision to configure timezone.
- Added HBP provision to configure custom annotations for pods.
- Added changes to make forward_service.protocol user configurable.
- Updated default value of istio.version to 1.7
- Update clog-journal.conf and clog-json.conf for timestamp parsing.

## [5.0.0] - 2020-12-18
- Added changes to handle Sensitive information
- Added reloader annotation to restart pod when sensitive info is updated and fixed indentation, code issues in fluentd chart.
- CSFLDA-2971: Added resource limit/request to fluentd scale job
- CSFS-29143: Minimized RBAC privileges for charts.
- CSFLDA-2954: Updated delete-pvc job name
- Added helm test
- Updated default value of istio.version to 1.6
- Updated docker image tag
- Updated mount path for precreated secret when sensitiveInfoInSecret is enabled
- updated fluentd image to point to latest java base image
- Updated default repo from centos7 to centos 8
- Docker image from delivered

## [4.7.3] - 2020-10-23
- Istio sidecar inject annotation added as per istio.enabled flag
- Removed misplaced config
- Upgraded kubectl image to v1.17.8-nano-20201006-9214
- CSFS-29870: Removed extra space from _helpers.tpl to solve lint issue in helm version 2.14.1

## [4.7.2] - 2020-10-06
- CSFOAM-6395: Updated templatename with chart.templatename

## [4.7.1] - 2020.09.30
### Added
- added prometheus source
- updated README.md file
- updated few fluentd parameters in README.md file
- added enable cvea to the configs
- added duplicate message handling in fluentd config in the elastich search
- Addition of prefix to pod names, job and container names
- Added nameoverride and fullname override configuration changes
- Updated job and job template name
- CSFS-28597: Added new headless service for prometheus
- Added dest rule for fluentd service for istio 1.4

## [4.7.0] - 2020.08.14
### Added
- fluentd docker image update for version upgrade 1.11.1, kubernetes_metadata_fliter updated to 2.5.2 and clog plugin fluent-plugin-prometheus updated to 1.8.01
- Moved docker image to delivered

## [4.6.2] - 2020.07.14
### Added
- Added fsGroup, supplementary groups, MCS label 
- Added liveness and readiness probe checks
- Added run as non-root condition check in fluentd daemonset.
- Support for pre-created Service Account, role and rolebinding
- Added customized security annotation which are user configurable
- Added support for istio
- Fixed annotations warning on upgrade
- Added provision for customized labels to pods
- Helmbestpractice changes for service account and rbac flag
- Added fluent-plugin-cvea-log by CLOG
- Added cvea plugin dependecies in docker image
- Moved docker image to delivered

## [4.6.1] - 2020.04.21
### Added
- Helm3 changes
- Istio-Style Formatting for ports
- Creation of separate service for fluentd-forward plugin

## [4.6.0] - 2020.02.12
### Added
- Modified post-delete job with proper roles
- Added file buffer in belk.conf
- Added parameters reconnect_on_error,reload_on_failure,reload_connections in all .conf files
- Upgraded td-agent to 3.6.0
- Added request_timeout parameter in all .conf files
- Added autoUpdateCron in BrPolicy for automatically deleting/creating/updating cronjob based on other parameters
- Increased default limits,requests values for memory and cpu
- Moved docker image to delivered

## [4.5.17] - 2020.01.31
### Added
- CSFS-17741:Wrong way of getting current time

## [4.5.16] - 2019.12.18
### Added
- Added fluentd-http output plugin to docker image
- Updated belk.conf fluentd configuration to support for BCMT IPv6
- Added fluentd plugins: route, concat, grok-parser
- Added clog provided plugins from fluent-plugins-3.4.1-1.0.2.x86_64.rpm
- Removed nss,libd package from fluentd image
- Moved fluentd image to delivered

## [4.5.15] - 2019.11.12
### Added
- Added fluentd-http output plugin to docker image
- Updated belk.conf fluentd configuration to support for BCMT IPv6
- Added fluentd plugins: route, concat, grok-parser
- Added clog provided plugins from fluent-plugins-3.4.1-1.0.2.x86_64.rpm
- Removed nss,libd package from fluentd image

## [4.5.14] - 2019.10.30
### Added
- Added postscalein job to delete unused PVCs
- CSFLDA-2118: Added BrPolicy for configmap restore
- Added autoEnableCron in BrPolicy
- Upgraded base image to centos-7.7
- Updated registry parameter
- Moving fluentd image to docker-delivered

## [4.5.13] - 2019.10.04
### Added
- Added affinity to fluentd daemonset

## [4.5.12] - 2019.10.01
### Added
- Upgraded kubectl image to v1.14.7-nano 

## [4.5.11] - 2019.09.23
### Added
- support for parsing non-container alarms for BCMT 19.09

## [4.5.10] - 2019.09.23
### Added
- add toleration for daemonset

## [4.5.9] - 2019.09.20
### Added
- add nodeSelector for daemonset

## [4.5.8] - 2019.09.06
### Added
- modify prometheus configuration in clog fluentd configuration to support for BCMT IPv6

## [4.5.7] - 2019-09-03
### Added
- update clog fluentd configuration to support for BCMT IPv6

## [4.5.6] - 2019-08-30
### Updated
- Added registry1 parameter for kubectl image

## [4.5.5] - 2019-08-26
### Fixed
- CSFS-15916: Some resource of belk-efkc can not be deleted after helm delete successfully

## [4.5.4] - 2019-07-19
### Fixed
- update clog fluentd configuration for C API

## [4.5.3] - 2019-07-08
### Added
- Moved all images to delivered


## [4.5.2] - 2019-07-05
### Fixed
- Added required field ServiceName in StatefulSet to comply with K8S API spec
### Updated
- Removed unrequired field updateStrategy from Deployment to comply with K8S API spec

## [4.5.1] - 2019-07-03
### Fixed
- Fix a fluentd configuration issue for journal

## [4.5.0] - 2019-07-03
### Added
- Added securityContext privileged to support reading non-container logs when docker selinux is enabled on BCMT

## [4.4.29] - 2019-07-03
### Fixed
- Fix a fluentd configuration issue for non-container audit log

## [4.4.28] - 2019-07-01
### Updated
- removed pos_file parameter for systemd plugin in belk.conf

## [4.4.27] - 2019-07-01
### Update
- Update fluentd docker image tag

## [4.4.26] - 2019-06-28
### Added
- Updated fluentd-clog plugin to 0.1.2
- Added job resources and security annotations in post-delete

## [4.4.25] - 2019-06-25
### Fixed
- Upgraded to td-agent 3.4.1 (fluentd-1.4.2)
- Add double quotation marks for SYSTEM and SYSTEMID in daemonset/deployment/statefulset
- update clog-json file for time issue
- Update docker image tag

## [4.4.24]
### Added
- CSF chart relocation rules enforced
- Support non-container log message

## [4.4.23] - 2019-06-07
### Added
- CSFS-13747: Added metrics port to fluentd service and pod
- Added enable_root_privilege flag to fluentd deployment

## [4.4.22] - 2019-05-13
### Added
- CSFS-11977:Fluentd app mounting /var/log and /data0/docker by default

## [4.4.21] - 2019-05-10
### Added
- CSFS-12268:Add fullnameOverride tag to BELK helm charts

## [4.4.20] - 2019-05-08
### Added
- CSFS-11977:Fluentd app mounting /var/log and /data0/docker by default

## [4.4.19] - 2019-05-03
### Added
- Added latest clog-journa.conf and clog-json.conf

## [4.4.18] - 2019-04-30
### Added
- Added ssl properties to fluentd configuration
- Added searchguard configuration for clog-json.conf, clog-journal.conf files
- Moved images to delivered.
- CSFS-11586: Journal log event fields are not searchable

## [4.4.17] - 2019-04-25
### Added
- Upgraded base image

## [4.4.16] - 2019-04-25
### Added
- Added ssl properties to fluentd configuration
- Added searchguard configuration for clog-json.conf, clog-journal.conf files

## [4.4.15] - 2019-04-23
### Added
-Corrected clog-journal.conf and clog-josn.conf files

## [4.4.14] - 2019-04-17
### Added
-Corrected clog-journal.conf file

## [4.4.13] - 2019-04-17
### Added
-Updated clog-json.conf and clog-journal.conf for brevity and clog plugins.

## [4.4.12] - 2019-04-16
### Added
-CSFS:12219-Invalid Time format

## [4.4.11] - 2019-04-09
### Added
-CSFS:11586-Journal log event fields are not searchable

## [4.4.10] - 2019-03-29
### Added
-Added clog configuration
-Removed extra configuration of prometheus

## [4.4.9] - 2019-03-29
### Added
-Added clog configuration 


## [4.4.8] - 2019-03-26
### Added
- Upgraded base image to Centos 7.6
- Moved images to stable

## [4.4.7] - 2019-03-22
### Added
- Upgraded base image to Centos 7.6

## [4.4.6] - 2019-03-07
### Added
- Included CLOG related plugins(fluent-plugin-remote_syslog, remote_syslog_sender, syslog_protocol, fluent-plugin-brevity-control )


## [4.4.5] - 2019-03-05
### Added
- Included CLOG related plugins(fluent-plugin-remote_syslog, remote_syslog_sender, syslog_protocol, fluent-plugin-brevity-control )

## [4.4.4] - 2019-02-28
### Added
- CSFLDA-1521:TLS for belk-fluentd helm chart
- Test move charts to stable


## [4.4.3] - 2019-02-27
### Added
- CSFLDA-1521:TLS for belk-fluentd helm chart

## [4.4.2] - 2019-02-21
### Added
- CSFLDA-1521:TLS for belk-fluentd helm chart

## [4.4.1] - 2019-02-14
### Added
- CSFLDA-1543: Implemented Fluentd POD anti-affinity rules

## [4.4.0] - 2019-02-13
### Added
- Upgraded td-agent rpm to 3.3.0
- CSFID-1932:Installed fluentd postgres, genhashvalue, splunk plugins
- CSFID-1976:Fluentd supporting as statefulsets

## [4.3.3] - 2019-01-15
### Added
- CSFS-9192:JSON formatted log messages not properly parsed by fluentd 1.2.2(So downgraded fluent-plugin-kubernetes_metadata_filter to 1.0.1)
- CSFS-9183:fluentd metrics are not visible in prometheus(annotations added)

## [4.3.2] - 2019-01-10
### Added
- CSFS-9192:JSON formatted log messages not properly parsed by fluentd 1.2.2(So downgraded fluent-plugin-kubernetes_metadata_filter to 1.0.1)
- CSFS-9183:fluentd metrics are not visible in prometheus(annotations added)


## [4.3.1] - 2019-01-10
### Added
- CSFS-9192:JSON formatted log messages not properly parsed by fluentd 1.2.2(So downgraded fluent-plugin-kubernetes_metadata_filter to 1.0.1)
- CSFS-9183:fluentd metrics are not visible in prometheus

## [4.3.0] - 2018-12-20
### Added
- Upgarde of td-agent to 3.2.1

## [4.2.5] - 2018-11-27
### Added
- secret creation is added for prometheus

## [4.2.4] - 2018-11-22
### Added
- Prometheus plugin added

## [4.2.3] - 2018-10-29
### Changed
- Added mulitline parser plugin

## [4.2.2] - 2018-09-26
### Changed
- Resource properties removed from templates and added in the values.yaml

## [4.2.1] - 2018-09-19
### Changed
- Added space for image name

## [4.2.0] - 2018-08-31
### Added
- Install and delete LCM events are added for fluentd.

## [4.1.1] - 2018-08-30
### Changed
- Updated image registry name from registry to global registry 

## [4.1.0] - 2018-08-28
### Changed
- Updated to the chart to use fluentd version 1.2.2
- Changed fluent to run as root user and created respective rolebinding to fix permission issue

## [4.0.2] - 2018-08-23
### Changed
- Changelog updated

## [4.0.1] - 2018-08-17
### Changed
- CSFS-4771:- Cannot deploy more than one ElasticSearch in a namespace

## [4.0.0] - 2018-08-13
### Changed
- Charts to follow semver2 semantic


## [1.0.2-18.07.02] - 2018-08-06
### Added
-  PSP/RBAC support

### Changed
-  Chart to follow semantic naming. belk-<component>-<opensource version>-<csf release year>.<csf release month>.<patch> 
   eg: belk-fluentd-1.0.2-18.07.02
-  docker image on Centos 7.5


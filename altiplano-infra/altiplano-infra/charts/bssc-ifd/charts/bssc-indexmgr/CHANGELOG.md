All notable changes to chart **bssc-indexmgr** are documented in this file,
which is effectively a **Release Note** and readable by customers.

Do take a minute to read how to format this file properly.
It is based on [Keep a Changelog](http://keepachangelog.com)
- Newer entries _above_ older entries.
- At minimum, every released (stable) version must have an entry.
- Pre-release or incubating versions may reuse `Unreleased` section.

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
- HBP: Added disablePodNamePrefixRestrictions at global and root levels to configure PodNamePrefix restrictions.
- HBP: Added indexmgr.certificate section at workload level to control configurations of cert-manager generated certificates (and has higher precedence over security.certManager).
- HBP: Added imageFlavor and imageFlavorPolicy at container, workload, root and global levels.
- Included containerName field for unified logs.


### Changed
- HBP: global.certManager is enabled to true by default.

### Removed

### Fixed

### Security
- Compliant for UKTSR 8.1 and 8.5
- Updated base images to rocky-nano:8.8-20231016. Updated java base image (for java modules) to java_base/11/nano:11.0.21.0.9.rocky8.8-20231027 (rocky8 jdk11), java_base/17/nano:17.0.9.0.9.rocky8.8-20231027 (rocky8 jdk17).
- Updated kubectl image to 1.26.10-rocky8-nano-20231027

## [9.0.0] - 2023-07-29
### Added

- Cross cluster replication: Added stopReplicationFollowerIndices in values.yaml to control deletion of indices in the Follower cluster when ccr is enabled for indexsearch.
- HBP: Added global.flatRegistry to support container registries with a flat structure.
- HBP: Added a newer section tls.secretRef under unifiedLogging.syslog to read syslog tls certificates.
- HBP: Added enableDefaultCpuLimits parameter at global and root levels to enable the pod CPU resources limit in all containers.
- HBP: sizeLimit is configured for all the emptyDirs of the container and made user-configurable in values.yaml file.
- HBP: certManager.enabled made user-configurable at root level in addition to existing flags under global and workload levels.

### Changed

- HBP: Changed the image repo and tag according to HBP_Containers_name_1 and HBP_Containers_name_2
- HBP: Common label helm.sh/chart to use nameoverride (if configured) instead of chart-name
- HBP: Default values of ephemeral storage requests and limits are modified.
- HBP: CronJob name is limited to 52 characters by Kubernetes. Removed truncation of CronJob name based on resourceNameLimit.
- HBP: Length of Pod suffix for helm test pods not allowed to exceed 19 characters
- Assigned GID 1000 instead of root(0) to the default userid(1000) for the container.


### Removed
- HBP: global.registry1 is removed and global.registry is used for all images.
- Default limits for resources.cpu are removed from values.yaml for all containers.
- Support for accepting certificates and credentials in Base64 format in values.yaml is removed. 
- HBP: Helm v2 support is removed
- Support for centos7 is dropped.

### Fixed

### Security
- Updated kubectl image to v1.26.8-rocky-nano-20230901 (rocky8)
- Updated base images to rocky-nano:8.8-20230901. Updated java base image (for java modules) to java_base/11/nano:11.0.20.0.8.rocky8.8-20230901 (rocky8 jdk11), java_base/17/nano:17.0.8.0.7.rocky8.8-20230901 (rocky8 jdk17).

## [8.3.0] - 2023-06-22
### Added
- Added ephemeral-storage request and limits to all helm hook jobs

### Changed
- Docker image size reduced for indexmgr
- HBP: Lengths of containerName prefix and containerName suffix not allowed to exceed 34 and 28 characters respectively
- HBP: Excluded seccompProfile from the pod-level securityContext for Openshift pre-4.11 environments
- HBP: certManager.enabled made user-configurable at global scope in addition to existing security.certManager.enabled.
- HBP: imagePullSecrets made user-configurable at global and workload scope in addition to existing imagePullSecrets at root level.

### Removed

### Fixed

### Security
- Updated kubectl image to v1.25.10-nano-20230602 (centos7) & v1.26.5-rocky-nano-20230602 (rocky8)
- Updated base images to rocky-nano:8.8-20230602 and centos-nano:7.9-20230428. Updated java base image (for java modules) to java_base/11/nano:11.0.19.0.7.rocky8.8-20230602 (rocky8 jdk11), java_base/17/nano:17.0.7.0.7.rocky8.8-20230602 (rocky8 jdk17) and java_base/11/nano:11.0.19.0.7.centos7.9-20230428 (centos7).

## [8.2.0] - 2023-03-31
### Added
- HBP: Indexmgr pod logs follow unified logging format. Enabled by default at indexmgr.unifiedLogging.enabled.
- HBP: Unified logging "extension" parameters made configurable in values.yaml
- Support sending pod logs to syslog along with stdout. Can be configured under indexmgr.unifiedLogging.syslog.
- Issuer group of the certificate created by CertManager made user configurable
### Changed
- Default values of logging parameters (logfile: '/tmp/mainContainerLogs/im.log' and logformat: json) updated under indexmgr.configMaps.config_yml as these are mandatorily required when unifiedLogging is enabled

### Removed

### Fixed
- CSFS-50634: Added quotes to all keys and values configured under custom labels and annotations
- CSFS-51472: Disabled fips in init container during the generation of secret keys used for encryption of sensitive information.
- Added common label and annotations for jobs created by indexmgr cronjob.

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

### Fixed
- CSFS-49434: Updated comment in values.yaml for ssl_no_validate and certificate parameters under config_yml

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
- Helm chart name changes from belk-curator to bssc-indexmgr to avoid elastic trademarks/wordmarks
- Rocky8 java 11 based image made default option. Provision to configure either of rocky8-java11, rocky8-java17 or centos7-java11 is provided.
- HBP: Common labels values changed as per HBP 3.0.0. They will be added by default for all resources.
- Updation of Cronjob in bssc-indexmgr to use apiVersion batch/v1 instead of deprecated batch/v1beta1
- K8s Jobs and helm test pod names updated to include fullnameoverride and nameoverride

### Removed
- common_labels option to enable/disable common labels is removed from values.yaml

### Fixed
- CSFS-46793: Istio CNI and Istio Version precedence issue fixed

### Security
- Updated kubectl image to v1.24.3-nano-20220729 version
- Updated base images to java_base/11/nano:11.0.16.0.8.centos7.9-20220729 (centos7), java_base/11/nano:11.0.16.0.8.rocky8.6-20220826 (rocky8 java 11) , java_base/17/nano:17.0.4.0.8.rocky8.6-20220826 (rocky8 java 17)

## [7.0.0] - 2022-06-30
### Added
- Upgraded curator to version 5.8.4
- Support for rocky8 based image
- HBP: rbac.psp.create and rbac.scc.create added to control creation of PodSecurityPolicy and SecurityContextConstraints
- HBP: PodDisruptionBudget(PDB) feature is added
- HBP: Customized labels are added
- HBP: Pod PriorityClassName made user configurable
- Ephemeral storage/emptyDir request and limit values for containers are made user configurable

### Changed
- HBP: sensitiveInfoInSecret.secretName is changed to sensitiveInfoInSecret.credentialName as per the naming convention
- HBP: curator.podLabels replaced by curator.custom.pod.labels
- HBP: Container name prefix will be added to all containers irrespective of fullnameOverride or nameOverride
- HBP: Timezone can be configured using global.timeZoneEnv or timezone.timezoneEnv at chart scope
- HBP: automountServiceAccountToken set to false in all serviceAccount objects and set to true/false in all the pods based on need
- HBP: Custom annotation values are quoted

### Removed
- HBP: timezone.mountHostLocaltime.mountHostLocaltimePath is now removed
- HBP: Removed hook-failed annotation value from hook deletion policy

### Fixed
- Resource limits and requests of init container made user configurable
- Curator serviceAccount names are limited to 63 characters

### Security
- Updated kubectl image to v1.24.0-nano-20220530 version
- Updated centos7 base image to 11.0.15.0.9.centos7.9-20220530


## [6.5.0] - 2022-03-04
### Added
- readOnlyRootFilesystem enabled in all containers
- Cert Manager feature supported 


### Changed

### Removed

### Fixed
- CSFS-43528: curator intermittent issue of encryption

### Security
- Updated java base image to 11.0.14.1.1.centos7.9-20220301
- Updated kubectl image to v1.23.1-nano-20220301

## [6.4.0] - 2021-12-21
### Added
- HBP: CommonLabels to all kubernetes resources

### Changed

### Removed

### Fixed

### Security
- Updated java base image to 11.0.13.0.8.centos7.9-20211208
- Updated kubectl image to v1.22.1-nano-20211208

## [6.3.1] - 2021-11-25
### Added

### Changed

### Removed
- CSFS-40064: Removed default credentials from values.yaml

### Fixed

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
- HBP: custom annotations for helm hook jobs and test pods
- HBP: imagePullSecrets (for pulling images from docker registries) made user-configurable.
- automountserviceaccounttoken parameter set to false in service account of job/pod which do not use kubectl/k8s api

### Changed
- RBAC changes: Separate Service accounts for jobs/pods as per permissions required
- RBAC changes: volume types in PSP to only needed types replacing '*'.

### Removed
 
### Fixed

### Security
- Upgraded kubectl image to v1.21.1-nano-20210702 to fix vulnerability


## [6.1.0] - 2021-06-11
### Added
- CSFID-3371: Support to run containers with configurable userid
- HBP: common_labels flag to inject common labels to all resources
- Affinity, tolerations and nodeSelector feature

### Changed
- Parameters rbac.enabled and serviceaccount are moved from global level to chart level as per HBP.
- Replaced jobResources with jobs.hookJobs.resources
- Helm test pods cleaned up on deletion of release.
- HBP: NOTES.txt enhanced to provide more information to customers

### Removed

### Fixed
- CSFS-36751: With sensitiveInfoInSecret enabled, curator fails when configured with multiple actions that are long running.

## [6.0.0] - 2021-04-14
- Replaced searchguard by opendistro security.
- Added HBP k8s common labels
- Added HBP provision to configure timezone.
- Added HBP provision to configure custom annotations for pods.

## [5.0.0] - 2020-12-18
- CSFS-29100: Updated changes to handle Sensitive information
- CSFS-29143: Minimized RBAC privileges for charts. 
- Added helm test
- CSFS-29928: Added configurable delay to wait for istio envoy proxy
- Updated default values of istio parameters for istio 1.6
- updated curator image to point to latest java base image
- Renamed parameter istio.envoy_health_chk_port to istio.envoy.healthCheckPort, added additional parameters under istio.envoy
- Updated default repo from centos7 to centos 8
- docker image from delivered

## [4.5.6] - 2020-10-30
- Added support for istio cni disabled
- Istio sidecar inject annotation added as per istio.enabled flag
- Check for istio envoy sidecar readiness before starting curator process
- Upgraded kubectl image to v1.17.8-nano-20201006-9214
- CSFS-29870: Removed extra space from _helpers.tpl to solve lint issue in helm version 2.14.1
- Updated curator chart to point to delivered image

## [4.5.5] - 2020-10-06
- CSFOAM-6395: Updated templatename with chart.templatename

## [4.5.4] - 2020-09-30
- Updated README.md file
- addition of prefix to pod names, job and container names
- added nameoverride and fullname override configuration changes
- updated job and job container template names
- updated docker image repo to choose between curator cos7 and cos8 images.
- Docker image moved to delivered

## [4.5.3] - 2020-07-20
- CSFS-22644: Added support to accept precreated curator configmap.

## [4.5.2] - 2020-07-13
### Updated
- Added fsGroup, supplementary groups, MCS label
- Support for pre-created Service Account, role and rolebinding
- Added customized security annotation which are user configurable
- Added support for istio
- Fixed annotations warning on upgrade
- Added provision for cutomized labels to pods
- helmbestpractice changes for service account and rbac flag
- Moved docker image to delivered

## [4.5.1] - 2020-04-23
### Updated
- Helm3 changes
- Istio-Style Formatting for ports


## [4.5.0] - 2020-02-11
### Updated
- Added service account to curator
- Upgraded curator to 5.8.1
- Updated job spec and job template parameters to be user configurable
- Updated curator-post-delete role permissions
- Moved docker image to delivered

## [4.4.7] - 2019-12-18
### Updated
- Updated curator configuration for deletion of snapshots
- Updated curator image to point to latest centos image
- Moved curator image to delivered

## [4.4.6] - 2019-10-30
### Updated
- Upgraded base image to centos-7.7
- Updated registry parameter
- Moving curator image to docker-delivered

## [4.4.5] - 2019-10-01
### Updated
- Upgraded kubectl image to v1.14.7-nano 

## [4.4.4] - 2019-08-29
### Updated
- Moved curator image to delivered

## [4.4.3] - 2019-08-26
### Updated
- CSFS-15916: Some resource of belk-efkc can not be deleted after helm delete successfully

## [4.4.2] - 2019-08-22
### Updated
- CSFLDA-1975: Moved curator image to centos nano image

## [4.4.1] - 2019-07-08
### Added
- Moved all images to delivered

## [4.4.0] - 2019-06-27
### Added
- Upgraded curator to 5.7.6

## [4.3.6] - 2019-05-21
### Added
- Added security annotation for curator

## [4.3.5] - 2019-05-20
### Added
- Added security annotation


## [4.3.4] - 2019-04-30
### Added
- Moved base image to delivered

## [4.3.3] - 2019-04-25
### Added
- Upgraded base image

## [4.3.2] - 2019-03-22
### Changed
- Upgraded base image to Centos 7.6

## [4.3.1] - 2019-02-19
### Changed
- Changed the version of kubectl image

## [4.3.0] - 2018-12-20
### Changed
- Upgraded curator to 5.6.0

## [4.2.1] - 2018-10-30
### Changed
- Changed certificates


## [4.2.0] - 2018-10-29
### Changed
- Elasticsearch curator upgraded to 5.5.4

## [4.1.4] - 2018-09-26
### Changed
- Resource properties removed from templates and added in the values.yaml

## [4.1.3] - 2018-09-19
### Changed
- Modified secret creation

## [4.1.2] - 2018-09-05
### Added
- Update config LCM event is added

## [4.1.1] - 2018-09-04
### Added
- CSFLDA-897: Fix for bug while installing chart with wrong base64 password

## [4.1.0] - 2018-08-31
### Added
- Install and delete LCM events are added for curator.

## [4.0.1] - 2018-08-30
### Changed
- CSF chart relocation rules enforced
- Updated image registry name from registry to global registry

## [4.0.0] - 2018-08-13
### Added
- All future chart versions shall provide a change log summary
- CSF chart relocation rules enforced
- PSP/RBAC support
### Changed
- Chart to follow semantic naming. belk-`component`-`opensource version`-`csf release year`.`csf release month`.`patch`
  e.g. `belk-curator-5.5.4-18.07.02`
- docker image on Centos 7.5

## [0.0.0] - YYYY-MM-DD
### Added | Changed | Deprecated | Removed | Fixed | Security
- your change summary, this is not a **git log**!


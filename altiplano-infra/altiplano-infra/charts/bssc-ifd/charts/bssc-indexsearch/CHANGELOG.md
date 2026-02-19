# Changelog
All notable changes to chart **bssc-indexsearch**  are documented in this file,
which is effectively a **Release Note** and readable by customers.

Do take a minute to read how to format this file properly.
It is based on [Keep a Changelog](http://keepachangelog.com)
- Newer entries _above_ older entries.
- At minimum, every released (stable) version must have an entry.
- Pre-release or incubating versions may reuse `Unreleased` section.

## [Unreleased]  or [Released]
### Added
- CSF chart relocation rules enforced

## [13.0.1] - 2023-11-29
### Added

### Changed

### Removed

### Fixed

### Security
- Updated base images to rocky-nano:8.9-20231124. Updated java base image (for java modules) to java_base/11/nano:11.0.21.0.9.rocky8.9-20231124 (rocky8 jdk11), java_base/17/nano:17.0.9.0.9.rocky8.9-20231124 (rocky8 jdk17).
- Updated kubectl image to 1.26.11-rocky8-nano-20231124
- Updated Cbura image to cbur-agent:1.1.0-alpine-6419

## [13.0.0] - 2023-11-24
### Added
- Upgraded to OpenSearch v2.11.0
- Addition of Index State Management Plugin for managing indices.
- Audit logging feature enabled
- HBP: Support for reading user-supplied server certificates via kubernetes secret (alternative to  sensitiveInfoInSecrets way).
- HBP: Added indexsearch.nodeCrt and indexsearch.adminCrt sections at workload level to control configurations of cert-manager generated certificates (and has higher precedence over security.certManager).
- HBP: Added provision to configure any number of internal users in key-value pairs, as an alternative to yaml file structure (secInternalUserYml).
- HBP: Added imageFlavor and imageFlavorPolicy at container, workload, root and global levels.
- HBP: Added disablePodNamePrefixRestrictions at global, root and workload levels to configure PodNamePrefix restrictions. Default value is true for indexsearch pods.
- Included containerName field for unified logs.

### Changed
- HBP: global.certManager is enabled to true by default.

### Removed

### Fixed

### Security
- Compliant for UKTSR 8.1 and 8.5
- Updated base images to rocky-nano:8.8-20231016. Updated java base image (for java modules) to java_base/11/nano:11.0.21.0.9.rocky8.8-20231027 (rocky8 jdk11), java_base/17/nano:17.0.9.0.9.rocky8.8-20231027 (rocky8 jdk17).
- Updated Cbura image to cbur-agent:1.0.3-6028
- Updated kubectl image to 1.26.10-rocky8-nano-20231027

## [12.0.0] - 2023-09-29
### Added
- Upgraded to OpenSearch v2.9.0
- CSFID-3607: Support for Cross-Cluster-Replication
- CSFID-4399: Sending indexsearch logs to syslog via log4j (default option) while sending via fluentd sidecar is still supported.
- CSFID-3863: Restore behaviour can be customized using options in cbur_restore_parameters in values.yaml
- Automated rollback procedure (for downgrade to a lower opensearch version). Will be usable from next release onwards to perform single-step helm rollback.
- Provision to configure REST API commands to be executed on bssc-indexsearch on every Helm Install/Upgrade/Rollback event.
- indexsearch.externalClientCertificates in values to create certificate for dashboards client-cert based authorization (CSFID:4348)
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
- Liveness probe for client pods modified to tcpSocket check of 9200 port. Also, made readiness and liveness probes user-configurable for client pods.
- CSFS-48154: Updated opensearch-grafana.json to remove interval dropdown and followed grafana best practice to handle it internally based on $__rate_interval

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
- Updated cbura image to 1.0.3-5650



## [11.3.0] - 2023-06-22
### Added
- Upgraded to OpenSearch v2.7.0
- HBP: TopologySpreadConstraints supported for indexsearch pods
- Added ephemeral-storage request and limits to all helm hook jobs and cbura containers
- Reload of syslog tls secret supported through csf-reloader annotation

### Changed
- Docker image size reduced for indexsearch
- HBP: Lengths of containerName prefix and containerName suffix not allowed to exceed 34 and 28 characters respectively
- HBP: Excluded seccompProfile from the pod-level securityContext for Openshift pre-4.11 environments
- HBP: certManager.enabled made user-configurable at global scope in addition to existing security.certManager.enabled
- HBP: imagePullSecrets made user-configurable at global scope in addition to workload level.
- Under security.sec_configmap section, whitelist_yml is deprecated and recommendation is to use allow_list_yml

### Removed

### Fixed

### Security
- Updated kubectl image to v1.25.10-nano-20230602 (centos7) & v1.26.5-rocky-nano-20230602 (rocky8)
- Updated cbura image to 1.0.3-5180
- Updated base images to rocky-nano:8.8-20230602 and centos-nano:7.9-20230428. Updated java base image (for java modules) to java_base/11/nano:11.0.19.0.7.rocky8.8-20230602 (rocky8 jdk11), java_base/17/nano:17.0.7.0.7.rocky8.8-20230602 (rocky8 jdk17) and java_base/11/nano:11.0.19.0.7.centos7.9-20230428 (centos7).

## [11.2.0] - 2023-03-31
### Added
- HBP: HorizontalPodAutoscaler supported for indexsearch client pods
- Support sending pod logs to syslog along with stdout. Can be configured under unifiedLogging.syslog.
- HBP: Unified logging "extension" parameters made configurable in values.yaml
- Issuer group of the certificate created by CertManager made user configurable

### Changed

### Removed

### Fixed
- CSFS-50634: Added quotes to all keys and values configured under custom labels and annotations
- CSFS-51472: Disabled fips in init container during the generation of secret keys used for encryption of sensitive information.
- CSFS-48370: Fix to avoid conflicting encryption of certificates in case of very short-duration backup operations.

### Security
- Updated kubectl image to v1.25.6-nano-20230130 (centos7), v1.24.10-rocky-nano-20230306 (rocky8)
- Updated cbura image to 1.0.3-4989
- Updated base images to java_base/11/nano:11.0.18.0.10.centos7.9-20230130 (centos7), java_base/11/nano:11.0.18.0.10.rocky8.7-20230306 (rocky8 java 11), java_base/17/nano:17.0.6.0.10.rocky8.7-20230306 (rocky8 java 17)


## [11.1.0] - 2022-12-16
### Added
- HBP: Added support for PodSecurityAdmission in Kubernetes 1.25 while continuing to support in lower versions with PSP/SCC.
- HBP: Annotations for PSP/SCC are made user configurable under rbac section
- HBP: Added containerSecurityContext parameter to inject securityContext for containers

### Changed
- HBP: securityContext parameter can be used to inject securityContext for pods
- HBP: PSP/SCC creation controlled on the basis of kubernetes versions.
- REST layer SSL communication for indexsearch is also routed via istio-proxy (i.e. istio mtls over application tls) as HTTP port 9200 is no longer excluded from istio routing.
- seccompProfile is set to RuntimeDefault for all containers and the annotation 'seccomp.security.alpha.kubernetes.io/allowedProfileNames' is by default added to PSPs (if created). These are default values and configurable through values.yaml


### Removed

### Fixed
- Support for istio outboundTrafficPolicy in REGISTRY_ONLY mode 
- CSFS-49778: Updated NOTES.txt with correct protocol used for accessing indexsearch svc in istio-enabled case.

### Security
- Updated kubectl image to v1.25.4-nano-20221125 (centos7), v1.25.4-rocky-nano-20221125 (rocky8)
- Updated cbura image to 1.0.3-4789
- Updated base images to java_base/11/nano:11.0.17.0.8.centos7.9-20221031 (centos7), java_base/11/nano:11.0.17.0.8.rocky8.7-20221125 (rocky8 java 11) , java_base/17/nano:17.0.5.0.8.rocky8.7-20221125 (rocky8 java 17)

## [11.0.0] - 2022-09-30
### Added
- Upgraded to OpenSearch 2.2.1
- Compliance with HBP v3.0.0
- Support added for java 17 for Rocky8
- HBP: global.annotations and global.labels are added for all k8s resources.

### Changed
- Helm chart name changed from belk-elasticsearch to bssc-indexsearch to avoid elastic trademarks/wordmarks
- Rocky8 java 11 based image made default option. Provision to configure either of rocky8-java11, rocky8-java17 or centos7-java11 is provided.
- HBP: Common labels values changed as per HBP 3.0.0. They will be added by default for all resources.
- HBP: podNamePrefix removed from the names of non-pod resources
- HBP: K8s Jobs and helm test pod names updated to include fullnameoverride and nameoverride 

### Removed
- common_labels option to enable/disable common labels is removed from values.yaml

### Fixed
- CSFS-46793: Istio CNI and Istio Version precedence issue fixed
- CSFS-46995: apiversion check for BrPolicy fixed

### Security
- Updated kubectl image to v1.24.3-nano-20220729 version
- Updated cbura image to 1.0.3-4538 version
- Updated base images to java_base/11/nano:11.0.16.0.8.centos7.9-20220729 (centos7), java_base/11/nano:11.0.16.0.8.rocky8.6-20220826 (rocky8 java 11) , java_base/17/nano:17.0.4.0.8.rocky8.6-20220826 (rocky8 java 17)


## [10.0.0] - 2022-06-30
### Added
- Migrated from Elasticsearch to OpenSearch 1.3.2
- Support for rocky8 based image
- HBP: rbac.psp.create and rbac.scc.create added to control creation of PodSecurityPolicy and SecurityContextConstraints
- HBP: PodDisruptionBudget(PDB) feature is added
- HBP: Customized labels are added
- HBP: Pod PriorityClassName made user configurable
- HBP: appProtocol field added for services
- Ephemeral storage/emptyDir request and limit values for containers are made user configurable
- Support for Dual-stack

### Changed
- HBP: sensitiveInfoInSecret.secretName is changed to sensitiveInfoInSecret.credentialName as per the naming convention
- HBP: elasticsearch_master.podLabels, elasticsearch_client.podLabels and esdata.podLabels replaced by custom.esMaster.pod.labels, custom.esData.pod.labels,custom.esClient.pod.labels respectively
- HBP: Container name prefix will be added to all container names irrespective of fullnameOverride or nameOverride configuration
- HBP: Timezone can be configured using global.timeZoneEnv or timezone.timezoneEnv at chart scope
- HBP: automountServiceAccountToken set to false in all serviceAccount objects and set to true/false in all the pods based on need.
- Chart made compatible with latest BrPolicy apiversion
- HBP: Custom annotation values are quoted
- Values of Resource limits and requests for init container reduced

### Removed
- HBP: timezone.mountHostLocaltime.mountHostLocaltimePath is now removed
- HBP: Removed hook-failed annotation value from hook deletion policy

### Fixed
- CSFS-44765: Added zone for anti-affinity feature in master, data and client templates
- Elasticsearch Service, Service Account names are limited to 63 characters

### Security
- Updated kubectl image to v1.24.0-nano-20220530 version
- Updated cbura image to 1.0.3-4164 version
- Updated centos7 base image to 11.0.15.0.9.centos7.9-20220530


## [9.3.0] - 2022-03-07
### Added
- readOnlyRootFilesystem enabled in all containers
- Cert manager feature supported
- CSFS-37465: jvm.options made user-configurable in Elasticsearch
- Provision to configure update strategy for elasticsearch client deployment

### Changed
- Service type fixed to ClusterIP for es-master discovery service

### Removed

### Fixed

### Security
- Updated log4j to 2.17.1
- Updated java base image to 11.0.14.1.1.centos7.9-20220301
- Updated kubectl image to v1.23.1-nano-20220301
- Updated cbura image tag to 1.0.3-3733
- Fixed anchore reported vulnerabilities
 
## [9.2.0] - 2021-12-21
### Added
- Provision to add environmental variables to elasticsearch pods.
- HBP: CommonLabels to all kubernetes resources

### Changed
- HBP: istio.version value type changed from float to string
- HBP: StorageClassName options for PVC
- cbura image tag to 1.0.3-3233

### Removed

### Fixed
- CSFS-39701: Fix for kibanaserver user getting overwritten with default password during SG to OD migration
- CSFS-39400: Elasticsearch log format updated with hostname & systemid fields as per harmonized logging
- CSFS-41541: Backup fails after restoring to an older snapshot

### Security
- Updated java base image to 11.0.13.0.8.centos7.9-20211208
- Fixed vulnerabilities in ES rpm, ingest plugin, Opendistro security plugin
- Updated kubectl image to v1.22.1-nano-20211208
- Fixed CVE-2021-44228, CVE-2021-45046, CVE-2021-45105 by updating log4j to 2.17.0

## [9.1.1] - 2021-11-25
### Added

### Changed

### Removed
- CSFS-40064: Removed default credentials from values.yaml

### Fixed

### Security
- Java base image to nano:11.0.13.0.8.centos7.9-20211029

## [9.1.0] - 2021-10-01
### Added

### Changed

### Removed

### Fixed

### Security
- Upgraded java base image to nano:11.0.12.0.7.centos7.9-20210923

## [9.0.0] - 2021-09-17
### Added
- Upgraded elasticsearch version to 7.10.2
- HBP: custom annotations for helm hook jobs and test pods made user configurable
- HBP:imagePullSecrets (for pulling images from docker registries) made user-configurable.
- HBP createDrForClient flag added to allow client application (running on istio) to access BELK running without istio
- automountserviceaccounttoken parameter set to false in service account of job/pod which do not use kubectl/k8s api

### Changed
- RBAC changes: Separate Service accounts created for jobs/pods with minimum required permissions
- RBAC changes: volume types in PSP to only needed types replacing '*'.

### Removed

### Fixed
- CSFS-37843 : sec-admin-es and upgrade jobs failed intermittently when few ES nodes join cluster while securityadmin is running
- HBP: Removed chart.version from common labels for PVCs
- Install/Upgrade job OOMKilled issue

### Security
- Upgraded kubectl image to v1.21.1-nano-20210702 to fix vulnerability


## [8.1.0] - 2021-06-11
### Added
- CSFID-3371: Support to run containers with configurable userid
- HBP: common_labels flag to inject common labels to all resources
- Affinity, tolerations and nodeSelector feature for jobs and helm test pods

### Changed
- Replaced antiAffinity parameter with podAntiAffinity having options to configure soft/hard or custom definition
- Parameters rbac.enabled and serviceaccount are moved from global level to chart level as per HBP.
- Replaced es_securityContext with securityContext
- Replaced jobResources with jobs.hookJobs.resources and installUpgradejobResources with jobs.secAdminEsUpgradeJob.resources
- Replaced customResourceNames.installJob with customResourceNames.secAdminEsJob
- Helm test pods cleaned up on deletion of release.
- HBP: NOTES.txt enhanced to provide more information to customers

### Removed
- customResourceNames.postDeletePrehealJob section is removed from values.yaml as its functionality is moved to postDeleteCleanupJob

### Fixed
- Install job remained in error state after rollback to revision 1


## [8.0.0] - 2021-04-14
- Replaced searchguard by opendistro security
- Added support for kibana multitenancy
- Updated docker image with es rebuilt rpm
- Added an option where ES chart can accept full internalusers.yml file or admin username, password from pre-created secret when sensitive info is enabled
- Added new user kibanaserver in internal_users.yml required by kibana for backend interactions with ES.
- Added new role kibana_multitenancy_user (mapped to all users) for kibana multitenancy.
- Added restoreSystemIndices flag to control restore of system indices during helm restore.
- Added HBP k8s common labels
- Added HBP provision to configure timezone.
- Added HBP provision to configure custom annotations for pods.
- Updated default repo from centos8 to centos7
- Fixed nodeAffinity issue in elasticsearch
- Updated default value of istio.version to 1.7

## [7.0.1] - 2021-01-20
- defined brOption as an integer in BrPolicy

## [7.0.0] - 2020-12-18
- CSFLDA-2971: Added resource limit/request to scale and heal jobs
- CSFS-29143: Minimized RBAC privileges for charts.
- CSFLDA-2954: Updated delete-pvc job name and hook-delete policies
- Added helm test
- Updated default values of istio parameters for istio 1.6
- Added provision to add/override elasticsearch.yml configurations.
- Added support for handling sensitive info
- updated elasticsearch image to point to latest java base image
- Added support for hostAlias
- Renamed parameter istio.envoy_health_chk_port to istio.envoy.healthCheckPort and also added istio.envoy.stopPort.
- Updated default repo from centos7 to centos 8
- Fixed es-client pod warning message during upgrade
- Removed "systemid" key from harmonized logs
- Docker image from delivered

## [6.1.3] - 2020-10-23
- Added support for istio cni disabled
- Istio sidecar inject annotation added as per istio.enabled flag
- Upgraded kubectl image to v1.17.8-nano-20201006-9214
- CSFS-29825: Added env variable NSS_SDB_USE_CACHE
- CSFS-29870: Removed extra space from _helpers.tpl to solve lint issue in helm version 2.14.1

## [6.1.2] - 2020-10-06
- CSFOAM-6395: Updated templatename with chart.templatename

## [6.1.1] - 2020-09-30
- Updated README.md file
- CSFS-24538: Saving list of indices in snapshot as a file in /elasticsearch_backup
- CSFS-28181: Removed jdk bundled with elasticsearch from the image
- Added support for istio 1.4
- Elasticsearch logging format modified for unified logging
- Addition of prefix to pod names, job and container names
- Added nameoverride and fullname override configuration changes
- updated job and job container template names
- CSFS-28597: Added new headless services for prometheus, removed cpro annotations from pods.
- updated docker image repo to choose between elasticsearch cos7 and cos8 images.
- Docker images moved to delivered

## [6.1.0] - 2020-08-31
### Updated
- Helm hook-delete-policy of pre/post-upgrade jobs made user configurable
- CSFS-24844: Updated ES sg-configmap parameters to be evaluated as template
- ELK upgrade to 7.8.0
- CSFS-26865: Updated the elasticsearch-graphana.json
- Updated cbura imageTag
- Added provision for self signed certificates for transport layer via docker entrypoint when istio is enabled 
- CSFS-27150: Added support for CKEY external to istio mesh
- Excluded .signals* indices from ES Backup restore in docker image
- Replaced CMS garbage collector with G1GC
- Moved ES docker image to delivered

## [6.0.21] - 2020-07-13
### Updated
- Added Pod affinity
- Added fsGroup, supplementary groups, MCS label
- Added readiness and liveness probe check
- Support for pre-created Service Account, role and rolebinding
- Added customized security annotation which are user configurable
- Added support for istio
- Fixed annotations warning on upgrade
- Added provision for cutomized labels to pods
- helmbestpractice changes for service account and rbac flag
- Fixed SG 6-7 upgrade issue when istio is enabled
- CSFS-22260: Added cleanup-job to delete remaining resources on purge
- CSFLDA-2602: Updated es-prometheus pod level annotations to work with istio enabled chart
- Integration with keycloak in mTLS
- Fixing Helm3 issue with headless svc
- Removed unused parameter base64RootCA
- Moved docker images to delivered

## [6.0.20] - 2020-04-23
### Updated
- Helm3 changes
- Istio-Style Formatting for ports

## [6.0.19] - 2020-02-11
### Updated
- Modified service account for elasticsearch
- Modification of role in Post-delete job
- Handled sg migration failures on data node not detected(Delivered as BELK-19.12 patch with chart version 6.0.1810)
- Fix for files have insecure file permission in elasticsearch image
- Improved backup and restore scripts in elasticsearch docker
- Fix for files have insecure file permission in elasticsearch image for elasticsearch.yml and jvm.options
- Added permission in post-upgrade job to view logs of pod
- Added support for ES cipher suites
- Added autoUpdateCron in BrPolicy for automatically deleting/creating/updating cronjob based on other parameters
- Fixed restore script in elasticsearch docker
- Moved docker image to delivered

## [6.0.18] - 2019-12-18
### Updated
- Removed es-svcprometheus service that contained es-prometheus annotations 
- Added es-prometheus annotations at pod level(es-master,es-data,es-client)
- Modified readiness probe for es-client to check searchguard health.
- Updated java_opts & network host to support IPv6 Env
- Fix for client pod logs breaking terminal
- made prometheus scrape annotation for https endpoints user configurable
- updated elasticsearch image to point to latest java base image
- Moved elasticsearch image to delivered

## [6.0.17] - 2019-10-30
### Updated
- Added es-prometheus service to scrape elasticsearch metrics
- Added postscalein job for deleting unused PVCs
- Updated es-prometheus service to add flag for SG enabled
- Improved SG migration code for ELK6 to ELK7 upgrade and removed sg_migrate flag.
- CSFLDA-2118: Updated BrPolicy for configmap restore
- Added autoEnableCron in BrPolicy
- Upgraded base image to centos-7.7
- Updated cbura image to 1.0.3-983, updated registry parameter
- Updated to latest java base image
- Moving elasticsearch images to docker-delivered

## [6.0.16] - 2019-10-17
### Updated
- Added ignoreFileChanged option in Brpolicy
- Upgraded kubectl image to v1.14.7-nano

## [6.0.15] - 2019-09-11
### Updated
- Modified readiness probe of es-master(CSFLDA-2113)
- Fixed indentation for nodeSelector in es-client & es-master

## [6.0.14] - 2019-08-29
### Updated
-  Moved elasticsearch images to delivered

## [6.0.13] - 2019-08-23
### Updated
- CSFS-15048: Updated cbura sidecar image to 1.0.3-871

## [6.0.12] - 2019-08-22
### Updated
- CSFLDA-1975: Moved elasticsearch image to JAVA 11 and centos nano image 

## [6.0.11] - 2019-08-16
### Updated
- Fixed kibana restore issue for re-indexing kibana index
- Moved docker images to delivered

## [6.0.10] - 2019-08-12
### Updated
- Fixed kibana restore issue for re-indexing kibana index

## [6.0.9] - 2019-08-06
### Updated
- Increased /tmp directory volume for cbur-sidecar.

## [6.0.8] - 2019-08-05
### Updated
- Fixed kibana restore issue
- Provided /tmp directory volume for backup.

## [6.0.7] - 2019-07-11
### Updated
- CSFS-14419: Made network_host user configurable. 

## [6.0.6] - 2019-07-08
### Added
- Moved all images to delivered

## [6.0.5] - 2019-07-06
### Added
- Fixed upgrade(ES-6 to ES-7) issue by adding SG migrate script.

## [6.0.4] - 2019-07-06
### Added
- Fixed upgrade(ES-6 to ES-7) issue by adding SG migrate script.

## [6.0.3] - 2019-07-05
### Added
- Added pvc for master pods as cluster state is persisted in path.data directory between node restarts

## [6.0.2] - 2019-07-01
### Modified
- Modified brOption to 0
- Modified pvc deletion to check for component=elasticsearch also

## [6.0.1] - 2019-06-28
### Added
- Upgraded ELK to 7.0.1
- Pointed the images to candidates

## [6.0.0] - 2019-06-28
### Added
- Upgraded ELK to 7.0.1
- Added job resources to jobs
- Added security annotations

## [5.2.6] - 2019-05-28
### Added
- Updated brOption and added cbur resource limits

## [5.2.5] - 2019-05-21
### Added
- Updated BRPolicy

## [5.2.4] - 2019-05-20
### Added
- Added security annotation

## [5.2.3] - 2019-05-14
### Added
- CSFID-2215:Add ElasticSearch dashboard for grafana

## [5.2.2] - 2019-04-30
### Added
- Upgraded ELK to 6.6.1
- moved images to delivered 

## [5.2.1] - 2019-04-25
### Added
- Upgraded base image

## [5.2.0] - 2019-04-25
### Added
- Upgraded ELK to 6.6.1

## [5.1.3] - 2019-03-26
### Added
- Upgraded base image to centos 7.6
- Moved images to delivered

## [5.1.2] - 2019-03-22
### Added
- Upgraded base image to centos 7.6 

## [5.1.1] - 2019-03-12
### Added
- CSFLDA-1590: Updated sg_roles and sg_roles_mapping with latest searchguard configurations

## [5.1.0] - 2019-03-04
### Added
- CSFID-1611: Keycloak integration

## [5.0.3] - 2019-02-28
### Added
- CSFLDA-1540: Implemented ElasticSearch POD anti-affinity rules
- Test move chart to stable

## [5.0.2] - 2019-02-14
### Added
- CSFLDA-1540: Implemented ElasticSearch POD anti-affinity rules

## [5.0.1] - 2019-02-01
### Added
- Upgraded chart to 6.5.4-oss
- Moved all docker images to delivered

## [5.0.0] - 2019-01-25
### Added
- Upgraded chart to 6.5.4-oss


## [4.4.8] - 2019-01-24
### Added
- CSFLDA-1436: fixed snapshot_name issue for postRestoreCommand.sh

## [4.4.7] - 2019-01-24
### Added
- CSFLDA-1436: Backup and restore enhancements. User no need to specify snapshot name in the values.yaml

## [4.4.6] - 2019-01-15
### Added
- CSFS-9322:Harmonized logging modified timezone field

## [4.4.5] - 2019-01-10
### Added
- CSFS-9384: Client doesnot recover after OoM
- CSFS-9385: ES-client threw OoM

## [4.4.4] - 2019-01-04
### Added
- Backup and restore below issues are fixed
- CSFLDA-1414: Backup is failing due to path_repo issue when we deploy EFKC chart with SearchGuard .
- CSFLDA-1420: Number of Snapshots were getting increased as the number of Datapods were getting increased.
- CSFLDA-1421: Backup of indices was failing when we deploy chart with SearchGuard.

## [4.4.3] - 2019-01-02
### Added
- Backup and restore issue fixed

## [4.4.2] - 2018-12-21
### Added
- Backup event if condition is added

## [4.4.1] - 2018-12-20
### Added
- Upgraded ES to 6.5.1

## [4.4.0] - 2018-12-19
### Added
- ES Implementation of backup LCM event for elasticsearch

## [4.3.3] - 2018-11-29
### Added
- ES chart with SG improvement

## [4.3.2] - 2018-11-26
### Added
- ES with SG image with Harmonized logging

## [4.3.1] - 2018-11-22
### Added
- Local Storage fo ES

## [4.3.0] - 2018-11-21
### Added
- Harmonized logging for ES
- Docker base image change which contains security fix
- Fix for deleting statefulsets while upgarding


## [4.2.0] - 2018-10-29
### Added
- Elasticsearch version Upgraded from 6.2.4 to 6.4.1

## [4.1.10] - 2018-10-24
### Added
- CSFS-7852:remove test folder

## [4.1.8] - 2018-09-27
### Added
- Heal LCM event is added.

## [4.1.7] - 2018-09-26
### Changed
- Resource properties removed from templates and added in the values.yaml

## [4.1.6] - 2018-09-19
### Changed
- Modified secret creation

## [4.1.5] - 2018-09-10
### Changed
- Searchguard configmap is passed from values file

## [4.1.4] - 2018-09-05
### Added
- Update configuration LCM event is added

## [4.1.3] - 2018-09-05
### Added
- CSFLDA-802: Upgrade and rollback LCM events are added for ES

## [4.1.2] - 2018-09-04
### Changed
- CSFLDA-897: Fix for bug while installing chart with wrong base64 password

## [4.1.1] - 2018-09-03
### Changed
- Modified update strategy and podmanegement policy to take from values file

## [4.1.0] - 2018-08-31
### Added
- Install and delete LCM events are added for ES

## [4.0.4] - 2018-08-30
### Changed
- Updated image registry name from registry to global registry

## [4.0.3] - 2018-08-28
### Changed
- CSFLDA-816: Fixed ES services endpoints
### Added
- CSF chart relocation rules enforced

## [4.0.1] - 2018-08-17
### Changed
- CSFS-4771:- Cannot deploy more than one ElasticSearch in a namespace

## [4.0.0] - 2018-08-13
### Changed
- Chart to follow semantic naming. belk-<component>-<opensource version>-<csf release year>.<csf release month>.<patch> 
  e.g. belk-elasticsearch-6.2.4-18.07.03
- docker image on Centos 7.5
### Added
-  PSP/RBAC support


# Changelog
All notable changes to chart **bssc-dashboards** are documented in this file,
which is effectively a **Release Note** and readable by customers.

Do take a minute to read how to format this file properly.
It is based on [Keep a Changelog](http://keepachangelog.com)
- Newer entries _above_ older entries.
- At minimum, every released (stable) version must have an entry.
- Pre-release or incubating versions may reuse `Unreleased` section.

## [Unreleased] or [Released]
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
- Fixed Opensearch plain text password issue in Dashboards chart.

## [13.0.0] - 2023-11-24
### Added
- Upgraded to OpenSearch Dashboards v2.11.0
- Addition of Index State Management Plugin for managing indices.
- HBP: Support for reading user-supplied server certificates via kubernetes secret (alternative to sensitiveInfoInSecrets way)
- HBP: Added dashboards.certificate section at workload level to control configurations of cert-manager generated certificates (and has higher precedence over security.certManager).
- HBP: Added imageFlavor and imageFlavorPolicy at container, workload, root and global levels.
- HBP: Added disablePodNamePrefixRestrictions at global and root levels to configure PodNamePrefix restrictions.
- Included containerName field for unified logs.

### Changed
- HBP: global.certManager is enabled to true by default.

### Removed

### Fixed

### Security
- Compliant for UKTSR 8.1 and 8.5
- Updated base images to rocky-nano:8.8-20231016. Updated java base image (for java modules) to java_base/11/nano:11.0.21.0.9.rocky8.8-20231027 (rocky8 jdk11), java_base/17/nano:17.0.9.0.9.rocky8.8-20231027 (rocky8 jdk17).
- Updated kubectl image to 1.26.10-rocky8-nano-20231027


## [12.0.0] - 2023-09-29

### Added
- Upgraded to OpenSearch Dashboards v2.9.0
- CSFID:4243 - Support for OpenSearch Dashboards Reporting feature
- CSFID:4348 - Client-certificate based authentication for dashboards backend-server interaction with opensearch
- unifiedLogging section added in values.yaml for unified logging parameters, with support continued for reading from harmonizedLogging section for backward compatibility.
- HBP: Added global.flatRegistry to support container registries with a flat structure.
- HBP: Added a newer section tls.secretRef under unifiedLogging.syslog to read syslog tls certificates.
- HBP: Added enableDefaultCpuLimits parameter at global and root levels to enable the pod CPU resources limit in all containers.
- HBP: sizeLimit is configured for all the emptyDirs of the container and made user-configurable in values.yaml file.
- HBP: certManager.enabled made user-configurable at root level in addition to existing flags under global and workload levels.

### Changed
- Opensearch-dashboards plugins are separately built in a different docker image (bssc-dboplugins) and moved to expected location through an init-container.
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

### Fixed

### Security
- Updated kubectl image to v1.26.8-rocky-nano-20230901 (rocky8)
- Updated base images to rocky-nano:8.8-20230901. Updated java base image (for java modules) to java_base/11/nano:11.0.20.0.8.rocky8.8-20230901 (rocky8 jdk11), java_base/17/nano:17.0.8.0.7.rocky8.8-20230901 (rocky8 jdk17).

## [11.3.0] - 2023-06-22
### Added
- Upgraded to OpenSearch Dashboards v2.7.0
- HBP: TopologySpreadConstraints supported for dashboards pods
- Added ephemeral storage request and limits to all helm hook jobs.
- Reload of syslog tls secret supported through csf-reloader annotation

### Changed
- Docker image size reduced for dashboards
- Readiness and Liveness probes modified to use TCP probe check instead of /api/status endpoint (due to security concerns). Also, /api/status is not required to be set in opensearch_security.auth.unauthenticated_routes when security is enabled.
- HBP: Lengths of containerName prefix and containerName suffix not allowed to exceed 34 and 28 characters respectively
- HBP: Excluded seccompProfile from the pod-level securityContext for Openshift pre-4.11 environments
- HBP: certManager.enabled made user-configurable at global scope in addition to existing security.certManager.enabled.
- HBP: imagePullSecrets made user-configurable at global and workload scope in addition to existing imagePullSecrets at root level.
- HBP: Replaced the deprecated annotation nginx.ingress.kubernetes.io/secure-backends with nginx.ingress.kubernetes.io/backend-protocol for ingress
- HBP: Replaced '.' with '-' for the ingress name according to ingress naming convention

### Removed

### Fixed

### Security
- Updated kubectl image to v1.25.10-nano-20230602 (centos7) & v1.26.5-rocky-nano-20230602 (rocky8)
- Updated base images to rocky-nano:8.8-20230602 and centos-nano:7.9-20230428. Updated java base image (for java modules) to java_base/11/nano:11.0.19.0.7.rocky8.8-20230602 (rocky8 jdk11), java_base/17/nano:17.0.7.0.7.rocky8.8-20230602 (rocky8 jdk17) and java_base/11/nano:11.0.19.0.7.centos7.9-20230428 (centos7).


## [11.2.0] - 2023-03-31
### Added
- HBP: HorizontalPodAutoscaler supported for dashboards pods
- Support sending pod logs to syslog along with stdout. Can be configured under dashboards.unifiedLogging.syslog.
- HBP: Unified logging "extension" parameters made configurable in values.yaml
- Issuer group of the certificate created by CertManager made user configurable
- CSFS-51383: Custom annotations for dashboards service made configurable at service.annotations

### Changed
- Updated harmonizedLogging configuration to add the fields host, system and systemid in the dashboards pod logs
- dashboards.env section is rendered as a template, allows referencing other values.yaml parameters.

### Removed

### Fixed
- CSFS-50634: Added quotes to all keys and values configured under custom labels and annotations
- CSFS-51472: Disabled fips in init container during the generation of secret keys used for encryption of sensitive information.
- Added common label and annotations for PDB created in dashboards

### Security
- Updated kubectl image to v1.25.6-nano-20230130 (centos7), v1.24.10-rocky-nano-20230306 (rocky8)
- Updated base images to java_base/11/nano:11.0.18.0.10.centos7.9-20230130 (centos7), java_base/11/nano:11.0.18.0.10.rocky8.7-20230306 (rocky8 java 11) , java_base/17/nano:17.0.6.0.10.rocky8.7-20230306 (rocky8 java 17)


## [11.1.0] - 2022-12-16
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
- CSFS-49939: Fixed the upgrade issue when dashboards and indexearch are installed as separate releases
- CSFS-49979: Fixed readiness/liveness probe issue when dashboards container alone restarts due to some config issue
- Fixed wrong rendering of annotations for chart-created istio gateway
- CSFS-49900: Updated NOTES.txt to remove extra space between labels used to list the dashboard pods

### Security
- Updated kubectl image to v1.25.4-nano-20221125 (centos7), v1.25.4-rocky-nano-20221125 (rocky8)
- Updated base images to java_base/11/nano:11.0.17.0.8.centos7.9-20221031 (centos7), java_base/11/nano:11.0.17.0.8.rocky8.7-20221125 (rocky8 java 11) , java_base/17/nano:17.0.5.0.8.rocky8.7-20221125 (rocky8 java 17)


## [11.0.0] - 2022-09-30
### Added
- Upgraded to OpenSearch Dashboards v2.2.1
- Compliance with HBP v3.0.0
- Support added for java 17 for Rocky8
- Support for upgrade with Dual Stack
- HBP: global.annotations and global.labels are added for all k8s resources.

### Changed
- Helm chart name changes from belk-kibana to bssc-dashboards to avoid elastic trademarks/wordmarks
- Rocky8 java 11 based image made default option. Provision to configure either of rocky8-java11, rocky8-java17 or centos7-java11 is provided.
- HBP: Common labels values changed as per HBP 3.0.0. They will be added by default for all resources.
- K8s Jobs and helm test pod names updated to include fullnameoverride and nameoverride

### Removed
- common_labels option to enable/disable common labels is removed from values.yaml

### Fixed
- CSFS-46793: Istio CNI and Istio Version precedence issue fixed
- CSFS-46995: apiversion check for BrPolicy fixed
- SERVER_HOST env can be now configured through values.yaml at dashboards.env

### Security
- Updated kubectl image to v1.24.3-nano-20220729 version
- Updated base images to java_base/11/nano:11.0.16.0.8.centos7.9-20220729 (centos7), java_base/11/nano:11.0.16.0.8.rocky8.6-20220826 (rocky8 java 11) , java_base/17/nano:17.0.4.0.8.rocky8.6-20220826 (rocky8 java 17)


## [10.0.0] - 2022-06-30
### Added
- Migrated from Kibana to OpenSearch-Dashboards 1.3.2
- Support for rocky8 based image
- HBP: rbac.psp.create and rbac.scc.create added to control creation of PodSecurityPolicy and SecurityContextConstraints
- HBP: PodDisruptionBudget(PDB) feature is added
- HBP: Customized labels are added
- HBP: Pod PriorityClassName made user configurable
- HBP: Added appProtocol field to services
- Ephemeral storage/emptyDir request and limit values for containers are made user configurable
- Support for Dual-stack 

### Changed
- HBP: sensitiveInfoInSecret.secretName is changed to sensitiveInfoInSecret.credentialName as per the naming convention
- HBP: kibana.podLabels replaced by kibana.custom.pod.labels
- HBP: Container name prefix will be added to all containers irrespective of fullnameOverride or nameOverride configuration
- HBP: Timezone can be configured using global.timeZoneEnv or timezone.timezoneEnv at chart scope
- HBP: Changed the structure of values under istio.gateways array for kibana
- HBP: automountServiceAccountToken set to false in all serviceAccount objects and set to true/false in all the pods based on need.
- Chart made compatible with latest BrPolicy apiversion
- Values of Resource limits and requests for init container reduced
- HBP: Custom annotation values are quoted

### Removed
- HBP: timezone.mountHostLocaltime.mountHostLocaltimePath is now removed
- HBP: Removed hook-failed annotation value from hook deletion policy

### Fixed
- Kibana Service Account names are limited to 63 characters.

### Security
- Updated kubectl image to v1.24.0-nano-20220530 version
- Updated centos7 base image to 11.0.15.0.9.centos7.9-20220530


## [9.3.0] - 2022-03-04
### Added
- readOnlyRootFilesystem enabled in all containers
- Cert Manager feature supported

### Changed

### Removed

### Fixed
- CSFS-42360: Kibana Log Export errors
- CSFS-43142: Kibana Log-exporter: Limitation of downloading upto 10k records resolved
- CSFS-40629: Kibana harmonized logs should be pushed to *log indices and updated the logging parameters format
- CSFS-41391: Ingress name made user configurable

### Security
- Updated java base image to 11.0.14.1.1.centos7.9-20220301
- Updated kubectl image to v1.23.1-nano-20220301

## [9.2.0] - 2021-12-21
### Added
- Kibana Log exporter plugin
- HBP: CommonLabels to all kubernetes resources

### Changed
- HBP: istio.version value type changed from float to the string
- Increased initialDelaySeconds and failureThreshold for liveness and readiness probes for kibana

### Removed

### Fixed
- CSFS-36073: Kibana Ingress resource API version is changed from v1beta1 to v1.

### Security
- Updated java base image to 11.0.13.0.8.centos7.9-20211208
- Fixed vulnerabilities in Kibana
- Updated kubectl image to v1.22.1-nano-20211208

## [9.1.1] - 2021-11-25
### Added

### Changed

### Removed
- CSFS-40064: Removed default credentials from values.yaml

### Fixed
- CSFS-41427: Added robustness to prevent intermittent kibana index migration issue

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
- Upgraded kibana version to 7.10.2
- HBP: custom annotations for helm hook jobs and test pods made user configurable
- HBP: Limit Scope of Istio Routing Rules with exportTo
- HBP:imagePullSecrets (for pulling images from docker registries) made user-configurable.
- HBP createDrForClient flag added to allow client application (running on istio) to access BELK running without istio
- automountserviceaccounttoken parameter set to false in service account of job/pod which do not use kubectl/k8s api

### Changed
- HBP: Istio gateway configurations moved from istio.gateway to istio.sharedHttpGateway and istio.gateways sections as per HBP.
- HBP: Replaced deprecated ingress annotation ingress.citm.nokia.com/sticky-route-services with nginx.ingress.kubernetes.io/affinity
- RBAC changes: Separate Service accounts created for jobs/pods as per required permissions.
- RBAC changes: volume types in PSP to only needed types replacing '*'.

### Removed

### Fixed

### Security
- Upgraded kubectl image to v1.21.1-nano-20210702 to fix vulnerability

## [8.1.0] - 2021-06-11
### Added
- CSFID-3371: Support to run containers with configurable userid
- HBP: common_labels flag to inject common labels to all resources
- Affinity, tolerations and nodeSelector feature and resource configuration for jobs and helm test pods

### Changed
- Parameters rbac.enabled and serviceaccount are moved from global level to chart level as per HBP.
- Helm test pods cleaned up on deletion of release.
- HBP: NOTES.txt enhanced to provide more information to customers

### Removed

### Fixed

## [8.0.0] - 2021-04-14
- Replaced searchguard by opendistro security
- Added support for kibana multitenancy
- Replaced admin user by kibanaserver user for backend interaction of kibana with elasticsearch.
- Added HBP k8s common labels
- Added HBP provision to configure timezone.
- Added HBP provision to configure custom annotations for pods.
- Updated ingress.tls section to be evaluated as template
- Kibana logs are compliant with harmonized-logging format
- Updated default repo from centos8 to centos7
- handlebar package version upgraded to 5.7.7 in log exporter.
- Updated default value of istio.version to 1.7

## [7.0.0] - 2020-12-18
- Added support for handeling sensitive information
- CSFS-29143: Minimized RBAC privileges for charts.
- Updated README.md file for handeling sensitive information
- Added helm test
- Updated default values of istio parameters for istio 1.6
- updated kibana image to point to latest java base image
- Added support for hostAlias
- Added parameters under istio.envoy for health check & termination ports
- Updated default repo from centos7 to centos 8
- Docker image from delivered

## [6.1.3] - 2020-10-23
- Added support for istio cni disabled
- Istio sidecar inject annotation added as per istio.enabled flag
- CSFS-29825: Added env variable NSS_SDB_USE_CACHE
- CSFS-29870: Removed extra space from _helpers.tpl to solve lint issue in helm version  2.14.1

## [6.1.2] - 2020-10-06
- CSFOAM-6395: Updated templatename with chart.templatename

## [6.1.1] - 2020-09-30
### Updated
- Fixed trademark bugs for CSFLDA-2765, CSFLDA-2764
- Updated README.md file
- Added support for istio 1.4
- CSFS-28353: Added TIMESTAMP_FIELD field as environmental value
- addition of prefix to pod names, job and container names
- added nameoverride and fullname override configuration changes
- updated docker image repo to choose between kibana cos7 and cos8 images.
- Docker images moved to delivered

## [6.1.0] - 2020-08-31
### Updated
- CSFS-24844: Updated kibana sg-configmap parameters to be evaluated as template
- CSFS-26654: Added server.rewritebasepath property to remove the warning
- CSFS-23274: Added csp.strict in kibana_configmap_yml
- Added support for mounting additional certificates to kibana pod
- Upgrade Kibana to 7.8.0
- Added support for log exporter plugin
- CSFS-27150: Added support for CKEY external to istio mesh
- Trademark changes for 7.8.0 kibana
- Incremental Trademark changes for 7.8.0 Kibana
- kibana chart with latest csan, exporter plugin
- Added env variables for exporter plugin
- Moved docker images to delivered

## [6.0.11] - 2020-07-13
### Updated
- Added fsGroup, supplementary groups, MCS label
- Updated readiness and liveness probe checks
- Support for pre-created Service Account, role and rolebinding
- Added customized security annotation which are user configurable
- Added support for istio
- Fixed annotations warning on upgrade
- Added provision for customized labels to pods
- Added istio-ingress gateway support
- helmbestpractice changes for service account and rbac flag
- Added serviceentry & virtualsvc for integration with keycloak in mTLS

## [6.0.10] - 2020-04-23
### Updated
- Helm3 changes
- Istio-Style Formatting for ports

## [6.0.9] - 2020-02-11
### Updated
- Added service account for kibana
- Added kibana optimization for SG and CSAN in k_sg image
- Docker image file permissions are changed and restricted 
- Added autoUpdateCron in BrPolicy for automatically deleting/creating/updating cronjob based on other parameters
- CSFS-18987: Kibana UI changes done to correct trademark policy violations
- Modified default ingress path to /logviewer
- Moved docker image to delivered

## [6.0.8] - 2019-12-18
### Updated
- Added latest csan plugin.
- Server.host set to pod hostname for compatibility with IPv6
- Updated kibana image to point to latest centos base image
- Moved kibana docker image to delivered


## [6.0.7] - 2019-12-02
### Updated
- Added latest csan plugin.
- Server.host set to pod hostname for compatibility with IPv6
- Updated kibana image to point to latest centos base image

## [6.0.6] - 2019-10-30
### Updated
- CSFS-14508: Added separator for secrets
- CSFLDA-2118: Added BrPolicy for configmap restore
- Creating optimize directory in kibana image
- Added autoEnableCron in BrPolicy
- Upgraded base image to centos-7.7
- Moving kibana images to docker-delivered

## [6.0.5] - 2019-08-29
### Updated
- Moved kibana images to delivered

## [6.0.4] - 2019-08-22
### Updated
- CSFLDA-1975: Moved kibana image to centos nano image

## [6.0.3] - 2019-07-31
### Added
- CSFS-14508: Added secret, env and values for csan

## [6.0.2] - 2019-07-19
### Added
- CSFS-14403: Added user configurable capture group for kibanabaseurl

## [6.0.1] - 2019-07-08
### Added
- Moved all images to delivered


## [6.0.0] - 2019-06-28
### Changed
- Upgraded kibana to 7.0.1

## [5.2.7] - 2019-06-28
### Changed
- CSFS-14066: kibana password is not changed after helm upgrade 

## [5.2.6] - 2019-06-27
### Changed
- Updated kibana docker images to delivered
- Added server.ssl.supportedProtocols: ["TLSv1.2"] to kibana configmap

## [5.2.5] - 2019-06-26
### Added
- Kibana-csan plugin is added

## [5.2.4] - 2019-05-21
### Added
- Added security annotation for kibana

## [5.2.3] - 2019-05-20
### Added
- Added security annotation


## [5.2.2] - 2019-04-30
### Added
- Upgraded chart to 6.6.1
- Moved docker images to delivered
- Removed Sentinl plugin

## [5.2.1] - 2019-04-25
### Added
- Upgraded base image

## [5.2.0] - 2019-04-25
### Changed
- Upgraded ELK to 6.6.1
- Removed Sentinl plugin

## [5.1.5] - 2019-03-26
### Changed
- Upgraded base image to Centos 7.6
- Moved images to delivered

## [5.1.4] - 2019-03-22
### Changed
- Upgraded base image to Centos 7.6

## [5.1.3] - 2019-03-18
### Changed
- Installed sentinl plugin for kibana chart

## [5.1.2] - 2019-03-15
### Changed
- Installed sentinl plugin for kibana 

## [5.1.1] - 2019-03-11
### Changed
- CSFID-1611: Keycloak integration - added searchguard.openid.root_ca parameter to kibana configmap

## [5.1.0] - 2019-03-04
### Added
- CSFID-1611: Keycloak integration
- Liveness and Readiness probe modified

## [5.0.5] - 2019-02-14
### Added
- CSFLDA-1542: Implemented Kibana POD anti-affinity rules

## [5.0.4] - 2019-02-13
### Added
- CSFS-10055: Kibana readiness probe is reporting "ready" too early

## [5.0.3] - 2019-02-01
### Added
- Upgraded to 6.5.4-oss
- Reduced the memory limit and request to kibana
- removed xpack env variables in docker image
- moved docker images to delivered

## [5.0.2] - 2019-01-31
### Added
- removed xpack env variables in docker image

## [5.0.1] - 2019-01-29
### Added
- Reduced the memory limit and request to kibana

## [5.0.0] - 2019-01-28
### Added
- Upgraded to 6.5.4 oss rpm

## [4.3.1] - 2019-01-04
### Added
- Fix for CSFLDA-1407:Kibana UI prompts twice for authentication

## [4.3.0] - 2018-12-20
### Added
- Upgraded kibana to 6.5.1

## [4.2.1] - 2018-11-05
### Added
- CSFS-7753: belk-efkc ingress configuration, TLS support missing

## [4.2.0] - 2018-10-29
### Added
- Kibana version Upgraded from 6.2.4 to 6.4.1

## [4.1.7] - 2018-10-26
### Changed
- CSFS-7750: Ingress not configurable in Kibana helm chart.

## [4.1.6] - 2018-10-24
### Changed
- CSFS-7750: Ingress not configurable in Kibana helm chart.
- CSFS-7753: belk-efkc ingress configuration, TLS support missing


## [4.1.5] - 2018-10-23
### Changed
- CSFS-7748: BELK add proxy authentication support


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
### Changed
- CSFLDA-897: Fix for bug while installing chart with wrong base64 password

## [4.1.0] - 2018-08-31
### Added
- Install and delete LCM events are added for kibana

## [4.0.2] - 2018-08-30
### Changed
- Updated image registry name from registry to global registry

## [4.0.1] - 2018-08-28
##Changed
- CSFLDA-816: Fixed Kibana service endpoints detection

## [4.0.0] - 2018-08-13
### Added
- All future chart versions shall provide a change log summary
- PSP/RBAC support
### Changed
- Chart to follow semantic naming. belk-`component`-`opensource version`-`csf release year`.`csf release month`.`patch` 
  e.g.: belk-kibana-6.2.4-18.07.02
- docker image on Centos 7.5### Added

## [0.0.0] - YYYY-MM-DD
### Added | Changed | Deprecated | Removed | Fixed | Security
- your change summary, this is not a **git log**!


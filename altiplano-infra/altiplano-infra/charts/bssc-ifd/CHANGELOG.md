# Changelog
All notable changes to chart **bssc-ifd** are documented in this file,
which is effectively a **Release Note** and readable by customers.

Do take a minute to read how to format this file properly.
It is based on [Keep a Changelog](http://keepachangelog.com)
- Newer entries _above_ older entries.
- At minimum, every released (stable) version must have an entry.
- Pre-release or incubating versions may reuse `Unreleased` section.

## [Unreleased]
### Added
- CSF chart relocation rules enforced

## [13.0.1] - 2023-12-01
### Added

### Changed

### Removed

### Fixed

### Security
- Updated base images to rocky-nano:8.9-20231124. Updated java base image (for java modules) to java_base/11/nano:11.0.21.0.9.rocky8.9-20231124 (rocky8 jdk11), java_base/17/nano:17.0.9.0.9.rocky8.9-20231124 (rocky8 jdk17).
- Updated kubectl image to 1.26.11-rocky8-nano-20231124 and Cbura image to cbur-agent:1.1.0-alpine-6419
- Fixed Opensearch plain text password issue in Dashboards chart.

## [13.0.0] - 2023-11-24
### Added
- Upgraded to OpenSearch and Opensearch Dashboards v2.11.0.
- Upgraded from td-agent v4.5.0 to fluent-package v5.1.0, td-agent rpm is renamed to fluent-package.
- Upgraded fluent-package to v5.0.1(fluentd 1.16.2) used in fluentd sidecar for all BSSC components.
- Addition of Index State Management Plugin for managing indices.
- Audit logging feature enabled in Indexsearch
- HBP: Support for reading user-supplied server certificates via kubernetes secret (alternative to sensitiveInfoInSecrets way)
- HBP: Added indexmgr.certificate, fluentd.certificate, dashboards.certificate, indexsearch.nodeCrt and indexsearch.adminCrt sections at workload level to control configurations of cert-manager generated certificates (and has higher precedence over security.certManager, fluentd.certManager).
- HBP: Added imageFlavor and imageFlavorPolicy at container, workload, root and global levels.
- HBP: Added disablePodNamePrefixRestrictions under all component at global and root levels to configure PodNamePrefix restrictions.
- HBP: Added provision to configure any num of internal users in key-value pairs, as an alternative to yaml file structure (secInternalUserYml).
- Included containerName field for unified logs in all BSSC components

### Changed
- HBP: global.certManager is enabled to true by default.
- File paths like /etc/td-agent and /var/log/td-agent are now changed to /etc/fluent and /var/log/fluent. Please update custom configs accordingly.

### Removed

### Fixed

### Security
- Compliant to UK-TSR 8.1 and 8.5
- Updated base images to rocky-nano:8.8-20231016. Updated java base image (for java modules) to java_base/11/nano:11.0.21.0.9.rocky8.8-20231027 (rocky8 jdk11), java_base/17/nano:17.0.9.0.9.rocky8.8-20231027 (rocky8 jdk17).
- Updated kubectl image to 1.26.10-rocky8-nano-20231027
- Updated Cbura image to cbur-agent:1.0.3-6028


## [12.0.0] - 2023-09-29
### Added
- Upgraded to OpenSearch and Opensearch-dashboards v2.9.0
- Upgraded to td-agent v4.5.0
- CSFID-3607: Support for Cross-Cluster-Replication. 
- CSFID-4399: Sending indexsearch logs to syslog via log4j (default option) while sending via fluentd sidecar is still supported.
- CSFID:3863 - Indexsearch restore behaviour can be customized using options in cbur_restore_parameters in values.yaml
- Automated rollback procedure (for downgrade to a lower opensearch version). Will be usable from next release onwards to perform single-step helm rollback.
- CSFID:4243 - Support for OpenSearch Dashboards Reporting feature
- CSFID:4348 - Client-certificate based authentication for dashboards backend-server interaction with opensearch. 
- Provision to configure REST API commands to be executed on bssc-indexsearch on every Helm Install/Upgrade/Rollback event.
- unifiedLogging section added for bssc-dashboards values for unified logging parameters, with support continued for reading from harmonizedLogging section for backward compatibility.
- HBP: Added global.flatRegistry to support container registries with a flat structure.
- HBP: Added a newer section tls.secretRef under unifiedLogging.syslog to read syslog tls certificates.
- HBP: Added enableDefaultCpuLimits parameter at global and root levels to enable the pod CPU resources limit in all containers.
- HBP: sizeLimit is configured for all the emptyDirs of the container and made user-configurable in values.yaml file.
- HBP: certManager.enabled made user-configurable at root level for all charts, in addition to existing flags under global and workload levels.

### Changed
- Opensearch-dashboards plugins are separately built in a different docker image (bssc-dboplugins) and moved to expected location through an init-container.
- HBP: Changed the image repo and tag according to HBP_Containers_name_1 and HBP_Containers_name_2
- HBP: Common label helm.sh/chart to use nameoverride (if configured) instead of chart-name
- HBP: Default values of ephemeral storage requests and limits are modified.
- HBP: Length of Pod suffix for helm test pods not allowed to exceed 19 characters
- HBP: CronJob name is limited to 52 characters by Kubernetes. Removed truncation of CronJob name based on resourceNameLimit.
- Assigned GID 1000 instead of root(0) to the default userid(1000) for the containers.
- Liveness probe for indexsearch client pods modified to tcpSocket check of 9200 port. Also, made readiness and liveness probes user-configurable for client pods.
- CSFS-48154: Updated opensearch-grafana.json to remove interval dropdown and followed grafana best practice to handle it internally based on $__rate_interval

### Removed
- HBP: global.registry1 is removed and global.registry is used for all images.
- Default limits for resources.cpu are removed from values.yaml for all containers. 
- Support for accepting certificates and credentials in Base64 format in values.yaml is removed.
- HBP: Helm v2 support is removed
- Support for centos7 is dropped.
- Parameter fluentd.useClusterAdminRole is removed and the chart would create required clusterrole (with min permissions) and not use cluster-admin.

### Fixed
- Added record_modifier filter in fluentd configuration to fix issues caused due to deprecation of de_dot feature of kubernetes_metadata_filter

### Security
- Updated kubectl image to v1.26.8-rocky-nano-20230901 (rocky8)
- Updated base images to rocky-nano:8.8-20230901. Updated java base image (for java modules) to java_base/11/nano:11.0.20.0.8.rocky8.8-20230901 (rocky8 jdk11), java_base/17/nano:17.0.8.0.7.rocky8.8-20230901 (rocky8 jdk17).
- Updated cbura image to 1.0.3-5650

## [11.3.0] - 2023-06-22
### Added
- Upgraded to Opensearch & OpenSearch Dashboards v2.7.0, td-agent v4.4.2
- HBP: TopologySpreadConstraints supported for indexsearch , dashboards and fluentd(applicable only for kind: Deployment and StatefulSet) pods.
- Added ephemeral storage request and limits to all helm hook jobs.
- Reload of syslog tls secret supported through csf-reloader annotation.

### Changed
- Docker image size reduced for all components
- Readiness and Liveness probes for dashboards pods modified to use TCP probe check instead of /api/status endpoint (due to security concerns). Also, /api/status is not required to be set in opensearch_security.auth.unauthenticated_routes when security is enabled.
- HBP: Lengths of containerName prefix and containerName suffix not allowed to exceed 34 and 28 characters respectively
- HBP: Excluded seccompProfile from the pod-level securityContext for Openshift pre-4.11 environments
- HBP: certManager.enabled made user-configurable at global scope in addition to existing  certManager.enabled flags under each component.
- HBP: imagePullSecrets made user-configurable at global and workload scope in addition to existing imagePullSecrets at root level.
- HBP: Replaced '.' with '-' for dashboard ingress name according to ingress naming convention
- HBP: Replaced the deprecated annotation nginx.ingress.kubernetes.io/secure-backends with nginx.ingress.kubernetes.io/backend-protocol for dashboard ingress
- Under security.sec_configmap section, whitelist_yml is deprecated and recommendation is to use allow_list_yml

### Removed

### Fixed

### Security
- Updated kubectl image to v1.25.10-nano-20230602 (centos7) & v1.26.5-rocky-nano-20230602 (rocky8)
- Updated cbura image to 1.0.3-5180
- Updated base images to rocky-nano:8.8-20230602 and centos-nano:7.9-20230428. Updated java base image (for java modules) to java_base/11/nano:11.0.19.0.7.rocky8.8-20230602 (rocky8 jdk11), java_base/17/nano:17.0.7.0.7.rocky8.8-20230602 (rocky8 jdk17) and java_base/11/nano:11.0.19.0.7.centos7.9-20230428 (centos7).


## [11.2.0] - 2023-03-31
### Added
- HBP: HorizontalPodAutoscaler supported for indexsearch client, dashboards and fluentd(applicable only for kind: Deployment) pods.
- HBP: Fluentd and indexmgr pod logs also follow unified logging format. Enabled by default at fluentd.unifiedLogging.enabled and indexmgr.unifiedLogging.enabled respectively
- HBP: Unified logging "extension" parameters made configurable in values.yaml
- Support sending pod logs to syslog along with stdout. Can be configured under unifiedLogging.syslog at global level or at the specific workload level.
- Issuer group of the certificate created by CertManager made user configurable
- CSFS-51383: Custom annotations for dashboards service made configurable at service.annotations
- Environment variables are made user-configurable for fluentd container, and also allow referencing values.yaml parameters.

### Changed
- Fluentd config files updated with log settings under <system> section (to set the log format to json). This is mandatorily required when unifiedLogging is enabled.
- Default values of logging parameters (logfile: '/tmp/mainContainerLogs/im.log' and logformat: json) updated under indexmgr.configMaps.config_yml as these are mandatorily required when unifiedLogging is enabled
- Updated harmonizedLogging configuration to add the fields host, system and systemid in the dashboards pod logs
- RBAC permissions in chart-created role minimized as required for the workload kind used for fluentd
- dashboards.env section is rendered as a template, allows referencing other values.yaml parameters.

### Removed

### Fixed
- CSFS-50634: Added quotes to all keys and values configured under custom labels and annotations
- CSFS-50418: Handling of allowPrivilegeEscalation in containerSecurityContext parameters in fluentd.
- CSFS-51472: Disabled fips in init container during the generation of secret keys used for encryption of sensitive information.
- CSFS-48370: Fix to avoid conflicting encryption of certificates in case of very short-duration backup operations in indexsearch.
- Added common label and annotations for PDB created in dashboards and for jobs created by indexmgr cronjob.

### Security
- Updated kubectl image to v1.25.6-nano-20230130 (centos7), v1.24.10-rocky-nano-20230306 (rocky8)
- Updated cbura image to 1.0.3-4989
- Updated base images to java_base/11/nano:11.0.18.0.10.centos7.9-20230130 (centos7), java_base/11/nano:11.0.18.0.10.rocky8.7-20230306 (rocky8 java 11), java_base/17/nano:17.0.6.0.10.rocky8.7-20230306 (rocky8 java 17)


## [11.1.0] - 2022-12-16
### Added
- HBP: Added support for PodSecurityAdmission in Kubernetes 1.25 while continuing to support in lower versions with PSP/SCC.
- HBP: Annotations for PSP/SCC are made user configurable under rbac section for each chart
- HBP: Added containerSecurityContext parameter to inject securityContext for containers

### Changed
- HBP: securityContext parameter can be used to inject securityContext for pods
- HBP: PSP/SCC creation controlled on the basis of kubernetes versions.
- REST layer SSL communication for indexsearch is also routed via istio-proxy (i.e. istio mtls over application tls) as HTTP port 9200 is no longer excluded from istio routing.
- seccompProfile is set to RuntimeDefault for all containers and the annotation 'seccomp.security.alpha.kubernetes.io/allowedProfileNames' is by default added to PSPs (if created). These are default values and configurable through values.yaml

### Removed
- CriticalPod Scheduler annotation (scheduler.alpha.kubernetes.io/critical-pod) has been removed from fluentd pods as it is non-functional starting k8s v1.16

### Fixed
- CSFS-49939: Fixed the upgrade issue when dashboards and indexearch are installed as separate releases
- CSFS-49979: Fixed readiness/liveness probe issue when dashboards container alone restarts due to some config issue
- Support for istio outboundTrafficPolicy in REGISTRY_ONLY mode
- Fixed wrong rendering of annotations for chart-created istio gateway for dashboards
- CSFS-49778: Updated NOTES.txt with correct protocol used for accessing indexsearch svc in istio-enabled case
- CSFS-49900: Updated NOTES.txt to remove extra space between labels used to list the dashboard pods
- CSFS-49434: Updated comment in values.yaml for ssl_no_validate and certificate parameters under config_yml for indexmgr

### Security
- Updated kubectl image to v1.25.4-nano-20221125 (centos7), v1.25.4-rocky-nano-20221125 (rocky8)
- Updated cbura image to 1.0.3-4789
- Updated base images to java_base/11/nano:11.0.17.0.8.centos7.9-20221031 (centos7), java_base/11/nano:11.0.17.0.8.rocky8.7-20221125 (rocky8 java 11) , java_base/17/nano:17.0.5.0.8.rocky8.7-20221125 (rocky8 java 17)


## [11.0.0] - 2022-09-30
### Added
- Upgraded to OpenSearch and OpenSearch Dashboards v2.2.1
- Compliance with HBP v3.0.0
- Support added for java 17 for Rocky8
- Support for upgrade with Dual Stack
- HBP: global.annotations and global.labels are added for all k8s resources.

### Changed
- Asset name changed from BELK to BSSC to avoid elastic trademarks/wordmarks
- Chart names changed belk-efkc -> bssc-ifd, belk-elasticsearch -> bssc-indexsearch,
belk-fluentd -> bssc-fluentd, belk-kibana -> bssc-dashboards, belk-curator -> bssc-indexmgr
- Rocky8 java 11 based image made default option. Provision to configure either of rocky8-java11, rocky8-java17 or centos7-java11 is provided.
- HBP: Common labels values changed as per HBP 3.0.0. They will be added by default for all resources.
- HBP: podNamePrefix removed from the names of non-pod resources 
- HBP: K8s Jobs and helm test pod names updated to include fullnameoverride and nameoverride 
- Updation of Cronjob in bssc-indexmgr to use apiVersion batch/v1 instead of deprecated batch/v1beta1

### Removed
- common_labels option to enable/disable common labels is removed from values.yaml

### Fixed
- CSFS-46793: Istio CNI and Istio Version precedence issue fixed
- CSFS-46995: apiversion check for BrPolicy fixed
- SERVER_HOST env can be now configured through values.yaml at bssc-dashboards.dashboards.env

### Security
- Updated kubectl image to v1.24.3-nano-20220729 version
- Updated base images to java_base/11/nano:11.0.16.0.8.centos7.9-20220729 (centos7), java_base/11/nano:11.0.16.0.8.rocky8.6-20220826 (rocky8 java 11) , java_base/17/nano:17.0.4.0.8.rocky8.6-20220826 (rocky8 java 17)


## [10.0.0] - 2022-06-30
### Added
- Migrated from Elasticsearch, Kibana to OpenSearch, OpenSearch-Dashboards 1.3.2
- Upgraded fluentd to version 1.14.6 (td-agent to version 4.3.1)
- Upgraded curator to version 5.8.4
- Support for rocky8 based image
- NCS22 support: New fluentd configuration added (belk-fluentd/fluentd-config/belk-cri.conf) that supports reading containerd logs
- HBP: rbac.psp.create and rbac.scc.create added to control creation of PodSecurityPolicy and SecurityContextConstraints
- HBP: PodDisruptionBudget(PDB) feature is added
- HBP: Customized labels are added
- HBP: Pod PriorityClassName made user configurable
- HBP: appProtocol field added to services.
- Ephemeral storage/emptyDir request and limit values for containers are made user configurable
- Support for Dual-stack
- Update-Strategy of fluentd deployment made user configurable


### Changed
- HBP: sensitiveInfoInSecret.secretName is changed to sensitiveInfoInSecret.credentialName in all charts as per the naming convention
- HBP: elasticsearch_master.podLabels, elasticsearch_client.podLabels and esdata.podLabels replaced by custom.esMaster.pod.labels, custom.esData.pod.labels,custom.esClient.pod.labels respectively
- HBP: kibana.podLabels replaced by kibana.custom.pod.labels
- HBP: curator.podLabels replaced by curator.custom.pod.labels
- HBP: fluentd.podLabels replaced by fluentd.custom.pod.labels
- Default value of belk-fluentd.fluentd.useClusterAdminRole is set to false - when rbac.enabled is set, the chart creates a cluster-role and PSP/SCC with minimum required permissions instead of using the existing 'cluster-admin' clusterrole.
- HBP: Timezone can be configured using global.timeZoneEnv or timezone.timezoneEnv at chart scope
- HBP: Changed the structure of values under istio.gateways array for kibana
- HBP: Container name prefix will be added to all containers irrespective of fullnameOverride or nameOverride
- HBP: automountServiceAccountToken set to false in all serviceAccount objects and set to true/false in all the pods based on need.
- Chart made compatible with latest BrPolicy apiversion
- HBP: Custom annotation values are quoted

### Removed
- HBP: timezone.mountHostLocaltime.mountHostLocaltimePath is now removed
- HBP: Removed hook-failed annotation value from hook deletion policy

### Fixed
- Fluentd config reload issue with RPC endpoint with sensitiveInfo enabled
- CSFS-44765: Added zone for anti-affinity feature in master, data and client templates in Elasticsearch
- Service, Service Account names are limited to 63 characters
- Resource limits and requests of all containers are made user configurable

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
- updateStrategy for fluentd daemonset made user-configurable

### Removed

### Fixed
- CSFS-42360: Kibana Log Export errors
- CSFS-43142: Kibana Log-exporter: Limitation of downloading upto 10k records resolved
- CSFS-40629: Kibana harmonized logs should be pushed to *log indices and updated the logging parameters format.
- CSFS-41391: Kibana Ingress name made user configurable
- CSFS-43528: Curator intermittent issue of encryption

### Security
- Updated log4j to 2.17.1 in elasticsearch
- Updated java base image to 11.0.14.1.1.centos7.9-20220301
- Updated kubectl image to v1.23.1-nano-20220301
- Updated cbura image tag to 1.0.3-3733


## [9.2.0] - 2021-12-21
### Added
- Kibana log exporter plugin
- HBP: CommonLabels to all kubernetes resources
- Provision to add environmental variables to elasticsearch pods

### Changed
- HBP: istio.version value type changed from float to string
- HBP: StorageClassName options for PVC
- Increased initialDelaySeconds and failureThreshold for liveness and readiness probes for kibana
- cbura image tag to 1.0.3-3233

### Removed

### Fixed
- CSFS-39701: Fix for kibanaserver user getting overwritten with default password during SG to OD migration
- CSFS-39400: Elasticsearch log format updated with hostname & systemid fields as per harmonized logging
- CSFS-36073: Kibana Ingress resource API version is changed from v1beta1 to v1
- CSFS-41541: Backup fails after restoring to an older snapshot

### Security 
- Fixed CVE-2021-44228, CVE-2021-45105, CVE-2021-45046 in Elasticsearch by updating log4j to 2.17.0
- Fixed vulnerabilities in Elasticsearch, fluentd and kibana
- Updated java base image to 11.0.13.0.8.centos7.9-20211208
- Updated kubectl image to v1.22.1-nano-20211208

## [9.1.1] - 2021-11-25
### Added
- CSFS-39180: Added fluent-plugin-cloudwatch-logs plugin

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
- Upgraded elasticsearch and kibana version to 7.10.2
- Upgraded fluentd to version 1.13.3 (td-agent to version 4.2.0)
- automountserviceaccounttoken parameter set to false in service account of job/pod which do not use kubectl/k8s api
- HBP: custom annotations for helm hook jobs and test pods made user configurable
- HBP:imagePullSecrets (for pulling images from docker registries) made user-configurable.
- HBP createDrForClient flag added to allow client application (running on istio) to access BELK running without istio
- HBP: Limit Scope of Istio Routing Rules with exportTo in kibana

### Changed
- HBP: Istio gateway configurations moved from istio.gateway to istio.sharedHttpGateway and istio.gateways sections as per HBP in kibana.
- HBP: Replaced deprecated ingress annotation ingress.citm.nokia.com/sticky-route-services with nginx.ingress.kubernetes.io/affinity in kibana
- RBAC changes: Separate Service accounts created for jobs/pods with minimum required permissions
- RBAC changes: volume types in PSP to only needed types replacing '*'.
- Made "allowedHostPaths" in PSP configurable in fluentd

### Removed

### Fixed
- CSFS-37843 : sec-admin-es and upgrade jobs failed intermittently when few ES nodes join cluster while securityadmin is running in ES
- HBP: Removed chart.version from common labels for PVCs in ES and fluentd
- Install/Upgrade job OOMKilled issue in ES
- CSFS-34146: Created SA for fluentd when rbac.enabled: true,enable_root_privilege: false instead of using 'default' SA

### Security
- CSFOAM-9072: Fixed security vulnerabilities reported by DISH
- Upgraded kubectl image to v1.21.1-nano-20210702 to fix vulnerability

## [8.1.0] - 2021-06-11
### Added
- CSFID-3371: Support to run containers with configurable userid
- Added securityContext.enabled under all components to control configuration of securityContext parameters for pods/containers
- HBP: common_labels flag to inject common labels to all resources
- Affinity, tolerations and nodeSelector feature added for curator
- Affinity, tolerations and nodeSelector feature added for helm hook jobs and helm test pods in all components
- chunk_limit_size parameter added in buffer sections of fluentd clog config

### Changed
- Replaced antiAffinity parameter in elasticsearch with podAntiAffinity having options to configure soft/hard or custom definition
- Parameters rbac.enabled and serviceaccount are moved from global level to chart level as per HBP.
- Replaced belk-elasticsearch.es_securityContext with belk-elasticsearch.securityContext
- Toleration for fluentd daemonset made user configurable with default tolerate value of NoExecute. This default toleration is applicable for all kinds of fluentd. STS/deployment kind fluentd users can remove it, if not required.
- Replaced belk-elasticsearch.customResourceNames.installJob with belk-elasticsearch.customResourceNames.secAdminEsJob
- Helm test pods cleaned up on deletion of release.
- HBP: NOTES.txt enhanced to provide more information to customers

### Removed
- belk-elasticsearch.customResourceNames.postDeletePrehealJob section is removed from values.yaml as its functionality is moved to postDeleteCleanupJob

### Fixed
- CSFS-36751: With sensitiveInfoInSecret enabled, curator fails when configured with multiple actions that are long running.
- Updated clog-journal.conf and clog-json.conf for kubelet/plugins parsing error.
- CSFS-37539: With sensitive info enabled, fluentd reads default configuration instead of confimap on container-only restart
- Elasticsearch install job remained in error state after rollback to revision 1

## [8.0.0] - 2021-04-14
### Updated
- Replaced searchguard by opendistro security
- Added support for kibana multitenancy
- Added new user kibanaserver in elasticsearch internal_users.yml & replaced admin user by kibanaserver user in kibana configuration for backend interaction of kibana with elasticsearch.
- Added new role kibana_multitenancy_user (mapped to all users) for kibana multitenancy.
- Added restoreSystemIndices flag to control restore of system indices during helm restore.
- Added an option where ES chart can accept full internalusers.yml file or admin username, password from pre-created secret when sensitive info is enabled
- Upgraded td-agent version to 4.1.0
- Update fluentd clog-journal.conf and clog-json.conf for timestamp parsing.
- Added HBP k8s common labels
- Added HBP provision to configure timezone.
- Added HBP provision to configure custom annotations for pods.
- Updated default repo from centos8 to centos7
- Updated kibana ingress.tls section to be evaluated as template
- Added changes to make fluentd forward_service.protocol user configurable.
- Kibana logs are compliant with harmonized-logging format
- handlebar package version upgraded to 5.7.7 in log exporter.
- Updated default value of istio.version to 1.7
- Fixed nodeAffinity issue in elasticsearch chart

## [7.0.1] - 2021-02-08
### Updated
- defined brOption as an integer in elasticsearch BrPolicy
- exposed storageClassName in umbrella chart values for backup-restore

## [7.0.0] - 2020-12-18
### Updated
- Added changes to handle Sensitive information for curator
- Added changes to handle Sensitive information for fluentd
- Added reloader annotation to restart pod when sensitive info is updated and fixed indentation, code issues in fluentd chart
- Updated resource limits/requests for jobs in elasticsearch & fluentd
- Passed data and secretData fields as tables in fluentd
- CSFS-29143: Minimized RBAC privileges for charts.
- Added changes to handle Sensitive information for Kibana
- Updated job name and hook-delete policies in elasticsearch and fluentd
- CSFS-29928: Added configurable delay to wait for istio envoy proxy
- Added helm test
- Updated default values of istio parameters for istio 1.6
- Added provision to add/override elasticsearch.yml configurations.
- Updated docker image tag for fluentd
- Updated mount path for precreated secret when sensitiveInfoInSecret is enabled in fluentd
- Added changes to handle Sensitive information for elasticsearch
- Added support for fluentd cento8 based image and upgraded centos7 base images to latest java base image.
- Support to add DNS entries in hostAliases of es-client & kibana pods.
- Added section istio.envoy with envoy related parameters and renamed istio.envoy_health_chk_port to istio.envoy.healthCheckPort
- Updated default repo from centos7 to centos 8
- Fixed es-client pod warning message during upgrade
- Removed "systemid" key from harmonized logs which will be populated by clog plugin in fluentd
- Docker image from delivered

## [6.3.3] - 2020-10-30
### Updated
- Added support for istio cni disabled
- Istio sidecar inject annotation added as per istio.enabled flag
- Removed misplaced config from fluentd clog config files
- Check for istio envoy sidecar readiness before starting curator process
- Upgraded kubectl image to v1.17.8-nano-20201006-9214
- CSFS-29825: Added env variable NSS_SDB_USE_CACHE
- CSFS-29870: Removed extra space from _helpers.tpl to solve lint issue in helm version  2.14.1
- Moved sub-charts to delivered

## [6.3.2] - 2020-10-08
### Updated
- CSFOAM-6395: Updated templatename with chart.templatename

## [6.3.1] - 2020-09-30
### Updated
- Fixed trademark bugs for CSFLDA-2765, CSFLDA-2764
- Updated readme file for efkc chart
- CSFS-28353: Added TIMESTAMP_FIELD field as environmental value
- Added support for istio 1.4
- Addition of prefix to pod names, job and container names
- Added nameoverride and fullname override configuration changes
- Updated job and jobcontainer template names
- CSFS-28597: Added new headless svcs in elasticsearch & fluentd for cpro server to scrape metrics
- made repo user configurable to choose between centos7 and centos8 images
- Added dest rule for fluentd service for istio 1.4
- Sub-charts and docker images are moved to delivered

## [6.3.0] - 2020-08-31
### Updated
- CSFS-22644:Added support to accept precreated curator configmap.
- CSFS-24844: Updated kibana sg-configmap parameters to be evaluated as template
- CSFS-26654: Added server.rewritebasepath as kibana env property to remove the warning
- CSFS-23274: Added csp.strict in kibana_configmap_yml
- Added support for mounting additional certificates to kibana pod
- Helm hook-delete-policy of pre/post-upgrade jobs made user configurable
- CSFS-24844: Updated ES sg-configmap parameters to be evaluated as template
- Upgrade ES, Kibana to 7.8.0
- CSFS-26865: Updated the elasticsearch-graphana.json
- Updated cbura imageTag
- Added support for log exporter plugin
- fluentd docker image update for version upgrade 1.11.1, kubernetes_metadata_fliter updated to 2.5.2 and clog plugin fluent-plugin-prometheus updated to 1.8.01
- certificates for transport layer generated as part of docker entrypoint when istio is enabled 
- CSFS-27150: Added support for CKEY external to istio mesh
- Excluded .signals* indices from ES Backup restore
- Replaced CMS garbage collector with G1GC in elasticsearch
- Trademark changes for 7.8.0 kibana
- Incremental Trademark changes for 7.8.0 Kibana
- Kibana chart with latest csan, exporter plugin
- Added env variables for exporter plugin
- Moved docker images to delivered

## [6.2.0] - 2020-07-14
### Updated
- Added Pod affinity for ES chart
- Added fsGroup, supplementary groups, SELinux label
- Added liveness and readiness probes check
- Support for pre-created Service Account, role and rolebinding
- Added run as non-root condition check in fluentd daemonset
- Added customized security annotation which are user configurable
- Added provision for customized labels to pods
- Added support for istio
- Added istio-ingress gateway support
- Helmbestpractice changes for service account and rbac flag
- Added fluent-plugin-cvea-log by CLOG
- Fixed SG 6-7 upgrade issue when istio is enabled
- Added cleanup-job to delete remaining resources on purge
- Updated es-prometheus pod level annotations to work with istio enabled chart
- Integration with keycloak in mTLS
- Fixed elasticsearch helm3 issue with headless svc
- Moved docker images to delivered

## [6.1.1] - 2020-04-24
### Updated
- Helm3 changes
- Istio-Style Formatting for ports
- Creation of separate service for fluentd forward plugin

## [6.1.0] - 2020-03-19
### Updated
- Added service account to curator
- Upgraded curator to 5.8.1
- Updated job spec and job template parameters to be user configurable
- Modified service account for elasticsearch
- Modification of role in Post-delete job
- Handled sg migration failures on data node not detected(Delivered as BELK-19.12 patch with chart version 6.0.1810)
- Fix for files have insecure file permission in elasticsearch image
- Improved backup and restore scripts in elasticsearch docker
- Added permission in post-upgrade job to view logs of pod
- Added support for ES cipher suites
- Modified post-delete job with proper roles in fluentd 
- Added file buffer in belk.conf
- Added parameters reconnect_on_error,reload_on_failure,reload_connections in all .conf files
- Added service account for kibana
- Added kibana optimization for SG and CSAN in k_sg image
- Docker image file permissions are changed and restricted
- Updating values-model and values-template files for compaas
- Added autoUpdateCron in BrPolicy of all charts for automatically deleting/creating/updating cronjob based on other parameters
- Upgraded td-agent to 3.6.0, added request_timeout parameter in fluentd config files
- Increased fluentd default limits,requests values for memory and cpu
- CSFS-18987: Kibana UI changes done to correct trademark policy violations
- Modified default ingress path to /logviewer
- Moved docker images to delivered

## [6.0.18] - 2019-12-19
### Updated
- Added latest csan plugin in kibana chart
- Added es-prometheus annotations at pod level(es-master,es-data,es-client)
- Modified readiness probe for es-client to check searchguard health
- Configuration changes for IPv6 compatibility
- Fix for elasticsearch-client pod logs breaking terminal
- Added fluentd plugins: route, concat, grok-parser and clog provided plugins
- Updated docker images with latest centos base images
- Removed belk-elasticsearch-exporter chart from efkc
- Moved all sub-charts to stable

## [6.0.17] - 2019-10-30
### Updated
- Updated individual chart names in values-template file
- Added es-prometheus service to scrape elasticsearch metrics
- Added postscalein job in es and fluentd for deleting unused PVCs
- Updated es-prometheus service to add flag for SG enabled
- Improved SG migration code for ELK6 to ELK7 upgrade and removed sg_migrate flag.
- CSFLDA-2118: Added/updated BrPolicy in es, kibana and fluentd for configmap restore
- Creating optimize directory in kibana image
- Added autoEnableCron in Brpolicy of all charts
- Updated base images to centos-7.7, updated cbura image to 1.0.3-983
- Updated elasticsearch to latest java base image
- Moving all the individual charts to stable

## [6.0.16] - 2019-10-04
### Updated
- Moved belk-efkc individual charts to stable

## [6.0.15] - 2019-09-11
### Updated
- Modified readiness probe of es-master(CSFLDA-2113)
- Fixed indentation for nodeSelector in es-client & es-master
- Fluentd clog configuration updated to support for BCMT IPv6
- Added nodeSelector, toleration for fluentd daemonset
- Fluentd clog configuration updated for parsing non-container alarms for BCMT 19.09
- Added ignoreFileChanged in elasticsearch Brpolicy
- Upgraded kubectl image to v1.14.7-nano

## [6.0.14] - 2019-08-30
### Updated
- Moved belk-efkc individual charts to stable

## [6.0.13] - 2019-08-26
### Updated
- CSFS-15916: Some resource of belk-efkc can not be deleted after helm delete successfully 

## [6.0.12] - 2019-08-23
### Updated
- CSFS-15048: Updated cbura sidecar image to 1.0.3-871

## [6.0.11] - 2019-08-22
### Updated
- CSFLDA-1975: Moved all efkc chart images to buildah

## [6.0.10] - 2019-08-19
### Added
- CSFS-14508: Added secret, env and values for csan

## [6.0.9] - 2019-08-19
### Added
- Fixed kibana index re-index issue in postRestore
- Updated fluentd Clog configuration for C API
- Added /tmp for cbur sidecar for backup
- Moved all charts to stable

## [6.0.8] - 2019-08-12
### Added
- Fixed kibana index re-index issue in postRestore
- Updated fluentd Clog configuration for C API

## [6.0.7] - 2019-08-06
### Added
- Increased /tmp directory for cbur-sidecar

## [6.0.6] - 2019-08-05
### Added
- Fixed kibana restore issue.
- Added /tmp for cbur sidecar for backup

## [6.0.5] - 2019-07-26
### Added
- CSFS-14403: Added user configurable capture group for kibanabaseurl.
### Updated
- CSFS-14419: Made network_host user configurable.

## [6.0.4] - 2019-07-08
### Added
- Upgrade ELK to 7.0.1
- Upgraded td-agent to 3.4.1
- Moved all charts to stable

## [6.0.3] - 2019-07-06
### Added
- Added fix for upgrade(ES-6 to ES-7) issue by adding SG migrate script.
- Added pvc for master pods to persist cluster state
- Added security context to fluentd

## [6.0.2] - 2019-07-01
### Added
- Updated BrOption to 0
- Updated fluentd and elasticsearch chart

## [6.0.1] - 2019-06-28
### Added
- Upgraded ELK to 7.0.1 

## [6.0.0] - 2019-06-28
### Added
- Upgraded ELK to 7.0.1
- Upgraded td-agent to 3.4.1

## [5.3.15] - 2019-06-27
### Added
- Moved kibana chart to stable


## [5.3.14] - 2019-06-27
### Added
- Moved kibana chart to stable
- Added server.ssl.supportedProtocols: ["TLSv1.2"] to kibana configmap

## [5.3.13] - 2019-06-26
### Added
- Added kibana-csan plugin to kibana docker image

## [5.3.12] - 2019-06-09
### Added
- CSFS-13747: Added fluentd prometheus metrics port
- Added enable_root_privilege flag to fluentd deployment

## [5.3.11] - 2019-05-31
### Add
- Updated brOption and added cbur resource limits
- Added security annotations to all charts
- Moved all charts to stable

## [5.3.10] - 2019-05-28
### Added
- Updated brOption and added cbur resource limits

## [5.3.9] - 2019-05-21
### Added
- Added security annotations to all charts

## [5.3.8] - 2019-05-21
### Added
- Added security annotations to charts

## [5.3.7] - 2019-05-15
### Added
- CSFID-2215:Add ElasticSearch dashboard for grafana

## [5.3.6] - 2019-05-14
### Added
- CSFS-11977:Fluentd app mounting /var/log and /data0/docker by default

## [5.3.5] - 2019-05-10
### Added
- CSFS-11977:Fluentd app mounting /var/log and /data0/docker by default
- CSFS-12268:Add fullnameOverride tag to BELK helm charts 

## [5.3.4] - 2019-05-03
### Added
- Updated audit logging configuration for clog.conf files

## [5.3.3] - 2019-04-30
### Added
- Upgraded ELK to 6.6.1
- Removed sentinl plugin
- Added fluentd chart to umbrella chart with updated clog fluentd configurations i.e clog-json.conf and clog-journal.conf
- Moved charts to stable

## [5.3.2] - 2019-04-26
### Added
- Upgraded base image


## [5.3.1] - 2019-04-25
### Added
- Added ssl parameter to fluentd chart

## [5.3.0] - 2019-04-25
### Added
- Upgraded ELK to 6.6.1
- Removed sentinl plugin
- Added fluentd chart to umbrella chart with updated clog fluentd configurations i.e clog-json.conf and clog-journal.conf

## [5.2.9] - 2019-04-24
### Added
- Added fluentd chart to umbrella chart with updated clog fluentd configurations i.e clog-json.conf and clog-journal.conf

## [5.2.8] - 2019-04-22
### Added
- Added fluentd chart to umbrella chart with different fluentd configurations i.e belk.conf,clog-json.conf and clog-journal.conf

## [5.2.7] - 2019-04-02
### Added
- Added CLOG configuration to umbrella chart

## [5.2.6] - 2019-04-01
### Added
- Added CLOG configuration to umbrella chart


## [5.2.5] - 2019-03-27
### Added
- Upgraded docker base image to Centos 7.6
- Installed gems in fluentd  image to support CLOG
- Moved all images to delivered

## [5.2.4] - 2019-03-22
### Added
- Upgraded docker base image to Centos 7.6
- Installed gems in fluentd  image to support CLOG 

## [5.2.3] - 2019-03-18
### Added
- Installed sentil plugin for kibana 

## [5.2.2] - 2019-03-12
### Added
- CSFLDA-1590: Updated sg_roles and sg_roles_mapping with latest searchguard configurations

## [5.2.1] - 2019-03-11
### Changed
- CSFID-1611: Keycloak integration -added searchguard.openid.root_ca parameter to kibana configmap

## [5.2.0] - 2019-03-05
### Added
- CSFID-1611: Keycloak integration
- Liveness and Readiness probe modified for kibana

## [5.1.5] - 2019-02-28
### Added
- CSFLDA-1521:TLS for belk-fluentd helm chart
- CSFLDA-1540:Implement ElasticSearch POD anti-affinity rules
- CSFLDA-1541:Implement Logstash POD anti-affinity rules
- CSFLDA-1542:Implement  Kibana POD anti-affinity rules
- CSFLDA-1543:Implement Fluentd POD anti-affinity rules
- Upgraded td-agent rpm to 3.3.0
- CSFID-1932:Installed fluentd postgres, genhashvalue, splunk plugins
- CSFID-1976:Fluentd supporting as statefulsets
- CSFS-10055:Kibana readiness probe is added
- moved all charts to stable

## [5.1.4] - 2019-02-27
### Added
- CSFLDA-1521:TLS for belk-fluentd helm chart

## [5.1.3] - 2019-02-19
### Added
- CSFLDA-1521:TLS for belk-fluentd helm chart
- upgraded kubectl image in curator chart

## [5.1.2] - 2019-02-19
### Added
- CSFS-10055:Kibana readiness probe is added

## [5.1.1] - 2019-02-18
### Added
- CSFLDA-1540:Implement ElasticSearch POD anti-affinity rules
- CSFLDA-1541:Implement Logstash POD anti-affinity rules
- CSFLDA-1542:Implement  Kibana POD anti-affinity rules
- CSFLDA-1543:Implement Fluentd POD anti-affinity rules
- Upgraded td-agent rpm to 3.3.0
- CSFID-1932:Installed fluentd postgres, genhashvalue, splunk plugins
- CSFID-1976:Fluentd supporting as statefulsets

## [5.1.0] - 2019-02-15
### Added
- CSFLDA-1540:Implement ElasticSearch POD anti-affinity rules
- CSFLDA-1541:Implement Logstash POD anti-affinity rules
- CSFLDA-1542:Implement  Kibana POD anti-affinity rules
- CSFLDA-1543:Implement Fluentd POD anti-affinity rules
- Upgraded td-agent rpm to 3.3.0
- CSFID-1932:Installed fluentd postgres, genhashvalue, splunk plugins
- CSFID-1976:Fluentd supporting as statefulsets

## [5.0.3] - 2019-02-01
### Added
- Upgraded chart to 6.5.4-oss
- Reduced memory limit to kibana
- removed xpack env variable from docker image
- moved docker images to stable

## [5.0.2] - 2019-01-31
### Added
- Upgraded chart to 6.5.4-oss
- Reduced memory limit to kibana
- removed xpack env variable from docker image

## [5.0.1] - 2019-01-29
### Added
- Upgraded chart to 6.5.4-oss
- Reduced memory limit to kibana

## [5.0.0] - 2019-01-28
### Added
- Upgraded chart to 6.5.4-oss

## [4.4.8] - 2019-01-24
### Changed
- CSFLDA-1436:fixed snapshot name for postRestoreCommand and added removeGlusterfs.sh in the BrPolicy.yaml

## [4.4.7] - 2019-01-24
### Changed
- CSFLDA-1436:Removed snapshot name from values.yaml.

## [4.4.6] - 2019-01-15
### Changed
- CSFS-9322:Harmonized logging changed timezone
- CSFS-9181:elasticsearch metrics are missing from prometheus
- CSFS-9183:fluentd metrics are not visible in prometheus
- CSFS-9192:JSON formatted log messages not properly parsed by fluentd 1.2.2
- CSFS-9384:efkc-belk-elasticsearch-client pods do not recover after error (OoM)
- CSFS-9385:ES-client threw OoM

## [4.4.5] - 2019-01-15
### Changed
- CSFS-9322:Harmonized logging changed timezone

## [4.4.4] - 2019-01-10
### Changed
- CSFS-9181:elasticsearch metrics are missing from prometheus
- CSFS-9183:fluentd metrics are not visible in prometheus
- CSFS-9192:JSON formatted log messages not properly parsed by fluentd 1.2.2
- CSFS-9384:efkc-belk-elasticsearch-client pods do not recover after error (OoM)
- CSFS-9385:ES-client threw OoM

## [4.4.3] - 2019-01-04
### Changed
- Upgarded charts to 6.5.1
- Backup and restore issues are fixed i.e CSFLDA-1414, CSFLDA-1420 and CSFLDA-1421
- Kibana issue fixed i.e CSFLDA-1407


## [4.4.2] - 2019-01-02
### Changed
- backup and restore issue fixed

## [4.4.1] - 2018-12-21
### Changed
- In backup if condition is added

## [4.4.0] - 2018-12-21
### Changed
- Upgarded charts to 6.5.1
- Backup and restore is added


## [4.3.6] - 2018-11-30
### Changed
- CSFS-7762:SG improvement.
- Fluentd chart with prometheus ssl
- Harmonized logging
- Local Storage added
- Fluent image with prometheus plugin
- Fix for data pod restart

## [4.3.5] - 2018-11-29
### Changed
- CSFS-7762:SG improvement.

## [4.3.4] - 2018-11-27
### Changed
- Fluentd chart with prometheus ssl

## [4.3.3] - 2018-11-26
### Changed
- ES chart with SG image changed

## [4.3.2] - 2018-11-22
### Added
- Local Storage added for efkc

## [4.3.1] - 2018-11-22
### Changed
- Fluentd prometheus plugin added
- Fix for restart of ES pod while upgrading

## [4.3.0] - 2018-11-22
### Changed
- Harmonized logging for ES
- Docker base image changes to latest with security fixes

## [4.2.6] - 2018-11-15
### Changed
- CSFS-7753: Moving kibana chart to stable

## [4.2.5] - 2018-11-13
### Changed
- CSFS-8273: Unable to install EFKC in ComPaaS and removed fluentd from umbrella chart in Compaas environment

## [4.2.4] - 2018-11-08
### Changed
- CSFS-7753: Adding host field for Kibana Ingress in efkc

## [4.2.3] - 2018-11-05
### Changed
- CSFS-7753:TLS support for ingress for efkc

## [4.2.2] - 2018-10-31
### Changed
- Moving all charts to stable

## [4.2.1] - 2018-10-30
### Changed
- Added all BELK upgraded charts(version 6.4.1) in the Umbrella and curator certificate change

## [4.2.0] - 2018-10-30
### Changed
- Added all BELK upgraded charts(version 6.4.1) in the Umbrella

## [4.1.11] - 2018-10-29
### Changed
- Changed the elasticsearch and kibana charts repo to stable
- CSFS-7748: BELK add proxy authentication support
- CSFS-7852: elasticsearch test* configmaps are still having http in use when searchguard is enabled
- CSFS-7699: Kibana ingress cannot be disabled by value
- CSFS-7753: Ingress TLS support


## [4.1.10] - 2018-10-26
### Changed
- CSFS-7750:Ingress not configurable in kibana


## [4.1.9] - 2018-10-25
### Changed
- CSFS-7748: BELK add proxy authentication support
- CSFS-7852: elasticsearch test* configmaps are still having http in use when searchguard is enabled
- CSFS-7699: Kibana ingress cannot be disabled by value
- CSFS-7753: Ingress TLS support
## [4.1.8] - 2018-10-24
### Changed
- CSFS-7748: BELK add proxy authentication support
- CSFS-7852: elasticsearch test* configmaps are still having http in use when searchguard is enabled
- CSFS-7699: Kibana ingress cannot be disabled by value

## [4.1.7] - 2018-09-27
### Added
- Heal LCM event for efkc is added.

## [4.1.6] - 2018-09-26
### Changed
- Refactored resource parameters of efkc

## [4.1.5] - 2018-09-20
### Changed
- Modified secret creation 

## [4.1.4] - 2018-09-10
### Changed
- Added update config for ES to take searchguard configmap from values file

## [4.1.3] - 2018-09-05
### Added
- Added update config and upgrade , rollback 

## [4.1.2] - 2018-09-04
### Changed
- CSFLDA-897:Fix for bug when deploying chart with wrong base64 password

## [4.1.1] - 2018-09-03
### Changed
- Modified elasticsearch to take upgrade strategy from values file

## [4.1.0] - 2018-08-30
### Added
- Added install and delete LCM events for efkc

## [4.0.4] - 2018-08-30
### Changed
- Updated image registry name from registry to global registry


## [4.0.3] - 2018-08-28
### Added
- CSFLDA-816 : Elasticsearch service endpoints issue
- Updated fluentd version to 1.2.2
### Changed
- Update fluentd to run as root user only to fix container logs permission issue

## [4.0.2] - 2018-08-24
### Added
- CSFS-4771:- Cannot deploy more than one ElasticSearch in a namespace

## [4.0.0] - 2018-08-13
### Added
- All future chart versions shall provide a change log summary
- PSP/RBAC support
### Changed
- Updated curator schedule in values.yaml
- Chart to follow semantic naming. belk-`component`-`opensource version`-`csf release year`.`csf release month`.`patch` 
  e.g.: belk-efkc-6.2.4-18.07.03
- docker image on Centos 7.5

## [0.0.0] - YYYY-MM-DD
### Added | Changed | Deprecated | Removed | Fixed | Security
- your change summary, this is not a **git log**!


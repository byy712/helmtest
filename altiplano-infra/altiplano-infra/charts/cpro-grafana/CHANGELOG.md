# Changelog
All notable changes to chart **cpro-grafana** are documented in this file,
which is effectively a **Release Note** and readable by customers.

Do take a minute to read how to format this file properly.
It is based on [Keep a Changelog](http://keepachangelog.com)
- Newer entries _above_ older entries.
- At minimum, every released (stable) version must have an entry.
- Pre-release or incubating versions may reuse `Unreleased` section.

## [Unreleased]
## [7.0.4]
### Fixed
- CSFOAM-19254: updated grafana docker images

## [7.0.3]
### Fixed
- CSFOAM-19000: Fix of CSFS-57652 and added logs for grafana mysql connection

## [7.0.2]
- CSFOAM-18944: updated grafana docker images

## [7.0.1]
- CSFOAM-18414: fix for CSFS-56649 Grafana installation fails due to rbac permission
- CSFOAM-18432: Updated components docker images and BSSC fluentd image docker tags

## [7.0.0]
### Added
- CSFOAM-17656: CentOS7 Deprecation - Charts Git
- CSFOAM-17677: Added TLS & Certificate configurations as per HBP 3.7.0 [HBP_Security_net_1, HBP_Security_cert_2,HBP_Security_Cert_5,HBP_Security_Cert_8] - Addressed review comments.
- CSFOAM-17680: Added global certManager to true as per HBP 3.7.0 [HBP_Security_cert_4]
- CSFOAM-17679: Added self-signed issuer creation code as per HBP 3.7.0 [HBP_Security_cert_6] - Addressed review comments.
- CSFOAM-17673: Chart changes as per HBP_3.7.0_Kubernetes_Pod_6 and pod_7 along with UT
- CSFOAM-17712: Sensitive data feature for grafana
- CSFOAM-17674: Added Image Flavor at global and container levels HBP_Kubernetes_Pod_8 
- CSFOAM-17676: Added Image Flavor Policy fields HBP_Kubernetes_Pod_2 
- CSFOAM-17700: Added small change based on common template for security encryption
- CSFOAM-17943: Added curlOptions configurability for grafana sidecar plugin 
- CSFOAM-18092: Added UT as per  HBP 3.7.0 security encryption
- CSFOAM-18163: UK TSR alert support
- CSFOAM-18160: updated grafana docker images
### Changed
- CSFOAM-17687: Update Docker to latest
- CSFOAM-18123: Removed Best Match from Image Flavor Policy at global level
- CSFOAM-18166: Update Docker to latest
- CSFOAM-18252: curl options modify for grafana plugin sidecar
- CSFOAM-18261: Remove CMDB plain certificate configurations
- CSFOAM-18169: Version update for 23.11 Release
- CSFOAM-18278: Updated fluentd config file paths
- CSFOAM-18278: Updated fluentd docker to latest
- CSFOAM-18314: updated image tag for cbur and kubectl image 
- CSFOAM-18311: Added brhooks to replace helm plugin hook jobs,removed quotes from myqsl cmds.
### Security
### Fixed
- CSFOAM-17878: Fix in NOTES.txt for Warn only if component, key or parent key is used/enabled.
- CSFOAM-16740: Fix for Unable to install cpro-grafana with same release name in two different namespaces
- CSFOAM-18168: Fix lint helm3 issues. Removed nil comparision in templates
- CSFOAM-18123: Image Flavor br hook fix


## [6.1.1]
### Added
### Changed
- CSFOAM-17749: Chart changes to point the docker images from delivered location 

### Security
### Fixed
- CSFOAM-17749: Fix to update the cpro-common-lib version in chart.yaml to take the fluentd image correctly and base docker image update
- CSFOAM-17749: Reverting to old base docker image due to issue in the restapi docker image( as openssl is not available in distroless docker image)




## [6.1.0]
### Added
- CSFOAM-16678: Added character length restriction for the containername and containerNamePrefix
- CSFOAM-16661: Removing multiple registry from the global and introducing flat registry in global as per HBP 3.5.0 [ HBP_Helm_reloc_1, HBP_Helm_reloc_2, HBP_Helm_reloc_3 ]
- CSFOAM-16661: increased chart version of cpro-common-lib to take the fluentd and logrotate global registry and flat registry as per HBP 3.5.0 
- CSFOAM-16912: Added certManager in global level and root level takes precedence over global level
- CSFOAM-16941: [HBP v3.6.0] HBP_Istio_sidecar_1 (Added changes to have configurable istio admin stopPort and healthCheckPort)
- CSFOAM-15494: [HBP v3.4.0] cpu limits are removed by default as per HBP 3.4.0 [HBP_Kubernetes_Pod_res_3] & 3.6.0 [HBP_Kubernetes_Pod_res_5]
- CSFOAM-15494: [HBP v3.4.0] To enable cpu limits for fluentd & logrotate containers as per HBP 3.4.0 [HBP_Kubernetes_Pod_res_3] & 3.6.0 [HBP_Kubernetes_Pod_res_5]
- CSFOAM-16582: Updated grafana docker image
- CSFOAM-16541: Added TLS_1_3 support for Grafana
- CSFOAM-17399: base docker image update
- CSFOAM-17406: Added few more tests in helm UT for Resource Requirement
### Changed
- CSFOAM-16663: Changing the syslog.enabled default value at global value from emtpy to false as per HBP v3.5.0 [HBP req id is: HBP_Kubernetes_Log_3]
- CSFOAM-16685: Image tag for distroless has been changed as imagename and tag has changed as per HBP 3.5.0 [HBP req id are: HBP_Containers_name_1, HBP_Containers_name_2, HBP_Kubernetes_Pod_2]
- CSFOAM-16665: Added reloader annotation to reload grafana pod upon update of secret or configmap mounted as Volumes in STS
- CSFOAM-16685: Image tag  and image name change as per HBP 3.5.0 [HBP req id are: HBP_Containers_name_1, HBP_Containers_name_2, HBP_Kubernetes_Pod_2]
- CSFOAM-17093: Fix for Grafana - post_logout_redirect_uri is hardcoded in values.yaml
- CSFOAM-16582: Update Docker to latest
- CSFOAM-17273: To take latest docker where name change of python38 to python3.8 in the imageflavor
- CSFOAM-16591: Grafana docker update
- CSFOAM-17405: Updating the cbura-sidecar container naming logic in _helpers.tpl
- CSFOAM-17402: Updated goproxy version to fix high level vulnerability
- CSFOAM-17621: Updated cbur-agent and log-manager versions
- CSFOAM-17468: Grafana docker update
- CSFOAM-17468: fluented docker update
- CSFOAM-17468:  move chart to stable
### Security
### Fixed
- CSFOAM-16894: Fix for CBUR Backup for 3gppxml fails due to: tar: /gen3gppxml-data: file changed as we read it.
- CSFOAM-16917: Fix for time zone setting uses wrong name
- CSFOAM-16951: Fix for the test container pod which is having to pull the image
- CSFOAM-17063: Fix for Helm test for grafana not failing in case cmdb instances are not present
- CSFOAM-16814: Fix for CSFS-54132 by replacing restartgrafana with processrestart
- CSFOAM-17401: Fix for Grafana kiwigrid version to take for centos and rocky versions
- CSFOAM-16741: Fix for Grafana delete datasource job is not failing with wrong password
- CSFOAM-17403: Updated Grafana Kiwigrid Version
## [6.0.1] - 2023-07-19
### Added
### Changed
### Security
### Fixed
- CSFOAM-16742: Fix for grafana dashboard delete job

## [6.0.0] - 2023-06-30
### Added
- CSFOAM-15693: [HBP v3.3.0] HBP_Kubernetes_Pod_3 & HBP_Kubernetes_Pod_4,  Addition of imagePullSecrets to workload level in Grafana chart
- CSFOAM-15869: Automate Manual Validations - autoUpdateCron and autoEnableCron parameter UT 
- CSFOAM-15287: [HBP v3.3.0] Added PodTopologySpreadConstraints as per HBP requirement HBP_Kubernetes_PodTopology_1 HBP_Kubernetes_PodTopology_2
- CSFOAM-16117: readonlyfilesystem and allowpreviledgeescalation has to be added in the fluentd and logrotate contianer security context
- CSFOAM-16189: ut for fluentd and logrotate to check the imagepull policy
### Changed
- CSFOAM-15845: [HBP v3.3.0] PodSecurityPolicy: HBP_Kubernetes_PSP_2, HBP_Kubernetes_PSP_3
- CSFOAM-16010: Kafka service metrics dashboard being deployed with CSFP
- CSFOAM-16204: configuring Generic template for syslog 
- CSFOAM-16014: Update all templates from csf-commons-lib to latest csf-common-lib-1.8.0 - remove deprecated content
- CSFOAM-16296: Grafana code changes for not displaying sensitive data
- CSFOAM-15766: updated the docker image tag
- CSFOAM-16118: Removed readonlyfilesystem and allowPrivilegeEscalation from the root level and added under the each container securitycontext
- CSFOAM-16256: changed fluentd tag to take the latest fluentd image 
- CSFOAM-16509: move chart to stable
### Security
### Fixed
- CSFOAM-16163: cpro-common-lib version update as imagepullpolicy for fluentd is empty
- CSFOAM-16124: Updated the docker image tag to fix logger.py in kiwigrid image should NOT be root uid permission.
- CSFOAM-16195: fix for CSFS-53278 cpro-grafana dashboards should use 4x larger sampling interval than prometheus scrape interval
- CSFOAM-16023: updated the docker image tag for distro and utils
- CSFOAM-16023: updated the docker image tag for distro
- CSFOAM-16195: fix for CSFS-53278 Fixed the title of the panel in the dashboards.
- CSFS-53666: Fix for error when syslog facility value set to capital letter
## [5.3.1] - 2023-04-28
### Fixed
- CSFOAM-15718: fix for CSFS-52613 Linting is failing for btel chart
- CSFOAM-15785: Authentication issue in datasource and dashboard jobs
- CSFOAM-16285: Fix for not working packaged dashboards
### Changed
- CSFOAM-15800: Chart Promotion

## [5.3.0] - 2023-04-06
### Added
- CSFOAM-14186: Added csf-common-lib to the chart dependencies
- CSFOAM-12904: [HBP v3.0.0] [HBP v3.1.0] poddisruptionbudget, Required ID: HBP_Kubernetes_PDB_1, Desc: Change in default configuration ie, setting the values for maxUnavailable.
- CSFOAM-14157: GRAFANA chart changes for ephemeral storage volume implementation.
- CSFOAM-14298: [HBP v3.1.0] HPA support for grafana
- CSFOAM-14390: charts changes for the klogrunner for kiwigrid container
- CSFOAM-14518: Added update strategy for grafana
- CSFOAM-14391: Making fluentd container for the syslog
- CSFOAM-14393: configuration added for the fluentd to forward logs to syslog server(with out tls)
- CSFOAM-14386: Support for dnsConfig customization
- CSFOAM-14158: cbur's ephemeral volumes for grafana
- CSFOAM-14394: Added logrotate configuration for grafana and kiwigride containers
- CSFOAM-14398: Added tls configuration for the syslog
- CSFOAM-15235: Added centos implementation for the fluentd
- CSFOAM-15356: Container name for segregating logs in syslog
- CSFOAM-15359: Installation fails for grafana with helm version less than 3.11
- CSFOAM-14397: UT for syslog feature
### Changed
- CSFOAM-14282: Made grafana logs path configurable and added grafana log mode to file
- CSFOAM-14687 : Templating keycloak context path
- CSFOAM-14775: Removed instance dropdown in Kubernetes App Metrics Dashboard.
- CSFOAM-14571: Removed obsolete labels in cpro-grafana
- CSFOAM-14032: Updated base docker image
- CSFOAM-15092: dashboards now take local browser time as default
- CSFOAM-15381: Base docker images update
- CSFOAM-15368: Modify ExecStart path in source code for grafana-server service
- CSFOAM-14663:Org creation restapi json response message changed
- CSFOAM-15439: change the fluentd image to delivered location for the syslog
### Security
### Fixed
- CSFOAM-14526: fix for Grafana installation error when HPA enabled
- CSFOAM-14303:Fix for CSFS-50980
- CSFOAM-14388:Grafana UI issues found in chart cpro-grafana-5.2.0
- CSFOAM-13855:Fix for post upgrade job is creating even when cmdb is set to false and sqlitetomdb is set to true in grafana
- CSFOAM-14076:Fix for Grafana installation notes.txt is not giving full information
- CSFOAM-15223: Fix for grafana installation failure
- CSFOAM-15255: Fix for grafana installation failure after syslog tls config is added
- CSFOAM-15301: Fix for fluentd and logrotate is not rendering even when syslog is disabled and extensions is enabled in grafana
- CSFOAM-14491: need to support secureJsonData field as part of SetDatasource section.
- CSFOAM-15355: Grafana unable to come up on syslog enabled and Plugin sidecar disabled
- CSFOAM-15243: Time field value being sent as null to the syslog server from the grafana sidecar container
- CSFOAM-14635: Multi-tenancy functionality is not working
- CSFOAM-15308: [Bug] In BVNF envt, grafana service Is not up
- CSFOAM-15395: Default datasource is not getting added during grafana installation

## [5.2.0] - 2023-01-13
### Added
- CSFOAM-13470: [HBP v3.1.0] [HBP_Kubernetes_PSP_1] Added functionality to validate/check for PodSecurityPolicy in kubernetes environment.
- CSFOAM-13469: [HBP v3.1.0] Helm Chart dependencies, Required ID: HBP_Helm_Umbrella_1, Desc: apiVersion has to be changed from v1 to v2
- CSFOAM-13468: [HBP v3.1.0] Changed the Anti Affinity label from failure-domain.beta.kubernetes.io/zone to topology.kubernetes.io/zone
- CSFOAM-13664: Fix for CSFS-44118: grafana chart deletion failure when cmdb is enabled in istio setup
- CSFOAM-12905: [HBP v3.0.0] made changes according to named-templates Helm Best Practices & HBP_Helm_Templates_1
- CSFOAM-12906: [HBP v3.1.0] Common-labels, Required ID: HBP_Helm_Labels_1, Desc: changes for common labels as per HBP 3.1.0
- CSFOAM-12907: [HBP v3.1.0] Changes for custom-labels-and-annotations requirement IDs:HBP_Helm_Annotations_1,HBP_Helm_Annotations_2, HBP_Helm_Annotations_3, HBP_Helm_Labels_5, HBP_Helm_Labels_6
- CSFOAM-13662: [HBP v3.1.0] [HBP_Security_PSS_2] Added functionality to validate/check for PodSecurityPolicy Context and ContainerSecurity Context in kubernetes environment.
- CSFOAM-13533: go version upgraded to 1.19.4 , base docker images upgraded , cbur update to 1.0.3-4789 and kubectl updated to v1.25.5-nano-20221226/v1.25.5-rocky-nano-20221226 
- CSFOAM-13539: Grafana Upgraded to 9.3.2      
- CSFOAM-14074: kiwi-grid version upgraded to 1.21.1 and corrected kubect centos version path to tools/centos/kubectl 
- CSFOAM-14071: WorkTicket-Kubernetes cluster monitoring (via Prometheus) dashboard jams Grafana
### Security
### Fixed
- CSFOAM-13845: fix for cpro-grafana pipeline failure during upgrade from non-ha to HA
- CSFOAM-13747: Add configurable service name for the grafana service.
- CSFOAM-12586: Fix for Unable to complete Grafana jobs
- CSFOAM-13963: Fix for Grafana jobs uninstallation failure
- CSFOAM-14038: Fixed return value checks in grafana jobs
- CSFOAM-13796: Corrected grafana headless service name for the statefulset  
- CSFOAM-13405: use mariadb client from cmdb in mdb tool 

## [5.1.0] - 2022-09-30
### Added
- CSFOAM-12592:Restrict /metrics endpoint access with out autentication
- CSFOAM-12854:Grafana Version Upgrade to 8.5.11
- CSFOAM-13099: upgrade go version to 1.18.6, distroless base image upgrade, Change default dockers to rocky8 and updated cbura and kubectl version
- CSFS-48109: Added 65534 user to root group in all non-distro image and change default user to 65530 for all distro image
- CSFOAM-13210: adding configuration to render svc in certificates
- CSFOAM-13206: add configurable service name for the grafana svc endpoint.
- CSFOAM-13213: Fix for CSFS-48055 Pod and JOB prefix name does not support in CPRO 22.06
- CSFS-48109: group permission changes to mounted cm and secret files to have same permission as that of user
- CSFOAM-13320: update docker versions
- CSFOAM-12590: Fix and UT for CSFS-46271

## [5.0.2] - 2022-09-08
### Fixed
- CSFOAM-12718: cpro-server is unable to communicate to grafana in istio mode 
- CSFS-46876: grafana pod is not coming up since cpro-grafana-sc-dashboard container is in error state
- CSFS-47325: Grafana 22.06 Import Dashboard Job fails to import node exported dashboard
- CSFS-47502: cpro server is unable to communicate to other components in istio mode
- CSFS-47742: System metrics UI shows Performance monitoring instead of system metric which is configured with appTittle in helm value
### Added
- CSFOAM-12449: Alerts Firing and Number cores configured panels are not populated in NCS22
- CSFOAM-12722: upgrade go version to 1.18.5, base docker version update, kubectl version update, fix for UT failure

## [5.0.1] - 2022-06-30
### Changed
- CSFS-44522: Fixed K8S dashboard view issue in NCS22

## [5.0.0] - 2022-06-30
### Added
- CSFOAM-10858: [HBP v2.1.0] service-port and container port
- CSFOAM-11536: Grafana Support on Rocky8
- CSFOAM-12224: DualStack support for CPRO
- CSFOAM-11919: Trademark for Grafana 8.5.3
- CSFOAM-12217: Unit test for the cpro components
### Changed
- CSFOAM-10856: [HBP v2.0.0] PodDisruptionBudget
- CSFOAM-10860: [HBP v2.1.0] Chart dependencies
- CSFOAM-8680 : [HBP v197] 2.27. Extended pod practices
- CSFOAM-8771: [HBP v197 ]Values
- CSFOAM-11688: [HBP v2.2.0] [PDB] Add support of 0
- CSFOAM-10857: [HBP v2.0.0] Kubernetes Versions
- CSFOAM-12122: Cpro and grafana Installation failing with Ingress
- CSFOAM-11955: Implement Docker and Chart - Upgraded grafana version to 8.5.2 without any customization
- CSFOAM-11712: Update Grafana charts with latest docker image
- CSFOAM-11654: Fix for CSFS-44118 : ig-cpro-grafana-post-del sa not getting deleted on grafana uninstall.
- CSFOAM-12163: Porting changes from 21.11FP1PP1 and PP2 to main branch
- CSFOAM-12163: Update base docker images, CBUR and kubectl images
- CSFOAM-12163: go version 1.18.2
- CSFOAM-12209: Installation failing with Cert Manager
- CSFOAM-10854: [HBP v2.0.0] Pod Security Context
- CSFOAM-11958: Chart changes for backend customization code(generic_oauth + sql + multi-tenancy)
- CSFOAM-12218: added resources for downloadDashboards container
- CSFS-43749: fix for CPRO pods do not follow naming convention for container name prefix for cbur-sidecar
- CSFOAM-11957: Updated grafana and plugins version
- CSFOAM-12225: Updated go version 1.18.3
- CSFOAM-12283: Upload Json not working with latest incubator grafana chart (5.0.0-13)
- CSFOAM-12356: fix for CSFS-46478, avoid adding podname prefix to pods when name override or fullname override is provisioned
- CSFOAM-12356: fix for CSFS-46500, helm test to check for specific app label  
- CSFOAM-12329: Grafana UI bugs in 8.5.3 version
- CSFOAM-12225: Updated docker tags after BDH-BOM integration
- CSFOAM-12426: Fixed Grafana burp scan autocomplete issue
- CSFOAM-12443: Added require promethus json in source code for datasource
- CSFOAM-12444: chart changes to use delivered docker for CPRO 22.06 release

## [4.2.0] - 2022-03-07
### Added
- CSFOAM-11010: Grafana chart Changes for docker optimization
- CSFOAM-11036: Grafana backup and restore via tls
- CSFOAM-11036: Grafana deldb and sqltomdb via tls
- CSFOAM-11492: Grafana FileSizeValidator code changes
- CSFOAM-11520: rebuilt dockers with latest base docker image and kubectl image update
- CSFOAM-12263: Implementation of emptyDir ephemeral storage for cpro-grafana
- CSFOAM-12263: Implementation of waitPodStableSeconds for cpro-grafana for cbur backup/restore
### Fixed
- CSFS-42697: CSFP monitoring - Kubernetes App Metrics reports with No data
- CSFOAM-11374: spec "keysize" is not available in cert-manager.io/v1 on openshift 4.9 platform
- CSFOAM-11379: Fixed grafana cmdb installation , backup and restore issue in non-tls mode
- CSFOAM-11390: Rebuilt dockers with go1.16.14
- CSFOAM-11407: Fix for configmap reload restart
- CSFOAM-11484: Fix for CSFS-43749. support for prefix for test container
- CSFOAM-12176: Fix Added template for certManager keysize condition

## [4.1.2] - 2022-01-28
### Added
- CSFOAM-10988: rename istio templates
### Fixed
- CSFOAM-11050: does not support custom host configurations when sharedgateway is enabled

## [4.1.1] - 2021-12-17
### Added
- CSFOAM-10820: Upgrade Base Docker image for grafana
- CSFOAM-10820: Upgrade Base Docker image for and use latest image.

### Fixed
- CSFOAM-9792: Remove git dependency in Grafana
- CSFOAM-10844: Fix Vulnerability reported by trivi scan.

## [4.1.0] - 2021-11-26
### Added
- CSFOAM-9466: [HBP v197] Addittion of PDB to Grafana chart
- CSFOAM-9561: [CPRO-Grafana][QG-Beta] 2.10 Replicas
- CSFS-39058: Added proviosing plugins folder
- CSFOAM-9509: [Istio related conventions] Implementation of Istio related values in Grafana
- CSFOAM-10073: grafana chart changes to updated all distroless images versions
- CSFOAM-10040: [HBP v197] 2.14. Ingress annotation - Grafana JSESSIONID (Deprecated)
- CSFOAM-9876: [CPRO-Grafana]2.24. Time consideration
- CSFOAM-8769: [HBP v197] Helm hooks and activeDeadlineSeconds
- CSFOAM-10000: Grafana UI trademark changes
- CSFOAM-10128: Helm chart upgrade with latest docker image
- CSFOAM-8728: [HBP v197] 2.29. anti-affinity, nodeselector and tolerations
- CSFOAM-10405: [CPRO-Grafana][HBP v197][REQUIRED] 2.13. Labels and Annotations
- CSFOAM-10042: Providing the priviledge to create the headless svc for adding workload in the istio mesh in REGISTRY_ONLY
- CSFOAM-10468: provision for configuring apiVersion for brPolicy and have livenessProbe and readinessProbe in all condition
- CSFOAM-10413: chart changes for cpro-grafana for CSFOAM-8729
- CSFS-38792: Adding support for issuerRef.group field in cert manger generated certs
- CSFOAM-10594: chart changes with updated docker image
- CSFOAM-10572: Chart changes to use latest image
- CSFOAM-10635: node-exporter , Kubernetes App Metrics, grafana Performance dashboard changes
- CSFOAM-10686: temp folder to be mounted in grafana for non-root users
- CSFOAM-10713: GO version upgrade
- CSFOAM-10715: Istio version compare with 1.6 failed when istio version is 1.11
- CSFOAM-10757: Grafana helm test is failing in EKS
- CSFOAM-10758: EKS - Unable to delete grafana chart
- CSFS-40091: cpro-grafana: Credentials cannot be hard-coded in helm charts and docker images
- CSFOAM-10871: When sensitive data is enabled, why it is mandatory to provide grafana adminPassword.

### Fixed
- CSFS-39778: CPRO Custom annotation values should be quoted
- CSFS-39133: K8s All Nodes graphs are not showing proper results for "y axis"
- CSFS-39127: K8s Cluster not showing totals for Cluster memory usage and Cluster CPU usage in Grafana dashboard
- CSFOAM-10080: Fix for istio proxy port CSFS-40209
- CSFOAM-10746: mdb tool go version fix

## [4.0.1] - 2021-08-24
### Changed
- CSFOAM-9621: Grafana chart changes to support NCMS exporter tool

## [4.0.0] - 2021-08-10
### Changed
- CSFOAM-8099: Grafana 7.5.9 helm chart upgrade
- CSFOAM-8974: Code changes for containers on root filesystems in read-only mode
- CSFOAM-9080: automountServiceAccountToken flag for grafana chart
- CSFOAM-9118: grafana chart changes for psp changes and allowPrivilegeEscalation flag
- CSFOAM-8994: [HBP v197][QG-Beta][CPRO-Grafana] 2.9. IP address
- CSFOAM-8099: Grafana 7.5.9 helm chart upgrade
- CSFOAM-9052: Replaced cpro-util container with grafana-util
- CSFOAM-9232: Updated Grafana plugins docker image
- CSFOAM-9095: Chart changes to remove internal cmdb
- CSFOAM-9165: CLONE - Creation of additional resources for grafana helm test.
- CSFOAM-9285: grafana chart changes with updated docker image
- CSFOAM-9298: grafana chart change
- CSFOAM-9304: TLS communication for grafana with External CMDB
- CSFOAM-9360: grafana chart change with latest docker CSFOAM-9357
- CSFOAM-9365: grafana docker file changes to fix csfoam-9363
- CSFOAM-9374: grafana docker changes for CSFOAM-9369
- CSFOAM-9358: Grafana docker image changes for CSFOAM-9358 and chart changes for CSFOAM-9366
- CSFOAM-9399: removing go.mod file from the grafana docker image

## [3.20.0] - 2021-06-11
### Changed
- CSFOAM-8040: [GRAFANA] Chart Level changes for random user support
- CSFOAM-8248: Add range in fsGroup and runAs within PSP(CSFID-3371)
- CSFOAM-8353: Review comments for centos7 Chart changes
- CSFOAM-8367: grafana chart change for CSFOAM-8342 and cluster role modification
- CSFOAM-8383: Upgrade failing for versions less than 3.18.2 to latest (3.20.0-4) with overwrite yaml values
- CSFOAM-8490: updating helm chart with new grafana docker image
- CSFOAM-8459: FsGroup not assigned for jobs in ncs for grafana
- CSFOAM-8526: Cbur Image is missing in candidates repo
- CSFOAM-8015: Grafana and cpro-util docker images tag update for autoComplete issue fix
- CSFOAM-8567: grafana chart upgrade with latest docker images
- CSFOAM-8520: Chart changes for docker tagging 

## [3.19.0] - 2021-01-05
### Changed
- CSFS-32553: Validation of dataEncryptionSecretName defaults in BrPolicy
- CSFS-29347: When grafana receives Authorization and X-WEBAUTH-USER, the request fails
- CSFOAM-7372: Fix for Disk Usage Alerts
- CSFOAM-7547: CertManager from NCM for Grafana - CSF-25745
- CSFOAM-7476: Chart changes to fix SVM-63645 ; grafana-plugin image tag
- CSFOAM-7655: Updated Grafana mdbtool image tag
- [CPRO][K8s best practice][labelling] - cpro-grafana chart dev
- CSFOAM-7840: helm chart changes with update docker version
- CSFOAM-7898: grafana chart upgrade for csfs-35535 ticket
- CSFOAM-7947: istio-version upgrade for grafana chart
- CSFOAM-8006: helm2 upgrade for cpro-grafana failing after HBP implementation

### Fixed
- CSFS-31409: Fixed to show query instead of Value if no __name__ and metric in dashbaords
- CSFOAM-7538: cpro-grafana 3.19.0-4 | SetDatasource job is going into crashloopbackoff
- CSFOAM-7631: Changes in Node exporter json dashboard for ipv6 - Fix for CSFS-33384
- CSFOAM-7620: Proxy Authentication for sensitive data feature
- CSFOAM-7651: Corrected imagePullPolicy and imagePullSecrets
- CSFOAM-7677: updating the comments for alertmanager dashboard
- CSFOAM-7683: Remove extra space in _helpers.tpl
- CSFOAM-7703: following HBP for grafana upgrade ( CSFS-34232 )
- CSFOAM-7782: Fixing imageTag for PluginsSideCar
- CSFOAM-7741: rebuilt dockers with latest base docker image
- CSFOAM-7727: configure nodeSelector/toleration/affinity for Jobs
- CSFOAM-7745: Deletion of pods went to "ERROR" state after upgradation of  pods was done from n-2 to n grafana chart version 
- CSFOAM-6981: grafana installation with internal cmdb fails if release name has cmdb in it
- CSFOAM-7586: new grafana rpm for addition of prometheus monitoring dashboards.
- CSFOAM-7841: Latest CMDB 7.14.1 is unable to connect to grafana
- CSFOAM-7142: Fixed COMPAAS installation issue

## [3.18.0] - 2020-12-25
###Added
- CSFOAM-6998: support for cni disabled in istio for cpro charts
- CSFOAM-7026: grafana chart changes to use latest docker images and apiVersion change for RBAC
- CSFOAM-6764: NOM Specific Requirements for Sensitive Data
- CSFS-28191: Resource name are limited to resourceNameLimit value
- CSFOAM-7129: Fix for CSFS-32119
- CSFOAM-7152: chart changes for mdb and jobs-CPRO-GRAFANA
- CSFOAM-7159: ComPaaS changes
- CSFOAM-7163: chart version upgrade

## [3.17.0] - 2020-11-16
### Fixed
- CSFS-29039: cpro-grafana-3.15.0 exposes invalid metrics endpoint
- CSFS-28721: grafana ini file is not getting updated during cpro-grafana upgrade
- CSFOAM-6512: encrypt and decrypt sensitive data as part of backup & restore
- CSFOAM-6526: Updating CMDB latest version in Grafana chart
- CSFS-25645: Plugins installed are not presisted after restart of pod.
- CSFS-25441: cpro-grafana SetDatasource & SetDashboard related issues.
- CSFOAM-6635: Change default value of prometheus.io/scheme annoation to https
- CSFOAM-6661: Updated grafana-tenant docker image tag with dependencies angularjs to 1.8.2
- CSFOAM-6524: To Align with HBP, downloadDashboards image has been modified from appropriate/curl to grafana-curl

## [3.16.1] - 2020-10-07
###Added
- CSFS-29417: Fixed dashboard rendering issue
- CSFS-20114: Grafana application title is user configurable
- CSFS-29475: Fixed grafana dashboard issue

## [3.16.0] - 2020-10-01
###Added
- CSFS-28115: Grafana should provide support for cbur autoUpdateCron parameter in BrPolicy
- CSFS-26510: Grafana allows password policy allows to set "@" character to grafana admin user password post this the subsequent upgrade fails
- CSFOAM-6172: Grafana chart changes to fix CSFS-27259
- CSFOAM-6234: CSFS-27347 grafana changes to expose metrics via service
- CSFOAM-6216: Updated grafana tenant docker image tag
- CSFS-18500: Updated file permissions for grafana volumes
- CSFS-17235: Fixed prometheus datasource error upon upgrade
- CSFOAM-6300: Update image tag and change registry to candidates
- CSFS-24504: Add Datasource button is added.
- CSFS-25869: SignIn redirection issue is solved wih grafana upgrade.
- CSFS-24478: SignIn redirection issue is solved wih grafana upgrade.
- CSFS-26961: SignIn redirection issue is solved wih grafana upgrade.
- CSFS-22926: Playlist can be saved after grafana upgrade.
- CSFS-27322: SignIn redirection issue is solved wih grafana upgrade.
- CSFOAM-6336: Updated hook deletion policy for update datasource job
- CSFOAM-6339: Auto Import dashboards and SetDatasource is failing for grafana in cpro-grafana-3.16.0-10.tgz
- CSFOAM-6371: updating readme.md for cpro-grafana

## [3.15.0] - 2020-09-01
###Added
CSFOAM-6154: Fix for grafana upgrade failure from cpro-grafana-3.14.0 to cpro-grafana-3.15.0-7
- CSFS-25109: CPRO chart has dependency on K8s version in EKS
- CSFS-25970: Specify resources for all containers
- Apply helm best practice for 'Relocatable Chart', global.registry2 is added for sidecar repository and global.registry5 is added for sane repository
- CSFS-27188, CSFS-27192, CSFS-27151: istioVersion as integer, support to integrate with external CKEY and readiness failure in istio 1.5 
- CSFS-24674: cpro-grafana support to evaluate _url config parameters as Template
- CSFOAM-5996 Grafana pods are going in crashloop backoff
- CSFS-24195: Added cookie_secure flag to grafana.ini

## [3.14.1] - 2020-07-23
###Added
- CSFS-26617: Grafana delete datasource job failing 

## [3.14.0] - 2020-07-16
#Added
- CSFS-26495: Support to provide option for global.istioVersion

## [3.13.0] - 2020-07-14
### Added
- ISTIO ingress certificate update to credentialName
- CSFOAM-5536: Grafana containers runs on single user id and runAsUser,fsGroup and supplementalGroups are configurable
- CSFOAM-5546: Added mcs label, seccomp and apparmor annoations
- CSFOAM-5849: Helm Best Practice changes for Grafana chart
- CSFOAM-5878: Added service entry and virtual service to support ckey.
- CSFS-23095: Added Golbal serviceAccountName
### Changed
- CSFS-25041: BTEL Grafana Helm chart backup using CBUR error - incorrect cmdb service name
- CSFS-22407: Grafanas "Kubernetes cluster monitoring (via Prometheus)" not showing the pods anymore
- CSFOAM-5550: istio single-gateway functionality , DestinationRule and Policy have been updated.
- CSFOAM-5551: istio changes for peer authentication
- CSFOAM-5793: Adding configuration for istio role,rolebinding
- CSFOAM-5855: docker image update and istio-mutual support
- CSFOAM-5882: match label for peer authentication
- CSFOAM-5921: PSP creation , when CNI is disabled doesnot have NET_RAW in allowedCapabilities
- CSFOAM-5943: fix for Grafana not coming up with internal cmdb when istio enabled

## [3.12.0] - 2020-05-11
### Added
- Helm Port Istio-Style Formatting
- CSFOAM-5316: Updated grafana docker image tag
- CSFOAM-5315: Upgraded Grafana component to the latest version

## [3.11.3] - 2020-03-14
### Added
- CPRO-Grafana Helm3 K8s 1.17 Compliance

## [3.11.2] - 2020-03-10
### Added
- Udating the tools/kubectl image version

## [3.11.1] - 2020-03-05
### Added
- Updating the semverCompare condition for helm3 upgrade

## [3.11.0] - 2020-03-03
### Added
- Updated to remove the deprecate K8S APIs
- docker image versions updated
- cmdb version changed from 6.3.1 to 7.6.0
## [3.10.0] - 2020-01-28
### Added
- Chart changes to support sane authentication using auth proxy
- By default sane is disabled
## [3.9.1] - 2019-12-20
### Added
- Remove Grafana logo, icon to overcome security trademark violations
- CSF chart relocation rules enforced
- Add istio feature
- Add a switch to retain cmdb data
### Changed
- Fix ticket CSFOAM-2687 in 1.0.3-2
- Change certification method. Avoiding manual steps in 1.0.3
### Security
- Integration with Grafana and Keycloak
### Fixed
CSFOAM-4490: image update for mysql deadlock issue

## [3.0.9] - 2019-09-24
### Fixed
- CSFS-16527:Grafana oauth session is forcely invalidated after "Access Token Lifespan" is exceeded

## [3.0.8] - 2019-09-10
### Added
- Added alertmanager datasources plugin
- Added bar chart and pie chart plugins
- Added before-hook-creation for import dashboard and datasource job.
- Added node-exporter-full dashboard.
- Supports to set existing keycloak secret in values.yaml
### Changed
- Change image to nano.
- Changed defaut ssl key and cert.
- helmDeleteImage updated to v1.14.3-nano
- Default pv size changed back to 1G.
- Removed session part in values.yaml
### Fixed
- Dashboard and datasource can be overwrited during upgrade.

## [3.0.7] - 2019-07-31
### Fix
- Fixed keycloak session issue

## [3.0.5] - 2019-07-4
### Changed
- Change Deployment to StatefulSet
- Change DS_PROMETHEUS to prometheus in dashboard
- Add backoffLimit parameter

## [3.0.4] - 2019-07-2
### Changed
- Add registry2 in deployment.yaml and values.yaml

## [3.0.3] - 2019-06-26
### Changed
- Change Values.schema to Values.scheme
- Fixed set datasource issue
- Add key pspUseAppArmor

## [3.0.2] - 2019-06-24
### Changed
- Fix initContainers bug in template

## [3.0.1] - 2019-06-19
### Changed
- Add a key deployOnCompass to 3.0.0

## [3.0.0] - 2019-06-19
### Changed
- Upgrade grafana version to 6.2.2

## [2.0.22] - 2019-06-26
### Changed
- Change Values.schema to Values.scheme
- Fixed set datasource issue

## [2.0.21] - 2019-06-25
### Changed
- Add key pspUseAppArmor

## [2.0.20] - 2019-06-24
### Changed
- Fix initContainers bug in template

## [2.0.19] - 2019-06-20
### Changed
- Add a key deployOnCompass to 2.0.18

## [2.0.18] - 2019-06-19
### Changed
- Change image tag

## [2.0.17] - 2019-06-13
### Changed
- Fixed post-delete secret issue
- support cpro-grafana to deploy on ComPaaS
- Parameterize CBUR configurations for cpro-grafana chart

## [2.0.15] - 2019-06-5
### Changed
- TLS can support between MariaDB and Grafana
- Fixed upgrade defects

## [2.0.13] - 2019-05-31
### Changed
- Made br policy configurable and fixed upgrade from 1.0.9.

## [2.0.10] - 2019-05-17
### Changed 
- Fixed backup/restore and upgrade issue.

## [2.0.5] - 2019-03-11
### Changed
- Change default database and session

## [2.0.4] - 2019-03-11
### Changed
- Change default ha value to false

## [2.0.3] - 2019-02-20
### Fixed
- Delete import-dashboard and set-datasource jobs when hook-succeeded
- Change post-delete job name

## [2.0.2] - 2019-01-31
### Fixed
- Fixed security policy for upgrade event

## [2.0.1] - 2019-01-30
### Changed
- Grafana HA support initial version
- Using cmdb 6.3.1
- Fix issue with NodeExporter 0.15.2 -> 0.16.0 (A lot of metrics were given different names)
- Support upgrading from version 1.0.9 using mariadb to this version

## [1.0.15] - 2019-1-21
### Changed
- Changed image tag to 1.5 so can be deployed in BCMT 18.12

## [1.0.14] - 2019-1-8
### Changed
- Add flag for BrPolicy

## [1.0.13] - 2018-12-28
### Changed
- Add Tenantlabel and Tenantvalue in Grafana for Prometheus Multi-tenancy support
- Limited to install under BCMT environment for adding BrPolicy

## [1.0.12] - 2018-12-28
### Changed
- Update grafana docker image

## [1.0.11] - 2018-12-19
### Changed
- Add brpolicy and upgrade for db schema change

## [1.0.10] - 2018-11-29
### Changed
- Adopt global relocation

## [1.0.9] - 2018-10-24
### Fixed
- Avoid updating password after Helm upgrade

## [1.0.8] - 2018-10-24
### Fixed
- Avoid updating password after Helm upgrade

## [1.0.7] - 2018-09-11
### Fixed
- Use CSF-built Grafana docker image

## [1.0.6] - 2018-09-10
### Fixed
- CSFS-6627: cpro-grafana upgrade issue. Change UpgradeStrategy

## [1.0.5] - 2018-09-09
### Fixed
- Avoiding 3rd party images. Use csf-built ones

## [1.0.4] - 2018-09-03
### Fixed
- Avoiding manual steps in 1.0.3

## [1.0.3] - 2018-08-29
### Added
- CSF chart relocation rules enforced
- Enable HTTPS for Grafana
- Integration with Grafana and Keycloak
### Security
- Enable HTTPS for Grafana
- Integration with Grafana and Keycloak
### Deprecated
- Deprecated because of manual steps

## [0.0.0] - YYYY-MM-DD
### Added | Changed | Deprecated | Removed | Fixed | Security
- your change summary, this is not a **git log**!


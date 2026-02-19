# Changelog
All notable changes to chart **cpro** are documented in this file,
which is effectively a **Release Note** and readable by customers.

Do take a minute to read how to format this file properly.
It is based on [Keep a Changelog](http://keepachangelog.com)
- Newer entries _above_ older entries.
- At minimum, every released (stable) version must have an entry.
- Pre-release or incubating versions may reuse `Unreleased` section.

## [Unreleased]

## [5.0.1]
### Changed
- CSFOAM-18432: Updated components docker images and BSSC fluentd image docker tags.

## [5.0.0] 
### Added
- CSFOAM-17710: Added sensitive data changes
- CSFOAM-17913: Added alert logs in cpro for uktsr for authentication and authorization with env parameters.Converted lower https to upper for gateway env variable.
- CSFOAM-17677: Added TLS & Certificate configurations as per HBP 3.7.0 [HBP_Security_net_1, HBP_Security_cert_2,HBP_Security_Cert_5,HBP_Security_Cert_8] - Addressed review comments-2
- CSFOAM-17673: Chart changes as per HBP_3.7.0_Kubernetes_Pod_6 and pod_7 along with UT
- CSFOAM-17679: Added self-signed issuer creation code as per HBP 3.7.0 [HBP_Security_cert_6]
- CSFOAM-18092: Added UT as per  HBP 3.7.0 security encryption
- CSFOAM-17674: Added Image Flavor to now support Strict and Best Match HBP_Kubernetes_Pod_8 
- CSFOAM-17676: Added Image Flavor Policy fields HBP_Kubernetes_Pod_2 - CPRO
### Changed
- CSFOAM-17656: CentOS7 Deprecation - Charts Git
- CSFOAM-18006: Compass code removal
- CSFOAM-17687: Update Docker to latest
- CSFOAM-18123: Removed Best Match from Image Flavor Policy at global level
- CSFOAM-18166: Update Docker to latest
- CSFOAM-18169: Version update for 23.11 Release
- CSFOAM-18278: Updated fluentd config file paths
- CSFOAM-18278: Updated fluentd docker to latest
- CSFOAM-18311: Added brhooks to replace helm plugin hook jobs
- CSFOAM-18314: updated image tag for cbur and kubectl image 
- CSFOAM-18160: updated  cpro docker images
### Security
### Fixed
- CSFOAM-17675: Fixed Restserver Init Container start issue
- CSFOAM-16740: Fix for Unable to install cpro with same release name in two different namespaces
- CSFOAM-18087: UT failing as there is mismatch in clusterole names
- CSFOAM-18125: Fixed fluentd parse errors for webhook-fluentdcm and added configurations to handle uktsr logs.
- CSFOAM-18224: Fix for cpro chart installation failure in HA mode
- CSFOAM-18230: Fix for sensitivedata endpoint validation failure in cpro
- CSFOAM-18172: Fix for non-tls mode failure in cpro
- CSFOAM-18123: Image Flavor br hook fix
- CSFOAM-18172: Fix for non-tls non-ha mode failure in cpro.
- CSFOAM-18172: Fixed the issue where prometheus scheme is missing for ksm
- CSFOAM-18247: Remove version label from deployments, as it's not needed,causes trouble to deploy WIP charts
- CSFOAM-18246: Fixed helm lint issues in NCS cluster 20.12.961-1.10.1 with helm version 3.4.1
- CSFOAM-18266: Fix custom resource name with out podname prefix is not taking into effect in final podname in cpro chart
- CSFOAM-18265: Fix for TLS conditions
- CSFOAM-18265: Fix for TLS conditions - Update chart version
## [4.1.1]
### Added
### Changed
- CSFOAM-17749: Chart changes to point the docker images from delivered location 
### Security
### Fixed
- CSFOAM-17749: Fix to update the cpro-common-lib version in chart.yaml to take the fluentd image correctly and base docker image update
- CSFOAM-17749: Reverting to old base docker image due to issue in the restapi docker image( as openssl is not available in distroless docker image)

## [4.1.0]
### Added
- CSFOAM-16634: roles and rolebinding for namespaceList for prometheus and KSM
- CSFOAM-16558: Added StartupProbe as per useReadyInStartupProbe feature flag
- CSFOAM-16678: Added character length restriction for the containername and containerNamePrefix 
- CSFOAM-16661: Removing multiple registry from the global and introducing flat registry in global as per HBP 3.5.0 [ HBP_Helm_reloc_1, HBP_Helm_reloc_2, HBP_Helm_reloc_3 ]
- CSFOAM-16661: increased chart version of cpro-common-lib to take the fluentd and logrotate global registry and flat registry as per HBP 3.5.0 
- CSFOAM-16912: Added certManager in global level and root level takes precedence over global level
- CSFOAM-16877: scrape jobs in custom namespaces
- CSFOAM-16941: [HBP v3.6.0] HBP_Istio_sidecar_1 (Added changes to have configurable istio admin stopPort and healthCheckPort)
- CSFOAM-15494: [HBP v3.4.0] cpu limits are removed by default as per HBP 3.4.0 [HBP_Kubernetes_Pod_res_3] & 3.6.0 [HBP_Kubernetes_Pod_res_5]
- CSFOAM-13764: Including chart changes for kubestate metrics deployment for it to run via application runner module when istio is enabled
- CSFOAM-17246: Fix for the cpro installation fails with nameoverride value
- CSFOAM-17399: restapi docker size optimization and base docker image update
- CSFOAM-16559: Chart chanages to monitor the server container from monitoring container. Changed one related parameter from strint to int
- CSFOAM-17437: Throw Error if ReplicaCount>1 for PGW
- CSFOAM-16543: Added TLS_1_3 support for REST_SERVER 
- CSFOAM-17406: Added few more tests in helm UT for Resource Requirement
- CSFOAM-17394: In cluster scope, jobs can be scrapped from custom namespaces  
- CSFOAM-17299: Added patch file changes which needs to be part of chart which is to add condition checks for cpro.webhook4fluentd.pdb.warnings in NOTES.txt and Added prometheus.io/port annotations in kube-state-metrics
- CSFOAM-17431: Aligining certManager with HBP
### Changed
- CSFOAM-16663: Changing the syslog.enabled default value at global value from emtpy to false as per HBP v3.5.0 [HBP req id is: HBP_Kubernetes_Log_3]
- CSFOAM-16685: Image tag for distroless has been changed as imagename and tag has changed as per HBP 3.5.0 [HBP req id are: HBP_Containers_name_1, HBP_Containers_name_2, HBP_Kubernetes_Pod_2]
- CSFOAM-16582: Update Docker to latest
- CSFOAM-17273: To take latest docker where name change of python38 to python3.8 and python36 to python3.6 in the imageflavor
- CSFOAM-16559: ImageFlavor addition for the restapi to take the distroless-jre11 and distroless-jre17  
- CSFOAM-17399: passing time zone to restapi and watching for certmanager certificate change in restapi
- CSFOAM-17405: Updating the cbura-sidecar container naming logic in _helpers.tpl
- CSFOAM-17402: Updated csdc version in restserver
- CSFOAM-17621: Updated cbur-agent and log-manager versions
- CSFOAM-17468: fluented docker update
- CSFOAM-17468:  move chart to stable

### Security
### Fixed
- CSFOAM-17079: Fix for the chart Uninstallation failure when ha is enabled
- CSFOAM-13980: Handled deletion of helm test failed pods
- CSFOAM-16873: Fix for error in cpro image pull back error for prometheus python and restapi 
- CSFOAM-16894: Fix for CBUR Backup for 3gppxml fails due to: tar: /gen3gppxml-data: file changed as we read it.
- CSFOAM-16917: Fix for time zone setting uses wrong name
- CSFOAM-16951: Fix for the test container pod which is having to pull the image
- CSFOAM-17185: Fix for monitoring container image tag issue
- CSFOAM-17183: Fix for alerts not reaching from prometheus to alertmanager
- CSFOAM-17307: Fix for helm test failure
- CSFOAM-17398: Fix for extension missing in the webhooklogs when extension is enabled either at global level or workload level. 


## [4.0.1]
### Added
### Changed
- CSFOAM-16599: Fix for prometheus node-exporter(cpro-3.5.0) not installing on OCP 4.12

## [4.0.0]
### Added
- CSFS-52816: Added rolling update strategy for pushgateway
- CSFOAM-15869: Automate Manual Validations - autoUpdateCron and autoEnableCron parameter UT
- CSFOAM-15652: [HBP v3.3.0] HBP_Kubernetes_Pod_3 & HBP_Kubernetes_Pod_4 ,Addition of imagePullSecrets to workload level in CPRO chart
- CSFOAM-15860: tls for webhook added, docker tag update
- CSFOAM-16117: readonlyfilesystem and allowpreviledgeescalation has to be added in the fluentd and logrotate contianer security context
- CSFOAM-16170: Fix for prometheus node-exporter not installing on OCP 4.12
- CSFOAM-16201: Fix for resources of helmtest pod for CPRO restserver
- CSFOAM-16189: ut for fluentd and logrotate to check the imagepull policy
- CSFOAM-16077: Pod topology spread for server and alertmanager
- CSFOAM-16270: Disable prometheus probe annotation for webhook4fluentd
- CSFOAM-16077: Pod topology spread for cpro components
### Changed
- CSFOAM-15878: Removed the cnot configuration and added the fluentd svc and fluentd port and made configurable
- CSFOAM-14382: Zombie Exported Depreciation.
- CSFOAM-15969: fluentd tag has been made configurable and docker image tag update to take the new rpm
- CSFOAM-15845: [HBP v3.3.0] PodSecurityPolicy: HBP_Kubernetes_PSP_2, HBP_Kubernetes_PSP_3
- CSFOAM-15503: CPRO needs to have a provision to add multiple volume dirs
- CSFS-53329: CPRO node port setting
- CSFOAM-15762: Update docker tags
- CSFOAM-16014: Update all templates from csf-commons-lib to latest csf-common-lib-1.8.0 - remove deprecated content
- CSFOAM-16118: Removed readonlyfilesystem and allowPrivilegeEscalation from the root level and added under the each container securitycontext
- CSFOAM-15766: Update docker tags
- CSFOAM-16256: changed fluentd tag to take the latest fluentd image
- CSFOAM-16509: move chart to stable
### Security
### Fixed
- CSFS-52830: Fixed to add new host path to cpro-server
- CSFOAM-16011: Fixed for webhook is not printing alarms to the console when fluentd svc or fluentd port is not configured under webhook configuration
- CSFS-52846: server-configmap: the name cpro is hardcoded for __meta_kubernetes_pod_label_app
- CSFOAM-15998: Fixed container name prefix in helpers.tpl for cpro's alertmanager, server, restserver and cproUtil
- CSFOAM-16107: Fix for Alertmanager is dependent on webhook4fluentd
- CSFOAM-16163: cpro-common-lib version update as imagepullpolicy for fluentd is empty
- CSFS-53666: Fix for error when syslog facility value set to capital letter
- CSFOAM-16396: Fix for Webhook minimum tls version configurability is missing in the cpro values file
## [3.5.1]
### Added
### Changed
- CSFOAM-15800: Chart Promotion
### Security
### Fixed
- CSFS-52436: Fixed termination of other components resources during release delete in BTEL
- CSFOAM-15995: Fixed the crashloopbackoff error when syslog is enabled for webhook4fluentd and extensions has been added to webhook4fluentd


## [3.5.0] - 2023-04-06
### Added
- CSFOAM-14186: Added csf-common-lib to the chart dependencies
- CSFOAM-12904: [HBP v3.1.0] poddisruptionbudget, Required ID: HBP_Kubernetes_PDB_1, Desc: Change in default configuration ie, setting the values for maxUnavailable.
- CSFOAM-14156: CPRO chart changes for ephemeral storage volume implementation.
- CSFOAM-14156: cpro-pushgateway pvc creation and cbur ephemeral storage volume implementation.
- CSFOAM-14667: charts changes to add klogrun for the cpro alertmanager,server,pushgateway,nodeexporter,webhook4fluentd
- CSFOAM-14667: charts changes to make container to emit logs to file for the kubestatemetrics 
- CSFOAM-14762: Helm chart changes to add fluentd container when syslog is enabled for alertmanager,server,pushgateway,nodeExporter,webhook4fluentd,kubestatemetrics
- CSFOAM-14477: Resource seperation of configmapReload and cproUtil.
- CSFOAM-15256: Added logrotate container when syslog is enabled for alertmanager,server,nodeexporter,pushgateway,webhook4fluentd
- CSFOAM-15266: Changes added for the restserver to send logs to file 
- CSFOAM-14768: fluentd configmap changes for modifying logs to syslog server for prometheus, configmapreload, alertmanager and nodeexporter
- CSFOAM-15292: helm chart changes to take syslog values like host, protocol( syslog parameters) from global or workload
- CSFOAM-15274: fluentd configmap changes for modifying logs to syslog server for kube-state-metrics and pushgateway
- CSFOAM-15313: Added changes for the logrotate and fluentd when extension field is enabled and syslog is disabled
- CSFOAM-15275: fluentd configmap changes for modifying logs to syslog server for webhook4fluentd
- CSFOAM-15350: Container level log segregation for prometheus and alertmanager pod
- CSFOAM-15350: Container level log segregation for prometheus pod
- CSFOAM-15263: Added HELM UT for syslog for [KLOG,FLUENTD and LOGROTATE]
### Changed
- CSFOAM-14197: Updated docker image for restapi to 3.11.0-3.14.0-1530
- CSFOAM-14032: Updated base docker image
- CSFOAM-15381: Base docker images update
- CSFOAM-15439: change the fluentd image to delivered location for the syslog
### Security
### Fixed
- CSFOAM-14679: Configure default path for pushgateway's persistence.file for pvc
- CSFOAM-15172: fix for Configmap reload log-format is causing error
- CSFOAM-15265: fix for Unable to render volumes for webhook4fulentd
- CSFOAM-15311: fix for webhook4fluentd changes 
- CSFOAM-15178: Fixed Node-exporter gatekeeper constraint
- CSFOAM-15325: Fixed for Restserver pod crashes with with syslog enabled
- CSFOAM-15304: Fixed cpro installation issue in NCS 20FP2 cluster
- CSFOAM-15322: Nodeexporter is unable to communicate with syslog server in vanilla k8s
- CSFOAM-15275: Status log for alarm id in webhook4fluentd towards syslog server
- CSFOAM-15471: logs from webhook4fluentd of type log are not in harmonized logging format

## [3.4.0] - 2023-01-13
### Added
- CSFOAM-13469: [HBP v3.1.0] Helm Chart dependencies, Required ID: HBP_Helm_Umbrella_1, Desc: apiVersion has to be changed from v1 to v2
- CSFOAM-13468: [HBP v3.1.0] Changed the Anti Affinity label from failure-domain.beta.kubernetes.io/zone to topology.kubernetes.io/zone
- CSFOAM-12905: [HBP v3.0.0] made cpro changes according to named-templates Helm Best Practices & HBP_Helm_Templates_1
- CSFOAM-12907: [HBP v3.1.0] Changes for custom-labels-and-annotations requirement IDs:HBP_Helm_Annotations_1,HBP_Helm_Annotations_2, HBP_Helm_Annotations_3, HBP_Helm_Labels_5, HBP_Helm_Labels_6
- CSFOAM-12906: [HBP v3.1.0] Common_labels 1: alertmanager, restserver, Required ID: HBP_Helm_Labels_1, Desc: changes for common labels as per HBP 3.1.0
- CSFOAM-12906: [HBP v3.1.0] Common_labels 2: ksm, nodeExporter, zombieExporter, pdb, wbf, Required ID: HBP_Helm_Labels_1, Desc: changes for common labels as per HBP 3.1.0
- CSFOAM-12906: [HBP v3.1.0] Common_labels 3: server, cbur, hooks, migrate, psp, pushgateway, serviceaccount, Required ID: HBP_Helm_Labels_1, Desc: changes for common labels as per HBP 3.1.0
- CSFOAM-13661: PSA and PSP compatiblity for any k8s versions
- CSFOAM-13533: go version upgraded to 1.19.4 , base docker images upgraded , cbur update to 1.0.3-4789 and kubectl updated to v1.25.5-nano-20221226/v1.25.5-rocky-nano-20221226
- CSFOAM-13909: secompProfile support for CPRO Chart
- CSFOAM-14074: Corrected kubect centos version path to tools/centos/kubectl
### Security
### Fixed
- CSFOAM-13664: Removed hook-failed hook-delete-policy from jobs
- CSFOAM-14036: Alert Manager fails to send host information in alarm data.
- CSFOAM-13913: helm test is failing for PSA changes in restserver
- CSFOAM-13529: alertmanager docker image update
- CSFOAM-14072: Provision to configure different ports for TCP and UDP with cpro-alertmanager service
- CSFOAM-14079: Prometheus unable to scrape Nodeexporter  metrics
- CSFOAM-14077: Nodeexporter flag failure in args when Application TLS is enabled
- CSFOAM-14084: cpro-server pod is unable to come up with individual components in tls mode  
- CSFOAM-13405: update go version docker branch in generic way

## [3.3.0] - 2022-09-30
### Added
- CSFOAM-12850: Making cpro server optional in cpro chart
- CSFOAM-13099: upgrade go version to 1.18.6, Change default dockers to rocky8, containerd update to 1.6.8 in prometheus, distroless base image upgrade, updated cbura and kubectl version 
- CSFOAM-13033: upgrade client_golang version to v1.13.0 in node exporter
- CSFOAM-12513: Jetty version upgrade to 9.4.49.v20220914 in restapi
- CSFOAM-13032: Jackson databind version to 2.13.4 in reatapi
- CSFOAM-12581: remove python2 dependency from zombie exporter
- CSFS-48109: Added 65534 user to root group in all non-distro image and change default user to 65530 for all distro image 
- CSFOAM-13213: Fix for CSFS-48055 Pod and JOB prefix name does not support in CPRO 22.06
- CSFS-48109: group permission changes to mounted cm and secret files to have same permission as that of user
- CSFOAM-13320: support for JDK11 rocky8 restapi image alone with image version update

## [3.2.1] - 2022-09-08
### Changed
- CSFOAM-12718: cpro server is unable to communicate to other components in istio mode
- CSFOAM-12722: upgrade go version to 1.18.5, base docker version update, kubectl version update, fix for UT failure

## [3.2.0] - 2022-06-30
### Added
- CSFOAM-10858: [HBP v2.1.0] service-port and container port
- CSFOAM-10851: [HBP] implementation of SCC in the OpenShift
- CSFOAM-12224: DualStack support for CPRO
- CSFOAM-12217: Unit test for the cpro components
- CSFOAM-12224: Fix for duplicate targets with dualStack settings.
### Changed
- CSFOAM-10856: [HBP v2.0.0] PodDisruptionBudget
- CSFOAM-8727: [HBP v197] 2.28. deployment
- CSFOAM-8771: [HBP v197 ]Values
- CSFOAM-8680: [HBP v197] 2.27. Extended pod practices
- CSFOAM-10861: [HBP v2.1.0] automountServiceAccountToken
- CSFOAM-11556: Provision to configure alertmanager dnsconfig searches
- CSFOAM-11688: [HBP v2.2.0] [PDB] Add support of 0
- CSFS-44321: containers in cpro chart do not follow container naming convention
- CSFOAM-10857: [HBP v2.0.0] Kubernetes Versions
- CSFOAM-11712: Update CPRO charts with latest docker image
- CSFOAM-12163: Fix for CSFS-45238. Support for prometheus server backup when https is enabled
- CSFOAM-12163: Fix for CSFS-45535. failure in restore when istio was enabled
- CSFOAM-12163: Porting changes from 21.11FP1PP1 and PP2 to main branch
- CSFOAM-12163: Update base docker images, CBUR and kubectl images
- CSFOAM-12163: go version 1.18.2
- CSFOAM-11712: Update CPRO charts with latest docker image
- CSFS-44519: csf mirror maker could not be installed when integrating with csf cpro
- CSFOAM-10854: [HBP v2.0.0] Pod Security Context
- CSFS-45668: fix for cpro backup and restore issue in NCS22
- CSFS-43749: fix for CPRO pods do not follow naming convention for container name prefix for cbur-sidecar
- CSFOAM-12225: Config Map reload version upgraded
- CSFOAM-12225: go version upgrade 1.18.3
#Fixed
- CSFOAM-11737: Fix Vulnerabilities Reported in Sonarqube in REST API
- CSFOAM-10791: Fix all SonarQube issue in CSF-PROMETHEUS-RESTAPI Repo
- CSFOAM-12109: Fix Added separate BrHook apiversion template
- CSFOAM-12150: Fix Added template for certManager keysize condition
- CSFOAM-12201: Fix Added Cpro helm chart upgrade for pushgateway
- CSFOAM-12236: Fix Added CPRO Installation failing with cert-manager
- CSFOAM-12225: Fix Added Updated the docker tag by rebuilding to fix helm test issue
- CSFOAM-12320: Fix for node-exporter not coming up in OC
- CSFOAM-12322: fix for alertmanager utils container custom name
- CSFOAM-12356: fix for CSFS-46478, avoid adding podname prefix to pods when name override or fullname override is provisioned
- CSFOAM-12225: Updated the docker tags after BDH-BOM integration
- CSFOAM-12397: restserver is unable to communicate to Kubernetes in IPV6 cluster

## [3.1.0] - 2022-03-07
#Added
- CSFOAM-10909: docker optimization for prometheus
- CSFOAM-5085: Enhancing restore procedure
- CSFOAM-10045: Certmanager support for kube state metrics
- CSFOAM-10066: Certmanager support for prometheus, alertmanager, pushgateway
- CSFOAM-10075: Certmanager support for restapi
- CSFOAM-11407: fix configmap reload
- CSFOAM-11410: ImagePullBackOff for restserver
- CSFOAM-11436: update csdc version to 2.1.17
- CSFOAM-11469: Fix for CSFS-43703
- CSFOAM-11482: Chart changes in cpro for Certmanager (issue CSFS-43754)
- CSFOAM-11506: nodeexporter and kubestatemetrics Chart improvement for certmanager
- CSFOAM-11507: Pushgateway component chart improvement for certmanager
- CSFOAM-11508: Restserver component chart improvement for certmanager
- CSFOAM-11482: server Chart improvement for certmanager
- CSFOAM-12263: Implementation of emptyDir ephemeral storage for cpro
- CSFOAM-12263: Implementation of waitPodStableSeconds for cpro for cbur backup/restore
- CSFOAM-12263: Implementation of emptyDir ephemeral storage for cpro with requests set to 20Mi
- CSFOAM-12444: chart changes to use delivered docker for CPRO 22.06 release
#Fixed
- CSFS-43063: Helm lint test failing for Cpro chart
- CSFOAM-11484: Fix for CSFS-43749. support for prefix for monitoring container

## [3.0.2] - 2022-01-21
#Added
- CSFOAM-10987: istio templates renaming
#Fixed
- CSFOAM-11050: does not support custom host configurations when sharedgateway is enabled
- CSFS-42518: Possibility to configure "--metric-labels-allowlist=" in via cpro helm-chart
- CSFOAM-11129: Fix alert manager preupgrade job
- CSFS-42518: handling default values for restapi configs when sensitive data is enabled
- CSFOAM-11111: Rest server fixes for 21.11 pp2

## [3.0.1] - 2021-12-17
#Added
- CSFOAM-10820: Upgrade Base Docker image for CPRO.
- CSFOAM-10739: Dev for CSFS-40067 and CSFS-40068
- CSFOAM-10820: Upgrade Base Docker image for and use latest image.

#Fixed
- CSFOAM-10844: Fix Vulnerability reported by trivi scan.
- CSFOAM-10918: Fix for CVE-2021-44228, log4j vulnerability.
- CSFOAM-10954: upgrade log4j to version 2.16.0 for restserver
- CSFOAM-10954: update clog api version for restserver

## [3.0.0] - 2021-11-26
#Added 
- CSFOAM-9464: CSFOAM-9045 [HBP v197] 3.5. PDB adding pod-disruption-budget.
- CSFID-3548: Prometheus server changes for mvno
- CSFOAM-9779: [CPRO-Restapi] Update CPRO charts with latest docker image(jetty version and nokia csdc version were upgraded in restserver rpm due to CSFOAM-9564 and CSFLCM-7827)
- CSFOAM-9560: [CPRO][QG-Beta] 2.10 Replicas
- CSFOAM-9723: Chart changes for kubestatemetrics version upgrade
- CSFOAM-9723: Chart changes for pushgateway version upgrade
- CSFID-3548: webhook changes for mvno
- CSFOAM-9979: cpro-restserver chart changes for CSFS-35538
- CSFOAM-8108: Node Exporter version upgrade
- CSFOAM-9757: [Istio related conventions] Implementation of Istio related values in CPRO
- CSFOAM-9745: [HBP v197] 2.3. imagePullSecrets - Implementation in CPRO chart
- CSFOAM-10019: Add provision to configure alert_relabel_configs in prometheus
- CSFOAM-10071: cpro chart changes to updated all distroless images versions
- CSFOAM-8112: Image update for Prom 2.30 and Alertmanager 0.23
- CSFOAM-10083: Fix DISH vulnerabilities in RestAPI image
- CSFOAM-10042: Added the createDrForClient condition in the kubestatemetrics.
- CSFOAM-10044: Using distroless images for pushgateway and kubestatemetrics
- CSFOAM-8657: Added startupProbe for prometheus server and added podManagementPolicy to Promethus server and alertmanager STS
- CSFOAM-8769: [HBP v197] Helm hooks and activeDeadlineSeconds
- CSFOAM-10101: [CPRO][HBP v197] [REQUIRED] 2.12. Common Labels
- CSFOAM-8657: [HBP v197] 2.18. Liveness/Readiness/Startup probe
- CSFOAM-9875: [CPRO]2.24. Time consideration
- CSFOAM-10390: Chart for prom 2.30.2
- CSFOAM-8728: [HBP v197] 2.29. anti-affinity, nodeselector and tolerations- cpro
- CSFOAM-9798: Restapi enhancement to remove dependency on python and java8, base docker image update anc CBUR image update
- CSFOAM-10042: Adding the priviledge to create the headless svc for workload to include in the istio mesh
- CSFOAM-10468: provision for configuring apiVersion for brPolicy
- CSFOAM-10412: chart changes for cpro for CSFOAM-8729
- CSFS-38792: Adding support for issuerRef.group field in cert manger generated certs
- CSFOAM-10524: CSFS-28647 add priority class configurability for node exporter
- CSFOAM-10402: [CPRO][HBP v197][REQUIRED] 2.13. Labels and Annotations
- CSFOAM-10546: go version update for cpro coomponents, update base images.
- CSFOAM-10534: Port Numbers in success message for Cpro and Gen3gppxml are default
- CSFOAM-10647: Adding new scrape jobs for grafana
- CSFOAM-10572: Use the latest image for all cpro components
- CSFS-41343: mvno support to replace NA with default mvno label value
- CSFOAM-10713: GO version upgrade
- CSFOAM-10715: Istio version compare with 1.6 failed when istio version is 1.11

#Fixed
- CSFS-39778: CPRO Custom annotation values should be quoted
- CSFOAM-10077: Fix kubestatemetrics flag usage when using restriced to namespace configuration
- CSFOAM-10112: kubernetes-pods-insecure and prometheus scrape_job configuration changes and adding alert label for CPRO generated alert
- CSFOAM-10376: Unable to upgrade from previous chart version 2.16.0/2.16.1/ or any other versions
- CSFOAM-10037: Fix for MVNO bug by moving relabel config to metric_relabel_configs
- CSFOAM-10508: Fix in KSM and webhook4fluentd for crashloopbackoff with istio enabled
- CSFOAM-10080: Fix for istio proxy port CSFS-40209
- CSFOAM-10555: Fix for CSFS-32882 dup not when AM in HA, separate job for each CPRO component and IPV6 fix for scrape job
- CSFOAM-10648: Fix the liveliness and readiness probe for nodeExporter
- CSFOAM-10572: fix app version in chart.yaml
- CSFOAM-10671: Fix for alert manager non-ha deployment failure in IPv6 and Enabling restapi component by default
- CSFS-41565: Fix nodeexporter headless service name.
- CSFOAM-10746: restapi version fix

## [2.16.1] - 2021-08-20
#Added 
- CSFS-39156: Illegal number syntax: "-" in case of 2.15.1 CPRO version

## [2.16.0] - 2021-08-10
#Added 
- CSFOAM-8451: Fix for CSFS-37429 Disable automountserviceaccount in the CPRO pods
- CSFOAM-8735: Fix for CSFS-35943 Run containers with root filesystems in read-only mode
- CSFOAM-8603: VAMS:Jetty < 9.4.41, 10.x < 10.0.3, 11.x < 11.0.3 - Remote Information Disclosure Vulnerability - GHSA-gwcr-j4wh-j3cq(CVE-2021-28169):SVM-71185
- CSFOAM-8860: migrate related changes for Service Account and hooks SA
- CSFOAM-8884: Fix to make volumes independent of readOnlyRootFilesystem flag.
- CSFOAM-8959: Pods are not able to run when istio cni disabled condition
- CSFOAM-8959: Pods are not able to run when istio cni disabled condition-helm test
- CSFOAM-8724: PSP creation control in CPRO values by adding new flag.
- CSFOAM-8541: Fixing ZombieExporter HostPort issue.
- CSFOAM-8667: docker and chart changes for go upgrade - Prometheus extensions
- CSFOAM-8685: Remove grafana utilities from upro-util docker and merge tools-image into it
- CSFOAM-8813: ISU Requirement - Prometheus - Container restart observed during restore operation
- CSFOAM-8894: Creating a psp for the exporters
- CSFOAM-8991: [HBP v197][QG-Beta][CPRO] 2.9. IP address
- CSFOAM-9086: Fix for CSFS-38529 telstra security requirements
- CSFOAM-8896: PSP optimization and service account changes for exporters
- CSFOAM-9148: Chart changes for all new dockers built with GO 1.15.14
- CSFOAM-9203: Fix for vulnerebilities in restapi by upgrading version, replacing os_base image with cpro-utils and updating kubectl version
- CSFOAM-8979: Docker change to use latest go version to compile  webhook4fluentd source code 
- CSFOAM-8979: Adding comments in values.yaml for  webhook4fluentd configuration
- CSFOAM-9048: chart changes for python3 zpe rpm
- CSFOAM-9361: [CPRO][BVNF] Zombie Exporter service not coming up during deployment
- CSFOAM-9372: Chart changes to support https for restserver helm test
- CSFOAM-9381: Java base docker image version update for restapi and replace tail -f /dev/null with sleep infinity and use latest docekr which was used for BOM integration
- CSFOAM-9383: making allowPrivilegeEscalation flag configurable 
- CSFOAM-9379: Update restapi image
- CSFOAM-9387: Changing default runAsUser and fsGroup for cpro-server
- CSFOAM-9423: Create restserver SSL certificates

## [2.15.0] - 2021-06-14
#Added
- CSFOAM-8077: Alertmanager chart changes for CSFID-3371
- CSFOAM-8217: cpro rest server changes for CSFID- 3371
- CSFOAM-8047: Fix for NodeExporter for CSFID-3371(Random users)
- CSFOAM-8048: Fix for Kubestatemetrics for CSFID-3371(Random users)
- CSFOAM-8052: Fix for Zombie exporter for CSFID-3371(Random users)
- CSFOAM-8082: Pushgateway changes for CSFID-3371
- CSFOAM-8086: webhook4fluentd changes for CSFID-3371
- CSFOAM-8074: Prometheus server changes for CSFID-3371
- CSFOAM-8236: Fix for CSFS-35911 prometheus monitoring alerts flag
- CSFOAM-8247: give permission to user level for dockers of prometheus and alertmanager for CSFID-3371
- CSFOAM-8256: Fix for CSFS-35538 - cpro rest server pod not coming up with sensitive data
- CSFOAM-8344: Fix for all statefulset updateStrategy
- CSFOAM-8248: Add range in fsGroup and runAs within PSP(CSFID-3371)
- CSFOAM-8233: Fix for migrate for CSFID- 3371 and fix to support backup and restore, addding dataEncryption feature for brpolicy
- CSFOAM-8340: RPM changes for jetty version
- CSFOAM-8250: give permission to user level for dockers of other components for CSFID-3371
- CSFOAM-8357: Create new cluster role and role for prometheus
- CSFOAM-8394: change runasuser in postdelete hook of prometheus server
- CSFOAM-8463: support for dynamic changing of restapi log level
- CSFOAM-8385: Role for other components RBAC
- CSFOAM-8258: Updatating the k8s api version for ingress
- CSFOAM-8519: Upgrade from CPRO-2.11.0 to CPRO-2.15.0-18 is failing due to webhookfluentd
- CSFOAM-8523: cpro-2.15.0-19 restserver GET & POST request fail when istio is enabled
- CSFOAM-8528: cpro-2.15.0-19 Rolebinding is not created for alertmanager and pushgateway when restricted namespace is disabled
- CSFOAM-8536: configurability of runAs user & fsgroup as well as volume type as part fo data migration of prometheus server from non HA to HA
- CSFOAM-8371: Upgrading GO version to 1.15.12 to fix vulnerability CVE-2021-31525.
- CSFOAM-8469: Backport fix in source code for prometheus web/web.go to fix vulnerability CVE-2021-29622
- CSFOAM-8506: Supporting host name for rest server ingress.
- CSFOAM-8525: removal of init chown containers
- CSFOAM-8518: Upgrading Zombie Exporter to python 3
- CSFOAM-8575: Fix for restserver ingress TLS

## [2.14.0] - 2021-04-12
#Added
- CSFOAM-7201: Fix , Test and Test automation for CSFS-32585
- CSFOAM-7413: Fix for alertmanager pod goining into crash in ipv6 and HA configuraion(CSFS-33539)
- CSFOAM-7192: Helm built in objects needs to be resolved on extraconfigmap mounts and extraSecretMounts for Prometheus server.
- CSFOAM-7372: Fix for Disk Usage Alerts
- CSFOAM-7537: Changes for fix of CSFS-33859
- CSFOAM-7573: Configure progressDeadlineSeconds for deployment in values.yaml
- CSFOAM-6519: alert for prometheus pvc disk for CSFS-31370
- CSFOAM-6080: Error in logs of kube-state-metrics pods for PodDisruptionBudget
- CSFOAM-7665: Removing extra space in _helper.tpl
- CSFOAM-6199: Istio ingress section tls.enabled in CPRO for pushgateway and restserver set as False
- CSFOAM-7535: [CPRO][K8s best practice][labelling] - cpro chart
- CSFOAM-7721: configure nodeSelector/tolerations/affinity in Jobs/Pods for CPRO chart
- CSFOAM-7585: compass changes and individual threshold for Alerts
- CSFOAM-7740: rebuilt dockers with latest base docker image
- CSFOAM-7734: update jetty to 9.4.38.v20210224 and kubernetes-client 4.13.2 in restapi 
- CSFOAM-7796: CPRO-nodeExporter scrapping metrices in tls mode (CSFS-33983)
- CSFOAM-7809: Updated Monitoring container docker image tag
- CSFOAM-7849: cpro helm chart changes
- CSFOAM-7943: istio-version upgrade in cpro chart
- CSFOAM-7894: Fixed COMPAAS installation issue
- CSFOAM-8012: Fix for CSFS-35899, kubestate metrics scrape issue in compaas
- CSFOAM-8505: unable to perform POST in restserver
- CSFOAM-8507: webhook4fluentd when enabled has to bind to "view" clusterlevelrole

## [2.13.0] - 2020-12-25
#Added
- CSFOAM-6711: Helm built in objects needs to be resolved on extraconfigmap mounts and extraSecretMounts for Prometheus server.
- CSFOAM-6805: Upgrade prometheus, pushgateway to 2.23.0 and 1.3.0 versions. Takes care of CSFS-30617,CSFS-30204
- CSFOAM-6480: Sensitive data encryption for secrets
- CSFOAM-6974: To support unique external labels per pod CSFS-28523
- CSFOAM-6998: support for cni disabled in istio for cpro charts
- CSFOAM-7025: update base docker image and fix helm3 lint errors
- CSFS-32060: Added livenessProbe configuration in alertmanager
- CSFOAM-7085: Chart changes for restapi sensitive data
- CSFOAM-7139: CPRO installation is failing when restserver is enabled
- CSFOAM-7141: Fixed CPRO installation failing issue in COMPAAS cluster
- CSFOAM-7159: Remove tab
- CSFOAM-7157: CPRO 2.13.0-13(restserver) - Pods are not coming up when sensitive data secret is configured
- CSFOAM-7163: chart version upgrade

## [2.12.0] -2020-11-16
#Added
- CSFOAM-6439: Detect and alert user incase of prometheus wal corruption
- CSFS-30204: cpro-server size based retention is not working when switching to run container as non-root 
- CSFOAM-6575: Detect and alert user incase of prometheus wal corruption - Part 2
- CSFOAM-6569: VAMS:Jetty ≤ 9.4.32v20200930 - Local Privilege Escalation Vulnerability - GHSA-g3wg-6mcf-8jj6(CVE-2020-27216):SVM-60228
- CSFOAM-6524: Updated restapi imageTag to 3.3.5

## [2.11.0] - 2020-10-01
#Added
- CSFS-28336: Option to disable consistency check in pushgateway (cpro v2.7.2)
- CSFS-28114: CPRO should provide support for cbur autoUpdateCron parameter in BrPolicy
- CSFS-22054: BCMT ETCD metrics cannot be scraped by Prometheus without root access
- CSFOAM-6233: CSFS-27347 prometheus changes to move it inside istio service mesh
- CSFOAM-6171: alertmanager and rest-server chart changes to fix CSFS-27259
- CSFOAM-6280: cpro-server , kubestatemetrics and pushgateway chart changes to fix CSFS-27259
- CSFOAM-6282: exporter,migrate and hooks chart changes to fix CSFS-27259
- CSFOAM-6217: Add web.listen-address: ":9100" to extraargs of nodeExporter
- CSFOAM-6247: helm test is failing when CPRO is deployed in HA mode 
- CSFS-26805: Handling WAL Corruptions
- CSFOAM-6287: Creating 20.08 version of readme.md for cpro
- CSFS-28997: Delete Policy for Helm Test for CPRO Server
- CSFOAM-6300: Update image tag and change registry to candidates
- CSFOAM-6310 - CPRO changes to scrape node exporter and zombie exporter with default configuration with istio feature enabled

- CSFOAM-6370: updating readme.md for cpro

## [2.10.0] - 2020-09-01
#Added
- CSFS-25109: CPRO chart has dependency on K8s version
- CSFS-25970: Specify resources for all containers
- CSFOAM-5936: HELM3 non-ha to ha upgrade , with same version of chart failed (cpro-2.7.3-14)
- CSFOAM-5971: Fix for Unable to change alert rules dynamically with istio and prefixURL usage
- CSFS-27188, CSFS-27192: istioVersion as integer and readiness probe fails in Istio 1.5 with Openshift
- CSFS-27378: scrape_config to gather metrics from https endpoints

## [2.9.0] - 2020-07-16
#Added
- CSFS-26495: Support to provide option for global.istioVersion

## [2.8.0] - 2020-07-14
### Added
- ISTIO certificate update to credentialName
- CSFS-21679: CPRO: Helm Port Istio-Style Formatting
- CSFOAM-5546: Added MCS label,seccomp and apparmor annotation
- CSFOAM-5675: Added Restricted to namespace flag for server and restserverv components
- CSFOAM-5534: Affinity/Anti affinity rules for cpro restserver and pushgateway components
- CSFOAM-5550: istio single gateway configuration, destination rule and policy 
- CSFOAM-5551: istio changes for peer authentication
- CSFOAM-5793: configuring role,rolebinding for istio
- CSFOAM-5855: docker image update and istio-mutual support
- CSFOAM-5857: Incorporated helm best practices
- CSFOAM-5863: pushgateway uri configuration & alertmanager statefulset.
- CSFOAM-5882: match label for peerauthentication
- CSFOAM-5884: Fixed helm backup issue
- CSFOAM-5886: Fixed Node-Exporter and Zombie-Exporter helm lint issue
- CSFOAM-5923: Fixed SecurityContext issue
- CSFOAM-5893: Reverted server serviceName back to server-headless
- CSFS-23095: Added Global serviceAccountName

### Changed
- - CSFOAM-5875: Helm Test Changes for CPRO and Restapi
- CSFOAM-5892,5894,5897,5921,5935: Istio bug fixes

## [2.7.2] - 2020-05-15
### Added
### Changed
- CSFS-24437: cpro-node-exporter container host volume mounts are not updating

## [2.7.1] - 2020-05-11
### Added
- CSFS-21679 - Reverting the tcp-cluster in alertmanager to retrieve the port from values.yaml

## [2.7.0] - 2020-05-11
### Added
- All future chart versions shall provide a change log summary
- CSFS-21679 - Helm Port Istio-Style Formatting
- CSFS-18070 - CPRO is only collecting node metrics on worker nodes.  Control and Edge nodes have no statistics.
- CSFS-21858: Configured wal compression flag
- CSFOAM-5321: Removed invalid baseUrl value
- CSFS-15670: SecurityContext updated for NodeExporter
- CSFOAM-5316: Updated cpro components docker image tags
- CSFOAM-5315 - Upgraded Prometheus, Alertmanager, Node Exporter and Pushgateway to the latest versions
### Changed
- Modify test script, add chart name
- Disable NodePort 31000
- Rebuild docker image with latest CentOS-mini:latest

## [2.5.0] - 2020-03-20
### Added

## [2.4.2] - 2020-03-14
### Added
- CSFS-21684 - CPRO Helm3 K8s 1.17 Changes

## [2.4.1] - 2020-03-05
### Added
- Updating the semverCompare condition for helm3 upgrade

## [2.4.0] - 2020-03-13
### Added
- Support for ipv6 for alert-manager
- Added environment variable to take k8s server url for ipv6
- Updated to remove the deprecate K8S APIs

## [2.2.15] - 2019-10-30
### Added
- Can specify storageClass name when Prometheus/Alertmanager is deployed in HA mode

## [2.2.14] - 2019-10-22
### Fixed
- ZombieProcessExporter should use non-root

## [2.2.13] - 2019-10-22
### Changed
- CSFOAM-4695: Non-root for all Prometheus components
- Use new version 2.0.3 for Prometheus RestAPI Server

## [2.2.12] - 2019-10-14
### Changed
- CSFS-9972: Update README.md
- CSFS-16413: Add param "ignoreFileChanged: true" in BrPolicy and change cbur image version from 637 to 983

## [2.2.11] - 2019-09-26
### Fixed
- CSFS-17048: CPRO uses latest tag for init-chown-data container

## [2.2.10] - 2019-09-26
### Fixed
- (sync with 2.3.0)CSFS-16574: Use Cinder Volume for Prometheus-backup folder
### Changed
- (sync with 2.3.1)CSFS-15040: CPRO alerts should have unique names

## [2.2.9] - 2019-09-23
### Added
- CSFS-16805: Add toleration for CPRO restserver

## [2.2.8] - 2019-09-11
### Changed
- CSFOAM-4183: New CPRO Backup/Restore method running on ComPaaS
- Alertmanager can set retention time now
- Use new kubectl image for post-delete job
### Fixed
- On ComPaaS environment, Prometheus HA post-delete job stucks

## [2.2.7] - 2019-09-03
### Changed
- CSFS-16095: Add service of CPRO server with cluster ip for external access
- CSFS-9906: cpro-server headless service incorrect port

## [2.2.6] - 2019-08-28
### Fixed
- Fix CSFS-14867
### Changed
- Use new restapi image 2.0.2

## [2.2.5] - 2019-08-28
### Fixed
- Fix CSFS-15670

## [2.2.4] - 2019-08-27
### Added
- CSFS-15521: Add NodePort in Pushgateway service
- CSFS-12715: Add livenessProbe and readinessProbe for Prometheus server
### Fixed
- CSFS-13963: Alertmanager Ingress in HA
### Changed
- CSFS-9972: Update README.md

## [2.2.3] - 2019-08-26
### Fixed
- Fix one typo which may lead to incorrect volume mount in server-statefulset.yaml

## [2.2.2] - 2019-08-26
### Fixed
- CSFS-15978: deploy the latest cpro-2.1.9, one container of cpro-restserver pod failed

## [2.2.1] - 2019-08-22
### Changed
- Use new docker image (prometheus:v2.11.1-3) built based on nano, with curl in it

## [2.2.0] - 2019-08-22
### Changed
- Use new docker image built based on nano
- Use new Prometheus version v2.11.1
- Use new Pushgateway version v0.9.1

## [2.1.9] - 2019-08-13
### Changed
- RestAPI server image version update to 2.0.1

## [2.1.8] - 2019-06-28
### Fixed
- RestAPI server in Chart 2.1.7 cannot rollback to 2.0.27

## [2.1.7] - 2019-06-27
### Fixed
- RestAPI server in Chart 2.1.7 cannot rollback to 2.0.27

## [2.1.6] - 2019-06-24
### Added
- (synced with 2.0.27)Now CPRO Helm chart can be deployed on ComPaaS > 18.11

## [2.1.5] - 2019-06-20
### Changed
- (synced with 2.0.24)Prometheus storage.tsdb.path now use different value with PersistentVolume
- (synced with 2.0.26)Add a pre-restore hook function to avoid time overlap during restore

## [2.1.4] - 2019-06-18
### Fixed
- One switch by default set to false

## [2.1.3] - 2019-06-11
### Added
- CSFOAM-3791 Integrate with new version of RESTAPI
### Changed
- File structure of CPRO Helm chart template folder

## [2.1.2] - 2019-06-10
### Changed
- CSFOAM-3983 Parameterized CBUR setting change variable name
- CSFOAM-3986 CPRO non-ha to ha upgrade

## [2.1.1] - 2019-05-27
### Changed
- CSFOAM-3983 Parameterized CBUR setting
- CSFS-13228 configure containerPort and targetPort of NodeExporter

## [2.1.0] - 2019-04-26
### Changed
- Use Prometheus new version v2.9.1
- Use new version of NodeExporter, Pushgateway, Alertmanager and Kube-state-metrics

## [2.0.27] - 2019-06-20
### Added
- Now CPRO Helm chart can be deployed on ComPaaS > 18.11

## [2.0.26] - 2019-06-16
### Fixed
- Wrong container name in pre-restore hook function

## [2.0.25] - 2019-06-15
### Changed
- Add a pre-restore hook function to avoid time overlap during restore

## [2.0.24] - 2019-06-12
### Changed
- Prometheus storage.tsdb.path now use different value with PersistentVolume
- Support data migration from non-HA to HA

## [2.0.23] - 2019-06-05
### Changed
- CSFOAM-3983 Parameterized CBUR setting change variable name
- Resources for restapi container doesnt effect

## [2.0.22] - 2019-05-27
### Changed
- CSFOAM-3983 Parameterized CBUR setting
- CSFS-13228 configure containerPort and targetPort of NodeExporter

## [2.0.21] - 2019-04-26
### Changed
- Add resource limits

## [2.0.20] - 2019-04-26
### Changed
- Rebuild docker image with latest CentOS-mini:latest

## [2.0.19] - 2019-03-20
### Changed
- Add alertmanagerWebhookFiles
CSFS-11436: CPRO: cannot customize my webhook4fluentd

## [2.0.18] - 2019-03-19
### Changed
- Add alertmanagerWebhookFiles
CSFS-11436: CPRO: cannot customize my webhook4fluentd

## [2.0.17] - 2019-03-18
### Added
- Alert rule now include one label "host"
- Providing a way to add custom Prometheus job, can do overwrite by Helm install
### Fixed
- Job "prometheus-nodeexporter" also need to do relabel for providing kubernetes_io_hostname

## [2.0.16] - 2019-03-14
### Changed
- Update restserver imageTag from 1.1.0 to 1.1.1

## [2.0.15] - 2019-03-13
### Changed
- Alertmanager service and ext-service use different annotation

## [2.0.14] - 2019-03-11
### Changed
- Change default ha value to false

## [2.0.13] - 2019-02-26
### Changed
- Update imageTag of configmap-reload from v0.1 to v0.1.1

## [2.0.12] - 2019-02-24
### Added
- Alertmanager webhook support TLS as output
### Fixed
- Kubernetes_sd_config wrongly remove endpoints

## [2.0.11] - 2019-02-19
### Added
- Label "source" in default alert definition

## [2.0.10] - 2019-01-31
### Fixed
- Fix Comments has Chinese characters 

## [2.0.9] - 2019-01-30
### Fixed
- Fix one issue in template/test/config.yaml to adapt ComPaaS change

## [2.0.8] - 2019-01-30
### Changed
- Change the livenessProbe and readinessProbe Request type of restserver

## [2.0.7] - 2019-01-29
### Fixed
- Move alert rules from serverRules to serverFiles

## [2.0.6] - 2019-01-29
### Fixed
- Fix for CSFS-9767: update webhook4fluentd image and job get hostname

## [2.0.5] - 2019-01-28
### Fixed
- Move alert rules from serverRules to serverFiles

## [2.0.4] - 2019-01-25
### Fixed
- Fix image.imagePullPolicy does not take effect [CSFS-9932]

## [2.0.3] - 2019-01-21
### Fixed
- Fix alter rules error

## [2.0.2] - 2019-01-21
### Added
- Add prometheus-restserver

## [2.0.1] - 2018-12-28
### Changed
- Changed sd_configs of server and node exporter to endpoints

## [2.0.0] - 2018-12-28
### Changed
- Add HA support for aletermanager and server
- Add zombieProcessExporter and webhook4fluentd
- Add Multi-tenancy support
### Fixed
- Removed lots of unexisting scrape targets

## [1.2.9] - 2018-11-29
### Changed
- Apply global relocation
### Fixed
- Change back to ClusterIP from NodePort

## [1.2.8] - 2018-11-21
### Changed
- Modify test script, add chart name

## [1.2.7] - 2018-11-13
### Added
- Insert namespace label for metrics.

## [1.2.6] - 2018-11-1
### Fixed
- Prometheus can find Alertmanager in same Helm release.

## [1.2.5] - 2018-10-21
### Changed
- Changed node_exporter and pushgateway docker image tag.

## [1.2.4] - 2018-09-29
### Added
- Add Backup/Restore

## [1.2.3] - 2018-08-29
### Added
- Delivered a new helm chart cpro-1.2.3
- Add ut tests into templates
- Set rbac.create=true in values.yaml

## [0.0.0] - YYYY-MM-DD
### Added | Changed | Deprecated | Removed | Fixed | Security
- your change summary, this is not a **git log**!

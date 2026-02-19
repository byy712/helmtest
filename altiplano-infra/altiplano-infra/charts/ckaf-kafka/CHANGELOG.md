# Changelog
All notable changes to chart **ckaf-kafka** are documented in this file,
which is effectively a **Release Note** and readable by customers.

Do take a minute to read how to format this file properly.
It is based on [Keep a Changelog](http://keepachangelog.com)
- Newer entries _above_ older entries.
- At minimum, every released (stable) version must have an entry.
- Pre-release or incubating versions may reuse `Unreleased` section.

## [Unreleased]
### Added
- incubating example only
### Changed
- incubating example only - behavior changed
### Deprecated
- incubating example only - existing behavior deprecated
### Removed
- incubating example only - existing behavior deleted
### Fixed
- incubating example only - buggy behavior fixed
### Security
- incubating example only - security vulnerability fix

## [8.0.2] - 2024-02-20
### Changed
- Image tag update
- Image tag update
- Image tag update

## [8.0.1] - 2024-01-10
### Changed
- Image tag update
- Image tag update

## [8.0.0] - 2023-12-08
### Changed
- Removal of socat from healthcheck[CSFS-55222].
- HBP 3.6.0 - Introduced enableDefaultCpuLimits flag which disables cpu resource limit by default.
- imageTag update.
- ImageTag update
- Image tag update
- Image tag update

### Added
- csfid-4406 modifications
- ImageTag update
- uktsr 8.1 and 8.5 support ALERT level log message. 


## [7.6.1] - 2023-10-31
### Changed
- Image tag update
- Image tag update
- Image tag update

## [7.6.0] - 2023-09-30
### Changed
- docker Image tag update
- docker Image tag update
- Image tag update
- Image tag update
- Jmx docker image tag update
- Image tag update

### Added
- support for PEM certificates[CSFID-4405].
- ckaf utility container resources made configurable
- loadbalancer service for kafka[CSFID-4350].
- HBP 3.5.0 (Introduced flatRegistry, helm chart will have one registry instead of multiple registries)

## [7.5.1] - 2023-07-21
### Fixed
- helm test fix [CSFS-54006,CSFS-54079]
### Changed
- Image tag update

## [7.5.0] - 2023-06-30
### Added
- Delivered image tag update
- Node Selectors for hook pods [CSFS-51604]
- HBP3.4 imagepull secrets.
- removed -it from kubectl exec command [CSFS-53192]
- Fix for pause containers [CSFS-53165]
### Changed
- imagetag update
- Fix for CSFS-50274
- Docker image tag update for java 17 and docker image size reduction
- Docker image tag update
- dependency Chart Update.
- HBP3.3 Pod topologySpreadConstraints

## [7.4.3] - 2023-07-13
### Fixed
- dos2unix fix for dashboard json 
- helm test fix
### Changed
- updated the chart version for promotion to stable repo.


## [7.4.2] - 2023-05-12
### Changed
- Image tag update, fix for [CSFS-52537 and CSFS-52432 ]
- dependency Chart Update.
- Image tag update
- Image tag update
### Added
- CustomContainer name and prefix for kafka-init [CSFS-52688]
- Merging syslog paramters defined at global and workload level[CSFS-52815].

## [7.4.1] - 2023-04-13
### Changed
- Aligning syslog parameters to HBP standards.
- fix for [CSFS-50274]
- Image tag update

## [7.4.0] - 2023-03-18
### Added
- Unified logging extensions [CSFID-4059]
- New limited metrics file added [CSFID-4092]
- Pod topologySpreadConstraints [CSFS-49130]
- Configurable ssl cipher suites.
### Changed
- Include headless service in the SAN entries[CSFS-49303]
- Image tag update
- Image tag update
- Image tag update

## [7.3.3] - 2023-02-14
### Changed
- Helm Test fix for [CSFS-51026]

## [7.3.2] - 2023-02-10
### Changed
- Image tag update

## [7.3.1] - 2023-01-18
### Changed
- Image Tag update.
- configure per broker svc with dual stack
- Image Tag update.

## [7.3.0] - 2022-12-16
### Changed
- Image Tag update.
- support for k8s 1.25
- cert-manager removed common name[CSFS-49857].
### Added
- support for Generic ephemeral volume
- Support for openshift routes.
- Image tag update
- seccomp changes
- Image tag update

## [7.2.2] - 2022-11-11
### Changed
- zookeeper heap configurable.[CSFS-49003]
- Image tag update
- Image tag update

## [7.2.1] - 2022-09-30
### Changed
- Image Tag update

## [7.2.0] - 2022-09-23
### Changed
- pre,post restore- sed command change to kubectl patch.
- HBP 3.0.0 Named template
- Fix for labels in virtual-service and gateway
- Custom annotations and labels
- Fix for trim issue
- Image Tag update to min image
- Image Tag update - Fix for SASL with min Image
- hostAliases changes
- Image Tag update
- Include namespcae in the host section of clog format[CSFS-47917]
- Image Tag update
### Added 
- Support for multiple citm instances [CSFID-3995]
- Istio support for external access [CSFID-3985]
- Version Upgrade Docker and Repo URL change
- SysLog support for kafka.

## [7.1.0] - 2022-06-30
### Added
- make istio side car ports used for healthcheck configurable, fix for CSFS-44646
- External listener service name configurable per broker(ADL).
- named template changes for common functions
- Dual stack changes.
- emphemeral storage limits/requests configurable [CSFID-3996]
### Changed
- Cbur API version update to cbur.csf.nokia.com/v1.
- cert manager support for v1 api version.
- HBP part-of change
- cbur image update.
- timeZoneName to timeZoneEnv [HBP-Time consideration]
- Docker image update and registry to delivered.

## [7.0.1] - 2022-05-19
### Added
### Changed
- kubectl, jmx and cbura image update.
- Fix for CSFS-45161. Taints/Toleration enhancement.
- updated zookeeper version to latest
- Remove external image references in chart notes.
- docker image with base image update.

## [7.0.0] - 2022-04-08
### Added
- PriorityClass support for statefulset. 
- Added autoMountServiceAccountToken
- Docker image tag update
- update api groups for CSFP env
- Docker image tag update
### Changed
- Docker Image Tag Update
- Fix for CSFANA-32091 - Restore enhancement
- /var/log emptyDir volumeMount
- Helm Best Practice 2.1.0 , PodDisruptionBudget changes(added maxUnavailable and pdb flag)
- fix for zstd compression format with readOnlyRootFileSystem.
- Chart.yaml API version updated to v2 helm3 support.
- requirements.yaml merged to Chart.yaml for helm3 integration.
- helm test hook annotation updated.
- Fix for custom service Account name.
- k8s 1.22 semver changes.
- PodDisruptionBudget(revert userinput validation for scale fix )
- fix for certLoader
- update apigroups
- Kafka scale enhancements.
- Version Upgrade [docker image tag update]

## [6.1.0] - 2021-12-21
### Added 
- support for TLS1.3
- support for multiple external listeners . CSFS-39902
- add "readOnlyRootFilesystem" flag per container level.
### Changed
- PodDisruptionBudget podname prefix in zk chart.Fix for CSFANA-31525
- Helm Best Practice,timezone [CSFS-41458].
- conditions for pre-restore,post-restore,BrPolicy,Cbur-cm. CSFS-41478
- helm test enhanced [CSFS-40954].
- update zookeeper version
- fix for external listener svc name
- Update imageTag to latest
- fix for transportingress for external listener
- image Tag update
- fix for ingressconfimap for external listener for istio
- istio peer authentication check enhanced. [CSFS-41592]
- tls flag defaults to  enable.
- multiple listeners istio mtls fix [CSFS-38087]
- Restore jobs readOnlyRootFilesystem fix
- image Tag update

## [6.0.0] - 2021-09-30
### Added
- Adding  failureThreshold and periodSeconds. Fix for CSFS-37700
- kafka helm chart with cert-manager support.
- Pod Disruption Budgets for kafka. CSFID-3654
- support for cbur.autoEnableCron parameter. CSFS-39521
### Changed
- Update incubator chart version and registry to candidates.
- mountSSL secrets on to kafka broker container.
- update imageTag to latest.
- update imageTag
- istio-ingress fix CSFS-38087
- update repository
- update imageTag after version upgrade
- fix for kafka scale issue CSFANA-29921
- post-delete job fix
- Pod Disruption Budgets ApiVersion Change.
- helm toolkit annotation value converted to string in helpers function.
- ckaf-reassign-partition script to use --bootstrap-server instead of --zookeeper
- promotion to delivered.

## [5.1.1] - 2021-09-07
### Changed
- updated image tag for vulnerablities fix.
- image tag update and chart promotion.

## [5.1.0] - 2021-05-28
### Changed
- ckey secret mandatory only when the internal protocol is set to SASL.
- Updated imageTag and registry to docker-candidates.
- imageTag update
- Random user support.
- imageTag Update and minor fix for init container
- post-delete job rules changes.
- jmx imageTag update
- image tag update and chart promotion.
### Added
- Helm Best Practice [Customized Labels]

## [5.0.0] - 2021-03-26
### Added
- variable to set timezone,CSFS-31394
- Helm Best Practice [k8s best practice labeling],CSFANA-24506 
- Helm Test Fix.
- Istio Test ,CSFS-31234
- Container Name/Pod Name Prefix for Helm Test 
- Option to choose ConfigMap/TransportIngress for ingress.
- CSFS-34568 [Helm Annotations - istio proxy annotations]
### Changed
- Helm Best Practice [Role/Rolebinding]
- Helm Best Practice [ IP Address]
- Zookeeper requirements.yaml update
- seccompAllowedProfileNames and seccompDefaultProfileName values to runtime/default
- pre/post upgrade jobs enhanced to denote the status of upgrade
- readOnlyRootFs fix
- pre-rollback jobs service account.
- changed values-model.yaml file
- RBAC fix for csfp - CSFS-35196.
- changed values-model.yaml log.retention.bytes
- pre-deletejob and rbac fix for rollback CSFS-35196.
- pre-rollback job fix to handle oeprator to helm rollback.
- Docker image tag update to delivered

## [4.1.0] - 2021-01-27
### Changed
- Docker image tag update [centos7]

## [4.0.0] - 2020-12-24
### Changed
- Docker image tag update to delivered

## [3.3.0] - 2020-12-11
### Added
- Fix for CSFS-31206 -CBUR
- Fix for CSFS-30511
- Fix for CSFS-31007 .Resource Quota for init container added
- Docker image tag update [centos8]
- Added pre-rollback job for operator compatbility along with service accounts .
- Fix for CSFS-30600.Changed Volume mount path for keystore and truststore.
- ISTIO 1.6.8 support.
- Change group name of connector CR for roleback role.
### Changed
- Cbur enable flag removed from global level.
- Fix for citm configmap naming convention with name overrides
- Docker image tag update kafka-init
- Docker image tag update [Vesrion upgrade 5.5.2]
- Namespace field change in per-broker-svc-entry template

## [3.2.0] - 2020-10-30
### Added
- Container Security changes.
- Added annotation for reloader
### Changed
- Fix for CSFS-29508
- preheal changes for rollout restart
- docker image tag update and zookeeper dependency  update.

## [3.1.0] - 2020-09-29
### Added
- Helm Best practice [Helm Test]
- Helm best practice [PodName and ContainerName Prefix ,jobname,job container name configuration] ,CSFS-27255
### Changed
- Docker Tag and chart version updation.
- TransportIngress CRD usage for ingress support.
- Jmx enabled flag. Fix for CSFS-28567
- Istio default values change.
- Revise documentaion for ckaf-kafka helm chart/values.yaml
- Kubectl tags updation
- docker image tag update and zookeeper dependency  update.

## [3.0.3] - 2020-09-01
### Added
- Helm Best practice [Ip Address : Making domain name configurable]
- Helm Best Practice [Chart Compliance to helm and k8s Versions]
- Helm Best Practice [Time consideration]
- Istio support for kafka ingress.
- CentOS 8 
- Helm Best Practice for kafka istio.
### Changed
- Updated Kafka post restore command
- Helm Best Practice [imagePullPolicy : IfNotPresent] 
- Helm Best practice [Changed chart maintainers]
- Hidden Files to be Used for Secrets
- Helm Best practice [StorageClassName]
- Helm Best Practice [Service related convention: Configurable kafka and zookeeper port],CSFS-26629.
- Kafka jmx port made configurable, CSFS-26439.
- Helm Best Practice [RBAC: RBAC enablement flag]
- Helm Best Practice [Values: Use a hierarchy, not a prefix/suffix]
- Docker image tag update fix for external listener with SASL.
### Removed
- TLS 1.0 from Issue-vulnerability for external kafka access,CSFS-26900
- Individual service account creation for upgrade and rollback


## [3.0.2] - 2020-07-07
### Changed
- cbur image tag update to latest for clair scan fix.

## [3.0.1] - 2020-07-01
### Changed
- kafka scale feature via upgrade jobs support.
- update the jmx image to latest.

## [3.0.0] - 2020-06-30
### Changed
- Kafka Scale fix on docker side. 
- Version Upgrade of kafka (v5.4.1)
- Removed ClusterIP Service - CSFS-23682
- External RBAC Support 
- ServiceAccount Variable Name Change - NameOverride Fix
- Krb5.conf as configmap instead of base64 value
- enable zk acl authorizer configurations.
- MCS labels
- ckaf-kafka charts with istio mtls
- fix for pvc cleanup upon scale in.
- Docker image tag change to latest delivered, update the dependent chart to latest stable.

## [2.0.0] - 2020-03-31
### Changed
- Docker Tag Change to Reflect Centos8,python3,Java11 upgrade
- Keytabs removal from chart.
- Helm3 Compliant
- Heal enhancement for Kafka component.
- Reverting back to centos7 . Docker Tag Change to Reflect the same.
- Istio Port Name Changes and annotation addition
- Deduplication of parameters in sts
- Istio changes in zk from listenonallips to ports exclusion
- Docker image tag change to latest delivered, update the dependent chart to latest stable.

## [1.6.7] - 2019-12-17
- configuration overrides flexibility added.
- add the generic service.
- configurable readiness and liveness probe timeouts.
- update the charts with the latest docker images and registry to candidates. 
-  update the charts with the latest docker images and registry to delivered.
## [1.6.6] - 2019-10-29
### Changed
- Fix for deletion of other application resource/pods due to incorrect kubectl delete command (BUG-CSFANA-14847) 
- CBUR changes implemented
- Fullname override feature code is implemented.
- Revertig the cross-upgrade code from kafka.
- Compass code modifications.
- Values model file change for cbur 
- Taking latest nano base image 1.8.0.222.centos7.6-20190801-2
- Added Prometheus annotations in service-headless file
- corrected docker image tag
- Changes for supporting user provided keytabs in kafka pods.
- Configurable number of ZK in Compass
- CSFANA-18429 Replace mv command with cp 
- Ingress for kafka CSFID-1967, with configurable external service names.
- update base docker image to 1.8.0.222.centos7.7-20190927 and VAMS fix
- fix for VAMS bug CSFANA-18533(related to sudo)
- SASL and SSL Parameters for Compass
- Base Image change for clair bug.
- Base Image change for clair bug.(re-do)
- docker image update with java base image update & requirements.yaml with zookeeper chart version
- docker delivered image and dependant stable chart updates for 19.10 release preparation 

## [1.6.5] - 2019-08-02
### Changed
- CSFS-12838 zkConnectUrl change to use zookeeper service and liveness readiness changes.
- Updated krb section of zookeeper in values.yaml for CSFS-12838.
- Java based nano image (CSFANA-13645 docker image tag change)
- Support for 3 Step Upgrade Procedure
- 19.07 delivery with Pre & post upgrade hooks disabled
- VAMS FIX (docker tag change CSFANA-14671)
- moving charts to stable 

## [1.6.4] - 2019-07-08
### Changed
- Kafka ERROR log level change

## [1.6.3] - 2019-06-21
### Changed
- Fullname override changes for Kafka.
- Exposed taint toleration parameter for zookeeper in values.yaml
- Node port support for kafka CSFID-1967 
- Added Per broker service creation yaml and configmap creation citm 
- Docker image tag change
- For Taint toleration and nodeLabel feature removed curly braces and gave reference example
- Made JmxExporter port generic in service files for kafka
- Fix for upgrade failure
- Fix for deploy failure
- reverting back fullname override changes
- For nodeSelector removed angaular brackets from example and provided example in comment
- Delivery 19.06

## [1.6.2] - 2019-06-02
### Changed
- readiness and liveness probe improvement
- changes in password-like fields in values-model.yaml format as password (CSFS-9850)
- change of attribute auto_remove_kf_secret to false (CSFS-9850)
- support for taints and tolerations
- Docker image tag change as per (CSFANA-13422)
- Docker image tag change as per rhel licensing issue.
- Moving artifacts to delivered

## [1.6.1] - 2019-04-09
### Changed
- clogEnable to true
- updated requirements.yaml
- Taking latest docker which has fix for clair vulnerability
- Docker image updation for 19.04 release
- Moving to delivered repo

## [1.6.0] - 2019-04-02
### Added
- Version Upgrade (CSFKAF-1510).
- Security gap fix for kafka  (CSFKAF-1526).
- Bug fix for CSFKAF-1757. Removed all hardcoded imagetag from values-template.yaml.j2
- updated zookeeper chart version
- Latest Docker Image Update for 19.03 release (CSFKAF-1804)

## [1.5.12] - 2019-02-28
### Added
- Added a new parameter zookeeperSetAcl in values.yaml to restrict unauthorized access to kafka from kafka manager
- Docker image 1.6.0-2.0.0-1151
### Changed 
- Bug fix for kafka scalein issue (CSFKAF-17).

## [1.5.11] - 2019-02-01
### Removed
- The imageTag of zookeeper in kafka values.yaml (CSFS-10148)

## [1.5.10] - 2019-02-01
### Changed
- Changed the imageTag of  zookeeper in values.yaml (CSFS-10148)

## [1.5.9] - 2019-01-31
### Added
- Added a new folder named dashboard which contains kafka metrics dashboard and node metrics dashboard which should be imported into grafana(CSFBANA-8274).
- Added ConfigMap for Jmx (CSFBANA-8277)
- Added autoPvEnabled to check if volumes are precreated then bind them to pods (CSFS-8360)
- Added selector in volumeClaimTemplates to bind pods to the specific labelled PVs (CSFS-8360)
### Changed
- Rbac updates for ComPaaS.(CSFS-9093)
- Changed the LogLevel (CSFS-9651)
- Changed nodeLabel , made it generic where the users have to give their own nodeType, which is a key value pair (CSFBANA-8472)

## [1.5.8] - 2018-12-27
### Changed
- sasl change
- Changed the kafka docker version to 1.4.0-2.0.0-880.
- Fixed deletion of kafka by deleting statefulset and pod(CSFS-8623)
- Fixed kafka scale in/ scale out issue if throttle value is large
- Change name of hooks,job,service-account,rolebindings to be unique (CSFS-9098).

## [1.5.7] - 2018-11-30
### Added
- Added nodeSelector in statefulset.yaml(CSFID-1747)
- Fix for CSFS-8292,lo4j.properties log volume mount utilization
### Changed
- Taking docker image from delivered(CSFBANA-7737)
- In values-template.yaml.j2 taking throttle value from values-model.yaml(CSFBANA-7737)

## [1.5.6] - 2018-11-20
### Added
- Pre rollback and pre delete hook(CSFS-7634)
- forceUpgrade, prepareRollback and enableRollback flag in values.yaml(CSFS-7634)
### Changed
- Changed pod management policy to OrderReady and deletion of kafka pods in pre-delete(CSFS-7634)
- Added statefulset deletion in pre-upgrade based on forceUpgrade flag in values.yaml(CSFS-7634)
- Fix for CSFBANA-7737
- Fix for CSFBANA-7930
- Fix for CSFS-8291

## [1.5.5] - 2018-10-31
### Changed
- Fix for CSFS-7683
- Fix for CSFS 7591
- Fix for CSFS 7732
- Fix for CSFS 7647
- Fix for CSFS-7634

## [1.5.4] - 2018-10-06
### Changed
- Fix for CSFS-7191: Creating seperate PVCs for data and log.
- Moved preheal and postheal under global in values.yaml as per latest heal plugin requirement(CSFS-7221)
- values-model realignment
### Added
- Put cpu and memory resources for cbur-agent and jobs(CSFS-7317)

## [1.5.3] - 2018-09-27
### Added
- Added storageClass variable in values.yaml to global scope.
### Removed
- Removed StorageClass and ckaf-zookeeper.storageClass from values.yaml

## [1.5.2] - 2018-09-12
### Changed
- Updated the memory requirement for charts(Gerrit 467349).

## [1.5.0] - 2018-09-11
### Changed
- CKAF 18.08 release: Supported CBUR 1.2.1, Fix terminate, Enhance scale and upgrade, Relocatable chart.

## [0.0.0] - YYYY-MM-DD
### Added | Changed | Deprecated | Removed | Fixed | Security
- your change summary, this is not a **git log**!


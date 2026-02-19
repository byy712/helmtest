# Changelog
All notable changes to chart **ckaf-zookeeper** are documented in this file,
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
- incubating example only - security vulnerability fi

## [8.0.2] - 2024-02-20
### Changed
- Image tag update
- Image tag update
- Fix for CSFS-57641
- Image tag update

## [8.0.1] - 2024-01-10
### Changed
- Image tag update
- fix for CSFS-56893
- Image tag update

## [8.0.0] - 2023-12-08
### Changed
- Image tag update
- HBP 3.6.0 - Introduced enableDefaultCpuLimits flag which disables cpu resource limit by default.
- Image tag update
- Image tag update
- Image tag update
- Image tag update
### Added
- uktsr 8.1 and 8.5 support ALERT level log message.

## [7.6.1] - 2023-10-31
### Changed
- Image tag update
- Image tag update
- Image tag update

## [7.6.0] - 2023-09-30
### Changed
- Version upgrade v7.4.1 docker image update
- HBP 3.5.0 (Docker image format changed, introduced flatRegistry, Chart will have one registry instead of multiple registries)
- Image tag update
- cbur docker tag update
- Image tag update
- jmx docker tag update
- Image tag update

## [7.5.1] - 2023-07-21
### Changed
- Image tag update

## [7.5.0] - 2023-06-30
### Changed
- Delivered docker image tag update
- image tag update
- fix for CSFS-50274
- Docker image tag update for java 17 and docker image size reduction
- Docker image tag update
- Removed -it  & -i from kubectl exec command used templates
### Added
- Node Selectors for hook pods [CSFS-51604]
- HBP3.4 imagepull secrets.
- Fix for ZK PVC deletion issue due to scale-in(Scale via upgrade) to 0 servers [CSFS-53060]
- Fix for pause containers [CSFS-53165]
- HBP3.3 Pod topologySpreadConstraints

## [7.4.2] - 2023-05-12
### Changed
- Merging syslog paramters defined at global and workload level[CSFS-52815].
- Image tag update
- Image tag update

## [7.4.1] - 2023-04-13
### Changed
- Aligning syslog parameters to HBP standards.
- Fix for [CSFS-50274]
- Image tag update

## [7.4.0] - 2023-03-18
### Added
- Unified logging extensions [CSFID-4059]
- Pod topologySpreadConstraints [CSFS-49130]
### Changed
- Image tag update
- Image tag update
- Image tag update
- Image tag update

## [7.3.2] - 2023-02-10
### Changed
- Helm test changes. Fix for CSFS-51026
- Image tag update

## [7.3.1] - 2022-12-18
### Changed
- Image tag update
- Image tag update

## [7.3.0] - 2022-12-16
### Added
- support for Generic ephemeral volume
### Changed
- Image tag update
- support for k8s 1.25
- update the image tag to latest.
- Image tag update
- Image tag update

## [7.2.2] - 2022-12-05
### Changed
- Configurable Heap options[CSFS-49003]
- Image tag update
- Image tag update
- seccomp changes

## [7.2.1] - 2022-09-30
### Changed
- Image tag update

## [7.2.0] - 2022-09-23
### Changed
- pre,post restore- sed command change to kubectl patch.
- HBP 3.0.0 Named template
- CSFID-3865 and common labels
- Version Upgrade Docker and Repo URL change
- Custom annotations and labels
- Fix trim in heal job files and change part-of label
- Image Tag update to min Image
- Image Tag update - Fix for SASL with min Image
- Image Tag update
- Image Tag update
- Include namespcae in the host section of clog format[CSFS-47917]
- Test configmap fix for minimal JDK.
- Image tag update
### Added
- SysLog support for Zookeeper.


## [7.1.0] - 2022-06-30
### Added
- make istio side car ports used for healthcheck configurable, fix for CSFS-44646
- named template changes for common functions
- Dual stack changes.
- emphemeral storage limits/requests configurable [CSFID-3996]
### Changed
- Cbur API version update to cbur.csf.nokia.com/v1.
- HBP part-of change.
- cbur and kubectl  image update 
- docker image update
- timeZoneName to timeZoneEnv [HBP-Time consideration]
- Docker image update and registry to delivered.

## [7.0.1] - 2022-05-18
### Added
### Changed
- kubectl, jmx and cbura image update
- Fix for CSFS-45161. Taints/Toleration enhancement.
- Remove external image references in chart notes.
- docker image with base image and kubectl image update.

## [7.0.0] - 2022-04-08
### Added
- PriorityClass support for statefulset.
- autoMountServiceAccountToken added.
- Docker image tag update
- update api groups for CSFP env
### Changed
- Docker Image Tag Update
- /var/log/ emptyDir volumeMount.
- Helm Best Practice 2.1.0 , PodDisruptionBudget changes(added maxUnavailable and pdb flag)
- Fix for CSFANA-32091 - Restore enhancement
- Chart.yaml API version updated to v2 helm3 support.
- helm test hook annotation updated.
- k8s 1.22 semver changes.
- PodDisruptionBudget(revert userinput validation for scale fix )
- update apigroups
- Version Upgarde 3.6.3 (docker tag update)

## [6.1.0] - 2021-12-21
### Added
- add "readOnlyRootFilesystem" flag per container level.
### Changed
- PodDisruptionBudget podname prefix in zk chart.Fix for CSFANA-31525
- Helm Best Practice , timezone [CSFS-41458].
- helm test enhanced [CSFS-40954].
- imageTag update
- Update imageTag to latest
- istio peer authentication check enhanced. [CSFS-41592]
- conditions for pre-restore,post-restore,BrPolicy,Cbur-cm. CSFS-41478
- Update imageTag to latest
- Restore jobs readOnlyRootFilesystem fix
- Update imageTag to latest

## [6.0.0] - 2021-09-30
### Added
- Adding  failureThreshold and periodSeconds. Fix for CSFS-37700
- Pod Disruption Budgets for zookeeper. CSFID-3654
- support for cbur.autoEnableCron parameter. CSFS-39521
### Changed
- Update incubator chart version and registry to candidates.
- update imageTag
- update repository
- update imageTag after version upgrade
- Pod Disruption Budgets ApiVersion Change.
- helm toolkit annotation value converted to string in helpers function.
- image update and promotion to delivered.

## [5.1.1] - 2021-09-07
### Changed
- service-clients yaml modified to include the tcp-metric port.
- update image tag.
- Image tag updates and chart promotion.

## [5.1.0] - 2021-05-28
### Added
- Random user support.
### Changed
- Updated imageTag and registry to docker-candidates
- imageTag update
- Helm Best Practice [Customized Labels] and common label enable flag
- Post-delete job rules updation.
- jmxImageTag update
- Image tag updates and chart promotion.

## [5.0.0] - 2021-03-26
### Added
- variable to set timezone,CSFS-31394
- Helm Best Practice [k8s best practice labeling],CSFANA-24506
- Istio Tests,CSFS-31234
- Container Name/Pod Name Prefix for Helm Test 
- Option to choose ConfigMap/TransportIngress for ingress.
- CSFS-34568 [Helm Annotations - istio proxy annotations]
### Changed
- Helm test fix
- Helm Best Practice [Role/Rolebinding]
- Helm Best Practice [IP address]
- Image Tag Update
- seccompAllowedProfileNames and seccompDefaultProfileName values to runtime/default
- pre/post upgrade jobs enhanced to denote the status of upgrade
- readOnlyRootFix fix
- RBAC fix for csfp - CSFS-35196
- Docker image tag update to delivered

## [4.1.0] - 2021-01-27
### Changed
- Docker image tag update [centos7]

## [4.0.0] - 2020-12-24
### Changed
- Docker image tag update to delivered

## [3.3.0] - 2020-12-04
### Added
- Fix for CSFS-31206 -CBUR
- Fix for CSFS-30511
- Docker image tag update [centos8]
- ISTIO 1.6.8 suport
### Changed
- Cbur enable flag removed from global level.
- Fix for citm configmap naming convention with name overrides.
- Docker image tag update [Vesrion upgrade 5.5.2]

## [3.2.0] - 2020-10-30
### Added
- Added annotation for reloader
### Changed
- Fix for CSFS-29508
- zk snapCount config addition
- preheal changes for rollout restart
- Docker image update to delivered.

## [3.1.0] - 2020-09-29
### Added
- Helm Best Practice [Helm Test]
### Changed
- Docker Tag and chart version updation.
- TransportIngress CRD usage for ingress support.
- Jmx enabled flag. Fix for CSFS-27457.
- Istio default values change and removing DR for non-headless svc.
- Revise Documentation For ckaf-zookeeper helm chart/values.yaml
- Docker image update to delivered.

## [3.0.2] - 2020-08-31
### Added
- Helm Best practice [Chart Compliance to helm and k8s Versions]
- Helm Best Practice [Time consideration]
- Istio support for zookeeper ingress.
- Istio helm best practice changes.
### Changed
- Helm Best Practice [imagePullPolicy : IfNotPresent] 
- Helm Best practice [Changing chart maintainers]
- Helm Best practice [StorageClassName]
- Helm Best Practice [Service related convention: Configurable kafka and zookeeper port],CSFS-26629.
- Helm Best Practice [RBAC: RBAC enablement flag]
- Helm Best Practice [Values: Use a hierarchy, not a prefix/suffix]
- ZK Health Check Changes
- CentOS8
- docker image tag update for Zk health script changes.
### Removed
- Individual service account creation for upgrade and rollback

## [3.0.1] - 2020-07-01
### Added
- Zookeeper support scale via upgrade.
- Update the jmx image to latest. 

## [3.0.0] - 2020-06-30
### Changed
- Zookeeper 3.5.7  Scale Fix.
- Version Upgrade to 3.5.7 and zookeeper upgrade fix.
- External RBAC Support
- ServiceAccount Variable Name Change - NameOverride Fix
- Krb5.conf as configmap instead of base64 value
- ckaf-zookeeper charts with istio mtls.
- fix for pvc cleanup upon scale in.
- log directory set for zk-gc log file
- Docker image tag update to delivered.

## [2.0.0] - 2020-03-30
### Changed
- Docker Tag Change to Reflect Centos8,python3,Java11 upgrade
- Helm3 Compliant
- Istio Support
- Reverting back to centos7.Docker Tag Change to Reflect the same.
- Istio changes from listenonallips to ports exclusion
- docker image tag change to latest delivered.

## [1.4.15] - 2019-12-17
- provide feasibility to override any zookeeper config property
- Update charts with latest image tag and registry
- Zookeeper client default port set to 2181
- Update charts with latest image tag and delivered registry

## [1.4.14] - 2019-10-29
### Added
- Fix for deletion of other application resource/pods due to incorrect kubectl delete command in CKAF components hooks
- Nodeport support for zookeeper CSFID-1967
- Fix/Added SASL  parameters for Zookeeper CSFANA-13634
- CBUR changes implemented
- Fullname override feature code is implemented.
- Reverted cbur-configmap name
- Reverting cross-upgrade code.
- Heal timeout paramter included
- compaas values-model file changes for cbur
- Replaced cbur prerestore cmd  from mv to cp 
- Included comment in prerestore hook job
- Taking latest nano base image 1.8.0.222.centos7.6-20190801-2
- added support for configuring SASL in compaas
- update base docker image to 1.8.0.222.centos7.7-20190927 and VAMS fix
- fix for VAMS bug CSFANA-18533(related to sudo)
- Base Image change for clair bug.
- Base Image change for clair bug.(re-do)
- docker image update with java base image update
- delivered docker image update for 19.10 release preparation

## [1.4.13] - 2019-08-02
### Added
- CSFS-12838 Changes in chart to use zk service as zkConnectUrl.
- Java based nano image ( CSFANA-13645 docker image tag change)
- Disabling sts deletion for every upgrade
- 19.07 delivery
- VAMS FIX (docker tag change CSFANA-14671)
- moving to delivered 

## [1.4.12] - 2019-06-20
### Added
- Fullname override changes for zookeeper.
- Support for ingress (CSFID-1967)
- Docker image tag change 
- For Taint toleration and nodeLabel feature removed curly braces and gave reference example
- Made JmxExporter port generic in service files for zookeeper
- Fix for upgrade
- Fix for deploy
- Reverting name and fullname override changes
- Delete pvc lable condition corrected
- Delete pvc lable condition corrected in postscalein.yaml
- For nodeSelector removed angaular brackets from example and provided example in comment
- Delivery 19.06

## [1.4.11] - 2019-06-02
### Added
- Format password for all password like fields in values-model.yaml for (CSFS-9850)
- Support for taint and tolerations
- Image tag change as a fix for  CSFS-13400.
- Docker image tag change as per rhel licensing issue.
- Moving artifacts to delivered.

## [1.4.10] - 2019-04-30
### Changed
- clogEnable to true
- Taking latest docker which has fix for clair vulnerability
- Taking 1.8.0.212.centos7.6-20190411 docker which has fix for clair vulnerability

## [1.4.9] - 2019-04-02
### Added
- Version Upgrade (CSFKAF-1510).
- Security gap fix (CSFKAF-782).
- Bug fix for CSFKAF-1757. Removed all hardcoded imagetag from values-template.yaml.j2
- Latest Docker Image Update for 19.03 release (CSFKAF-1802)
### Changed
- Fix the issues while upgrading from ckaf-zookeeper 1.4.6(CSFS-11514)

## [1.4.8] - 2019-02-28
### Added
- Docker change 1.6.0-3.4.12-1151 
### Changed 
- Bug fix for zookeeper scale issue (CSFKAF-17).


## [1.4.7] - 2019-01-31
### Added
- Added preAllocationSize for zookeeper snapcount files
- Added a new folder named dashboard which contains zookeeper metrics dashboard which should be imported into grafana (CSFBANA-8272).
- Added ConfigMap for Jmx(CSFBANA-8443).
- Added autoPvEnabled to check if volumes are precreated then bind them to pods (CSFS-8360)
- Added selector in volumeClaimTemplates to bind pods to the specific labelled PVs (CSFS-8360)
### Changed
- Rbac updates for ComPaaS.(CSFS-9093)
- Changed nodeLabel , made it generic where the users have to give their own nodeType, which is a key value pair (CSFBANA-8471).


## [1.4.6] - 2018-12-11
### Added
- sasl refactor
- Added clog changes
- Added dynamic creation of zookeeper ensemble (CSFS-8362).
### Changed
- Docker image tag for zookeeper 1.4.0-3.4.12-880.
- Change name of hooks,job,service-account,rolebindings to be unique (CSFS-9098).

## [1.4.5] - 2018-11-29
### Added
- Added nodeSelector in statefulset.yaml.
- Added log rotation in log4j.properties and redirected the logs of zookeeper into specified log volume mount (CSFS 8289).

## [1.4.4] - 2018-11-19
### Added
- Pre-upgrade, post-upgrade and pre-rollback hooks(CSFS 7634).

## [1.4.3] - 2018-10-31
### Changed
- Updated the storageClass and namespace for zookeeper(CSFS 7591).

## [1.4.2] - 2018-10-06
### Changed
- Moved preheal and postheal under global in values.yaml as per latest heal plugin requirement(CSFS-7221)
- values-model realignment
- meta data support CSFS-7191
### Added
- Put cpu and memory resources for cbur-agent and jobs(CSFS-7317)

## [1.4.1] - 2018-09-27
### Changed
- Moved storageClass variable in values.yaml to global scope(CSFS-7253)

## [1.4.0] - 2018-09-10
### Changed
- CKAF-Zookeeper 18.08 release: CBUR 1.2.1 support, Fix terminate, Fix scale, Relocatable chart.

## [0.0.0] - YYYY-MM-DD
### Added | Changed | Deprecated | Removed | Fixed | Security
- your change summary, this is not a **git log**!

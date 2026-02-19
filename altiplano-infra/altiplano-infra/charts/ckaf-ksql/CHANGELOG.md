# Changelog
All notable changes to chart **ckaf-ksql** are documented in this file,
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

## [8.1.0] - 2024-03-28
### Added
- HBP 3.7.0 - move certManager.enabled to global and root level
- HBP 3.7.0 Introduced imageFlavor and imageFlavorPolicy
- HBP 3.7.0 Introduced PodnamePrefix
- support TLS for jmx endpoints.
- HBP 3.8 introduce podAntiAffinity

### Changed
- CSFID-4592 - Remove hardcoded resources from charts and make them configurable
- imagePullSecrets param from string to an array of secrets names - fix for CSFS-57841
- HBP 3.8 use two spaces per level of indentation
- Image tag update
- Image tag update
- Image tag update
- Image tag update
- Image tag update

## [8.0.0] - 2023-12-08
### Changed
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
- version upgrade 7.4.1 docker image tag update.
- Image tag update
- HBP 3.5.0 (Introduced flatRegistry, helm chart will have one registry instead of multiple registries and hpaValues common-lib template used)
- Image tag update
- Image tag update
- Jmx docker image tag update
- Image tag update

## [7.5.0] - 2023-06-30
### Changed
- Delivered docker image tag update
- image tag update
- Docker image tag update for java 17 and docker image size reduction
- Docker image tag update
- syslog standardization to HBP.
### Added
- Node Selectors for hook pods [CSFS-51604]
- HBP3.4 imagepull secrets.
- cert-manager support
- HBP3.3 Pod topologySpreadConstraints

## [7.4.1] - 2023-04-06
### Changed
- Aligning syslog parameters to HBP standards.

## [7.4.0] - 2023-03-18
### Added
- Unified logging extensions [CSFID-4059]
### Changed
- Added sleeptime for ksql headless service
- Image Tag update
- Image Tag update
- Image Tag update
- Image Tag update

## [7.3.1] - 2023-02-09
### Changed
- Helm test changes.Fix for CSFS-51026

## [7.3.0] - 2022-12-16
### Added
- Image tag update
- support for k8s 1.25
- HPA changes
- support for Generic ephemeral volume
- Image tag update
- seccomp changes
- Image tag update

## [7.2.2] - 2022-11-10
### Changed
- Image tag update
- Image tag update

## [7.2.0] - 2022-09-23
### Changed
- HBP 3.0.0 Named template
- CSFID-3865 and common labels
- Version Upgrade Docker and Repo URL change
- Custom annotations and labels
- Removed part-of label
- Image Tag update to min image
- Image Tag update - Fix for SASL with min Image
- hostAliases changes
- Image Tag update
- Image Tag update
- Include namespcae in the host section of clog format[CSFS-47917]
- Image Tag update
### Added 
- SysLog support for KSQL.

## [7.1.0] - 2022-06-30
### Added
- make istio side car ports used for healthcheck configurable, fix for CSFS-44646
- named template changes for common functions
- Dual stack support
- emphemeral storage limits/requests configurable [CSFID-3996]
### Changed
- Version Upgrade 7.1.0 [Docker image tag update]
- kubectl and jmx image update
- Fix for CSFS-45161. Taints/Toleration enhancement.
- HBP part-of and ingress pathType change.
- kubectl image tag update
- timeZoneName to timeZoneEnv [HBP-Time consideration]
- Docker image update and registry to delivered.

## [7.0.0] - 2022-04-08
### Added
- PriorityClass support for deployment.
- Added autoMountServiceAccountToken
- Docker image tag update
- update api groups for CSFP env
### Changed
- Docker Image Tag Update
- /var/log emptyDir volumeMount
- Helm Best Practice 2.1.0 , PodDisruptionBudget changes(added maxUnavailable and pdb flag)
- Chart.yaml API version updated to v2 helm3 support.
- helm test hook annotation updated.
- k8s 1.22 semver changes.
- update apigroups
- KSQL udf imagePullPolicy fix 
- Version Upgrade 7.0.1 [Docker image tag update]

## [6.1.0] - 2021-12-21
### Added
- Support for TLS1.3
- add "readOnlyRootFilesystem" flag per container level.
### Changed
- Helm Best Practice,timezone [CSFS-41458].
- Helm Best Practice [README.md]
- Update imageTag to latest
- istio peer authentication check enhanced. [CSFS-41592]
- tls flag defaults to enable.
- Update imageTag to latest

## [6.0.0] - 2021-09-30
### Added
- Pod Disruption Budgets for ksql. CSFID-3654
- ReadOnlyRootFs fix for ksql.
### Changed
- Image tag update to use ksql 6.2.0 image. 
- Updated ImageTag
- updated imageTag after version upgrade.
- support for v1 API version update of kind ingress object on k8s 1.20.
- Pod Disruption Budgets ApiVersion Change.
- helm toolkit annotation value converted to string in helpers function.
- image update and promotion to delivered.

## [5.1.0] - 2021-05-28
### Added
- Option to load any custom plugins via init container
- Helm Best Practice [k8s custom annotation and label]
### Changed
- Updated imageTag and registry to docker-candidates
- Helm Best Practices - Port Naming
- imageTag update
- Random user support
- imageTag update for random user
- imageTag update
- jmx imageTag update
- image tag update and chart promotion.

## [5.0.0] - 2021-03-26
### Added
- Helm Best Practice [k8s best practice labeling],CSFANA-24506
- variable to set timezone,CSFS-31394
- Ksql init container changes
- Ksql headless mode init contianer changes
- Helm Best Practice [Role/Rolebinding]
- pre/post upgrade jobs enhanced to denote the status of upgrade
### Changed
- Helm Best Practice [IP address]
- seccompAllowedProfileNames and seccompDefaultProfileName values to runtime/default
- RBAC fix for csfp - CSFS-35196.
- Docker image tag update to delivered

## [4.1.0] - 2020-01-27
### Changed
- Docker image tag update [centos7]


## [4.0.0] - 2020-12-24
### Changed
- Docker image tag update to delivered

## [3.2.0] - 2020-12-15
### Changed
- Docker image tag update [centos8]
- Docker image tag update [Vesrion Upgrade 5.5.2]
- Istio 1.6.8 version upgade in values.yaml

## [3.1.0] - 2020-09-29
### Added
- Helm best practice [Adding chart maintainers]
- Helm Best Practice [Ip Address : Making domain name configurable]
- Helm Best Practice [Ingress annotation]
- Helm Best Practice [Chart Compliance to helm and k8s Versions]
- Helm Best Practice [Time consideration]
- Istio support for KSQL.
- Istio default values change and gatway changes
- Helm Best Practice [Helm Test]
### Changed 
- Helm Best Practice [Naming convention: Port naming]
- Helm Best Practice [RBAC: RBAC enablement flag]
- Helm Best Practice [Values: Use a hierarchy, not a prefix/suffix]
- Centos8 docker tag updation 
- Helm Best Practice [Using NOTES.txt]
- Docker image tag update to delivered.

## [3.0.1] - 2020-07-07
### Changed
- update jmx image tag to latest delivered.

## [3.0.0] - 2020-06-30
### Changed
- Vesrion Upgrade of KSQL (v5.4.1)
### Added
- KSQL chart changes to add liveness and readiness probe
- Krb5.conf as configmap instead of base64 value
- KSQL chart changes to support external ksql-queries file.
- KSQL chart changes to support both default as well as user-defined configmap for ksql-queries.
- KSQL chart changes to disable SSL for ksql as server for  headless mode.
- KSQL chart changes to use user-created keytab instead of creating inside the pod.
- Docker image tag change to latest delivered.

## [2.0.0] - 2020-03-30
### Changed
- Docker Tag Change to Reflect Centos8,python3,Java11 upgrade.
- 2 way ssl implementation
- Helm 3 Compliant
- support Schema registry with Basic authentication.
- Reverting back to centos7.Docker Tag Change to Reflect the same.
- KSQL upgarde fix 
- Docker image tag change to latest delivered.

## [1.1.5] - 2019-12-18
- ingress back end port fix.
- update charts with latest docker images and registry to candidates.
- added properties for ksql to connect to kafka with ssl
- update charts with latest docker images and registry to delivered.

## [1.1.4] - 2019-10-29
### Added
- Fix for deletion of other application resource/pods due to incorrect kubectl delete command (BUG-CSFANA-14847) 
- Fullname and name override feature code implemented.
- Taking latest nano base image 1.8.0.222.centos7.6-20190801-2
- ingress support for ckaf-ksql CSFID-1967
- Added configuration option in configurationOverrides section
- update base docker image to 1.8.0.222.centos7.7-20190927 and VAMS fix
- fix for VAMS bug CSFANA-18533(related to sudo)
- fix for CSFANA-18397 ksql keystore mapping issue
- fix for ksql ingress name/override check
- fix for non ssl of ksql check CSFANA-18598
- Base Image change for clair bug.
- Base Image change for clair bug.(merged)
- docker image update with java base image update
- delivered docker image update for 19.10 release preparation

## [1.1.3] - 2019-08-02
### Added
- Docker image change for (CSFANA-14376)
- Java based nano image (CSFANA-13645 docker image tag change)
- 19.07 delivery
- VAMS FIX (CSFANA-14730 docker image tag change)
- moving the charts to delivered 

## [1.1.2] - 2019-07-01
### Added
- Fullname override changes for ksql.
- Docker image tag change
- For Taint toleration and nodeLabel feature removed curly braces and gave reference example
- Fix for upgrade
- Fix for deploy
- Reverting back the fullName and NameOverride changes 
- For nodeSelector removed angaular brackets from example and provided example in comment
- Delivery 19.06

## [1.1.1] - 2019-06-02
### Added
- support for taints and tolerations
- Docker image tag change as per (CSFANA-13425)
- Docker image tag change as per rhel licensing issue.
- Moving artifacts to delivered.

## [1.1.0] - 2019-04-30
### Added
- Taking latest docker which has fix for clair vulnerability
### Changed
- Latest Docker Image Update for 19.04 release

## [1.0.1] - 2019-04-02
### Added
- fix for 7 per gap in KSQL (CSFKAF-1529).
- Latest Docker Image Update for 19.03 release

### Changed
- Using latest KSQL docker image.

## [1.0.0] - 2019-01-31
### Added
- KSQL release(CSFID-1818)
- Added KSQL chart.
- Added a new folder named dashboard which contains KSQL metrics dashboard which should be imported into grafana(CSFBANA-8555)
- Added security changes for KSQL

## [0.0.0] - YYYY-MM-DD
### Added | Changed | Deprecated | Removed | Fixed | Security
- your change summary, this is not a **git log**!


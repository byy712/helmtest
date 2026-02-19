# Changelog
All notable changes to chart **ckaf-filter-manager** are documented in this file,
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

## [5.1.0] - 2024-03-28
### Added
- HBP 3.7.0 - cert-manager enabled at global and root level
- HBP 3.7.0 - Introduced imageFlavor and imageFlavorPolicy
- HBP 3.7.0 - Naming convention of the values.yaml for user supplied certificates via Kubernetes Secret 
- HBP 3.7.0 - Introduced PodnamePrefix
- update certmanager api version for certificate kind.
- support TLS for jmx endpoints.
- HBP 3.8 introduce podAntiAffinity
- Add ipFamilyPolicy and ipFamilies for CSFS-57627

### Changed
- fix for CSFS-57919. 
- HBP 3.7.0 - Introduced new flag for HBP 3.7 new convention for resource name.
- HBP 3.8 use two spaces per level of indentation
- Update image tag
- Image tag update
- Image tag update
- Image tag update

## [5.0.0] - 2023-12-08
### Changed
- HBP 3.6.0 - Introduced enableDefaultCpuLimits flag which disables cpu resource limit by default.
- Image tag update
- Image tag update
- Image tag update
- Image tag update

### Added
- uktsr 8.1 and 8.5 support ALERT level log message.

## [4.7.0] - 2023-11-06
### Changed
- Fix for CSFS-50274

## [4.6.1] - 2023-10-31
### Changed
-Image tag update
-Image tag update
-Image tag update

## [4.6.0] - 2023-09-30
### Changed
- Image tag update
- Image tag update
- Image tag update
- Image tag update
- Jmx docker image tag update
- Image tag update
### Added
- kafka heap opts - fix for CSFS-55078
- HBP 3.5.0 (Introduced flatRegistry, helm chart will have one registry instead of multiple registries)

## [4.5.1] - 2023-07-21
### Fixed
- Fix for CSFS-53962 on FP5 release, upgrade failure when tls is enabled.
### Changed
- Image tag update

## [4.5.0] - 2023-06-30
### Changed
- Delivered docker image tag update
- imageTag update
- Docker image tag update for java 17 and docker image size reduction
- Docker image tag update
- syslog merge global and workload values.
### Added
- Node Selectors for hook pods [CSFS-51604]
- HBP3.4 imagepull secrets.
- HBP3.3 Pod topologySpreadConstraints
- HBP3.4 cert-manager support for mirror-maker 
- Aligning syslog parameters to HBP standards.

## [4.4.3] - 2023-07-17
### Fixed
- Fix for CSFS-53962, upgrade failure when tls is enabled.

### Changed
- Chart version update for promotion to stable.

## [4.4.0] - 2023-03-18
### Changed
- Image tag update
- Image tag update
- Image tag update
- Image tag update

### Added 
- Configurable ssl cipher suites.
- Unified logging extensions [CSFID-4059]


## [4.3.1] - 2023-01-18
### Changed
- Image tag update
- Image tag update

## [4.3.0] - 2022-12-16
### Changed
- Image tag update
- support for k8s 1.25
- Image tag update
- seccomp changes
- Image tag update

## [4.2.2]- 2022-11-10
### Changed
- Image tag update
- Image tag update

## [4.2.0] - 2022-09-23
### Changed
- HBP 3.0.0 Named template
- CSFID-3865 and common labels
- Version Upgrade Docker and Repo URL change
- Custom annotations and labels
- Update chart for Inclusive Terms
- Image Tag update to min Image
- Image Tag update - Fix for SASL with min Image
- Image Tag update
- Image Tag update
- Include namespcae in the host section of clog format[CSFS-47917]
- Image Tag update
- Image Tag update
### Added 
- SysLog support for kafka mirror maker.

## [4.1.0] - 2022-06-30
### Added
- named template changes for common functions
- emphemeral storage limits/requests configurable [CSFID-3996]
### Changed
- HBP part-of change
- kubectl image tag update
- timeZoneName to timeZoneEnv [HBP-Time consideration]
- Docker image update and registry to delivered.

## [4.0.1] - 2022-05-18
### Added
### Changed
- kubectl and jmx image update
- Fix for CSFS-45161. Taints/Toleration enhancement.
- docker image with base image and kubectl image update.

## [4.0.0] - 2022-04-08
### Added
- PriorityClass support for deployment.
- Docker image tag update
- Helm Best Practice 2.1.0 , PodDisruptionBudget
- update api groups for CSFP env
### Changed
- Docker Image Tag Update
- /var/log emptyDir volumeMount
- Chart.yaml API version updated to v2 helm3 support.
- k8s 1.22 semver changes.
- update apigroups
- Version Upgrade [Docker image tag Update]

## [3.1.0] - 2021-12-21
### Added
- Support for TLS1.3
- Support for readOnlyRootFilesystem. 
- add "readOnlyRootFilesystem" flag per container level.
### Changed
- Update tags to latest
- tls defaults to enable
- Update tags to latest
- Timezone changes.
- Update tags to latest

## [3.0.0] - 2021-09-30
### Changed
- Updated imageTag to latest and repo to incubator
- updated imageTag after version upgrade.
- expose jmx metrics on a port and add prometheus annotation.
- CSFS-39589 MirrorMaker reflections exception log fix.
- helm toolkit annotation value converted to string in helpers function.
- image update and promotion to delivered.

## [2.1.0] - 2021-05-28
### Added
-  Helm Best Practice [Lables and annotations]
- jobResources in values.yaml
- image tag update and chart promotion.

### Changed
- Helm Best Practice [k8s best practice labeling]
- Updated imageTag and registry to docker-candidates
- imageTag update
- Random user support.
- jmx imageTag update

## [2.0.0] - 2021-03-26
### Added
- Helm Best Practice [k8s best practice labeling],CSFANA-24506
- variable to set timezone,CSFS-31394
- Helm Best Practice [Chart Compliance to helm and k8s Versions]
- Fix for fails to detect topic,CSFS-33732
- Helm Best Practice [IP address]
- Init container support.
- Fix for Mirror-Maker SASL_PLAIN deployment issue.
### Changed
- seccompAllowedProfileNames and seccompDefaultProfileName values to runtime/default
- pre/post upgrade jobs enhanced to denote the status of upgrade
- RBAC fix for csfp - CSFS-35196.
- Docker imageTag update to delivered

## [1.2.0] - 2020-01-27
- Docker imageTag update [centos7]

## [1.1.0] - 2020-12-24
### Added
- helm chart with plaintext and ssl and SASL support.
- Liveness and readiness addition.
- Docker imageTag upgrade.
### Changed
- Docker imageTag update to delivered

# Changelog
All notable changes to chart **citm-default-backend** are documented in this file,
which is effectively a **Release Note** and readable by customers.

Do take a minute to read how to format this file properly.
It is based on [Keep a Changelog](http://keepachangelog.com)
- Newer entries _above_ older entries.
- At minimum, every released (stable) version must have an entry.
- Pre-release or incubating versions may reuse `Unreleased` section.

## [1.8.1] - 2023-12-06
- 23.11.PP1 release

### Changed
- CSFAR-9719: remove dev tags and take up image from delivered repo                         | 1.8.1
- CSFAR-9718: update imageTag after base image update for [24-11-2023]                      | 1.8.1-dev0.1.0

## [1.8.0] - 2023-11-17
- 23.11 release

### Added
- CSFAR-9044: HBP 3.7.0 added disablePodNamePrefixRestrictions to root level                | 1.8.0-dev0.2.0
- CSFAR-9127: Update container image tag with change related to golang upgrade (1.21.1)     | 1.8.0-dev0.1.0 

### Changed
- CSFAR-9152: Update images to delivered and remove devs tags                               | 1.8.0
- CSFAR-9057: Updated istio version and image tags                                          | 1.8.0-dev0.4.0
- CSFAR-8967: Update tags to use njs v0.8.2                                                 | 1.8.0-dev0.3.0

## [1.7.0] - 2023-09-14
- 22.03.FP6 release

### Added
- CSFAR-8307: Support to enable default cpu resources limits on containers                  | 1.7.0-dev0.5.0
- CSFAR-8299: Support for disabling pod name prefix restriction introduced in HBP-3.4.0     | 1.7.0-dev0.4.0
- CSFAR-8275: def404 support for container registries with a flat structure                 | 1.7.0-dev0.3.0
- CSFAR-8273: HBP-3.4.0 pod naming changes                                                  | 1.7.0-dev0.2.0
- CSFAR-8273: HBP-3.4.0 container naming changes                                            | 1.7.0-dev0.1.0

### Changed
- CSFAR-8956: Remove dev tag and use delivered images                                       | 1.7.0
- CSFAR-8935: updated kubectl image tag                                                     | 1.7.0-dev0.9.1
- CSFAR-8797: updated image tag post CCBI base image update                                 | 1.7.0-dev0.9.0
- CSFAR-8770: Istio version bump to 1.17.3                                                  | 1.7.0-dev0.8.1
- CSFAR-8311: updated image tag post golang version upgrade                                 | 1.7.0-dev0.8.0
- CSFAR-8310: Handle image repo with older values post flatRegistry changes                 | 1.7.0-dev0.7.1
- CSFAR-8314: updated image tag post CCBI base image update                                 | 1.7.0-dev0.7.0
- CSFAR-8671: Bug fix for probe, added timeoutseconds in values.yaml                        | 1.7.0-dev0.6.0

## [1.6.0] - 2023-06-15
- 22.03.FP5 release

### Added
- CSFAR-7106: updated def404 page wrt Nokia rebranding
- CSFAR-7299: Added autoGenerateLabelSelector parameter for topologySpreadConstraint as HBP 3.3.0 requirement
- CSFAR-7277: added imagePullSecrets as per HBP 3.3.0 requirement
- CSFAR-7363: updated container name according to HBP 3.4.0

### Changed
- CSFAR-7852: Remove dev tag and image repo to delivered                                    | 1.6.0
- CSFAR-7725: updated istio version to 1.17.2 and image tag to 4.0.4-17.5                   | 1.6.0-dev0.9.0
- CSFAR-7731: updated pdb api versions                                                      | 1.6.0-dev0.8.2
- CSFAR-7696: automountServiceAccountToken configuratbility in non istio case               | 1.6.0-dev0.8.1
- CSFAR-7705: updated image tag to 4.0.4-17.4                                               | 1.6.0-dev0.8.0
- CSFAR-7363: reverted changes of updated container name and pod name acc to HBP 3.4.0      | 1.6.0-dev0.7.1
- CSFAR-7106: updated image tag to 4.0.4-17.1, kubectl image tag & Nokia rebranding changes 
- CSFAR-7239: updated image tag to 4.0.4-17.2, updated image to use njs 0.7.12 
- CSFAR-7363: updated pod  name according to HBP 3.4.0

## [1.5.0] - 2023-03-16
- 22.03.FP4 release

### Added
- CSFAR-6948: Removed the dev tag from chart and image repo to delivered
- CSFAR-6812: Updated istio version to 1.16.3
- CSFAR-6812: Updated default404 image to 4.0.4-16.3
- CSFAR-6760: updated ./helmignore to exclude UT
- CSFAR-6746: Updated default404 image to 4.0.4-16.2
- CSFAR-6686: Updated default404 image tags
- CSFAR-6514: Updated empty labels field 
- CSFAR-6511: Update default404, kubectl image tags
- CSFAR-6488: Support for fullnameOverride to work with helm test

## [1.4.0] - 2022-12-15
- 22.03.FP3 release

### Added
- Support for using global.ipFamilyPolicy and global.ipFamilies  | 1.4.0-dev0.4.0
- Support for PSA | 1.4.0-dev0.3.0

### Changed
- removed the dev tag from chart and image repo to delivered
- updated kubectl image tag to v1.25.4-rocky-nano-20221125 | 1.4.0-dev0.3.1
- updated image tag to 4.0.4-15.0 | 1.4.0-dev0.2.0
- updated image tag to 4.0.4-14.0 | 1.4.0-dev0.1.0


## [1.3.0] - 2022-09-29
- 22.03.FP2 release

### Changed
- Updated docker image tag to 4.0.4-13.0 | 1.3.0-dev0.1.1
- Updated docker image tag to 4.0.4-12.0 | 1.3.0-dev0.1.0

## Added
- added curlExtraOpts for the test curl and defaults to `--connect-timeout 60` | 1.3.0-dev0.1.2
- added a check on .Values.rbac.podSecurityPolicy.enabled for psp use verb | 1.3.0-dev0.0.1

## [1.2.0] - 2022-07-04
- 22.03.FP1 release
### Changed
- removed dev tag from charts and image repos to delivered

## [1.2.0-dev0.10.2] - 2022-06-28
### Changed
- added sidecar injection annotation to test pod

## [1.2.0-dev0.10.1] - 2022-06-28
### Changed
- made changes to _helpers.tpl,psp to fix issue with psp api version

## [1.2.0-dev0.10.0] - 2022-06-20
### Changed
- commonlibs chart templates is used for handling common labels

## [1.2.0-dev0.9.1] - 2022-06-24
### Changed
- updated README.md file
- update values.template.yaml.j2

## [1.2.0-dev0.9.0] - 2022-06-20
### Added
- Exposed liveness and readiness probe values in values.yaml
- Exposed skip test value in values.yaml
- Added registy1 pointing to delivered repo

## [1.2.0-dev0.8.0] - 2022-06-15
### Changed
- Minor change to dualStack.ipFamilies order in values.yaml

## [1.2.0-dev0.7.0] - 2022-06-08
### Changed
- HBP 3.0 changes for named template, kubernetes versions and pdb

## [1.2.0-dev0.6.2] - 2022-06-01
### Changed
- new docker image

## [1.2.0-dev0.6.1] - 2022-05-31
### Changed
- Global setting of security context

## [1.2.0-dev0.6.0] - 2022-05-25
### Added
- Support for random user id

## [1.2.0-dev0.5.0] - 2022-05-23
### Added
- Support for dual stack

## [1.2.0-dev0.4.0] - 2022-05-19
### Changed
- pod anti-affinity configuration

## [1.2.0-dev0.3.0] - 2022-05-06
### Added
- added anti-affinity configuration

## [1.2.0-dev0.2.0] - 2022-04-28
### Changed
- updated new artifactory_url

## [1.2.0-dev0.1.0] - 2022-04-06
### Changed
- dropped helm2 support

## [1.1.0] - 2022-03-30
- 22.03 Release
### Changed
- updated latest chart version and docker registry

## [1.1.0-dev0.5.2] - 2022-03-25
## Changed
- test pod name trunc logic changed

## [1.1.0-dev0.5.1] - 2022-03-24
## Changed
- retry logic for test curl which helps when istio injection is enabled
- trunc the name of test pod

## [1.1.0-dev0.5.0] - 2022-03-11
## Added
- automountServiceAccountToken in ServiceAccount
- priorityClassName configurable in global scope

## [1.1.0-dev0.4.0] - 2022-03-07
## Changed
- image tag to 4.0.4-8.0

## [1.1.0-dev0.3.1] - 2022-02-18
## Changed
- image tag to 4.0.4-7.0

## [1.1.0-dev0.3.0] - 2022-02-17
## Changed
- Kubectl image to v1.23.1-rocky-nano-20220128
- image tag to 4.0.4-7

## [1.1.0-dev0.2.0] - 2022-02-04
## Changed
- Corrected maintainer name and email id

## [1.1.0-dev0.1.0] - 2021-12-22
## Changed
- fixed semverCompare causing issue on pre-released k8s version

## [1.0.47] - 2021-12-16
- 21.08. FP1 Release
### Added
- updated latest chart version

## [1.0.47-dev0.5.1] - 2021-12-08
### Changed
- kubectl image to v1.22.1-nano-20211208

## [1.0.47-dev0.5.0] - 2021-12-08
### Added
- Update istio version

## [1.0.47-dev0.4.1] - 2021-11-24
### Added
- support to inject user provided psp from parent chart using global

## Changed
- Custom psp now can be set as global value and gains the high priority
- kubectl image tag

## [1.0.47-dev0.4.0] - 2021-11-18
### Added
- support to inject user provided psp

## [1.0.47-dev0.3.0] - 2021-11-08
### Added
- Support for pod topology spread constraints to default404 chart
- Added clusterDomain for accessing svc - HBP 2.9
- Added option to add podLabels
- Added evenPodSpreadEnabled option to ensure the EvenPodSpread feature gate enabled on k8s 1.16 and 1.17

## [1.0.47-dev0.2.0] - 2021-11-04
### Added
- terminationMessagePath and terminationMessagePolicy

## [1.0.47-dev0.1.0] - 2021-10-27
### Added
- Support for pod disruption budget

## [1.0.46] - 2021-08-12
### Changed
- new kubectl docker (v1.21.1-nano-20210702)

## [1.0.45] - 2021-07-27
### Changed
- specify securityContext.runAsUser

## [1.0.44] - 2021-05-27
### Changed
- readOnlyRootFilesystem activated

## [1.0.43] - 2021-04-30
### Changed
- new kubectl docker (v1.19.8-nano-20210309)

## [1.0.42] - 2021-03-11
### Changed
- new docker citm-default-backend:4.0.4-6

## [1.0.41] - 2021-02-18
### Added
- istio annotation

## [1.0.40] - 2021-02-08
### Added
- commons labels

## [1.0.39] - 2020-12-16
### Changed
- Rollback NCSDEV-42

## [1.0.37] - 2020-12-14
### Changed
- istio: fixed networking.istio.io/v1alpha3 VirtualService

## [1.0.35] - 2020-11-15
### Changed
- NCSDEV-42: Assign critical NCS Pods to proper priority classes (cont.)

## [1.0.34] - 2020-10-05
### Changed
- prefix helper functions with chart name

## [1.0.33] - 2020-09-07
### Added
- affinity (.Values.affinity)
- hook-delete-policy on helm test (.Values.test.hookDeletePolicy)

## [1.0.32] - 2020-08-31
### Changed
- rename default404.rbac.create to default404.rbac.enabled to be compliant with CSF Helm Best Practices

## [1.0.30] - 2020-08-12
### Added
- Support of Support of global.podNamePrefix and global.containerNamePrefix

## [1.0.29] - 2020-07-31
### Added
- Support of fullnameOverride

## [1.0.28] - 2020-07-15
### Changed
- Fixed rbac & Istio

## [1.0.27] - 2020-07-02
### Changed
- Fixed serviceAccount

## [1.0.26] - 2020-06-29
### Changed
- Support of kubernetes 1.16 and upper
- Clean up rbac. Only activated on Istio (rbac.create=true and istio.enable=true)
- Support predefined service account thanks to .Values.rbac.serviceAccountName (rbac.create=false)
- Update kubectl image to v1.17.6-nano

## [1.0.21] - 2020-05-26
### Changed
- increase curl timeout for helm test. DNS resolution is slow on ipv6
- Remove set on ClusterIP

### Added
- Istio port naming convention

## [1.0.18] - 2020-03-16
### Added
- Add NET_RAW, needed by istio sidecar

## [1.0.17] - 2020-03-02
### Fixed
- Fixed ServiceAccount

## [1.0.16] - 2020-01-06
### Changed
- Use own ServiceAccount and do not rely on default one

## [1.0.15] - 2019-11-20
### Changed
- new kubectl docker for chart test

## [1.0.14] - 2019-10-31
### Added
- runOnEdge flag
- new kubectl docker for chart test

## [1.0.13] - 2019-09-23
### Added
- kubernetes tolerations

## [1.0.12] - 2019-09-18
### Fixed
- Fixed istio support

## [1.0.11] - 2019-07-12
### Added
- Add readiness probe

## [1.0.10] - 2019-03-13
### Added
- helm test on release

### Changed
- Provide resources limits for CPU & Memory

## [1.0.9] - 2019-02-13
### New
- Listening port is now configurable

## [1.0.7] - 2019-01-16
### New
- support of rbac & Istio

## [1.0.5] - 2018-11-29
### Fixed
- new docker image: citm/citm-default-backend:4.0.4-3

## [1.0.4] - 2018-11-26
### Fixed
- ComPass rendering

## [1.0.3] - 2018-11-06
### Fixed
- Rename Chart

## [1.0.2] - 2018-10-16
### Fixed
- First version

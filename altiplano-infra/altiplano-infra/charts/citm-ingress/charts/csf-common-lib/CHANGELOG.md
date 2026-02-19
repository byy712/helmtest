# Changelog

All notable changes to chart **csf-common-lib** are documented in this file,
which is effectively a **Release Note** and readable by customers.

## [Unreleased]
- Never delete this Unreleased section as it allows `unit-test/` changes
  using an incubating chart version. Move all accumulated Added/Changed/Removed
  sections when the chart is released.

## [1.10.0] - 2023-10-03
### Added
- `csf-common-lib.v2.imageHelper` - fix issue with usage of function outside the csf-common-lib
- `csf-common-lib.v2.imageTag` - fix `csf-common-lib.v1.imageHelper` issue with usage of function outside the csf-common-lib
- `csf-common-lib.v2.imageRepository` - fix `csf-common-lib.v1.imageHelper` issue with usage of function outside the csf-common-lib
### Removed
- `csf-common-lib.v1.imageHelper` - it used function outside the csf-common-lib, which makes it unusable.
- `csf-common-lib.v1.imageTag` - it used `csf-common-lib.v1.imageHelper`
- `csf-common-lib.v1.imageRepository` - it used `csf-common-lib.v1.imageHelper`

## [1.9.0] - 2023-09-29
### Added
- New functions to support `imageFlavor` and `imageFlavorPolicy`:
  - `csf-common-lib.v1.imageFlavorOrFail`
  - `csf-common-lib.v1.imageTag`
  - `csf-common-lib.v1.imageRepository`
  - `csf-common-lib.v1.imageHelper`
- Example of proxy functions in `README.md`
- New functions to support `.disablePodNamePrefixRestrictions` parameter at root level:
    - `csf-common-lib.v3.resourceName` (additionally support custom name)
    - `csf-common-lib.v3.workloadName`
    - `csf-common-lib.v4.hpa`
    - Note that pdb functions do not need to be changed - they use names which do not depend on `podNamePrefix`
- New function to check if podNamePrefix meets restrictions, otherwise fail.
  It can be used to fast-fail win info that `.disablePodNamePrefixRestrictions` parameter should be used to disable restrictions:
    - `csf-common-lib.v1.podNamePrefixRestrictionsCheck`
- New functions to support configurable secretName:
  - `csf-common-lib.v4.certificate`
  - `csf-common-lib.v4.certificateValues`
### Fixed
- Secret name duplication by generation secretName based on certificate name. New functions:
  - `csf-common-lib.v3.certificateSecretName` and functions which depends on it:
    - `csf-common-lib.v4.certificate`
    - `csf-common-lib.v4.certificateValues`
### Deprecated
- `csf-common-lib.v1.certificate`,`csf-common-lib.v2.certificate`,`csf-common-lib.v3.certificate` - use `csf-common-lib.v4.certificate` instead
- `csf-common-lib.v1.certificateValues`,`csf-common-lib.v2.certificateValues`,`csf-common-lib.v3.certificateValues` - use `csf-common-lib.v4.certificateValues` instead
- `csf-common-lib.v1.certificateSecretName`,`csf-common-lib.v2.certificateSecretName` - use `csf-common-lib.v3.certificateSecretName` instead

## [1.8.0] - 2023-06-09
### Fixed
- New functions to support Certificate in v1alpha3 version:
  - `csf-common-lib.v3.certificate`
  - `csf-common-lib.v3.certificateValues`

## [1.7.0] - 2023-06-09
### Fixed
- New function `csf-common-lib.v2.topologySpreadConstraints` which fix issue with multiple topologySpreadConstraint entries

## [1.6.0] - 2023-06-07
### Added
- New functions, which use `csf-common-lib.v2.resourceName`:
  - `csf-common-lib.v2.certificate`
  - `csf-common-lib.v2.certificateValues`
  - `csf-common-lib.v3.hpa`
  - `csf-common-lib.v3.pdb`
  - `csf-common-lib.v2.workloadName`
### Fixed
- New function `csf-common-lib.v2.resourceName` which:
  - handles empty suffix - no need to have `nameSuffix` in a workload block in `values.yaml`
  - handles `.global.disablePodNamePrefixRestrictions`

## [1.5.0] - 2023-03-01
### Added
- New function `csf-common-lib.v1.containerName`
- New function `csf-common-lib.v1.resourceName`
- New function `csf-common-lib.v1.workloadName`
  (simplified version of `csf-common-lib.v1.resourceName`)
- New function `csf-common-lib.v2.hpa`
  use `csf-common-lib.v1.resourceName`, removed conditional object generation
- New function `csf-common-lib.v2.pdb`
  use `csf-common-lib.v1.resourceName`, removed conditional object generation
- New function `csf-common-lib.v1.certificateValues`
- New function `csf-common-lib.v1.certificate`
- New function `csf-common-lib.v1.isEmptyValue`
- New function `csf-common-lib.v1.coalesceBoolean`
- New function `csf-common-lib.v1.release_name_check`

### Deprecated
- `csf-common-lib.v1.objectNameTemplate` - use `csf-common-lib.v1.resourceName` instead
- `csf-common-lib.v1.isEmpty` - use `csf-common-lib.v1.isEmptyValue` instead
- `csf-common-lib.v1.boolDefaultTrue` - use `csf-common-lib.v1.coalesceBoolean` instead
- `csf-common-lib.v1.boolDefaultFalse` - use `csf-common-lib.v1.coalesceBoolean` instead
- `csf-common-lib.v1.pdb` - use `csf-common-lib.v2.pdb` instead
- `csf-common-lib.v1.hpa` - use `csf-common-lib.v2.hpa` instead
- `csf-common-lib.v1.isHpaEnabled` - use `csf-common-lib.v1.coalesceBoolean` instead

## [1.4.0] - 2023-02-09
### Changed
- Skipped version.

## [1.3.0] - 2022-11-29
### Added
- New function `csf-common-lib.v1.topologySpreadConstraints`

## [1.2.0] - 2022-11-25
### Added
- New function `csf-common-lib.v1.kubeVersion`

## [1.1.0] - 2022-08-12
### Added
- New function `csf-common-lib.v1.hpaValues`
- New function `csf-common-lib.v1.hpa`
- New function `csf-common-lib.v1.isHpaEnabled`
### Changed
- For `unit-tests/csf-common-test`, moved the dependencies: block from
  `requirements.yaml` to `Chart.yaml` as per helm3 recommendation.
- Align helm unit test to the new format, since the helmUnitTests.py
  has breaking interface changes deployed in image csf-charts-tools:20220602-12650
- Enhance helm unit test to use the new format allowed in helmUnitTests.py 1.2.0

## [1.0.0] - 2022-03-30
### Added
- Initial `csf-common-lib` release
- New function `csf-common-lib.v1.customLabels`
- New function `csf-common-lib.v1.customAnnotations`
- New function `csf-common-lib.v1.commonLabels`
- New function `csf-common-lib.v1.selectorLabels`
- New function `csf-common-lib.v1.pdbValues`

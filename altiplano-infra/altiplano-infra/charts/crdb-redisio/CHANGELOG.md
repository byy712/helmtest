# Changelog
All notable changes to chart **crdb-redisio** are documented in this file.

## [Unreleased]

## [9.0.3] - 2024-02-07
### Fixed
- CSFOSDB-5197: intermittent lost slot during robustness testing
- CSFOSDB-5337: fix redisio_tools using instance.name instead of pod_name
- CSFS-57467: Admin probes cannot run when IPv6 disabled
### Changed
- CSFOSDB-5297: Update to redis.io 7.2.4
- CSFOSDB-5297: Update to redis.io 7.0.15 for rollback support
- CSFOSDB-5247: Update redis_exporter to v1.57.0
- CSFOSDB-5247: Update base image to rocky8-python311-nano:3.11.5-20240129
### Added
- CSFOSDB-5246: Support for Anti Affinity section of HBP 3.8

## [9.0.2] - 2023-12-11
### Fixed
- CSFS-56881: include rewriteAppHTTPProbers annotation in all injected containers
- CSFOSDB-5266: handle inability to reverse-resolve Service IPs (CSFS-56816)
### Changed
- CSFS-56766: Move rollback socket to /tmp and make configurable
- CSFS-56948: Update to redis++ 1.3.11
- CSFOSDB-5238: Update base image to rocky8-python311-nano:3.11.5-20231222
- CSFOSDB-5238: Update cbur-agent version to 1.1.1-alpine-6578

## [9.0.1] - 2023-12-07
### Fixed
- CSFS-56528: post-install is failing in ipv6-only setup
### Changed
- CSFOSDB-5116: removed jobs rules from RBAC Roles, excluding -delete
- CSFOSDB-5169: Update base image to rocky8-python311-nano:3.11.5-20231124
- CSFOSDB-5169: Update CLOG to 23.09 FP1
- CSFOSDB-5169: Update cbur-agent to 23.11
- CSFOSDB-5169: Update pypi packages to latest

## [9.0.0] - 2023-11-15
### Fixed
- CSFS-54474: Request to make the alarm service name configurable
- CSFS-55173: Passwords not persisted in all disaster recovery scenarios
- CSFS-55447: Redis-server is not come up when IPv6 is disabled in the VM
- CSFS-56002: containerNamePrefix not appending hyphen consistently
- CSFS-56051: Remove unused rules/verbs from runtime RBAC Role
- CSFOSDB-4990: Update admin-base to 6.1-7 for early pre_restore exit
- CSFOSDB-4998: Change to rebuild server.conf when zero-length file
- CSFOSDB-5002: scale in left master with no replicas
### Changed
- CSFOSDB-3780: Change controller type to Deployment for admin pod
- CSFOSDB-4713: Update to python 3.11
- CSFOSDB-4713: Remove centos7
- CSFOSDB-4736: Updated chart for Helm Best Practice 3.7.0 compliance
- CSFOSDB-5005: Include securityContext seccompProfile pre K8s 1.25
- CSFOSDB-5031: Update redis_exporter to v1.55.0
- CSFOSDB-5066: Create server-0 Service for simplex
- CSFOSDB-5080: Update to 20231017 base image
- CSFOSDB-5080: Update to cbur-agent to 22.09 FP4 PP1
- CSFOSDB-5080: Update to CLOG 23.09 PP1
- CSFOSDB-4700: Update csf-common-lib to v1.10.0
### Added
- CSFOSDB-4700: Missed requirements for Helm Best Practice 3.3.0
- CSFOSDB-4740: CRDB-redis.io support for Rollback from 7.2
- CSFOSDB-4744: Integration of Redis.io 7.2.3
- CSFOSDB-4783: Enhancement to prevent Sentinel cross talk
- CSFOSDB-4873: UK_TSR 8.1/8.5 Security Compliance

## [8.2.5] - 2023-11-07
### Fixed
- CSFS-56001: containerNamePrefix not appending hyphen consistently

## [8.2.4] - 2023-11-02
### Fixed
- CSFOSDB-5002: scale in left master with no replicas
- CSFS-55447: Redis-server is not come up when IPv6 is disabled in the VM
### Changed
- CSFOSDB-5027: Update redis.io to 7.0.14 (CVE-2023-45145)
- CSFOSDB-5029: Update redis.io used for rollback to 6.2.14 (CVE-2023-45145)
- CSFOSDB-5031: Update redis_exporter to v1.55.0
- CSFOSDB-5016: Update base image to 20231027
- CSFOSDB-5016: Updated to CBUR 22.09 FP4 cbura-agent:1.0.3-6028

## [8.2.3] - 2023-10-06
### Fixed
- CSFS-55173: Passwords not persisted in all disaster recovery scenarios
- CSFS-55615: Include securityContext seccompProfile pre K8s 1.25
- CSFOSDB-4700: Missed requirements for Helm Best Practice 3.3.0
- CSFOSDB-4998: Change to rebuild server.conf when zero-length file
### Changed
- CSFOSDB-4992: Update the crdb-redisio image to 20230928
- CSFOSDB-4990: Update admin-base to 6.1-7 for early pre_restore exit

## [8.2.2] - 2023-09-21
### Fixed
- CSFOSDB-4830: Missing import for SIGTERM
- CSFOSDB-4853: Syntax errors in redisio-manage
### Changed
- CSFOSDB-4892: Update redis.io to 7.0.13
- CSFOSDB-4927: Update redis_exporter to 1.54
- CSFOSDB-4926: Update crdb-redisio base image to 20230901

## [8.2.1] - 2023-08-14
### Fixed
- CSFS-53900: Ignore acl user rules when user-defined Secret provided
- CSFS-54151: Default dnsNames usnig wrong FQDN becasue of workload suffix
- CSFS-54295: Allow cluster install with slave-less shards
- CSFS-54304: Disable protected-mode check when default user has password in rules
- CSFS-54324: Selective module cleanup based on pre-stop coordination
- CSFS-54492: Added wait_istio_proxy to rolemon entrypoint
- CSFS-54548: Fix helm test for metrics with IPv6 Service address
- CSFS-54622: Upgrade failing for CRDB
- CSFS-54635: Post rollback CRDB admin pod is not coming up
- Partial rolemon container spec leaked into server container spec for simplex
### Changed
- Allow use of double-semicolon for newline in server.confInclude

## [8.2.0] - 2023-07-14
### Fixed
- CSFS-52737: crdb not support repl-diskless-load setting
- CSFS-53940: typo in chart preventing user-defined TLS secrets
- CSFS-53973: CRDB deployment is not working
- CSFOSDB-4705: helm test failing with replicaof in user ACL rules
### Changed
- CSFOSDB-4702: Update redis_exporter to v1.51.0
- CSFOSDB-4731: Update redis.io to 7.0.12
### Added
- CSFOSDB-4627: CRDB-redis.io support for Rollback over Major Release
- CSFOSDB-4684: Update base images to 3.6.8-20230630

## [8.1.0] - 2023-06-19
### Fixed
- CSFS-51991: auditlog Module needs to flush stdout with v1 unified logging
- CSFS-52457: Admin not explicitly setting container on all exec_pod()
- CSFS-52457: Issues with custom module during upgrade and rollback
- CSFS-52517: When enabling syslog logging for CRDB, TLS connections stay in FIN_WAIT2 status
- CSFS-52577: Apply containerNamePrefix to cbura-sidecar (support added by CBUR)
- CSFS-52640: Sentinel sdown events incorrectly firing as server down alarms
- CSFS-52892: Forced myid in sentinels with handling during pre-upgrade
- CSFS-52965: Shard failover always times out
- CSFS-52986: Updated cryptography to 39.0.2 for vulns
- CSFS-52991: Master link down alarm doesn't clear on slaves
- CSFS-53177: User secrets not being updated in certain scenarios
- CSFS-53590: Missing securityContext for module initContainers
### Changed
- CSFS-52892: Added statefulset access to pre-upgrade in RBAC
- CSFS-53093: Allow template partials in server.loadModules Value items
- CSFS-53457: Module loading done via server init containers instead of admin
- CSFS-53457: Updated os centos7 base image to 3.6.8-20230428
- CSFOSDB-4508: Updated os rocky8 base image to 3.6.8-20230602
- CSFOSDB-4508: Updated k8s-client base to 26.0.1-3
- CSFOSDB-4566: Updated to redis.io 7.0.11
- CSFOSDB-4566: Updated to latest admin-base with Redis 7.0.11
### Added
- CSFS-53457: Module consistency verification during helm test
- CSFOSDB-4497: Include csf-common-lib v1.5.0, add global.certManager, move tls secret and cert-manager certificate values per workload, add flat registry support, comment out cpu limits in values
- CSFOSDB-4498: Support for PVC-less configuration
- CSFOSDB-4508: CRDB-redis.io Container Size Reduction
- CSFOSDB-4529: Improved shard placement and audit for node placement

## [8.0.1] - 2023-04-09
### Fixed
- CSFS-52134: Failed pre-backup when AOF enabled
- CSFS-51529: Upgrade failing for CRDB with syslog enabled
- CSFS-51560: Restore of crdb fails when syslog is enabled
- CSFS-51642: TLS bye failed: Resource temporarily unavailable, try again.
- CSFS-52236: Incorrect handling of extraneous lines in cluster ConfigMap
- CSFOSDB-4531: fix bug in Modules.diff() causing KEYSTORE_DIR error in admin
### Added
- CSFOSDB-4504: Update CRDB-redisio to Redis 7.0.10
### Changed
- CSFOSDB-4506: Update CLOG to 22.11 FP1 PP1 and support syslog appender changes
- Updated flexlog to v2-3.0-2.99
- Updated redis_exporter to v1.49.0
- Updated redis-py to 4.3.6
- Updated CBURA image to 22.01 FP2
- Updated base images to 20230331
- CSFOSDB-4535: Update Redis Dashboard

## [8.0.0] - 2023-03-10
### Added
- CSFOSDB-4232: Integration of Redis.io 7.0.9
- CSFOSDB-4381: Support for rbac.psp.name and rbac.scc.name Values
### Fixed
- CSFS-50658: Quote custom label Values including global
- CSFS-50882: helm test fails when using non-default services.redis.port
- CSFS-51083: Default sentinel.metrics.image to server if null
- CSFS-51568: labels and annotations missing from logging-configmap
- CSFS-51531: allow PSP name to be customized to prevent name collision
- CSFS-51708: cannot upgrade crdb-redisio with enabling syslog
- CSFOSDB-4344: prestop hook fails on helm upgrade to new release
- ACL rules are always taken from values on upgrade
- Skip attempted switchover on shutdown for restore
- global.jobhookenable now defaults to false
### Changed
- CSFOSDB-4328: Admin pod specify container name on tests in case unexpected default
- CSFOSDB-4329: Standalone scale out with istio may not choose correct master
- CSFOSDB-4350: cluster scale-out can leave a master with no replicas
- CSFOSDB-4386: Update base images to 20230306
- CSFOSDB-4395: Updated cbura to 22.09 FP1 PP1
- Updated redis_exporter to v1.46.0
- Updated base images to latest versions

## [7.5.1] - 2022-12-22
### Fixed
- CSFS-50199: Correct case in StatefulSet used by lookup function for old K8s
- Image tags for non-server CRDB images retained in Release Values unexpectedly
### Added
- CSFS-50158: Automatically add rewriteAppHTTPProbers annotation when istio.mtls.enabled

## [7.5.0] - 2022-12-09
### Fixed
- CSFS-48822: Missing headless metrics services in istio deployment
- CSFS-49530: Added checks for cbur ephemeral-storage sizes
- CSFS-49737: Added Value for terminationGracePeriodSeconds for server Pods
- helm warnings about DEBUG env variable being defined multiple times
### Added
- CSFOSDB-2948: Add Sentinel Metrics support
- CSFOSDB-3667: Support for Kubernetes 1.25 (incl conditional PSP w/ Istio)
- CSFOSDB-3667: Support for conditional SCC w/ Istio
- CSFOSDB-3667: Support for imageFlavor/image.flavor Values
- CSFSODB-4115: CRDB-redis.io to support logging to syslog
- CSFOSDB-4132: Support headless service in support of metrics in an Istio environment
- CSFOSDB-4139: Support for install during upgrade (as subchart)
- Added debug command for tools user to ACL
### Changed
- CSFOSDB-3667: Updated chart for Helm Best Practice 3.1.0 compliance
- CSFOSDB-3667: Updated topologyKey to newer topology.kubernetes.io/zone
- Changed default cbur ephemeral-storage values to null to be auto-calculated
- Updated base images to latest versions
- Updated redis_exporter to v1.45.0

## [7.4.1] - 2022-10-04
### Fixed
- CSFS-48566: backwards compatibility with old BrPolicy API Version
### Changed
- CSFOSDB-4075: Removed disableIPv6 altering sentinel probe
- CSFOSDB-4101: Updated base images to latest ver 0926

## [7.4.0] - 2022-09-07
### Added
- Check to require protected-mode no when default user enabled w/o password
- CSFOSDB-3986: Add support for additional BrPolicy options
### Changed
- CSFOSDB-3970: BrPolicy to use apiVersion of cbur.csf.nokia.com/v1
- CSFOSDB-3974: Update base image to latest ver 0826
- CSFOSDB-3987: Removed Nokia URLs from Chart.yaml
- CSFOSDB-4003: Updated python dependencies to latest

## [7.3.2] - 2022-07-22
- CSFS-46667: properly preserve common.password as none

## [7.3.1] - 2022-07-14
### Fixed
- CSFS-46465: correct truncation of podPrefix and Job name
- CSFOSDB-3856: supervisord doesnt restart on container failure, causing CrashLoopBackoff
- CSFOSDB-3858: server probes updated to listen on IPv6
- CSFOSDB-3897: Pre-Rollback exception on v5.x.x Secret structure
### Changed
- CSFOSDB-3879: Check for unexpected dir config directive

## [7.3.0] - 2022-06-10
### Fixed
- CSFS-45790: Updated to admin-base 5.0+ for user-named Secret cleanup
### Added
- CSFOSDB-3685: Support for K8s dual-stack
- CSFOSDB-3685: server.customBind and sentinel.customBind Values
- CSFOSDB-3806: Resource ephemeral-storage values included by default
### Changed
- CSFOSDB-3578: Updated server container probes to be http-based
- CSFOSDB-3666: Updated chart for Helm Best Practice 3.0.0 compliance
- CSFOSDB-3685: Removed BIND env by default
- CSFOSDB-3815: Updated os rocky8 base image to 3.6.8-20220530
- CSFOSDB-3815: Updated os centos7 base image to 3.6.8-20220530
- CSFOSDB-3815: Updated admin-base to 5.1-2
- CSFOSDB-3815: Updated k8s-client base to 22.6.0-7
- CSFOSDB-3815: Updated redis_exporter to v1.39.0
- Job backoffLimit of 0 allowed instead of using default
- PodDisruptionBudgets named using pod-prefix
- Moved metrics Service port Values to services section
- Add -c option to $REDIS_CLI when cluster.enabled
- Requires image(s) v4.3+ for new http probe interface
### Removed
- CSFOSDB-3685: Removed support for disableIPv6 Value

## [7.2.0] - 2022-04-11
### Fixed
- CSFS-43354: Add timeZone handling to compat for upgrade from pre-7.x chart
- CSFS-43421: fix custom labels/annotations for quoted values
- CSFS-43682: fix PDB Values to allow maxUnavailable over minAvailable
- CSFS-44270: metrics container not connecting when TLS enabled
- CSFS-44270: tests require service token when istio.enabled
### Added
- CSFOSDB-3537: Support for list-based nodeSelector Values
### Changed
- CSFOSDB-3587: Added more commands for metrics-user to ACL
- CSFOSDB-3590: Updated os rocky8 base image to 3.6.8-20220328
- CSFOSDB-3590: Updated os centos7 base image to 3.6.8-20220301
- CSFOSDB-3590: Updated admin-base to 5.0-2
- CSFOSDB-3590: Updated k8s-client base to 22.6.0-4
- CSFOSDB-3590: Updated redis_exporter to v1.37.0
- CSFOSDB-3601: Implement helm testing in admin pod (vs chart pods)
- Changed artifactory repo to repo.cci.nokia.net
- Granted status RBAC to admin ServiceAccount
- Granted job RBAC to prelcm ServiceAccount

## [7.1.0] - 2022-02-02
### Fixed
- CSFS-41704: Update redisio to 4.1-1 for pre-stop data loss improvement
- CSFS-42624: Fix imagePullSecrets in specs
- CSFS-42954: missing tolerations support on Jobs
### Added
- CSFOSDB-3349: Support liveness for the rolemon container
- CSFOSDB-2406: Add parameter and alarms for expiring certificates
- CSFOSDB-2406: Updated rolemon and admin pods to get cert updates when cert-manager publishes them
- CSFOSDB-2406: Added config for server auto-rollout if certs are updated without pod restart
- CSFOSDB-3478: Updated os base images to 3.6.8-20220128
- CSFOSDB-3478: Updated admin-base to 4.2-3
- CSFOSDB-3478: Updated k8s-client base to 19.15.0-7
- CSFOSDB-3478: Updated redis_exporter to v1.34.1
### Changed
- CSFOSDB-3419: Updated chart for Helm Best Practice 2.1.0 compliance
- CSFOSDB-3478: Updated admin pod to 512Mi limit for new k8s_client

## [7.0.2] - 2021-12-03
### Fixed
- CSFS-41942: admin entrypoint needs addl proxy wait for istio
### Changed
- CSFOSDB-3357: force-disable default user in ACL when acl.default.enabled=false
- CSFOSDB-3357: helm test password-less access disabled when default user disabled

## [7.0.1] - 2021-11-01
### Fixed
- CSFS-40621: check-metrics-status test using services instead of pod IPs
- CSFS-40650: update redisio image to 4.0-2 for null masterauth fix on nopass
- CSFS-40783: update redisio image to 4.0-2 for entrypoint groupName fix
### Changed
- Updated CBUR sidecar image to latest available
- Added metrics-type label to Services related to metrics
### Added
- CSFOSDB-3296: lookup of 5.x password with migrateFromChartVersion Value
- CSFOSDB-3301: Updated admin-base and centos7 base

## [7.0.0] - 2021-10-08
### Fixed
- CSFS-37389: include +bgrewriteaof to crdb-tools-user ACL
- CSFS-37939: Fixed typo in startupProbe
- CSFS-39417: CBUR BrHooks missing volumes for readOnlyRootFilesystem
- CSFS-39915: loadModules Value support broken by container prefix
- CSFS-40329: removed istio Role and RoleBinding when cni.enabled
### Changed
- Add release to CBUR policy matchLabels
- Updated to redis_exporter v1.27.1
- Refactored ACL and credential-related Secrets
- Updated to apiVersion 2
### Removed
- Support for helm2
### Added
- CSFOSDB-3128: Updated admin-base and improved admin DB auth
- CSFOSDB-3193: missing acl.*.secretName from values.yaml comments
- CSFOSDB-3093: Support of PodDisruptionBudget
- CSFOSDB-3093: Support for PodTopology Spread Constraints
- CSFOSDB-3093: Support for tolerations on Statefulsets
- CSFOSDB-3093: Support for nodeSelectors on Statefulsets
- CSFOSDB-3093: Support for priorityClassName on Statefulsets
- CSFOSDB-3198: Support for acl.*.credentialName for credential passing

## [6.1.2] - 2021-09-29
### Fixed
- CSFS-40474: updated to 3.4-3 for podNamePrefix fixes
- CSFS-40474: removed *_ANNOUNCE_IP env variables from StatefulSet

## [6.1.1] - 2021-09-15
### Changed
- CSFOSDB-3222: updated admin-base and cbur images for vulns

## [6.1.0] - 2021-07-15
### Fixed
- CSFS-38203: Updated default values to use el7 images
- CSFS-36003: Server metrics container unset AUTH variable
- Incorrect ConfigMap mount path in admin Jobs
### Changed
- CSFOSDB-2471: Updated chart for Helm Best Practice v192 compliance
- Moved rbacEnabled to rbac.enabled
- serviceAccountName always included if passed in Values
- initContainers use same, configurable, resources from primary container
- Pre-Rollback and Pre-Delete Jobs use prelcm SA
- Added release to K8S_LABELS
- CSFOSDB-3087: Update server statefulset to include a startupProbe
### Added
- CSFOSDB-1664: Support for server.auditLogging Values
- Support for podSecurityContext and containerSecurityContext Values
- Istio Policy and DestinationRule to exposure Services
- VolumeMounts and Volumes for mapping Timezone into containers
- Values to disable Timezone mounts and add TZ env into containers
- Helm Test resources configurable via Values
- CSFOSDB-2892: Support for per-user Secrets
- CSFOSDB-3057: Support for fifoPath Value
- CSFOSDB-2923: include HOME in admin env for kubectl cache purposes
- CSFOSDB-2923: readOnlyRootFilesystem enabled and related emptyDir volumes
- CSFOSDB-3122: support for disableIPv6 Value (no bind to ::1)

## [6.0.5] - 2021-03-30
### Fixed
- Render problem with test-cluster-status helm test
### Changed
- Updated images to 3.2-1 for admin orchestrator probe improvement (CSFS-35782)
- Updated images to 3.2-1 for vulnerabilities in underlying base
### Added
- Support for TLS and related certificates (CSFOSDB-2653)
- Check for cluster.enabled and sentinel.enabled

## [6.0.4] - 2021-02-24
### Fixed
- Invalid kubectl exec syntax in Helm test test-server-config-files
### Changed
- Replaced invalid-password test with password-required test
- Refactored helm tests to use setup template function
- Revised Helm best practice labeling (CSFOSDB-2738)
### Added
- Support for Automatic backup on upgrade (CSFOSDB-2214)

## [6.0.2] - 2021-01-31
### Fixed
- Updated audit-not-disabled helm test to kill istio proxy (CSFOSDB-2769)
### Added
- Support for Helm best practice labeling (CSFOSDB-2738)

## [6.0.1] - 2021-01-25
### Fixed
- Updated incorrect acl user example in crdb-redisio values (CSFOSDB-2744)
- Updated test-rolemon-labels test to translate IPv6 per rolemon (CSFS-32965)
- Added missing HOOK_TIMEOUT to BrHooks and NCMS Jobs (CSFS-31170)
- Updated auth-encrypt Secret to be derived from image (CSFS-33183)
### Changed
- Changed deprecated RBAC API v1beta1 to v1
- Added ::1 to bind for IPv6 support (CSFS-32965)
### Added
- Ability to tune Readiness and Liveness probes via Values
- Ability to disable Cluster Audit via Values

## [6.0.0] - 2020-11-03
### Fixed
- test-redisio-connection Test missing Yaml file separator
### Changed
- Config import directory from /import to /import/config
- Updated images to 3.0-1 for Redis6
- Removed common from Values
- Updated minimum image requirements to 3.0
- Moved helm test templates to tests/tests.tpl
### Added
- Support for Redis6 ACL and necessary Values
- ACL import from /import/acl

## [5.7.4] - 2020-10-15
### Changed
- Updated images to 2.12-2 for improved socket timeout defaults
- Updated images to 2.12-2 for additional cluster scaling improvements (CSFOSDB-2168)

## [5.7.3] - 2020-10-12
### Changed
- Updated images to 2.12-1 for cluster Audit detection of no replicas
- Updated images to 2.12-1 for cluster Audit handling scale (CSFOSDB-2168)
- Updated images to 2.12-1 for admin base wait_istio_proxy --fail (CSFS-29616)
- Updated test-redisio-marker-files to use less kubectl calls
- Renamed the Pre-Install/Upgrade RBAC as was confusing on upgrade
- Added before-hook-creation policy to prelcm RBAC resources
- Increased default timers for preUpgrade as they are much too short for scale-in

## [5.7.2] - 2020-10-06
### Fixed
- Removed cluster port from per-node (pod) services when not enabled
- Fixed csf-subcomponent label on admin-event configmap
### Changed
- Updated images to 2.11-3 for rolemon IPv6 compatibility
- Updated images to 2.11-3 for admin py3 issue with redis-cluster (CSFOSDB-2607)
### Added
- Server metrics now exposable on per-node (pod) services (CSFOSDB-2581)

## [5.7.1] - 2020-09-02
### Fixed
- Added missing ServiceAccount to helm tests
### Changed
- Updated images to 2.11-2 for admin base missing curl (CSFS-28252)
- Updated images to 2.11-2 for failed sync temp file cleanup (CSFS-27839)

## [5.7.0] - 2020-08-29
### Changed
- Updated images to EL8 2.11-1

## [5.6.4] - 2020-08-17
### Changed
- Updated images to 2.10-5 for additional changes for arbitrary UID support
### Added
- Redis Cluster robustness audit timers to Values (CSFS-27642)

## [5.6.3] - 2020-07-24
### Fixed
- Removed creation of PSP and related Role/RoleBinding when serviceAccount passed
### Changed
- Added k8sobjects to BrPolicy to backup Secret (CSFOSDB-2496)
- Specify delete policy for all helm tests
### Removed
- null nodeSelector properties from values.yaml as it caused misleading helm warning

## [5.6.2] - 2020-07-16
### Fixed
- Render problem on CBUR BrHooks missing global scope on .Values (CSFOSDB-2491)
### Changed
- Increased Maximum serverCount in values-yaml from 9 to 200
### Removed
- Unused server.numDatabases from values

## [5.6.1] - 2020-07-10
### Fixed
- When using helm 2.16.8, install failed due to template issue (CSFS-26410)
### Changed
- Updated images to 2.10-3 for indefinite slave wait on install
### Added
- Added clusterDomain to values model
- Istio sidecar injection annotation to not depend on namespace auto-injection
- Consolidate helm test for marker files and add check for .master

## [5.6.0] - 2020-07-02
### Changed
- Updated images to 2.10-2 for underlying FOSS updates (CSFOSDB-2392)
- Removed if rbacEnabled on admin statefulset securityContext
### Added
- Support for server.loadModules (CSFS-24570)
- Ability to pass a serviceAccount disabling creation of RBAC Resources (CSFOSDB-2396)
- admin statefulset preStop to save database to disk (CSFOSDB-2425)
### Removed
- IS_HELM_UPGRADE from server Statefulset causing RollingUpdate on any first upgrade

## [5.5.6] - 2020-06-09
### Changed
- Updated to admin image to 2.9-7 for pre-rollback fix (CSFOSDB-2387)

## [5.5.5] - 2020-05-29
### Changed
- Updated images to 2.9-6 for Recovery after ReInstall enhancement (CSSOSFB-2165)
- Added post-restore to server-cbur-policy BrPolicy for cluster node restore
### Added
- BrHooks implementation for updated CBUR integration (CSFOSDB-2164)
- Support for addlSecretAnnotations and addlSecretLabels for Secret discovery (CSFS-24663)

## [5.5.4] - 2020-05-08
### Changed
- Updated redisio image to 2.9-5 for sentinel docker-entrypoint.sh fix (CSFS-24230)

## [5.5.3] - 2020-05-05
### Changed
- Renamed all ports to include tcp- prefix
- Fixed syntax error in cli-cluster-check test (CSFOSDB-2333)
- Updated images to 2.9-4 to include cluster fix (CSFS-24052)

## [5.5.2] - 2020-05-04
### Changed
- Structure of tests to be single container only to simplify killing istio proxy
### Added
- Support for Istio
- Missing default nodeAntiAffinity to values.yaml

## [5.5.1] - 2020-04-23
### Added
- Pre-Stop lifecycle hook to servers to issue sentinel failover when master

## [5.5.0] - 2020-04-17
### Fixed
- Added pre-upgrade hook to admin-secrets
- Added hooks Values object to values-compat
- Removed leading . in values-compat clusterDomain
### Changed
- Improved semver check
- Updated minimum required image version of 2.9.1 to support admin
- Added optional flag to event-cm for pre-upgrade Job
- Updated server reference in values-image-version-check in error message
- Updated various references to Redis per trademark policy
- Updated pre-install Job to use install RBAC
### Added
- Pre/Post Rollback Jobs and admin implementation
- Admin chart migration detection and implementation
- Added create to main RBAC
- Added IsUpgrade env for servers to avoid forced-master
### Removed
- Removed ASCII-art logo from NOTES.txt per trademark policy
- Removed admin-secrets as pre-install hook

## [5.4.2] - 2020-03-20
### Fixed
- Added necessary changes to ComPaaS values files for metrics and backup hooks
### Changed
- Updated redisio image to remove gethostbyname in docker-entrypoint.sh for IPv6

## [5.4.1] - 2020-02-28
### Changed
- Updated images to 2.8-1 to include tools updates for cluster robustness audit
- Updated default cbura image to 1.0.3-1665
- Updated images to CRDB 2.9 for cluster robustness enhancements per CSFOSDB-2042
### Added
- AntiAffinity node-control label for pod rescheduling
- RBAC rules for listing Statefulset

## [5.4.0] - 2019-12-31
### Changed
- Updated images to 2.8-0 for Redis.io 5.0.7, redis-py 3.3.11, and exporter 1.3.4
- Updated Statefulsets to apiVersion apps/v1
### Added
- Support for Redis Cluster
- apiVersion to Chart.yaml
- New clusterDomain value
- Values to allow disabling job hooks
- admin-event ConfigMap for upgrade event handling and args
- tests for unexpected marker files

## [5.3.1] - 2019-11-06
### Changed
- Added injection of replicaof to server config during install for CSFS-18112
- Added test for ensuring replicaof in saved config

## [5.3.0] - 2019-09-10
### Changed
- Updated images to 2.7-1 to include tools updates and redis-py v3.3.7
- admin image updated to use nano-based base image
- Updated to redis_exporter v1.1.1
- sentinel resources are excluded on singleserver (server.count=1)
- rolemon excluded on singleserver (server.count=1) for CSFOSDB-1571
### Added
- Image version check to prevent problematic helm upgrades with old images
- NCMS Restore plugin hook jobs for CBUR
- Support for nodeSelector values for server and sentinel
### Removed
- Removed pre/post restore from CBUR policy

## [5.2.11] - 2019-09-10
### Fixed
- Fixed values-compat merging of metrics-related values not allowing disabled metrics
- Added *.src to helmignore to exclude files from packaging

## [5.2.10] - 2019-09-06
### Changed
- Updated to images for 2.6-3 to increase all socket_timeout default values to 2.0s

## [5.2.9] - 2019-09-05
### Changed
- Updated to images for 2.6-2 to include entrypoint change for setup_include during init
- Updated to images for 2.6-2 to include sentinel_monitor thread exception change

## [5.2.8] - 2019-08-21
### Fixed
- Added command without redisio-monitor to prevent harmonize_log reaping
### Changed
- Updated to images for 2.6-1 to include rolemon label resource util enhancement

## [5.2.7] - 2019-08-20
### Changed
- Updates to crdb-redisio-test to integrate with CCTF launch script
- Included newer images with flexlog 1.1-5.103

## [5.2.6] - 2019-08-06
### Fixed
- Added configmaps to post-delete RBAC Role

## [5.2.5] - 2019-07-29
### Changed
- Added values-compat to fix upgrade compatibility issues with metrics and cbura

## [5.2.4] - 2019-07-26
### Changed
- cbura image name and tag in values-model for ComPaaS

## [5.2.3] - 2019-06-26
### Changed
- Updated to nano-based images
### Added
- Checks to skip invalid password helm test when password not used

## [5.2.2] - 2019-06-19
### Added
- Support for nodePort port specification in values and services
- Support for server.tmpfsWorkingDir for tmpfs-backed database
- Helm tests for rolemon-managed pod labels

## [5.2.1] - 2019-06-13
### Changed
- Increased default rolemon container memory limit to 256Mi
- Fixed incorrect default image tag

## [5.2.0] - 2019-05-31
### Changed
- Updated images to 2.5-1 to incorporate alarm handling

## [5.1.0] - 2019-05-28
### Changed
- Updated redisio entrypoint to resolve SLAVE_ANNOUNCE_IP from a name to an IP
- Updated redisio entrypoint to remove replicaof/slaveof entries from server conf
- Added crdb-redisio-test template
- Redis to version 5.0.5
- CRDB tools to 2.4-1
### Added
- Added metrics sidecar container support to server statefulset
- Added server dashboard configmap for Grafana integration

## [5.0.2] - 2019-05-01
### Changed
- Updated images to latest based on changes to Jenkins build

## [5.0.1] - 2019-04-29
### Added
- values-model.yaml and values-template.yaml.j2 for ComPaaS UI

## [5.0.0] - 2019-04-08
### Changed
- Updated to new redisio and admin images for CSFS-11265
- Sentinel datadir to be based on emptyDir volume
- Helm render tests as needed for chart changes
- Redis to version 5.0.4
- Redis-py to version 3.2.1
### Added
- Per-pod service for servers
- Master and Num_Slaves labels on server pods for better status visibility
### Removed
- PVCs from Sentinel Statefulsets
- Server node headless service
- fsGroup from container spec in Statefulsets

## [4.1.2] - 2019-02-06
### Changed
- Updated base images and tool dependencies

## [4.1.1] - 2019-01-30
### Fixed
- Corrected RBAC hook weights to be unique

## [4.1.0] - 2019-01-23
### Changed
- Modified RBAC definition to be more selective for enhanced ComPaaS security
- Updates test Pods to have requests and limits set

## [4.0.3] - 2019-01-16
### Fixed
- Check for cbur.enabled=false to exclude cbur manifest

## [4.0.2] - 2019-01-08
### Changed
- CRDB tools to v2.3.2

## [4.0.1] - 2018-12-31
### Fixed
- Invalid kubectl command in NOTES when admin.debug enabled
### Changed
- CRDB tools to v2.3.1
- Changed environment-based config to use _CRDB_REDISIO prefix
### Added
- Added basic helm test cases
- Added post-install hook Job to wait for pods to be Running
- Added pre-delete hook Job to cleanup preceeding Jobs

## [3.2.2] - 2018-12-20
### Fixed
- confInclude Values causing invalid yaml
### Changed
- Changed chart to be built in different git repo
### Added
- Added render-test

## [3.2.1] - 2018-11-29
### Changed
- Changed default images to use 2.2-1.367 with Redis 5.0.2

## [3.1.1] - 2018-11-07
### Fixed
- Fixed exposed services to use groupname instead of fullname

## [3.0.4] - 2018-11-07
### Changed
- Modified fullname template to support fullnameOverride and Release Name suffix

## [3.0.3] - 2018-11-06
### Fixed
- Corrected nameOverride handling when groupName null

## [3.0.2] - 2018-10-31
### Added
- Added resources to all containers for ComPaaS

## [3.0.1] - 2018-10-30
### Changed
- Refactored image and imageTag into partial template include
- Altered image-related value structure
- Updated NOTES to use redis:// URI
### Added
- Added support for CBUR-based Backup/Recovery

## [2.1.2] - 2018-10-25
### Fixed
- Fixed noauth with common.password=none

## [2.1.1] - 2018-10-15
### Fixed
- Compaas storageclass in stateful sets
### Changed
- Removed storageClass value to force use of default

## [2.0.1] - 2018-09-25
### Changed
- Improved support for Healing of restarted Pods
- Restructure of configuration files in Pods
- Changed priority of storageClass values
### Added
- Access to master and slave pods through services
- Access to sentinel through service
- Server sidecar for managing labels
- Support for persistence on sentinel

## [1.0.2] - 2018-09-07
### Changed
- Removed chart name and version as a resource label
- Added selector to statefulsets

## [1.0.1] - 2018-08-30
### Added
- Initial Release of crdb-redisio Chart

## Entry Template:
## [0.0.0] - YYYY-MM-DD
### Added | Changed | Deprecated | Removed | Fixed | Security
- your change summary, this is not a **git log**!

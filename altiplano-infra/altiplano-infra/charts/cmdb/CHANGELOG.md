# Changelog
All notable changes to chart **cmdb** are documented in this file,
which is effectively a **Release Note** and readable by customers.

Do take a minute to read how to format this file properly.
It is based on [Keep a Changelog](http://keepachangelog.com)
- Newer entries _above_ older entries.
- At minimum, every released (stable) version must have an entry.
- Pre-release or incubating versions may reuse `Unreleased` section.
## [Unreleased]

## [9.2.1] - 2024-04-24
### Fixed
- CSFS-58242: PWD change job aborted due to other inprogress job in race condition
- CSFS-58329: Update CMDB app.kubernetes.io/name label based on HBP common lib for podAntiAffinity to work
- CSFS-58350: CMDB is not preserving during restore
- CSFS-58490: CMDB 23.09 FP2 (9.2.0) Post upgrade is failing with Simplex cluster type
- CSFS-58397: CSF4LS#3253- Query relating to maxscale primary role switchover
- CSFOSDB-5562: Clear alarms when admin pod recovers
- CSFS-58574: Auto-injected sidecar resources are not defined
- CSFS-58711: Backup failing for simplex cluster
- CSFOSDB-5591: Incorrect ownershp of datadir during VM restore
### Changed
- Update CBUR sidecar image to CBUR 23.11 FP1
- Add delay to invoke passwd change job after restore

## [9.2.0] - 2024-03-13
### Fixed
- CSFS-57092: Rebuild slave does not work in pure IPv6 environment (joinerBind)
- CSFOSDB-5313: Support permissive for istio.mtls.mode
### Changed
- CSFOSDB-5165: Password sync for built-in users after a restore
- CSFS-56868: No serviceaccounttoken attached in mariadb pod in CMDB 9.1.2 if istio and cni are enabled
- Upgrade mysqld-exporter to 0.15.1
- Upgrade MariaDB to 10.11.7
- Upgrade mariadb Pyton connector to 1.1.10
- CSFS-57452: Remove Roles created without any rules in CMDB chart
- CSFS-57568: cnfc_uuid is same for all deploy/sts
- Update base image to rocky8-python311-nano:3.11.5-20240301
- CSFOSDB-5415: Remove operator configuration from documentation
### Added
- CSFOSDB-4825: Audit and recreate admin secret if deleted
- CSFOSDB-5211: CMDB support for HBP 3.8
- CSFS-56573: Request new parameter (tls.mode) for CMDB installation
- CSFOSDB-5129: Validate and Integrate CBUR snapshot feature
- CSFOSDB-4631: Simultaneous Scale for both MaxScale and MariaDB pods
- Enhanced replica-monitor to better manage auto-scale jobs
- CSFS-55877: Raise AdminPodFailure alarm on admin pod restart or crash

## [9.1.3] - 2024-01-09
### Fixed
- CSFS-56933: Silent OOM observed in mariadb pods.
### Changed
- Update base image to rocky8-python311-nano:3.11.5-20231222
- CSFOSDB-5268: Update CBUR to 23.11 PP1
- CSFOSDB-5273: Changing BDH version and softwareName

## [9.1.2] - 2023-12-13
### Fixed
- CSFS-56366: Remove configuration of CHAS in bootstrap
- CSFS-56426: Implement fix/workaround to mariadb connector python memory leak issue
- CSFOSDB-5207: Must grant READ_ONLY ADMIN privilege to maxscale user
- CSFS-56271: Use of psp.yaml in cmdb
- CSFOSDB-5215: Update cryptography to 41.0.7 to resolve CVE
### Changed
- Update base image to rocky8-python311-nano:3.11.5-20231124
- Update zt-proxy image to 1.1-3.35
- CSFOSDB-5126: Upgrade to maxscale-23.08.4 to get fix to disallow deprectated TLS versions
### Added
- Generate alert when ssl_version set to TLSv10, TLSv11, or MAX

## [9.1.1] - 2023-11-14
### Fixed
- CSFOSDB-4980: Major Version Rollback (from 9.0.0 to 8.7.1-beta) is failing on EKS and TKG
- CSFS-54733: observing frequent admin pod liveness probe failures
- CSFS-55489: Some of the cmdb services are with IPv6 and some of them are with IPv4 when ipFamilies is set to Ipv6 in dualstack deployment
- CSFS-55792: Post cmdb upgrade, applications are not able to access the DB if cmdb-mariadb-rs-0 pod becomes master
- CSFS-56005: CSF4LS#2602 21.12 FP5 PP3 || mariadb-Admin pod call password-update for maxscale user and success even authentication failed.
- CSFS-56053: CMDB - ServiceAccount tokens mounted in the Kubernetes pods have privileges to list secrets
- CSFS-55419: CMDB 21.12 FP6 PP2, disable ssl failed
- CSFS-55991: pre-upgrade job is failing during cmdb major upgrade from old release
- CSFS-55424: cmdb helm chart documentation improvement
- pre-migrate/rollback handle case where container prefix changes format
### Changed
- Upgrade MaxScale to maxscale-23.08.3
- Change default pre-rollback job timeout to 1200 (from 300)
- CSFOSDB-5005: Include securityContext seccompProfile pre K8s 1.25
- Upgrade to redis-7.0.14 for admin pod (CVE-2023-45145)
- Upgrade CBUR agent to 22.09 FP4 PP1 with tag 1.0.4-6312
- Upgrade redis-py to 5.0.1
- Upgrade csfdb-zt-proxy to 1.1-2.33
### Added
- CSFOSDB-4954: CMDB-Security Compliance UK_TSR8.1
- CSFOSDB-4955: CMDB-Security Compliance UK_TSR8.5
- CSFOSDB-4952: Support HBP 3.7
- CSFOSDB-4837: Support TLS and non-TLS interfaces simultaneously
- CSFOSDB-4937: Support update of built in users secret when GR is enabled post install
- CSFOSDB-5100: Extend support for older relasess upgrade to 23.09
- CSFOSDB-4347: CMDB support to set server id

## [9.0.1] - 2023-09-20
### Fixed
- CSFOSDB-4780: Support sql_mode with padding
- CSFS-54707: CMDB restore fails due to sqlmode=ORACLE
- Remove quote for mariadb pdb minAvaliable and maxUnavailable
- CSFOSDB-4931: CMDB: hpa-scale tests for "mariadb-cpu-hpa-scale, mariadb-mem-hpa-scale" are failing for EKS
- CSFOSDB-4944: CMDB: upgrade tests are failed due to pre-upgrade is failing in case of Istio is enabled on OCP,EKS,GKE,AKS,TKG
### Changed
- Remove support for legacy ncms restore hooks
- MariaDB major upgrade to MariaDB-10.11.5
- MaxScale upgraded to maxscale-23.02.4
- Support for centos7 and python3.6 has been removed
- Per-pod mariadb service is fixed, no longer an option
- cooperative_monitoring_locks moved to maxscale-tools default config
- CSFOSDB-4845: Remove support for Galera Arbitrator
- Need to create additional RBAC for MU rollback in istio
### Added
- CSFOSDB-4779: CMDB B/R related enhancements
- CSFOSDB-4690: Support rocky8 python3.11
- CSFOSDB-4637: Support rollback over major upgrade
- CSFOSDB-4698: Support HBP 3.5/3.6
- Added jemalloc library for mariadb memory fragmentation

## [8.7.0] - 2023-07-26
### Fixed
- CSFS-54206: RBAC permission issue for pod/ephemeralcontainers resources with cmdb-8.6.1 chart
### Changed
- CMDB 21.12 FP7 (VM features) - chart re-released
### Added
- CSFOSDB-4767: Option per-pod service to be created for any deployment

## [8.6.1] - 2023-07-12
### Fixed
- CSFOSDB-4692: Make initContainers resources configurable for NCS tenants
- CSFS-52046: Useless RBAC created when istio.cni disabled
- CSFS-53874: Make cbur.apiVersion configurable.
- CSFOSDB-4716: Remove tar packge after unpacking to reduce disk usage during restore.
### Changed
- Upgrade base images to 0630
- Upgrade CBUR to 22.08 FP3
- Upgrade CLOG to 22.11 FP2 PP1

## [8.6.0] - 2023-06-19
### Fixed
- CSFOSDB-4538: Rebuild CMDB exporters to resolve vulnerabilities
- CSFS-52787: Upgrade for cmdb is failing from simplex to master-slave
- CSFS-52590: CMDB disk alarm threshold gets reflected until pod restart
- CSFOSDB-4619: With SelectPod on, choose master for backup when slaves are unavailable
- CSFS-52190: cmdb scale out is failing in the TKG env
- CSFS-52835: Not able to change system user password
- replica-monitor prints external job in progerss every 30 seconds, not once
### Changed
- Upgrade MariaDB to MariaDB-10.6.14
- Upgrade MaxScale to maxscale-23.02.2
- Upgrade to CLOG 22.11 FP2
- Added full deployment RBAC to admin container to manage major upgrade rollback
- CSFOSDB-4494: Support for HBP 3.4.0
### Added
- CSFS-52802: Support for adding custom annotations/labels per workload type
- CSFOSDB-4512: CMDB support for Zero Trust
- Add RBAC to allow admin pod to add ephemeral containers to pods

## [8.5.3] - 2023-04-03
### Fixed
- CSFS-51969: MariaDB auditlog is crashing
- CSFS-51527: Upgrade failed for CMDB with syslog enabled
- CSFS-51590: Backup of cmdb fails when syslog is enabled
- Database migration can crash if no upgrade to be performed
### Changed
- CSFS-50885: Update CBUR 22.01 FP2 and automatically select CBUR API version
- CSFOSDB-4463: Update CLOG to 22.11 FP1 PP1 and support syslog appender changes
- Update base images to latest centos7/rocky8 images
- cmdb-8.5.2 chart DEPRECATED - update gnutls packages

## [8.5.1] - 2023-03-21
### Fixed
- need values-compat injection for mariadb.backupRestore defaults
- need values-compat injection for maxscale HPA structure
- CSFOSDB-4340: Retry decryption to support both md5 and sha256 packages(CSFS-50753)
- CSFS-50992: not able to deploy cmdb chart in CSFP21 FP5 template
- seccomp error when installing in istio in older kubernetes environment
- cluster/node heal broken
- CSFS-51031: Update brpolicy to prevent two backup running simultanously
- cannot upgrade cmdb chart with enabling syslog
- additional security hardening of docker image files
- CSFS-51410: Incorporate new flexlog to fix fluentd issues
- CSFS-51981: cmdb installation failed in istio with cni enabled
### Changed
- kubernetes probes changed to HTTP-based probes
- Upgrade redis to 6.2.11 for CVE
- Remove MariaDB-compat for newer Rocky8 distributions
- workload pullSecrets renamed to imagePullSecrets (per HBP 3.3.0)
- Add maxscale.hpa.predefinedMetrics to comply with HBP 3.3.0
- CSFOSDB-4391: Increase MASTER_HOST limit from 60 to 255 characters
- remove setuptools python package from docker containers
### Added
- CSFOSDB-4145: Support for HPA for mariadb pods
- deployRequires to specify number of pods required during deployment
- CSFOSDB-4036: CMDB Advanced automated regression tests for NCS Env.
- CSFOSDB-4296: Support for startup probes
- CSFOSDB-4345: Allow configuration of configmap mounted on /import/initdb.d
- CSFOSDB-4365: Changes for HBP 3.3.0 compatibility
- CSFOSDB-4370: Upgrade MariaDB to 10.6.12, MaxScale to 22.08.4

## [8.4.4] - 2023-01-10
### Fixed
- CSFOSDB-4263: Need to remove systemd and dbus packages from all container images
- CSFS-50154: Need to send TZ environment to metrics and cbura-sidecar containers
- maxscale docker-helper.py --create-servers does not add new servers to maxscale config
- update python package certifi-2022.12.07
- CSFS-49732: Restore terminated and pod crashed for large DB
- CSFS-48362: Metric container uses much CPU in cmdb-8.2.3

## [8.4.3] - 2022-12-05
### Fixed
- Updated TLSv1.3 to use image flavor

## [8.4.2] - 2022-12-02
### Fixed
- CSFOSDB-4130: datacenter-monitor exception after setting remote replication
- CSFS-49461: CMDB upgrade from 8.0.2 to 8.3.2 failed due to ep issue
- CSFS-49249: CMDB cant be installed on EKS1.22 due to EP permission
- CSFS-49456: CMDB 8.3.2 post-upgrade failed.
- CSFS-49834: pkill not available in mariadb pod causes failure of mariadb_rebuild_slave
- CSFOSDB-4015: Force md5 hash for openssl
### Changed
- Removed inclusion of systemd and dependencies in container images
- MariaDB upgraded to 10.6.10
- MaxScale upgraded to 22.08.1
- Tighten PodSecurityPolicy for kubernetes versions <1.25
- Change default image to rocky8
### Added
- Support for Kubernetes v1.25.0 (removal of PSP in istio)
- Support for optional creation of SecurityContextConstraints (SCC) in OpenShift
- CSFOSDB-4087: Support for HBP 3.1
- CSFOSDB-3954: Support enabling TLS as part of upgrade
- CSFOSDB-4121: Support creation of ServiceEntry resources in geo istio
- CSFOSDB-4028: Support for HPA for maxscale pods
- CSFOSDB-4141: Support for image flavor (rocky8/centos7)
- CSFOSDB-3977: CMDB enable TLS termination in CITM
- CSFOSDB-4096: Support for logging to syslog
- CSFOSDB-4198: Support migration of data if an "old" database is detected

## [8.3.1] - 2022-09-21
### Fixed
- CSFS-48132: Mariadb bin log cleanup didnt happen in Master even though clean_log_interval was set
- CSFS-48141: Not able to install cmdb helm chart with galera mode using 8.3.0
- CSFOSDB-4043: Address TLS Geo-redundant issue with get_remote_master ( CSFS-47317 )
- CSFOSDB-4033: Default hash for storing config file checksums to SHA256 ( CSFS-47825 )
- CSFOSDB-4060: Operator adoption of standalone helm deployment fails
- admin.env keeps growing in mariadb/maxscale containers
- CSFS-47269: Mariadb-brhook-prebackup pod goes to err state due to minlcm SA
- CSFS-48203: CMDB restore fails due to .nfs file
- CSFS-47978: RMT_ACCESS_FAIL is cleared in failure condition
- CSFS-46871: CMDB restore fails on backup pvc disabled.
- CSFS-47970: Disaster Recovery - maxscale pods down after restore
- CSFS-47825: CMDB 8.2.4 deploy failing in fips enabled el8 host

## [8.3.0] - 2022-08-26
### Fixed
- CSFS-46712: CMDB legacy password change logs the credentials
- Update brpolicy default dir to /mariadb/backup
- CSFOSDB-3920: heal is not working for master-slave configuration
- Add common Audit class to cleanup wait_role and upgrade key if no job in progress
- pre_updatecfg drop maxscale user exception
- CSFOSDB-3943: Change heuristic rollback to default none (from rollback)
- admin topology audit not correctly determining if job in progress
- CSFS-47693: CMDB is using an deprecated label for the anti-affinity zone
### Changed
- CBUR default API changed to cbuf.csf.nokia.com/v1
- Updated to admin-base image with k8s-client-24.2.0
- Updated cbura-sidecar image to 1.0.3-4164
- Updated unified-logging versions
- Changed maxscale threads default to 2 (from auto)
- Upgrade MariaDB to MariaDB-10.6.9 (CVE fixes)
- Upgrade MaxScale to maxscale-6.4.1
### Added
- CSFOSDB-3893: Additional B/R config options
- Install python3-redis via pip to support latest version 4.3.4
- Upgrade keyring to 23.4.1 and install via pip
- CSFOSDB-3917: Support configurable replication SSL to remote datacenters
- CSFOSDB-3135: CMDB Support for TLSv1.3 
- CSFOSDB-3988: CMDB to provide option to give preference to IPv4 in dual stack environment
- CSFOSDB-4004: mariadb pods take too long to terminate due to exporter pods not exiting

## [8.2.4] - 2022-07-19
### Fixed
- CSFS-46752: Not able to bring up cmdb 8.2.2 with istio 1.7
- CSFS-46695: Mulit-datacenter password change via credenital secret failing
- Must wait for deleted pods to become ready if force keystore update
- CSFS-46356: Correct truncation of podPrefix and Job name
### Changed
- CSFOSDB-3885: Remove vim-minimal from all container images

## [8.2.3] - 2022-06-28
### Added
- CSFOSDB-3809: Add ephemeral storage resource/limit default values
### Changed
- Added job specific hooks cpu/memory resources (vs using admin pod)
- Update all conatiner images to latest 20220627 base images
### Fixed
- CSFOSDB-3849: Fix brhook default names and fix resource trunccation
- CSFOSDB-3851: Enable maxscale pdb by default
- CSFOSDB-3855: supervisord doesnt restart on container failure, causing CrashLoopBackoff
- podNamePrefix truncation error

## [8.2.2] - 2022-06-02
### Fixed
- CSFS-45385: Mariadb auditmon crashes
- CSFOSDB-3721: Need enhancements for user privileges and wildcard hostnames to meet CIS MySQL Benchmark
- CSFOSDB-3722: CIS MySQL test 7.3 fails - Need to take case into account when dealing with hostnames
- CSFS-45634: cmdb-mariadb pods should not use default SA
- CSFS-45642: Set automountServiceAccountToken false in SA
- Update cbur-policy to stop background poking when mariadb_db_backup script is done.
- CSFOSDB-3795: Update C Connector to address security vuln
### Changed
- CSFOSDB-3617: Restrict PSP condition for Openshift 4.10
- CSFOSDB-3649: Update MM2MS config morph script
- CSFOSDB-3778: Replace gzip with pigz for BR
- CSFOSDB-8303: Update base images for centos7/rocky8 to 20220530
### Added
- CSFOSDB-3498: Allow backup path for CBUR to be configured.
- CSFOSDB-3632: Integrate NCC changes to CMDB code
- CSFOSDB-3665: CMDB compliant with HBP 3.0.0
- CSFOSDB-3635: CMDB support of prefix for PodDisruptionBudget
- CSFOSDB-3627: Support for K8s Dual Stack
- Added Service, Job and Statefulset/Deployment render tests

## [8.1.0] - 2022-04-13
### Fixed
- CSFOSDB-3480: admin_base python performance updates
- CSFOSDB-3481: Chart upgrade to 8.0.x does not decode provided maxctrl exporter password
- CSFS-43201: MariaDB backup is failing after CMDB 8.0.1 upgrade
- CSFS-44115: mariadb audit logging not working as expected
### Changed
- Upgrade maxscale to maxscale-6.2.3
- Upgrade MariaDB to MariaDB-10.6.7 (CVE fixes)
- CSFOSDB-3464: BrPolicy to use apiVersion of cbur.csf.nokia.com/v1
- CSFOSDB-3515: Changed default install from galera to master-slave w/HA
- CSFOSDB-3565: Change admin type to Deployment (from StatefulSet), remove PVC
- Upgraded to csfdb-admin-base image 5.0 which removes kubectl executable
- Changed default artifactory repo to repo.cci.nokia.net
### Added
- CSFOSDB-3231: Support storage full alarms
- CSFOSDB-3414: Remove default maxscale admin user
- CSFOSDB-3328: Replace leader-elector with Maxscale cooperative monitoring
- CSFOSDB-3468: Eliminate admin pod dependence on kubectl executable
- CSFOSDB-3466: Support MYSQL_OPTS for adding arguments to admin mysql client
- CSFOSDB-3134: Support CMDB GEO with unique certs on each DC
- Support mysqld-exporter docker with sending config via fifo from mariadb
- Support sending maxctrl-exporter container config via fifo from maxscale
- CSFOSDB-3465: Support for geo-redundancy in Istio (Gateway configuration)
- CSFOSDB-3535: Support for additional replication options for Blue/Green
- CSFOSDB-3594: Implement helm testing in admin pod (vs chart pods)

## [8.0.1] - 2022-01-17
### Fixed
- CSFOSDB-3444: Upgrade from 7.15.x charts to 8.0.0 fail on migration of admin secret
- CSFOSDB-3448: Increase certificate alarm severity
### Changed
- keyring-19.2.0 will be installed for el7 as well as el8 based containers
- CSFOSDB-3251: PIP install cryptography and other keyring dependencies to eliminate cryptography vulnerability
- Uninstall pip packages from all container images to remove pip vulnerability

## [8.0.0] - 2022-01-10
### Fixed
- CSFS-41364: CMDB rollback failed
- CSFOSDB-2601: maxscale admin HTTPS interface exposes libcurl memory leak
- CSFOSDB-3356: mariadb docker-helper has multiple SQL statements
- CSFOSDB-3358: SVM-73828: Multiple Remote Denial of Service Vulnerabilities including CVE-2021-35604
- CSFOSDB-3360: need to enhance compare logic in generate_config.py for python3
- CSFOSDB-3405: Metrics container in mariadb pods reporting errors with respect to slave status
- CSFOSDB-3413: maxscale tools fixes CMDB 21.12 release
- Disable credentials audit during chart migration
- creds-monitor reports secret errors with multi_dc_key of empty string
- Fixed secret migration to new credentials in multi-dc environment
- mariadb metrics container is not exiting on pod terminate - requires force
### Changed
- CSFOSDB-3431: Comply to latest HBP version 2.1.0 
- CSFOSDB-3268: Comply to latest HBP version 2.0.0 
- CSFOSDB-3210: Support of partial backup/restore in non geo-redundant config.
- Upgrade MariaDB to MariaDB-10.6.5
- Upgrade MaxScale to maxscale-6.1.4 (ssl=required to true)
- Upgrade mysqld-exporter to version 0.13.0
- Remove maxinfo 8003 port references
- Upgrade to admin-base image 4.1 derived from k8s-client base image
- Support graceful-shutdown option in mariadb STS preStop lifecycle event
- Dropped support for helm2
- Support cmdb-7.17.7 to cmdb-8.0.0 chart upgrade using prepare-major-upgrade
- Must change admin memory default to 512Mi for values-model.yaml
- mariadb STS terminationGracePeriodSeconds changed to 120s
### Added
- Remove MariaDB RPMs from admin container
- Support for Rocky8 containers
- CSFOSDB-2749: Support for maxctrl_exporter provided by github/Vetal1977
- CSFOSDB-3291: CMDB support readOnlyRootFilesystem in psp:restricted
- CSFOSDB-3308: Support for Amazon EKS environment for CMDB
- Support new MaxCtrl dashboard
- Major chart upgrade must perform controlled shutdown before rolling upgrade

## [7.17.2] - 2021-11-08
### Fixed
- Must mount admin-user-creds in jobs for simplex topology
- CSFS-41248: CMDB simplex upgrade from 7.17.1 failing

## [7.17.1] - 2021-10-28
### Fixed
- CSFOSDB-3269: Remove extra "mariabackup --prepare" during restore stage.
- CSFS-40723: CMDB: Changes to best practice common labels
### Changed
- CSFOSDB-3279: Upgrade CBUR to latest cbura image 1.0.3-3233
- CSFOSDB-3287: Pass usernames to pods via init container vs environment variables
- CSFOSDB-3293: CMDB changes to incremental backup.
- Updated admin-base and os-base images to centos7-python3-nano:3.6.8-20211026
### Added
- CSFOSDB-3225: Automatic password update triggered by change in Secret
- CSFOSDB-3174: Support additional port configuration

## [7.17.0] - 2021-09-29
### Fixed
- admin.auth is being copied to /etc/mariadb and left there, remove it
- Add release to CBUR policy matchLabels
- CSFS-39774: Custom annotation values should be quoted
- CSFS-40070: serviceAccount is not set when rbac is disabled.
- CSFS-40172: Support compatibility bridge for helm restore between chart 7.14.1 to 7.14.2 and beyond
- CSFS-40240: Multi-datacenter password change breaks with directConnect true
### Changed
- MariaDB upgraded to MariaDB-10.3.31
- MaxScale upgraded to maxscale-2.4.17
- CSFOSDB-3190: Upgrade CBUR to latest cbura image 1.0.3-3009
- Add release to CBUR policy matchLabels
- CSFS-39774: Custom annotation values should be quoted
- CSFS-40070: serviceAccount is not set when rbac is disabled.
- CSFOSDB-3239: Support compatibility bridge for helm restore between chart 7.14.1 to 7.14.2 and beyond
- CSFOSDB-3246: Backup tar files cleanup failed in preRestore job.
- CSFS-40167: Mariadb CBUR restore failed.
- Built-in user names and passwords moved to users section
- Upgrade to latest centos7-python3-nano:3.6.8-20210923 image
- [HBP 1.2.0] global.istioVersion moved to istio.version
### Added
- CSFOSDB-2193: Support for embedded Backup (CMDB)
- CSFOSDB-2814: CMDB to support python3
- CSFOSDB-2468: CMDB to support MariaDB python connector
- CSFOSDB-3094: CMDB Support of PodDisruptionBudget
- CSFOSDB-3097: CMDB support for Pod Topology Spread Constraints
- CSFOSDB-3199: Comply to latest HBP version
- CSFOSDB-3224: [HBP_Security_1.2] Allow all user credentials to be passed in secrets

## [7.16.2] - 2021-08-30
### Fixed
- CSFS-36283: CMDB metrics are not coming in CPRO with istio
- CSFS-38966: CMDB without PodSecurityPolicy has dead psp use references
- CSFOSDB-3194 post_install in istio environment takes exception due to istio_proxy not up
### Changed
- Convert all network.istio.io from v1alpha3 to v1beta1

## [7.16.1] - 2021-08-05
### Fixed
- CSFS-37137: Disaster recovery in helm fails due to admin-db password not preserved
- Add MAXSCALE_CTL_PORT to maxscale-statefulset.yaml

## [7.16.0] - 2021-07-27
### Fixed
- CSFS-38235: CMDB MaxScale GR GTID is not set after B&R
- CSFS-38106: CBUR restore failed w/o predefined root_password
- CSFS-37679: After selective B&R non-admin user not able to connect to DB with old/new password
- CSFS-36788: CMDB self-heal with keystore recovered after B&R
- CSFS-34651: Audit to ensure wait_role is not left behind to cause upgrade issues
- CSFS-36184: Recopy keystore if 0 length
- CSFS-37725: CMDB auditmon crashes after CMDB upgrade
- CSFS-37866: CBUR backup and restore failing between 7.14.4 and 7.15.4 
- mariadb/maxscale activity.log generate double docker stdout messages
- CSFOSDB-3132: pwchange does not work for non-built-in users
- CSFS-38871: CMDB MaxScale GR environment replication user password causes replication broken
- CSFS-38866: maxscale STS requires config/datacenter CM annotation
- CSFDOSDB-3144: Do not see failure for password change when k8s secret has invalid parameter
### Changed
- CSFOSDB-3061: Enhance 2 DC to support separate Domain IDs
- CSFS-37869: CMDB maxscale GR grafana dashboard shows Cluster-slaves running 1
- CSFOSDB-3088: Support wild cards in the cert-manager certificate
- upgrade leader-elector image with latest os_base image
- Added pre_pwchange job to validate multi_dc_key and replication working
### Added
- CSFOSDB-2874: Alarms generated for expiring certificates
- CSFOSDB-3034: Set Security Context dynamically
- CSFOSDB-3040: Migration support galera
- CSFOSDB-2794: Upgrade Redis version to Redis6
- CSFOSDB-2545: Protect the admin password
- CSFOSDB-2475: Helm best practice:move rbac_enabled to rbac.enabled(2.15), global/customized labels and annotations(2.13)
- CSFOSDB-3070: Support direct connect to alternate DC vs via service/EP
- CSFOSDB-3104: Trigger auto-rebuild of mariadb pod on pre-defined errors
- CSFOSDB-1754: Configurable cbur selectPod to backup most up-to-date Slave

## [7.15.3] - 2021-05-20
### Changed
- Use hard-coded CMDB chart version vs .Chart.Version for chart migration
- Increase default pre-rollback job timer to 300 (from 180)
### Fixed
- CSFS-36781: CMDB Maxscale GR replication link broke with error 1942 after selective backup and restore
- CSFS-36936: CMDB Master external communication is non-TLS even when the configuration is set to be TLS in GR
- CSFS-37041: rollback to previous release, going from 4 datacenters replicating 4 ways back to 2 distinct pairs of datacenters, leaves replication in a bad state
- CSFS-37054: slave_skip_errors parameter is not used under templates directory
- Delete global:upgrade key in pre-upgrade/rollback if not being set
- CSFS-37229: mysql_upgrade needs --skip-version-check to allow application override of version
- CSFOSDB-3058: Topology morph exception in CMDB 21.02 FP1 release

## [7.15.1] - 2021-05-05
### Changed
- CSFOSDB-3029: Upgrade mariadb/maxscale to new centos-nano:7.9-20210301 os_base
### Fixed
- CSFOSDB-3021: Investigate and resolve SonarQube blocker issues in CHAS plugin

## [7.15.0] - 2021-04-30
### Fixed
- CSFOSDB-2907: Repair promotion scheme for CMDB - nflg should be pfiles.neg
- CSFS-34949: Eliminate the second copy of the DB
- CSFS-34777: Use SubPath support later helm versions
- CSFOSDB-2918: Do not default fake version for MariaDB - causes issues
- datacenter-monitor logs appearing twice in maxscale pod stdout
- CSFS-36403: Added partOf to values.yaml
- mariadb-master-remote-service port was hard-coded to 3306, use values.yaml
- enable redisio logging to docker stdout (loglevel warning)
### Changed
- CSFOSDB-2898: Upgrade MariaDB to 10.3.28 for CVE vulnerability
- datacenter.conf change to FQDN of maxscale/master service vs. service name
- CSFOSDB-2971: Enable semi-sync replication by default in maxscale config
- CSFOSDB-2917: Default readiness probe to 5 seconds (from 2 seconds)
### Added
- CSFOSDB-2786: Add alarming on mariadb and maxscale pod failures
- CSFOSDB-2808: Functional support for 4 CMDB sites
- CSFOSDB-2809: Support tools to automatically re-establish replication links
- CSFOSDB-2810: Enhance mariadb_adm/maxscale_adm to support multiple datacenters
- added release to K8S_LABELS in support of helm to operator adoption

## [7.14.1] - 2021-03-11
### Fixed
- CSFOSDB-2759: Restore of DC with excluded list of tables from replication is not working
### Changed
- Install promotion.sql to mariadb pods as well as maxscale
- CSFOSDB-2886: Fake mairadb version to avoid version leak to connections

## [7.14.0] - 2021-02-25
### Fixed
- CSFS-34526: cmdb upgrade via helm3 does not work
- CSFOSDB-2856: Helm backup for CMDB not working after restore has been performed
### Changed
- CSFS-26251: PodSecurityPolicy not required when ISTIO and CNI is enabled
- CSFOSDB-2737: update managed-by label per best practice change
- Remove cbur.jobhookenable functionality
### Added
- CSFS-34078: Helm Annotations - istio proxy annotations (custom pod/psp)
### Fixed
- Rollback from master-slave to simplex and galera must clear replication

## [7.13.14] - 2021-02-09
### Fixed
- mariadb server rebuild must save cmdb-recovery.info over rebuild process
- incorrect Values reference for exporter port in mariadb-statefulset
- CSFS-33370: CMDB verify-geo-replication helm test fails due to missing brace
- CSFS-32881: CMDB rollback from maxscale to simplex must delete PVCs for extra pods
- CSFS-31760: Cannot pre-specify maxscale/replication passwords during simplex to maxscale upgrade
### Changed
- update OS base image to centos-nano:7.9-20210201
### Added
- CSFOSDB-2716: CMDB add cbur value that would enable a temp pvc
- Add support for tar method for rebuild to support Blue/Green managed-upgrade
- CSFOSDB-2737: support for Helm best practice labeling
- CSFOSDB-2606: GR backup/restore improvement

## [7.13.13] - 2021-01-15
### Fixed
- CSFS-31294: cmdb-mariadb pod restarts continously after unsuccessful restore
- CSFOSDB-2764: Enhance mariadb_bootstrap.sh to ensure MASTER is configured on ACTIVE node
- RBAC ServiceAccount not set correctly for post-rollback job
- Fixed comment to be accurate for mariadb.mysqldOpts
### Added
- CSFS-31135: support secret template

## [7.13.12] - 2021-01-04
### Fixed
- CSFOSDB-2747: fix race between mariadb_switchover plugin and CHAS

## [7.13.11] - 2020-12-17
### Fixed
- Clear MARIADB-MASTER pod labels in all mariadb pods in pre-restore
- CSFOSDB-2619: mariadb_db_backup enhancement to eliminate use of extra copy
### Changed
- CSFOSDB-2668: CMDB must report progress on Upgrades/Rollback
### Added
- Add support for server_id prefix for all server_id assignments
- CSFS-29913: username/password based authentication to cmdb

## [7.13.10] - 2020-12-10
### Fixed
- CSFS-31495: fixes for password change with selective replication
- CSFOSDB-2705: exit code from mariadb_db_backup is hidden
- post-upgrade job does not have sufficent RBAC for pw change operation
- CSFS-31495: pw change fails due to no .keydir in maxscale pods
- CSFS-31371: post_morph does not remove global:upgrade AdminDB key
- CSFS-31372: promotion.sql not applied on disaster recovery scenario
- CSFS-31583: datacenter-monitor needs to stop activity when maxscale disabled
- CSFS-31495: maxscale helper must select cmdbadmin DB for replication to work
### Added
- CSFS-31506: Support user defined priorityClass names in CMDB StatefulSets
### Changed
- Changed deprecated RBAC API v1beta1 to v1

## [7.13.9] - 2020-11-30
### Fixed
- CSFS-31550: CMDB 7.13.8 upgrade fails the geo redundancy replication link

## [7.13.8] - 2020-11-27
### Fixed
- CSFS-30929: Maxscale may leave nodes unconfigured on deploy if missing

## [7.13.7] - 2020-11-20
### Fixed
- CSFS-30778: Database restore broken by PITR feature
- CSFOSDB-2634: Support for MaxScale Disaster Recovery with old passwords
- CSFS-30951: Cannot delete /import/database_users.json until after apply-pending-sql
- tcp-mysql-ro port has broken targetPort
- slave_purge_interval configuration not taken on simple datacenter
### Changed
- Upgrade MariaDB to MariaDB-10.3.27 (CVE fixes)
- Upgrade MaxScale to maxscale-2.4.13
- Added ability to import certs from /etc/.certificates/server or client subdir
### Added
- CSFS-30900: Expose readiness and liveness probe configuration in values.yaml
- CSFS-28778: Support CITM Ingress for geo-redundancy as option to NodePort	
- Added helm render tests to chart

## [7.13.6] - 2020-11-02
### Fixed
- CSFS-30351: Helm test pods are not removed even after successful completion
### Added
- CSFOSDB-2603: Readiness and liveness checks use bash not python

## [7.13.5] - 2020-10-27
### Fixed
- CSFS-30076: CMDB deploy in Istio enabled namespace && istio enabled variables set false istio sidecar still injected
### Added
- CSFID-3336: Support for reduced service name length
- CSFID-3247: Support for setting timezone in container from host
- CSFS-28562: CMDB support for mariadb startup option --safe-user-create

## [7.13.3] - 2020-10-15
### Fixed
- CSFS-29507: CMDB (MariaDB) deployment from the CSFP 20FP1 catalog fails
- CSFS-29694: Regression in enablement of metrics user during upgrade
- CSFS-29616: wait_istio_proxy function doesn't work reliably (admin-base image)
### Changed
- CSFOSDB-2617: VAMS indicates critical CMDB vulnerabiity - need to move to MariaDB version 10.3.25
- change readiness probe timeout for mariadb-statefulset from 1 to 2 seconds

## [7.13.2] - 2020-10-01
### Fixed
- CSFOSDB-2604: cmdb/admin HIGH dbus vulnerability

## [7.13.1] - 2020-09-30
### Fixed
- maxscale-metrics service is being created when maxscale not configured
- CSFS-28601: Support REQUIRE-SSL for the maxscale account
- CSFS-28786: CMDB pre & post backup & restore jobs should specify cpu and memory resources for its containers
- BrHook jobs must point to podNamePrefix'ed BrPolicy object
- maxscale/mariadb pods must wait for CMGR certificates in init container
- CSFS-28906: Maxscale with enabled geo redundancy access error on BCMT pure IPV6
### Changed
- CSFOSDB-2557: Support for maxscale-2.4
- CSFOSDB-2586: Upgrade to supervisor-4.2.0
- CSFS-28601: Support REQUIRE-SSL for the maxscale account
- CSFS-22811: Need cmdb jobs support tolerations and nodeselector
- admin pod RBAC must have permission to delete endpoints
### Added
- CSFOSDB-2575: Revise Documentation for helm chart/values.yaml
- CSFOSDB-2533: Need to enhance maxctrl port to use https
- CSFOSDB-2357: Automatic Migration from MariaDB Galera to MariaDB with MaxScale (container)
- CSFOSDB-2582: Automatic Migration from MariaDB Simplex to MariaDB with MaxScale (container)
- CSFS-26943: Support for mounting of shared storage in mariadb pods
- CSFS-28551: Support for provisioning of temp PVC for mariadb tmpdir

## [7.12.2] - 2020-09-11
### Fixed
- Add tests/values-compat.yaml to ensure values-compat rendered before tests
- Fix values-compat for services.mysql.sessionAffinity
- Need to add values-compat for brhook values

## [7.12.1] - 2020-09-09
### Fixed
- CSFS-28232: keystore_server errors in simplex deployment once/sec
- containerNamePrefix cannot apply to cbura-sidecar container name
- CSFS-28277: CMDB install fails with error in BrPolicy in OpenShift with AspenMesh 1.4.6
- CSFS-28420: database access test failed if Values.global.podNamePrefix is set
- BrPolicy name must be same as mariadb statefulset with podNamePrefix
### Changed
- Implement pod/container name prefix in helm tests
- Implement full job/container name supprt in NCMS hooks heal/restore

## [7.12.0] - 2020-08-31
### Fixed
- CSFS-27891: Streamline pre_stop admin pod tasks to be as fast as possible
### Changed
- pre/post job timeouts moved from admin to hooks section
- pre/post backup/restore timeouts moved from admin to cbur section
- must default terminationGracePeriodSeconds for admin pre_stop to 120 (from 30)
### Added
- CSFOSDB-2541: Add support to add prefix to pod names and container names
- Addition control over hook job/container creation an naming
- CSFS-26575: Add DB name from original server audit log to data.object field
- CSFOSDB-2457: Support Customization of logrotate parameters
- Handle SIGTERM in admin container using terminationGracePeriodSeconds
- CSFS-28112: Support cbur.autoUpdateCron configuration

## [7.11.2] - 2020-08-14
### Fixed
- CSFS-27629: Internal replication needs to use repl_use_ssl vs use_tls
### Changed
- global.istioVersion must be supplied for installing into istio environment
### Added
- CSFOSDB-2541: CMDB policy objects to support istio 1.4 and 1.5

## [7.11.1] - 2020-08-12
### Fixed
- Additional arbitrary UID fixes
- helm upgrade broken from pre-7.5 chart versions
- CSFS-27438: Invalid spec configuration for PeerAuthentication

## [7.11.0] - 2020-07-31
### Fixed
- mariabackup SST method does not work in container environment
### Changed
- CSFS-26017: Specify delete policy for all CMDB Helm tests
- CSFOSDB-2505: Upgrade admin container to kubernetes 1.17.9
- CSFS-26157: enhance mdb_show_tables to ignore missing table entires
### Added
- CSFOSDB-2499: Support newer istio-1.6 security.istio.io API
- CSFOSDB-2411: Added Openshift arbitraty UID support
- CSFOSDB-2140: Support TLS/SSL for Galera IST/SST replication
- CSFOSDB-2389: Comprehensive support for Grafana dashboards for CMDB

## [7.10.3] - 2020-07-13
### Fixed
- CSFS-25673: Fix scenario where restoring an earlier backup (not the latest)
- CSFS-26157: enhance mdb_show_tables to ignore missing database entires
- CSFS-23497: provide default cert-manager DNS enrty
- CSFS-26188: CMDB Chart 7.10.2 installation fails for ISTIO enabled
- CSFS-25094: CMDB Metrics integration with Prometheus is not working

## [7.10.2] - 2020-06-30
### Fixed
- CSFS-24867: Cannot restore CMDB from 19.06 on a 20.03 BCMT env
- CSFS-25282: Istio sidecars injection works autoInject: false
- Heal event uses istio rbac when istio is enabled
- CSFS-25445: When using helm 2.16.8, cmdb install failed due to template issue
- CSFS-25545: admin job container exiting too quickly in istio may leave istio-proxy running
- CSFOSDB-2397: failed auto-heal can leave auto-heal delayed indefinitely
- CSFS-25621: Remove spaces in hooks.deletePolicy for BrHooks
- CSFS-25102: Enable maxscale with start slave does not start the slave process
### Added
- Support for configuration of the k8s cluster domain (cluster.local)
- CSFS-23077: Ability to pass a serviceAccount disabling creation of RBAC Resources
- securityContext added to all jobs
- admin-statefulset preStop script to SAVE database to disk
- CSFOSDB-2375: Support for auto-rebuild of failed master to slave if replication broken
### Changed
- CSFOSDB-2402: Use dedicated maxscale_exporter built product
- CSFOSDB-2410: Upgrade redis.io to 5.0.9
- CSFS-25741: Add checks for mariabackup errors
- CSFOSDB-2401: update mariadb_convert with nochas option
- CSFOSDB-2424: admin pod should persist to disk periodically

## [7.10.1] - 2020-05-31
### Fixed
- CSFS-24705: fail to run helm upgrade with cmdb in an umbrella chart when istio is enabled
- Need to wait_istio_proxy before running any kubectl commands in docker-entrypoint
### Added
- CSFOSDB-2346: Support cbur.ignoreFileChanged parameter in CMDB chart
- CSFOSDB-2163: CMDB Support for CBUR Backup and Restore Hooks
- CSFOSDB-2313: Support mysql service sessionAffinity
### Changed
- Upgrade MariaDB to MariaDB-10.3.23 (CVE fixes)
- Upgrade MaxScale to maxscale-2.3.19
- CSFOSDB-2348: Add X509v3 extensions: client+server auth

## [7.9.4] - 2020-05-12
### Added
- CSFOSDB-2348: Support for cert-manager version cert-manager.io/v1alpha2

## [7.9.3] - 2020-05-12
### Fixed
- CSFOSDB-2345: pre-install job failure with cmdb-7.9.2 chart

## [7.9.2] - 2020-05-08
### Fixed
- CSFOSDB-2330: Maxscale leader-elector container restarts twice during install in istio
### Added
- Istio support for helm tests
- Support for auto-heal on loss of galera quorum
### Changed
- CSFOSDB-2332: Enhance story CSFS-22503 to include the encrypt_binlog parameter

## [7.9.1] - 2020-05-04
### Fixed
- CSFOSDB-2328: Labeling of mariadb-master pod in istio environment not working
- CSFOSDB-2329: admin pod restarts when job completes in istio

## [7.9.0] - 2020-04-29
### Fixed
- Fixed maxscale docker-helper for broken scale
- Remove CLUSTER_SIZE environment variable from maxscaleinit-keystore
- CSFS-23273: mariadb tcp-socket liveness probe noisy
### Added
- CSFS-21678: CMDB: Helm Port Istio-Style Formatting
- CSFOSDB-1343: Istio support for CMDB
- CSFOSDB-2204: Manage MariaDB core files
- CSFS-22503: Data-At-Rest CMDB encryption support
- CSFOSDB-2236: Selective backup of CMDB tables
- Pass ISTIO_ENABLED to jobs to request istio-proxy sidecar stop after complete

## [7.8.2] - 2020-04-07
### Fixed
- CSFS-22791: Don't remove database_users.json until after processed

## [7.8.1] - 2020-04-03
### Fixed
- CSFS-22200: Fix for B/R of colocated datacenter config

## [7.8.0] - 2020-03-27
### Fixed
- CSFS-22079: helm restore with jobhookenable must force heal
- CSFS-22216: thread leak in mariadb_auditmon
### Changed
- Move admin-base docker iamge and tools to CSF-OSDB repo
- CSFOSDB-2184: Remove MariaDB from CMDB log messages
- upgrade flexlog and crypto-keyring to latest versions
- change MY_POD_NAMESPACE to K8S_NAMESPACE in maxscale statefulset

## [7.7.2] - 2020-03-09
### Fixed
- CSFS-22082: mariadb_lib failed to find server list

## [7.7.1] - 2020-03-04
### Fixed
- Install of simplex still requires that mariadb.count be set to 1
- CSFS-21813: mariadb_db_backup tool needs to capture firewall state from stderr

## [7.7.0] - 2020-02-28
### Fixed
- CSFS-20729: pre-delete will attempt to use admin contain but bypass if necessary
- CSFS-21510: Galera pods may not come up after heal, auto-heal or restore
- Galera restore needs to force heal operation
- Simplex deployment will not updatecfg on every helm upgrade
### Added
- CSFS-20748: Cluster heal will do minimum necessary (or nothing) to fix cluster
- CSFOSDB-2030: Automatically generated cert-manager certificates
- CSFOSD-2162: Support for Chart migrations and upgrade rollback (helm rollback)
### Changed
- CSFS-20774: Default mariadb nodeAffinity to disabled (not is_worker)
- leader-elector sidecar upgraded to 4.6-1.15
- upgrade MaxScale to maxscale-2.3.17

## [7.6.1] - 2020-02-05
### Fixed
- CSFOSDB-2116: maxscale cmdbadmin user must be created as admin user

## [7.6.0] - 2020-01-30
### Added
- CSFS-19923: Add option to annotate statefulsets on configuration update
- quorum_wait_time added to specify additional time to wait after quorum reached
- CSFS-12486: Support auto-heal for galera cluster
- Audit MARIADB-MASTER labels for mariadb pods
### Fixed
- CSFS-16110: Add base64 password requirement to deployment form
- Fixed maxscale exporter scrape address to localhost:8003
- Upgrade maxscale_exporter to work with maxscale-2.3
- CSFS-19483: Perf-test: metrics container of cmdb crashed and does not come up
### Changed
- Change mariadb liveness probe to attempt socket connection to localhost:3306
- Change mariadb liveness probe to succeed until bootstrap complete

## [7.5.3] - 2020-01-02
### Changed
- updated admin-base base image to v1.14.10-nano for vulnerabilities
- updated other base images to 7.7-20191216 for vulnerabilities

## [7.5.2] - 2019-12-31
### Fixed
- maxscale pod can pull passwords from mariadb before build-in password import
### Added
- add apiVersion to Chart.yaml
### Changed
- Changed deprecated StatefulSet API apps/v1beta1 to apps/v1

## [7.5.1] - 2019-12-04
### Fixed
- Admin container needs permission to get statefulset status
- Do not run update-config helper in pods if statefulset is in rolling update
- Do not run update-config helper in galera if would result in loss of quarum

## [7.5.0] - 2019-11-27
### Changed
- Add authentication to admin container for redis.io password authentication
- Add ability to have a job request pre-emption of job in progress (pre-delete)
- CSFOSDB-1903: Support a 2nd CA for cert-manager objects
- CSFOSDB-1875: Support for galera in pure IPv6 environment

## [7.4.5] - 2019-11-06
### Changed
- CSFS-17953: Add before-hook-creation to default hooks deletePolicy

## [7.4.4] - 2019-11-04
### Changed
- update for mariadb-tools-4.9-5

## [7.4.3] - 2019-11-01
### Changed
- updated for centos-nano:7.7 and kubectl:v1.14.7 docker base images

## [7.4.2] - 2019-10-31
### Changed
- updated for CMDB 4.12-1 19.10 final release (BVNF 19.08)

## [7.4.1] - 2019-10-30
### Fixed
- CSFS-17703: New variable to mysql_site_conf (values.yaml) --> helm upgrade --> cmdb pod is not updated

## [7.4.0] - 2019-10-24
### Added
- CSFOSDB-1658: CMDB support for common audit logging framework

## [7.3.3] - 2019-10-23
### Changed
- updated for CMDB 4.11-3 19.09.2 release

## [7.3.2] - 2019-10-18
### Changed
- leader-elector container moved to CSF-OSDB repo
- updated for CMDB 4.11-2 19.09.1 release

## [7.3.1] - 2019-09-30
### Fixed
- values-compat.yaml merging boolean true values must check for value exists
### Changed
- mariadb_recover to handle SSH failures

## [7.3.0] - 2019-09-26
### Fixed
- Problem with scale-out of mariadb pods in maxscale environment
### Added
- Support nodeSelector and tolerations (default empty) in all statefulsets
- Perform pre-install checks of topology and node counts (eg. galera < 3 nodes)
- CSFOSDB-1708: Verify CBUR restore of a DC with backup from the remote DC
### Changed
- Auto-generate helm chart files for easier deployment/management
- Added configurable registry and image tags to ComPaaS values-model.yaml
- CSFS-15382: Maxscale readiness probe won't return ready unless Master exists
- Upgrade redis.io to version 5.0.5

## [7.2.0] - 2019-08-28
### Fixed
- CSFS-15830: post-upgrade of simplex deploy fails on chart upgrade
- CSFS-15349: Restore backup prior to mysqld_exporter user password change breaks metrics
### Changed
- Upgrade MariaDB to 10.3.17-1
- Upgrade maxscale to maxscale-2.3
- CSFS-15049: heuristic_recover defaults to rollback for non-simplex, none for simplex
### Added
- Add INSTALLED_CLUSTER_TYPE to mariadb-cluster-configmap for test container
- CSFOSDB-1311: Support replication SSL via repl_use_ssl value

## [7.1.0] - 2019-07-31
### Fixed
- maxscale leader-elector and exporter compatibility with BCMT 19.06
- support static mariadb-master-remote service IP assignment
- maxscale leader-elector registry incorrect for new leader-elector
- allow standalone in pre-migrate job and delete existing admin-deploy cm first
### Added
- CSFOSDB-1511: ncms pre/post restore hooks for maxscale
- Support for configuration of CLEAN_LOG_INTERVAL in chart
### Changed
- Upgrade MariaDB to MariaDB-10.3.16 and include MariaDB-cracklib-password-check

## [7.0.3] - 2019-06-26
### Fixed
- Fixed remote services to support IPv6 addresses
- CBUR backups fail due to security context on cbur sidecar container
### Added
- CSFOSDB-1620: Support for IPv6 and dual stack for external CMDB interfaces
- Support dual-stack installation, preferring IPv6 over IPv4

## [7.0.1] - 2019-06-14
### Fixed
- CSFS-13714: BCMT 19.06 compatibility removed optional on volumeMounts
- CSFS-14010: maxscale_exporter registry incorrect in default case
- CSFS-14072: CMDB upgrade from 7.0.0 to 7.0.0 fails (simplex)

## [7.0.0] - 2019-05-28
### Added
- CSFOSDB-1538: Parameterize CBUR configurations for MariaDB (NNEO-621)
- added admin pod to run small redis.io DB and run jobs
- CSFS-13159: Support nodePort assignments for mysql, mariadb-master, maxscale services
- CSFS-13072: Can't Turn off Node Affinity with values.yaml override
- CSFOSDB-1445: Support for maxscale-exporter sidecar for maxscale pod
- allow the mysqld_exporter port to be configured
### Changed
- Eliminate dependence on CSDC by running admin container as daemon
- cluster_type=simplex will force mariadb replica count to 1
- Upgrade to MariaDB-10.3.15 and maxscale-2.2.21
- changed maxscale readiness probe back to check-sanity

## [6.7.0] - 2019-04-30
### Fixed
- Force simplex to not use SDC even if etcd.client exists
### Added
- terminationGracePeriodSeconds can be configured for mariadb/maxscale pods
- add maxscale.listener.rwSplit to all configuration of default rwSplit service

## [6.6.4] - 2019-04-12
### Changed
- Updated to include CMDB 4.6-3 changes

## [6.6.3] - 2019-04-10
### Fixed
- CSFS-11850: Part 2 - helm restore for cluster-type galera (CSFOSDB-1143)

## [6.6.2] - 2019-04-10
### Fixed
- CSFS-11850: helm restore for cluster-type galera (CSFOSDB-1143)

## [6.6.1] - 2019-04-04
### Fixed
- CSFS-12061: maxscale_master_listener error in ComPaaS
- CSFS-11853: install in compaas fails due to missing resource requests/limits
- CSFS-11736: CMDB chart values-template renders empty strings into nulls instead of omitting them
### Changed
- Always create maxscale service if maxscale nodes exist (mariadb preStop)
- Make mariadb preStop master-switchover timeout tunable

## [6.6.0] - 2019-03-29
### Added
- Support for BCMT heal plugin
- IPv4 and IPv6 localhost addresses for exporter user
- Support for configuration of maxscale Master-Only service
- Support for configuration of RO-Service and Master-Service ports
- Support preStop hook in mariadb-statefulset to switchover master
- Helm tests for basic Maxscale verification
- Helm test for multi-DC replication verification
- Helm test for metrics verification
- Helm test for cmdbadmin database
- Pre-Upgrade Job to move metrics credentials from secret to keystore
- Added wait based on container status when SDC not used
### Changed
- Default csdc.enabled to true (from false) in ComPaaS
- Upgrade CSDC requirement to 2.0.29
- Upgrade to maxscale-2.2.20
- MaxScale readiness probe changed to attempt to connect to DB via 3306 port
- Upgrade CMDB images to 4.6-0
- Change exporter container to allow time for env file to be available and restart
- Update metrics-shared emptyDir to be memory-based
### Fixed
- Helm upgrade of galera cluster sometimes terminates all pods
- Post-install on simplex waits for pod to be ready

## [6.5.1] - 2019-03-03
### Fixed
- Fixed scaled-out nodes from using default passwords

## [6.5.0] - 2019-03-01
### Added
- values-compat template to support settings default values on upgrades
- values-image-version-check template to support minimum image version requirements
- maxscale init container to copy keystore from mariadb pod
- password change support
- initial set of basic helm test cases
### Changed
- upgrade to mariadb-10.3.13
- upgrade to maxscale-2.2.19
- upgrade admin-base image to support kubectl:v1.12.3
- upgrade to mysqld-exporter:v0.11.0
- provide a method to disable individual jobs from running
- Moved database_users to a hook-generated temporary configmap
- Removed persistence.enabled values since always required
### Fixed
- Fixed typo in maxscale-secrets which ignores maxscale user password in values

## [6.4.3] - 2019-02-07
### Fixed
- pre-install hook more selective on checking for existing PVCs

## [6.4.2] - 2019-02-05
### Changed
- Moved build of cmdb Helm chart to CSF-MARIADB repo/pipeline

## [6.4.1] - 2019-02-04
### Fixed
- Simplex post-install fails with exception

## [6.4.0] - 2019-01-31
### Fixed
- Fixed attribute mis-spelling in mariadb-statefulset
- Fixed RBAC hook weights so resources created in order

## [6.3.2] - 2019-01-24
### Changed
- Modified RBAC definition to be more selective for enhanced ComPaaS security
- Upgraded CSDC requirement to 2.0.3

## [6.3.1] - 2018-12-21
### Fixed
- Simplify metrics service management so works in MaxScale environment also

## [6.3.0] - 2018-12-19
### Added
- Allow nodeAffinity rules to be set for both mariadb and maxscale statefulsets
- Default set maxscale query_retries and query_retry_timeout
- Allow maxctrl to be configured for external access on port 8989
- Add optional maxctrl service that will follow leader maxscale pod
### Changed
- MaxScale upgraded to maxscale-2.2.18
- MaxScale pods will by default run on edge nodes to enhance HA
- Added limits to both mariadb and maxscale pods in BCMT environment
- Run mysql_upgrade on all upgrades/downgrades

## [6.2.1] - 2018-12-07
### Added
- Allow metrics and dashboard to be enabled via ComPaaS
### Changed
- Remove delete of CSDC PVC on terminate since CSDC-1.0.48 chart fixed issue
### Fixed
- audit_logging options not working in ComPaaS

## [6.2.0] - 2018-11-30
### Added
- Added admin.quickInstall flag to allow for faster deployment if needed
- Create dashboards configmap with MySQL_Overview.json dashboard if enabled
### Changed
- Upgraded MariaDB to MariaDB-10.2.11
- Upgraded CSDC requirement to 1.0.48
### Fixed
- Fix ComPaaS Rendered Template Check issue
- Produce chart render error if database name contains hyphen character

## [6.1.3] - 2018-11-12
### Fixed
- Adding metrics user causes password assignment failure

## [6.1.2] - 2018-10-31
### Fixed
- Updated CMDB to 4.1-3 which resolves logging in BVNF environments

## [6.1.1] - 2018-10-30
### Fixed
- MaxScale will not come up in ComPaaS
- CSDC chart embedded enable flag not set correctly in ComPaaS
- pre-install job must not require SDC if being deployed as sub-chart

## [6.1.0] - 2018-10-29
### Added
- CSFS-7099: Support WITH GRANT OPTION via deploy.yaml for non-root users
- CSFOSDB-1107: Enable non-performance impacting audits by default
- Enhance galera to do auto-heal when deploying with existing PVCs
### Changed
- auto_rollback changed to heuristic_recover={rollback|commit|none}
- Default storageClass size for ComPaaS change to 5Gi (from 20Gi)
- max_node_wait changed from default 15 to 5 minutes
- mariadb readiness and livliness probe configurations changed
- updated CSDC chart to csdc-1.0.40
### Fixed
- Fixed statefulset storageClass definitions
- Add RBAC rule for MaxScale leader-elector container to manage endpoints
- pre-delete job should not require SDC

## [6.0.3] - 2018-10-10
### Fixed
- missing users.requires allowing user to specify REQUIRES SSL/X509 for user
- CSFS-7465: Please clean up older backup files first before 'helm backup'

## [6.0.2] - 2018-10-04
### Added
- Add CSDC chart requirement to optionally deploy CSDC chart with CMDB
### Changed
- Remove CSDC/etcd dependency for simplex deployments (does not require CSDC)
- CBUR can use either datadir/backup directory or additional backup volume
- Default to auto-generated password for repl_user and maxscale_user if not set (not hardcoded)
### Fixed
- INFO broken about how to deploy mariadb client pod
- don't generate repl@b.c in database_users.json unless mariadb.count > 1
- remove pre-install hook-delete-policy hook-succeeded
- ComPaaS environment change all passwords to 'password' type on GUI

## [6.0.0] - 2018-09-28
### Added
- Added support for HA (multiple) maxscale pods
- Integration of CBUR for helm driven backup/restore support
- Support second PVC for MariaDB backups
- Support MariaDB 10.3.9 and MaxScale 2.2.13
- Support TLS with MaxScale northbound and southbound
- Support import of CA certificates for SSL
### Changed
- image information (name/tag/pullPolicy) consistency
- default storageClass is not not set to use kubernetes default
- support CSDC with TLS enabled
### Fixed
- All containers must have request/limts defined for ComPaaS 18.08

## [5.0.4] - 2018-09-25
### Fixed
- CSFS-7236: parameter values were not updated after helm upgrade

## [5.0.3] - 2018-09-17
### Fixed
- added CSDC dependency requirement to README.md
- post-delete job will not fail if SDC access fails
- install with PSP/RBAC disabled fails
### Changed
- user must specify "requires: SSL" (or not) when users created

## [5.0.2] - 2018-09-07
### Fixed
- Remove chart version from labels
- add selector label to statefulsets

## [5.0.1] - 2018-09-07
### Added
- CSFS-5141: Follow standardized template naming rules
### Fixed
- Fix issue with roles, rolebindings not being deleted on terminate
- Fixed metrics registry relocation issue
### Changed
- Delete jobs back to post-delete hook
- Support 3.6-2 release MariaDB 10.2.17

## [5.0.0] - 2018-08-28
### Added
- PSP/RBAC support
- Delete jobs in pre-delete hook
- Add TLS support for MariaDB
- CSF chart relocation rules enforced

## [4.3.2] - 2018-08-06
### Added
- All future chart versions shall provide a change log summary

## [0.0.0] - YYYY-MM-DD
### Added | Changed | Deprecated | Removed | Fixed | Security
- your change summary, this is not a **git log**!


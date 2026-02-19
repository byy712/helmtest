# Changelog

## [1.17.0] - 2024-03-25
### Added
- CBUR-1267: Add HBP Kubernetes podAntiAffinity
- CBUR-1304: Support keystore for syslog configuration
- CBUR-1302: Support RFC5424 message format when logging to syslog
- CBUR-620: Add onBackupFailureCmd execution for failed backups
- CBUR-1627: Add separate unified logging extensions for each deployment
- CBUR-1289: Add options to CBUR values and BrPolicy that allow to specify compression method
- CBUR-1725: Add pigz support and compression options to main/mycelery pod
- CBUR-1320: Add facility level for security audit logs
- CBUR-1733: Add compressionLevel option to BrPolicy
- CBUR-1291: Add new compression options to CBUR
- CBUR-1426: Add configurable logger log levels
- CBUR-1684: HBP 3.8 - split unified logging values per workload
- CBUR-1366: Add request protocol to nginx logs
- CBUR-1425: Improve istio resources in CBUR chart
- CBUR-1361: Add support for applying Multus configuration
### Changed
- CBUR-1297: Set runAsNonRoot on a pod level instead of a container
- CBUR-1323: Use log-manager image from CSF-CCBUR repo
- CBUR-1521: API version change from v1 to v2
- CBUR-1305: Add openssl to the cbur-logmanager image
- CBUR-1569: Update base images
- CBUR-1551: Return 404 instead of 500 when BrPolicy doesn't exist
- CBUR-1618: Restrict urllib3 version during python kubernetes installation
- CBUR-1606: Removed unifiedLogging.syslog.tls.enabled value
- CBUR-1567: Removed Helm 2 support
- CBUR-1376: Support logLevel from unified logging, enable unified logging format by default
- CBUR-1238: Update base images and tools versions
- CBUR-1752: Update go libs in cbur-logmanager
- CBUR-1260, CBUR-1805: CSF components upgrade
- CBUR-1262: Update python packages to use latest fixed version
### Fixed
- CBUR-854:  Fix cburaVolume in namespaced scope RBAC issue
- CBUR-1286: Fix cbur-main registry path
- CBUR-1547: Refreshed TLS certificate not used by cbur
- CBUR-1114: Removed NETBKUP from the valid backends list
- CSFS-57708: Reintroduce RBAC creation flag
- CBUR-1500: Fix for restore with -b parameter, sftp backend and celery enabled
- CBUR-1549: Fix certificate issuer based on custom cert-manager issuer values
- CBUR-1758: Fix EncodeError while doing backup
- CBUR-1719: Fix alarm logs with syslog enabled
- CBUR-1756: Syslog config map port bug fixed
- CBUR-1735: Fix for br-admin change/reset password
- CBUR-1809: Fix host name in syslog log message, when avamar pod is run with host network enabled
- CBUR-1835: Fix for untar problem while restore on EKS clusters with default EFS storage class
- CBUR-1901: Fix for post-delete job when enabled
- CBUR-1902: Fix for GCS backend restore process on GKE cluster

## [1.16.1] - 2023-12-14
### Changed
- 1.16.1-1 CBUR-1040: CSF components integration (CITM, CRDB)
- 1.16.1-2 CBUR-1044: Update python packages to use latest fixed version
- 1.16.1-3 CBUR-1086: fix for starting backup/restore hooks
- 1.16.1-4 CBUR-1040: CRDB image path fixed
- 1.16.1-5 CBUR-1038: Update base images, tools
- 1.16.1-6 CBUR-998: Decrease value of startretries in cburm.conf
- 1.16.1-7 CBUR-1087: keep authentication services configs in botocore
- 1.16.1-8 CBUR-1084: Fixed syslog containers not setting cpu limit with enableDefaultCpuLimits
- 1.16.1-9 CBUR-1002: Remove snapshot.enabled flag from CBUR helm chart + update DOCS
- 1.16.1-10 CBUR-1107: Add custom annotations for job pods
- 1.16.1-11 CBUR-1108: Add option to use localhost connection between celery and redis containers
- 1.16.1-12 CBUR-1110: Improve the error message for volumeSnapshot backup failure
- 1.16.1-13 CBUR-1029: Fix recreating PVC using VolumeSnapshot and createVolumeOnly
- 1.16.1-14 CBUR-1120: Update CRDB
- 1.16.1-15 CBUR-922: hardcoded passwords removed
- 1.16.1-16 CBUR-1112: Fix namespace restore with enabled appdata in namespaced scope
- 1.16.1-17 CBUR-1087: keep kms in botocore
- 1.16.1-18 CBUR-1064: update Alpine image version
- 1.16.1 CBUR-1064: Release the official chart

## [1.16.0] - 2023-11-24
### Changed
- 1.16.0-1 CBUR-518: CBUR to support HBP 3.7.0 - Kubernetes pod changes
- 1.16.0-2 CBUR-737: update alpine image version
- 1.16.0-3 CBUR-606: Update CBUR codebase to drop CentOS7 / RHEL7 support
- 1.16.0-4 CBUR-772: update base image version
- 1.16.0-5 CBUR-569: Different names to describe timestamp
- 1.16.0-6 CBUR-505: Create an alert when auth.enabled is set to false
- 1.16.0-7 CBUR-506: Create an alert when securityContext takes CBUR out of the hardened state
- 1.16.0-8 CBUR-519: HBP 3.7 - Kubernetes security credential changes
- 1.16.0-9 CBUR-774: BCMT cluster info bug on non-ncs environment fixed
- 1.16.0-10 CBUR-520: CBUR to support HBP 3.7.0 - Certificates and TLS changes
- 1.16.0-11 CBUR-823: fix bug with wrong default TLS certificate being used in CBUR
- 1.16.0-12 CBUR-813: update base image version
- 1.16.0-13 CBUR-487: hardcoded runAsGroup fix
- 1.16.0-14 CBUR-587: Remove unnecessary ports from CBUR, add image flavor to tag name
- 1.16.0-15 CBUR-614: Create an alert related to RBAC when CBUR is out of the hardened state
- 1.16.0-16 CBUR-834: Backup command output inconsistency
- 1.16.0-17 CBUR-616: Created alerts for Pod Security Standards
- 1.16.0-18vs CBUR-594: single volume snapshot
- 1.16.0-19 CBUR-889: Create hardening alerts for Pod Security Standards - message correction
- 1.16.0-20 CBUR-778: Remove support for avamar.useHelmPlugin
- 1.16.0-21 CBUR-884 & CBUR-897: Check pod status after pre-restore hook + k8s_s3.py logger warning misspell fix
- 1.16.0-22 CBUR-899: Fix missing namespace in host field inside audit log
- 1.16.0-23 CBUR-896: fix bug for security vulnerability issue reported in CSFS-56051
- 1.16.0-24 CBUR-770: CSF components integration (CITM, CLOG, CHAR, CRDB)
- 1.16.0-25 CBUR-892: Reduce cbur-main image size
- 1.16.0-26 CBUR-858: Update python packages
- 1.16.0-27 CBUR-898: Allowing NCS correct permissions in K8S version >= 1.25.x
- 1.16.0-28 CBUR-665 & CBUR-851: Update base images and tools versions, 'TypeError' object is not subscriptable - self-backup CBUR
- 1.16.0-29 CBUR-920: CSF components integration (CLOG, CRDB) - part 2
- 1.16.0-30 CBUR-918: After enabling 'enableDefaultCpuLimits' CBUR chart is not picking custom limits.cpu
- 1.16.0-31 CBUR-937: Fix rendering of post-delete-job
- 1.16.0-32 CBUR-774: Checking clusterId and clusterName while startup
- 1.16.0-33 CBUR-660: Use metadata file to detect pvc source for single snapshot
- 1.16.0-34 CBUR-774: Checking cluster_id and cluster_name while startup loop fix
- 1.16.0-35 CBUR-981: Fix for volume snapshot backup with unmounted PVC
- 1.16.0-36 CBUR-1000: Fix for pre-upgrade-job with auth enabled
- 1.16.0-37 CBUR-1014: Fix certificate paths in cbur-cli auth.sh
- 1.16.0-38 CBUR-1015: fix encryption issue during volume snapshot BR
- 1.16.0-39 CBUR-1016: Address Sonarqube blocker bugs
- 1.16.0-40 CBUR-1021: fix for restore when only K8SOBJECT resources are used
- 1.16.0 CBUR-669: Release the official chart.

## [1.15.0] - 2023-09-22
### Changed
- 1.15.0-1 CSFLCM-10020: CBUR to support HBP 3.5.0
- 1.15.0-2 CSFLCM-10044: cbur helm chart to support GCS configuration
- 1.15.0-3 CSFLCM-10052: add post delete job to delete cbur-basic-auth secret
- 1.15.0-4 CSFLCM-10052: change container name
- 1.15.0-5 CSFLCM-9177: enhance upstream-vhost annotations
- 1.15.0-6 CSFS-54195:   fix bugs on CBUR PDB value handling
- 1.15.0-7 CSFLCM-10053: CBUR to support HBP 3.6.0
- 1.15.0-8 CBUR-160: add ability to choose avamar client version, add hostAliases to avamar pod
- 1.15.0-9 CSFLCM-9995: Update to the latest images.
- 1.15.0-10 CBUR-266: cbur legacy short svc name parameter in values (legacyShortSvcName)
- 1.15.0-11 CBUR-290: hardcoded python packages versions
- 1.15.0-12 CBUR-116: Add securityContext.runAsGroup
- 1.15.0-13 CBUR-195: skip namespace BrPolicy object removal before restore to keep status section
- 1.15.0-14 CBUR-435: add debug logs about forbidden access error during backup and restore
- 1.15.0-15 CSFLCM-10191: Remove obsolete helm3 home path and reword comments
- 1.15.0-16 CBUR-498: use root as a default avamar user
- 1.15.0 CSFLCM-9995: Release the official chart.

## [1.14.0] - 2023-06-23
### Changed
- 1.14.0-1 CSFS-52468: CBUR to support clusterIP when use GKE build-in ingress controller
- 1.14.0-2 CSFCLM-9601: CBUR to support HBP 3.3.0
- 1.14.0-3 CSFCLM-9810: Remove cbur.fullname-secret-tls
- 1.14.0-4 CSFLCM-9328: Support integrity check before restore on helm chart
- 1.14.0-5 CSFLCM-9823: Fix cbur-avamar pod failing to come up due to port collision with harbor-ingress
- 1.14.0-6 CSFLCM-8730: CBUR to support modsecurity
- 1.14.0-7 CSFLCM-9719: Add a control in CBUR values.yaml to disable brpolicy permission
- 1.14.0-8 CSFLCM-9602: CBUR to support HBP 3.4.0
- 1.14.0-9 CSFS-53108: Cbur appends regex which causes ingress creation failure when ALB is used
- 1.14.0-10 CSFS-53108: Update the ingressType avaliable values.
- 1.14.0-11 CSFLCM-9858: Change the default values of CBUR chart and support K8s 1.20.
- 1.14.0-12 CSFLCM-9601: Add restriction for scccompProfile generation
- 1.14.0-13 CSFLCM-9774: Added VirtualService url prefix match
- 1.14.0-14 CSFLCM-9719: Add create permission to support disabling admin and accessAll; add new apiGroup ncs.nokia.com.
- 1.14.0-15 CSFLCM-9601: Add podNamePrefix and containeNamePrefix restriction per HBP 3.4.0
- 1.14.0-16 CSFLCM-9824: Change the e2e integrity check default value to false
- 1.14.0-17 CSFLCM-9602: Fix bug when generating issuer
- 1.14.0-18 CSFS-53493: Fix bug for volumeMount failure in k8swatcher pod when celery not enabled
- 1.14.0-19 CSFLCM-8730: update modsecurity for CBUR chart
- 1.14.0-20 CSFLCM-9602: add Checksum for certification
- 1.14.0-21 CSFLCM-9602: Fix issues for certification
- 1.14.0 CSFLCM-9602: Release the official chart.

## [1.13.0] - 2023-03-24
### Changed
- 1.13.0-1 CSFS-49677: CBUR backup/restore process fails when we upgrade helm chart after modifying cbur-celery values
- 1.13.0-2 CSFLCM-9244: add pss related settings in README.md
- 1.13.0-3 CSFLCM-9275: Remove files in /BACKUP when upgrade
- 1.13.0-4 CSFLCM-9278: cbur ingress creation create route automatically for OpenShift
- 1.13.0-5 CSFLCM-9275: Also remove files in /BACKUP when install
- 1.13.0-6 CSFLCM-9247: CBUR HBP 3.2.0 support to support unifiled logging extension and imageFlavor
- 1.13.0-7 CSFLCM-9316: cbur chart to add service.type in values.yaml
- 1.13.0-8 CSFS-50949: Add matchLables for cbur PeerAuthenthication
- 1.13.0-9 CSFLCM-9342: provide config flexibility for syslog tls secret and add Priority tag to syslog message
- 1.13.0-10 CSFLCM-9289: update chart to use correct image
- 1.13.0-11 CSFLCM-9287: cronjob couldn't be created if auth enabled
- 1.13.0-12 CSFLCM-9342: port code to main branch
- 1.13.0-13 CSFS-50801: fix CBUR cron scheduling failure due to setting seccompProfile
- 1.13.0-14 CSFLCM-9437: CBUR to support ephemeral storage configuration
- 1.13.0-15 CSFLCM-9437: remove the subpath for tmp directory volumemount which will cause syslog not work
- 1.13.0-16 CSFLCM-9467: Add options for copy between cbura-sidecar and cburm.
- 1.13.0-17 CSFLCM-9467: Change "cpFromCbura" to "copyFromCbura".
- 1.13.0-18 CSFLCM-9231: Add startupCheck changes in values.yaml to README.md file
- 1.13.0-19 CSFLCM-9485: cbur chart change to support GKE ingress controller
- 1.13.0-20 CSFLCM-9247: update syslog unified loggingformat for extension.
- 1.13.0-21 CSFLCM-9467: Change varialbe names and use the latest images.
- 1.13.0-22 CSFLCM-9485: fix bug in ingress.yaml
- 1.13.0-23 CSFLCM-9556: Mount the .kube to the right directory
- 1.13.0-24 CSFLCM-9280: Use the latest images.
- 1.13.0 CSFLCM-9280: Release the official chart.

## [1.12.0] - 2022-12-08
### Changed
- 1.12.0-1 CSFS-48552: Unable to install cbur because of apigroup cbur.bcmt.local in roles
- 1.12.0-2 CSFLCM-8849: The cburm-ssh-public-key will be admin after helm upgrade if the pod isn't restarted
- 1.12.0-3 CSFLCM-8988: CBUR needs to create the VirtualService where istio is enabled but a gateway is not provisioned
- 1.12.0-4 CSFLCM-8958: Different workloads need to use different PDBs
- 1.12.0-5 CSFLCM-9021: fix checkstart pod failed
- 1.12.0-6 CSFLCM-9006:CBUR support output to syslog in addition to stdout
- 1.12.0-7 CSFLCM-9006:insert syslog side car to all CBUR pods
- 1.12.0-8 CSFLCM-9009: Remove the extra dirs in Avamar pod template
- 1.12.0-9 CSFLCM-9006:insert syslog side car to avamar pod
- 1.12.0-10 CSFLCM-9002: Comply to Helm Best Practices to apply new PSS
- 1.12.0-11 CSFLCM-9002: Modify the securityContext of syslogSidecar container and celery pod container
- 1.12.0-12 CSFLCM-9006: call supervisor config file *.syslog when syslog enabled
- 1.12.0-13 CSFS-48310: Add startupCheck of istio befroe starting application process
- 1.12.0-14 CSFLCM-9006: add support to output log to cbur-syslog side car console when syslog enabled
- 1.12.0-15 CSFLCM-9002: Fix bug when cbur running with root and k8s version is less than 1.25.
- 1.12.0-16 CSFS-49488: Add prefix for check-startup job related to pod name
- 1.12.0-17 CSFS-49529: Fix check-startup job doesn't exit due to long prefix
- 1.12.0-18 CSFLCM-9006: update syslog feature to meet HBP 3.2.0
- 1.12.0-19 CSFLCM-9002: add pss support for k8s version < 1.25
- 1.12.0-20 CSFLCM-9006: set runAsUser to 0 when its values is AUTO for avamar-syslog side car
- 1.12.0-21 CSFS-49485: make resources configurable for check-startup job
- 1.12.0-22 CSFLCM-9006: don't set runAsUser to 0 for syslogSideCar due to logrotate failing issue
- 1.12.0-23 CSFLCM-9006: set runAsUser to 0 for redis side car due to redis default user group not root and syslog side car can't access it
- 1.12.0-24 CSFLCM-9145: 1)fix restore k8s objects(statefulset pod) failed when using basic role 2)Use the latest cburm image
- 1.12.0-25 CSFLCM-9006: update omfwd option to line up with harbor
- 1.12.0-26 CSFLCM-9012: mount /usr/local/avamar/etc directory in avamar pod
- 1.12.0-27 CSFS-48310: fix bash not exit due to startupCheck of istio
- 1.12.0-28 CSFLCM-9009: Remove the extra dirs in Avamar pod template
- 1.12.0-29 CSFLCM-9012: copy the etc file from /usr/local/avamar/etc.bk
- 1.12.0-30 CSFLCM-9198: Remove extra parts in CBUR service and virtualservice templates
- 1.12.0-31 CSFLCM-9031: Update to use the latest images.
- 1.12.0-32 CSFLCM-9031: Update to use the latest images.
- 1.12.0-33 CSFLCM-9210: Fix the bug if define https.port when install/upgrade CBUR
- 1.12.0-34 CSFLCM-9212: Modify the ingress format in values.yaml
- 1.12.0 CSFLCM-9212: Release the official chart

## [1.11.0] - 2022-09-08
### Changed
- 1.11.0-1 CSFLCM-8589: Obsolete Helm v2 support and “brpolices.cbur.bcmt.local”
- 1.11.0-2 CSFS-46915: fix typo to change customlabels to customLabels
- 1.11.0-3 CSFLCM-8653: Add configurable item in the helm chart for nginx listen IP protocol
- 1.11.0-4 CSFLCM-8684: fix bug for readOnlyRootFilesystem in rbac.yaml and psp create for avamar
- 1.11.0-5 CSFLCM-8577: CBUR supports automated validation checking to ensure that the Upgrade/Rollback was successful
- 1.11.0-6 CSFLCM-8593: Pass server kubeVersion to CBUR containers to support multiple kube clients.
- 1.11.0-7 CSFLCM-8593: Upgrade redisio image and fix kubeVersion issues.
- 1.11.0-8 CSFLCM-8714: Update with the latest images.
- 1.11.0-9 CSFLCM-8629: fix bug in avamar pod that the certs volume should be readOnly
- 1.11.0-10 CSFLCM-8733: no checking Error status pod for post hook
- 1.11.0-11 CSFLCM-8577: add startupCheck parameter for ISU checking startup
- 1.11.0-12 CSFS-47048: Updating cbur's basic role by removing deletecollection verb from brhooks resource
- 1.11.0-13 CSFLCM-8605: enhance ingress to support TLS
- 1.11.0-14 CSFLCM-8605: fix ingress issue
- 1.11.0-15 CSFLCM-8605: Use the latest cburm image.
- 1.11.0-16 CSFLCM-8808: Build the CBUR chart with the latest images.
- 1.11.0 CSFLCM-8808: Release the official chart

## [1.10.0] - 2022-06-16
### Changed
- 1.10.0-1 CSFLCM-8503: CBUR supports Openshift 4.10 Kubernetes 1.23
- 1.10.0-2 CSFLCM-8409: Comply to HBP 2.2.0 and 3.0.0
- 1.10.0-3 CSFS-44900: Apply changes that done in NCC
- 1.10.0-4 CSFLCM-8409: Comply to HBP 2.2.0 and 3.0.0, changes to labels and annotations etc.
- 1.10.0-5 CSFLCM-8409: Comply to HBP 2.2.0 and 3.0.0, fix bug for pdb
- 1.10.0-6 CSFLCM-8535: Support SSE-KMS integrity check
- 1.10.0-7 CSFLCM-8535: Update the image tag in values.yaml for SSE-KMS integrity check
- 1.10.0-9 CSFLCM-8547: Update the image tag in values.yaml for auto scheduled backup
- 1.10.0-10 CSFLCM-8531: update the iamge tag
- 1.10.0-11 CSFLCM-8531: add handle_istio logic in pre-upgrade hook when istio is enabled
- 1.10.0-12 CSFLCM-8560: Fix volumesnapshot restore issue when adminRole is false
- 1.10.0-13 CSFLCM-8432: Upgrade cburm image with the latest clog.
- 1.10.0 CSFLCM-8432: Release the official chart
### Added
- 1.10.0-8 CSFLCM-8531: cbur chart code change to support pre-upgrade to backup cbur self

## [1.9.0] - 2022-04-29
### Changed
- 1.9.0-1 CSFS-43881: Unable to take backup from CBUR 1.8.0 installed in csf-app namespace, but works if CBUR is deployed in default namespace
- 1.9.0-2 CSFLCM-8255: Allow CBUR to delete pod during restore
- 1.9.0-3 CSFLCM-8255: Change cburm tag
- 1.9.0-4 CSFLCM-8289: CBUR Support for multi-namespaced in namespace mode
- 1.9.0-5 CSFLCM-8271: add S3 bucket encurption via KMS
- 1.9.0-6 CSFLCM-8308: Remove the extra rules for volumesnapshotclasses and CRDs
- 1.9.0-7 CSFLCM-8280: CBUR code enhancement to remove psp.create option in values.yaml
- 1.9.0-8 CSFLCM-8324: Namespace backup/restore change to support multiple namespace backup/restore
- 1.9.0-9 CSFLCM-8355: CBUR ingress apiGroup change to comply to kubectl 1.22
- 1.9.0-10 CSFLCM-8360: Add the delete/deletecollection permission in basic_role.yaml
- 1.9.0-11 CSFS-44243: Allow exclusion of DaemonSet from permissions for basic role
- 1.9.0-12 CSFS-43520: Increase the default celery memory requests / limits and cpu requests
- 1.9.0-13 CSFLCM-8313: Use the latest crdb/redisio image.
- 1.9.0-14 CSFLCM-8374: Use the latest cburm image.
- 1.9.0-15 CSFLCM-8383: The cburm-ssh-public-key will be admin after helm upgrade and the pod isn't restarted
- 1.9.0-16 CSFLCM-8383: Revert the code change for cburm-ssh-public-key secret as the lookup function has bug when helm version < 3.2
- 1.9.0-17 CSFLCM-8313: Remove vi from official delivery.
- 1.9.0-18 CSFLCM-8397: CBUR psp change to support istio cni disable
- 1.9.0-19 CSFLCM-8271: Enhancment for CBUR add S3 bucket encurption via KMS
- 1.9.0-20 CSFLCM-8313: Update cbur-avamar Rocky8 image to fix one CVE.
- 1.9.0 CSFLCM-8313: Release the official chart

## [1.8.0] - 2022-01-29
### Changed
- 1.8.0-1 CSFS-40716: support retaining CBUR PVCs with uninstall of cbur master
- 1.8.0-2 CSFLCM-7907: Run containers as read-only
- 1.8.0-3 CSFLCM-8079: CBUR to line up with CSF Helm Best Practices #165~1.1.0
- 1.8.0-4 CSFS-41649: Writing CBUR alarm logs to BR.log
- 1.8.0-5 CSFLCM-8082: CBUR to line up with CSF Helm Best Practices v2.0.0
- 1.8.0-6 CSFLCM-8082: CBUR to add PDB to line up with CSF Helm Best Practices v2.0.0
- 1.8.0-7 CSFLCM-7899: Nginx security hardening 8.1 and 12.1
- 1.8.0-8 CSFLCM-8035: Remove the sensitive information from the env
- 1.8.0-9 CSFLCM-8123: CBUR to line up with CSF Helm Best Practices v2.1.0
- 1.8.0-10 CSFLCM-8082: undo changes to priorityClassName to avoid inconsistency across releases
- 1.8.0-11 CSFLCM-7907: Fix the bug of run containers as read-only in openshift env
- 1.8.0-12 CSFLCM-8035: Fix the bug for removing the sensitive information from the env
- 1.8.0-13 CSFLCM-8035: Fix the cephs3 compatible issue for removing the sensitive information from the env
- 1.8.0-14 CSFLCM-8137: cbur chart enhancement to support psp create
- 1.8.0-15 CSFLCM-8137: cbur chart enhancement to support psp create
- 1.8.0-16 CSFLCM-8035: Fix the compatible issue
- 1.8.0-17 CSFLCM-8136: Add feature flag for snapshot
- 1.8.0-18 CSFLCM-8137: cbur chart bug fix for psp create feature
- 1.8.0-19 CSFLCM-8137: fix bug in basic-role.yaml
- 1.8.0-20 CSFLCM-8137: fix bugs
- 1.8.0-21 CSFLCM-8137: Modify allowedHostPaths in psp and CBUR basic roles.
- 1.8.0-22 CSFLCM-8137: fix bug for istio and add more rules in cbur basic role
- 1.8.0-23 CSFLCM-8168: Modify roles and psp for several scenarios.
- 1.8.0-24 CSFLCM-8145: Modify crdb/redisio tag to use the latest one.
- 1.8.0-25 CSFLCM-8035: Fix the bug for removing the sensitive information from the env
- 1.8.0-26 CSFLCM-8136: CBUR supports volumesnapshot backup, modify the default value for snapshot in values.yaml
- 1.8.0-27 CSFLCM-8136: CBUR supports volumesnapshot backup, add the replicasets permission in basic_role
- 1.8.0-28 CSFLCM-8135: fix about SNAPSHOT_ENABLED default is false issue in cburm
- 1.8.0 CSFLCM-8135: Release the official chart

## [1.7.3] - 2021-11-25
- 1.7.3-1 CSFS-40716: update keep_pvc to keepPvc per helm best practice request
- 1.7.3 CSFS-40716: Release the official chart

## [1.7.2] - 2021-11-24
### Changed
- 1.7.2-1 CSFLCM-8036: remove path /opt/bcmt/config/bcmt-cmdb from hostPath and provide patch 1.7.2
- 1.7.2 CSFLCM-8036: Release the official chart

## [1.7.1] - 2021-10-19
### Changed
- 1.7.1-1 CSFS-40187: Update BrPolicy to use cbur.csf.nokia.com and not cbur.bcmt.local
- 1.7.1-2 CSFLCM-7952: Enhance CBUR cluster restore without helm2
- 1.7.1 CSFLCM-7970: Release the official chart
### Removed
- 1.7.1-3 CSFLCM-7970: Remove NetBackup from cbur delivery.
### Fixed
- 1.7.1-4 CSFLCM-7970: fix backuphist and requesthist timestamp don't match

## [1.7.0] - 2021-09-30 (Internal)
### Changed
- 1.7.0-1 CSFS-37694: Helm test failed for CBUR 1.5.0 pods in Customer Openshift environment
- 1.7.0-2 CSFS-38046: Restore may fail if selectPod is removed or changed to other pod.
- 1.7.0-3 CSFLCM-7603:CBUR to support backup/restore k8s namespace.
- 1.7.0-6 CSFS-39739: helm test failed in openshift env
- 1.7.0-7 CSFLCM-7919: update with latest code
- 1.7.0-8 CSFS-40303: Change cronjob to use the tolerations defined in CBUR helm values
- 1.7.0-9 CSFLCM-7921: In NCS namespaced scope, cbur-master rolebinding and cbur-master-cbur-basic-namespaced both bond to SA
- 1.7.0-10 CSFLCM-7923: helm install/upgrade failed with .Values.ingress.enable not exist
- 1.7.0 CSFLCM-7938: Release the official chart
### Fixed
- 1.7.0-4 CSFLCM-7890: Fix Avamar log rotation issue and mount new NCS user-db4keycloak path.
### Security
- 1.7.0-5 CSFLCM-7892: Nginx security hardening.

## [1.6.2] - 2021-07-12
### Changed
- 1.6.2-2 CSFS-37694: Helm test failed for CBUR 1.5.0 pods in Customer Openshift environment
- 1.6.2-2 CSFLCM-7682: Modify some info in README.md and basic_role.yaml.
- 1.6.2-3 CSFLCM-7671: redisio:3.2-1.2114.el7. docker image for ncm19.12.2
### Security
- 1.6.2-1 CSFLCM-7671: update docker image for ncm19.12.2

## [1.6.1] - 2021/07/05
### Changed
- 1.6.1-1 CSFS-37694: Helm test failed for CBUR 1.5.0 pods in Customer Openshift environment
- 1.6.1-2 CSFLCM-7682: Modify some info in README.md and basic_role.yaml.
- 1.6.1 CSFLCM-7682: Release the official chart.

## [1.6.0] - 2021-05-31
### Added
- 1.6.0-1 CSFLCM-7563: upgrade base image and installed packages
- 1.6.0-2 CSFLCM-7585: Only deployment_netbkup.yaml is using .Values.global.defaultNodeSelector
- 1.6.0-3 CSFLCM-7471: Adding k8s best practice labling
- 1.6.0-6 CSFS-36712: Support helm3 upgrade for CBUR release converted from Helm v2
### Changed
- 1.6.0-4 CSFS-36886: Do not use env variables to store secret for redis password
- 1.6.0-5 CSFS-36768: Default dnsPolicy to ClusterFirstWithHostNet for Avamar pod and Netbackup pod
- 1.6.0-7 CSFLCM-7587: Change the default tolerations
- 1.6.0-8 CSFS-37493: For namespace scoped CBUR, add control to limit initial permissions to Kubernetes resources
- 1.6.0-9 CSFLCM-7632: Rebuild cbur-cli and cbura images.
- 1.6.0-10 CSFS-37518: Export locale in Centos7.
- 1.6.0-11 CSFLCM-7632: Need to exclude the restoreCluster when lower the k8s_type
- 1.6.0 CSFLCM-7639: Release the official chart.

## [1.5.0] - 2021-03-12
### Added
- 1.5.0-4 CSFS-34075: Add custom helm annotations.
### Changed
- 1.5.0-1 CSFS-30987: CBUR helm rollback fails
- 1.5.0-2 CSFLCM-7476: The BrPolicy name of cbur is incorrect when adding podNamePrefix
- 1.5.0-3 CSFLCM-7477: Change Avamar pod to use host network by default.
- 1.5.0-5 CSFLCM-7523: Namespace scoped CBUR cannot work in NCS20 FP2.
- 1.5.0 CSFLCM-7523: Release the official chart.

## [1.4.410] - 2021-01-27
###Changed
- 1.4.410 CSFS-33242: Remove namespace from long CronJob name for namespace scoped CBUR. (This is the patch on cbur-1.4.4)

## [1.4.5] - 2020-12-31
### Added
- incubating example only - behavior changed
- 1.4.5-2 CSFLCM-7397: Add new parameter predefined_bucket for AWSS3.
- 1.4.5-3 CSFLCM-7355: For Avamar, supports backup/restore longer than 1 hour
- 1.4.5-5 CSFS-31504: Add priorityClassName to CBUR pod
- 1.4.5-6 CSFLCM-7395: CBUR supports IPv6
- 1.4.5-8 CSFLCM-7355: support selective restoration of helm3 releases in cluster restore and fix bug
- 1.4.5-9 CSFLCM-7434: Compliance to Helm Best Practices
- 1.4.5-10 CSFLCM-7436: Add annotations to not regenerate redis_secret when run helm upgrade
- 1.4.5-11 CSFLCM-7438: Support separate Helm3 home and configure Helm2/Helm3 home automatically
### Changed
- 1.4.5-1 CSFLCM-7388: change brpolicy schema check default value to true
- 1.4.5-4 CSFLCM-7389: Remove crdb for cbur celery async task
- 1.4.5-7 CSFLCM-7424: Upgrade software version and fix cbur self BR issues for Avamar backend
- 1.4.5-12 CSFLCM-7438: Fix helmHome issue and remove hook annotations for "cbur-redis" secret.
- 1.4.5 CSFLCM-7434: Release the official chart.

## [1.4.4] - 2020-10-31
### Added
- 1.4.4-1 CSFS-29431: Containers dynamically created by cronjobs for scheduled backups do not specify resources required
- 1.4.4-2 CSFS-29431: Change repo to registry1 for cburm
###Changed
- 1.4.4-3 CSFLCM-7366: CBUR full istio support
- 1.4.4-4 CSFLCM-7366: CBUR full istio support bug fix
- 1.4.4-5 CSFLCM-7382: istio cronjob, gateway and virtualservice fix
- 1.4.4-6 CSFLCM-7382: Add documentation for new parameters.
- 1.4.4 CSFLCM-7382: Release the official chart.

## [1.4.3] - 2020-09-30
### Added
- 1.4.3-2: CSFS-28316: Add annotatoins in cbur deployment to disable istio injection
- 1.4.3-3: CSFS-28316: Add a new parameter nodeSelectorOverride to override hard code nodeSelector
- 1.4.3-4: CSFLCM-6231: Cluster backup / restore enhancement for supporting helm3
### Changed
- 1.4.3-1 CSFS-27262: Add support to add prefix to pod names and container names
- 1.4.3 CSFLCM-7300: Release the official chart.
### Security
- 1.4.3-5 CSFLCM-7300: Remove encryption cmd from CBUR log

## [1.4.2] - 2020-09-02
### Changed
- 1.4.2-1 CSFLCM-7191: Fix cluster restore issues.
- 1.4.2-2 CSFLCM-7203: Change redisio version to line up with NCS 20 FP1.
- 1.4.2 CSFLCM-7203: Release the official chart.

## [1.4.1] - 2020-08-10
### Changed
- 1.4.1-1 CSFLCM-6706: support auth with SSO (REVERTED)
- 1.4.1-2 CSFLCM-7042: Revert 1.4.1-1 and use the newest images.
- 1.4.1-3 CSFS-27101: Add workaround for gateway timeout issue.
- 1.4.1 CSFS-27101: Release the official chart.

## [1.4.0] - 2020-07-17
### Added
- 1.4.0-1 CSFLCM-6232: add fixed labels to the service to let users or helm plugins easily find it instead of fixed release name
- 1.4.0-2 CSFLCM-6232: remove the dependency of the helm and kubectl CLIs in host
- 1.4.0-3 CSFLCM-6331: Not set up PVC and secret for cluster BR when k8swatcher and support basic auth in openshift
- 1.4.0-4 CSFS-24908:  fix b64enc returns nil on empty string
- 1.4.0-5 CSFLCM-6457: CBUR support https certs file user configurable
- 1.4.0-6 CSFLCM-6449: master, watcher and celery containers can run as an arbitrary uid but will only can provide limited functions
- 1.4.0-9 CSFLCM-6332: k8swatcher can watch namespace level and cluster level crd event
- 1.4.0-12 CSFLCM-6781: Add new backend "SWIFTS3".
### Changed
- 1.4.0-7 CSFLCM-6449: to add fsGroup in case no writable permission in the mounted volumes
- 1.4.0-8 CSFLCM-6449: let master, watcher and celery containers avoid changing /etc/passwd (related vulnerability refer to https://access.redhat.com/articles/4859371)
- 1.4.0-10 CSFLCM-6493: To give the least privilege Role/RoleBinding when CBUR function is limited in a namespace
- 1.4.0-11 CSFLCM-6332: brpolicy and brhook crd will be manually installed, so don't need to create cluster role.
- 1.4.0-13 CSFLCM-6493: to add roles for maintaining the hook jobs of BrHook
- 1.4.0-14 CSFLCM-6871: Support https endpoint for SwiftS3 and CephS3
- 1.4.0-15 CSFLCM-6921: For Avamar, the files should be remained for retry; CSFLCM-6884: cluster restore should work for S3
- 1.4.0 CSFS-26692: remove schema check for k8sobject when enableBrSchemaValidation is false

## [1.3.6] - 2020-04-15
### Added
- 1.3.6-1 CSFS-21180: Avamar client name support
- 1.3.6-2 CSFLCM-4257: Mount helm3 to cbur pods
### Changed
- 1.3.6-3 CSFS-21117: To add readinessProbe to cbur master deployment in case other apps fail to be installed when cbur is not ready
- 1.3.6-4 CSFLCM-5551: Restore all in BrPolicy if both --volume and --object_type args not provided.
- 1.3.6-5 CSFS-21252: Add enable flag for brpolicy schema validation
- 1.3.6-6 CSFLCM-5630: Change counter to timeout and install tar to Avamar image.
- 1.3.6-7 CSFLCM-5659: helm3 path can be not defined.
- 1.3.6-8 CSFLCM-5001: support direct pvc backup / restore
- 1.3.6-9 CSFLCM-5816: if no data needs to backup, restore return immediately without sync backup history
- 1.3.6-10 CSFLCM-5688: Change BrHook group name to cbur.csf.nokia.com.
- 1.3.6-11 CSFLCM-6020: Job failures need to include activeDeadlineSeconds timeout
- 1.3.6-12 CSFLCM-6071: local rotation method change to use backup id timestamp instead of modification time
- 1.3.6 CSFLCM-4911: internal enhancements and bug fixes

## [1.3.5] - 2020-01-21
### Added
- 1.3.5 CSFLCM-5010: Add CBUR web portal

## [1.3.4] - 2019-12-30
### Added
- 1.3.4-1 CSFLCM-4224: CCBUR need to update avamar client package version to 18.2
- 1.3.4-2 CSFLCM-3507: Support backend SFTP to backup and restore
- 1.3.4-3 CSFLCM-3508: Support ssh hostkey check for backend SFTP
- 1.3.4-6 CSFLCM-4481: Support audit log
### Changed
- 1.3.4-4 CSFS-18189: rebuild cbura image to update alpine version
- 1.3.4-5 CSFLCM-3508: add ssh mode configuration
- 1.3.4-7 CSFLCM-4224: Add compatibility of Avamar client 7.4
- 1.3.4-8 CSFLCM-4481: fix bug in k8s watcher
- 1.3.4-9 CSFLCM-4515: To make resources configurable for each container
- 1.3.4-10 CSFLCM-4740: To give the minimum values for default requests.cpu and requests.memory for minimizing the CPU requirements of BCMT controller node
- 1.3.4-11 CSFLCM-4831: enhance for backup/restore in CBUR side
- 1.3.4-12 CSFLCM-4740: To give the minimum resources to avamar
- 1.3.4 CSFLCM-4256: Enhancements and Bug fix

## [1.3.3] - 2019-12-19 (cbur-ce)
### Added
- 1.3.3-1 CSFLCM-4448: mount helm home to avamar client pod
- 1.3.3-2 CSFLCM-4448: mount kubectl to avamar client pod in case helm plugin use it to create hook job
- 1.3.3-3 CSFS-18567: helm search only output lowercase chart name but helm install is case sensitive
- 1.3.3-4 CSFLCM-4628: support excluding brpolicy and disabling execution of hook job for avamar new.restore.sh
- 1.3.3 CSFLCM-4447: temp solution for avamar client hooks to use hook job

## [1.3.2] - 2019-09-28
### Added
- 1.3.2-1 CSFLCM-3574: add new param for enable / disable auth to support cbur auth
- 1.3.2-2 CSFLCM-3546: to support rwx pvc for netbackup and avamar pod
- 1.3.2-3 CSFLCM-3301: to support using pvc name directly
- 1.3.2-4 CSFLCM-3355: add ingress to open api and portal
- 1.3.2-5 CSFS-16143: Support running hooks on all pods even if the backup/restore is done on one pod.
- 1.3.2-6 CSFS-16143: update ingress and add secret tls and update helm-cli in deployment/deployment_mycelery
- 1.3.2-7 CSFLCM-3955: support upgrade changing strategy from RollingUpdate to Recreate
### Changed
- 1.3.2-8 CSFLCM-3994: direct redis created by cbur can listen IPv6 address
- 1.3.2-9 CSFLCM-3985 & CSFLCM-4012 & CSFLCM-4013: issue fixes
          CSFLCM-3574: update avamar backup and restore
- 1.3.2-10 CSFLCM-4033: let scripts in cli and avamar support https
- 1.3.2 CSFID-2390: support auth

## [1.3.1] - 2019-08-30
### Added
- 1.3.1-1 CSFLCM-3504: support disabling CBUR encryption in BrPolicy
- 1.3.1-3 CSFLCM-3430: To use BCMT's redis image as an option other than crdb
- 1.3.1-5 CSFLCM-3430: make redis exposed port configurable
- 1.3.1-6 CSFLCM-3663: Add option in BrPolicy to ignore file changes during backup on cbura sidecar
### Changed
- 1.3.1-2 CSFLCM-3504: Fix crdb-redisio version to "5.0.1" temporary since CBUR didn't find way to disable the metrics feature in the new release.
- 1.3.1-4 CSFLCM-3430: To let directly using redis image be backward compatible with previous celery option
- 1.3.1-7 CSFLCM-3740: To directly use crdb/redisio image
- 1.3.1 CSFLCM-3620: To support cluster level Secrets/ConfigMaps backup and restore

## [1.3.0] - 2019-07-04
### Added
- 1.3.0-1 CSFLCM-2864: mount cluster host paths to cbur master pod for backup
- 1.3.0-2 CSFLCM-2881: make clusterId configurable and can configure onlyRestore to let CBUR only do restore and cluster restore
- 1.3.0-3 CSFLCM-2869: make integrity check for "local transfer" and "s3 upload/download" configurable
- 1.3.0-5 CSFLCM-2868: Configure the storage threshold
### Changed
- 1.3.0-4 CSFLCM-2864: mount cluster host paths to celery when celery is enabled
- 1.3.0-6 CSFLCM-2864: improve brpolicy
- 1.3.0-7 CSFLCM-3037: move to the centos-nano image as the base image
- 1.3.0-8 CSFLCM-2864: mount /CLUSTER/netbackup to NetBackup pod
- 1.3.0-9 CSFID-2143: cluster level and app level backup / restore
- 1.3.0-10 CSFS-14262: make Restful API backward compatibility
- 1.3.0 CSFID-2143: cluster level and app level backup / restore

## [1.2.9] - 2019-05-17
### Added
- 1.2.9 CSFID-2148: add new apis for enable / disable scheduled backup and add alarm support
### Changed
- 1.2.9 CSFS-13111: To remove incomplete backup data when backup failed and to remove temp backup data after coping to remote
- 1.2.9-3 CSFLCM-2845: add a default brpolicy for backup itself
- 1.2.9-1 CSFLCM-2626: merge cburm, watcher and celery to one docker image
- 1.2.9-2 CSFLCM-2572: let CBUR pod timezone be the same with host

## [1.2.8] - 2019-03-29
### Added
- 1.2.8 CSFS-11712: S3 buckets used by CBUR need to have AES-256 Server side encryption and S3 server access logging enabled
- 1.2.8-3 CSFS-11701: Make bucket prefix configurable in values.yaml
- 1.2.8-2 CSFLCM-2339: add flag to indicate if enable CLOG logging and add logging level settings for stdout and file respectively
### Changed
- 1.2.8-1 CSFS-10653: passing the release name not chart name to helm importer
- 1.2.8 CSFLCM-2372: change default tolerations for BCMT 19.03
### Security
- 1.2.8 CSFLCM-2530: upgrade 3rd party software to latest versions

## [1.2.7] - 2019-02-27
### Added
- incubating example only - behavior changed
- 1.2.7-1 CSFS-10726: Add a new parameter "GLOBAL_BACKEND" in CBUR chart to override BrPolicy backend

## [1.2.6] - 2019-01-31
### Added
- incubating example only - behavior changed
- 1.2.6-4 CSFLCM-2295: fix typo
- 1.2.6-3 CSFLCM-2295: cbur chart change to add S3Settings parameter
- 1.2.6-2 CSFLCM-2254: add a new secret cburm-ssh-public-key to attach to netbackup pod as authorized_keys

### Changed
- incubating example only - existing behavior changed
- 1.2.6-7 CSFLCM-2343: Fix typos and change image versions to the latest one.
- 1.2.6-6 CSFLCM-2295: change AWSS3 and CEPTHS3 settings in values.yaml
- 1.2.6-5 CSFS-9891: to sync backup history between brpolicy and cburm local record
- 1.2.6-1 CSFLCM-2193: Attach volume for cbura

## [1.2.5] - 2019-01-04
### Added
- incubating example only - behavior changed
- 1.2.5-1 CSFLCM-2095: add deployment definition for k8s watcher
- 1.2.5-6 CSFLCM-2095: add secret for ncm data
- 1.2.5-8 CSFLCM-2095: add a new glusterfs volume for storing cluster data
### Changed
- incubating example only - existing behavior changed
- 1.2.5-0 CSFS-7875: add resources definition for auto-injected sidecar
- 1.2.5-1 CSFLCM-2095: mount new volume for storing backup cluster level data in cburm
- 1.2.5-1 CSFS-8716: create clusterroles for brpolices.cbur.bcmt.local
- 1.2.5-2 CSFLCM-2114:cburm pod failed for incorrect name of redis secret if celery enabled
- 1.2.5-3 CSFLCM-2099: include kubectl cli in cburm
- 1.2.5-4 CSFLCM-2096:include docker/ncm/helm cli in cburm
- 1.2.5-5 CSFLCM-2097: To restore BCMT cluster level data
- 1.2.5-7 CSFLCM-2099:include kubectl cli in mycelery
- 1.2.5-9 CSFLCM-2095: set k8swatcher.enabled to be false in default
- 1.2.5-10 CSFLCM-2097: Restore form netbackup & change docker images version

## [1.2.4] - 2018-11-08
### Changed
- 1.2.4-0 change crdb-codis to crdb-redisio and also using redisio password for auth
- 1.2.4 change cburm version with which fix issue CSFS-8048

## [1.2.3] - 2018-10-31
### Changed
- 1.2.3-1: CSFLCM-1830: CBUR needs to support backup cbur-repo to remote server
- 1.2.3-0: rename glusterfs.enable to volumeType.glusterfs

## [1.2.2] - 2018-09-30
### Added
- incubating example only - behavior changed
- https env enhancement for celery and cburm
- add glusterfs volume mounts to celery
- add AVAMAR_ENABLE to cburm and CELERY_ENABLED to avamar deployment. Sync all env to celery deployment
- add env for deployment_netbkup.yaml
- https support
### Changed
- change avamar/netback to use the same value, update cburm/celery images
- change chart version
- add CBURM_NAME and CBURM_PORT in env for cronjob
- CSFS-6618: use combined matchlabels to get deployment/statefulset pod name
- change netbkup chart to remove policy_name and change cburm ENV
- CSFLCM-1568 initial netbkup deployment

## [1.2.1] - 2018-08-30
### Changed
- CSFS-6459 fix for new cburm version 1.8-14-353, new avamar version 0.0.1-354
- CSF chart relocation rules enforced
- initial avamar deployment and relocable support
- add cli image version and env for k8s cronjob

## [1.1.2] - 2018-08-22
### Changed
- change cburm version which has critical fix for CSFLCM-1611

## [1.1.1] - 2018-08-10
### Added
- All future chart versions shall provide a change log summary

## [0.0.0] - YYYY-MM-DD
### Added | Changed | Deprecated | Removed | Fixed | Security
- your change summary, this is not a **git log**!

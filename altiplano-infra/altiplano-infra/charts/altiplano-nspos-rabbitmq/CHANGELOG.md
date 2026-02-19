# Changelog
All notable changes to chart **crmq** are documented in this file,
which is effectively a **Release Note** and readable by customers.
## [Unreleased]


## [4.3.2] - 2023-08-16
#Changed
- update docker tags after base image update
- update docker tags to delivered

## [4.3.1] - 2023-07-20
#Changed 
- update docker tags 
- improve resource deletions in post delete job. (CSFS-53732)
- update docker tags 
- update docker tags 
- update docker tags to delivered 

## [4.3.0] - 2023-06-30
#Changed 
- update docker tags 
- update docker tags 
- update docker tags and fix for CSFS-53510
- version upgrade to rabbitmq-3.12.0, erlang-26.0.1
- HBP 3.3 and 3.4
- update docker tags 
- update helm tests for latest pika module.
- version reverts to rabbitmq-3.11.18, erlang-25.3.2.2
- update docker tags as delivered 

## [4.2.1] - 2023-05-04
#Changed 
- revert patch for crmq 22.12FP2PP3 
- update docker tags to delivered

## [4.2.0] - 2023-03-31
#Added
- rollme annotation. Fix for [CSFS-51899]
- PSA requirement with restricted enforce as capabilities.drop to included ALL.
#Changed
- Fix for CSFS-52145
- securityContext addition in scalein job
- management tls helper function fix. 
- Version Upgrade to 3.11.10
- update docker tags to delivered

## [4.1.2] - 2023-02-08
#Changed
- support for auto enable cbur cron jobs
- update docker tags
- update docker tags for delivered

## [4.1.1] - 2023-01-17
#Changed
- fix for duplicate cluster roles
- update docker tags
- update docker tags
- update docker tags for delivered

## [4.1.0] - 2022-12-16
#Changed
- upgrade rabbitmq version to 3.11.3 and erlang version to 25.1.2
- HBP 3.1.0 
- image tag updates
- add seccomp profile annotation to security context
- add volume mount for syslog directory
- image tags update
- image tags update

## [4.0.1] - 2022-11-07
#Changed
- upgrade rabbitmq version to 3.11.0 and erlang version to 25.1.1
- partOf label to be rendered if crmq chart is a dependency chart
- labels and annotations removed from istio-virtualservice.yaml when shared gateway is used.
- Revert version upgrade and plugin version fix
- update image tags

## [4.0.0] - 2022-09-28
#Changed
- Artifactory url change to repo.cci.nokia.net and update docker tag
- hook weights for helm test is reordered
- Update docker image tag after version upgrade to 3.10.7
- Update docker image tag
- image tag update for docker dependency reduction
- docker updates to delivered

## [3.2.1] - 2022-07-22
#Changed
- named template changes for common functions

## [3.2.0] - 2022-06-29
#Added
- Add heal jobs.
- Add support for dual stack.
#Changed
- upgrade rabbitmq version to 3.9.15 and erlang version to 24.3.3
- base image updates and tag updates for kubectl and cbur.
- HBP 2.2.0 code changes
- checksum removed from statefulset
- apiVersion changes for CBUR
- Configure healthCheckPort and stopPort
- upgrade rabbitmq version to 3.9.16 and base image updates
- fix for certmanager api version
- User created secret delete issue fixed
- Add ephemeral-storage to resources
- hbp timezone fix for heal jobs
- resources limits for heal jobs
- image tag update, registry updated to delivered.

## [3.1.0] - 2022-04-01
#Added
- Added autoMountServiceAccountToken.
- Tls1.3 support
- Interbroker TLS
- Interbroker TLS with Cert-Manager
- IPV6 changes for internode tls
#Changed 
- Fix for CSFS-44322 and kubectl docker tag update
- upgrade rabbitmq version to 3.9.11 and new image rocky8-python36-nano:3.6.8-20211213
- upgrade rabbitmq version to 3.9.13
- Chart.yaml API version updated to v2 helm3 support.
- helm test hook annotation updated.
- crmq test debug statements added.[CSFS-40093]
- kubectl exec with container names. [CSFS-43478]
- istio-proxy check enhanced. [CSFS-43568]
- password update added in dynamic config block [CSFS-37744]
- make dnsConfig optional and diabled by default [CSFS-43991]
- ingress api change for k8s1.22
- added prometheus port annotation to fix [CSFS-43968]
- image tag upgrade + ciphers comment alignment.
- image tag update, registry updated to delivered.

## [3.0.0] - 2021-12-17
#Added 
- Ckey integration. [CSFAR-3985]
- SupplemtalGroups + SELinux support. [CSFAR-4036]
- PriorityClass support for statefulset. [CSFID-3287]
#Changed
- PodDisruptionBudget podname prefix
- Helm Best Practice,timezone [CSFS-41458].
- Added pod anti affinity support for the pods jobs and tests.
- removed the existing affinity support for statefulset, and affinity is now based on pod labels.
- remove plaintext username/password fields from values.yaml file, added support to take default creds from secret.
- Check to ignore commented dynamic config commands in post-install and post-upgrade job.
- configurable domain names [CSFS-31476].
- Tls configuration fix for ingress.
- Helm Best Practices - 189 (Common Labels)
- Helm Best Practices (serviceAccountName separate from rbac flag)
- App version update
- Disable non tls amqp port when tls is turned on.
- Fix for Rollback issue and Base Image Update
- HBP istio Block (1.2.0)
- Deprecate file content and path mode of configuring tls, provide new secret method of cert input.
- support pod topology spread constraints for crmq statefulset. [CSFID-3656]
- helm test enhanced [CSFS-40093].
- Verify peer support for management port.
- prometheus cert password taken as secret.
- image tag update
- PDB support [CSFS-40217] 
- istio peer authentication check enhanced. [CSFS-41592]
- post-delete job and associated SA,roles annotations added for helm3.
- tls flag defaults to true.
- securityContext in jobs and helm tests.
- helm test image tag update.
- registry updated to delivered and image tags update

## [2.12.0] - 2021-08-26
- add cipher suite order paramaters
- changed repo to candidates and updated imageTag
- added random user support.
- added support for Issuer reference groups [CSFS-38795]
- istio >1.5 mtls strict mode support.
- post upgrade job fix.
- istio mtls strict fix for headless svc wrt ports.
- 3371 csfid fix for upgrade/rollback issue wrt erlang cookie
- erlang cookie upgrade/rollback fix.
- Added job resources to postscalein and postupgrade jobs.
- Helm test docker image tag changes
- password change enhancement

## [2.11.4] - 2021-06-23
- add rabbitmq 3.8.17 + erl 24.0.2
- add /tmp volumes to be able to run backup/restore for cbur sidecar

## [2.11.3] - 2021-06-10
- add new helm test image ( back to centos7 )

## [2.11.2] - 2021-06-10
- Fix allowedPrivilegedEscalation & readOnlyRootFilesystem that was not well set in sts and job, no more fail with helm3
- Add a diffrent post-upgrade job if rabbitmq.dynamicConfig.upgrade is set to true. This allow to set dynamicConfig also at upgrade time.
- remove url ref in README.md
- fix tls port exposition in case of uploadPath use.
- fix all kubectl command that use release={{ .Release.Name }} without ",app={{ template "rabbitmq.name" . }}" ( not enought specific in case of crmq use as subchart )
- fix CRMQ containers should have allowedPrivilegedEscalation set to false

## [2.11.1] - 2021-05-27
- disable helm test tls secret creation if not needed ( if cert-manager used or tls disable )

## [2.11.0] - 2021-05-24
- add uploadPath option to change cert path in rabibtmq configuration if client upload cert directly in the pod. ( with there own secret/volume ). 
- rabbitmq 3.8.16 + securityContext in values +  securityContext container set readOnlyRootFilesystem: true
- add tls option to load cert from path file
- fix delete with use fullnameOverride + add ingress path option + rollingupdate configurable
- add the option to change partOf value in commonLabels.

## [2.10.1] - 2021-04-08
- fix labels in volumeClaimTemplate in sts for helm3 upgrade 
- modify post-delete job to correctly remove all secret execept if owner helm.
- add values to change postDeletePolicy jobs.
- fix Best practice anti-affinity, nodeselector and tolerations for jobs

## [2.10.0] - 2021-02-24
- add rabbitmq_3.8.12-1.el7_erlang_23.2-1.el7
- add best practice labeling
- change hook-delete-policy to align with HBP
- add missing namespace in post-upgrade exec cmd.
- add custom.statefulset.annotations
- add new localtime option to disable the mount of /etc/localtime is needed

## [2.9.0] - 2021-01-29
- fixing values model & template
- add new rabbitmq 3.8.11
- add new rabbitmq 3.8.10 + needed to change default encryp password
- add new self-sign certificates tls4test
- add sts annotaion to reload secret if it change during upgrade. ( to refresh certs )
- add vm_memory_high_watermark_relative option to memory
- add rabbitmq prometheus tls 
- option clusterDomain to change sts DnsConfig with appropriate clusterDomain
- clean core dump in workingdir except first one

## [2.8.0] - 2020-12-01
	
- fix chart version re-release 2.4.7 as 2.8.0
	
## [2.7.1] - 2020-12-01	
- fix chart version re-release 2.4.6 as 2.7.1
	
## [2.7.0] - 2020-12-01	
		
- fix chart version re-release 2.4.5 as 2.7.0
	
## [2.6.0] - 2020-12-01
- fix chart version re-release 2.4.4 as 2.6.0
	
	
## [2.5.0] - 2020-12-01
- fix chart version re-release 2.4.3 as 2.5.0

## [2.4.7] - 2020-10-28
- fix tls enabled value value-model + memory values.
- rabbitmq_3.8.9-1.el8 & erlang_23.1-1.el8
- add helmTestDeletePolicy to change delete policy of helm test
- matching helm best practices.
- add rabbitmq.tls.versions to Limit TLS version used by rabbitmq.
- add tls.enabled option instead of checking tls on crt value.
- add memory values configuration + remove unused diskFreeLimit value.
- fix helm test when istio is enabled
- container guidelines for sensitive information

## [2.4.6] - 2020-09-08
- add condition on cni for podSecurityPolicy creation.
- fix backup issue due to rabbitmqadmin typo "python33"

## [2.4.5] - 2020-09-08
- rabbitmq 3.8.8
- fix conflict with post delete job and secret creation
- remove debug logs
- add prefix and suffix option for pod & container name.
- add call of post-delete on pre-install hooks.

## [2.4.4] - 2020-07-15
- rbac apiversion auto set based on k8s version 
- add rabbitmq-auth-backend-oauth2 compatibility
- change helm test tls check
- enable to set only serviceaccountName with rbac false
- update to crmq 3.8.5

## [2.4.3] - 2020-06-03
### Added
- new image with correct buildah erlang version
- add prom enable in j2
- add ipAddresses in CertManager
- istio support on BCMT20.03
- K8S 1.16 compatibility for PSP
- add rabbitmq.backuprestore.resources for CBUR sidecar
### Changed
- commonName in CertManager can be overwritten
### Fixed
- helm test with management in HTTPS

## [2.4.2] - 2020-04-30
- new image centos8-python3-nano-3.6.8-20200401
- Rabbitmq 3.8.3-1 & erlang 22.3.2-1
- update to kubectl 1.17.5
- Erlang ipv6 env was missing ipv6 with dynamic config now works
- Change rbac. to rbac.test for helm test ressources
- add ressources specification in post_upgrade
- add external rbac feature + helm test compatibility
- Fixed helm test on prometheus
- add rabbitmq.amqpSvc parameter
- open ssl port id cert_manager is used
- use_cert_manager replaced by certmanager.used

## [2.3.2] - 2020-03-24
- Job now fails if one user command fails to execute
- Adding resources in post-install
- Add some resilience when running commands in dynamicConfig (fixed)
- Added a maxCommandRetries parameter: how many times we should run a command before going to the next one
- prometheus plugin configuration for RabbitMQ 3.8

## [2.3.1] - 2020-03-12
- Fix Locale issue
- Use of centos8-python-nano image (rebuild docker image rabbitmq_3.8.2-1.el8_erlang_22.2.7-1.el8 (-610))
- fix backup.sh & restore.sh scripts
- post-install job now fails if the bash script command fails
- Change statefulset api version to v1
- Change for Helm Port Istio-Style Formatting

## [2.3.0] - 2020-02-26
### Added
- add log to console & delete log in file
- update to erlang 22.2.7
- support of CLOG
- cert-manager compatibility on BCMT 19.12
- cert-manager additional custom options
### Changed
- changed post-install job deletion requirements (CSFS-17927)
- removed LC_ALL & add LANG env to en_US.UTF-8
- change outdated tls certs for helm test
- correct tlsSecret in value.yaml
- kubectl image version v1.14.10-nano
- new rabbitmq-test image (with django 3.0.2 and python 3)
- upgrade rabbitmq to 3.8.2, erlang 22.2.7
- upgrade rsyslog to 8.37.0-13.el8
- docker image: rabbitmq_3.8.2-1.el8_erlang_22.2.7-1.el8 (-588)
- upgrade cbur-agent to 1.0.3-983

## [2.2.19] - 2019-12-19
### Changed
- use a unique naming for the K8S objects

## [2.2.18] - 2019-12-16
### Changed
- new docker images for RHSA-2019:4190 

## [2.2.17] - 2019-12-12
### Changed
- upgrade rabbitmq version to 3.7.23

## [2.2.16] - 2019-12-12
### Fixed
- crmq post install/upgrade/delete jobs use a label that matches the service selector

## [2.2.15] - 2019-11-5
### upgrade
- upgrade rabbitmq version to 3.7.21
- add ipv6 support

## [2.2.14] - 2019-10-10
### upgrade
- upgrade kubectl version to 1.14.7

## [2.2.13] - 2019-10-10
### fix
- update rabbitmq version to 3.7.18 for compaas

## [2.2.12] - 2019-9-24
### Update
- update rabbitmq version to 3.7.18

## [2.2.11] - 2019-9-18
### Added
- waiting for pod ready in post-install when dynamicConfig is true

## [2.2.10] - 2019-8-30
### Fixed
- remove 'chart: {{ template "rabbitmq.chart" .  }}' from volumeClaimTemplates section 

## [2.2.9] - 2019-8-30
### Fixed
- backup may fail while using side-car injection
- update backup/restore script, change image

## [2.2.8] - 2019-8-30
### Fixed
- crmq post-install pod uses labels that match the service selector

## [2.2.7] - 2019-8-17
### Fixed
- post-install can not be run when dynamicConfig is true

## [2.2.6] - 2019-8-16
### Added
- Update django version in test image

## [2.2.5] - 2019-7-4
### Fixed
- upgrade failed when persistence.data.enabled is false

## [2.2.4] - 2019-6-20
### Added
- Update images based on nano.

## [2.2.3] - 2019-6-10
### Added
- Add longname in post-install hook.

## [2.2.2] - 2019-5-30
### Added
- Update readinessProbe command.

## [2.2.1] - 2019-5-30
### Added
- Update readinessProbe command.

## [2.2.0] - 2019-5-29
### Added
- Update image without redhat packages.

## [2.1.6] - 2019-5-22
### Added
- Add cbur configuration option.
- Add clustering type configuration.
- Update readinessProbe command.
- Update post-upgrade mechanism.

## [2.1.5] - 2019-5-10
### Added
- Support password change during upgrade(not support rollback)

## [2.1.4] - 2019-5-7
### Added
- Update value for CPU limit

## [2.1.3] - 2019-4-28
### Added
- Update the minimum port in values-model.yaml

## [2.1.2] - 2019-4-28
### Added
- Update the cpu resource limit

## [2.1.1] - 2019-4-22
### Added
- Split istio resource

## [2.1.0] - 2019-4-15
### Added
- Support deploy on istio

## [2.0.6] - 2019-4-4
### Fixed
- Add pre-defined sidecar for backuprestore

## [2.0.5] - 2019-3-21
### Fixed
- Add default amqpPort

## [2.0.4] - 2019-3-19
### Fixed
- Add force upgrade flag

## [2.0.3] - 2019-3-08
### Fixed
- Change default image tag.

## [2.0.2] - 2019-2-25
### Fixed
- add cpu/memory limit for test pod which is required in ComPaas

## [2.0.0] - 2019-2-19
### Fixed
- Add svc annotation in values-model.yaml
- Add disable rbac option for tests files
- split secret

## [1.6.8] - 2019-2-13
### Fixed
- Remove the dnsConfig field in values.yaml.

## [1.6.7] - 2019-2-11
### Added
- Enhance security requirements for passwords
- Support fixed nodePort.

## [1.6.6] - 2019-1-31
### Fixed
- Split apiGroups in test_serviceaccount.yaml.

## [1.6.5] - 2019-1-29
### Added
- Update the appversion to rabbitmq 3.7.10.
- Support enable/disable of cbur.
- Add option to enable and disable management plugin.

## [1.6.4] - 2019-1-21
### Fixed
- Add helm test support 
- Fix post delete condition issue 

## [1.6.2] - 2018-12-18
### Fixed
- Change ClusterRole to Role
- Change ClusterRoleBinding to RoleBinding

## [1.6.1] - 2018-11-16
### Fixed
- Fix to set multi rabbitmqctl command after chart deployed.
- Update app version.

## [1.6.0] - 2018-11-1
### Added
- Add support for rabbitmq_delayed_message_exchange plugin

## [1.5.9] - 2018-10-31
### Added
- Enhance the chart to add mqtt retained parameter

## [1.5.8] - 2018.10.23
### Added
- Enhance the chart to support SSL and compass for mqtt plugin

## [1.5.7] - 2018.10.18
### Added
- Enhance the chart to download rabbitmq_delayed_message_exchange plugin.

## [1.5.6] - 2018.10.12
### Added
- Add annotation for prometheus

## [1.5.5] - 2018.10.11
### Added
- Support MQTT plugin

## [1.5.4] - 2018-09-30
### Fixed
- Add indent of rabbitmq.environment in values-template.yaml.j2.

## [1.5.3] - 2018-09-30
### Fixed
- Fix the default container is crmq when rsyslog enabled.

## [1.5.2] - 2018-09-29
### Fixed
- Fix plugin issue in values-model.yaml

## [1.5.1] - 2018-09-29
### Fixed
- Fix port issue in values-model.yaml

## [1.5.0] - 2018-09-29
### Added
- Support prometheus configuration.
- Support unified logging configuration via rsyslog.

## [1.4.9] - 2018-09-18
### Fixed
- Fixed secret delete logic in post-delete.yaml.

## [1.4.8] - 2018-09-17
### Fixed
- Add configuration error in configuration.yaml.

## [1.4.7] - 2018-09-17
### Fixed
- Add serviceaccount and secret resource in rule of role.yaml.

## [1.4.6] - 2018-09-11
### Added
- Enhance CRMQ chart to support TLS

## [1.4.5] - 2018-09-05
### Added
- Change restore mode from 2 to 0 and remove restore pre hook

## [1.4.4] - 2018-09-04
### Fixed
- incubating example only 
- password changs after upgrade fixed

## [1.4.3] - 2018-08-31
### Changed
- Upgrade the docker image info to latest.
### Added
- Support backup/restore on BCMT 18.06.
- Add option to define policies in values.yaml.
### Fixed
- Fix to support to set replicas in crmq on ComPaaS.

## [0.0.0] - YYYY-MM-DD
### Added | Changed | Deprecated | Removed | Fixed | Security
- your change summary, this is not a **git log**!


# Changelog
All notable changes to chart **ckey** are documented in this file,
which is effectively a **Release Note** and readable by customers.

Do take a minute to read how to format this file properly.
It is based on [Keep a Changelog](http://keepachangelog.com)
- Newer entries _above_ older entries.
- At minimum, every released (stable) version must have an entry.
- Pre-release or incubating versions may reuse `Unreleased` section.

## [12.2.0] - 2023-03-15
### Added
- support for CLOG v2 API
- backward compatibility support for "PERMISSIVE" mode mTLS in PeerAuthentication
- podAntiAffinty section under affinity
- new annotations for postIsuRollbackJob and postUpgradeIsuJob
- httpPort and httpsPort flexibility to allow metrics scraping to Prometheus and scheme annotation to set the communication protocol
- terminationGracePeriodSeconds to keep CKEY container alive after receiving SIGTERM request
- performance specific metrics in Quarkus level by default

### Changes
- podManagementPolicy was changed to Parallel
- reduced default CPU and memory values for CKEY
- isuUpgrade enabled flag made true by default
- Cleaning up /ckey/backup directory before taking mysql dump to avoid multiple copies of dumps associated with a backupid.
- Redirecting traffic only to temp ISU pods during ISU upgrade and rollback to avoid downtime.
- Fixed empty Role rules under stateful_rbac.yaml
- changed Brpolicy k8sobject to match with name
- vertx port binding is now limited to localhost
- Introduced delay in resource watcher job for istio-proxy container to be ready before calling Kubernetes API
- Deprecated ingress snippet annotation 'nginx.ingress.kubernetes.io/configuration-snippet' to align with ingress deprecation
- Changed ingress annotation session-cookie-name to AUTH_SESSION_ID as suggested by OS
- Deleting resource watcher pod as part of pre-upgrade job
- podNamePrefix and containerNamePrefix code fixes as per HBP
- Enhance headless-service to list podIP immediately after they are scheduled

## [12.1.0] - 2023-11-30
### Added
- Parameter internalCustomProviderRegistry to define repo for a custom provider docker
- Parameter secretCredentials.dbKeystoreSecret to support database mTLS encryption
- Parameters jgroupsTCPBindPort, jgroupsFDPort for additional Infinispan network configuration
- Parameter secretCredentials.rabbitMqPushEventListenerSecret to support RabbitMQ configuration as a secret
- Hardening alerts implemented
- Several bug fixes and improvements for ISU

### Changes
- Parameter disablePodNamePrefixRestrictions value set to false to control pod names with this having precedence over global level (HBP 3.7.0)
- Better support for TLS encryption between Infinispan caches
- Fixed a problem with container name in In-service upgrade/rollabck
- Default database connection idle time decreased to reduce downtime during database upgrade
- Fix to downtime during In-Service upgrade/rollback related to switching traffic to 'green' instance of CKEY
- Updated versions of depended containers: cbur, kubectl
- Make less strict rules for enabling Ingress with ISTIO

## [12.0.2] - 2023-10-31
### Changes
- Patch release to fix HTTP/2 Rapid Reset Vulnerability (CVE-2023-44487) and some vulnerabilities in baseOS
- FOSS Keycloak upgraded to version 22.0.5

## [12.0.1] - 2023-09-26
### Added
- Parameter global.disablePodNamePrefixRestrictions to control pod names
- Parameters global.enableDefaultCpuLimits, enableDefaultCpuLimits to control pod CPU limitation settings
- Parameter certManager.enabled to enable/disable CertManager on workload level
- Parameter serviceSessionAffinity to control load balancing on a service level
- Parameters isuUpgrade.cburBackup.enabled, isuUpgrade.dbSwitching.enabled to exclude some steps in In-Service upgrade
- Parameter tls.certManager.isTlsExternalCertViaCertManager to generate ingress tls certificate by CertManager
- Parameter ingress.ingressClassName for ingress class name setting
- A new secret for using spi in mtls mode
- New REST API and Alarms for LDAP health check
- Login banner shows values for failed login attempts
### Changes
- FOSS Keycloak upgraded to 22.0.3
- Updated versions of depended containers: cbur, kubectl
- Redesign parameters for repos and containers
- Adjust time values for startup, readinessProbe and liveness probs
- Optimization for supporting smaller CPU footprint
- Fix database backup/restore in ISU upgrade and rollback
- Fixed indefinite wait on ckey pods on brhook job

## [11.1.1] - 2023-07-14
### Added
- Fix liveness probe. Call proper health endpoint
- Final chart for 23.03 FP2 PP2

## [11.1.0] - 2023-06-23
### Added
- TCP stack configuration parameters: ipFamilies, ipFamilyPolicy
- Parameter httpPort to enable HTTP communication
- Secret secretCredentials.zeroTrustMetricSecret to support metric endpoint authentication
- Missing annotations
- New parameters for masterRealmConfigurationJob: jobActiveDeadline, jobBackOffLimit
- Parameters to manage Java memory allocation: memoryFactorForKeycloak, memoryFactorForUnifiedLogger
- Ability to restrict Ingress access to specified endpoints
### Changed
- FOSS Keycloak upgraded to 21.1.1
- Istio default deployment mode changed from PASSTHROUGH to SIMPLE
- Istio section refactored to support various tls modes
- Tls section refactored as required by Helm Best Practices
- Added containerSecurityContext to ISU jobs
- Resources ephemeral-storage parameters are enabled by default
- Removed value from resources.limits.cpu parameters
- Default value of podManagementPolicy changed to OrderedReady to address deployment racing condition
- Added parameter  certManager.enabled to global section
- Fix related to DNS naming convention for contrainerNamePrefix
- Fix for imagePullSecrets templating
- Fix for timeZone parameter name
- Fix for customProvider type. Changed from hotModule to extension-jar and adding support of type theme
### Removed
- Removed ingress support for k8s version <= 1.18

## [11.0.1] - 2023-04-21
### Changed
- Provision for separate keystore for syslog purpose
- Fix for custom providers image pull policy
- Exposing POD_Namespace field for hosts parameter in logs
- Fix for RabbitMQ and Kafka dependencies issue for csfpusheventlistner
- update for docker-py image in helm chart
- Addition of emptydir volume to CBUR container.

## [11.0.0] - 2023-03-24
### Changed
- Major CKEY release based on Keycloak 21.0.1 Quarkus distribution. See CKEY documentation for full list of changes and install/upgrade instructions see CKEY documentation

## [10.3.1] - 2023-01-19
### Changed
- Fix Umbrella chart openshift issue
- Added the keycloak container name when exec into CKEY pods
- Parameterized br policy parameter backendMode
- Fix timeout in helm heal
- Fix nested securityContext
### Added
- Added new containerSecurityContext

## [10.3.0] - 2022-12-16
### Changed
- Keycloak upgraded to 19.0.3
- Replace deprecated topologyKey in podAntiAffinity
- Set memory to Java harmonized_alarms.jar process
- Fixed Helm Test in case of Istio enabled
- adoption to HBP3.1 pod security. Refactor code to securityConext supplementalGroups.
- Infinispan upgraded to 12.1.12
- Updated and fixed invocations for including BusyBox container resources specification
- Updated cbur and cmdb versions and generate candidates chart for FP3 testing.
- Updated kubectlTag version to latest.
- Updated apiVersion for horizontalPodAutoScale
- Disable PodSecurityPolicy for kubeversion 1.25.
- Fixed max log size for periodic-size-logger

## [10.2.2] - 2022-09-23
- Add delete hooks to all jobs which missed it
- Remove the flag istio.enable to bind ipAddress for dual stack compatibility
- Update depended artifacts to latest

## [10.2.1] - 2022-07-29
### Changed
- Fix podNamePrefix change during upgrade
- Fixed enabling of audit logging on the chart installation
- Fix for password with special characters
- Fix for templating failure with customProviders
- Fix automountServiceAccountToken on master realm job when Istio is enabled
- Reverted the cbur container name to cbura-sidecar

## [10.2.0] - 2022-06-24
### Changed
- FOSS Keycloak upgraded to version 18.0.0
- Added pod name prefix for test pod
- All artifactory repos replaced by new one repo.cci.nokia.net
- Names template prefixed with ckey
- Disable automountServiceAccountToken for several pods
- Removed unused secret cleanup rbac
- Update kubectl/cbur/cmdb dependencies to latest
### Added
- Added support for JDBC min and max connection pool configuration
- Added custom annotations and labels for pods
- Add appProtocol property to services

## [10.1.0] - 2022-04-14
### Changed
- Fixed ckey jobs security context from cbur to ckey
- Upgraded dependent CMDB, CBUR, kubectl to latest
- Fix the resource watcher Config map and Secret names
### Added
- Added container prefix for test container
- Added Horizontal Pod Autoscaler (HPA) support
- Added CBUR policy APIVersion parameter to values file.

## [10.0.0] - 2022-02-25
### Changed
- Fixed missing toleration in several jobs
- Fixed bug in logging for resource watcher job
- Updated the kubectl image to latest
- Removed Helm2 support
- Infinispan geo redundancy chart upgraded to 12.1.11.Final  for fixing log4j vulnerabilities
- PDB name changes and support for various api versions
- To make it compatible with HelmBP 2.0.0
- Upgrade to Keycloak 16.1.1
- Fix for Anti-affinity for CKEY pods
- Separate database secret from main keycloak secret
- Deprecate database root user for isu upgrade
### Added
- Support for Topology based spread constraints
- Support for certManager and secure curl requests
- Add parameter to configure number of temporary pods for ISU upgrade


## [9.10.0] - 2021-11-30
### Changed
- Added permissions for db user keycloak for tmpdb4keycloak database for in-service upgrade. Only when CMDB is a depended chart
- Fix secret decryption in in-service upgrade
- Improving in-service upgrade logging
- Updated brpolicy to csf.nokia.com
### Added
- Add ephemeral-storage setting for main and cbur containers

## [9.9.0] - 2021-10-28
### Changed
- Make work Istio up to version 1.10
- Upgrade cbur to latest version
- Changing rbacEnable parameter to rbac.enabled
- Depended CMDB chart upgraded to latest
- Fix for UMLite PODs fail to start when externalTlsCertificate is enabled for umLite

## [9.8.1] - 2021-09-17
### Changed
- Add supplementalGroups to fix issue generating random uid in OpenShift env
- Add home dir location to gpg command under K8s-restricted-config script
- Fix several UMLite container vulnerabilities

## [9.8.0] - 2021-08-19
### Changed
- Address Keycloak 14 restrictions to to load properties in custom provider
- Updated infi-cache-job name by appending revision
- Fixing UMLITE upgrade issue
- Infinispan Operator image removed
- Fixed template format to resolve exporter parsing issue
- Set allowPrivilegeEscalation to false for master realm configuration job
- UMLITE removed admin username and password from environment variables

### Added
- Implemented PodDisruptionBudget
- Added code to watch kubernetes resources like configmaps and secrets and restart ckey podd upon changes in them.

## [9.7.0] - 2021-07-22
### Changed
- FOSS Keycloak upgraded to version 14.0.0
- New UMLite docker image
- Updated version of depended docker images: cbur, kubectl
- Removed chart labels from infi-statefulset to resolve upgrade issue for ckey in geo redundancy mode
- Changed permission of deletion rbac to allow deletion of secrets and pvc
### Added
- Added service account list and delete permission to deletion service account for ckey in geo redundancy mode
- Added configuration for nodeAffinity in brhook-postrestore.yaml

## [9.6.0] - 2021-06-10
### Added
- External Infinispan for achieving Geo-Redundancy
- Extension to clear admin events entity table periodically
- Ability to set database password as base64 encoded
### Changed
- Fix Stateful Service Account auto mount for Istio
- Group admin should be able to access usermanagement lite application with confidential client
- Fix realm config job on delete and reinstall
- Fix password encoding in populate secret job

## [9.5.0] - 2021-05-04
### Changed
- Do not run master configuration job second time
- Add missing RBAC Istio roles for all service accounts
- Check for master realm configuration job enabled in secret-cleanup-job
- Remove duplicated Istio PSP
- Refactor ISU code
- If users are using external secret, prevent secret populate job from coming up
- Upgrade version of k8s network api in ingresses
- Turn off NodeAffinity configuration by default
- Enhance release name templating in _helper.tpl
- Remove fsGroup from CBUR security context
- Add quote to custom annotations and labels
- Allow autoset UID for containers
### Added
- Add node affinity / anti-affinity to jobs
- Add "useGlobalRegistry" to customProvider parameters

## [9.4.0] - 2021-03-24
### Changed
- Fixing UMLite upgrade problem. Allow secret to retain admin password after upgrade or rollback.
- Enable TLS 1.3
- Allow Istio VirtualService prefix path to be configurable
- Add index suffix to custom provider container name to prevent duplicated name cases
- Single service account with broad permissions split to several smaller service accounts
- Cleanup secret-cleanup-job pod after it is finished
- Enhance secret clean up job to wait for master realm configuration job completion upon Helm install
- Added registry4 for be able change repositories only for ckey docker image
- Add custom labels and annotations support to CKEY statefulset and UMLite deployment
### Added
- k8s common labels
- UMLite UI confidential client support and fixing some vulnerabilities
- Allow Helm ISU to upgrade CKEY from versions prior to 20.10FP4
- Add initial startup delay for database alarm

## [9.3.0] - 2021-02-19
### Added
- Helm In Service Upgrade (ISU) support
- nodeSelector parameter to assign pods to selected nodes
### Changed
- Change default path from /auth to /access
- Enhance selectors in our http-service in CKEY chart
- Keycloak upgraded to version 12.0.3

## [9.2.0] - 2021-01-14
### Added
- Added Harmonized Logging
### Changed
- Fix error in custom provider loading from docker image
- Remove k8s-restricted-config ConfigMap upon Helm delete
- Add FD_SOCK exclusion port to statefulset when Istio is enabled
- Keycloak upgraded to version 12.0.1

## [9.1.0] - 2020-12-17
### Added
- Added IPv6 support in Livenessprobe script
- Added failureThreshold in LivenessProbe
### Changed
- Add trimSuffix "-" to _helper.tpl on line where trunc 63 is present
- Add pre-rollback hook to k8s-restricted-config ConfigMap
- Add priorityClassName config to statefulset and UMLite deployment
- Allow dynamic template for Ingress TLS configuration
- Fix wildcard IP address in IPv6 for Istio enabled environment
- Allow CBUR to backup CKEY encrypted secret volume
- Change directory of secret key for sensitive information

## [9.0.56] - 2020-11-12
### Changed
- Fix helm test for running with Istio
- Exclude secret from BrPolicy if preserveSecret parameter set to false
- Upgrade CMDB to 7.13.5 to fix CMDB not coming up with istio.enabled in an istio injected namespace
- Allow custom Ingress annotations to override Istio annotations
- Improve Istio support in Umlite GUI
- Fix liveness probe log parsing script
- Fix quotes for brBolicy cronSpec parameter
- Keycloak upgraded to version 11.0.3
### Added
- Added Custom customJavaOpts parameter to append java command line parameters to default one
- Added ConfigMap to manage push listener configuration without helm
- Umlite istio enablement

## [9.0.30] - 2020-10-15
### Added
- Add resource limits to brhook-postrestore and post-upgrade-job
- Added liveness probe script for restarting container based on log parsing
- Timezone settings to match with Helm best practices guideline
- Add prefix support for pod and container names
- Added helm test
### Changed
- Change Istio template to match with Helm best practices guideline
- Fix for UMLite pod uses busybox image without tag
- Change brPolicy property names brMaxicopy, brCronSpec to maxiCopy, cronSpec to make them consistent with other CSF components
- TLS improvements for Lite User interface

## [9.0.6] - 2020-09-18
### Changed
- Added encryption mechanism for sensitive secret information
- Allow any-address binding for dualstack environment
- Add contextPath to ingress configuration in case Ingress path contains Regex or special characters
- Remove default passwords from values-model.yaml for password fields
- Remove csf-paas label from CKEY ingress
- CMDB upgraded to version 7.11.2
- Keycloak upgraded to version 11.0.2
### Added
- Post upgrade job to run master realm security hardening measures on upgrade
- Added new CBUR parameters autoEnableCron, autoUpdateCron
- Add resource quota for all jobs

## [8.11.0] - 2020-08-14
### Added
- Added support for custom ingress web-context paths.
- Added brPolicy config parameter ignoreFileChanged, cronSpec and brMaxiCopy
- Add PeerAuthentication/Policy mTLS mode configuration for Istio configuration
### Changed
- FOSS Keycloak upgraded to version 11.0.0
- Upgrade version of UMLite GUI
- Configurable certificate expiry alarm period
- Improved start time of post-install master realm configuration job
- Fix clustering issue in Istio enabled environment with REGISTRY_ONLY outboundTrafficPolicy
- Fix Helm restore hanging on PostRestore hook
- Force CKEY secret to be redeployed when Helm upgrade is triggered

## [8.10.28] - 2020-07-16
### Changed
- Feature to support SMP usecase for SaaS (DS RBAC - Customer contribution)
- Fix KEYCLOAK_IP not matching exactly with Keycloak service IP in configure-realm.sh
- Allow CKEY Helm Chart to customize DNS domain
- Upgrade CMDB dependency version to 7.10.3 to fix Helm upgrade/scale issue in Istio enabled environment
- Secure ingress sticky session cookie 'route'
- Remove fsGroup from securityContext
- Remove sensitive environment variables and mount them all into secret
- kubectl container used in jobs upgraded to v1.17.6-nano
- Add addtional RBAC rule to allow security hardening init container run as root
- Change certificates mounting procedure for security hardening
- Fix external database address with extra port in Helm chart
### Added
- Allow Istio to bind to existing Gateway/Hosts and configure TLS mode

## [8.10.12] - 2020-06-18
### Added
- Added support for external RBAC account
- Let users specify any number of labels for istio ingress gateway configuration.
### Changed
- Use a single service account for all the jobs
- Upgrade version of umlite image to address security vulnerabilities in serialize-javascript package
- nodeAffinity rule with BCMT label is_worker is disabled by default
- Remove metrics-exporter-registry.json config to allow Metrics Event Listener to listen to all event actions when enabled
- Eleminate init containers to allow ckey deploy when istio cni is enabled.
- Change cmdb chart version to 7.9.7 which contains a fix related to helm upgrade and helm backup/restore.

## [8.10.1] - 2020-05-14
### Added
- CBUR post-restore job to restart CKEY pods automatically
- Automatically backup restore CKEY secret by CBUR
- Supports istio - psp, sidecard injection, a sample istio ingress gateway configuration, destination rules
- Support for loading custom extensions: custom providers, themes
### Changed
- FOSS Keycloak upgraded to version 10.0.1
- Update Lite User Interface version

## [8.9.4] - 2020-04-16
### Changed
- RBAC fixes: Scope Mapping disassociation and not listing account-console client
- Version of depended CMDB changed to 7.7.0
### Added
- Basic Istio support

## [8.9.0] - 2020-03-15
### Changed
- FOSS Keycloak upgraded to version 9.0.0
- Changed port names to match Istio formatting
- Replaced 'Keycloak' trademark in Admin GUI
- Custom configuration script moved from config map to values.yaml. Removed parameter overrideEntryPoint from values.yaml.
- Updated old kubernetes API versions
- Version on depended CMDB changed to 7.6.0
### Added
- Tolerations configuration

## [8.8.11] - 2020-02-25
### Changed
- Fix master realm config job for ipv6

## [8.8.10] - 2020-02-20
### Added
- Added Prometheus annotations
- Added configuration for Health Check port
- Master realm configuration job fix for custom TLS certificate
- Added configuration for Generic Event Listener registry
- RBAC - Client role creation for authentication disabled client
### Removed
- Removed notification-interface sample file

## [8.8.0] - 2020-01-17
### Added
- FOSS Keycloak upgraded to version 8.0.1

## [8.7.6] - 2019-12-12
### Added
- Changed master realm job to https compatibility
- Fixed master realm job err handling
- Make chart compatible with IPv6 BCMT. Added new parameter ipType.
- CMDB dependency updated to latest version
- Default initial delay for liveness probe increased to 600 sec, for readiness probe descreased to 180 sec

## [8.7.0] - 2019-11-14
### Added
- New value added to values.yaml to set cors header
- New value added to values.yaml file to make binding ip configurable
- Fixed syntax error in rbac.yaml,post-heal and pre-heal to make heal working
- Fix helm upgrade by removing service accounts from hooks
- Allow special character in admin password
- Changing RBAC Light UI version

## [8.6.0] - 2019-10-17
### Changed
- Changed master realm job running condition to only INSTALL and added pre upgrade hook
- In keycloak chart missing configmap metrics-exporter-registry.yaml
- Handling empty scope mapping and adding resource for UMLite
- Added fullnameOverride and nameOverride parameter for fixed service name since it required for profile deployment in swordfish envrionment
- RBAC adding custom claims to access, userinfo, openid token
- Delete all pvc by default on helm delete

## [8.5.7] - 2019-09-26
### Changed
- CSFS-15099, CSFID-2449: Added Custom Role Based Access Control and User Light GUI
- CSFSEC-2990: Updated Ingress annotations

## [8.5.5] - 2019-09-13
### Changed
- Added error handling for master realm config job

## [8.5.2] - 2019-08-16
### Changed
- The messages in the CKEY login banner (if enabled) are now customizable. For more information on how to enable the CKEY login banner, please consult our user guide. The customizable messages will be applied to the login banner in the new 6.0.1-1 CKEY docker image.
- Error handling for helm master realm config

## [8.5.0] - 2019-07-18
### Changed
- Upgraded the CKEY version to 6.0.1-0
- Added a new log configuration for a periodic size logger.

## [8.4.1] - 2019-07-05
### Changed
- Upgraded the kubectl image to v1.14.3-nano
- Upgraded the cbur/cbura image to version 1.0.3-983

## [8.4.0] - 2019-07-04
### Changed
- Upgraded the CMDB helm chart dependency to version 7.0.3
- Removed fsgroup entry from the CBUR container inside the statefulset resource.

## [8.3.3] - 2019-06-24
### Changed
- Upgraded the CKEY version to 6.0.0-1

## [8.3.2] - 2019-06-06
### Changed
- Modified pre-delete script to fix syntax error.

## [8.3.1] - 2019-05-24
### Changed
### Added
- Upgraded the CKEY version to 6.0.0-0
- Changed the default allowed TLS Cipher Suite to TLSv1.2 If you want to enable other cipher suites, please configure the tlsVersionList environment variable as per your requirements.

## [8.3.0] - 2019-05-01
### Changed
### Added
- Added custom attributes configuration through values.yaml

## [8.2.0] - 2019-04-12
### Added
- Added push event notification configuration through values.yaml.
### Changed
- Upgraded the CKEY version to 5.0.0-0
- Changed name of realm-configuration-job to master-realm-configuration-job.
- Added the notUsername password policy to the existing list of password policies that are set in the realm configuration job.

## [8.1.7] - 2019-03-25
### Added
- Added configurable timeout and period seconds for the liveness and readiness probes. The default timeout for the liveness probe is not set to 5 seconds.

## [8.1.6] - 2019-03-15
### Changed
- Upgraded the CKEY version to 4.8.3-1.

## [8.1.5] - 2019-03-15
### Fixed
- Re-introduced SHARED label for compatiblity of ComPaaS 19.01 versions

## [8.1.4] - 2019-03-07
### Fixed
- Removed dash from  host in ingress files

## [8.1.3] - 2019-03-01
### Fixed
- SVC_SCOPE has been fixed

## [8.1.2] - 2019-02-26
### Added
- Added a new ingress-management.yaml file for JBoss management console. This will allow HTTPS connections to keycloak service on port 8443 and HTTP connections to JBoss mananement console on port 9990.
- Added dbAddress variable to values.yaml which needs to be set while deploying with external CMDB. This has replaced the old dbIP variable.
- Added dbPort variable to values.yaml which needs to be set while deploying with external CMDB.
### Removed
- Removed SHARED label from ckey chart.
- Removed dbFQDN variable from ckey chart.

## [8.1.0] - 2019-02-14
### Added
- Added an initContainer to wait for external CMDB to become ready before ckey deployment gets started.
- Added dbFQDN variable to values.yml file which need to be set while deploying with external CMDB.
- Added Node Affinity ruled for ckey so that pods are deployed only on the worker node.
### Changed
- Upgraded the CKEY version to 4.8.3-0.
- Upgraded the Kubectl version to v1.12.3.
- Upgraded the CMDB version to 6.4.3.
- Replaced ClusterRole and ClusterRoleBinding with Role and RoleBinding where applicable.
- Attributes that are related to the backup persistance in CMDB are now configurable on ComPaaS.
- Added an additional check to the backup volume mount in the statefulset.yaml file.
- The CMDB dependency no longer requires CSDC (for simplex deployments).
- Replaced the 'default' storage class with the empty String where applicable.
- This new version introduces changes to the CKEY statefulset and as a result, the 'helm upgrade' command will not be compatible if upgrading from an older version.
### Fixed
- Fixed an issue in the ingress specification that was causing the template not to render properly when a range of ingress hosts is specified.

## [7.0.2] - 2019-01-30
### Added
- Added a new if-end check to volumeClaimTemplates in statefulset.yaml so that it will not create volume claim if cbur is disabled.

## [7.0.1] - 2019-01-22
### Added
- Added a new variable that allows users to enable ingress for jboss management console on port 9990. This will allow JConsole to remotely connect to keycloak for remote monitoritng.

## [7.0.0] - 2018-12-17
### Added
- A new realm configuration job has been added. The job creates a kubectl client, waits for CKEY to be ready, and configures certain security settings in the CKEY master realm if the job is enabled. The script that runs in the new realm configuration job is available in the new custom realm configuration configmap.
- Added the ability to configure additional custom arguments that get passed on to the CKEY statefulset.
- Added service accounts that are specific to the pre-delete job and to the new realm configuration job.
- Added new variables that allow the user to mount a custom Java keystore and a custom Java client truststore. Users can now provide the passwords for the keystores that they want to import.
- Added new volume mount for custom CKEY scripts.
### Changed
- Made small adjustments to the waiting times in the CKEY init containers.
- Modified default admin password from 'admin' to 'Admin123!' to comply with the new password policies.
- Upgraded the CKEY docker image to 4.5.0-3

## [6.1.0] - 2018-11-23
### Added
- Added support for backup and restore for CKEY.
### Changed
- Upgraded CKEY docker image to 4.5.0-2.

## [6.0.5] - 2018-11-16
### Changed
- The Keycloak default user credentials are now stored in a secret that has a pre-install hook annotation.
- Added a Keycloak pre-delete job to delete the secret that contains default user credentials.

## [6.0.4] - 2018-11-15
### Changed
- Added new boolean flag to determine whether the initial user should be created or not.

## [6.0.3] - 2018-10-25
### Changed
- Update CKEY docker image to 4.5.0-1.

## [6.0.2] - 2018-10-15
### Changed
- Heal events implemented for ckey

## [6.0.1] - 2018-10-11
### Changed
- CKEY now uses CMDB 6.0.3.
- The 'requires' field (for SSL and X509) is now configurable for DB users.

## [6.0.0] - 2018-10-05
### Changed
- The CKEY docker image now uses keycloak 4.4.0 and supports MariaDB versions that are larger 10.3.
- Updated the CMDB chart in requirements.yaml to 6.0.0.
### Added
- Users can now add SSL certificates for CMDB into CKEY.

## [5.0.4] - 2018-09-27
### Changed
- Made the initial delays for the readiness and liveness probes configurable.

## [5.0.3] - 2018-09-25
### Added
- Users can now add a trusted LDAPS certificate into CKEY.

## [5.0.2] - 2018-09-18
### Fixed
- Fixed the CKEY image reference in the values-template.j2.yaml file.

## [5.0.1] - 2018-08-31
### Changed
- Minor fix the the CHANGELOG.

## [5.0.0] - 2018-08-31
### Changed
- CKEY now uses a "Statefulset", as opposed to a "Deployment".
- Added an additional headless service for the CKEY statefulset.
- Added an initContainer to have CKEY wait for the CMDB container to be ready, the initContainer takes place if cmdb.enabled is set to true.
- CKEY now uses the new docker image from the 18.8 release. The current version is based on Keycloak 4.2.1.
### Security
- Added securityContext configurations to the helm chart. The helm chart can now be deployed as non-root user.
- The utilized CKEY docker image now runs as a "keycloak" user, with user ID 1000.

## [4.0.3] - 2018-08-28
### Changed
- Made the servicePort configurable in the ingress.yaml file. Users can now choose which Keycloak service port they would like to configure with ingress.

## [4.0.2] - 2018-08-16
### Fixed
- Made a small change to the ingress.yaml file. The ingress configuration now points to httpProxy.

## [4.0.1] - 2018-08-07
### Added
- All future chart versions shall provide a change log summary

## [0.0.0] - YYYY-MM-DD
### Added | Changed | Deprecated | Removed | Fixed | Security
- your change summary, this is not a **git log**!

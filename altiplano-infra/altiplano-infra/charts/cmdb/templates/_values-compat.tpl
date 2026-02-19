{{- define "cmdb.values-compat" -}}
{{/*
This file contains some default values structure to help in upgrade scenarios.

When --reuse-values is used on upgrade, any newly added values in the packaged values.yaml
file are not included, which can cause logic errors in the rendering of the new version of the chart.
This file provides a place for altering of the .Values dictionary to help in these cases.  Typically
this will be used to merge sub-dictionaries onto the .Values to inject default values where non exist.

*/}}
{{- if not (hasKey .Values.cbur "enabled") -}}
  {{- $_ := merge .Values (dict "cbur" (dict "enabled" true)) -}}
{{- end -}}

{{/* Set a default .Values.hooks for upgrade from before it existed, v6.5.0 */}}
{{- $_ := merge .Values (dict "hooks" (dict "deletePolicy" "hook-succeeded,before-hook-creation")) -}}

{{/* Set default values for .Values.services.maxscale for upgrade from before it existed, v6.6.0 */}}
{{- $_ := merge .Values (dict "services" (dict "maxscale" (dict "port" "8989"))) -}}

{{/* Set default values for .Values.services.admin for upgrade from before it existed, v7.0.0 */}}
{{- $_ := merge .Values (dict "services" (dict "admin" (dict "type" "ClusterIP"))) -}}
{{- if not (hasKey .Values.admin "persistence") -}}
  {{- $_ := merge .Values (dict "admin" (dict "persistence" (dict "enabled" true "accessMode" "ReadWriteOnce" "size" .Values.mariadb.persistence.size))) -}}
{{- end -}}
{{- $_ := merge .Values (dict "admin" (dict "postInstallTimeout" "900" "preUpgradeTimeout" "180" "postUpgradeTimeout" "1800" "preDeleteTimeout" "120" "postDeleteTimeout" "180")) -}}
{{/* Added nodeAffinity enable flags */}}
{{- if not (hasKey .Values.admin "nodeAffinity") -}}
  {{- $_ := merge .Values (dict "admin" (dict "nodeAffinity" (dict "enabled" false "key" "is_worker" "value" true))) -}}
{{- end -}}
{{- if not (hasKey .Values.mariadb.nodeAffinity "enabled") -}}
  {{- $_ := merge .Values (dict "mariadb" (dict "nodeAffinity" (dict "enabled" false))) -}}
{{- end -}}
{{- if not (hasKey .Values.maxscale.nodeAffinity "enabled") -}}
  {{- $_ := merge .Values (dict "maxscale" (dict "nodeAffinity" (dict "enabled" true))) -}}
{{- end -}}
{{/* Added maxscale-exporter metrics */}}
{{- $_ := merge .Values (dict "maxscale" (dict "metrics" (dict "enabled" false))) -}}
{{/* Add CBUR configurable parameters */}}
{{- $_ := merge .Values (dict "cbur" (dict "cronSpec" "0 0 * * *" "maxiCopy" 5 "backendMode" "local")) -}}

{{/* Set default values for .Values.mariadb.clean_log_interval for upgrade from before it existed, v7.1.0 */}}
{{- $_ := merge .Values (dict "mariadb" (dict "clean_log_interval" 3600)) -}}

{{/* Set default values for new values, v7.2.0 */}}
{{- $_ := merge .Values (dict "mariadb" (dict "repl_use_ssl" false)) -}}

{{/* Set default values for new values, v7.3.0 */}}
{{- $_ := merge .Values (dict "global" (dict "registry2" "csf-docker-delivered.repo.cci.nokia.net")) -}}
{{- if not (hasKey .Values.cbur "dataEncryption") -}}
  {{- $_ := merge .Values (dict "cbur" (dict "dataEncryption" true)) -}}
{{- end -}}

{{/* Set default values for new values, v7.5.0 */}}
{{- $_ := merge .Values (dict "cbur" (dict "autoEnableCron" false)) -}}

{{/* Set default values for new values, v7.6.0 */}}
{{- $_ := merge .Values (dict "admin" (dict "configAnnotation" false)) -}}
{{- if not (hasKey .Values "quorum_node_wait") -}}
  {{- $_ := merge .Values (dict "quorum_node_wait" 120) -}}
{{- end -}}
{{- if not (hasKey .Values.admin "autoHeal") -}}
  {{- $_ := merge .Values (dict "admin" (dict "autoHeal" (dict "enabled" true "pauseDelay" 900))) -}}
{{- end -}}

{{/* Set default values for new values, v7.9.0 */}}
{{- $_ := merge .Values (dict "istio" (dict "enabled" false)) -}}
{{- $_ := merge .Values (dict "mariadb" (dict "encryption" (dict "enabled" false))) -}}
{{- if not (hasKey .Values.certManager "apiVersion") -}}
  {{- $_ := merge .Values (dict "certManager" (dict "apiVersion" "cert-manager.io/v1")) -}}
{{- end -}}
{{- $_ := merge .Values (dict "cbur" (dict "ignoreFileChanged" false)) -}}

{{/* Set default values for new values, v7.10.0 */}}
{{- if not (hasKey .Values.cbur "brhookType") -}}
  {{- $_ := merge .Values (dict "cbur" (dict "brhookType" "brpolicy")) -}}
{{- end -}}
{{- if not (hasKey .Values.cbur "brhookWeight") -}}
  {{- $_ := merge .Values (dict "cbur" (dict "brhookWeight" 0)) -}}
{{- end -}}
{{- if not (hasKey .Values.cbur "brhookEnable") -}}
  {{- $_ := merge .Values (dict "cbur" (dict "brhookEnable" true)) -}}
{{- end -}}
{{- if not (hasKey .Values.cbur "brhookTimeout") -}}
  {{- $_ := merge .Values (dict "cbur" (dict "brhookTimeout" 600)) -}}
{{- end -}}
{{- $_ := merge .Values (dict "services" (dict "mysql" (dict "sessionAffinity" (dict "enabled" false)))) -}}

{{/* Set default values for new values, v7.11.0 */}}
{{- if not (hasKey .Values.admin "rebuildSlave") -}}
  {{- $_ := merge .Values (dict "admin" (dict "rebuildSlave" (dict "enabled" true "preferredDonor" "slave" "allowMasterDonor" true "timeout" 300 "parallel" 2 "useMemory" "256M"))) -}}
{{- end -}}
{{- if not (hasKey .Values "clusterDomain") -}}
  {{- $_ := merge .Values (dict "clusterDomain" "cluster.local") -}}
{{- end -}}

{{/* Set default values for new values, v7.12.0 */}}
{{- if not (hasKey .Values.hooks "preInstallJob") -}}
  {{- $_ := merge .Values (dict "hooks" (dict "preInstallJob" (dict "enabled" true "timeout" 120))) -}}
{{- end -}}
{{- if not (hasKey .Values.hooks "postInstallJob") -}}
  {{- $_ := merge .Values (dict "hooks" (dict "postInstallJob" (dict "enabled" true "timeout" 900))) -}}
{{- end -}}
{{- if not (hasKey .Values.hooks "preUpgradeJob") -}}
  {{- $_ := merge .Values (dict "hooks" (dict "preUpgradeJob" (dict "enabled" true "timeout" 180))) -}}
{{- end -}}
{{- if not (hasKey .Values.hooks "postUpgradeJob") -}}
  {{- $_ := merge .Values (dict "hooks" (dict "postUpgradeJob" (dict "enabled" true "timeout" 1800))) -}}
{{- end -}}
{{- if not (hasKey .Values.hooks "preRollbackJob") -}}
  {{- $_ := merge .Values (dict "hooks" (dict "preRollbackJob" (dict "enabled" true "timeout" 300))) -}}
{{- end -}}
{{- if not (hasKey .Values.hooks "postRollbackJob") -}}
  {{- $_ := merge .Values (dict "hooks" (dict "postRollbackJob" (dict "enabled" true "timeout" 1800))) -}}
{{- end -}}
{{- if not (hasKey .Values.hooks "preDeleteJob") -}}
  {{- $_ := merge .Values (dict "hooks" (dict "preDeleteJob" (dict "enabled" true "timeout" 120))) -}}
{{- end -}}
{{- if not (hasKey .Values.hooks "postDeleteJob") -}}
  {{- $_ := merge .Values (dict "hooks" (dict "postDeleteJob" (dict "enabled" true "timeout" 180))) -}}
{{- end -}}
{{- if not (hasKey .Values.maxscale "keystorePullTimeout") -}}
  {{- $_ := merge .Values (dict "maxscale" (dict "keystorePullTimeout" 300)) -}}
{{- end -}}
{{- $_ := merge .Values (dict "cbur" (dict "autoUpdateCron" false)) -}}

{{/* Set default values for new values, v7.12.1 */}}
{{- if not (hasKey .Values.hooks "postHealJob") -}}
  {{- $_ := merge .Values (dict "hooks" (dict "postHealJob" (dict "name" "postheal" "containerName" "postheal-admin" "timeout" 1800))) -}}
{{- end -}}
{{- if not (hasKey .Values.hooks "preRestoreJob") -}}
  {{- $_ := merge .Values (dict "hooks" (dict "preRestoreJob" (dict "name" "prerestore" "containerName" "prerestore-admin" "timeout" 180))) -}}
{{- end -}}
{{- if not (hasKey .Values.hooks "postRestoreJob") -}}
  {{- $_ := merge .Values (dict "hooks" (dict "postRestoreJob" (dict "name" "postrestore" "containerName" "postrestore-admin" "timeout" 1800))) -}}
{{- end -}}

{{/* Set default values for new values, v7.13.0 */}}
{{- if not (hasKey .Values.mariadb.persistence "backup") -}}
  {{- $_ := merge .Values (dict "mariadb" (dict "persistence" (dict "backup" (dict "enabled" false)))) -}}
{{- end -}}
{{- if not (hasKey .Values.mariadb.persistence "temp") -}}
  {{- $_ := merge .Values (dict "mariadb" (dict "persistence" (dict "temp" (dict "enabled" false)))) -}}
{{- end -}}
{{- if not (hasKey .Values.mariadb.persistence "shared") -}}
  {{- $_ := merge .Values (dict "mariadb" (dict "persistence" (dict "shared" (dict "enabled" false)))) -}}
{{- end -}}
{{- if not (hasKey .Values.cbur "preBackupHook") -}}
  {{- $_ := merge .Values (dict "cbur" (dict "preBackupHook" (dict "timeout" 180))) -}}
{{- end -}}
{{- if not (hasKey .Values.cbur "postBackupHook") -}}
  {{- $_ := merge .Values (dict "cbur" (dict "postBackupHook" (dict "timeout" 120))) -}}
{{- end -}}
{{- if not (hasKey .Values.cbur "preRestoreHook") -}}
  {{- $_ := merge .Values (dict "cbur" (dict "preRestoreHook" (dict "timeout" 240))) -}}
{{- end -}}
{{- if not (hasKey .Values.cbur "postRestoreHook") -}}
  {{- $_ := merge .Values (dict "cbur" (dict "postRestoreHook" (dict "timeout" 900))) -}}
{{- end -}}

{{/* Set default values for new values, v7.13.4 */}}
{{- $_ := merge .Values (dict "services" (dict "mariadb" (dict "exporter" (dict "port" "9104")))) -}}
{{- $_ := merge .Values (dict "services" (dict "maxscale" (dict "exporter" (dict "port" "9195")))) -}}
{{- $_ := merge .Values (dict "services" (dict "endpoints" (dict "master" (dict "name" "")))) -}}
{{- $_ := merge .Values (dict "services" (dict "endpoints" (dict "maxscale" (dict "name" "")))) -}}

{{/* Set default values for new values, v7.13.7 */}}
{{- $_ := merge .Values (dict "services" (dict "mariadb_master" (dict "port" "3306"))) -}}

{{/* Set default values for new values, v7.13.14 */}}
{{- if not (hasKey .Values.cbur "persistence") -}}
  {{- $_ := merge .Values (dict "cbur" (dict "persistence" (dict "cburtmp" (dict "enabled" false)))) -}}
{{- end -}}

{{/* Set default values for new values, v7.14.0 */}}
{{- if not (hasKey .Values.istio "cni") -}}
  {{- $_ := merge .Values (dict "istio" (dict "cni" (dict "enabled" false))) -}}
{{- end -}}
{{- $_ := merge .Values (dict "custom" (dict "pod" (dict "annotations" (dict)))) -}}
{{- $_ := merge .Values (dict "custom" (dict "psp" (dict "annotations" (dict)))) -}}

{{/* Set default values for new values, v7.15.0 */}}
{{- if and (.Values.geo_redundancy.enabled) (not (hasKey .Values.geo_redundancy "remoteSites")) (hasKey .Values.geo_redundancy "remote" ) -}}
  {{- $_ := merge .Values (dict "geo_redundancy" (dict "remoteSites" (list (dict "name" (default "remote" .Values.geo_redundancy.remote.name) "maxscale" (dict "remoteService" .Values.geo_redundancy.remote.maxscale "serviceName" (default "" .Values.services.endpoints.maxscale.name)) "master" (dict "remoteService" .Values.geo_redundancy.remote.master "serviceName" (default "" .Values.services.endpoints.master.name) "serviceIP" (default "" .Values.geo_redundancy.remote.master_remote_service_ip)))))) -}}
{{- end -}}
{{- $_ := merge .Values (dict "geo_redundancy" (dict "autoSiteReconnect" false)) -}}
{{- if not (hasKey .Values.maxscale "semiSyncReplication") -}}
  {{- $_ := merge .Values (dict "maxscale" (dict "semiSyncReplication" true)) -}}
{{- end -}}

{{/* Set default values for new values, v7.16.0 */}}
{{- if not (hasKey .Values.mariadb "podSecurityContext") -}}
  {{- $_ := merge .Values (dict "mariadb" (dict "podSecurityContext" (dict "runAsUser" 1771 "runAsGroup" 1771 "fsGroup" 1771))) -}}
{{- end -}}
{{- if not (hasKey .Values.mariadb "containerSecurityContext") -}}
  {{- $_ := merge .Values (dict "mariadb" (dict "containerSecurityContext" (dict "runAsUser" 1771 "runAsGroup" 1771))) -}}
{{- end -}}
{{- if not (hasKey .Values.mariadb.metrics "containerSecurityContext") -}}
  {{- $_ := merge .Values (dict "mariadb" (dict "metrics" (dict "containerSecurityContext" (dict "runAsUser" 1771 "runAsGroup" 1771)))) -}}
{{- end -}}
{{- if not (hasKey .Values.cbur "containerSecurityContext") -}}
  {{- $_ := merge .Values (dict "cbur" (dict "containerSecurityContext" (dict "runAsUser" 1771 "runAsGroup" 1771))) -}}
{{- end -}}
{{- if not (hasKey .Values.maxscale "podSecurityContext") -}}
  {{- $_ := merge .Values (dict "maxscale" (dict "podSecurityContext" (dict "runAsUser" 1772 "runAsGroup" 1772))) -}}
{{- end -}}
{{- if not (hasKey .Values.maxscale "containerSecurityContext") -}}
  {{- $_ := merge .Values (dict "maxscale" (dict "containerSecurityContext" (dict "runAsUser" 1772 "runAsGroup" 1772))) -}}
{{- end -}}
{{- if not (hasKey .Values.maxscale.metrics "containerSecurityContext") -}}
  {{- $_ := merge .Values (dict "maxscale" (dict "metrics" (dict "containerSecurityContext" (dict "runAsUser" 1772 "runAsGroup" 1772)))) -}}
{{- end -}}
{{- if not (hasKey .Values.admin "podSecurityContext") -}}
  {{- $_ := merge .Values (dict "admin" (dict "podSecurityContext" (dict "runAsUser" 1773 "runAsGroup" 1773 "fsGroup" 1773))) -}}
{{- end -}}
{{- $_ := merge .Values (dict "geo_redundancy" (dict "directConnect" false)) -}}
{{- if not (hasKey .Values.hooks "jobDelay") -}}
  {{- $_ := merge .Values (dict "hooks" (dict "jobDelay" 0)) -}}
{{- end -}}
{{/* rbac_enabled moved to rbac.enabled for HBP in v7.16.0 */}}
{{- if hasKey .Values "rbac_enabled" -}}
  {{- $_ := merge .Values (dict "rbac" (dict "enabled" .Values.rbac_enabled)) -}}
{{- end -}}
{{/* admin.activeDeadlineSeconds moved to hooks.preUpgradeJob.activeDeadlineSeconds */}}
{{- if hasKey .Values.admin "activeDeadlineSeconds" -}}
  {{- $_ := merge .Values (dict "hooks" (dict "preUpgradeJob" (dict "activeDeadlineSeconds" .Values.admin.activeDeadlineSeconds))) -}}
{{- end -}}
{{/* Added in v7.16.0 with default false, change the default to true starting v9.1.1 */}}
{{- if not (hasKey .Values.cbur "selectPod") -}}
  {{- $_ := merge .Values (dict "cbur" (dict "selectPod" true)) -}}
{{- end -}}

{{/* Set default values for new values, v7.16.2 */}}
{{- if not (hasKey .Values.services.mariadb.exporter "headless") -}}
  {{- $_ := merge .Values (dict "services" (dict "mariadb" (dict "exporter" (dict "headless" (dict "name" ""))))) -}}
{{- end -}}
{{- if not (hasKey .Values.services.maxscale.exporter "headless") -}}
  {{- $_ := merge .Values (dict "services" (dict "maxscale" (dict "exporter" (dict "headless" (dict "name" ""))))) -}}
{{- end -}}

{{/* Set default values for new values, v7.17.0 */}}
{{/* Auto-backup on Upgrade via CBUR */}}
{{- $_ := merge .Values (dict "cbur" (dict "backup" (dict "upgrade" false "timeout" 900))) -}}
{{- $_ := merge .Values (dict "cbur" (dict "service" (dict "namespace" "ncms" "name" "cbur-master-cbur" "protocol" "http"))) -}}
{{- if not (hasKey .Values.rbac "psp") -}}
  {{/* PodSecurityPolicy(psp) */}}
  {{- $_ := merge .Values (dict "rbac" (dict "psp" ( dict "create" true ))) -}}
{{- end -}}

{{/* Pod Disruption Budgets (PDB) */}}
{{- if not (hasKey .Values.mariadb "pdb") -}}
  {{- $_ := merge .Values (dict "mariadb" (dict "pdb" (dict "enabled" false "minAvailable" "50%"))) -}}
{{- end -}}
{{- if not (hasKey .Values.maxscale "pdb") -}}
  {{- $_ := merge .Values (dict "maxscale" (dict "pdb" (dict "enabled" false "maxUnavailable" "1"))) -}}
{{- end -}}
{{- if not (hasKey .Values.admin "pdb") -}}
  {{- $_ := merge .Values (dict "admin" (dict "pdb" (dict "enabled" false "maxUnavailable" "100%"))) -}}
{{- end -}}
{{/* [HBP_Security_1.2] Allow user/password to be provided via secrets
* Migrate old username/password values to new users group
*/}}
{{- if not (hasKey .Values "users") -}}
  {{- $_ := merge .Values (dict "users" (dict)) -}}
{{- end -}}
{{- if not (hasKey .Values.users "root") -}}
  {{- $_ := merge .Values (dict "users" (dict "root" (dict "allowExternal" .Values.mariadb.allow_root_all))) -}}
{{- end -}}
{{- if and (not (hasKey .Values.users.root "password")) (hasKey .Values.mariadb  "root_password") -}}
  {{- $_ := merge .Values (dict "users" (dict "root" (dict "password" .Values.mariadb.root_password))) -}}
{{- end -}}
{{- if not (hasKey .Values.users "replication") -}}
  {{- $_ := merge .Values (dict "users" (dict "replication" (dict "username" (default "repl@b.c" .Values.mariadb.repl_user)))) -}}
{{- end -}}
{{- if and (not (hasKey .Values.users.replication "password")) (hasKey .Values.mariadb "repl_user_password") -}}
  {{- $_ := merge .Values (dict "users" (dict "replication" (dict "password" .Values.mariadb.repl_user_password))) -}}
{{- end -}}
{{- if not (hasKey .Values.users "mariadbMetrics") -}}
  {{- $_ := merge .Values (dict "users" (dict "mariadbMetrics" (dict "username" (default "exporter" .Values.mariadb.metrics.user)))) -}}
{{- end -}}
{{- if and (not (hasKey .Values.users.mariadbMetrics "password")) (hasKey .Values.mariadb.metrics "metrics_password") -}}
  {{- $_ := merge .Values (dict "users" (dict "mariadbMetrics" (dict "password" .Values.mariadb.metrics.metrics_password))) -}}
{{- end -}}
{{- if not (hasKey .Values.users "maxscale") -}}
  {{- $_ := merge .Values (dict "users" (dict "maxscale" (dict "username" (default "maxscale" .Values.maxscale.maxscale_user)))) -}}
{{- end -}}
{{- if and (not (hasKey .Values.users.maxscale "password")) (hasKey .Values.maxscale "maxscale_user_password") -}}
  {{- $_ := merge .Values (dict "users" (dict "maxscale" (dict "password" .Values.maxscale.maxscale_user_password))) -}}
{{- end -}}
{{/* istioVersion moved to istio.version for HBP in v7.17.0 */}}
{{- if hasKey .Values.global "istioVersion" -}}
  {{- $_ := merge .Values (dict "istio" (dict "version" .Values.global.istioVersion)) -}}
{{- end -}}

{{/* Set default values for new values, v7.17.1 */}}
{{- if not (hasKey .Values.admin "pwchangeTimeout") -}}
  {{- $_ := merge .Values (dict "admin" (dict "pwchangeTimeout" 900)) -}}
{{- end -}}

{{/* Set default values for new values, v8.0.0 */}}
{{- if not (hasKey .Values.users "maxscaleMetrics") -}}
  {{- $_ := merge .Values (dict "users" (dict "maxscaleMetrics" (dict "username" (default "max_exporter" .Values.maxscale.metrics.user)))) -}}
{{- end -}}
{{- if and (not (hasKey .Values.users.maxscaleMetrics "password")) (hasKey .Values.maxscale.metrics "metrics_password") -}}
  {{- $_ := merge .Values (dict "users" (dict "maxscaleMetrics" (dict "password" .Values.maxscale.metrics.metrics_password))) -}}
{{- end -}}

{{/* timezone.timeZoneEnv moved to timeZoneEnv for HBP in v8.0.0 */}}
{{- if and ( not ( hasKey .Values "timeZoneEnv") ) ( hasKey .Values "timezone" ) -}}
  {{- $_ := merge .Values (dict "timeZoneEnv"  ( .Values.timezone.timeZoneEnv )) -}}
{{- end -}}

{{/* Set default values for new values, v8.1.0 */}}
{{/* Carry forward dnsName config */}}
{{- if ( hasKey .Values.certManager "dnsName1" ) -}}
{{- if ( hasKey .Values.certManager "dnsName2" ) -}}
  {{- $_ := merge .Values (dict "certManager"  (dict "dnsNames" ( list .Values.certManager.dnsName1 .Values.certManager.dnsName2 ))) -}}
{{- else -}}
  {{- $_ := merge .Values (dict "certManager" (dict "dnsNames" ( list .Values.certManager.dnsName1 ))) -}}
{{- end -}}
{{- end -}}
{{/* Set new mysqld-exporter image name */}}
{{- $_ := merge .Values (dict "mariadb" (dict "metrics" (dict "image" (dict "name" "cmdb/mysqld-exporter")))) -}}
{{/* Set new mariadb PVC alarm thresholds */}}
{{- if not ( hasKey .Values.mariadb.persistence "nearFullPercent" ) -}}
{{- $_ := merge .Values (dict "mariadb" (dict "persistence" ( dict "nearFullPercent" 85 ))) -}}
{{- end -}}
{{- if not ( hasKey .Values.mariadb.persistence "fullPercent" ) -}}
{{- $_ := merge .Values (dict "mariadb" (dict "persistence" ( dict "fullPercent" 95 ))) -}}
{{- end -}}
{{/* Set new istio.gateway defaults */}}
{{- if not (hasKey .Values.istio "gateway") -}}
  {{- $_ := merge .Values (dict "istio" (dict "gateway" (dict "enabled" false "ingressPodSelector" (dict) "hosts" (list) (dict "tls" (dict "mode" "ISTIO_MUTUAL" "credentialName" "" "custom" (dict)))))) -}}
{{- end -}}
{{/* Set new hooks.testJob defaults */}}
{{- if not (hasKey .Values.hooks "testJob") -}}
  {{- $_ := merge .Values (dict "hooks" (dict "testJob" (dict "enabled" true "backoffLimit" 0 "timeout" 300))) -}}
{{- end -}}

{{/* Set default values for new values, v8.2.0 */}}
{{/* Set new admin.rebuildSlave values defaults */}}
{{- if not (hasKey .Values.admin.rebuildSlave "mode") -}}
  {{- $_ := merge .Values (dict "admin" (dict "rebuildSlave" (dict "mode" "safe"))) -}}
{{- end -}}
{{- if not (hasKey .Values.admin.rebuildSlave "retries") -}}
  {{- $_ := merge .Values (dict "admin" (dict "rebuildSlave" (dict "retries" 1))) -}}
{{- end -}}
{{/* move old onErrors to onErrorIO */}}
{{- if not (hasKey .Values.admin.rebuildSlave "onErrorsIO") -}}
  {{- $_ := merge .Values (dict "admin" (dict "rebuildSlave" (dict "onErrorsIO" (default "1236" .Values.admin.rebuildSlave.onErrors)))) -}}
{{- end -}}

{{/* Set default values for new values, v8.2.3 */}}
{{/* added ephemeral-storage resource settings in v8.2.3 */}}
{{- if not (hasKey .Values.mariadb.resources.requests "ephemeral-storage") -}}
  {{- $_ := merge .Values (dict "mariadb" (dict "resources" (dict "requests" (dict "ephemeral-storage" "1Gi")))) -}}
{{- end -}}
{{- if not (hasKey .Values.mariadb.resources.limits "ephemeral-storage") -}}
  {{- $_ := merge .Values (dict "mariadb" (dict "resources" (dict "limits" (dict "ephemeral-storage" "1Gi")))) -}}
{{- end -}}
{{- if not (hasKey .Values.mariadb.metrics.resources.requests "ephemeral-storage") -}}
  {{- $_ := merge .Values (dict "mariadb" (dict "metrics" (dict "resources" (dict "requests" (dict "ephemeral-storage" "128Mi"))))) -}}
{{- end -}}
{{- if not (hasKey .Values.mariadb.metrics.resources.limits "ephemeral-storage") -}}
  {{- $_ := merge .Values (dict "mariadb" (dict "metrics" (dict "resources" (dict "limits" (dict "ephemeral-storage" "128Mi"))))) -}}
{{- end -}}
{{- if not (hasKey .Values.maxscale.resources.requests "ephemeral-storage") -}}
  {{- $_ := merge .Values (dict "maxscale" (dict "resources" (dict "requests" (dict "ephemeral-storage" "1Gi")))) -}}
{{- end -}}
{{- if not (hasKey .Values.maxscale.resources.limits "ephemeral-storage") -}}
  {{- $_ := merge .Values (dict "maxscale" (dict "resources" (dict "limits" (dict "ephemeral-storage" "1Gi")))) -}}
{{- end -}}
{{- if not (hasKey .Values.maxscale.metrics.resources.requests "ephemeral-storage") -}}
  {{- $_ := merge .Values (dict "maxscale" (dict "metrics" (dict "resources" (dict "requests" (dict "ephemeral-storage" "128Mi"))))) -}}
{{- end -}}
{{- if not (hasKey .Values.maxscale.metrics.resources.limits "ephemeral-storage") -}}
  {{- $_ := merge .Values (dict "maxscale" (dict "metrics" (dict "resources" (dict "limits" (dict "ephemeral-storage" "128Mi"))))) -}}
{{- end -}}
{{- if not (hasKey .Values.admin.resources.requests "ephemeral-storage") -}}
  {{- $_ := merge .Values (dict "admin" (dict "resources" (dict "requests" (dict "ephemeral-storage" "1Gi")))) -}}
{{- end -}}
{{- if not (hasKey .Values.admin.resources.limits "ephemeral-storage") -}}
  {{- $_ := merge .Values (dict "admin" (dict "resources" (dict "limits" (dict "ephemeral-storage" "1Gi")))) -}}
{{- end -}}
{{- if not (hasKey .Values.cbur.resources.requests "ephemeral-storage") -}}
  {{- $_ := merge .Values (dict "cbur" (dict "resources" (dict "requests" (dict "ephemeral-storage" "128Mi")))) -}}
{{- end -}}
{{- if not (hasKey .Values.cbur.resources.limits "ephemeral-storage") -}}
  {{- $_ := merge .Values (dict "cbur" (dict "resources" (dict "limits" (dict "ephemeral-storage" "128Mi")))) -}}
{{- end -}}
{{/* added job specific hook resource settings in v8.2.3 */}}
{{- if not (hasKey .Values.hooks "resources") -}}
  {{- $_ := merge .Values (dict "hooks" (dict "resources" (dict "requests" (dict "memory" "256Mi" "cpu" "250m" "ephemeral-storage" "128Mi")) (dict "limits" (dict "memory" "256Mi" "cpu" "250m" "ephemeral-storage" "128Mi")))) -}}
{{- end -}}

{{/* Set default values for new values, v8.3.0 */}}
{{- if not (hasKey .Values.mariadb "backupRestore") -}}
  {{- $_ := merge .Values (dict "mariadb" (dict "backupRestore" (dict "parallel" 2 "useMemory" "512MB" "fullBackupInterval" 1))) -}}
{{- end -}}

{{/* Set default values for new values, v8.4.0 */}}
{{- $_ := merge .Values (dict "rbac" (dict "scc" ( dict "create" false ))) -}}
{{- $_ := merge .Values (dict "istio" (dict "serviceEntry" (dict "create" false))) -}}
{{- if not (hasKey .Values "imageFlavor") -}}
  {{- $_ := merge .Values (dict "imageFlavor" "rocky8") -}}
{{- end -}}
{{/* carry forward citmIngress service configuration */}}
{{- if (hasKey .Values.services.maxscale "citmIngressTcpConfigMapName") -}}
  {{- $_ := merge .Values (dict "services" (dict "maxscale" (dict "citmIngress" (dict "configMapName" .Values.services.maxscale.citmIngressTcpConfigMapName "port" .Values.services.maxscale.citmIngressTcpPort)))) -}}
{{- end -}}
{{- if (hasKey .Values.services.mariadb_master "citmIngressTcpConfigMapName") -}}
  {{- $_ := merge .Values (dict "services" (dict "mariadb_master" (dict "citmIngress" (dict "configMapName" .Values.services.mariadb_master.citmIngressTcpConfigMapName "port" .Values.services.mariadb_master.citmIngressTcpPort)))) -}}
{{- end -}}
{{/* carry forward csfTransportIngress service configuration */}}
{{- if (hasKey .Values.services.maxscale "csfTransportIngressName") -}}
  {{- $_ := merge .Values (dict "services" (dict "maxscale" (dict "csfTransportIngress" (dict "name" .Values.services.maxscale.csfTransportIngressName "port" .Values.services.maxscale.csfTransportIngressPort)))) -}}
{{- end -}}
{{- if (hasKey .Values.services.mariadb_master "csfTransportIngressName") -}}
  {{- $_ := merge .Values (dict "services" (dict "mariadb_master" (dict "csfTransportIngress" (dict "name" .Values.services.mariadb_master.csfTransportIngressName "port" .Values.services.mariadb_master.csfTransportIngressPort)))) -}}
{{- end -}}
{{/* defaults for unifiedLogging */}}
{{- $_ := merge .Values (dict "global" (dict "unifiedLogging" (dict "extension" (dict) "syslog" (dict "enabled" nil "host" "" "port" "" "protocol" "" "timeout" "" "closeReqType" "" "keyStore" (dict) "keyStorePassword" (dict) "trustStore" (dict) "trustStorePassword" (dict))))) -}}
{{- $_ := merge .Values (dict "unifiedLogging" (dict "extension" (dict) "syslog" (dict "enabled" nil "host" "" "port" "" "protocol" "" "timeout" "" "closeReqType" "" "keyStore" (dict) "keyStorePassword" (dict) "trustStore" (dict) "trustStorePassword" (dict)))) -}}
{{/* maxscale HPA added */}}
{{- $_ := merge .Values (dict "global" (dict "hpa" (dict))) -}}
{{- $_ := merge .Values (dict "maxscale" (dict "hpa" (dict "predefinedMetrics" (dict)) "metrics" (list))) -}}

{{/* Set default values for new values, v8.5.0 */}}
{{/* startupProbe added in v8.5.0 */}}
{{- $_ := merge .Values (dict "mariadb" (dict "startupProbe" (dict))) -}}
{{- $_ := merge .Values (dict "maxscale" (dict "startupProbe" (dict))) -}}
{{- $_ := merge .Values (dict "admin" (dict "startupProbe" (dict))) -}}
{{/* mariadb HPA added */}}
{{- $_ := merge .Values (dict "mariadb" (dict "hpa" (dict "predefinedMetrics" (dict "averageCPUThreshold" 80 "averageMemoryThreshold" 80)) "metrics" (list))) -}}
{{- if not (hasKey .Values.mariadb.hpa.predefinedMetrics "enabled") -}}
  {{- $_ := merge .Values (dict "mariadb" (dict "hpa" (dict "predefinedMetrics" (dict "enabled" true)))) -}}
{{- end -}}
{{/* maxscale convert default metrics to predefinedMetrics */}}
{{- $ctx := .Values -}}
{{- range $item := .Values.maxscale.hpa.metrics }}
  {{- if hasKey $item "name" -}}
    {{- if eq $item.name "cpu" -}}
      {{- $_ := mergeOverwrite $ctx (dict "maxscale" (dict "hpa" (dict "predefinedMetrics" (dict "enabled" true "averageCPUThreshold" (int $item.averageUtilization))))) -}}
    {{- else if eq $item.name "memory" -}}
      {{- $_ := mergeOverwrite $ctx (dict "maxscale" (dict "hpa" (dict "predefinedMetrics" (dict "enabled" true "averageMemoryThreshold" (int $item.averageUtilization))))) -}}
    {{- else -}}
      {{- $_ := required "maxscale.hpa.metrics must be modified to new values format" "" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- $_ := merge .Values (dict "maxscale" (dict "hpa" (dict "predefinedMetrics" (dict "averageCPUThreshold" 80 "averageMemoryThreshold" 80)))) -}}
{{- if not (hasKey .Values.maxscale.hpa.predefinedMetrics "enabled") -}}
  {{- $_ := merge .Values (dict "maxscale" (dict "hpa" (dict "predefinedMetrics" (dict "enabled" true)))) -}}
{{- end -}}
{{/* imagePullSecrets HBP naming convention */}}
{{- if hasKey .Values.admin "pullSecrets" -}}
  {{- $_ := merge .Values (dict "admin" (dict "imagePullSecrets" .Values.admin.pullSecrets)) -}}
{{- end -}}
{{- if hasKey .Values.mariadb "pullSecrets" -}}
  {{- $_ := merge .Values (dict "mariadb" (dict "imagePullSecrets" .Values.mariadb.pullSecrets)) -}}
{{- end -}}
{{- if hasKey .Values.maxscale "pullSecrets" -}}
  {{- $_ := merge .Values (dict "maxscale" (dict "imagePullSecrets" .Values.maxscale.pullSecrets)) -}}
{{- end -}}

{{/* Set default values for new values, v8.6.0 */}}
{{/* zero trust proxy support */}}
{{- $_ := merge .Values (dict "auth" (dict "enabled" "" "skipVerifyInsecure" false "secretRef" (dict "name" "") "tls" (dict "secretRef" (dict "name" "" "keyNames" (dict "caCrt" "ca.crt" "tlsKey" "tls.key" "tlsCrt" "tls.crt"))))) -}}
{{- $_ := merge .Values (dict "mariadb" (dict "auth" (dict "enabled" "" "secretRef" (dict "name" "") "tls" (dict "secretRef" (dict "name" "" "keyNames" (dict "caCrt" "" "tlsKey" "" "tlsCrt" "")))))) -}}
{{- $_ := merge .Values (dict "maxscale" (dict "auth" (dict "enabled" "" "secretRef" (dict "name" "") "tls" (dict "secretRef" (dict "name" "" "keyNames" (dict "caCrt" "" "tlsKey" "" "tlsCrt" "")))))) -}}
{{/* HBP 3.4.0 */}}
{{/* ROOT: merge global.certManager and certManager.enabled true if not defined */}}
{{- if not (hasKey .Values.global "certManager") -}}
  {{- $_ := merge .Values (dict "global" (dict "certManager" (dict "enabled" true "apiVersion" ""))) -}}
{{- end -}}
{{- if not (hasKey .Values.certManager "enabled") -}}
  {{- $_ := merge .Values (dict "certManager" (dict "enabled" true)) -}}
{{- end -}}
{{/* CLIENTS: merge clients.mariadb.tls */}}
{{- $_ := merge .Values (dict "clients" (dict "mariadb" (dict "tls" (dict)))) -}}
{{- if hasKey .Values.mariadb "certificates" -}}
  {{- $_ := set .Values.clients.mariadb.tls.secretRef.keyNames "caCrt" (default "ca.crt" .Values.mariadb.certificates.client_ca_cert) -}}
  {{- $_ := set .Values.clients.mariadb.tls.secretRef.keyNames "tlsKey" (default "tls.key" .Values.mariadb.certificates.client_key) -}}
  {{- $_ := set .Values.clients.mariadb.tls.secretRef.keyNames "tlsCrt" (default "tls.crt" .Values.mariadb.certificates.client_cert) -}}
  {{- $_ := set .Values.clients.mariadb.tls.secretRef "threshold" (default 7 .Values.mariadb.certificates.threshold) -}}
  {{- $_ := set .Values.clients.mariadb.tls.secretRef "polling" (default 3600 .Values.mariadb.certificates.polling) -}}
{{- end -}}
{{/* merge clients.mariadb.certificate (w/o enabled default true) */}}
{{- $_ := merge .Values (dict "clients" (dict "mariadb" (dict "certificate" (dict "issuerRef" (dict "name" "" "kind" "ClusterIssuer" "group" "cert-manager.io") "duration" "8760h" "renewBefore" "360h" "subject" "" "commonName" "" "usages" "" "dnsName" (list) "uris" (list) "ipAddresses" (list) "privateKey" (dict "algorithm" "" "encoding" "" "size" "" "rotationPolicy" "Never"))))) -}}
{{/* MARIADB: merge mariadb.tls (w/o enabled boolean to true) */}}
{{- $_ := merge .Values (dict "mariadb" (dict "tls" (dict "secretRef" (dict "name" "" "keyNames" (dict "caCrt" "ca.crt" "tlsKey" "tls.key" "tlsCrt" "tls.crt"))))) -}}
{{- if hasKey .Values.mariadb "certificates" -}}
  {{- $_ := set .Values.mariadb.tls.secretRef.keyNames "caCrt" (default "ca.crt" .Values.mariadb.certificates.server_ca_cert) -}}
  {{- $_ := set .Values.mariadb.tls.secretRef.keyNames "tlsKey" (default "tls.key" .Values.mariadb.certificates.server_key) -}}
  {{- $_ := set .Values.mariadb.tls.secretRef.keyNames "tlsCrt" (default "tls.crt" .Values.mariadb.certificates.server_cert) -}}
{{- end -}}
{{/* merge mariadb.tls.enabled (default true) with old mariadb.use_tls (default false) */}}
{{- if hasKey .Values.mariadb "use_tls" -}}
  {{- $_ := set .Values.mariadb.tls "enabled" .Values.mariadb.use_tls -}}
  {{- $_ := unset .Values.mariadb "use_tls" -}}
{{- else if not (hasKey .Values.mariadb.tls "enabled") -}}
  {{- $_ := merge .Values (dict "mariadb" (dict "tls" (dict "enabled" false))) -}}
{{- end -}}
{{/* merge mariadb.certificate (w/o enabled default true) */}}
{{- $_ := merge .Values (dict "mariadb" (dict "certificate" (dict "issuerRef" (dict "name" "" "kind" "ClusterIssuer" "group" "cert-manager.io") "duration" "8760h" "renewBefore" "360h" "subject" "" "commonName" "" "usages" "" "dnsName" (list) "uris" (list) "ipAddresses" (list) "privateKey" (dict "algorithm" "" "encoding" "" "size" "" "rotationPolicy" "Never")))) -}}
{{/* merge old mariadb.certificates to new structure (both client/server) */}}
{{- if hasKey .Values.mariadb "certificates" -}}
  {{- $_ := set .Values.mariadb.certificate "enabled" (eq (default "none" .Values.mariadb.certificates.secret) "cmgr") -}}
  {{- $_ := set .Values.clients.mariadb.certificate "enabled" (eq (default "none" .Values.mariadb.certificates.secret) "cmgr") -}}
  {{- if not .Values.mariadb.certificate.enabled -}}
    {{ $_ := merge .Values (dict "mariadb" (dict "tls" (dict "secretRef" (dict "name" .Values.mariadb.certificates.secret)))) -}}
    {{ $_ := merge .Values (dict "clients" (dict "mariadb" (dict "tls" (dict "secretRef" (dict "name" .Values.mariadb.certificates.secret))))) -}}
  {{- end -}}
{{- else if not (hasKey .Values.mariadb.certificate "enabled") -}}
  {{- $_ := set .Values.mariadb.certificate "enabled" true -}}
  {{- $_ := set .Values.clients.mariadb.certificate "enabled" true -}}
{{- end -}}
{{/* MAXSCALE: merge maxscale.tls (w/o enabled boolean to true) */}}
{{- $_ := merge .Values (dict "maxscale" (dict "tls" (dict "secretRef" (dict "name" "" "keyNames" (dict "caCrt" "ca.crt" "tlsKey" "tls.key" "tlsCrt" "tls.crt"))))) -}}
{{- if hasKey .Values.maxscale "certificates" -}}
  {{- $_ := set .Values.maxscale.tls.secretRef.keyNames "caCrt" (default "ca.crt" .Values.maxscale.certificates.server_ca_cert) -}}
  {{- $_ := set .Values.maxscale.tls.secretRef.keyNames "tlsKey" (default "tls.key" .Values.maxscale.certificates.server_key) -}}
  {{- $_ := set .Values.maxscale.tls.secretRef.keyNames "tlsCrt" (default "tls.crt" .Values.maxscale.certificates.server_cert) -}}
{{- end -}}
{{/* merge maxscale.tls.enabled (default true) with old maxscale.use_tls (default false) */}}
{{- if hasKey .Values.maxscale "use_tls" -}}
  {{- $_ := set .Values.maxscale.tls "enabled" .Values.maxscale.use_tls -}}
  {{- $_ := unset .Values.maxscale "use_tls" -}}
{{- else if not (hasKey .Values.maxscale.tls "enabled") -}}
  {{- $_ := merge .Values (dict "maxscale" (dict "tls" (dict "enabled" false))) -}}
{{- end -}}
{{/* merge maxscale.certificate (w/o enabled default true) */}}
{{- $_ := merge .Values (dict "maxscale" (dict "certificate" (dict "issuerRef" (dict "name" "" "kind" "ClusterIssuer" "group" "cert-manager.io") "duration" "8760h" "renewBefore" "360h" "subject" "" "commonName" "" "usages" "" "dnsName" (list) "uris" (list) "ipAddresses" (list) "privateKey" (dict "algorithm" "" "encoding" "" "size" "" "rotationPolicy" "Never")))) -}}
{{/* merge old maxscale.certificates to new structure */}}
{{- if hasKey .Values.maxscale "certificates" -}}
  {{- $_ := set .Values.maxscale.certificate "enabled" (eq (default "none" .Values.maxscale.certificates.secret) "cmgr") -}}
  {{- if not .Values.maxscale.certificate.enabled -}}
    {{ $_ := merge .Values (dict "maxscale" (dict "tls" (dict "secretRef" (dict "name" .Values.maxscale.certificates.secret)))) -}}
  {{- end -}}
{{- else if not (hasKey .Values.maxscale.certificate "enabled") -}}
  {{- $_ := set .Values.maxscale.certificate "enabled" true -}}
{{- end -}}
{{/* delete old certificates dictionaries */}}
{{- $_ := unset .Values.mariadb "certificates" -}}
{{- $_ := unset .Values.maxscale "certificates" -}}

{{/* Set default values for new values, v9.0.0 */}}
{{- $_ := merge .Values (dict "admin" (dict "restoreServer" (dict "enabled" false "joinCluster" false))) -}}

{{- if not (hasKey .Values.global "flatRegistry") -}}
  {{- $_ := merge .Values (dict "global" (dict "flatRegistry" "false")) -}}
{{- end -}}

{{- if not (hasKey .Values.global "enableDefaultCpuLimits") -}}
  {{- $_ := merge .Values (dict "global" (dict "enableDefaultCpuLimits" "false")) -}}
{{- end -}}

{{- $_ := merge .Values (dict "mariadb" (dict "cbur" (dict "emptyDir" (dict "sizeLimit" "40Gi")))) -}}

{{/* Set default cpu limit if configured */}}
{{- $_ := merge .Values (dict "mariadb" (dict "resources" (dict "limits" (dict "_cpu" "1")))) -}}
{{- $_ := merge .Values (dict "mariadb" (dict "initContainers" (dict "resources" (dict "limits" (dict "_cpu" "100m"))))) -}}
{{- $_ := merge .Values (dict "mariadb" (dict "metrics" (dict "resources" (dict "limits" (dict "_cpu" "250m"))))) -}}
{{- $_ := merge .Values (dict "mariadb" (dict "auth" (dict "resources" (dict "limits" (dict "_cpu" "250m"))))) -}}
{{- $_ := merge .Values (dict "maxscale" (dict "resources" (dict "limits" (dict "_cpu" "500m")))) -}}
{{- $_ := merge .Values (dict "maxscale" (dict "initContainers" (dict "resources" (dict "limits" (dict "_cpu" "100m"))))) -}}
{{- $_ := merge .Values (dict "maxscale" (dict "metrics" (dict "resources" (dict "limits" (dict "_cpu" "250m"))))) -}}
{{- $_ := merge .Values (dict "maxscale" (dict "auth" (dict "resources" (dict "limits" (dict "_cpu" "250m"))))) -}}
{{- $_ := merge .Values (dict "admin" (dict "resources" (dict "limits" (dict "_cpu" "500m")))) -}}
{{- $_ := merge .Values (dict "hooks" (dict "resources" (dict "limits" (dict "_cpu" "250m")))) -}}
{{- $_ := merge .Values (dict "cbur" (dict "resources" (dict "limits" (dict "_cpu" "250m")))) -}}


{{/* Set default values for new values, v9.1.0 */}}
{{/* HBP 3.7.0 */}}
{{- $_ := merge .Values (dict "imageFlavorPolicy" "BestMatch") -}}
{{- $_ := merge .Values (dict "global" (dict "imageFlavor" "rocky8")) -}}
{{- $_ := merge .Values (dict "global" (dict "imageFlavorPolicy" "BestMatch")) -}}

{{- if not (hasKey .Values.cbur "volumeBackupType" ) -}}
  {{- $_ := merge .Values (dict "cbur" (dict "volumeBackupType" "volume" "volumeSnapshotClassName" "cinder-csi-snapclass" "saveVolumeContentToBackend" true "createVolumeOnly" false "keepLocalSnapshotIfSaveToBackend" false "retrieveVolumeContentFromBackend" true )) -}}
{{- end -}}

{{/* merge global.tls.enabled and tls.enabled, true if not defined */}}
{{- if not (hasKey .Values.global "tls") -}}
  {{- $_ := merge .Values (dict "global" (dict "tls" (dict "enabled" true))) -}}
{{- end -}}
{{- if not (hasKey .Values "tls") -}}
  {{- $_ := merge .Values (dict "tls" (dict "enabled")) -}}
{{- end -}}

{{/* merge global.disablePodNamePrefixRestrictions and disablePodNamePrefixRestrictions, false if not defined */}}
{{- if not (hasKey .Values.global "disablePodNamePrefixRestrictions") -}}
  {{- $_ := merge .Values (dict "global" (dict "disablePodNamePrefixRestrictions")) -}}
{{- end -}}
{{- if not (hasKey .Values "disablePodNamePrefixRestrictions") -}}
  {{- $_ := merge .Values (dict "disablePodNamePrefixRestrictions") -}}
{{- end -}}

{{/* construct mysql service listeners ports if not present */}}
{{- $use_tls := eq (include "cmdb.tls_enabled" (tuple . "mariadb")) "true" -}}
{{/* ----- rwSplit ----- */}}
{{- if not (hasKey .Values.services.mysql "rwSplit") -}}
  {{- $rwPort := default 0 .Values.maxscale.listeners.rwSplit -}}
  {{- $_ := merge .Values (dict "services" (dict "mysql" (dict "rwSplit" (dict "enabled" (ne (int $rwPort) 0))))) -}}
  {{- $_ := merge .Values (dict "services" (dict "mysql" ($use_tls | ternary (dict "rwSplit" (dict "tlsPort" $rwPort "nonTlsPort" 0)) (dict "rwSplit" (dict "tlsPort" 0 "nonTlsPort" $rwPort))))) -}}
  {{- if hasKey .Values.services.mysql "nodePort" }}
    {{- $_ := merge .Values (dict "services" (dict "mysql" (dict "rwSplit" (dict "nodePort" .Values.services.mysql.nodePort)))) }}
  {{- end -}}
  {{- $_ := unset .Values.maxscale.listeners "rwSplit" -}}
{{- else -}}
  {{- $_ := merge .Values (dict "services" (dict "mysql" ($use_tls | ternary (dict "rwSplit" (dict "tlsPort" 3306 "nonTlsPort" 0)) (dict "rwSplit" (dict "tlsPort" 0 "nonTlsPort" 3306))))) -}}
{{- end -}}
{{/* ----- readOnly ----- */}}
{{- if not (hasKey .Values.services.mysql "readOnly") -}}
  {{- $roPort := default 0 .Values.maxscale.listeners.readOnly -}}
  {{- $_ := merge .Values (dict "services" (dict "mysql" (dict "readOnly" (dict "enabled" (ne (int $roPort) 0))))) -}}
  {{- $_ := merge .Values (dict "services" (dict "mysql" ($use_tls | ternary (dict "readOnly" (dict "tlsPort" $roPort "nonTlsPort" 0)) (dict "readOnly" (dict "tlsPort" 0 "nonTlsPort" $roPort))))) -}}
  {{- if hasKey .Values.services.mysql "nodePort_readonly" }}
    {{- $_ := merge .Values (dict "services" (dict "mysql" (dict "readOnly" (dict "nodePort" .Values.services.mysql.nodePort_readonly)))) }}
  {{- end -}}
  {{- $_ := unset .Values.maxscale.listeners "readOnly" -}}
  {{- $_ := unset .Values.services.mysql "nodePort_readonly" -}}
{{- else -}}
  {{- $_ := merge .Values (dict "services" (dict "mysql" ($use_tls | ternary (dict "readOnly" (dict "tlsPort" 3307 "nonTlsPort" 0)) (dict "readOnly" (dict "tlsPort" 0 "nonTlsPort" 3307))))) -}}
{{- end -}}
{{/* ----- masterOnly ----- */}}
{{- if not (hasKey .Values.services.mysql "masterOnly") -}}
  {{- $mstrPort := default 0 .Values.maxscale.listeners.masterOnly -}}
  {{- $_ := merge .Values (dict "services" (dict "mysql" (dict "masterOnly" (dict "enabled" (ne (int $mstrPort) 0))))) -}}
  {{- $_ := merge .Values (dict "services" (dict "mysql" ($use_tls | ternary (dict "masterOnly" (dict "tlsPort" $mstrPort "nonTlsPort" 0)) (dict "masterOnly" (dict "tlsPort" 0 "nonTlsPort" $mstrPort))))) -}}
  {{- if hasKey .Values.services.mysql "nodePort_mstronly" }}
    {{- $_ := merge .Values (dict "services" (dict "mysql" (dict "masterOnly" (dict "nodePort" .Values.services.mysql.nodePort_mstronly)))) }}
  {{- end -}}
  {{- $_ := unset .Values.maxscale.listeners "masterOnly" -}}
  {{- $_ := unset .Values.services.mysql "nodePort_mstronly" -}}
{{- else -}}
  {{- $_ := merge .Values (dict "services" (dict "mysql" ($use_tls | ternary (dict "masterOnly" (dict "tlsPort" 3308 "nonTlsPort" 0)) (dict "masterOnly" (dict "tlsPort" 0 "nonTlsPort" 3308))))) -}}
{{- end -}}
{{/* ensure ports are csv list or string */}}
{{- $_ := set .Values.services.mysql.rwSplit "tlsPort" (nospace (toString .Values.services.mysql.rwSplit.tlsPort)) -}}
{{- $_ := set .Values.services.mysql.rwSplit "nonTlsPort" (nospace (toString .Values.services.mysql.rwSplit.nonTlsPort)) -}}
{{- $_ := set .Values.services.mysql.rwSplit "nodePort" (nospace (toString (default "" .Values.services.mysql.rwSplit.nodePort))) -}}
{{- $_ := set .Values.services.mysql.readOnly "tlsPort" (nospace (toString .Values.services.mysql.readOnly.tlsPort)) -}}
{{- $_ := set .Values.services.mysql.readOnly "nonTlsPort" (nospace (toString .Values.services.mysql.readOnly.nonTlsPort)) -}}
{{- $_ := set .Values.services.mysql.readOnly "nodePort" (nospace (toString (default "" .Values.services.mysql.readOnly.nodePort))) -}}
{{- $_ := set .Values.services.mysql.masterOnly "tlsPort" (nospace (toString .Values.services.mysql.masterOnly.tlsPort)) -}}
{{- $_ := set .Values.services.mysql.masterOnly "nonTlsPort" (nospace (toString .Values.services.mysql.masterOnly.nonTlsPort)) -}}
{{- $_ := set .Values.services.mysql.masterOnly "nodePort" (nospace (toString (default "" .Values.services.mysql.masterOnly.nodePort))) -}}

{{/* update postRollbackJob timeout */}}
{{- if eq (toString .Values.hooks.postRollbackJob.timeout) "300" -}}
  {{- $_ := set .Values.hooks.postRollbackJob "timeout" 1800 -}}
{{- end -}}

{{/* Set default values for new values, v9.2.0 */}}
{{- $_ := merge .Values (dict "cbur" (dict "snapshotWaitDisk" 60 ) ) -}}

{{/* HBP 3.8.0 */}}
{{/* podAntiAffinity added to workloads in v9.2.0 */}}
{{/* Backward compatible: podAntiAffinity node type is based on nodeAntiAffinity, zone type  */}}
{{/* nodeAntiAffinity deprecated in favor of workload.podAntiAffinity in v9.2.0 */}}

{{- $node_anti_affinity :=  default "soft" .Values.nodeAntiAffinity  -}}
{{- $zone_def := dict "type" "soft" "topologyKey" "topology.kubernetes.io/zone" -}}
{{- $node_def := dict "type" $node_anti_affinity "topologyKey" "kubernetes.io/hostname" -}}
{{- $_ := merge .Values.mariadb.podAntiAffinity (dict "zone" $zone_def "node" $node_def )  -}}
{{- $_ := merge .Values.maxscale.podAntiAffinity ( dict "zone" $zone_def "node" $node_def )  -}}

{{/* customRules has priority over node/zone configuration */}}
{{- if hasKey .Values.mariadb.podAntiAffinity "customRules" -}}
  {{- $_ := set .Values.mariadb.podAntiAffinity.node "type" "" -}}
  {{- $_ := set .Values.mariadb.podAntiAffinity.zone "type" "" -}}
  {{- $_ := merge .Values.mariadb.podAntiAffinity (dict "customRules" (dict) )  -}}
{{- end -}}
{{- if hasKey .Values.maxscale.podAntiAffinity "customRules" -}}
  {{- $_ := set .Values.maxscale.podAntiAffinity.node "type" "" -}}
  {{- $_ := set .Values.maxscale.podAntiAffinity.zone "type" "" -}}
  {{- $_ := merge .Values.maxscale.podAntiAffinity (dict "customRules" (dict) )  -}}
{{- end -}}

{{- $_ := merge .Values (dict "istio" (dict "destinationRule" (dict "tls" ( dict "mode" "ISTIO_MUTUAL" )))) -}}

{{/* added workload.name for csf-common-lib.v1.selectorLabels - v9.2.0 */}}
{{- $_ := set .Values.mariadb "name" "mariadb" -}}
{{- $_ := set .Values.maxscale "name" "maxscale" -}}
{{- $_ := set .Values.admin "name" "admin" -}}
{{/* added workload.name for csf-common-lib.v3.resourceName */}}
{{- $_ := set .Values.mariadb "nameSuffix" "mariadb" -}}
{{- $_ := set .Values.maxscale "nameSuffix" "maxscale" -}}
{{- $_ := set .Values.admin "nameSuffix" "admin" -}}

{{/* add new syslog rfc and tls sections to global and site*/}}
{{- $_ := merge .Values.unifiedLogging.syslog (dict "rfc" (dict "enabled" nil)) -}}
{{- $_ := merge .Values.unifiedLogging.syslog (dict "tls" (dict "name" nil)) -}}
{{- $_ := merge .Values.unifiedLogging.syslog.tls (dict "secretRef" (dict "name" nil)) -}}
{{- $_ := merge .Values.unifiedLogging.syslog.tls.secretRef (dict "keyNames" (dict)) -}}
{{- $_ := merge .Values.global.unifiedLogging.syslog (dict "rfc" (dict "enabled" nil)) -}}
{{- $_ := merge .Values.global.unifiedLogging.syslog (dict "tls" (dict "name" nil)) -}}
{{- $_ := merge .Values.global.unifiedLogging.syslog.tls (dict "secretRef" (dict "name" nil)) -}}
{{- $_ := merge .Values.global.unifiedLogging.syslog.tls.secretRef (dict "keyNames" (dict "caCrt" "ca.crt" "tlsKey" "tls.key" "tlsCrt" "tls.crt")) -}}

{{/* create workload level unifiedLogging default configuration with certificate */}}
{{- $_ := merge .Values (dict "admin" (dict "unifiedLogging" (dict "extension" (dict) "syslog" (dict "enabled" nil "host" "" "port" "" "protocol" "" "timeout" "" "closeReqType" "" "keyStore" (dict) "keyStorePassword" (dict) "trustStore" (dict) "trustStorePassword" (dict) "rfc" (dict "enabled" nil) "tls" (dict "secretRef" (dict "name" "" "keyNames" (dict))))))) -}}
{{- $_ := merge .Values (dict "mariadb" (dict "unifiedLogging" (dict "extension" (dict) "syslog" (dict "enabled" nil "host" "" "port" "" "protocol" "" "timeout" "" "closeReqType" "" "keyStore" (dict) "keyStorePassword" (dict) "trustStore" (dict) "trustStorePassword" (dict) "rfc" (dict "enabled" nil) "tls" (dict "secretRef" (dict "name" "" "keyNames" (dict))))))) -}}
{{- $_ := merge .Values (dict "maxscale" (dict "unifiedLogging" (dict "extension" (dict) "syslog" (dict "enabled" nil "host" "" "port" "" "protocol" "" "timeout" "" "closeReqType" "" "keyStore" (dict) "keyStorePassword" (dict) "trustStore" (dict) "trustStorePassword" (dict) "rfc" (dict "enabled" nil) "tls" (dict "secretRef" (dict "name" "" "keyNames" (dict))))))) -}}

{{/* merge site-level unifiedLogging into workload level unifiedLogging */}}
{{- $root := . -}}
{{- range (list .Values.admin .Values.mariadb .Values.maxscale ) }}
  {{- $workload := . }}
  {{- $workload_syslog_enabled := $workload.unifiedLogging.syslog.enabled }}
  {{- $workload_rfc_enabled := $workload.unifiedLogging.syslog.rfc.enabled }}
  {{- $_ := merge $workload.unifiedLogging $root.Values.unifiedLogging -}}
  {{- if and (eq (include "csf-common-lib.v1.isEmptyValue" $workload_syslog_enabled) "true") (eq (include "csf-common-lib.v1.isEmptyValue" $root.Values.unifiedLogging.syslog.enabled) "true") }}
    {{- $_ := set $workload.unifiedLogging.syslog "enabled" nil }}
  {{- else -}}
    {{- $_ := set $workload.unifiedLogging.syslog "enabled" (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple $workload_syslog_enabled $root.Values.unifiedLogging.syslog.enabled false)) "true") }}
  {{- end -}}
  {{- if and (eq (include "csf-common-lib.v1.isEmptyValue" $workload_rfc_enabled) "true") (eq (include "csf-common-lib.v1.isEmptyValue" $root.Values.unifiedLogging.syslog.rfc.enabled) "true") }}
    {{- $_ := set $workload.unifiedLogging.syslog.rfc "enabled" nil }}
  {{- else -}}
    {{- $_ := set $workload.unifiedLogging.syslog.rfc "enabled" (eq (include "csf-common-lib.v1.coalesceBoolean" (tuple $workload_rfc_enabled $root.Values.unifiedLogging.syslog.rfc.enabled false)) "true") }}
  {{- end -}}
{{- end -}}

{{/* add new certificate blocks for syslog, the same default as client.mariadb.certificate */}}
{{- $cmgr := .Values.clients.mariadb.certificate -}}
{{- $root := . -}}
{{- range (list .Values.admin .Values.mariadb .Values.maxscale ) }}
  {{- $workload := . }}
  {{- $_ := merge $workload.unifiedLogging.syslog (dict "certificate" (dict "issuerRef" (dict)) "nameSuffix" (printf "%s-syslog" $workload.name)) -}}
  {{- $_ := merge $workload.unifiedLogging.syslog.certificate (pick $cmgr "duration" "renewBefore" "subject" "commonName" "usages" "dnsNames" "uris" "ipAddresses" "privateKey" ) -}}
  {{- if not (hasKey $workload.unifiedLogging.syslog.certificate "enabled") -}}
    {{ $_ := set $workload.unifiedLogging.syslog.certificate "enabled" true -}}
  {{- end -}}
{{- end -}}

{{/* add issuerRef per HBP 3.7.0 */}}
{{- $_ := merge .Values.global (dict "certManager" (dict "issuerRef" (dict))) -}}
{{- $_ := merge .Values (dict "certManager" (dict "issuerRef" (dict))) -}}

{{/* Set default value for istio.mtls.enabled and istio.permissive  */}}
{{- if not ( hasKey .Values.istio "mtls" ) -}}
  {{- $_ := merge .Values (dict "istio" (dict "mtls" (dict "enabled" true ))) -}}
{{- end -}}
{{- if not ( hasKey .Values.istio "permissive" ) -}}
  {{- $_ := merge .Values (dict "istio" (dict "permissive" false )) -}}
{{- end -}}

{{- end -}}

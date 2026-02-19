{{- define "crdb-redisio.values-compat" -}}
{{/*

This file contains some default values structure to help in upgrade scenarios.

When --reuse-values is used on upgrade, any newly added values in the packaged values.yaml
file are not included, which can cause logic errors in the rendering of the new version of the chart.
This file provides a place for altering the .Values dictionary to help in these cases.  Typically
this will be used to merge sub-dictionaries onto the .Values to inject default values where none exist.

*** Important *** 
Helm seems to process .yaml files in reverse-alpha order.  Therefore the merge of these values are not
available to files that come after this file lexographically or is a subdirectory (e.g., tests/)

*/}}

{{- if not (hasKey .Values.server "metrics") -}}
  {{- $_ := merge .Values (dict "server" (dict "metrics" (dict "enabled" true))) -}}
  {{- $_ := merge .Values (dict "server" (dict "metrics" (dict "image" (dict "name" "oliver006/redis_exporter" "tag" "v1.0.0" "pullPolicy" "IfNotPresent")))) -}}
  {{- $_ := merge .Values (dict "server" (dict "metrics" (dict "annotations" (dict "prometheus.io/scrape" "true" "prometheus.io/port" "9121")))) -}}
  {{- $_ := merge .Values (dict "server" (dict "metrics" (dict "resources" (dict "requests" (dict "memory" "64Mi" "cpu" "250m"))))) -}}
{{- end -}}

{{- if not (hasKey .Values.sentinel "metrics") -}}
  {{- $_ := merge .Values (dict "sentinel" (dict "metrics" (dict "enabled" true))) -}}
  {{- $_ := merge .Values (dict "sentinel" (dict "metrics" (dict "image" (dict)))) -}}
  {{- $_ := merge .Values (dict "sentinel" (dict "metrics" (dict "resources" (dict "requests" (dict "memory" "64Mi" "cpu" "250m"))))) -}}
{{- end -}}

{{- $mEnabled := .Values.server.metrics.enabled -}}
{{- if not (hasKey .Values.server "dashboard") -}}
  {{- $_ := merge .Values (dict "server" (dict "dashboard" (dict "enabled" $mEnabled "label" (dict "grafana_dashboard" "yes")))) -}}
{{- end -}}

{{/* Set default for new values, including cluster and admin daemon pod and clusterDomain, v5.4.0 */}}
{{- if not (hasKey .Values "cluster") -}}
  {{- $_ := merge .Values (dict "cluster" (dict "enabled" false "shardSize" 2 "confInclude" "")) -}}
{{- end -}}
{{- $_ := merge .Values (dict "services" (dict "admin" (dict "type" "ClusterIP"))) -}}
{{- if not (hasKey .Values.admin "persistence") -}}
  {{- $_ := merge .Values (dict "admin" (dict "persistence" (dict "enabled" true "accessMode" "ReadWriteOnce" "size" "1Gi"))) -}}
{{- end -}}
{{- $_ := merge .Values (dict "admin" (dict "postInstallTimeout" "900" "preUpgradeTimeout" "180" "postUpgradeTimeout" "1800" "preDeleteTimeout" "120" "postDeleteTimeout" "180")) -}}
{{- if not (hasKey .Values.admin "nodeAffinity") -}}
  {{- $_ := merge .Values (dict "admin" (dict "nodeAffinity" (dict "enabled" true "key" "is_worker" "value" true))) -}}
  {{- $_ := merge .Values (dict "clusterDomain" "cluster.local" )}}
{{- end -}}
{{/* Istio added, v5.5.2 */}}
{{- if not (hasKey .Values "istio") -}}
  {{- $_ := merge .Values (dict "istio" (dict "enabled" false)) -}}
{{- end -}}
{{/* Cluster audit and timers added, v5.6.4 */}}
{{- if not (hasKey .Values.cluster "audit") -}}
  {{- $_ := merge .Values (dict "cluster" (dict "audit" (dict "timers" (dict "no_action_time" 300 "resched_label_time" 30)))) -}}
{{- end -}}
{{/* metrics usePodServices added, v5.7.2 */}}
{{- if not (hasKey .Values.server.metrics "usePodServices") -}}
  {{- $_ := merge .Values (dict "server" (dict "metrics" (dict "usePodServices" false))) -}}
{{- end -}}
{{/* scale-in requires much higher default timeout, v5.7.3 */}}
{{- if eq (toString .Values.admin.preUpgradeTimeout) "180" -}}
  {{- $_ := merge .Values (dict "admin" (dict "preUpgradeTimeout" "1800")) -}}
{{- end -}}
{{- if eq (toString .Values.admin.preUpgradeActiveDeadlineSeconds) "180" -}}
  {{- $_ := merge .Values (dict "admin" (dict "preUpgradeActiveDeadlineSeconds" "1800")) -}}
{{- end -}}

{{/* Added required hooks Values object to support upgrade from pre-v5.4 */}}
{{- if not (hasKey .Values "hooks") -}}
  {{- $_ := merge .Values (dict "hooks" (dict "deletePolicy" "hook-succeeded,before-hook-creation")) -}}
{{- end -}}

{{- if not (hasKey .Values.cluster "audit") -}}
  {{- $_ := merge .Values (dict "cluster" (dict "audit" (dict "timers" (dict "no_action_time" 300 "resched_label_time" 30)))) -}}
{{- end -}}

{{/* New acl/user structure in v6.0.0, carry-forward old single-user to default user */}}
{{- if or (not (hasKey .Values "systemUsers")) (semverCompare "<6.0" (toString (default "6.0.0" .Values.migrateFromChartVersion))) -}}
  {{- $_ := merge .Values (dict "systemUsers" (dict "metrics" "default")) -}}
  {{/* Need to force these users to be default to ensure migration retains connectivity between old/new */}}
  {{- $_ := set .Values.systemUsers "tools" "default" -}}
  {{- $_ := set .Values.systemUsers "probe" "default" -}}
  {{- $_ := set .Values.systemUsers "sentinel" "default" -}}
  {{- $_ := set .Values.systemUsers "replication" "default" -}}

  {{/* Setup acl */}}
  {{- $old_secret_name := include "csf-common-lib.v3.resourceName" (tuple . "secret" "redis-secrets") -}}
  {{- $common_password := index (index (lookup "v1" "Secret" .Release.Namespace $old_secret_name) "data") "redis-password" | default "none" -}}
  {{- $_ := merge .Values (dict "common" (dict "password" $common_password)) -}}
  {{- $_ := merge .Values (dict "acl" (dict "default" (dict "enabled" true "password" .Values.common.password))) -}}

  {{/* Migration need to forcefully enable default user rules for migration,
       but still allow installer to set more-restrictive, if needed */}}
  {{- if contains "off" (default "off" .Values.acl.default.rules) -}}
    {{- $_ := set .Values.acl.default "rules" "on +@all ~*" -}}
  {{- end -}}
{{- end -}}

{{/* groupName moved in v6.0.0 */}}
{{- if hasKey .Values "common" -}}
  {{- $_ := merge .Values (dict "groupName" (index .Values.common "groupName")) -}}
{{- end -}}

{{/* livenessProbe/readinessProbe exposed via Values in v6.0.1 */}}
{{- $_ := merge .Values (dict "server" (dict "readinessProbe" (dict) "livenessProbe" (dict))) -}}
{{- $_ := merge .Values (dict "sentinel" (dict "readinessProbe" (dict) "livenessProbe" (dict))) -}}
{{- $_ := merge .Values (dict "admin" (dict "readinessProbe" (dict) "livenessProbe" (dict))) -}}
{{/* added support for admin.pre/postRestoreTimeout */}}
{{- $_ := merge .Values (dict "admin" (dict "preRestoreTimeout" "600" "postRestoreTimeout" "1800")) -}}

{{/* Auto-backup on Upgrade via CBUR added in v6.0.3 */}}
{{- $_ := merge .Values (dict "cbur" (dict "backup" (dict "upgrade" false "timeout" 900))) -}}
{{- $_ := merge .Values (dict "cbur" (dict "service" (dict "namespace" "ncms" "name" "cbur-master-cbur" "protocol" "http"))) -}}

{{/* TLS added in v6.0.5 */}}
{{- $_ := merge .Values (dict "tls" (dict "enabled" false "certificates" (dict))) -}}
{{- if not (hasKey .Values.tls "authClients") -}}
  {{- $_ := merge .Values (dict "tls" (dict "authClients" true)) -}}
{{- end -}}
{{- $_ := merge .Values (dict "tls" (dict "certificates" (dict "server" (dict "source" "cmgr" "secret" "" "caCert" "ca.crt" "cert" "tls.crt" "key" "tls.key")))) -}}
{{- $_ := merge .Values (dict "tls" (dict "certificates" (dict "client" (dict "source" "cmgr" "secret" "" "caCert" "ca.crt" "cert" "tls.crt" "key" "tls.key")))) -}}
{{- $_ := merge .Values (dict "tls" (dict "certificates" (dict "certManager" (dict "apiVersion" "cert-manager.io/v1alpha3" "duration" "8760h" "renewBefore" "360h" "commonName" "" "caIssuer" (dict) "dnsNames" (list) "ipAddresses" (list) "uris" (list))))) -}}
{{- $_ := merge .Values (dict "tls" (dict "certificates" (dict "certManager" (dict "caIssuer" (dict "name" "ncms-ca-issuer" "kind" "ClusterIssuer" "group" "cert-manager.io"))))) -}}

{{/* rbacEnabled moved to rbac.enabled for HBP in v6.1.0 */}}
{{- if hasKey .Values "rbacEnabled" -}}
  {{- $_ := merge .Values (dict "rbac" (dict "enabled" .Values.rbacEnabled)) -}}
{{- end -}}
{{/* istio Values expanded for HBP in v6.1.0 */}}
{{- $_ := merge .Values (dict "istio" .Values.global.istio) -}}
{{- $_ := merge .Values (dict "istio" (dict "cni" (dict "enabled" false) "mtls" (dict) "permissive" false "createDrForClient" false)) -}}
{{- if not (hasKey .Values.istio.mtls "enabled") -}}
  {{- $_ := merge .Values.istio.mtls (dict "enabled" true) -}}
{{- end -}}
{{/* refactor of hooks/Jobs Values in v6.1.0 */}}
{{- range $j,$to := dict "preInstallJob" 120 "postInstallJob" 900 "preUpgradeJob" 1800 "postUpgradeJob" 1800 "preRollbackJob" 180 "postRollbackJob" 600 "preDeleteJob" 120 "postDeleteJob" 180 "preRestoreJob" 180 "postRestoreJob" 180 -}}
  {{/* migrate old admin.*Timeout values */}}
  {{- $_ := merge $.Values (dict "hooks" (dict $j (dict "timeout" (default $to (index $.Values.admin (replace "Job" "Timeout" $j)))))) -}}
  {{/* carefully merge boolean */}}
  {{- if not (hasKey (index $.Values.hooks $j) "enabled") -}}
    {{- $_ := merge $.Values (dict "hooks" (dict $j (dict "enabled" true))) -}}
  {{- end -}}
{{- end -}}
{{/* ActiveDeadlineSeconds moved to hooks in v6.1.0 */}}
{{- if hasKey .Values.admin "preUpgradeActiveDeadlineSeconds" -}}
  {{- $_ := merge .Values (dict "hooks" (dict "preUpgradeJob" (dict "activeDeadlineSeconds" .Values.admin.preUpgradeActiveDeadlineSeconds))) -}}
{{- end -}}
{{/* helm test resources added to Values in v6.1.0 */}}
{{- $_ := merge .Values (dict "tests" (dict "resources" (dict "requests" (dict "memory" "64Mi" "cpu" "100m")))) -}}
{{- $_ := merge .Values (dict "tests" (dict "resources" (dict "limits" (dict "memory" "64Mi")))) -}}
{{/* auditLogging added to Values in v6.1.0 */}}
{{- if not (hasKey .Values.server "auditLogging") -}}
  {{- $_ := merge .Values (dict "server" (dict "auditLogging" (dict "enabled" true "events" (list "auth" "permission")))) -}}
{{- end -}}
{{/* fifoPath added to Values in v6.1.0 */}}
{{- $_ := merge .Values (dict "fifoPath" "/tmp") -}}
{{/* startupProbe added in v6.1.0 */}}
{{- $_ := merge .Values (dict "server" (dict "startupProbe" (dict))) -}}
{{/* +acl needed for tools user to support password change */}}
{{- $tools_rules := index (index .Values.acl .Values.systemUsers.tools) "rules" -}}
{{- if and (not (contains "+acl" $tools_rules)) (not (contains "+@all" $tools_rules)) -}}
  {{- $tools_modrules := printf "%s +acl" $tools_rules -}}
{{- $_ := set (index .Values.acl .Values.systemUsers.tools) "rules" $tools_modrules -}}
{{- end -}}
{{/* add fix in v6.1.1 */}}
{{/* +bgrewriteaof needed for tools user to support AOF persistence */}}
{{- $tools_rules := index (index .Values.acl .Values.systemUsers.tools) "rules" -}}
{{- if and (not (contains "+bgrewriteaof" $tools_rules)) (not (contains "+@all" $tools_rules)) -}}
  {{- $tools_modrules := printf "%s +bgrewriteaof" $tools_rules -}}
  {{- $_ := set (index .Values.acl .Values.systemUsers.tools) "rules" $tools_modrules -}}
{{- end -}}

{{/* Set default values for new values, v6.2.0 */}}
{{/* Pod Disruption Budgets (PDB) */}}
{{- if not (hasKey .Values.server "pdb") -}}
  {{- $_ := merge .Values (dict "server" (dict "pdb" (dict "enabled" false "minAvailable" "50%"))) -}}
{{- end -}}
{{- if not (hasKey .Values.sentinel "pdb") -}}
  {{- $_ := merge .Values (dict "sentinel" (dict "pdb" (dict "enabled" false "minAvailable" "50%"))) -}}
{{- end -}}
{{- if not (hasKey .Values.admin "pdb") -}}
  {{- $_ := merge .Values (dict "admin" (dict "pdb" (dict "enabled" false "maxUnavailable" "100%"))) -}}
{{- end -}}

{{/* timezone section of Values moved to timeZone and mounts removed in v7.1.0 */}}
{{- if not (hasKey .Values "timeZone") -}}
  {{- if hasKey .Values "timezone" -}}
    {{- $_ := merge .Values (dict "timeZone" (dict "timeZoneEnv" .Values.timezone.timeZoneEnv)) -}}
  {{- else -}}
    {{- $_ := merge .Values (dict "timeZone" (dict "timeZoneEnv" "")) -}}
  {{- end -}}
{{- end -}}
{{/* rbac.psp.create added in v7.1.0 */}}
{{- if not (hasKey .Values.rbac "psp") -}}
  {{- $_ := merge .Values.rbac (dict "psp" (dict "create" true)) -}}
{{- end -}}
{{/* rolemon.livenessProbe added in v7.1.0 */}}
{{- $_ := merge .Values.rolemon (dict "livenessProbe" (dict)) -}}
{{- $_ := merge .Values.rolemon.livenessProbe (dict "initialDelaySeconds" 180) -}}
{{- $_ := merge .Values.rolemon.livenessProbe (dict "periodSeconds" 60) -}}
{{- $_ := merge .Values.rolemon.livenessProbe (dict "timeoutSeconds" 5) -}}
{{- $_ := merge .Values.rolemon.livenessProbe (dict "failureThreshold" 6) -}}
{{- $_ := merge .Values.rolemon.livenessProbe (dict "successThreshold" 1) -}}

{{/* +acl needed for metrics user in v7.2.0 */}}
{{- $metrics_rules := index (index .Values.acl .Values.systemUsers.metrics) "rules" -}}
{{- if eq "on +info" $metrics_rules -}}
  {{- $new_rules := "on +client +ping +info +config|get +cluster|info +slowlog +latency +memory +select +get +scan +xinfo +type +pfcount +strlen +llen +scard +zcard +hlen +xlen +eval allkeys" -}}
  {{- $_ := set (index .Values.acl .Values.systemUsers.metrics) "rules" $new_rules -}}
{{- end -}}
{{/* test Job refactored in v7.2.0 */}}
{{- if not (hasKey .Values.hooks "testJob") -}}
  {{- $_ := merge .Values.hooks (dict "testJob" (dict "enabled" true "backoffLimit" 0 "timeout" 300)) -}}
{{- end -}}

{{/* added services.server in v7.3.0 */}}
{{- $_ := merge .Values.services (dict "server" (dict)) -}}
{{/* moved metrics ports from *.metrics.port to services.*.exporter.port in v7.3.0 */}}
{{- $_ := merge .Values.services.server (dict "exporter" (dict "port" .Values.server.metrics.port)) -}}
{{- $_ := merge .Values.services.sentinel (dict "exporter" (dict "port" .Values.sentinel.metrics.port)) -}}
{{/* added ephemeral-storage resource settings in v7.3.0 */}}
{{- $_ := merge .Values.server.resources (dict "requests" (dict "ephemeral-storage" "1Gi")) -}}
{{- $_ := merge .Values.server.resources (dict "limits" (dict "ephemeral-storage" "1Gi")) -}}
{{- $_ := merge .Values.server.metrics.resources (dict "requests" (dict "ephemeral-storage" "64Mi")) -}}
{{- $_ := merge .Values.server.metrics.resources (dict "limits" (dict "ephemeral-storage" "64Mi")) -}}
{{- $_ := merge .Values.sentinel.resources (dict "requests" (dict "ephemeral-storage" "64Mi")) -}}
{{- $_ := merge .Values.sentinel.resources (dict "limits" (dict "ephemeral-storage" "64Mi")) -}}
{{- $_ := merge .Values.sentinel.metrics.resources (dict "requests" (dict "ephemeral-storage" "64Mi")) -}}
{{- $_ := merge .Values.sentinel.metrics.resources (dict "limits" (dict "ephemeral-storage" "64Mi")) -}}
{{- $_ := merge .Values.rolemon.resources (dict "requests" (dict "ephemeral-storage" "64Mi")) -}}
{{- $_ := merge .Values.rolemon.resources (dict "limits" (dict "ephemeral-storage" "64Mi")) -}}
{{- $_ := merge .Values.admin.resources (dict "requests" (dict "ephemeral-storage" "256Mi")) -}}
{{- $_ := merge .Values.admin.resources (dict "limits" (dict "ephemeral-storage" "256Mi")) -}}
{{- $_ := merge .Values.tests.resources (dict "requests" (dict "ephemeral-storage" "64Mi")) -}}
{{- $_ := merge .Values.tests.resources (dict "limits" (dict "ephemeral-storage" "64Mi")) -}}

{{/* added cbur.apiVersion and cbur.brPolicy in v7.4.0 */}}
{{- $_ := merge .Values.cbur (dict "apiVersion" "cbur.csf.nokia.com/v1") -}}
{{- $_ := merge .Values.cbur (dict "brPolicy" (dict "weight" 0 "cronSpec" "0 0 * * *" "maxiCopy" 5)) -}}
{{- $_ := merge .Values.cbur (dict "brPolicy" (dict "autoEnableCron" false "autoUpdateCron" false)) -}}
{{- $_ := merge .Values.cbur (dict "brPolicy" (dict "backend" .Values.cbur.backend)) -}}

{{/* backwards-compatibility and support for mixed BrPolicy/BrHook apiVersions in v7.4.1 */}}
{{- if not (.Capabilities.APIVersions.Has (printf "%s/BrPolicy" .Values.cbur.apiVersion)) -}}
{{- $_ := merge .Values.cbur.brPolicy (dict "apiVersion" "cbur.bcmt.local/v1") -}}
{{- end -}}

{{/* enabling metrics for sentinel, v7.5.0 */}}
{{- if not (hasKey .Values.sentinel.metrics "annotations") -}}
  {{- $_ := merge .Values.sentinel.metrics (dict "annotations" (dict "prometheus.io/scrape" "true" "prometheus.io/port" "9121")) -}}
{{- end -}}
{{- if not (hasKey .Values.sentinel.metrics "usePodServices") -}}
  {{- $_ := merge .Values.sentinel.metrics (dict "usePodServices" false) -}}
{{- end -}}

{{/* CBUR ephemeral-storage requirements updated in v7.5.0 */}}
{{- $pvcSize := .Values.server.persistence.size -}}
{{- $unit := regexSplit "[0-9]+" $pvcSize 2 | last -}}
{{- $dblPvcSize := printf "%d%s" (trimSuffix $unit $pvcSize | mul 2) $unit -}}
{{- $_ := merge .Values.cbur.resources (dict "requests" (dict "ephemeral-storage" $pvcSize)) -}}
{{- $_ := merge .Values.cbur.resources (dict "limits" (dict "ephemeral-storage" $dblPvcSize)) -}}
{{/* +debug needed for tools user to support fix during cluster operations */}}
{{- $tools_rules := index (index .Values.acl .Values.systemUsers.tools) "rules" -}}
{{- if and (not (contains "+debug" $tools_rules)) (not (contains "+@all" $tools_rules)) -}}
  {{- $tools_modrules := printf "%s +debug" $tools_rules -}}
{{- $_ := set (index .Values.acl .Values.systemUsers.tools) "rules" $tools_modrules -}}
{{- end -}}
{{/* added defaults in v7.5.0 */}}
{{- $_ := merge .Values.server (dict "terminationGracePeriodSeconds" 120) -}}
{{- $_ := merge .Values (dict "imageFlavor" "rocky8") -}}
{{- $_ := merge .Values.rbac (dict "scc" (dict "create" false)) -}}

{{/* defaults for unifiedLogging */}}
{{- $_ := merge .Values (dict "global" (dict "unifiedLogging" (dict "extension" (dict) "syslog" (dict "enabled" nil "host" "" "port" "" "protocol" "" "keyStore" (dict) "keyStorePassword" (dict) "trustStore" (dict) "trustStorePassword" (dict))))) -}}
{{- $_ := merge .Values (dict "unifiedLogging" (dict "extension" (dict) "syslog" (dict "enabled" nil "host" "" "port" "" "protocol" "" "keyStore" (dict) "keyStorePassword" (dict) "trustStore" (dict) "trustStorePassword" (dict)))) -}}

{{/* undo image tags retained in Release Values by v7.5.0 - fixed in v7.5.1 */}}
{{- if eq (default "" .Values.sentinel.image.tag) "4.5-1.3059" -}}
  {{- $_ := unset .Values.sentinel.image "tag" -}}
{{- end -}}
{{- if eq (default "" .Values.rolemon.image.tag) "4.5-1.3059" -}}
  {{- $_ := unset .Values.rolemon.image "tag" -}}
{{- end -}}
{{- if eq (default "" .Values.admin.image.tag) "4.5-1.3059" -}}
  {{- $_ := unset .Values.admin.image "tag" -}}
{{- end -}}

{{/* extra acls needed for sentinel-user in redis7 - v8.0.0 */}}
{{- if (hasKey (index .Values.acl .Values.systemUsers.sentinel) "rules") -}}
  {{- $sentinel_rules := index (index .Values.acl .Values.systemUsers.sentinel) "rules" -}}
  {{- if $sentinel_rules -}}
    {{- if not (contains "allchannels" $sentinel_rules)}}
      {{- $sentinel_modrules := printf "%s allchannels" $sentinel_rules -}}
      {{- $_ := set (index .Values.acl .Values.systemUsers.sentinel) "rules" $sentinel_modrules -}}
    {{- end -}}
    {{- $sentinel_rules := index (index .Values.acl .Values.systemUsers.sentinel) "rules" -}}
    {{- if not (contains "+role" $sentinel_rules)}}
      {{- $sentinel_modrules := printf "%s +role" $sentinel_rules -}}
      {{- $_ := set (index .Values.acl .Values.systemUsers.sentinel) "rules" $sentinel_modrules -}}
    {{- end -}}
    {{- if not (contains "+script|kill" $sentinel_rules)}}
      {{- $sentinel_modrules := printf "%s +script|kill" $sentinel_rules -}}
      {{- $_ := set (index .Values.acl .Values.systemUsers.sentinel) "rules" $sentinel_modrules -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/* extra acls needed for crdb-tools-user in redis7 - v8.0.0 */}}
{{- if (hasKey (index .Values.acl .Values.systemUsers.tools) "rules") -}}
  {{- $tools_rules := index (index .Values.acl .Values.systemUsers.tools) "rules" -}}
  {{- if $tools_rules -}}
    {{- if not (contains "+function" $tools_rules)}}
      {{- $tools_modrules := printf "%s +function" $tools_rules -}}
      {{- $_ := set (index .Values.acl .Values.systemUsers.tools) "rules" $tools_modrules -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/* default new pvcless related values */}}
{{- if not (hasKey .Values.server.persistence "enabled") -}}
  {{- $_ := merge .Values.server.persistence (dict "enabled" true) -}}
{{- end -}}
{{- if not (hasKey .Values.cluster "masterRestartDelay") -}}
  {{- $_ := set .Values.cluster "masterRestartDelay" 10 }}
{{- end -}}

{{/* +module|list needed for probe user to allow helm test for module consistency - added in v8.0.2 */}}
{{- $probe_rules := index (index .Values.acl .Values.systemUsers.probe) "rules" -}}
{{- if and (not (contains "+module" $probe_rules)) (not (contains "+@all" $probe_rules)) -}}
  {{- $probe_modrules := printf "%s +module|list" $probe_rules -}}
{{- $_ := set (index .Values.acl .Values.systemUsers.probe) "rules" $probe_modrules -}}
{{- end -}}

{{/* add global and root level certManager - v8.1.0 */}}
{{- $_ := merge .Values.global (dict "certManager" (dict)) -}}
{{- $_ := merge .Values (dict "certManager" (dict)) -}}
{{/* new certManager.enabled - set from deprecated tls.certificates.server.source - v8.1.0 */}}
{{- if not (hasKey .Values.certManager "enabled") -}}
  {{- $_ := set .Values.certManager "enabled" (eq "cmgr" .Values.tls.certificates.server.source) -}}
{{- end -}}

{{/* add workload.tls.enabled override - v8.1.0 */}}
{{ $_ := merge .Values.server (dict "tls" (dict)) -}}
{{ $_ := merge .Values.sentinel (dict "tls" (dict)) -}}
{{- if not (hasKey .Values.server.tls "enabled") -}}
  {{- $_ := merge .Values (dict "server" (dict "tls" (dict "enabled"))) -}}
{{- end -}}
{{- if not (hasKey .Values.sentinel.tls "enabled") -}}
  {{- $_ := merge .Values (dict "sentinel" (dict "tls" (dict "enabled"))) -}}
{{- end -}}

{{/* add clients (certificates) - v8.1.0 */}}
{{ $_ := merge .Values (dict "clients" (dict "internal" (dict "tls" (dict)))) -}}

{{/* added workload.nameSuffix for common-lib utils - v8.1.0 */}}
{{ $_ := merge .Values (dict "server" (dict "nameSuffix" "server")) -}}
{{ $_ := merge .Values (dict "sentinel" (dict "nameSuffix" "sentinel")) -}}
{{ $_ := merge .Values (dict "clients" (dict "internal" (dict "nameSuffix" "client-internal"))) -}}
{{- range $n, $v := .Values.clients }}{{ $_ := merge $v (dict "nameSuffix" (printf "client-%s" $n)) }}{{ end -}}

{{/* moved tls.certificates.certManager to workload tls certificate - v8.1.0 */}}
{{- $_gn := include "crdb-redisio.groupname" . -}}
{{- $cmgr := .Values.tls.certificates.certManager -}}
{{- $_ := merge .Values.server (dict "certificate" (dict "issuerRef" $cmgr.caIssuer "nameSuffix" "server-cert")) -}}
{{/* dnsNames generated by csf-common-lib.v1.certificate append server workload suffix by default, which is incorrect in our case.  Ref: CSFS-54151 */}}
{{- $_svrNames := list "localhost" -}}
{{- $_svrNames = append $_svrNames (printf "%s.%s" $_gn .Release.Namespace) -}}
{{- $_svrNames = append $_svrNames (printf "%s-readonly.%s" $_gn .Release.Namespace) -}}
{{- $_svrNames = append $_svrNames (printf "%s.%s.svc" $_gn .Release.Namespace) -}}
{{- $_svrNames = append $_svrNames (printf "%s-readonly.%s.svc" $_gn .Release.Namespace) -}}
{{- $_svrNames = append $_svrNames (printf "%s.%s.svc.%s" $_gn .Release.Namespace .Values.clusterDomain) -}}
{{- $_svrNames = append $_svrNames (printf "%s-readonly.%s.svc.%s" $_gn .Release.Namespace .Values.clusterDomain) -}}
{{- $_ := merge .Values.server.certificate (dict "dnsNames" $_svrNames) -}}
{{- $_ := merge .Values.server.certificate (pick $cmgr "duration" "renewBefore" "subject" "commonName" "usages" "dnsNames" "uris" "ipAddresses" "privateKey" ) -}}
{{- if not (hasKey .Values.server.certificate "enabled") -}}
  {{ $_ := set .Values.server.certificate "enabled" (eq "cmgr" .Values.tls.certificates.server.source) -}}
{{- end -}}
{{/* note: sentinel previously used certs from server */}}
{{- $_ := merge .Values.sentinel (dict "certificate" (dict "issuerRef" $cmgr.caIssuer "nameSuffix" "server-cert")) -}}
{{/* dnsNames generated by csf-common-lib.v1.certificate append server workload suffix by default, which is incorrect in our case.  Ref: CSFS-54151 */}}
{{- $_sentNames := list "localhost" -}}
{{- $_sentNames = append $_sentNames (printf "%s-sentinel.%s" $_gn .Release.Namespace) -}}
{{- $_sentNames = append $_sentNames (printf "%s-sentinel.%s.svc" $_gn .Release.Namespace) -}}
{{- $_sentNames = append $_sentNames (printf "%s-sentinel.%s.svc.%s" $_gn .Release.Namespace .Values.clusterDomain) -}}
{{- $_ := merge .Values.sentinel.certificate (dict "dnsNames" $_sentNames) -}}
{{- $_ := merge .Values.sentinel.certificate (pick $cmgr "duration" "renewBefore" "subject" "commonName" "usages" "dnsNames" "uris" "ipAddresses" "privateKey" ) -}}
{{- if not (hasKey .Values.sentinel.certificate "enabled") -}}
  {{ $_ := set .Values.sentinel.certificate "enabled" (eq "cmgr" .Values.tls.certificates.server.source) -}}
{{- end -}}
{{/* dnsNames generated by csf-common-lib.v1.certificate append server workload suffix by default, which is incorrect in our case.  Ref: CSFS-54151 */}}
{{- $_clntNames := list "localhost" -}}
{{- $_ := merge .Values.clients.internal (dict "certificate" (dict "issuerRef" $cmgr.caIssuer "nameSuffix" "client-cert")) -}}
{{- $_ := merge .Values.clients.internal.certificate (dict "dnsNames" $_clntNames) -}}
{{- $_ := merge .Values.clients.internal.certificate (pick $cmgr "duration" "renewBefore" "subject" "commonName" "usages" "dnsNames" "uris" "ipAddresses" "privateKey" ) -}}
{{- if not (hasKey .Values.clients.internal.certificate "enabled") -}}
  {{ $_ := set .Values.clients.internal.certificate "enabled" (eq "cmgr" .Values.tls.certificates.client.source) -}}
{{- end -}}

{{/* moved tls.certificates.{client,server}.{source,secret,caCert,cert,key} to workload tls secretRef - v8.1.0 */}}
{{- $servercert := .Values.tls.certificates.server -}}
{{- $_ := merge .Values.server.tls (dict "secretRef" (dict "name" $servercert.secret)) -}}
{{- $_ := merge .Values.server.tls.secretRef (dict "keyNames" (dict "caCrt" $servercert.caCert "tlsKey" $servercert.key "tlsCrt" $servercert.cert)) -}}
{{/* note: sentinel previously used certs from server */}}
{{- $sentinelcert := .Values.tls.certificates.server -}}
{{- $_ := merge .Values.sentinel.tls (dict "secretRef" (dict "name" $sentinelcert.secret)) -}}
{{- $_ := merge .Values.sentinel.tls.secretRef (dict "keyNames" (dict "caCrt" $sentinelcert.caCert "tlsKey" $sentinelcert.key "tlsCrt" $sentinelcert.cert)) -}}
{{- $clientcert := .Values.tls.certificates.client -}}
{{- $_ := merge .Values.clients.internal.tls (dict "secretRef" (dict "name" $clientcert.secret)) -}}
{{- $_ := merge .Values.clients.internal.tls.secretRef (dict "keyNames" (dict "caCrt" $clientcert.caCert "tlsKey" $clientcert.key "tlsCrt" $clientcert.cert)) -}}

{{/* Add option to deldb on major rollback */}}
{{- if not (hasKey .Values.server "majorRollbackDelDb") -}}
  {{- $_ := set .Values.server "majorRollbackDelDb" false }}
{{- end -}}

{{/* extra acls needed for crdb-tools-user to support rollback */}}
{{- if (hasKey (index .Values.acl .Values.systemUsers.tools) "rules") -}}
  {{- $tools_rules := index (index .Values.acl .Values.systemUsers.tools) "rules" -}}
  {{- if $tools_rules -}}
    {{- if not (contains "+wait" $tools_rules)}}
      {{- $tools_modrules := printf "%s +wait" $tools_rules -}}
      {{- $_ := set (index .Values.acl .Values.systemUsers.tools) "rules" $tools_modrules -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/* higher rollback timeouts needed for major rollback support */}}
{{- if eq (toString .Values.admin.preRollbackTimeout) "180" -}}
  {{- $_ := set .Values.admin "preRollbackTimeout" 1800 -}}
{{- end -}}
{{- if eq (toString .Values.admin.postRollbackTimeout) "180" -}}
  {{- $_ := set .Values.admin "postRollbackTimeout" 1800 -}}
{{- end -}}
{{- if eq (toString .Values.hooks.preRollbackJob.timeout) "180" -}}
  {{- $_ := set .Values.hooks.preRollbackJob "timeout" 1800 -}}
{{- end -}}
{{- if eq (toString .Values.hooks.postRollbackJob.timeout) "600" -}}
  {{- $_ := set .Values.hooks.postRollbackJob "timeout" 1800 -}}
{{- end -}}

{{/* Add option for data only backup and restore */}}
{{- if not (hasKey .Values.server "dataOnlyBackupRestore") -}}
  {{- $_ := set .Values.server "dataOnlyBackupRestore" false }}
{{- end -}}

{{/* +client|setinfo needed for probe user in redis 7.2.x */}}
{{- $probe_rules := index (index .Values.acl .Values.systemUsers.probe) "rules" -}}
{{- if and (not (contains "+client|setinfo" $probe_rules)) (not (contains "+@all" $probe_rules)) -}}
  {{- $probe_modrules := printf "%s +client|setinfo" $probe_rules -}}
{{- $_ := set (index .Values.acl .Values.systemUsers.probe) "rules" $probe_modrules -}}
{{- end -}}

{{/* admin.startupProbe added in v9.0.0 */}}
{{- $_ := merge .Values (dict "admin" (dict "startupProbe" (dict))) -}}
{{/* services.redis.tlsPort and .nonTlsPort added in 9.0.0, .port removed */}}
{{- $svr_tls := eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.server.tls.enabled .Values.tls.enabled .Values.global.tls false)) "true" }}
{{- $def_tls_port := $svr_tls | ternary (default 6379 .Values.services.redis.port) 0 -}}
{{- $def_nontls_port := $svr_tls | ternary 0 (default 6379 .Values.services.redis.port) -}}
{{- if and (not .Values.services.redis.tlsPort) (ne (toString .Values.services.redis.tlsPort) "0") -}}
  {{- $_ := set .Values.services.redis "tlsPort" $def_tls_port -}}
{{- end -}}
{{- if and (not .Values.services.redis.nonTlsPort) (ne (toString .Values.services.redis.nonTlsPort) "0") -}}
  {{- $_ := set .Values.services.redis "nonTlsPort" $def_nontls_port -}}
{{- end -}}
{{- $_ := set .Values.services.redis "tlsPort" (nospace (toString .Values.services.redis.tlsPort)) -}}
{{- $_ := set .Values.services.redis "nonTlsPort" (nospace (toString .Values.services.redis.nonTlsPort)) -}}
{{- $_ := set .Values.services.redis "nodePort" (nospace (toString (default "" .Values.services.redis.nodePort))) -}}
{{- $_ := set .Values.services.redis "nodePortReadOnly" (nospace (toString (default "" .Values.services.redis.nodePortReadOnly))) -}}
{{- $_ := unset .Values.services.redis "port" -}}
{{/* added workload admin.nameSuffix for common-lib utils - v9.0.0 */}}
{{ $_ := merge .Values (dict "admin" (dict "nameSuffix" "admin")) -}}
{{/* added global.istio.sidecar - v9.0.0 */}}
{{- $_ := merge .Values.global (dict "istio" (dict "sidecar" (dict "healthCheckPort" nil "stopPort" 15000))) -}}

{{/* sentinel auth added in v9.0.0 */}}
{{- $_ := merge .Values (dict "sentinel" (dict "acl" (dict "rules" (dict)))) -}}
{{- if not (hasKey .Values.sentinel.acl "enabled") -}}
  {{- $_ := set .Values.sentinel.acl "enabled" true -}}
{{- end -}}
{{- if not (hasKey .Values.sentinel.acl.rules "sentinel") -}}
  {{- $_ := set .Values.sentinel.acl.rules "sentinel" "on +@all ~* &*" -}}
{{- end -}}
{{- if not (hasKey .Values.sentinel.acl.rules "metrics") -}}
  {{- $_ := set .Values.sentinel.acl.rules "metrics" "-@all +sentinel|masters +sentinel|ckquorum +sentinel|sentinels +sentinel|slaves +info +client|setname &*" -}}
{{- end -}}

{{/* configurable socket location for rollback */}}
{{- if not (hasKey .Values.server "rollbackSocket") -}}
  {{- $_ := set .Values.server "rollbackSocket" "/tmp/redis.sock" }}
{{- end -}}

{{/* podAntiAffinity added to workloads in v9.0.3 */}}
{{- $_ := merge .Values.server (dict "podAntiAffinity" (dict "zone" (dict) "node" (dict))) -}}
{{- $_ := merge .Values.sentinel (dict "podAntiAffinity" (dict "zone" (dict) "node" (dict))) -}}

{{/* nodeAntiAffinity deprecated in favor of workload.podAntiAffinity sections in v9.0.3 */}}
{{- if hasKey .Values "nodeAntiAffinity" -}}
  {{- $_ := merge .Values.server.podAntiAffinity.zone (dict "type" "soft") -}}
  {{- $_ := merge .Values.server.podAntiAffinity.node (dict "type" (.Values.nodeAntiAffinity | default "hard")) -}}
  {{- $_ := set .Values.server.podAntiAffinity.zone "type" .Values.server.podAntiAffinity.zone.type -}}
  {{- $_ := set .Values.server.podAntiAffinity.node "type" .Values.server.podAntiAffinity.node.type -}}
  {{- $_ := merge .Values.sentinel.podAntiAffinity.zone (dict "type" "soft") -}}
  {{- $_ := merge .Values.sentinel.podAntiAffinity.node (dict "type" (.Values.nodeAntiAffinity | default "hard")) -}}
  {{- $_ := set .Values.sentinel.podAntiAffinity.zone "type" .Values.sentinel.podAntiAffinity.zone.type -}}
  {{- $_ := set .Values.sentinel.podAntiAffinity.node "type" .Values.sentinel.podAntiAffinity.node.type -}}
  {{- $_ := unset .Values "nodeAntiAffinity" -}}
{{- end -}}

{{/* added workload.name for csf-common-lib.v1.selectorLabels - v9.0.3 */}}
{{- $_ := set .Values.admin "name" "admin" -}}
{{- $_ := set .Values.sentinel "name" "sentinel" -}}
{{- $_ := set .Values.server "name" "server" -}}

{{- end -}}

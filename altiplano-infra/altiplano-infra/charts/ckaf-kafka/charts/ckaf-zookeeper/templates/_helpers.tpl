{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}

{{/*
Create a default fully qualified app name.
We truncate at maximum of 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}

{{- define "ckaf-zookeeper.name" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else if .Values.nameOverride -}}
{{- printf "ckaf-zk-%s" .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "zk-%s" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Define pod name prefix value
*/}}
{{- define "ckaf-zookeeper.podNamePrefix" -}}
{{- if or (.Values.fullnameOverride) (.Values.nameOverride) -}}
{{- printf "" -}}
{{- else -}}
{{- default "" .Values.global.podNamePrefix -}}
{{- end -}}
{{- end -}}

{{/*
Define container name prefix value
*/}}
{{- define "ckaf-zookeeper.containerNamePrefix" -}}
{{- if or (.Values.fullnameOverride) (.Values.nameOverride) -}}
{{- printf "" -}}
{{- else -}}
{{- default "" .Values.global.containerNamePrefix -}}
{{- end -}}
{{- end -}}

{{/*
Define statefulset names with podName prefix
*/}}
{{- define "ckaf-zookeeper.statefulset" -}}
{{- printf "%s%s" (include "ckaf-zookeeper.podNamePrefix" .) (include "ckaf-zookeeper.name" .)  | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}


{{/*
Define zookeeper container name value
*/}}
{{- define "ckaf-zookeeper.containerName" -}}
{{- if .Values.customResourceNames.zookeeperPod.zkContainerName -}}
{{- printf "%s%s" (include "ckaf-zookeeper.containerNamePrefix" .) .Values.customResourceNames.zookeeperPod.zkContainerName | lower | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s" (include "ckaf-zookeeper.containerNamePrefix" .) "ckaf-zookeeper-server" | lower | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Define JMX container name value
*/}}
{{- define "ckaf-zookeeper.jmxContainerName" -}}
{{- if .Values.customResourceNames.zookeeperPod.jmxContainerName -}}
{{- printf "%s%s" (include "ckaf-zookeeper.containerNamePrefix" .) .Values.customResourceNames.zookeeperPod.jmxContainerName | lower | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s" (include "ckaf-zookeeper.containerNamePrefix" .) "ckaf-zookeeper-jmx-exporter" | lower | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}


{{/*
Define job names with pod prefix
*/}}
{{- define "ckaf-zookeeper.postDeleteJobName" -}}
{{- if .Values.customResourceNames.postDeleteJob.name -}}
{{- printf "%s%s" (include "ckaf-zookeeper.podNamePrefix" .) .Values.customResourceNames.postDeleteJob.name | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-zk-postdelete-job" (include "ckaf-zookeeper.podNamePrefix" .) (include "ckaf-zookeeper.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-zookeeper.postRollBackJobName" -}}
{{- if .Values.customResourceNames.postRollBackJob.name -}}
{{- printf "%s%s" (include "ckaf-zookeeper.podNamePrefix" .) .Values.customResourceNames.postRollBackJob.name | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-zk-postrollback-job" (include "ckaf-zookeeper.podNamePrefix" .) (include "ckaf-zookeeper.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-zookeeper.preHealJobName" -}}
{{- if .Values.customResourceNames.preHealJob.name -}}
{{- printf "%s%s" (include "ckaf-zookeeper.podNamePrefix" .) .Values.customResourceNames.preHealJob.name | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-zk-preheal-job" (include "ckaf-zookeeper.podNamePrefix" .) (include "ckaf-zookeeper.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-zookeeper.preUpgradeJobName" -}}
{{- if .Values.customResourceNames.preUpgradeJob.name -}}
{{- printf "%s%s" (include "ckaf-zookeeper.podNamePrefix" .) .Values.customResourceNames.preUpgradeJob.name | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-zk-preupgrade-job" (include "ckaf-zookeeper.podNamePrefix" .) (include "ckaf-zookeeper.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-zookeeper.postScaleInJobName" -}}
{{- if .Values.customResourceNames.postScaleInJob.name -}}
{{- printf "%s%s" (include "ckaf-zookeeper.podNamePrefix" .) .Values.customResourceNames.postScaleInJob.name | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-zk-postscalein-job" (include "ckaf-zookeeper.podNamePrefix" .) (include "ckaf-zookeeper.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-zookeeper.postScaleOutJobName" -}}
{{- if .Values.customResourceNames.postScaleOutJob.name -}}
{{- printf "%s%s" (include "ckaf-zookeeper.podNamePrefix" .) .Values.customResourceNames.postScaleOutJob.name | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-zk-postscaleout-job" (include "ckaf-zookeeper.podNamePrefix" .) (include "ckaf-zookeeper.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-zookeeper.preRollBackJobName" -}}
{{- if .Values.customResourceNames.preRollBackJob.name -}}
{{- printf "%s%s" (include "ckaf-zookeeper.podNamePrefix" .) .Values.customResourceNames.preRollBackJob.name | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-zk-prerollback-job" (include "ckaf-zookeeper.podNamePrefix" .) (include "ckaf-zookeeper.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-zookeeper.postRestoreJobName" -}}
{{- if .Values.customResourceNames.postRestoreJob.name -}}
{{- printf "%s%s" (include "ckaf-zookeeper.podNamePrefix" .) .Values.customResourceNames.postRestoreJob.name | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-zk-postrestore-job" (include "ckaf-zookeeper.podNamePrefix" .) (include "ckaf-zookeeper.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-zookeeper.preRestoreJobName" -}}
{{- if .Values.customResourceNames.preRestoreJob.name -}}
{{- printf "%s%s" (include "ckaf-zookeeper.podNamePrefix" .) .Values.customResourceNames.preRestoreJob.name | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-zk-prerestore-job" (include "ckaf-zookeeper.podNamePrefix" .) (include "ckaf-zookeeper.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}


{{- define "ckaf-zookeeper.postHealJobName" -}}
{{- if .Values.customResourceNames.postHealJob.name -}}
{{- printf "%s%s" (include "ckaf-zookeeper.podNamePrefix" .) .Values.customResourceNames.postHealJob.name | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-zk-postheal-job" (include "ckaf-zookeeper.podNamePrefix" .) (include "ckaf-zookeeper.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-zookeeper.postUpgradeJobName" -}}
{{- if .Values.customResourceNames.postUpgradeJob.name -}}
{{- printf "%s%s" (include "ckaf-zookeeper.podNamePrefix" .) .Values.customResourceNames.postUpgradeJob.name | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-zk-postupgrade-job" (include "ckaf-zookeeper.podNamePrefix" .) (include "ckaf-zookeeper.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}


{{- define "ckaf-zookeeper.preScaleInJobName" -}}
{{- if .Values.customResourceNames.preScaleInJob.name -}}
{{- printf "%s%s" (include "ckaf-zookeeper.podNamePrefix" .) .Values.customResourceNames.preScaleInJob.name | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-zk-prescalein-job" (include "ckaf-zookeeper.podNamePrefix" .) (include "ckaf-zookeeper.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-zookeeper.postUpgradeScaleJobName" -}}
{{- if .Values.customResourceNames.postUpgradeScaleJob.name -}}
{{- printf "%s%s" (include "ckaf-zookeeper.podNamePrefix" .) .Values.customResourceNames.postUpgradeScaleJob.name | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-zk-postupgradescale-job" (include "ckaf-zookeeper.podNamePrefix" .) (include "ckaf-zookeeper.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-zookeeper.preRollBackScaleJobName" -}}
{{- if .Values.customResourceNames.preRollBackScaleJob.name -}}
{{- printf "%s%s" (include "ckaf-zookeeper.podNamePrefix" .) .Values.customResourceNames.preRollBackScaleJob.name | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-zk-prerollbackscale-job" (include "ckaf-zookeeper.podNamePrefix" .) (include "ckaf-zookeeper.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-zookeeper.preUpgradeScaleJobName" -}}
{{- if .Values.customResourceNames.preUpgradeScaleJob.name -}}
{{- printf "%s%s" (include "ckaf-zookeeper.podNamePrefix" .) .Values.customResourceNames.preUpgradeScaleJob.name | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-zk-preupgradescale-job" (include "ckaf-zookeeper.podNamePrefix" .) (include "ckaf-zookeeper.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-zookeeper.helmTestJobName" -}}
{{- if .Values.customResourceNames.helmTest.name -}}
{{- printf "%s%s" (include "ckaf-zookeeper.podNamePrefix" .) .Values.customResourceNames.helmTest.name | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-zk-testpod-status" (include "ckaf-zookeeper.podNamePrefix" .) (include "ckaf-zookeeper.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-zookeeper.podDisruptionBudgetJobName" -}}
{{- if .Values.customResourceNames.podDisruptionBudget.name -}}
{{- printf "%s%s" (include "ckaf-zookeeper.podNamePrefix" .) .Values.customResourceNames.podDisruptionBudget.name | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s" (include "ckaf-zookeeper.podNamePrefix" .) (include "ckaf-zookeeper.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}


{{/*
Define job container names with containerName prefix
*/}}
{{- define "ckaf-zookeeper.postDeleteJobContainerName" -}}
{{- if .Values.customResourceNames.postDeleteJob.containerName -}}
{{- printf "%s%s" (include "ckaf-zookeeper.containerNamePrefix" .) .Values.customResourceNames.postDeleteJob.containerName| trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-zk-postdel" (include "ckaf-zookeeper.containerNamePrefix" .) (include "ckaf-zookeeper.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}} 


{{- define "ckaf-zookeeper.postRollBackJobContainerName" -}}
{{- if .Values.customResourceNames.postRollBackJob.containerName -}}
{{- printf "%s%s" (include "ckaf-zookeeper.containerNamePrefix" .) .Values.customResourceNames.postRollBackJob.containerName | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-zk-postrollback" (include "ckaf-zookeeper.containerNamePrefix" .) (include "ckaf-zookeeper.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-zookeper.preHealJobContainerName" -}}
{{- if .Values.customResourceNames.preHealJob.containerName -}}
{{- printf "%s%s" (include "ckaf-zookeeper.containerNamePrefix" .) .Values.customResourceNames.preHealJob.containerName | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-zk-preheal" (include "ckaf-zookeeper.containerNamePrefix" .) (include "ckaf-zookeeper.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-zookeeper.preUpgradeJobContainerName" -}}
{{- if .Values.customResourceNames.preUpgradeJob.containerName -}}
{{- printf "%s%s" (include "ckaf-zookeeper.containerNamePrefix" .) .Values.customResourceNames.preUpgradeJob.containerName | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-zk-preupgrade" (include "ckaf-zookeeper.containerNamePrefix" .) (include "ckaf-zookeeper.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-zookeper.postScaleInJobContainerName" -}}
{{- if .Values.customResourceNames.postScaleInJob.containerName -}}
{{- printf "%s%s" (include "ckaf-zookeeper.containerNamePrefix" .) .Values.customResourceNames.postScaleInJob.containerName | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-zk-postscalein" (include "ckaf-zookeeper.containerNamePrefix" .) (include "ckaf-zookeeper.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-zookeeper.postScaleOutJobContainerName" -}}
{{- if .Values.customResourceNames.postScaleOutJob.containerName -}}
{{- printf "%s%s" (include "ckaf-zookeeper.containerNamePrefix" .) .Values.customResourceNames.postScaleOutJob.containerName | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-zk-postscaleout" (include "ckaf-zookeeper.containerNamePrefix" .) (include "ckaf-zookeeper.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-zookeeper.preRollBackJobContainerName" -}}
{{- if .Values.customResourceNames.preRollBackJob.containerName -}}
{{- printf "%s%s" (include "ckaf-zookeeper.containerNamePrefix" .) .Values.customResourceNames.preRollBackJob.containerName | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-zk-prerollback" (include "ckaf-zookeeper.containerNamePrefix" .) (include "ckaf-zookeeper.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-zookeeper.postRestoreJobContainerName" -}}
{{- if .Values.customResourceNames.postRestoreJob.containerName -}}
{{- printf "%s%s" (include "ckaf-zookeeper.containerNamePrefix" .) .Values.customResourceNames.postRestoreJob.containerName | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-zk-postrestore" (include "ckaf-zookeeper.containerNamePrefix" .) (include "ckaf-zookeeper.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-zookeeper.preRestoreJobContainerName" -}}
{{- if .Values.customResourceNames.preRestoreJob.containerName -}}
{{- printf "%s%s" (include "ckaf-zookeeper.containerNamePrefix" .) .Values.customResourceNames.preRestoreJob.containerName | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-zk-prerestore" (include "ckaf-zookeeper.containerNamePrefix" .) (include "ckaf-zookeeper.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-zookeeper.postHealJobContainerName" -}}
{{- if .Values.customResourceNames.postHealJob.containerName -}}
{{- printf "%s%s" (include "ckaf-zookeeper.containerNamePrefix" .) .Values.customResourceNames.postHealJob.containerName | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-zk-postheal" (include "ckaf-zookeeper.containerNamePrefix" .) (include "ckaf-zookeeper.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-zookeeper.postUpgradeJobContainerName" -}}
{{- if .Values.customResourceNames.postUpgradeJob.containerName -}}
{{- printf "%s%s" (include "ckaf-zookeeper.containerNamePrefix" .) .Values.customResourceNames.postUpgradeJob.containerName | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-zk-postupgrade" (include "ckaf-zookeeper.containerNamePrefix" .) (include "ckaf-zookeeper.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}


{{- define "ckaf-zookeeper.preScaleInJobContainerName" -}}
{{- if .Values.customResourceNames.preScaleInJob.containerName -}}
{{- printf "%s%s" (include "ckaf-zookeeper.containerNamePrefix" .) .Values.customResourceNames.preScaleInJob.containerName | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-zk-prescalein" (include "ckaf-zookeeper.containerNamePrefix" .) (include "ckaf-zookeeper.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-zookeeper.postUpgradeScaleJobContainerName" -}}
{{- if .Values.customResourceNames.postUpgradeScaleJob.containerName -}}
{{- printf "%s%s" (include "ckaf-zookeeper.containerNamePrefix" .) .Values.customResourceNames.postUpgradeScaleJob.containerName | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-zk-postupgradescale" (include "ckaf-zookeeper.containerNamePrefix" .) (include "ckaf-zookeeper.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-zookeeper.preRollBackScaleJobContainerName" -}}
{{- if .Values.customResourceNames.preRollBackScaleJob.containerName -}}
{{- printf "%s%s" (include "ckaf-zookeeper.containerNamePrefix" .) .Values.customResourceNames.preRollBackScaleJob.containerName | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-zk-prerollbackscale" (include "ckaf-zookeeper.containerNamePrefix" .) (include "ckaf-zookeeper.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-zookeeper.preUpgradeScaleJobContainerName" -}}
{{- if .Values.customResourceNames.preUpgradeScaleJob.containerName -}}
{{- printf "%s%s" (include "ckaf-zookeeper.containerNamePrefix" .) .Values.customResourceNames.preUpgradeScaleJob.containerName | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-zk-preupgradescale" (include "ckaf-zookeeper.containerNamePrefix" .) (include "ckaf-zookeeper.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-zookeeper.helmTestJobContainerName" -}}
{{- if .Values.customResourceNames.helmTest.containerName -}}
{{- printf "%s%s" (include "ckaf-zookeeper.containerNamePrefix" .) .Values.customResourceNames.helmTest.containerName | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-zk-status-test" (include "ckaf-zookeeper.containerNamePrefix" .) (include "ckaf-zookeeper.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Define ckaf-zookeeper.namespace 
*/}}
{{- define "ckaf-zookeeper.namespace" -}}
{{- printf "%s" .Release.Namespace }}
{{- end -}}

{{/*
Define service account for zookeeper 
*/}}
{{- define "ckaf-zookeeper.serviceAccountName" }}
      {{- if .Values.global.rbac.enabled }}
      {{- if .Values.serviceAccountName }}
        {{- .Values.serviceAccountName }}
      {{- else -}}
        {{ template "ckaf-zookeeper.name" . }}-zkadmin
      {{- end }}
      {{- end }}
{{- end -}}

{{/* Generate/Add Common labels as per HBP */}}
{{- define "ckaf-zookeeper.commonlabels" }}
{{- if .Values.global.common_labels -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/component: {{.Values.name}}
app.kubernetes.io/part-of: {{.Values.partOf }}
app.kubernetes.io/managed-by: {{ .Values.managedBy }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{- end }}
{{- end }}

{{- define "ckaf-zookeeper.pdb-values" -}}
{{/* Checking if both (maxUnavailable/minAvailable) is set */}}
{{- if and ( and ( not (kindIs "invalid" .Values.pdb.maxUnavailable)) ( ne ( toString ( .Values.pdb.maxUnavailable )) "" )) ( and ( not (kindIs "invalid" .Values.pdb.minAvailable)) ( ne ( toString ( .Values.pdb.minAvailable )) "" )) }}
  {{- required "Both the values(maxUnavailable/minAvailable) are set.Only One of the values to be set." "" }}

{{/* Checking if minAvailable is set */}}
{{- else if and (not (kindIs "invalid" .Values.pdb.minAvailable)) ( ne ( toString ( .Values.pdb.minAvailable )) "" ) }}
minAvailable: {{ .Values.pdb.minAvailable }}

{{/* Checking if maxUnavailable is set */}}
{{- else if and (not (kindIs "invalid" .Values.pdb.maxUnavailable)) ( ne ( toString ( .Values.pdb.maxUnavailable )) "" ) }}
maxUnavailable: {{ .Values.pdb.maxUnavailable  }}

{{- else }}
  {{- required "None of the values(maxUnavailable/minAvailable) are set.Only One of the values to be set." "" }}
{{- end }}
{{- end -}}

{{- define "ckaf-zookeeper.timeZoneEnv" -}}
{{- if .Values.timeZone.timeZoneEnv }}
{{- .Values.timeZone.timeZoneEnv | quote -}}
{{- else }}
{{- .Values.global.timeZoneEnv | default "UTC" | quote -}}
{{- end }}
{{- end }}


{{/* Select API Version for statefulset */}}
{{- define "ckaf-zookeeper.statefulset.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "apps/v1" }}
{{- print "apps/v1" }}
{{- else }}
{{- print "apps/v1beta1" }}
{{- end }}
{{- end }}

{{/*  Taint/Toleration Feature */}}
{{- define "ckaf-zookeeper.tolerations" -}}
{{- with .Values.tolerations }}
tolerations:
{{ toYaml . }}
{{- end }}
{{ end }}

{{/* Select API Version for CBUR */}}
{{- define "ckaf-zookeeper.cbur.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "cbur.csf.nokia.com/v1/BrPolicy" }}
{{- print "cbur.csf.nokia.com/v1" }}
{{- else }}
{{- print "cbur.bcmt.local/v1" }}
{{- end }}
{{- end }}

{{- define "ckaf-zookeeper.dualStack.config" -}}
{{- if or ( .Values.ipFamilyPolicy ) ( .Values.ipFamilies ) }}
{{- if .Values.ipFamilyPolicy }}
ipFamilyPolicy: {{ .Values.ipFamilyPolicy }}
{{- end }}
{{- if .Values.ipFamilies }}
ipFamilies: {{ .Values.ipFamilies | toYaml | nindent 2 }}
{{- end }}
{{- else if or ( .Values.global.ipFamilyPolicy ) ( .Values.global.ipFamilies ) }}
{{- if .Values.global.ipFamilyPolicy }}
ipFamilyPolicy: {{ .Values.global.ipFamilyPolicy }}
{{- end }}
{{- if .Values.global.ipFamilies }}
ipFamilies: {{ .Values.global.ipFamilies | toYaml | nindent 2 }}
{{- end }}
{{- end }}
{{- end }}

{{/* creating psp only when kube version is less than 1.25 */}}
{{- define "ckaf-zookeeper.PspCreation" }}
{{- if lt (trimPrefix "v" .Capabilities.KubeVersion.GitVersion) "1.25.0-0" }}
{{- print "true" }}
{{- end -}}
{{- end -}}

{{/* enable or disable Generic ephemeral Volume */}}
{{- define "ckaf-zookeeper.ephemeralVolume" -}}
{{- if .Values.ephemeralVolume.enabled }}
{{- .Values.ephemeralVolume.enabled }}
{{- else }}
{{- .Values.global.ephemeralVolume.enabled | default false }}
{{- end }}
{{- end }}

{{/* render seccomp profile type */}}
{{- define "ckaf-zookeeper.renderSeccompProfile" }}
{{- if and (lt (trimPrefix "v" .Capabilities.KubeVersion.GitVersion) "1.24.0") (.Capabilities.APIVersions.Has "security.openshift.io/v1/SecurityContextConstraints") }}
{{- print "false" }}
{{- else }}
{{- print "true" }}
{{- end -}}
{{- end -}}


{{/* enable or disable syslog based on values.yaml */}}
{{- define "ckaf-zookeeper.syslogEnabled" }}
{{- $syslog := dict }}
{{- if eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.unifiedLogging.syslog.enabled .Values.global.unifiedLogging.syslog.enabled false)) "true" }}
{{- $_ := set . "syslogEnabled" "true" }}
  {{- if eq (include "csf-common-lib.v1.coalesceBoolean" (tuple .Values.global.unifiedLogging.syslog.enabled false)) "false" }}
    {{- $_ := set . "syslog"  .Values.unifiedLogging.syslog }}
  {{- else }}
    {{- $_ := set . "syslog"  (merge  .Values.unifiedLogging.syslog .Values.global.unifiedLogging.syslog) }}
  {{- end }}
{{- else }}
{{- $_ := set . "syslogEnabled" "false" }}
{{- end }}
{{- end }}

{{/* render kubernetes resources */}}
{{- define "ckaf-zookeeper.getResources" }}
{{- $root := index . 0 }}
{{- $resources := index . 1 }}
{{- $defaultCpuLimit := index . 2 }}
requests:
  memory: {{ $resources.requests.memory }}
  cpu: {{ $resources.requests.cpu }}
  ephemeral-storage: {{ index $resources.requests "ephemeral-storage" }}
limits:
  memory: {{ $resources.limits.memory }}
  {{- if ne ( toString ( $resources.limits.cpu )) ""}}
  cpu: {{ $resources.limits.cpu }}
  {{- else if eq (include "csf-common-lib.v1.coalesceBoolean" (tuple $root.Values.enableDefaultCpuLimits $root.Values.global.enableDefaultCpuLimits false)) "true" }}
  cpu: {{ $defaultCpuLimit }}
  {{- end }}
  ephemeral-storage: {{ index $resources.limits "ephemeral-storage" }}
{{- end -}}


{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}

{{- define "ckaf-kafka.name" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else if .Values.nameOverride -}}
{{- printf "ckaf-kf-%s" .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "kf-%s" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Define pod name prefix value
*/}}
{{- define "ckaf-kafka.podNamePrefix" -}}
{{- if or (.Values.fullnameOverride) (.Values.nameOverride) -}}
{{- printf "" -}}
{{- else -}}
{{- default "" .Values.global.podNamePrefix -}}
{{- end -}}
{{- end -}}

{{/*
Define container name prefix value
*/}}
{{- define "ckaf-kafka.containerNamePrefix" -}}
{{- if or (.Values.fullnameOverride) (.Values.nameOverride) -}}
{{- printf "" -}}
{{- else -}}
{{- default "" .Values.global.containerNamePrefix -}}
{{- end -}}
{{- end -}}

{{/*
Define statefulset names with podName prefix
*/}}
{{- define "ckaf-kafka.statefulset" -}}
{{- printf "%s%s" (include "ckaf-kafka.podNamePrefix" .) (include "ckaf-kafka.name" .)  | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}

{{/*
Define kafka container name value
*/}}
{{- define "ckaf-kafka.containerName" -}}
{{- if .Values.customResourceNames.kafkaPod.kfContainerName -}}
{{- printf "%s%s" (include "ckaf-kafka.containerNamePrefix" .) .Values.customResourceNames.kafkaPod.kfContainerName | lower | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s" (include "ckaf-kafka.containerNamePrefix" .) "ckaf-kafka-broker" | lower | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Define kafka-init container name value
*/}}
{{- define "ckaf-kafka.initContainerName" -}}
{{- if .Values.customResourceNames.kafkaPod.initContainerName -}}
{{- printf "%s%s" (include "ckaf-kafka.containerNamePrefix" .) .Values.customResourceNames.kafkaPod.initContainerName | lower | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s" (include "ckaf-kafka.containerNamePrefix" .) "ckaf-kafka-init" | lower | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}


{{/*
Define JMX container name value
*/}}
{{- define "ckaf-kafka.jmxContainerName" -}}
{{- if .Values.customResourceNames.kafkaPod.jmxContainerName -}}
{{- printf "%s%s" (include "ckaf-kafka.containerNamePrefix" .) .Values.customResourceNames.kafkaPod.jmxContainerName | lower | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s" (include "ckaf-kafka.containerNamePrefix" .) "ckaf-kafka-jmx-exporter" | lower | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Define kafka Utility container name value
*/}}
{{- define "ckaf-kafka.utilityContainerName" -}}
{{- if .Values.customResourceNames.kafkaPod.utilityConatinerName -}}
{{- printf "%s%s" (include "ckaf-kafka.containerNamePrefix" .) .Values.customResourceNames.kafkaPod.utilityConatinerName | lower | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s" (include "ckaf-kafka.containerNamePrefix" .) "ckaf-kafka-utility" | lower | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}


{{/*
Define kafka job names with pod name prefix
*/}}
{{- define "ckaf-kafka.postRollBackJobName" -}}
{{- if .Values.customResourceNames.postRollBackJob.name -}}
{{- printf "%s%s" (include "ckaf-kafka.podNamePrefix" .) .Values.customResourceNames.postRollBackJob.name | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-kf-postrollback-job" (include "ckaf-kafka.podNamePrefix" .) (include "ckaf-kafka.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-kafka.preHealJobName" -}}
{{- if .Values.customResourceNames.preHealJob.name -}}
{{- printf "%s%s" (include "ckaf-kafka.podNamePrefix" .) .Values.customResourceNames.preHealJob.name | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-kf-preheal-job" (include "ckaf-kafka.podNamePrefix" .) (include "ckaf-kafka.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-kafka.postScaleInJobName" -}}
{{- if .Values.customResourceNames.postScaleInJob.name -}}
{{- printf "%s%s" (include "ckaf-kafka.podNamePrefix" .) .Values.customResourceNames.postScaleInJob.name | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-kf-postscalein-job" (include "ckaf-kafka.podNamePrefix" .) (include "ckaf-kafka.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-kafka.postScaleOutJobName" -}}
{{- if .Values.customResourceNames.postScaleOutJob.name -}}
{{- printf "%s%s" (include "ckaf-kafka.podNamePrefix" .) .Values.customResourceNames.postScaleOutJob.name | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-kf-postscaleout-job" (include "ckaf-kafka.podNamePrefix" .) (include "ckaf-kafka.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-kafka.preRollBackJobName" -}}
{{- if .Values.customResourceNames.preRollBackJob.name -}}
{{- printf "%s%s" (include "ckaf-kafka.podNamePrefix" .) .Values.customResourceNames.preRollBackJob.name | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-kf-prerollback-job" (include "ckaf-kafka.podNamePrefix" .) (include "ckaf-kafka.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-kafka.postRestoreJobName" -}}
{{- if .Values.customResourceNames.postRestoreJob.name -}}
{{- printf "%s%s" (include "ckaf-kafka.podNamePrefix" .) .Values.customResourceNames.postRestoreJob.name | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-kf-postrestore-job" (include "ckaf-kafka.podNamePrefix" .) (include "ckaf-kafka.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-kafka.preRestoreJobName" -}}
{{- if .Values.customResourceNames.preRestoreJob.name -}}
{{- printf "%s%s" (include "ckaf-kafka.podNamePrefix" .) .Values.customResourceNames.preRestoreJob.name | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-kf-prerestore-job" (include "ckaf-kafka.podNamePrefix" .) (include "ckaf-kafka.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-kafka.postDeleteJobName" -}}
{{- if .Values.customResourceNames.postDeleteJob.name -}}
{{- printf "%s%s" (include "ckaf-kafka.podNamePrefix" .) .Values.customResourceNames.postDeleteJob.name | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-kf-postdelete-job" (include "ckaf-kafka.podNamePrefix" .) (include "ckaf-kafka.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-kafka.postUpgradeJobName" -}}
{{- if .Values.customResourceNames.postUpgradeJob.name -}}
{{- printf "%s%s" (include "ckaf-kafka.podNamePrefix" .) .Values.customResourceNames.postUpgradeJob.name | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-kf-postupgrade-job" (include "ckaf-kafka.podNamePrefix" .) (include "ckaf-kafka.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-kafka.preScaleInJobName" -}}
{{- if .Values.customResourceNames.preScaleInJob.name -}}
{{- printf "%s%s" (include "ckaf-kafka.podNamePrefix" .) .Values.customResourceNames.preScaleInJob.name | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-kf-prescalein-job" (include "ckaf-kafka.podNamePrefix" .) (include "ckaf-kafka.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-kafka.postHealJobName" -}}
{{-  if .Values.customResourceNames.postHealJob.name -}}
{{- printf "%s%s" (include "ckaf-kafka.podNamePrefix" .) .Values.customResourceNames.postHealJob.name | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-kf-postheal-job" (include "ckaf-kafka.podNamePrefix" .) (include "ckaf-kafka.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-kafka.preDeleteJobName" -}}
{{- if .Values.customResourceNames.preDeleteJob.name -}}
{{- printf "%s%s" (include "ckaf-kafka.podNamePrefix" .) .Values.customResourceNames.preDeleteJob.name | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-kf-predelete-job" (include "ckaf-kafka.podNamePrefix" .) (include "ckaf-kafka.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-kafka.preUpgradeJobName" -}}
{{- if .Values.customResourceNames.preUpgradeJob.name -}}
{{- printf "%s%s" (include "ckaf-kafka.podNamePrefix" .) .Values.customResourceNames.preUpgradeJob.name | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-kf-preupgrade-job" (include "ckaf-kafka.podNamePrefix" .) (include "ckaf-kafka.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-kafka.postUpgradeScaleJobName" -}}
{{- if .Values.customResourceNames.postUpgradeScaleJob.name -}}
{{- printf "%s%s" (include "ckaf-kafka.podNamePrefix" .) .Values.customResourceNames.postUpgradeScaleJob.name | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-kf-postupgradescale-job" (include "ckaf-kafka.podNamePrefix" .) (include "ckaf-kafka.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-kafka.preRollBackScaleJobName" -}}
{{- if .Values.customResourceNames.preRollBackScaleJob.name -}}
{{- printf "%s%s" (include "ckaf-kafka.podNamePrefix" .) .Values.customResourceNames.preRollBackScaleJob.name | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-kf-prerollbackscale-job" (include "ckaf-kafka.podNamePrefix" .) (include "ckaf-kafka.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-kafka.preUpgradeScaleJobName" -}}
{{- if .Values.customResourceNames.preUpgradeScaleJob.name -}}
{{- printf "%s%s" (include "ckaf-kafka.podNamePrefix" .) .Values.customResourceNames.preUpgradeScaleJob.name | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-kf-preupgradescale-job" (include "ckaf-kafka.podNamePrefix" .) (include "ckaf-kafka.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}


{{- define "ckaf-kafka.helmTestJobName" -}}
{{- if .Values.customResourceNames.helmTest.name -}}
{{- printf "%s%s" (include "ckaf-kafka.podNamePrefix" .) .Values.customResourceNames.helmTest.name | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-kf-testpod-status" (include "ckaf-kafka.podNamePrefix" .) (include "ckaf-kafka.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-kafka.podDisruptionBudgetJobName" -}}
{{- if .Values.customResourceNames.podDisruptionBudget.name -}}
{{- printf "%s%s" (include "ckaf-kafka.podNamePrefix" .) .Values.customResourceNames.podDisruptionBudget.name | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s" (include "ckaf-kafka.podNamePrefix" .) (include "ckaf-kafka.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Define kafka job container names with containerName prefix
*/}}
{{- define "ckaf-kafka.postRollBackJobContainerName" -}}
{{- if .Values.customResourceNames.postRollBackJob.containerName -}}
{{- printf "%s%s" (include "ckaf-kafka.containerNamePrefix" .) .Values.customResourceNames.postRollBackJob.containerName | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-kf-postrollback" (include "ckaf-kafka.containerNamePrefix" .) (include "ckaf-kafka.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-kafka.preHealJobContainerName" -}}
{{- if .Values.customResourceNames.preHealJob.containerName -}}
{{- printf "%s%s" (include "ckaf-kafka.containerNamePrefix" .) .Values.customResourceNames.preHealJob.containerName | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-kf-preheal" (include "ckaf-kafka.containerNamePrefix" .) (include "ckaf-kafka.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-kafka.postScaleInJobContainerName" -}}
{{- if .Values.customResourceNames.postScaleInJob.containerName -}}
{{- printf "%s%s" (include "ckaf-kafka.containerNamePrefix" .) .Values.customResourceNames.postScaleInJob.containerName | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-kf-postscalein" (include "ckaf-kafka.containerNamePrefix" .) (include "ckaf-kafka.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-kafka.postScaleOutJobContainerName" -}}
{{- if .Values.customResourceNames.postScaleOutJob.containerName -}}
{{- printf "%s%s" (include "ckaf-kafka.containerNamePrefix" .) .Values.customResourceNames.postScaleOutJob.containerName | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-kf-postscaleout" (include "ckaf-kafka.containerNamePrefix" .) (include "ckaf-kafka.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-kafka.preRollBackJobContainerName" -}}
{{- if .Values.customResourceNames.preRollBackJob.containerName -}}
{{- printf "%s%s" (include "ckaf-kafka.containerNamePrefix" .) .Values.customResourceNames.preRollBackJob.containerName | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-kf-prerollback" (include "ckaf-kafka.containerNamePrefix" .) (include "ckaf-kafka.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-kafka.postRestoreJobContainerName" -}}
{{- if .Values.customResourceNames.postRestoreJob.containerName -}}
{{- printf "%s%s" (include "ckaf-kafka.containerNamePrefix" .) .Values.customResourceNames.postRestoreJob.containerName | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-kf-postrestore" (include "ckaf-kafka.containerNamePrefix" .) (include "ckaf-kafka.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-kafka.preRestoreJobContainerName" -}}
{{- if .Values.customResourceNames.preRestoreJob.containerName -}}
{{- printf "%s%s" (include "ckaf-kafka.containerNamePrefix" .) .Values.customResourceNames.preRestoreJob.containerName | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-kf-prerestore" (include "ckaf-kafka.containerNamePrefix" .) (include "ckaf-kafka.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-kafka.postDeleteJobContainerName" -}}
{{- if .Values.customResourceNames.postDeleteJob.containerName -}}
{{- printf "%s%s" (include "ckaf-kafka.containerNamePrefix" .) .Values.customResourceNames.postDeleteJob.containerName | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-kf-postdelete" (include "ckaf-kafka.containerNamePrefix" .) (include "ckaf-kafka.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-kafka.postUpgradeJobContainerName" -}}
{{- if .Values.customResourceNames.postUpgradeJob.containerName -}}
{{- printf "%s%s" (include "ckaf-kafka.containerNamePrefix" .) .Values.customResourceNames.postUpgradeJob.containerName | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-kf-postupgrade" (include "ckaf-kafka.containerNamePrefix" .) (include "ckaf-kafka.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-kafka.preScaleInJobContainerName" -}}
{{- if .Values.customResourceNames.preScaleInJob.containerName -}}
{{- printf "%s%s" (include "ckaf-kafka.containerNamePrefix" .) .Values.customResourceNames.preScaleInJob.containerName | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-kf-prescalein" (include "ckaf-kafka.containerNamePrefix" .) (include "ckaf-kafka.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-kafka.postHealJobContainerName" -}}
{{-  if .Values.customResourceNames.postHealJob.containerName -}}
{{- printf "%s%s" (include "ckaf-kafka.containerNamePrefix" .) .Values.customResourceNames.postHealJob.containerName | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-kf-postheal" (include "ckaf-kafka.containerNamePrefix" .) (include "ckaf-kafka.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-kafka.preDeleteJobContainerName" -}}
{{- if .Values.customResourceNames.preDeleteJob.containerName -}}
{{- printf "%s%s" (include "ckaf-kafka.containerNamePrefix" .) .Values.customResourceNames.preDeleteJob.containerName | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-kf-predelete" (include "ckaf-kafka.containerNamePrefix" .) (include "ckaf-kafka.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-kafka.preUpgradeJobContainerName" -}}
{{- if .Values.customResourceNames.preUpgradeJob.containerName -}}
{{- printf "%s%s" (include "ckaf-kafka.containerNamePrefix" .) .Values.customResourceNames.preUpgradeJob.containerName | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-kf-preupgrade" (include "ckaf-kafka.containerNamePrefix" .) (include "ckaf-kafka.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-kafka.postUpgradeScaleJobContainerName" -}}
{{- if .Values.customResourceNames.postUpgradeScaleJob.containerName -}}
{{- printf "%s%s" (include "ckaf-kafka.containerNamePrefix" .) .Values.customResourceNames.postUpgradeScaleJob.containerName | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-kf-postupgradescale" (include "ckaf-kafka.containerNamePrefix" .) (include "ckaf-kafka.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-kafka.preRollBackScaleJobContainerName" -}}
{{- if .Values.customResourceNames.preRollBackScaleJob.containerName -}}
{{- printf "%s%s" (include "ckaf-kafka.containerNamePrefix" .) .Values.customResourceNames.preRollBackScaleJob.containerName | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-kf-prerollbackscale" (include "ckaf-kafka.containerNamePrefix" .) (include "ckaf-kafka.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-kafka.preUpgradeScaleJobContainerName" -}}
{{- if .Values.customResourceNames.preUpgradeScaleJob.containerName -}}
{{- printf "%s%s" (include "ckaf-kafka.containerNamePrefix" .) .Values.customResourceNames.preUpgradeScaleJob.containerName | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-kf-preupgradescale" (include "ckaf-kafka.containerNamePrefix" .) (include "ckaf-kafka.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-kafka.preRollBackOpJobName" -}}
{{- if .Values.customResourceNames.preRollbackOpJob.name -}}
{{- printf "%s%s" (include "ckaf-kafka.podNamePrefix" .) .Values.customResourceNames.preRollbackOpJob.name | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-kf-prerollbackop-job" (include "ckaf-kafka.podNamePrefix" .) (include "ckaf-kafka.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-kafka.preRollBackOpJobContainerName" -}}
{{- if .Values.customResourceNames.preRollbackOpJob.containerName -}}
{{- printf "%s%s" (include "ckaf-kafka.containerNamePrefix" .) .Values.customResourceNames.preRollbackOpJob.containerName | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-kf-prerollbackop" (include "ckaf-kafka.containerNamePrefix" .) (include "ckaf-kafka.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ckaf-kafka.helmTestJobContainerName" -}}
{{- if .Values.customResourceNames.helmTest.containerName -}}
{{- printf "%s%s" (include "ckaf-kafka.containerNamePrefix" .) .Values.customResourceNames.helmTest.containerName | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-kf-status-test" (include "ckaf-kafka.containerNamePrefix" .) (include "ckaf-kafka.name" .) | trunc (int .Values.customResourceNames.resourceNameLimit) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Construct zookeeper Connect URL
*/}}
{{- define "ckaf-kafka.zookeeperConnectUrl" }}
{{- if index .Values "ckaf-zookeeper" "enabled" -}}

{{- if index .Values "ckaf-zookeeper" "fullnameOverride" -}}
    {{- $rlsname := index .Values "ckaf-zookeeper" "fullnameOverride" -}}
    {{- $namespace := .Release.Namespace -}}
    {{- $port := index .Values "ckaf-zookeeper" "zookeeperClientPort" | toString -}}
        {{ $rlsname }}.{{ $namespace }}.svc.{{ .Values.clusterDomain }}:{{ $port }}
{{- else if index .Values "ckaf-zookeeper" "nameOverride" -}}
    {{- $rlsname := index .Values "ckaf-zookeeper" "nameOverride" -}}
    {{- $namespace := .Release.Namespace -}}
    {{- $port := index .Values "ckaf-zookeeper" "zookeeperClientPort" | toString -}}
        ckaf-zk-{{ $rlsname }}.{{ $namespace }}.svc.{{ .Values.clusterDomain }}:{{ $port }}
{{- else -}}
    {{- $rlsname := .Release.Name -}}
    {{- $namespace := .Release.Namespace -}}
    {{- $port := index .Values "ckaf-zookeeper" "zookeeperClientPort" | toString -}}
        {{- printf "zk-%s.%s.svc.%s:%s" $rlsname $namespace .Values.clusterDomain $port -}}
{{- end -}}

 {{- else -}}
    {{- printf "%s" .Values.zkConnect }}
{{- end -}}
{{- end -}}

{{/* Service Account for kafka
*/}}
{{- define "ckaf-kafka.serviceAccountName" }}
      {{- if .Values.global.rbac.enabled }}
      {{- if .Values.serviceAccountName }}
        {{- .Values.serviceAccountName }}
      {{- else -}}
        {{ template "ckaf-kafka.name" . }}-kfadmin
      {{- end }}
      {{- end }}
{{- end -}}

{{/* Kafka Namespace
*/}}
{{- define "ckaf-kafka.namespace" -}}
{{- printf "%s" .Release.Namespace }}
{{- end -}}


{{/* Generate/Add Common labels as per HBP */}}
{{- define "ckaf-kafka.commonLabels" }}
{{- if .Values.global.common_labels -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/component: {{.Values.name}}
app.kubernetes.io/managed-by: {{ .Values.managedBy }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{- end }}
{{- end }}

{{- define "ckaf-kafka.certReloader" -}}
{{- if .Values.ssl.certManager.enabled }}
{{- .Values.ssl.certManager.enabled -}}
{{- else }}
{{- .Values.ssl.certReloader -}}
{{- end }}
{{- end }}

{{- define "ckaf-kafka.storeSecret" -}}
{{- if .Values.ssl.certManager.enabled }}
{{- template "ckaf-kafka.statefulset" . }}-cert-manager-secret
{{- else -}}
{{- required "valid ssl secret name to be provided" .Values.ssl.secret_name -}}
{{- end }}
{{- end }}

{{/* if the certificate type is PEM and cert-manager is enabled Keystore file name in the secret
will be tls.key else keystore.jks, and if a user provided secret is provided then a valid secret name along
with keystore secret reference name to be provided.
*/}}
{{- define "ckaf-kafka.keystoreSecretKey" -}}
{{- if .Values.ssl.certManager.enabled }}
{{- include "ckaf-kafka.certManager.keystoreSecretKey" . }}
{{- else -}}
{{- required "valid keystore secret key reference name to be provided .Values.ssl.keystore_key"  .Values.ssl.keystore_key -}}
{{- end }}
{{- end }}

{{- define "ckaf-kafka.certManager.keystoreSecretKey" -}}
{{- if (ne (include "ckaf-kafka.certificateFormat" .) "PEM") }}
{{- printf "keystore.jks" -}}
{{- else }}
{{- printf "tls.key" -}}
{{- end }}
{{- end }}

{{/* if the certificate type is PEM and cert-manager is enabled truststore file name in the secret
will be ca.crt else truststore.jks, and if a user provided secret is provided then a valid secret name along
with truststore secret reference name to be provided.
*/}}
{{- define "ckaf-kafka.truststoreSecretKey" -}}
{{- if .Values.ssl.certManager.enabled }}
{{- include "ckaf-kafka.certManager.truststoreSecretKey" . }}
{{- else -}}
{{- required "valid truststore secret key reference name to be provided .Values.ssl.truststore_key" .Values.ssl.truststore_key -}}
{{- end }}
{{- end }}

{{- define "ckaf-kafka.certManager.truststoreSecretKey" -}}
{{- if (ne (include "ckaf-kafka.certificateFormat" .) "PEM") }}
{{- printf "truststore.jks" -}}
{{- else }}
{{- printf "ca.crt" -}}
{{- end }}
{{- end }}

{{/* if the certificate type is PEM and cert-manager is enabled then the signed cert file name in the secret
will be tls.crt and in case of JKS this is not needed, and if a user provided secret is provided then a valid secret name along
with signedcert secret reference name to be provided.
*/}}
{{- define "ckaf-kafka.signedCertSecretKey" -}}
{{- if .Values.ssl.certManager.enabled }}
{{- include "ckaf-kafka.certManager.signedCertSecretKey" . }}
{{- else }}
{{- required "valid Signed cert secret key reference name to be provided .Values.ssl.signedCert_key" .Values.ssl.signedCert_key -}}
{{- end }}
{{- end }}

{{- define "ckaf-kafka.certManager.signedCertSecretKey" -}}
{{- if (eq (include "ckaf-kafka.certificateFormat" .) "PEM") }}
{{- printf "tls.crt" -}}
{{- end }}
{{- end }}

{{- define "ckaf-kafka.storePasswordSecret" -}}
{{- if and .Values.ssl.certManager.enabled  (ne (include "ckaf-kafka.certificateFormat" .) "PEM") }}
{{- required "valid cert-manager store encryption secret name to be provided" .Values.ssl.certManager.store_password_secret_name -}}
{{- else -}}
{{- required "ssl secret name" .Values.ssl.secret_name -}}
{{- end }}
{{- end }}

{{- define "ckaf-kafka.keystorePasswordSecretKey" -}}
{{- if and .Values.ssl.certManager.enabled (ne (include "ckaf-kafka.certificateFormat" .) "PEM") }}
{{- required "valid cert-manager store encryption secret key name to be provided" .Values.ssl.certManager.store_password_key -}}
{{- else -}}
{{- required "valid keystore password secret key  name to be provided" .Values.ssl.keystore_passwd_key -}}
{{- end }}
{{- end }}

{{/* keystore key passsword is not mandatory in case of PEM format certificates, whereas in the case of 
JKS they are mandatory.
*/}}
{{- define "ckaf-kafka.keystoreKeyPasswordSecretKey" -}}
{{- if and .Values.ssl.certManager.enabled  (ne (include "ckaf-kafka.certificateFormat" .) "PEM") }}
{{- required "valid cert-manager store encryption secret key name to be provided" .Values.ssl.certManager.store_password_key -}}
{{- else -}}
{{- if  (ne (include "ckaf-kafka.certificateFormat" .) "PEM") }}
{{- required "valid keystore key password secret key  name to be provided" .Values.ssl.keystore_key_passwd_key -}}
{{- else }}
{{- .Values.ssl.keystore_key_passwd_key }}
{{- end }}
{{- end }}
{{- end }}


{{/* This function will provide a global varaible "privateKeyEncryption" to be acsessed in statefulset 
which can be used to check if the private key is encrypted or not 
in case of cert-manager with PEM format private key encryption is not possible this needs to be enahnced when supported.
*/}}
{{- define "ckaf-kafka.checkIfPrivateKeyEncryptionIsEnabled" -}}
{{- if .Values.ssl.certManager.enabled }}
{{- $_ := set . "privateKeyEncryption" "false" }}
{{- else -}}
{{- if .Values.ssl.keystore_key_passwd_key }}
{{- $_ := set . "privateKeyEncryption" "true" }}
{{- else }}
{{- $_ := set . "privateKeyEncryption" "false" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "ckaf-kafka.truststorePasswordSecretKey" -}}
{{- if and .Values.ssl.certManager.enabled  (ne (include "ckaf-kafka.certificateFormat" .) "PEM") }}
{{-  required "valid cert-manager store encryption secret key name to be provided" .Values.ssl.certManager.store_password_key -}}
{{- else -}}
{{- required "valid truststore password secret key  name to be provided" .Values.ssl.truststore_passwd_key -}}
{{- end }}
{{- end }}




{{- define "ckaf-kafka.pdb-values" -}}
{{/* Checking if both (maxUnavailable/minAvailable) is set */}}
{{- if and ( and ( not (kindIs "invalid" .Values.pdb.maxUnavailable)) ( ne ( toString ( .Values.pdb.maxUnavailable )) "" )) ( and ( not (kindIs "invalid" .Values.pdb.minAvailable)) ( ne ( toString ( .Values.pdb.minAvailable )) "" )) }}
  {{- required "Both the values(maxUnavailable/minAvailable) are set.Only One of the values to be set." "" }}

{{/* Checking if minAvailable is set */}}
{{- else if and (not (kindIs "invalid" .Values.pdb.minAvailable)) ( ne ( toString ( .Values.pdb.minAvailable )) "" ) }}
minAvailable: {{ .Values.pdb.minAvailable }}
{{/* Checking if maxUnavailable is set */}}
{{- else if and (not (kindIs "invalid" .Values.pdb.maxUnavailable)) ( ne ( toString ( .Values.pdb.maxUnavailable )) "" ) }}
maxUnavailable: {{ .Values.pdb.maxUnavailable }}
{{- else }}
  {{- required "None of the values(maxUnavailable/minAvailable) are set.Only One of the values to be set." "" }}
{{- end }}
{{- end -}}


{{- define "ckaf-kafka.timeZoneEnv" -}}
{{- if .Values.timeZone.timeZoneEnv }}
{{- .Values.timeZone.timeZoneEnv | quote -}}
{{- else }}
{{- .Values.global.timeZoneEnv | default "UTC" | quote -}}
{{- end }}
{{- end }}

{{/* Select API Version for statefulset */}}
{{- define "ckaf-kafka.statefulsetApiVersion" -}}
{{- if .Capabilities.APIVersions.Has "apps/v1" }}
{{- print "apps/v1" }}
{{- else }}
{{- print "apps/v1beta1" }}
{{- end }}
{{- end }}

{{/*  Taint/Toleration Feature */}}
{{- define "ckaf-kafka.tolerations" -}}
{{- with .Values.tolerations }}
tolerations:
{{ toYaml . }}
{{- end }}
{{ end }}

{{/* Select API Version for CBUR */}}
{{- define "ckaf-kafka.cburApiVersion" -}}
{{- if .Capabilities.APIVersions.Has "cbur.csf.nokia.com/v1/BrPolicy" }}
{{- print "cbur.csf.nokia.com/v1" }}
{{- else }}
{{- print "cbur.bcmt.local/v1" }}
{{- end }}
{{- end }}

{{- define "ckaf-kafka.dualStackConfig" -}}
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

{{/* kind certificate API versions */}}
{{- define "ckaf-kafka.certificateApiVersion" -}}
{{- if .Capabilities.APIVersions.Has "cert-manager.io/v1" }}
{{- print "cert-manager.io/v1" }}
{{- else if .Capabilities.APIVersions.Has "cert-manager.io/v1beta1" }}
{{- print "cert-manager.io/v1beta1" }}
{{- else if .Capabilities.APIVersions.Has "cert-manager.io/v1alpha3" }}
{{- print "cert-manager.io/v1alpha3" }}
{{- else if .Capabilities.APIVersions.Has "cert-manager.io/v1alpha2" }}
{{- print "cert-manager.io/v1alpha2" }}
{{- end }}
{{- end }}

{{/* keyencryption details for cert-manager */}}
{{- define "ckaf-kafka.privateKeyConfigs" -}}
{{- if and (eq (include "ckaf-kafka.certificateFormat" .) "PEM") (ne .Values.ssl.certManager.encoding "PKCS8") }}
{{- fail "Invalid certManager.encoding type for PEM, Kafka supports only PKCS8 encoding with PEM format" }}
{{- end }}
{{- if or ( .Capabilities.APIVersions.Has "cert-manager.io/v1" ) (.Capabilities.APIVersions.Has "cert-manager.io/v1beta1" ) }}
privateKey:
  algorithm: {{ .Values.ssl.certManager.algorithm }}
  encoding: {{ .Values.ssl.certManager.encoding }}
  size: {{ .Values.ssl.certManager.keySize }}
  rotationPolicy: {{ .Values.ssl.certManager.rotationPolicy }}
{{- else }}
keyAlgorithm: {{ .Values.ssl.certManager.algorithm |lower}}
keyEncoding: {{ .Values.ssl.certManager.encoding |lower}} 
keySize: {{ .Values.ssl.certManager.keySize }}
rotationPolicy: {{ .Values.ssl.certManager.rotationPolicy }}
{{- end }}
{{- end }}

{{/* creating psp only when kube version is less than 1.25 */}}
{{- define "ckaf-kafka.PspCreation" }}
{{- if lt (trimPrefix "v" .Capabilities.KubeVersion.GitVersion) "1.25.0-0" }}
{{- print "true" }}
{{- end -}}
{{- end -}}

{{/* setting allocateLoadBalancerNodePorts flag to false only when kube version is greater than 1.20 since the flag was introduced in k8s 1.20 */}}
{{- define "ckaf-kafka.disableLoadBalancerNodePorts" }}
{{- if ge (trimPrefix "v" .Capabilities.KubeVersion.GitVersion) "1.20.0-0" }}
{{- print "true" }}
{{- end -}}
{{- end -}}

{{/* enable or disable Generic ephemeral Volume */}}
{{- define "ckaf-kafka.ephemeralVolume" -}}
{{- if .Values.ephemeralVolume.enabled }}
{{- .Values.ephemeralVolume.enabled }}
{{- else }}
{{- .Values.global.ephemeralVolume.enabled | default false }}
{{- end }}
{{- end }}

{{/* render seccomp profile type */}}
{{- define "ckaf-kafka.renderSeccompProfile" }}
{{- if and (lt (trimPrefix "v" .Capabilities.KubeVersion.GitVersion) "1.24.0") (.Capabilities.APIVersions.Has "security.openshift.io/v1/SecurityContextConstraints") }}
{{- print "false" }}
{{- else }}
{{- print "true" }}
{{- end -}}
{{- end -}}

{{/* enable or disable syslog based on values.yaml */}}
{{- define "ckaf-kafka.syslogEnabled" }}
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


{{/* this function compares the keystore and truststore type and sets a common format */}}
{{- define "ckaf-kafka.certificateFormat" }}
{{- if eq  ( .Values.ssl.keyStoreType |upper) ( .Values.ssl.trustStoreType |upper) }}
{{- .Values.ssl.keyStoreType |upper }}
{{- else }}
{{- fail "keyStoreType and trustStoreType are not the same" }} 
{{-  end }}
{{- end }}

{{- define "ckaf-kafka.kubectlImageRepo" }}
{{- coalesce .Values.kubectlImageRepo .Values.kubectlImage }}
{{- end }}

{{/* render kubernetes resources */}}
{{- define "ckaf-kafka.getResources" }}
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

{{- define "ckaf-kafka.istioAndExternalListenersConfig" }}
{{- $root := index . 0 }}
{{- $istio := index . 1 }}
{{- $ingress := index . 2 }}
{{- $istioTlsEnabled := true }}
{{- if and (eq $istio.enabled true) (eq $istio.mtls.enabled false) (eq $istio.permissive false) }}
  {{- if and $ingress.enableExternalAccess (or (eq $ingress.type "ocpRoute") ( eq "IstioGateway" $ingress.type ))}}
    {{- range $index, $listener := $ingress.externalListeners }}
      {{- if not (hasKey $listener.IstioGateway "tls") }}
        {{- $istioTlsEnabled = true }}
      {{- else }}
         {{- $istioTlsEnabled = false }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- else }}
  {{- $istioTlsEnabled = false }}
{{- end }}

{{- $istioTlsEnabled }}
{{- end }}

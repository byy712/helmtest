{{/*
Create PodDisruptionBudget parameters based on input values as defined in a HBP.

## Parameters

One dict parameter expected with keys:
* enabled - boolean
* maxUnavailable - string (optional)
* minAvailable - string (optional)

One of maxUnavailable/minAvailable need to be set.

## Examples

* Workload (named core) common labels
** values.yaml
+
----
core:
  pdb:
    enabled: True
    maxUnavailable: 50%
----
** snippet from a poddistruptionbudget template
+
----
spec:
  {{- include "csf-common-lib.v1.pdbValues" .Values.core.pdb | indent 2}}
----

## HBP

This is a helper function for:

.HBP_Helm_PDB_1 of HBP v2.2.0
****
PodDisruptionBudget need to be supported
****

*/}}
{{- define "csf-common-lib.v1.pdbValues" -}}
{{- if and ( and ( not (kindIs "invalid" .maxUnavailable)) ( ne ( toString ( .maxUnavailable )) "" )) ( and ( not (kindIs "invalid" .minAvailable)) ( ne ( toString ( .minAvailable )) "" )) }}
  {{- required "Both of the values (maxUnavailable/minAvailable) are set. Only one of the values need to be set." "" }}
{{- else if and (not (kindIs "invalid" .minAvailable)) ( ne ( toString ( .minAvailable )) "" ) }}
minAvailable: {{ .minAvailable }}
{{- else if and (not (kindIs "invalid" .maxUnavailable)) ( ne ( toString ( .maxUnavailable )) "" ) }}
maxUnavailable: {{ .maxUnavailable }}
{{- else }}
{{- required "None of the values (maxUnavailable/minAvailable) are set. Only one of the values need to be set." "" }}
{{- end }}
{{- end -}}
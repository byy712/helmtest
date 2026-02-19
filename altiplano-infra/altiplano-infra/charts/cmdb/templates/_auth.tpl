{{/*
*  Utility template for metrics sidecar configuration
   Args: (tuple . <workload>)
*/}}
{{- define "cmdb.use_zt_proxy" -}}
{{- $Values := index (first .) "Values" -}}
{{- $spec := index $Values (index . 1) -}}
{{- (and (hasKey $spec.auth "enabled") (kindIs "bool" $spec.auth.enabled)) | ternary $spec.auth.enabled ($Values.auth.enabled | default false) -}}
{{- end }}

{{- define "cmdb.mariadb_use_zt_proxy" -}}
{{- include "cmdb.use_zt_proxy" (tuple . "mariadb") }}
{{- end }}
{{- define "cmdb.maxscale_use_zt_proxy" -}}
{{- include "cmdb.use_zt_proxy" (tuple . "maxscale") }}
{{- end }}


{{/*
*  zt-proxy sidecar file system volumeMounts/volumes
 * Args: (tuple . <workload>)
*/}}
{{- define "cmdb-fs.vm-auth" -}}
{{- $Values := index (first .) "Values" }}
{{- $spec := index $Values (index . 1) }}
{{- $oidc_secret := coalesce $spec.auth.secretRef.name $Values.auth.secretRef.name "none" }}
- name: fs-tmp
  mountPath: /tmp
- name: fs-varlibauth
  mountPath: /var/lib/zt-proxy
{{- if ne $oidc_secret "none" }}
- name: fs-client-secret
  mountPath: /etc/zt-proxy
  readOnly: true
{{- end }}
{{- end }}

{{/* Args: (tuple . <workload>) */}}
{{- define "cmdb-fs.vol-auth" -}}
{{- $Values := index (first .) "Values" }}
{{- $spec := index $Values (index . 1) }}
{{- $oidc_secret := coalesce $spec.auth.secretRef.name $Values.auth.secretRef.name "none" }}
{{- if (include "cmdb.use_zt_proxy" .) }}
- name: fs-varlibauth
  emptyDir: {}
{{- if ne $oidc_secret "none" }}
- name: fs-client-secret
  secret:
    secretName: {{ $oidc_secret }}
    items:
      - key: "clientSecret"
        path: "client_secret"
        mode: 400
    optional: true
{{- end }}
{{- end }}
{{- end }}

{{/*
   zt-proxy sidecar environment
   Args: (tuple . <workload>)
*/}}
{{- define "cmdb-auth.env" -}}
{{- $Values := index (first .) "Values" }}
{{- $spec := index $Values (index . 1) }}
{{- $oidc_secret := coalesce $spec.auth.secretRef.name $Values.auth.secretRef.name "none" }}
{{- if ne $oidc_secret "none" }}
- name: CLIENT_ID
  valueFrom:
    secretKeyRef:
      key: clientId
      name: {{ $oidc_secret }}
      optional: true
- name: OIDC_ENDPOINT
  valueFrom:
    secretKeyRef:
      key: oidcDiscoveryEndpoint
      name: {{ $oidc_secret }}
- name: AUDIENCE
  valueFrom:
    secretKeyRef:
      key: audience
      name: {{ $oidc_secret }}
      optional: true
- name: USE_INSECURE
  value: {{ (and (hasKey $spec.auth "skipVerifyInsecure") (kindIs "bool" $spec.auth.skipVerifyInsecure)) | ternary $spec.auth.skipVerifyInsecure ($Values.auth.skipVerifyInsecure | default true) | quote }}
{{- end }}
{{- end }}

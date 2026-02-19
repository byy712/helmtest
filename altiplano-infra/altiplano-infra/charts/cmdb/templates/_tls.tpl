{{/* vim: set filetype=mustache: */}}

{{- /* Utilities for dealing with TLS certs */ -}}

{{- /*
        TLS volumes
*/ -}}
{{- define "cmdb-tls.vol" -}}
{{- include "cmdb-tls.vol-mariadb" . }}
{{- include "cmdb-tls.vol-maxscale" . }}
{{- end }}

{{- /* MariaDB TLS volumes */ -}}
{{- define "cmdb-tls.vol-mariadb" -}}
{{- if and (eq (include "cmdb.tls_enabled" (tuple . "mariadb")) "true") (eq (include "cmdb.mariadb_use_cmgr" .) "true") }}
- name: mdb-certificates
  projected:
    sources:
    - secret:
        name: {{ template "cmdb.fullname" . }}-server-cert
        items:
        - key: tls.crt
          path: server-cert.pem
        - key: tls.key
          path: server-key.pem
        - key: ca.crt
          path: server-ca-cert.pem
    - secret:
        name: {{ template "cmdb.fullname" . }}-client-cert
        items:
        - key: tls.crt
          path: client-cert.pem
        - key: tls.key
          path: client-key.pem
        - key: ca.crt
          path: client-ca-cert.pem
{{- else if and (eq (include "cmdb.tls_enabled" (tuple . "mariadb")) "true") ( and (ne (default "none" .Values.mariadb.tls.secretRef.name) "none") (ne (default "none" .Values.clients.mariadb.tls.secretRef.name) "none")) }}
- name: mdb-certificates
  secret:
    secretName: {{ (tpl .Values.mariadb.tls.secretRef.name .) }}
{{- end }}
{{- end }}

{{- /* MaxScale TLS volumes */ -}}
{{- define "cmdb-tls.vol-maxscale" -}}
{{- if eq (include "cmdb.has_maxscale" .) "true" }}
{{- if and (eq (include "cmdb.tls_enabled" (tuple . "maxscale")) "true") (or (eq (include "cmdb.maxscale_use_cmgr" .) "true") (ne (default "none" .Values.maxscale.tls.secretRef.name) "none")) }}
- name: mxs-certificates-server
  secret:
  {{- if eq (include "cmdb.maxscale_use_cmgr" .) "true" }}
    secretName: {{ template "cmdb.fullname" . }}-maxctrl-cert
    items:
    - key: tls.crt
      path: mxs-server-cert.pem
    - key: tls.key
      path: mxs-server-key.pem
    - key: ca.crt
      path: mxs-server-ca-cert.pem
  {{- else }}
    secretName: {{ (tpl .Values.maxscale.tls.secretRef.name .) }}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}

{{- /*
  Metrics Prometheus Authentication TLS Volume
  Args: (tuple . <workload>)
*/ -}}
{{- define "cmdb-tls.vol-prom-auth" -}}
{{- $Values := index (first .) "Values" -}}
{{- $spec := index $Values (index . 1) -}}
{{- $secret := coalesce $spec.auth.tls.secretRef.name $Values.auth.tls.secretRef.name "none" }}
{{- if ne $secret "none" }}
- name: prom-certificates-server
  secret:
    secretName: {{ (tpl $secret (first .)) }}
{{- end }}
{{- end }}

{{- /*
        TLS volumeMounts
*/ -}}
{{- /* mariadb certificate volumeMounts */ -}}
{{- define "cmdb-tls.vm-mariadb" -}}
{{- if and (eq (include "cmdb.tls_enabled" (tuple . "mariadb")) "true") (or (eq (include "cmdb.mariadb_use_cmgr" .) "true") (and (ne (default "none" .Values.mariadb.tls.secretRef.name) "none") (ne (default "none" .Values.clients.mariadb.tls.secretRef.name) "none"))) }}
- name: mdb-certificates
  readOnly: true
  mountPath: "/etc/my.cnf.d/ssl/"
{{- end }}
{{- end }}

{{- /* maxscale certificate volumeMounts */ -}}
{{- define "cmdb-tls.vm-maxscale" -}}
{{- if and (eq (include "cmdb.has_maxscale" .) "true") (eq (include "cmdb.tls_enabled" (tuple . "maxscale")) "true") (or (eq (include "cmdb.maxscale_use_cmgr" .) "true") (ne (default "none" .Values.maxscale.tls.secretRef.name) "none")) }}
- name: mxs-certificates-server
  readOnly: true
  mountPath: "/etc/certs/maxscale/"
{{- end }}
{{- end }}

{{- /*
  Metrics Prometheus certificate volumeMounts
  Args: (tuple . <workload>)
*/ -}}
{{- define "cmdb-tls.vm-prom-auth" -}}
{{- $Values := index (first .) "Values" -}}
{{- $spec := index $Values (index . 1) -}}
{{- $secret := coalesce $spec.auth.tls.secretRef.name $Values.auth.tls.secretRef.name "none" }}
{{- if ne $secret "none" }}
- name: prom-certificates-server
  mountPath: "/etc/certs/prom/"
  readOnly: true
{{- end }}
{{- end }}

{{- /*
        TLS mariadb certificate import
*/ -}}
{{- define "cmdb-tls.import-certs" -}}
{{- if and (eq (include "cmdb.tls_enabled" (tuple . "mariadb")) "true") (eq (include "cmdb.mariadb_use_cmgr" .) "true") }}
wait_certificates /etc/my.cnf.d/ssl server-cert.pem server-ca-cert.pem server-key.pem
wait_certificates /etc/my.cnf.d/ssl client-cert.pem client-ca-cert.pem client-key.pem
{{- end }}
{{- end }}

{{- /*
        TLS maxscale certificate wait
*/ -}}
{{- define "cmdb-tls.wait-maxscale-certs" -}}
{{- if and (eq (include "cmdb.has_maxscale" .) "true" ) (eq (include "cmdb.tls_enabled" (tuple . "maxscale")) "true") (eq (include "cmdb.maxscale_use_cmgr" .) "true") }}
wait_certificates /etc/certs/maxscale mxs-server-cert.pem mxs-server-ca-cert.pem mxs-server-key.pem
{{- end }}
{{- end }}

{{- /*
  Metrics Prometheus Authentication TLS Environment
  Args: (tuple . <workload>)
*/ -}}
{{- define "cmdb-tls.env-prom-auth" -}}
{{- $Values := index (first .) "Values" -}}
{{- $spec := index $Values (index . 1) -}}
{{- $secret := coalesce $spec.auth.tls.secretRef.name $Values.auth.tls.secretRef.name "none" }}
{{- if ne $secret "none" }}
- name: PROM_SERVER_CA_CERT
  value: /etc/certs/prom/{{ coalesce $spec.auth.tls.secretRef.keyNames.caCrt $Values.auth.tls.secretRef.keyNames.caCrt }}
- name: PROM_SERVER_KEY
  value: /etc/certs/prom/{{ coalesce $spec.auth.tls.secretRef.keyNames.tlsKey $Values.auth.tls.secretRef.keyNames.tlsKey }}
- name: PROM_SERVER_CERT
  value: /etc/certs/prom/{{ coalesce $spec.auth.tls.secretRef.keyNames.tlsCrt $Values.auth.tls.secretRef.keyNames.tlsCrt }}
{{- end }}
{{- end }}

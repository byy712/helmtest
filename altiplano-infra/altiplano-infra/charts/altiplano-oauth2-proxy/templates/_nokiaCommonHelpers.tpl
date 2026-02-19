{{/* vim: set filetype=mustache: */}}
{{/*
Derive the image name from three different parameters.
*/}}
{{- define "image.fullname" -}}

    {{- if not (empty .Values.image.registry) -}}
        {{- if not (eq "-" .Values.image.registry) -}} {{ .Values.image.registry }}{{- end -}}
    {{- else if .Values.global.registry -}} {{ .Values.global.registry }}
    {{- end -}}

    {{- if .Values.image.repository -}}
        {{- if not (empty .Values.image.registry) -}}
            {{- if not (eq "-" .Values.image.registry) -}}/{{- end -}}
        {{- else if .Values.global.registry -}}/
        {{- end -}}
    {{ .Values.image.repository }}
    {{- end -}}

    {{- if .Values.image.tag -}}
        {{- if .Values.image.repository -}}:
        {{- else -}}
            {{- if not (empty .Values.image.registry) -}}
                {{- if not (eq "-" .Values.image.registry) -}}:{{- end -}}
            {{- else if .Values.global.registry -}}:
            {{- end -}}
        {{- end -}}
    {{ .Values.image.tag }}
    {{- end -}}

{{- end -}}

{{/*
Derive the image name from three different parameters for fnms-keycloak-radius-plugin
*/}}
{{- define "radiusImage.fullname" -}}

    {{- if not (empty .Values.radiusImage.registry) -}}
        {{- if not (eq "-" .Values.radiusImage.registry) -}} {{ .Values.radiusImage.registry }}{{- end -}}
    {{- else if .Values.global.registry -}} {{ .Values.global.registry }}
    {{- end -}}

    {{- if .Values.radiusImage.repository -}}
        {{- if not (empty .Values.radiusImage.registry) -}}
            {{- if not (eq "-" .Values.radiusImage.registry) -}}/{{- end -}}
        {{- else if .Values.global.registry -}}/
        {{- end -}}
    {{ .Values.radiusImage.repository }}
    {{- end -}}

    {{- if .Values.radiusImage.tag -}}
        {{- if .Values.radiusImage.repository -}}:
        {{- else -}}
            {{- if not (empty .Values.radiusImage.registry) -}}
                {{- if not (eq "-" .Values.radiusImage.registry) -}}:{{- end -}}
            {{- else if .Values.global.registry -}}:
            {{- end -}}
        {{- end -}}
    {{ .Values.radiusImage.tag }}
    {{- end -}}

{{- end -}}



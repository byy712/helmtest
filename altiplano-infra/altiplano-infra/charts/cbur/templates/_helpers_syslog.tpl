{{/*
Map possible facility values to it's corresponding ID
*/}}
{{- define "cbur.syslog.facilityConversion" -}}
{{- $facility := . }}
{{- $facilityNumber := "" }}
{{- if eq (lower $facility) "kern" }}
{{- $facilityNumber = 0 }}
{{- else if eq (lower $facility) "user" }}
{{- $facilityNumber = 1 }}
{{- else if eq (lower $facility) "mail" }}
{{- $facilityNumber = 2 }}
{{- else if eq (lower $facility) "daemon" }}
{{- $facilityNumber = 3 }}
{{- else if eq (lower $facility) "auth" }}
{{- $facilityNumber = 4 }}
{{- else if eq (lower $facility) "syslog" }}
{{- $facilityNumber = 5 }}
{{- else if eq (lower $facility) "lpr" }}
{{- $facilityNumber = 6 }}
{{- else if eq (lower $facility) "news" }}
{{- $facilityNumber = 7 }}
{{- else if eq (lower $facility) "uucp" }}
{{- $facilityNumber = 8 }}
{{- else if eq (lower $facility) "cron" }}
{{- $facilityNumber = 9 }}
{{- else if eq (lower $facility) "authpriv" }}
{{- $facilityNumber = 10 }}
{{- else if eq (lower $facility) "ftp" }}
{{- $facilityNumber = 11 }}
{{- else if eq (lower $facility) "ntp" }}
{{- $facilityNumber = 12 }}
{{- else if eq (lower $facility) "log_audit" }}
{{- $facilityNumber = 13 }}
{{- else if eq (lower $facility) "log_alert" }}
{{- $facilityNumber = 14 }}
{{- else if eq (lower $facility) "clock" }}
{{- $facilityNumber = 15 }}
{{- else if eq (lower $facility) "local0" }}
{{- $facilityNumber = 16 }}
{{- else if eq (lower $facility) "local1" }}
{{- $facilityNumber = 17 }}
{{- else if eq (lower $facility) "local2" }}
{{- $facilityNumber = 18 }}
{{- else if eq (lower $facility) "local3" }}
{{- $facilityNumber = 19 }}
{{- else if eq (lower $facility) "local4" }}
{{- $facilityNumber = 20 }}
{{- else if eq (lower $facility) "local5" }}
{{- $facilityNumber = 21 }}
{{- else if eq (lower $facility) "local6" }}
{{- $facilityNumber = 22 }}
{{- else if eq (lower $facility) "local7" }}
{{- $facilityNumber = 23 }}
{{- else }}
{{- fail "Not supported facility value" }}
{{- end }}
{{- $facilityNumber -}}
{{- end }}

{{/*
Map log level from values to severity number
*/}}
{{- define "cbur.syslog.logLevel" -}}
{{- $logLevel := . }}
{{- $syslogLevel := "" }}
{{- if eq (lower $logLevel) "fatal" }}
{{- $syslogLevel = "2" }}
{{- else if eq (lower $logLevel) "error" }}
{{- $syslogLevel = "3" }}
{{- else if eq (lower $logLevel) "warn" }}
{{- $syslogLevel = "4" }}
{{- else if eq (lower $logLevel) "info" }}
{{- $syslogLevel = "6" }}
{{- else if or (eq (lower $logLevel) "debug") (eq (lower $logLevel) "trace") (eq (lower $logLevel) "all") }}
{{- $syslogLevel = "7" }}
{{- else if (ne (lower $logLevel) "off") }}
{{- fail "Not supported unifiedLogging.logLevel value" }}
{{- end }}
{{- $syslogLevel -}}
{{- end }}

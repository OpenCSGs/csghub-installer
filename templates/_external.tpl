{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Return domain of csghub
*/}}
{{- define "csghub.domain" -}}
{{- $host := "csghub.examle.com" }}
{{- $port := "80" }}
{{- if hasKey .Values.global "ingress" }}
  {{- if hasKey .Values.global.ingress "external" }}
    {{- if hasKey .Values.global.ingress.external "host" }}
      {{- $host = .Values.global.ingress.external.host }}
    {{- end }}
    {{- if hasKey .Values.global.ingress.external "port" }}
      {{- $port = .Values.global.ingress.external.port | toString }}
    {{- end }}
  {{- end }}
{{- end }}
{{- if gt (len $port | toString) "4" }}
{{- printf "%s:%s" $host $port -}}
{{- else }}
{{- $host -}}
{{- end }}
{{- end }}

{{/*
Define the endpoint of gitea
*/}}
{{- define "csghub.external.url" -}}
{{- $prefix := "http://" }}
{{- if hasKey .Values.global "ingress" }}
  {{- if hasKey .Values.global.ingress "tls" }}
    {{- if hasKey .Values.global.ingress.tls "enabled" }}
      {{- if .Values.global.ingress.tls.enabled }}
        {{- $prefix = "https://" }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
{{- printf "%s%s" $prefix (include "csghub.domain" .) -}}
{{- end }}

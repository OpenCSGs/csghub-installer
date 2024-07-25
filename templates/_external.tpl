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
      {{- $port = .Values.global.ingress.external.port }}
    {{- end }}
  {{- end }}
{{- end }}
{{- if eq (len ($port | quote) | toString) "4" }}
{{- printf "%s:%s" $host $port -}}
{{- else }}
{{- $host -}}
{{- end }}
{{- end }}
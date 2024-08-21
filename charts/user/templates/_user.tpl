{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Define the host for component user
*/}}
{{- define "user.host" -}}
{{- printf "%s-%s-svc"  .Release.Name "user" }}
{{- end }}

{{/*
Define the port for component user
*/}}
{{- define "user.port" -}}
{{- $port := "" }}
{{- if hasKey .Values.global "user" }}
  {{- if hasKey .Values.global.user "service" }}
    {{- if hasKey .Values.global.user.service "port" }}
      {{- $port = .Values.global.user.service.port }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $port | default "8080" -}}
{{- end }}
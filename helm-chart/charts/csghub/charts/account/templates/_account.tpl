{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Define the host of account component
*/}}
{{- define "account.host" -}}
{{- printf "%s-%s-svc" .Release.Name "account" }}
{{- end }}

{{/*
Define the api port of account component
*/}}
{{- define "account.port" }}
{{- $port := "" }}
{{- if hasKey .Values.global "account" }}
  {{- if hasKey .Values.global.account "service" }}
    {{- if hasKey .Values.global.account.service "port" }}
      {{- $port = .Values.global.account.service.port }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $port | default "8086" -}}
{{- end }}

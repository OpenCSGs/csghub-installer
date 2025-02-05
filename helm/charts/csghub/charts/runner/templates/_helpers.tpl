{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Define the internal domain for runner
*/}}
{{- define "runner.internal.domain" -}}
{{- include "common.names.custom" (list . "runner") }}
{{- end }}

{{/*
Define the internal port for runner
*/}}
{{- define "runner.internal.port" -}}
{{- $port := "8082" }}
{{- if hasKey .Values.global "runner" }}
  {{- if hasKey .Values.global.runner "service" }}
    {{- if hasKey .Values.global.runner.service "port" }}
      {{- $port = .Values.global.runner.service.port }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $port | toString -}}
{{- end }}

{{/*
Define the internal endpoint for runner
*/}}
{{- define "runner.internal.endpoint" -}}
{{- printf "http://%s:%s" (include "runner.internal.domain" .) (include "runner.internal.port" .) -}}
{{- end }}
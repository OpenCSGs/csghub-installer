{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Define the internal domain for builder
*/}}
{{- define "builder.internal.domain" -}}
{{- include "common.names.custom" (list . "builder") }}
{{- end }}

{{/*
Define the internal port for builder
*/}}
{{- define "builder.internal.port" -}}
{{- $port := "8080" }}
{{- if hasKey .Values.global "builder" }}
  {{- if hasKey .Values.global.builder "service" }}
    {{- if hasKey .Values.global.builder.service "port" }}
      {{- $port = .Values.global.builder.service.port | toString }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $port -}}
{{- end }}

{{/*
Define the internal endpoint for builder
*/}}
{{- define "builder.internal.endpoint" -}}
{{- printf "http://%s:%s" (include "builder.internal.domain" .) (include "builder.internal.port" .) }}
{{- end }}
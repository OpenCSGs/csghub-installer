{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Define the internal domain for dataflow
*/}}
{{- define "dataflow.internal.domain" -}}
{{- include "common.names.custom" (list . "dataflow") }}
{{- end }}

{{/*
Define the internal port for dataflow
*/}}
{{- define "dataflow.internal.port" -}}
{{- $port := "8000" }}
{{- if hasKey .Values.global "dataflow" }}
  {{- if hasKey .Values.global.dataflow "service" }}
    {{- if hasKey .Values.global.dataflow.service "port" }}
      {{- $port = .Values.global.dataflow.service.port | toString }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $port -}}
{{- end }}

{{/*
Define the internal endpoint for dataflow
*/}}
{{- define "dataflow.internal.endpoint" -}}
{{- printf "http://%s:%s" (include "dataflow.internal.domain" .) (include "dataflow.internal.port" .) }}
{{- end }}
{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Define the internal domain for dataviewer
*/}}
{{- define "dataviewer.internal.domain" -}}
{{- include "common.names.custom" (list . "dataviewer") }}
{{- end }}

{{/*
Define the internal port for dataviewer
*/}}
{{- define "dataviewer.internal.port" -}}
{{- $port := "8093" }}
{{- if hasKey .Values.global "dataviewer" }}
  {{- if hasKey .Values.global.dataviewer "service" }}
    {{- if hasKey .Values.global.dataviewer.service "port" }}
      {{- $port = .Values.global.dataviewer.service.port | toString }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $port -}}
{{- end }}

{{/*
Define the internal endpoint for dataviewer
*/}}
{{- define "dataviewer.internal.endpoint" -}}
{{- printf "http://%s:%s" (include "dataviewer.internal.domain" .) (include "dataviewer.internal.port" .) }}
{{- end }}
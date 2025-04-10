{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Define the internal domain for aigateway
*/}}
{{- define "aigateway.internal.domain" -}}
{{- include "common.names.custom" (list . "aigateway") }}
{{- end }}

{{/*
Define the internal port for aigateway
*/}}
{{- define "aigateway.internal.port" -}}
{{- $port := "8084" }}
{{- if hasKey .Values.global "aigateway" }}
  {{- if hasKey .Values.global.aigateway "service" }}
    {{- if hasKey .Values.global.aigateway.service "port" }}
      {{- $port = .Values.global.aigateway.service.port | toString }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $port -}}
{{- end }}
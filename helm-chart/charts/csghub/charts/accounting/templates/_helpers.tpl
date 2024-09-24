{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Define the internal domain for accounting
*/}}
{{- define "accounting.internal.domain" -}}
{{- include "common.names.custom" (list . "accounting") }}
{{- end }}

{{/*
Define the internal port for accounting
*/}}
{{- define "accounting.internal.port" -}}
{{- $port := "8086" }}
{{- if hasKey .Values.global "accounting" }}
  {{- if hasKey .Values.global.accounting "service" }}
    {{- if hasKey .Values.global.accounting.service "port" }}
      {{- $port = .Values.global.accounting.service.port | toString }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $port -}}
{{- end }}

{{/*
Define the internal endpoint for accounting
*/}}
{{- define "accounting.internal.endpoint" -}}
{{- printf "http://%s:%s" (include "accounting.internal.domain" .) (include "accounting.internal.port" .) }}
{{- end }}
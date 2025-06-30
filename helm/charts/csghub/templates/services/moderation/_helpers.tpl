{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Define the internal domain for moderation
*/}}
{{- define "moderation.internal.domain" -}}
{{- include "common.names.custom" (list . "moderation") }}
{{- end }}

{{/*
Define the internal port for moderation
*/}}
{{- define "moderation.internal.port" -}}
{{- $port := "8089" }}
{{- if hasKey .Values.global "moderation" }}
  {{- if hasKey .Values.global.moderation "service" }}
    {{- if hasKey .Values.global.moderation.service "port" }}
      {{- $port = .Values.global.moderation.service.port | toString }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $port -}}
{{- end }}
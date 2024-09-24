{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Define the internal domain for redis
*/}}
{{- define "redis.internal.domain" -}}
{{- include "common.names.custom" (list . "redis") }}
{{- end }}

{{/*
Define the internal port for redis
*/}}
{{- define "redis.internal.port" -}}
{{- $port := "6379" }}
{{- if hasKey .Values.global "redis" }}
  {{- if hasKey .Values.global.redis "service" }}
    {{- if hasKey .Values.global.redis.service "port" }}
      {{- $port = .Values.global.redis.service.port | toString }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $port -}}
{{- end }}

{{/*
Define the internal endpoint for redis
*/}}
{{- define "redis.internal.endpoint" -}}
{{ printf "http://%s:%s" (include "redis.internal.domain" .) (include "redis.internal.port" .) }}
{{- end }}
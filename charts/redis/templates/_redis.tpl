{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Random Password for which password not set
*/}}
{{- define "redis.endpoint" -}}
{{- $host := include "redis.host" . }}
{{- $port := include "redis.port" . }}
{{- printf "%s:%s" $host $port -}}
{{- end }}

{{/*
Define the host of redis
*/}}
{{- define "redis.host" -}}
{{- printf "%s-%s-hl-svc" .Release.Name "redis" -}}
{{- end }}

{{/*
Define the port of redis
*/}}
{{- define "redis.port" -}}
{{- $port := "6379" }}
{{- if hasKey .Values.global "redis" }}
  {{- if hasKey .Values.global.redis "service" }}
    {{- if hasKey .Values.global.redis.service "port" }}
      {{- $port = .Values.global.redis.service.port }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $port -}}
{{- end }}
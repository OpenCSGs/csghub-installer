{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Define the host for csghub redis
*/}}
{{- define "csghub.redis.host" -}}
{{- $host := .Values.redis.host }}
{{- if hasKey .Values.global "redis" }}
{{- if hasKey .Values.global.redis "external" }}
{{- if .Values.global.redis.external }}
{{- if hasKey .Values.global.redis "connection" }}
{{- if hasKey .Values.global.redis.connection "host" }}
{{- $host = .Values.global.redis.connection.host }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- $host -}}
{{- end }}

{{/*
Define the port for csghub redis
*/}}
{{- define "csghub.redis.port" -}}
{{- $port := .Values.redis.port }}
{{- if hasKey .Values.global "redis" }}
{{- if hasKey .Values.global.redis "external" }}
{{- if .Values.global.redis.external }}
{{- if hasKey .Values.global.redis "connection" }}
{{- if hasKey .Values.global.redis.connection "port" }}
{{- $port = .Values.global.redis.connection.port }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- $port -}}
{{- end }}

{{/*
Define the endpoint for csghub redis
*/}}
{{- define "csghub.redis.endpoint" -}}
{{- $endpoint := .Values.redis.endpoint }}
{{- printf "%s:%s" (include "csghub.redis.host" .) (include "csghub.redis.port" .) -}}
{{- end }}

{{/*
Define the password for csghub redis
*/}}
{{- define "csghub.redis.password" -}}
{{- $password := .Values.redis.password }}
{{- if hasKey .Values.global "redis" }}
{{- if hasKey .Values.global.redis "external" }}
{{- if .Values.global.redis.external }}
{{- if hasKey .Values.global.redis "connection" }}
{{- if hasKey .Values.global.redis.connection "password" }}
{{- $password = .Values.global.redis.connection.password }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- $password -}}
{{- end }}
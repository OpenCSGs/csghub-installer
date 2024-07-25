{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Define if minio enabled by global default
*/}}
{{- define "minio.enabled" -}}
{{- $minioEnabled := true }}
{{- if hasKey .Values.global "minio" }}
  {{- if hasKey .Values.global.minio "enabled" }}
    {{- $minioEnabled = .Values.global.minio.enabled }}
  {{- end }}
{{- end }}
{{- $minioEnabled -}}
{{- end }}

{{/*
Define if postgresql enabled by global default
*/}}
{{- define "postgresql.enabled" -}}
{{- $postgresqlEnabled := true }}
{{- if hasKey .Values.global "postgresql" }}
  {{- if hasKey .Values.global.postgresql "enabled" }}
    {{- $postgresqlEnabled = .Values.global.postgresql.enabled }}
  {{- end }}
{{- end }}
{{- $postgresqlEnabled -}}
{{- end }}

{{/*
Define if registry enabled by global default
*/}}
{{- define "registry.enabled" -}}
{{- $registryEnabled := true }}
{{- if hasKey .Values.global "registry" }}
  {{- if hasKey .Values.global.registry "enabled" }}
    {{- $registryEnabled = .Values.global.registry.enabled }}
  {{- end }}
{{- end }}
{{- $registryEnabled -}}
{{- end }}

{{/*
Define if redis enabled by global default
*/}}
{{- define "redis.enabled" -}}
{{- $redisEnabled := true }}
{{- if hasKey .Values.global "redis" }}
  {{- if hasKey .Values.global.redis "enabled" }}
    {{- $redisEnabled = .Values.global.redis.enabled }}
  {{- end }}
{{- end }}
{{- $redisEnabled -}}
{{- end }}
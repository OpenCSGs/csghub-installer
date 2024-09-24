{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Define dsn for external postgresql
*/}}
{{- define "portal.postgresql.dsn" -}}
{{- $user := "" }}
{{- $password := "" }}
{{- $host := "" }}
{{- $port := "" }}
{{- $database := "" }}
{{- if hasKey .Values.global "portal" }}
  {{- if hasKey .Values.global.portal "postgresql" }}
    {{- if hasKey .Values.global.portal.postgresql "user" }}
      {{- $user = .Values.global.portal.postgresql.user }}
    {{- end }}
    {{- if hasKey .Values.global.portal.postgresql "password" }}
      {{- $password = .Values.global.portal.postgresql.password }}
    {{- end }}
    {{- if hasKey .Values.global.portal.postgresql "host" }}
      {{- $host = .Values.global.portal.postgresql.host }}
    {{- end }}
    {{- if hasKey .Values.global.portal.postgresql "port" }}
      {{- $port = .Values.global.portal.postgresql.port }}
    {{- end }}
    {{- if hasKey .Values.global.portal.postgresql "database" }}
      {{- $database = .Values.global.portal.postgresql.database }}
    {{- end }}
  {{- end }}
{{- end }}
{{- printf "postgresql://%s:%s@%s:%s/%s?sslmode=disable" $user (include "postgres.password.encode" $password ) $host $port $database -}}
{{- end }}
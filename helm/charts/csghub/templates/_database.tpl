{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Define the host for csghub postgresql
*/}}
{{- define "csghub.postgresql.host" -}}
{{- $host := or .Values.postgresql.host (include "common.names.custom" (list . "postgresql")) }}
{{- if hasKey .Values.global "postgresql" }}
{{- if hasKey .Values.global.postgresql "external" }}
{{- if .Values.global.postgresql.external }}
{{- if hasKey .Values.global.postgresql "connection" }}
{{- if hasKey .Values.global.postgresql.connection "host" }}
{{- if .Values.global.postgresql.connection.host }}
{{- $host = .Values.global.postgresql.connection.host }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- $host -}}
{{- end }}

{{/*
Define the port for csghub postgresql
*/}}
{{- define "csghub.postgresql.port" -}}
{{- $port := .Values.postgresql.port }}
{{- if hasKey .Values.global "postgresql" }}
{{- if hasKey .Values.global.postgresql "external" }}
{{- if .Values.global.postgresql.external }}
{{- if hasKey .Values.global.postgresql "connection" }}
{{- if hasKey .Values.global.postgresql.connection "port" }}
{{- if .Values.global.postgresql.connection.port }}
{{- $port = .Values.global.postgresql.connection.port }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- $port | toString -}}
{{- end }}

{{/*
Define the database for csghub postgresql
*/}}
{{- define "csghub.postgresql.database" -}}
{{- $database := .Values.postgresql.database }}
{{- if hasKey .Values.global "postgresql" }}
{{- if hasKey .Values.global.postgresql "external" }}
{{- if .Values.global.postgresql.external }}
{{- if hasKey .Values.global.postgresql "connection" }}
{{- if hasKey .Values.global.postgresql.connection "database" }}
{{- if .Values.global.postgresql.connection.database }}
{{- $database = .Values.global.postgresql.connection.database }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- $database -}}
{{- end }}

{{/*
Define the user for csghub postgresql
*/}}
{{- define "csghub.postgresql.user" -}}
{{- $user := .Values.postgresql.user }}
{{- if hasKey .Values.global "postgresql" }}
{{- if hasKey .Values.global.postgresql "external" }}
{{- if .Values.global.postgresql.external }}
{{- if hasKey .Values.global.postgresql "connection" }}
{{- if hasKey .Values.global.postgresql.connection "user" }}
{{- if .Values.global.postgresql.connection.user }}
{{- $user = .Values.global.postgresql.connection.user }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- $user -}}
{{- end }}

{{/*
Define the password for csghub postgresql
*/}}
{{- define "csghub.postgresql.password" -}}
{{- $password := .Values.postgresql.password }}
{{- if hasKey .Values.global "postgresql" }}
{{- if hasKey .Values.global.postgresql "external" }}
{{- if .Values.global.postgresql.external }}
{{- if hasKey .Values.global.postgresql "connection" }}
{{- if hasKey .Values.global.postgresql.connection "password" }}
{{- if .Values.global.postgresql.connection.password }}
{{- $password = .Values.global.postgresql.connection.password }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- $password -}}
{{- end }}

{{/*
Define the timezone for csghub postgresql
*/}}
{{- define "csghub.postgresql.timezone" -}}
{{- $timezone := .Values.postgresql.timezone }}
{{- if hasKey .Values.global "postgresql" }}
{{- if hasKey .Values.global.postgresql "external" }}
{{- if .Values.global.postgresql.external }}
{{- if hasKey .Values.global.postgresql "connection" }}
{{- if hasKey .Values.global.postgresql.connection "timezone" }}
{{- if .Values.global.postgresql.connection.timezone }}
{{- $timezone = .Values.global.postgresql.connection.timezone }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- $timezone -}}
{{- end }}
{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Define the host of server
*/}}
{{- define "server.host" }}
{{- printf "%s-%s-svc" .Release.Name "server" -}}
{{- end }}

{{/*
Define the port of server
*/}}
{{- define "server.port" }}
{{- $port := "8080" }}
{{- if hasKey .Values.global "server" }}
  {{- if hasKey .Values.global.server "service" }}
    {{- if hasKey .Values.global.server.service "port" }}
      {{- $port = .Values.global.server.service.port }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $port -}}
{{- end }}

{{/*
Define url of server
*/}}
{{- define "server.url" -}}
{{- printf "http://%s:%s" (include "server.host" .) (include "server.port" .) }}
{{- end }}

{{/*
Define callback url of server
*/}}
{{- define "server.url.callback" -}}
{{- printf "%s/server/callback" (include "csghub.url.external" .) }}
{{- end }}

{{/*
Define git callback url of server
*/}}
{{- define "server.url.callback.git" -}}
{{- printf "http://%s:%s/api/v1/callback/git" (include "server.host" .) (include "server.port" .) }}
{{- end }}

{{/*
Define the user for external postgresql
*/}}
{{- define "server.postgresql.user" -}}
{{- $user := "" }}
{{- if hasKey .Values.global "server" }}
  {{- if hasKey .Values.global.server "postgresql" }}
    {{- if hasKey .Values.global.server.postgresql "user" }}
      {{- $user = .Values.global.server.postgresql.user }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $user -}}
{{- end }}

{{/*
Define the password for external postgresql
*/}}
{{- define "server.postgresql.password" -}}
{{- $password := "" }}
{{- if hasKey .Values.global "server" }}
  {{- if hasKey .Values.global.server "postgresql" }}
    {{- if hasKey .Values.global.server.postgresql "password" }}
      {{- $password = .Values.global.server.postgresql.password }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $password -}}
{{- end }}

{{/*
Define the host for external postgresql
*/}}
{{- define "server.postgresql.host" -}}
{{- $host := "" }}
{{- if hasKey .Values.global "server" }}
  {{- if hasKey .Values.global.server "postgresql" }}
    {{- if hasKey .Values.global.server.postgresql "host" }}
      {{- $host = .Values.global.server.postgresql.host }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $host -}}
{{- end }}

{{/*
Define the port for external postgresql
*/}}
{{- define "server.postgresql.port" -}}
{{- $port := "" }}
{{- if hasKey .Values.global "server" }}
  {{- if hasKey .Values.global.server "postgresql" }}
    {{- if hasKey .Values.global.server.postgresql "port" }}
      {{- $port = .Values.global.server.postgresql.port }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $port -}}
{{- end }}

{{/*
Define the port for external postgresql
*/}}
{{- define "server.postgresql.database" -}}
{{- $database := "" }}
{{- if hasKey .Values.global "server" }}
  {{- if hasKey .Values.global.server "postgresql" }}
    {{- if hasKey .Values.global.server.postgresql "database" }}
      {{- $database = .Values.global.server.postgresql.database }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $database -}}
{{- end }}

{{/*
Define dsn for external postgresql
*/}}
{{- define "server.postgresql.dsn" -}}
{{- $user := include "server.postgresql.user" . }}
{{- $password := include "server.postgresql.password" . }}
{{- $host := include "server.postgresql.host" . }}
{{- $port := include "server.postgresql.port" . }}
{{- $database := include "server.postgresql.database" . }}
{{- printf "postgresql://%s:%s@%s:%s/%s?sslmode=disable" $user (include "postgres.password.encode" $password ) $host $port $database -}}
{{- end }}

{{/*
Define the configmap of server
*/}}
{{- define "server.cm" }}
{{- printf "%s-%s-cm" .Release.Name "server" -}}
{{- end }}

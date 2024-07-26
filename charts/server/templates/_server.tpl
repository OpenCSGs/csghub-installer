{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Define global unique HUB_SERVER_API_TOKEN
*/}}
{{- define "server.hub.api.token" }}
{{- printf "%s%s" (.Release.Namespace | sha256sum) (.Release.Name | sha256sum) }}
{{- end }}

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
Define callback url of server
*/}}
{{- define "server.callback.url" -}}
{{- printf "http://%s:%s/api/v1/callback/git" (include "server.host" .) (include "server.port" .) }}
{{- end }}

{{/*
Define dsn for external postgresql
*/}}
{{- define "server.postgresql.dsn" -}}
{{- $user := "" }}
{{- $password := "" }}
{{- $host := "" }}
{{- $port := "" }}
{{- $database := "" }}
{{- if hasKey .Values.global "server" }}
  {{- if hasKey .Values.global.server "postgresql" }}
    {{- if hasKey .Values.global.server.postgresql "user" }}
      {{- $user = .Values.global.server.postgresql.user }}
    {{- end }}
    {{- if hasKey .Values.global.server.postgresql "password" }}
      {{- $password = .Values.global.server.postgresql.password }}
    {{- end }}
    {{- if hasKey .Values.global.server.postgresql "host" }}
      {{- $host = .Values.global.server.postgresql.host }}
    {{- end }}
    {{- if hasKey .Values.global.server.postgresql "port" }}
      {{- $port = .Values.global.portal.postgresql.port }}
    {{- end }}
    {{- if hasKey .Values.global.server.postgresql "database" }}
      {{- $database = .Values.global.server.postgresql.database }}
    {{- end }}
  {{- end }}
{{- end }}
{{- printf "postgresql://%s:%s@%s:%s/%s?sslmode=disable" $user (include "postgres.password.encode" $password ) $host $port $database -}}
{{- end }}

{{/*
Define the configmap of server
*/}}
{{- define "server.cm" }}
{{- printf "%s-%s-cm" .Release.Name "server" -}}
{{- end }}

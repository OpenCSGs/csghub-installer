{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Define the host for postgresql
*/}}
{{- define "postgresql.hybrid.host" -}}
{{- $host := "" }}
{{- if eq "true" (include "postgresql.enabled" .)}}
{{- $host = include "postgresql.host" . }}
{{- else }}
{{- $host = include "server.postgresql.host" . }}
{{- end }}
{{- $host -}}
{{- end }}

{{/*
Define the port for postgresql
*/}}
{{- define "postgresql.hybrid.port" -}}
{{- $port := "5432" }}
{{- if eq "true" (include "postgresql.enabled" .)}}
{{- $port = include "postgresql.port" . }}
{{- else }}
{{- $port = include "server.postgresql.port" . }}
{{- end }}
{{- $port -}}
{{- end }}

{{/*
Define the user for postgresql
*/}}
{{- define "postgresql.hybrid.user" -}}
{{- $user := "" }}
{{- if eq "true" (include "postgresql.enabled" .)}}
{{- $user = "csghub_server" }}
{{- else }}
{{- $user = include "server.postgresql.user" . }}
{{- end }}
{{- $user -}}
{{- end }}

{{/*
Define the database for postgresql
*/}}
{{- define "postgresql.hybrid.database" -}}
{{- $database := "" }}
{{- if eq "true" (include "postgresql.enabled" .)}}
{{- $database = "csghub_server_production" }}
{{- else }}
{{- $database = include "server.postgresql.database" . }}
{{- end }}
{{- $database -}}
{{- end }}
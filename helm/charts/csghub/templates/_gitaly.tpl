{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Define the host for csghub gitaly
*/}}
{{- define "csghub.gitaly.host" -}}
{{- $host := .Values.gitaly.host }}
{{- if hasKey .Values.global "gitaly" }}
{{- if hasKey .Values.global.gitaly "external" }}
{{- if .Values.global.gitaly.external }}
{{- if hasKey .Values.global.gitaly "connection" }}
{{- if hasKey .Values.global.gitaly.connection "host" }}
{{- $host = .Values.global.gitaly.connection.host }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- $host -}}
{{- end }}

{{/*
Define the port for csghub gitaly
*/}}
{{- define "csghub.gitaly.port" -}}
{{- $port := .Values.gitaly.port }}
{{- if hasKey .Values.global "gitaly" }}
{{- if hasKey .Values.global.gitaly "external" }}
{{- if .Values.global.gitaly.external }}
{{- if hasKey .Values.global.gitaly "connection" }}
{{- if hasKey .Values.global.gitaly.connection "port" }}
{{- $port = .Values.global.gitaly.connection.port }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- $port -}}
{{- end }}

{{/*
Define the token for csghub gitaly
*/}}
{{- define "csghub.gitaly.token" -}}
{{- $token := include "gitaly.internal.token" . }}
{{- if hasKey .Values.global "gitaly" }}
{{- if hasKey .Values.global.gitaly "external" }}
{{- if .Values.global.gitaly.external }}
{{- if hasKey .Values.global.gitaly "connection" }}
{{- if hasKey .Values.global.gitaly.connection "token" }}
{{- $token = .Values.global.gitaly.connection.token }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- $token -}}
{{- end }}

{{/*
Define the endpoint for csghub gitaly
*/}}
{{- define "csghub.gitaly.endpoint" -}}
{{ printf "tcp://%s:%s" (include "csghub.gitaly.host" .) (include "csghub.gitaly.port" .) }}
{{- end }}
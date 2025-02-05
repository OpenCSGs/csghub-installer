{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Define the internal domain for server
*/}}
{{- define "server.internal.domain" -}}
{{- include "common.names.custom" (list . "server") }}
{{- end }}

{{/*
Define the internal port for server
*/}}
{{- define "server.internal.port" -}}
{{- $port := "8080" }}
{{- if hasKey .Values.global "server" }}
  {{- if hasKey .Values.global.server "service" }}
    {{- if hasKey .Values.global.server.service "port" }}
      {{- $port = .Values.global.server.service.port }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $port | toString -}}
{{- end }}

{{/*
Define the internal endpoint for server
*/}}
{{- define "server.internal.endpoint" -}}
{{- printf "http://%s:%s" (include "server.internal.domain" .) (include "server.internal.port" .) -}}
{{- end }}

{{/*
Define the git callback url for server
*/}}
{{- define "server.callback.git" -}}
{{- printf "%s/api/v1/callback/git" (include "server.internal.endpoint" .) -}}
{{- end }}

{{/*
Define the user callback url for server
*/}}
{{- define "server.callback.user" -}}
{{- printf "%s/server/callback" (include "csghub.external.endpoint" .) -}}
{{- end }}

{{/*
Define global unique HUB_SERVER_API_TOKEN
*/}}
{{- define "server.hub.api.token" -}}
{{- $namespaceHash := (.Release.Namespace | sha256sum) }}
{{- $nameHash := (.Release.Name | sha256sum) }}
{{- printf "%s%s" $namespaceHash $nameHash -}}
{{- end }}
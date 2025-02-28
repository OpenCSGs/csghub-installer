{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Define the internal domain for gitaly
*/}}
{{- define "gitaly.internal.domain" -}}
{{- include "common.names.custom" (list . "gitaly") }}
{{- end }}

{{/*
Define the internal port for gitaly
*/}}
{{- define "gitaly.internal.port" -}}
{{- $port := "8075" }}
{{- if hasKey .Values.global "gitaly" }}
  {{- if hasKey .Values.global.gitaly "service" }}
    {{- if hasKey .Values.global.gitaly.service "port" }}
      {{- $port = .Values.global.gitaly.service.port }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $port | toString -}}
{{- end }}

{{/*
Define the internal token for gitaly
*/}}
{{- define "gitaly.internal.token" -}}
{{- printf "%s@1234!" .Release.Name | b64enc -}}
{{- end }}

{{/*
Define the internal endpoint for gitaly
*/}}
{{- define "gitaly.internal.endpoint" -}}
{{- printf "http://%s:%s" (include "gitaly.internal.domain" .) (include "gitaly.internal.port" .) -}}
{{- end }}
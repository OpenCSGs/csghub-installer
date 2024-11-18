{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Define the internal domain for user
*/}}
{{- define "user.internal.domain" -}}
{{- include "common.names.custom" (list . "user") }}
{{- end }}

{{/*
Define the internal port for user
*/}}
{{- define "user.internal.port" -}}
{{- $port := "8088" }}
{{- if hasKey .Values.global "user" }}
  {{- if hasKey .Values.global.user "service" }}
    {{- if hasKey .Values.global.user.service "port" }}
      {{- $port = .Values.global.user.service.port | toString }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $port -}}
{{- end }}

{{/*
Define the internal endpoint for user
*/}}
{{- define "user.internal.endpoint" -}}
{{- printf "http://%s:%s" (include "user.internal.domain" .) (include "user.internal.port" .) }}
{{- end }}

{{/*
Define the password of user root
*/}}
{{- define "user.password" }}
{{- "Root@1234" -}}
{{- end }}
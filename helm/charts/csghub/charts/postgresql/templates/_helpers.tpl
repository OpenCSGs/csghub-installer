{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Define the internal domain for postgresql
*/}}
{{- define "postgresql.internal.domain" -}}
{{- include "common.names.custom" (list . "postgresql") }}
{{- end }}

{{/*
Define the internal port for postgresql
*/}}
{{- define "postgresql.internal.port" -}}
{{- $port := "5432" }}
{{- if hasKey .Values.global "postgresql" }}
  {{- if hasKey .Values.global.postgresql "service" }}
    {{- if hasKey .Values.global.postgresql.service "port" }}
      {{- $port = .Values.global.postgresql.service.port | toString }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $port -}}
{{- end }}

{{/*
Random Password for which password not set
*/}}
{{- define "postgresql.initPass" -}}
{{- printf "%s@%s" (now | date "15/04") . | sha256sum | trunc 16 | b64enc | b64enc -}}
{{- end }}

{{/*
Define a custom urlencode function.
*/}}
{{- define "postgresql.encode" -}}
{{- $value := . -}}
{{- $value | replace "@" "%40" | replace ":" "%3A" -}}
{{- end -}}
{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Random Password for which password not set
*/}}
{{- define "postgresql.initPass" -}}
{{- printf "%s@%s" (now | date "15/04") . | sha256sum | trunc 16 | b64enc | b64enc -}}
{{- end }}

{{/*
Define the host of postgresql
*/}}
{{- define "postgresql.host" -}}
{{- printf "%s-%s-hl-svc" .Release.Name "postgresql" -}}
{{- end }}

{{/*
Define the port of postgresql
*/}}
{{- define "postgresql.port" -}}
{{- $port := "5432" }}
{{- if hasKey .Values.global "postgresql" }}
  {{- if hasKey .Values.global.postgresql "service" }}
    {{- if hasKey .Values.global.postgresql.service "port" }}
      {{- $port = .Values.global.postgresql.service.port }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $port -}}
{{- end }}

{{/*
Define the secret of postgresql
*/}}
{{- define "postgresql.secret" -}}
{{- printf "%s-%s-secret" .Release.Name "postgresql" -}}
{{- end }}
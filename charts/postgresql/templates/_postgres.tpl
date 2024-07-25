{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Random Password for which password not set
*/}}
{{- define "postgres.initPass" -}}
{{- printf "%s@%s" (now | date "15/04") . | sha256sum | trunc 16 | b64enc | b64enc }}
{{- end }}

{{/*
Define the host of postgres
*/}}
{{- define "postgres.host" -}}
{{- printf "%s-%s-hl-svc" .Release.Name "postgresql" }}
{{- end }}

{{/*
Define the port of postgres
*/}}
{{- define "postgres.port" -}}
{{- $postgresSubchart := .Values.global.postgresql | default dict }}
{{- $service := $postgresSubchart.service | default dict }}
{{- coalesce $service.port "5432" }}
{{- end }}
{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Define the name of server endpoint
*/}}
{{- define "minio.endpoint" -}}
{{- $port := include "minio.ports.api" . }}
{{- printf "http://%s:%s" (include "names.hl.svc" .) $port }}
{{- end }}

{{/*
Define the port of server api
*/}}
{{- define "minio.ports.api" -}}
{{- $minioSubchart := .Values.global.minio | default dict }}
{{- coalesce $minioSubchart.service.ports.api "9000" }}
{{- end }}

{{/*
Define the port of server console
*/}}
{{- define "minio.ports.console" -}}
{{- $minioSubchart := .Values.global.minio | default dict }}
{{- coalesce $minioSubchart.service.ports.console "9001" }}
{{- end }}

{{/*
Define the region of server
*/}}
{{- define "minio.region" -}}
{{- $minioSubchart := .Values.global.minio | default dict }}
{{- coalesce $minioSubchart.region "cn-north-1" }}
{{- end }}
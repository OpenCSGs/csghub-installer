{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Define the name of minio endpoint external
*/}}
{{- define "minio.endpoint.external" -}}
{{- $port := include "csghub.port" . }}
{{- printf "http://%s:%s" (include "external.domain.minio" .) $port -}}
{{- end }}

{{/*
Define the name of minio endpoint
*/}}
{{- define "minio.endpoint" -}}
{{- $host := include "minio.host" . }}
{{- $port := include "minio.ports.api" . }}
{{- printf "http://%s:%s" $host $port -}}
{{- end }}

{{/*
Define the host of minio
*/}}
{{- define "minio.host" -}}
{{- printf "%s-%s-hl-svc" .Release.Name "minio" -}}
{{- end }}

{{/*
Define the port of minio api
*/}}
{{- define "minio.ports.api" -}}
{{- $port := "9000" }}
{{- if hasKey .Values.global "minio" }}
  {{- if hasKey .Values.global.minio "service" }}
    {{- if hasKey .Values.global.minio.service "ports" }}
        {{- if hasKey .Values.global.minio.service.ports "api" }}
            {{- $port = .Values.global.minio.service.ports.api }}
        {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $port -}}
{{- end }}

{{/*
Define the port of minio console
*/}}
{{- define "minio.ports.console" -}}
{{- $port := "9001" }}
{{- if hasKey .Values.global "minio" }}
  {{- if hasKey .Values.global.minio "service" }}
    {{- if hasKey .Values.global.minio.service "ports" }}
        {{- if hasKey .Values.global.minio.service.ports "console" }}
            {{- $port = .Values.global.minio.service.ports.console }}
        {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $port -}}
{{- end }}

{{/*
Define the region of server
*/}}
{{- define "minio.region" -}}
{{- $region := "cn-north-1" }}
{{- if hasKey .Values.global "minio" }}
  {{- if hasKey .Values.global.minio "region" }}
    {{- $region = .Values.global.minio.region }}
  {{- end }}
{{- end }}
{{- $region -}}
{{- end }}

{{/*
Define the secret of minio
*/}}
{{- define "minio.secret" -}}
{{- printf "%s-%s-secret" .Release.Name "minio" -}}
{{- end }}
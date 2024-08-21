{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Define the host of minio
*/}}
{{- define "minio.host" -}}
{{- printf "%s-%s-hl-svc" .Release.Name "minio" -}}
{{- end }}

{{/*
Define the api port of minio
*/}}
{{- define "minio.ports.api" -}}
{{- $port := "" }}
{{- if hasKey .Values.global "minio" }}
  {{- if hasKey .Values.global.minio "service" }}
    {{- if hasKey .Values.global.minio.service "ports" }}
        {{- if hasKey .Values.global.minio.service.ports "api" }}
            {{- $port = .Values.global.minio.service.ports.api }}
        {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $port | default "9000" -}}
{{- end }}

{{/*
Define the console port of minio
*/}}
{{- define "minio.ports.console" -}}
{{- $port := "" }}
{{- if hasKey .Values.global "minio" }}
  {{- if hasKey .Values.global.minio "service" }}
    {{- if hasKey .Values.global.minio.service "ports" }}
        {{- if hasKey .Values.global.minio.service.ports "console" }}
            {{- $port = .Values.global.minio.service.ports.console }}
        {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $port | default "9001" -}}
{{- end }}

{{/*
Define the external endpoint of minio
*/}}
{{- define "minio.url.external" -}}
{{- $port := include "csghub.port" . }}
{{- printf "http://%s:%s" (include "external.domain.minio" .) $port -}}
{{- end }}

{{/*
Define the internal endpoint of minio
*/}}
{{- define "minio.endpoint" -}}
{{- $host := include "minio.host" . }}
{{- $port := include "minio.ports.api" . }}
{{- printf "http://%s:%s" $host $port -}}
{{- end }}

{{/*
Define the region of minio
*/}}
{{- define "minio.region" -}}
{{- $region := "" }}
{{- if hasKey .Values.global "minio" }}
  {{- if hasKey .Values.global.minio "region" }}
    {{- $region = .Values.global.minio.region }}
  {{- end }}
{{- end }}
{{- $region | default "cn-north-1" -}}
{{- end }}

{{/*
Define the secret of minio
*/}}
{{- define "minio.secret" -}}
{{- printf "%s-%s-secret" .Release.Name "minio" -}}
{{- end }}
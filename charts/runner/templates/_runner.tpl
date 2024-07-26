{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Define the service of runner
*/}}
{{- define "runner.endpoint" }}
{{- printf "http://%s:%s" (include "runner.host" .) (include "runner.port" .) }}
{{- end }}

{{/*
Define the service of runner
*/}}
{{- define "runner.host" }}
{{- printf "%s-%s-svc" .Release.Name "runner" }}
{{- end }}

{{/*
Define the port of runner
*/}}
{{- define "runner.port" }}
{{- $port := "8082" }}
{{- if hasKey .Values.global "runner" }}
  {{- if hasKey .Values.global.runner "service" }}
    {{- if hasKey .Values.global.runner.service "port" }}
      {{- $port = .Values.global.runner.service.port }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $port -}}
{{- end }}

{{/*
Define namespace of kubernetes for space application
*/}}
{{- define "runner.namespace" -}}
{{- $namespace := "space" }}
{{- if hasKey .Values.global "runner" }}
  {{- if hasKey .Values.global.runner "namespace" }}
    {{- $namespace = .Values.global.runner.namespace }}
  {{- end }}
{{- end }}
{{- $namespace -}}
{{- end }}

{{/*
Define the configmap of runner
*/}}
{{- define "runner.cm" }}
{{- printf "%s-%s-cm" .Release.Name "runner" }}
{{- end }}
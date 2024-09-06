{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

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
{{- $port := "" }}
{{- if hasKey .Values.global "runner" }}
  {{- if hasKey .Values.global.runner "service" }}
    {{- if hasKey .Values.global.runner.service "port" }}
      {{- $port = .Values.global.runner.service.port }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $port | default "8082" -}}
{{- end }}

{{/*
Define the service of runner
*/}}
{{- define "runner.endpoint" }}
{{- printf "http://%s:%s" (include "runner.host" .) (include "runner.port" .) }}
{{- end }}

{{/*
Define namespace of kubernetes for space application
*/}}
{{- define "runner.namespace" -}}
{{- $namespace := "" }}
{{- if hasKey .Values.global "runner" }}
  {{- if hasKey .Values.global.runner "namespace" }}
    {{- $namespace = .Values.global.runner.namespace }}
  {{- end }}
{{- end }}
{{- $namespace | default "space" -}}
{{- end }}

{{/*
Define the configmap of runner
*/}}
{{- define "runner.cm" }}
{{- printf "%s-%s-cm" .Release.Name "runner" }}
{{- end }}

{{/*
Get the secret of kube config
*/}}
{{- define "kube.configs" }}
{{- $secretName := "" }}
{{- if hasKey .Values.global "runner" }}
  {{- if hasKey .Values.global.runner "kubeConfig" }}
    {{- if hasKey .Values.global.runner.kubeConfig "secretName" }}
      {{- if .Values.global.runner.kubeConfig.secretName }}
        {{- $secretName = .Values.global.runner.kubeConfig.secretName }}
      {{- else }}
        {{ fail "A valid secret containing .kube/config must be provided" }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $secretName }}
{{- end }}
{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Kubernetes standard labels
*/}}
{{- define "common.labels" -}}
{{- $ctx := . }}
{{- $customLabels := dict -}}
{{- $service := "" -}}
{{- $selectorOnly := false -}}


{{/* 解析参数 */}}
{{- if hasKey . "context" -}}
  {{- $ctx = .context -}}
  {{- $customLabels = .customLabels | default dict -}}
  {{- $service = .service | default "" -}}
  {{- $selectorOnly = .selector | default false -}}
{{- end -}}

{{/* 基础标签 */}}
app.kubernetes.io/instance: {{ $ctx.Release.Name }}

{{- if $service }}
app.kubernetes.io/name: {{ $service }}
{{- else }}
app.kubernetes.io/name: {{ include "common.names.name" $ctx }}
{{- end }}

{{- if not $selectorOnly }}
app.kubernetes.io/managed-by: {{ $ctx.Release.Service }}
helm.sh/chart: {{ include "common.names.chart" $ctx }}
{{- with $ctx.Chart.AppVersion }}
app.kubernetes.io/version: {{ . | quote }}
{{- end }}
{{- end }}

{{/* 自定义标签 */}}
{{- range $key, $value := $customLabels }}
{{ $key }}: {{ $value | quote }}
{{- end -}}
{{- end -}}

{{/*
Selector标签（只包含核心标识）
*/}}
{{- define "common.labels.selector" -}}
{{ include "common.labels" (dict "selector" true "context" .) }}
{{- end -}}

{{/*
组件Selector标签（包含服务标识）
*/}}
{{- define "common.serviceSelectorLabels" -}}
{{ include "common.labels" (dict "selector" true "service" .service "context" .context) }}
{{- end -}}

{{/*
Define matched labels for network policies
*/}}
{{- define "common.labels.selector.netpol" -}}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
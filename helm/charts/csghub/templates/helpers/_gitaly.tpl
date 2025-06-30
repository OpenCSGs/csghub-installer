{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
生成Gitaly配置的核心helper函数
*/}}
{{- define "csghub.gitaly.config" -}}
{{- $service := .service -}}
{{- $global := .global -}}
{{- $config := dict -}}

{{- if $global.Values.global.gitaly.enabled -}}
  {{/* 使用内部Gitaly */}}
  {{- $_ := set $config "host" (include "common.names.custom" (list $global "gitaly")) -}}
  {{- $_ := set $config "port" ($global.Values.gitaly.service.port | default 8075) -}}
  {{- $_ := set $config "storage" ($global.Values.gitaly.storage | default "default") -}}
  {{- $_ := set $config "token" (or $global.Values.gitaly.token (include "gitaly.internal.token" $global)) -}}
  {{- $_ := set $config "isCluster" false -}}
  {{- $_ := set $config "scheme" "tcp" -}}
{{- else -}}
  {{/* 使用外部Gitaly */}}
  {{- $_ := set $config "host" $global.Values.global.gitaly.host -}}
  {{- $_ := set $config "port" $global.Values.global.gitaly.port -}}
  {{- $_ := set $config "storage" ($global.Values.global.gitaly.storage | default "default") -}}
  {{- $_ := set $config "token" $global.Values.global.gitaly.token -}}
  {{- $_ := set $config "isCluster" ($global.Values.global.gitaly.isCluster | default false) -}}
  {{- $_ := set $config "scheme" ($global.Values.global.gitaly.scheme | default "tcp") -}}
{{- end -}}

{{/* 确保端口是字符串 */}}
{{- $_ := set $config "port" ($config.port | toString) -}}

{{- $config | toYaml -}}
{{- end -}}

{{/*
兼容性helper函数 - 保持原有的API
*/}}
{{- define "csghub.gitaly.host" -}}
{{- $config := include "csghub.gitaly.config" (dict "service" (dict "gitaly" (dict)) "global" .) | fromYaml -}}
{{- $config.host -}}
{{- end }}

{{- define "csghub.gitaly.port" -}}
{{- $config := include "csghub.gitaly.config" (dict "service" (dict "gitaly" (dict)) "global" .) | fromYaml -}}
{{- $config.port -}}
{{- end }}

{{- define "csghub.gitaly.storage" -}}
{{- $config := include "csghub.gitaly.config" (dict "service" (dict "gitaly" (dict)) "global" .) | fromYaml -}}
{{- $config.storage -}}
{{- end }}

{{- define "csghub.gitaly.token" -}}
{{- if eq .Chart.Name "gitlab-shell" }}
{{- $token := or .Values.gitaly.token (include "gitaly.internal.token" .) }}
{{- if hasKey .Values.global "gitaly" }}
{{- if hasKey .Values.global.gitaly "enabled" }}
{{- if not .Values.global.gitaly.enabled }}
{{- if hasKey .Values.global.gitaly "token" }}
{{- if .Values.global.gitaly.token }}
{{- $token = .Values.global.gitaly.token }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- $token -}}
{{- else }}
{{- $config := include "csghub.gitaly.config" (dict "service" (dict "gitaly" (dict)) "global" .) | fromYaml -}}
{{- $config.token -}}
{{- end }}
{{- end}}

{{- define "csghub.gitaly.cluster" -}}
{{- $config := include "csghub.gitaly.config" (dict "service" (dict "gitaly" (dict)) "global" .) | fromYaml -}}
{{- $config.isCluster -}}
{{- end }}

{{- define "csghub.gitaly.scheme" -}}
{{- $config := include "csghub.gitaly.config" (dict "service" (dict "gitaly" (dict)) "global" .) | fromYaml -}}
{{- $config.scheme -}}
{{- end }}

{{/*
生成Gitaly连接端点
*/}}
{{- define "csghub.gitaly.endpoint" -}}
{{- $service := .service -}}
{{- $global := .global -}}
{{- $config := include "csghub.gitaly.config" . | fromYaml -}}
{{- printf "%s://%s:%s" $config.scheme $config.host $config.port -}}
{{- end }}

{{/*
生成Gitaly gRPC连接字符串
*/}}
{{- define "csghub.gitaly.grpcEndpoint" -}}
{{- $service := .service -}}
{{- $global := .global -}}
{{- $config := include "csghub.gitaly.config" . | fromYaml -}}
{{- if $config.tls -}}
{{- printf "tls://%s:%s" $config.host $config.port -}}
{{- else -}}
{{- printf "tcp://%s:%s" $config.host $config.port -}}
{{- end -}}
{{- end }}

{{/*
检查是否使用外部Gitaly
*/}}
{{- define "csghub.gitaly.external" -}}
{{- not .Values.gitaly.enabled -}}
{{- end }}
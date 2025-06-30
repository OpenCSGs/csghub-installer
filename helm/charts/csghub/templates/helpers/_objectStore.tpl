{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
生成S3配置的helper函数
*/}}
{{- define "chart.objectStoreConfig" -}}
{{- $service := .service -}}
{{- $global := .global -}}
{{- $config := dict -}}

{{- if $global.Values.global.objectStore.enabled  -}}
  {{/* 使用内部MinIO */}}
  {{- $_ := set $config "endpoint" (include "minio.internal.endpoint" $global) -}}
  {{- $_ := set $config "region" "cn-north-1" -}}

  {{/* 默认随机生成密码   */}}
  {{- $secretUser := "minio" }}
  {{- $secretPass := (randAlphaNum 15) }}
  {{- $_ := set $config "accessKey" $secretUser -}}
  {{- $_ := set $config "secretKey" $secretPass -}}

  {{/* 如何已存在 secrets，则使用 secrets 的值 */}}
  {{- $secretData := (lookup "v1" "Secret" $global.Release.Namespace (include "common.names.custom" $global)).data }}
  {{- if $secretData }}
  {{- $secretUser = index $secretData "MINIO_ROOT_USER" }}
  {{- if $secretUser }}
  {{- $_ := set $config "accessKey" $secretUser -}}
  {{- end }}
  {{- $secretPass = index $secretData "MINIO_ROOT_PASSWORD" }}
  {{- if $secretPass }}
  {{- $_ := set $config "secretKey" $secretPass -}}
  {{- end }}
  {{- end }}

  {{- $_ := set $config "encrypt" false -}}
  {{- $_ := set $config "secure" false -}}
  {{- $_ := set $config "pathStyle" true -}}
{{- else -}}
  {{/* 使用外部S3 */}}
  {{- $_ := set $config "endpoint" $global.Values.objectStore.endpoint -}}
  {{- $_ := set $config "region" $global.Values.objectStore.region -}}
  {{- $_ := set $config "accessKey" $global.Values.objectStore.accessKey -}}
  {{- $_ := set $config "secretKey" $global.Values.objectStore.secretKey -}}
  {{- $_ := set $config "encrypt" $global.Values.objectStore.encrypt -}}
  {{- $_ := set $config "secure" $global.Values.objectStore.secure -}}
  {{- $_ := set $config "pathStyle" $global.Values.objectStore.pathStyle -}}
{{- end -}}

{{/* 服务级别的配置覆盖 */}}
{{- if $service.objectStore.endpoint -}}
  {{- $_ := set $config "endpoint" $service.objectStore.endpoint -}}
{{- end -}}
{{- if $service.objectStore.accessKey -}}
  {{- $_ := set $config "accessKey" $service.objectStore.accessKey -}}
{{- end -}}
{{- if $service.objectStore.secretKey -}}
  {{- $_ := set $config "secretKey" $service.objectStore.secretKey -}}
{{- end -}}
{{- if hasKey $service.objectStore "encrypt" -}}
  {{- $_ := set $config "encrypt" $service.objectStore.encrypt -}}
{{- end -}}
{{- if hasKey $service.objectStore "secure" -}}
  {{- $_ := set $config "secure" $service.objectStore.secure -}}
{{- end -}}
{{- if hasKey $service.objectStore "pathStyle" -}}
  {{- $_ := set $config "pathStyle" $service.objectStore.pathStyle -}}
{{- end -}}

{{/* 设置bucket */}}
{{- $_ := set $config "bucket" $service.objectStore.bucket -}}

{{- $config | toYaml -}}
{{- end -}}


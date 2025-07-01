{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
generate object store config
*/}}
{{- define "chart.objectStoreConfig" -}}
{{- $service := .service -}}
{{- $global := .global -}}
{{- $config := dict -}}

{{- if $global.Values.global.objectStore.enabled  -}}
  {{/* use internal minio */}}
  {{- $_ := set $config "endpoint" (include "minio.internal.endpoint" $global) -}}
  {{- $_ := set $config "region" "cn-north-1" -}}

  {{/* random secret   */}}
  {{- $secretUser := "minio" }}
  {{- $secretPass := (randAlphaNum 15) }}
  {{- $_ := set $config "accessKey" $secretUser -}}
  {{- $_ := set $config "secretKey" $secretPass -}}

  {{/* use secret if exists */}}
  {{- $secret := (include "common.names.custom" (list $global "minio")) -}}
  {{- $secretData := (lookup "v1" "Secret" $global.Release.Namespace $secret).data }}
  {{- if $secretData }}
  {{- $secretUser = index $secretData "MINIO_ROOT_USER" }}
  {{- if $secretUser }}
  {{- $_ := set $config "accessKey" ($secretUser | b64dec) -}}
  {{- end }}
  {{- $secretPass = index $secretData "MINIO_ROOT_PASSWORD" }}
  {{- if $secretPass }}
  {{- $_ := set $config "secretKey" ($secretPass | b64dec) -}}
  {{- end }}
  {{- end }}

  {{- $_ := set $config "encrypt" false -}}
  {{- $_ := set $config "secure" false -}}
  {{- $_ := set $config "pathStyle" true -}}
{{- else -}}
  {{/* use external object store */}}
  {{- $_ := set $config "endpoint" $global.Values.objectStore.endpoint -}}
  {{- $_ := set $config "region" $global.Values.objectStore.region -}}
  {{- $_ := set $config "accessKey" $global.Values.objectStore.accessKey -}}
  {{- $_ := set $config "secretKey" $global.Values.objectStore.secretKey -}}
  {{- $_ := set $config "encrypt" $global.Values.objectStore.encrypt -}}
  {{- $_ := set $config "secure" $global.Values.objectStore.secure -}}
  {{- $_ := set $config "pathStyle" $global.Values.objectStore.pathStyle -}}
{{- end -}}

{{/* service level config override */}}
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

{{/* set bucket */}}
{{- $_ := set $config "bucket" $service.objectStore.bucket -}}

{{- $config | toYaml -}}
{{- end -}}


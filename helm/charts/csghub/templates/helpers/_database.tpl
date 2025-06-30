{{/*
生成PostgreSQL配置的helper函数
*/}}
{{- define "csghub.postgresql.config" -}}
{{- $service := .service -}}
{{- $global := .global -}}
{{- $config := dict -}}

{{- if $global.Values.global.postgresql.enabled -}}
  {{/* 使用内部PostgreSQL */}}
  {{- $_ := set $config "host" (include "common.names.custom" (list $global "postgresql")) -}}
  {{- $_ := set $config "port" 5432 -}}
  {{- $_ := set $config "database" ($global.Values.postgresql.database) -}}

  {{- $user := $service.postgresql.user }}
  {{- $password := include "postgresql.initPass" $user }}

  {{- $secret := (include "common.names.custom" (list $global "postgresql")) -}}
  {{- $secretData := (lookup "v1" "Secret" $global.Release.Namespace $secret).data }}
  {{- if $secretData }}
  {{- $secretPassword := index $secretData $user }}
  {{- if $secretPassword }}
  {{- $password = $secretPassword | b64dec }}
  {{- end }}
  {{- end }}

  {{- $_ := set $config "user" $user -}}
  {{- $_ := set $config "password" $password -}}
  {{- $_ := set $config "timezone" "UTC" -}}
  {{- $_ := set $config "sslMode" "disable" -}}
{{- else -}}
  {{/* 使用外部PostgreSQL */}}
  {{- $_ := set $config "host" $global.Values.global.postgresql.host -}}
  {{- $_ := set $config "port" $global.Values.global.postgresql.port -}}
  {{- $_ := set $config "user" $global.Values.global.postgresql.user -}}
  {{- $_ := set $config "password" $global.Values.global.postgresql.password -}}
  {{- $_ := set $config "timezone" ($global.Values.global.postgresql.timezone | default "UTC") -}}
  {{- $_ := set $config "sslMode" ($global.Values.global.postgresql.sslMode | default "require") -}}
{{- end -}}

{{/* 服务级别的配置覆盖 */}}
{{- if $service.postgresql.host -}}
  {{- $_ := set $config "host" $service.postgresql.host -}}
{{- end -}}
{{- if $service.postgresql.port -}}
  {{- $_ := set $config "port" $service.postgresql.port -}}
{{- end -}}
{{- if $service.postgresql.database -}}
  {{- $_ := set $config "database" $service.postgresql.database -}}
{{- end -}}
{{- if $service.postgresql.user -}}
  {{- $_ := set $config "user" $service.postgresql.user -}}
{{- end -}}
{{- if $service.postgresql.password -}}
  {{- $_ := set $config "password" $service.postgresql.password -}}
{{- end -}}
{{- if $service.postgresql.timezone -}}
  {{- $_ := set $config "timezone" $service.postgresql.timezone -}}
{{- end -}}
{{- if $service.postgresql.sslMode -}}
  {{- $_ := set $config "sslMode" $service.postgresql.sslMode -}}
{{- end -}}

{{/* 设置其他可选配置 */}}
{{- if hasKey $global.Values.global.postgresql "maxConnections" -}}
  {{- $_ := set $config "maxConnections" $global.Values.global.postgresql.maxConnections -}}
{{- end -}}
{{- if hasKey $global.Values.global.postgresql "connectionTimeout" -}}
  {{- $_ := set $config "connectionTimeout" $global.Values.global.postgresql.connectionTimeout -}}
{{- end -}}

{{/* 确保端口是字符串 */}}
{{- $_ := set $config "port" ($config.port | toString) -}}

{{- $config | toYaml -}}
{{- end -}}

{{/*
兼容性helper函数 - 保持原有的API
*/}}
{{- define "csghub.postgresql.host" -}}
{{- $config := include "csghub.postgresql.config" (dict "service" (dict "postgresql" (dict)) "global" .) | fromYaml -}}
{{- $config.host -}}
{{- end }}

{{- define "csghub.postgresql.port" -}}
{{- $config := include "csghub.postgresql.config" (dict "service" (dict "postgresql" (dict)) "global" .) | fromYaml -}}
{{- $config.port -}}
{{- end }}

{{- define "csghub.postgresql.database" -}}
{{- $config := include "csghub.postgresql.config" (dict "service" (dict "postgresql" (dict)) "global" .) | fromYaml -}}
{{- $config.database -}}
{{- end }}

{{- define "csghub.postgresql.user" -}}
{{- $config := include "csghub.postgresql.config" (dict "service" (dict "postgresql" (dict)) "global" .) | fromYaml -}}
{{- $config.user -}}
{{- end }}

{{- define "csghub.postgresql.password" -}}
{{- $config := include "csghub.postgresql.config" (dict "service" (dict "postgresql" (dict)) "global" .) | fromYaml -}}
{{- $config.password -}}
{{- end }}

{{- define "csghub.postgresql.timezone" -}}
{{- $config := include "csghub.postgresql.config" (dict "service" (dict "postgresql" (dict)) "global" .) | fromYaml -}}
{{- $config.timezone -}}
{{- end }}

{{/*
生成PostgreSQL连接URL
*/}}
{{- define "csghub.postgresql.url" -}}
{{- $service := .service -}}
{{- $global := .global -}}
{{- $config := include "csghub.postgresql.config" . | fromYaml -}}
{{- printf "postgresql://%s:%s@%s:%s/%s?sslmode=%s&timezone=%s" $config.user $config.password $config.host $config.port $config.database $config.sslMode $config.timezone -}}
{{- end }}

{{/*
生成PostgreSQL DSN
*/}}
{{- define "csghub.postgresql.dsn" -}}
{{- $service := .service -}}
{{- $global := .global -}}
{{- $config := include "csghub.postgresql.config" . | fromYaml -}}
{{- printf "host=%s port=%s user=%s password=%s dbname=%s sslmode=%s" $config.host $config.port $config.user $config.password $config.database $config.sslMode -}}
{{- end }}
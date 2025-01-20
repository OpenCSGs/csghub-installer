{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Define the internal domain for casdoor
*/}}
{{- define "casdoor.internal.domain" -}}
{{- include "common.names.custom" (list . "casdoor") }}
{{- end }}

{{/*
Define the internal port for casdoor
*/}}
{{- define "casdoor.internal.port" -}}
{{- $port := "8000" }}
{{- if hasKey .Values.global "casdoor" }}
  {{- if hasKey .Values.global.casdoor "service" }}
    {{- if hasKey .Values.global.casdoor.service "port" }}
      {{- $port = .Values.global.casdoor.service.port | toString }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $port -}}
{{- end }}

{{/*
Define the internal endpoint for casdoor
*/}}
{{- define "casdoor.internal.endpoint" -}}
{{- printf "http://%s:%s" (include "casdoor.internal.domain" .) (include "casdoor.internal.port" .) }}
{{- end }}

{{/*
Define the external http domain for casdoor
*/}}
{{- define "casdoor.external.domain" -}}
{{- include "global.domain" (list . "casdoor-stg") }}
{{- end }}

{{/*
Define the external endpoint for casdoor
*/}}
{{- define "casdoor.external.endpoint" -}}
{{- $domain := include "casdoor.external.domain" . }}
{{- if eq .Values.global.ingress.service.type "NodePort" }}
{{- if .Values.global.ingress.tls.enabled -}}
{{- printf "https://%s:%s" $domain "30443" -}}
{{- else }}
{{- printf "http://%s:%s" $domain "30080" -}}
{{- end }}
{{- else }}
{{- if .Values.global.ingress.tls.enabled -}}
{{- printf "https://%s" $domain -}}
{{- else }}
{{- printf "http://%s" $domain -}}
{{- end }}
{{- end }}
{{- end }}

{{/*
Define postgresql dsn for casdoor
*/}}
{{- define "casdoor.postgresql.dsn" -}}
{{- $postgres_dsn := "" }}
{{- if not .Values.global.postgresql.external }}
{{- $host := include "postgresql.internal.domain" . }}
{{- $port := include "postgresql.internal.port" . }}
{{- $database := "csghub_casdoor" }}
{{- $user := $database }}
{{- $password := include "postgresql.initPass" $database }}
{{- $secret := (include "common.names.custom" (list . "postgresql")) -}}
{{- $secretData := (lookup "v1" "Secret" .Release.Namespace $secret).data }}
{{- if $secretData }}
{{- $password = index $secretData "csghub_casdoor" | b64dec }}
{{- end }}
{{- $postgres_dsn = (printf "user=%s password=%s host=%s port=%s sslmode=disable dbname=%s" $user $password $host $port $database) }}
{{- else }}
{{- with .Values.global.postgresql }}
{{- $postgres_dsn = (printf "user=%s password=%s host=%s port=%s sslmode=disable dbname=%s" .username .password .host .port .database) }}
{{- end }}
{{- end }}
{{- $postgres_dsn -}}
{{- end }}
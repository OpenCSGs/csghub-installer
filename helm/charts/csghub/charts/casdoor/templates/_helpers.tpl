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
      {{- $port = .Values.global.casdoor.service.port }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $port | toString -}}
{{- end }}

{{/*
Define the internal endpoint for casdoor
*/}}
{{- define "casdoor.internal.endpoint" -}}
{{- printf "http://%s:%s" (include "casdoor.internal.domain" .) (include "casdoor.internal.port" .) -}}
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
{{- $host := include "csghub.postgresql.host" . }}
{{- $port := include "csghub.postgresql.port" . }}
{{- $database := include "csghub.postgresql.database" . }}
{{- $user := include "csghub.postgresql.user" . }}
{{- $password := or (include "csghub.postgresql.password" .) (include "postgresql.initPass" $database) }}
{{- $secret := (include "common.names.custom" (list . "postgresql")) -}}
{{- $secretData := (lookup "v1" "Secret" .Release.Namespace $secret).data }}
{{- if $secretData }}
{{- $password = index $secretData $user | b64dec }}
{{- end }}
{{- printf "user=%s password=%s host=%s port=%s sslmode=disable dbname=%s" $user $password $host $port $database -}}
{{- end }}
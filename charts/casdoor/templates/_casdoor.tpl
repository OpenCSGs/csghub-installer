{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Define url for casdoor
*/}}
{{- define "casdoor.url" -}}
{{- $domain := include "external.domain.casdoor" . }}
{{- $port := include "csghub.port" . }}
{{- $tlsEnabled := false }}
{{- if hasKey .Values.global "casdoor" }}
  {{- if hasKey .Values.global.casdoor "ingress" }}
    {{- if hasKey .Values.global.casdoor.ingress "tls" }}
      {{- if hasKey .Values.global.casdoor.ingress.tls "enabled" }}
        {{- $tlsEnabled = .Values.global.casdoor.ingress.tls.enabled }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
{{- if $tlsEnabled }}
{{- printf "https://%s:%s" $domain $port }}
{{- else }}
{{- printf "http://%s:%s" $domain $port }}
{{- end }}
{{- end }}

{{/*
Define oauth url for casdoor
*/}}
{{- define "casdoor.postgresql.datasource" -}}
{{- $secret := (include "postgresql.secret" .) -}}
{{- $secretData := (lookup "v1" "Secret" .Release.Namespace $secret).data }}
{{- $password := include "postgresql.initPass" "casdoor_production" | b64enc }}
{{- if $secretData }}
{{- $password = index $secretData "casdoor" }}
{{- end }}
{{- if eq "true" (include "postgresql.enabled" .) }}
{{- printf "user=casdoor password=%s host=%s port=%s sslmode=disable dbname=casdoor_production" $password (include "postgresql.host" .) (include "postgresql.port" .) }}
{{- else }}
{{- printf "user=%s password=%s host=%s port=%s sslmode=disable dbname=%s" (include "server.postgresql.user" .) (include "server.postgresql.password" .) (include "server.postgresql.host" .) (include "server.postgresql.port" .) (include "server.postgresql.database" .) }}
{{- end }}
{{- end }}

{{/*
Define the secret of runner
*/}}
{{- define "casdoor.secret" }}
{{- printf "%s-%s-secret" .Release.Name "casdoor" }}
{{- end }}
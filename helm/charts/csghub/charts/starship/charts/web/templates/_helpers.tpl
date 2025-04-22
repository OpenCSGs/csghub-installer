{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Define the internal domain for web
*/}}
{{- define "web.internal.domain" -}}
{{- include "common.names.custom" (list . "web") }}
{{- end }}

{{/*
Define the internal port for web
*/}}
{{- define "web.internal.port" -}}
{{- $port := "8000" }}
{{- if hasKey .Values.global "web" }}
  {{- if hasKey .Values.global.web "service" }}
    {{- if hasKey .Values.global.web.service "port" }}
      {{- $port = .Values.global.web.service.port }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $port | toString -}}
{{- end }}

{{/*
Define the external endpoint for web
*/}}
{{- define "web.external.endpoint" -}}
{{- $domain := include "web.external.domain" . }}
{{- if eq .Values.global.ingress.service.type "NodePort" }}
{{- if eq (include "global.ingress.tls.enabled" .) "true" }}
{{- printf "%s:%s" $domain "30443" -}}
{{- else }}
{{- printf "%s:%s" $domain "30080" -}}
{{- end }}
{{- else }}
{{- printf "%s" $domain -}}
{{- end }}
{{- end }}

{{/*
Define the external endpoint for starship
*/}}
{{- define "starship.api.domain.withport" -}}
{{- $endpoint := include "starship.external.api.endpoint" . }}
{{- $parsedURL := urlParse $endpoint }}
{{- $port := 80 }}
{{- if eq $parsedURL.scheme "https" }}
{{- $port = 443 }}
{{- end }}
{{- printf "%s:%s" $parsedURL.host $port -}}
{{- end }}

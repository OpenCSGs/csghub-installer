{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Define the external domain for public
*/}}
{{- define "public.external.domain" -}}
{{- include "global.domain" (list . "public") }}
{{- end }}

{{/*
Define the external endpoint for public
*/}}
{{- define "public.external.endpoint" -}}
{{- $domain := include "proxy.external.domain" . }}
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
{{- printf "htts://%s" $domain -}}
{{- end }}
{{- end }}
{{- end }}
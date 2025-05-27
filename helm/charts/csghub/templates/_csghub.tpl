{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Define the external domain for csghub
*/}}
{{- define "csghub.external.domain" -}}
{{- $domain := include "global.domain" (list . "csghub") }}
{{- if hasKey .Values.global.ingress "useTop" }}
{{- if .Values.global.ingress.useTop }}
{{- $domain = .Values.global.ingress.domain }}
{{- end }}
{{- end }}
{{- $domain -}}
{{- end }}

{{/*
Define the external public domain for csghub
*/}}
{{- define "csghub.external.public.domain" -}}
{{- include "global.domain" (list . "public") -}}
{{- end }}

{{/*
Define the external endpoint for csghub
*/}}
{{- define "csghub.external.endpoint" -}}
{{- $domain := include "csghub.external.domain" . }}
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
Define the external public endpoint for csghub
*/}}
{{- define "csghub.external.public.endpoint" -}}
{{- $domain := include "csghub.external.public.domain" . }}
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
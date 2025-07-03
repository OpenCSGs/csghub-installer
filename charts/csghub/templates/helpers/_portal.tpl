{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Define the internal domain for portal
*/}}
{{- define "portal.internal.domain" -}}
{{- include "common.names.custom" (list . "portal") }}
{{- end }}

{{/*
Define the internal port for portal
*/}}
{{- define "portal.internal.port" -}}
{{ include "csghub.svc.port" "portal" }}
{{- end }}

{{/*
Define the internal endpoint for portal
*/}}
{{- define "portal.internal.endpoint" -}}
{{- printf "http://%s:%s" (include "portal.internal.domain" .) (include "portal.internal.port" .) -}}
{{- end }}

{{/*
Define the external domain for portal
*/}}
{{- define "portal.external.domain" -}}
{{- include "global.domain" (list . "portal") }}
{{- end }}

{{/*
Define the external endpoint for portal
*/}}
{{- define "portal.external.endpoint" -}}
{{- $domain := include "portal.external.domain" . }}
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
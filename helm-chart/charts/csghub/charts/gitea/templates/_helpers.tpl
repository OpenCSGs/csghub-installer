{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Define the internal domain for gitea
*/}}
{{- define "gitea.internal.domain" -}}
{{- include "common.names.custom" (list . "gitea") }}
{{- end }}

{{/*
Define the internal port for gitea
*/}}
{{- define "gitea.internal.port" -}}
{{- $port := "3001" }}
{{- if hasKey .Values.global "gitea" }}
  {{- if hasKey .Values.global.gitea "service" }}
    {{- if hasKey .Values.global.gitea.service "port" }}
      {{- $port = .Values.global.gitea.service.port | toString }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $port -}}
{{- end }}

{{/*
Define the internal endpoint for gitea
*/}}
{{- define "gitea.internal.endpoint" -}}
{{- printf "http://%s:%s" (include "gitea.internal.domain" .) (include "gitea.internal.port" .) }}
{{- end }}

{{/*
Define the external http domain for gitea
*/}}
{{- define "gitea.external.domain" -}}
{{- include "global.domain" (list . "gitea") }}
{{- end }}

{{/*
Define the external endpoint for gitea
*/}}
{{- define "gitea.external.endpoint" -}}
{{- $domain := include "gitea.external.domain" . }}
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
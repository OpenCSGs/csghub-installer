{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Define the internal domain for proxy
*/}}
{{- define "proxy.internal.domain" -}}
{{- include "common.names.custom" (list . "proxy") }}
{{- end }}

{{/*
Define the internal port for proxy
*/}}
{{- define "proxy.internal.port" -}}
{{- $port := "8083" }}
{{- if hasKey .Values.global "proxy" }}
  {{- if hasKey .Values.global.proxy "service" }}
    {{- if hasKey .Values.global.proxy.service "port" }}
      {{- $port = .Values.global.proxy.service.port | toString }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $port -}}
{{- end }}

{{/*
Define the internal endpoint for proxy
*/}}
{{- define "proxy.internal.endpoint" -}}
{{- printf "http://%s:%s" (include "proxy.internal.domain" .) (include "proxy.internal.port" .) }}
{{- end }}

{{/*
Define the ip of proxy nginx service self-managed
*/}}
{{- define "proxy.nginx.ip" -}}
{{- $ip := include "coredns.system" . }}
{{- $nip := regexReplaceAll "[0-9]+$" $ip "12" }}
{{- $nip -}}
{{- end }}

{{/*
Define the external domain for proxy
*/}}
{{- define "proxy.external.domain" -}}
{{- include "global.domain" (list . "proxy") }}
{{- end }}

{{/*
Define the external endpoint for proxy
*/}}
{{- define "proxy.external.endpoint" -}}
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
{{- printf "http://%s" $domain -}}
{{- end }}
{{- end }}
{{- end }}
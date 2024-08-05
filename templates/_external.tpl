{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Return the port of csghub external
*/}}
{{- define "csghub.port" -}}
{{- $port := "80" }}
{{- if hasKey .Values.global "ingress" }}
  {{- if hasKey .Values.global.ingress "service" }}
    {{- if hasKey .Values.global.ingress.service "type" }}
      {{- $type := .Values.global.ingress.service.type }}
        {{- if eq "NodePort" $type }}
          {{- if .Values.global.ingress.tls.enabled }}
            {{- $port = .Values.global.ingress.service.nodePorts.https | toString }}
          {{- else }}
            {{- $port = .Values.global.ingress.service.nodePorts.http | toString }}
          {{- end }}
        {{- else }}
          {{- if .Values.global.ingress.tls.enabled }}
            {{- $port = "443" | toString }}
          {{- end }}
        {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $port -}}
{{- end }}

{{/*
Return domain of csghub
*/}}
{{- define "csghub.domain" -}}
{{- $host := (include "external.csghub.domain" .) }}
{{- $port := include "csghub.port" . }}
{{- if gt (len $port | toString) "4" }}
{{- printf "%s:%s" $host $port -}}
{{- else }}
{{- $host -}}
{{- end }}
{{- end }}

{{/*
Define the endpoint of csghub external
*/}}
{{- define "csghub.external.url" -}}
{{- $prefix := "http://" }}
{{- if hasKey .Values.global "ingress" }}
  {{- if hasKey .Values.global.ingress "tls" }}
    {{- if hasKey .Values.global.ingress.tls "enabled" }}
      {{- if .Values.global.ingress.tls.enabled }}
        {{- $prefix = "https://" }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
{{- printf "%s%s" $prefix (include "csghub.domain" .) -}}
{{- end }}

{{/*
Define the service type of external
*/}}
{{- define "csghub.external.service.type" -}}
{{- $type := "ClusterIP" }}
{{- if hasKey .Values.global "ingress" }}
  {{- if hasKey .Values.global.ingress "service" }}
    {{- if hasKey .Values.global.ingress.service "type" }}
      {{- $type = .Values.global.ingress.service.type }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $type -}}
{{- end }}

{{/*
Judge if .Values.global.ingress.external.domain exists
*/}}
{{- define "ingress.external.domain" -}}
{{- $host := "example.com" }}
{{- if hasKey .Values.global "ingress" }}
  {{- if hasKey .Values.global.ingress "external" }}
    {{- if hasKey .Values.global.ingress.external "domain" }}
      {{- $host = .Values.global.ingress.external.domain }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $host -}}
{{- end }}

{{/*
Define the external domain for csghub
*/}}
{{- define "external.csghub.domain" -}}
{{- printf "csghub.%s" (include "ingress.external.domain" .) }}
{{- end }}

{{/*
Define the external domain for minio
*/}}
{{- define "external.minio.domain" -}}
{{- printf "minio.%s" (include "ingress.external.domain" .) }}
{{- end }}

{{/*
Define the external domain for registry
*/}}
{{- define "external.registry.domain" -}}
{{- printf "registry.%s" (include "ingress.external.domain" .) }}
{{- end }}

{{/*
Define the external domain for public
*/}}
{{- define "external.public.domain" -}}
{{- printf "public.%s" (include "ingress.external.domain" .) }}
{{- end }}
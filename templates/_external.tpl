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
{{- $host := (include "external.domain.csghub" .) }}
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
{{- define "csghub.url.external" -}}
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
{{- define "csghub.service.type.external" -}}
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
Judge if .Values.global.ingress.domain.external exists
*/}}
{{- define "ingress.domain.external" -}}
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
{{- define "external.domain.csghub" -}}
{{- printf "csghub.%s" (include "ingress.domain.external" .) }}
{{- end }}

{{/*
Define the external domain for minio
*/}}
{{- define "external.domain.minio" -}}
{{- printf "minio.%s" (include "ingress.domain.external" .) }}
{{- end }}

{{/*
Define the external domain for registry
*/}}
{{- define "external.domain.registry" -}}
{{- printf "registry.%s" (include "ingress.domain.external" .) }}
{{- end }}

{{/*
Define the external domain for casdoor
*/}}
{{- define "external.domain.casdoor" -}}
{{- printf "casdoor.%s" (include "ingress.domain.external" .) }}
{{- end }}

{{/*
Define the external domain for public
*/}}
{{- define "external.domain.public" -}}
{{- printf "public.%s" (include "ingress.domain.external" .) }}
{{- end }}

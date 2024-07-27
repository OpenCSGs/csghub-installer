{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Define the endpoint of space builder
*/}}
{{- define "builder.endpoint" }}
{{- printf "http://%s:%s" (include "builder.host" .) (include "builder.port" .) }}
{{- end }}

{{/*
Define the host of space builder
*/}}
{{- define "builder.host" }}
{{- printf "%s-%s-hl-svc" .Release.Name "builder" }}
{{- end }}

{{/*
Define the port of  space builder
*/}}
{{- define "builder.port" }}
{{- $port := "8080" }}
{{- if hasKey .Values.global "builder" }}
  {{- if hasKey .Values.global.builder "service" }}
    {{- if hasKey .Values.global.builder.service "port" }}
      {{- $port = .Values.global.builder.service.port }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $port -}}
{{- end }}

{{/*
Define the public domain of space builder
*/}}
{{- define "builder.public.domain" -}}
{{- $host := "csghub.public.com" }}
{{- $port := "80" }}
{{- if hasKey .Values.global "builder" }}
  {{- if hasKey .Values.global.builder "ingress" }}
    {{- if hasKey .Values.global.builder.ingress "host" }}
      {{- $host = .Values.global.builder.ingress.host }}
    {{- end }}
    {{- if hasKey .Values.global.ingress.external "port" }}
      {{- $port = .Values.global.ingress.external.port | toString }}
    {{- end }}
  {{- end }}
{{- end }}
{{- if or (eq "80" $port) (eq "443" $port) }}
{{- $host -}}
{{- else }}
{{- printf "%s:%s" $host $port -}}
{{- end }}
{{- end }}

{{/*
Define the internal domain of space builder
*/}}
{{- define "builder.internal.domain" }}
{{- $domain := "app.internal" }}
{{- if hasKey .Values.global "builder" }}
  {{- if hasKey .Values.global.builder "internal" }}
    {{- if hasKey .Values.global.builder.internal "domain" }}
      {{- $domain = .Values.global.builder.internal.domain }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $domain -}}
{{- end }}

{{/*
Define the internal port of space builder
*/}}
{{- define "builder.internal.port" }}
{{- $port := "80" }}
{{- if hasKey .Values.global "builder" }}
  {{- if hasKey .Values.global.builder "internal" }}
    {{- if hasKey .Values.global.builder.internal "port" }}
      {{- $port = .Values.global.builder.internal.port | toString }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $port -}}
{{- end }}

{{/*
Define the full internal domain of space builder
*/}}
{{- define "builder.full.internal.domain" }}
{{- $namespace := include "runner.namespace" . }}
{{- $domain := include "builder.internal.domain" . }}
{{- $port := include "builder.internal.port" . }}
{{- if or (eq "80" $port) (eq "443" $port) }}
{{- printf "%s.%s" $namespace $domain -}}
{{- else }}
{{- printf "%s.%s:%s" $namespace $domain $port -}}
{{- end }}
{{- end }}

{{/*
Define the host of space builder
*/}}
{{- define "builder.docker.cm" }}
{{- printf "%s-%s-docker-cm" .Release.Name "builder" }}
{{- end }}

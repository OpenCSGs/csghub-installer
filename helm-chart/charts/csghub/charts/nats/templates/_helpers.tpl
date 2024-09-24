{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Define the internal domain for nats
*/}}
{{- define "nats.internal.domain" -}}
{{- include "common.names.custom" (list . "nats") }}
{{- end }}

{{/*
Define the internal api port for nats
*/}}
{{- define "nats.internal.ports.api" -}}
{{- $port := "4222" }}
{{- if hasKey .Values.global "nats" }}
  {{- if hasKey .Values.global.nats "service" }}
    {{- if hasKey .Values.global.nats.service "ports" }}
      {{- if hasKey .Values.global.nats.service.ports "api" }}
        {{- $port = .Values.global.nats.service.ports.api | toString }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $port -}}
{{- end }}

{{/*
Define the internal cluster port for nats
*/}}
{{- define "nats.internal.ports.cluster" -}}
{{- $port := "6222" }}
{{- if hasKey .Values.global "nats" }}
  {{- if hasKey .Values.global.nats "service" }}
    {{- if hasKey .Values.global.nats.service "ports" }}
      {{- if hasKey .Values.global.nats.service.ports "cluster" }}
        {{- $port = .Values.global.nats.service.ports.cluster | toString }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $port -}}
{{- end }}

{{/*
Define the internal monitor port for nats
*/}}
{{- define "nats.internal.ports.monitor" -}}
{{- $port := "8222" }}
{{- if hasKey .Values.global "nats" }}
  {{- if hasKey .Values.global.nats "service" }}
    {{- if hasKey .Values.global.nats.service "ports" }}
      {{- if hasKey .Values.global.nats.service.ports "monitor" }}
        {{- $port = .Values.global.nats.service.ports.monitor | toString }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $port -}}
{{- end }}

{{/*
Define the internal api endpoint for nats
*/}}
{{- define "nats.internal.endpoints.api" -}}
{{- printf "http://%s:%s" (include "nats.internal.domain" .) (include "nats.internal.ports.api" .) }}
{{- end }}

{{/*
Define the internal cluster endpoint for nats
*/}}
{{- define "nats.internal.endpoints.cluster" -}}
{{- printf "http://%s:%s" (include "nats.internal.domain" .) (include "nats.internal.ports.cluster" .) }}
{{- end }}

{{/*
Define the internal monitor endpoint for nats
*/}}
{{- define "nats.internal.endpoints.monitor" -}}
{{- printf "http://%s:%s" (include "nats.internal.domain" .) (include "nats.internal.ports.monitor" .) }}
{{- end }}
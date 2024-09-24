{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Random Password for which password not set
*/}}
{{- define "nats.initPass" -}}
{{- printf "%s@%s" (now | date "15/04") . | sha256sum | trunc 16 | b64enc | b64enc -}}
{{- end }}

{{/*
Define the host of nats
*/}}
{{- define "nats.host" -}}
{{- printf "%s-%s-svc" .Release.Name "nats" }}
{{- end }}

{{/*
Define the api port of nats
*/}}
{{- define "nats.ports.api" }}
{{- $port := "" }}
{{- if hasKey .Values.global "nats" }}
  {{- if hasKey .Values.global.nats "service" }}
    {{- if hasKey .Values.global.nats.service "ports" }}
      {{- if hasKey .Values.global.nats.service.ports "api" }}
        {{- $port = .Values.global.nats.service.ports.api }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $port | default "4222" -}}
{{- end }}

{{/*
Define the cluster port of nats
*/}}
{{- define "nats.ports.cluster" }}
{{- $port := "" }}
{{- if hasKey .Values.global "nats" }}
  {{- if hasKey .Values.global.nats "service" }}
    {{- if hasKey .Values.global.nats.service "ports" }}
      {{- if hasKey .Values.global.nats.service.ports "cluster" }}
        {{- $port = .Values.global.nats.service.ports.cluster }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $port | default "6222" -}}
{{- end }}

{{/*
Define the monitor port of nats
*/}}
{{- define "nats.ports.monitor" }}
{{- $port := "" }}
{{- if hasKey .Values.global "nats" }}
  {{- if hasKey .Values.global.nats "service" }}
    {{- if hasKey .Values.global.nats.service "ports" }}
      {{- if hasKey .Values.global.nats.service.ports "monitor" }}
        {{- $port = .Values.global.nats.service.ports.monitor }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $port | default "8222" -}}
{{- end }}

{{/*
Define the secret of nats
*/}}
{{- define "nats.secret" -}}
{{- printf "%s-%s-secret" .Release.Name "nats" }}
{{- end }}
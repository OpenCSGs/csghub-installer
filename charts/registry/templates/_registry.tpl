{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Define the endpoint of registry
*/}}
{{- define "registry.endpoint" -}}
{{- $host := include "registry.host" . }}
{{- $port := include "registry.port" . }}
{{- $type := "ClusterIP" }}
{{- if hasKey .Values.global "registry" }}
    {{- if hasKey .Values.global.registry "ingress" }}
        {{- if hasKey .Values.global.registry.ingress "enabled" }}
            {{- if .Values.global.registry.ingress.enabled }}
              {{- if hasKey .Values.global.registry.ingress "host" }}
                {{- $host = .Values.global.registry.ingress.host }}
              {{- end }}
            {{- end }}
        {{- end }}
    {{- end }}
    {{- if hasKey .Values.global.registry "service" }}
      {{- if hasKey .Values.global.registry.service "type" }}
        {{- $type = .Values.global.registry.service.type }}
      {{- end }}
    {{- end }}
{{- end }}
{{- if and (eq "NodePort" $type) (ne "80" $port) (ne "443" $port) }}
{{- printf "%s:%s" $host $port -}}
{{- else }}
{{- printf "%s" $host -}}
{{- end }}
{{- end }}

{{/*
Define the host of registry
*/}}
{{- define "registry.host" -}}
{{- printf "%s-%s-hl-svc" .Release.Name "registry" -}}
{{- end }}

{{/*
Define the port of registry
*/}}
{{- define "registry.port" -}}
{{- $port := "5000" }}
{{- if hasKey .Values.global "registry" }}
  {{- if hasKey .Values.global.registry "service" }}
    {{- if hasKey .Values.global.registry.service "port" }}
      {{- $port = .Values.global.registry.service.port }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $port -}}
{{- end }}
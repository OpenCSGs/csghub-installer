{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Define domain of gitea with route
*/}}
{{- define "gitea.domain" -}}
{{- printf "%s/gitea" (include "csghub.domain" .) }}
{{- end }}

{{/*
Define the root url of gitea
*/}}
{{- define "gitea.url.root" -}}
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
{{- printf "%s%s" $prefix (include "gitea.domain" .) -}}
{{- end }}

{{/*
Return the endpoint of gitea
*/}}
{{- define "gitea.endpoint" -}}
{{- printf "http://%s:%s" (include "gitea.host.http" .) (include "gitea.port.http" .) }}
{{- end }}

{{/*
Define the host of gitea
*/}}
{{- define "gitea.host.http" -}}
{{- printf "%s-%s-http" .Release.Name "gitea" }}
{{- end }}

{{/*
Define the host of gitea
*/}}
{{- define "gitea.host.ssh" -}}
{{- printf "%s-%s-ssh" .Release.Name "gitea" }}
{{- end }}

{{/*
Define the http port of gitea
*/}}
{{- define "gitea.port.http" -}}
{{- $port := "3001" }}
{{- if hasKey .Values.global "gitea" }}
  {{- if hasKey .Values.global.gitea "service" }}
    {{- if hasKey .Values.global.gitea.service "ports" }}
      {{- if hasKey .Values.global.gitea.service.ports "http" }}
        {{- $port = .Values.global.gitea.service.ports.http }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $port -}}
{{- end }}

{{/*
Define the ssh port of gitea
*/}}
{{- define "gitea.port.ssh" -}}
{{- $port := "22" }}
{{- if eq "NodePort" (include "csghub.service.type.external" .)}}
  {{- if hasKey .Values.global.ingress.service "nodePorts" }}
    {{- if hasKey .Values.global.ingress.service.nodePorts "tcp" }}
      {{- range $key, $nport := .Values.global.ingress.service.nodePorts.tcp }}
        {{- $port = $nport | toString }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $port -}}
{{- end }}

{{/*
Define the secret of gitea
*/}}
{{- define "gitea.secret" -}}
{{- printf "%s-%s-secret" .Release.Name "gitea" }}
{{- end }}
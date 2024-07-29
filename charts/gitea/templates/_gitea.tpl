{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Define domain of gitea with route
*/}}
{{- define "gitea.domain" -}}
{{- printf "%s/admin" (include "csghub.domain" .) }}
{{- end }}

{{/*
Define the root url of gitea
*/}}
{{- define "gitea.root.url" -}}
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
{{- printf "http://%s:%s" (include "gitea.host" .) (include "gitea.port" .) }}
{{- end }}

{{/*
Define the host of gitea
*/}}
{{- define "gitea.host" -}}
{{- printf "%s-%s-http" .Release.Name "gitea" }}
{{- end }}

{{/*
Define the host of gitea
*/}}
{{- define "gitea.ssh" -}}
{{- printf "%s-%s-ssh" .Release.Name "gitea" }}
{{- end }}

{{/*
Define the port of gitea
*/}}
{{- define "gitea.port" -}}
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
{{- define "gitea.ssh.port" -}}
{{- $port := "22" }}
{{- if hasKey .Values.global "ingress" }}
  {{- if hasKey .Values.global.ingress "service" }}
    {{- if hasKey .Values.global.ingress.service "type" }}
      {{- $type := .Values.global.ingress.service.type }}
        {{- if eq "NodePort" $type }}
          {{- range $key, $nport := .Values.global.ingress.service.nodePorts.tcp }}
            {{- $port = $nport | toString }}
          {{- end }}
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
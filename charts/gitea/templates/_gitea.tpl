{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Define domain of gitea with route
*/}}
{{- define "gitea.domain" -}}
{{- printf "%s/gitserver" (include "csghub.domain" .) }}
{{- end }}

{{/*
Define the endpoint of gitea
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
{{- printf "%s/%s" $prefix (include "gitea.domain" .) -}}
{{- end }}

{{/*
Return the root url of gitea
*/}}
{{- define "gitea.endpoint" -}}
{{- printf "http://%s:%s" (include "gitea.host" .) (include "gitea.port" .) }}
{{- end }}

{{/*
Define the host of gitea
*/}}
{{- define "gitea.host" -}}
{{- printf "%s-%s-hl-svc" .Release.Name "gitea" }}
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
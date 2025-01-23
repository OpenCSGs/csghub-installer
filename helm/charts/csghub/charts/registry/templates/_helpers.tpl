{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Define the external domain for registry
*/}}
{{- define "registry.external.domain" -}}
{{- include "global.domain" (list . "registry-stg") }}
{{- end }}

{{/*
Define the external endpoint for registry
*/}}
{{- define "registry.external.endpoint" -}}
{{- $domain := include "registry.external.domain" . }}
{{- if eq .Values.global.ingress.service.type "NodePort" }}
{{- if eq (include "global.ingress.tls.enabled" .) "true" }}
{{- printf "%s:%s" $domain "30443" -}}
{{- else }}
{{- printf "%s:%s" $domain "30080" -}}
{{- end }}
{{- else }}
{{- printf "%s" $domain -}}
{{- end }}
{{- end }}

{{/*
Random Password for which password not set
*/}}
{{- define "registry.initPass" -}}
{{- printf "%s@%s" (now | date "15/04") . | sha256sum | trunc 16 | b64enc | b64enc -}}
{{- end }}
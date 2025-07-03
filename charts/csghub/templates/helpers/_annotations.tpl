{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Common deployment annotations
*/}}
{{- define "common.annotations.deployment" -}}
{{- with .Values.annotations }}
{{- toYaml . }}
{{- end }}
{{- end -}}

{{/*
Resource dependencies annotation
This is used to indicate which resources this component depends on
*/}}
{{- define "common.annotations.dependencies" -}}
{{- if .dependencies }}
resource.dependencies/deployments: |
{{- range .dependencies }}
  {{ . }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
Standard ingress annotations for nginx
*/}}
{{- define "common.annotations.ingress.nginx" -}}
nginx.ingress.kubernetes.io/enable-cors: "true"
{{- if .auth }}
nginx.ingress.kubernetes.io/auth-type: basic
nginx.ingress.kubernetes.io/auth-secret: {{ .auth.secret }}
nginx.ingress.kubernetes.io/auth-realm: {{ .auth.realm | default "Authentication Required" | quote }}
{{- end }}
{{- with .custom }}
{{- toYaml . }}
{{- end }}
{{- end -}}

{{/*
Helm hook annotations for jobs
*/}}
{{- define "common.annotations.helm.hooks" -}}
{{- if .preInstall }}
"helm.sh/hook": pre-install,pre-upgrade
{{- else if .postInstall }}
"helm.sh/hook": post-install,post-upgrade
{{- end }}
{{- if .deletePolicy }}
"helm.sh/hook-delete-policy": {{ .deletePolicy }}
{{- else }}
"helm.sh/hook-delete-policy": before-hook-creation,hook-succeeded
{{- end }}
{{- end -}}

{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Define the repository for csghub registry
*/}}
{{- define "csghub.registry.repository" -}}
{{- $repository := include "registry.external.endpoint" . }}
{{- if hasKey .Values.global "registry" }}
{{- if hasKey .Values.global.registry "external" }}
{{- if .Values.global.registry.external }}
{{- if hasKey .Values.global.registry "connection" }}
{{- if hasKey .Values.global.registry.connection "repository" }}
{{- $repository = .Values.global.registry.connection.repository }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- $repository -}}
{{- end }}

{{/*
Define the namespace for csghub registry
*/}}
{{- define "csghub.registry.namespace" -}}
{{- $namespace := "csghub" }}
{{- if hasKey .Values "connection" }}
{{- if hasKey .Values.connection "namespace" }}
{{- $namespace = .Values.connection.namespace }}
{{- end }}
{{- end }}
{{- if hasKey .Values.global "registry" }}
{{- if hasKey .Values.global.registry "external" }}
{{- if .Values.global.registry.external }}
{{- if hasKey .Values.global.registry "connection" }}
{{- if hasKey .Values.global.registry.connection "namespace" }}
{{- $namespace = .Values.global.registry.connection.namespace }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- $namespace -}}
{{- end }}

{{/*
Define the username for csghub registry
*/}}
{{- define "csghub.registry.username" -}}
{{- $username := "registry" }}
{{- if hasKey .Values "connection" }}
{{- if hasKey .Values.connection "username" }}
{{- $username = .Values.connection.username }}
{{- end }}
{{- end }}
{{- if hasKey .Values.global "registry" }}
{{- if hasKey .Values.global.registry "external" }}
{{- if .Values.global.registry.external }}
{{- if hasKey .Values.global.registry "connection" }}
{{- if hasKey .Values.global.registry.connection "username" }}
{{- $username = .Values.global.registry.connection.username }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- $username -}}
{{- end }}

{{/*
Define the password for csghub registry
*/}}
{{- define "csghub.registry.password" -}}
{{- $password := include "registry.initPass" (include "csghub.registry.username" .) }}
{{- if hasKey .Values "connection" }}
{{- if hasKey .Values.connection "password" }}
{{- $password = .Values.connection.password }}
{{- end }}
{{- end }}
{{- if hasKey .Values.global "registry" }}
{{- if hasKey .Values.global.registry "external" }}
{{- if .Values.global.registry.external }}
{{- if hasKey .Values.global.registry "connection" }}
{{- if hasKey .Values.global.registry.connection "password" }}
{{- $password = .Values.global.registry.connection.password }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- $password -}}
{{- end }}
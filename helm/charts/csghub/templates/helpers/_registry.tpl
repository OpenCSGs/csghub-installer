{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Define the repository for csghub registry
*/}}
{{- define "csghub.registry.repository" -}}
{{- $repository := or .Values.registry.repository (include "registry.external.endpoint" .) }}
{{- if hasKey .Values.global "registry" }}
{{- if hasKey .Values.global.registry "external" }}
{{- if .Values.global.registry.external }}
{{- if hasKey .Values.global.registry "connection" }}
{{- if hasKey .Values.global.registry.connection "repository" }}
{{- if .Values.global.registry.connection.repository }}
{{- $repository = .Values.global.registry.connection.repository }}
{{- end }}
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
{{- $namespace := or .Values.registry.namespace .Release.Name }}
{{- if hasKey .Values.global "registry" }}
{{- if hasKey .Values.global.registry "external" }}
{{- if .Values.global.registry.external }}
{{- if hasKey .Values.global.registry "connection" }}
{{- if hasKey .Values.global.registry.connection "namespace" }}
{{- if .Values.global.registry.connection.namespace }}
{{- $namespace = .Values.global.registry.connection.namespace }}
{{- end }}
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
{{- $username := .Values.registry.username }}
{{- if hasKey .Values.global "registry" }}
{{- if hasKey .Values.global.registry "external" }}
{{- if .Values.global.registry.external }}
{{- if hasKey .Values.global.registry "connection" }}
{{- if hasKey .Values.global.registry.connection "username" }}
{{- if .Values.global.registry.connection.username }}
{{- $username = .Values.global.registry.connection.username }}
{{- end }}
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
{{- $password := or .Values.registry.password (include "registry.initPass" (include "csghub.registry.username" .)) }}
{{- if hasKey .Values.global "registry" }}
{{- if hasKey .Values.global.registry "external" }}
{{- if .Values.global.registry.external }}
{{- if hasKey .Values.global.registry "connection" }}
{{- if hasKey .Values.global.registry.connection "password" }}
{{- if .Values.global.registry.connection.password }}
{{- $password = .Values.global.registry.connection.password }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- $password -}}
{{- end }}
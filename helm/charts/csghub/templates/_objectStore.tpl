{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Define the endpoint for csghub objectStore
*/}}
{{- define "csghub.objectStore.endpoint" -}}
{{- $endpoint := or .Values.objectStore.endpoint (include "minio.external.endpoint" .) }}
{{- if hasKey .Values.global "objectStore" }}
{{- if hasKey .Values.global.objectStore "external" }}
{{- if .Values.global.objectStore.external }}
{{- if hasKey .Values.global.objectStore "connection" }}
{{- if hasKey .Values.global.objectStore.connection "endpoint" }}
{{- if .Values.global.objectStore.connection.endpoint }}
{{- $endpoint = .Values.global.objectStore.connection.endpoint }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- $endpoint -}}
{{- end }}

{{/*
Define the accessKey for csghub objectStore
*/}}
{{- define "csghub.objectStore.accessKey" -}}
{{- $accessKey := .Values.objectStore.accessKey }}
{{- if hasKey .Values.global "objectStore" }}
{{- if hasKey .Values.global.objectStore "external" }}
{{- if .Values.global.objectStore.external }}
{{- if hasKey .Values.global.objectStore "connection" }}
{{- if hasKey .Values.global.objectStore.connection "accessKey" }}
{{- if .Values.global.objectStore.connection.accessKey }}
{{- $accessKey = .Values.global.objectStore.connection.accessKey }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- $accessKey -}}
{{- end }}

{{/*
Define the accessSecret for csghub objectStore
*/}}
{{- define "csghub.objectStore.accessSecret" -}}
{{- $accessSecret := or .Values.objectStore.accessSecret (randAlphaNum 15) }}
{{- if hasKey .Values.global "objectStore" }}
{{- if hasKey .Values.global.objectStore "external" }}
{{- if .Values.global.objectStore.external }}
{{- if hasKey .Values.global.objectStore "connection" }}
{{- if hasKey .Values.global.objectStore.connection "accessSecret" }}
{{- if .Values.global.objectStore.connection.accessSecret }}
{{- $accessSecret = .Values.global.objectStore.connection.accessSecret }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- $accessSecret -}}
{{- end }}

{{/*
Define the bucket for csghub objectStore
*/}}
{{- define "csghub.objectStore.bucket" -}}
{{- $bucket := .Values.objectStore.bucket }}
{{- if hasKey .Values.global "objectStore" }}
{{- if hasKey .Values.global.objectStore "external" }}
{{- if .Values.global.objectStore.external }}
{{- if hasKey .Values.global.objectStore "connection" }}
{{- if hasKey .Values.global.objectStore.connection "bucket" }}
{{- if .Values.global.objectStore.connection.bucket }}
{{- $bucket = .Values.global.objectStore.connection.bucket }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- $bucket -}}
{{- end }}

{{/*
Define the region for csghub objectStore
*/}}
{{- define "csghub.objectStore.region" -}}
{{- $region := .Values.objectStore.region }}
{{- if hasKey .Values.global "objectStore" }}
{{- if hasKey .Values.global.objectStore "external" }}
{{- if .Values.global.objectStore.external }}
{{- if hasKey .Values.global.objectStore "connection" }}
{{- if hasKey .Values.global.objectStore.connection "region" }}
{{- if .Values.global.objectStore.connection.region }}
{{- $region = .Values.global.objectStore.connection.region }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- $region -}}
{{- end }}

{{/*
Define the encrypt for csghub objectStore
*/}}
{{- define "csghub.objectStore.encrypt" -}}
{{- $encrypt := .Values.objectStore.encrypt }}
{{- if eq (include "global.ingress.tls.enabled" .) "true" }}
{{- $encrypt = "true" }}
{{- end }}
{{- if hasKey .Values.global "objectStore" }}
{{- if hasKey .Values.global.objectStore "external" }}
{{- if .Values.global.objectStore.external }}
{{- if hasKey .Values.global.objectStore "connection" }}
{{- if hasKey .Values.global.objectStore.connection "encrypt" }}
{{- if .Values.global.objectStore.connection.encrypt }}
{{- $encrypt = .Values.global.objectStore.connection.encrypt }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- $encrypt -}}
{{- end }}

{{/*
Define the secure for csghub objectStore
*/}}
{{- define "csghub.objectStore.secure" -}}
{{- $secure := .Values.objectStore.secure }}
{{- if eq (include "global.ingress.tls.enabled" .) "true" }}
{{- $secure = "true" }}
{{- end }}
{{- if hasKey .Values.global "objectStore" }}
{{- if hasKey .Values.global.objectStore "external" }}
{{- if .Values.global.objectStore.external }}
{{- if hasKey .Values.global.objectStore "connection" }}
{{- if hasKey .Values.global.objectStore.connection "secure" }}
{{- if .Values.global.objectStore.connection.secure }}
{{- $secure = .Values.global.objectStore.connection.secure }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- $secure -}}
{{- end }}

{{/*
Define the pathStyle for csghub objectStore
*/}}
{{- define "csghub.objectStore.pathStyle" -}}
{{- $pathStyle := .Values.objectStore.pathStyle }}
{{- if hasKey .Values.global "objectStore" }}
{{- if hasKey .Values.global.objectStore "external" }}
{{- if .Values.global.objectStore.external }}
{{- if hasKey .Values.global.objectStore "connection" }}
{{- if hasKey .Values.global.objectStore.connection "pathStyle" }}
{{- if .Values.global.objectStore.connection.pathStyle }}
{{- $pathStyle = .Values.global.objectStore.connection.pathStyle }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- $pathStyle -}}
{{- end }}

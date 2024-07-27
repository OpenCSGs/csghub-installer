{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Define the host of coredns
*/}}
{{- define "coredns.host" -}}
{{- printf "%s-%s-svc" .Release.Name "coredns" }}
{{- end }}
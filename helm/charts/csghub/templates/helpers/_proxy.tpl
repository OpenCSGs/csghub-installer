{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Define the ip of proxy nginx service self-managed
*/}}
{{- define "rproxy.nginx.ip" -}}
{{- $ip := include "system.coredns.ip" . }}
{{- $nip := regexReplaceAll "[0-9]+$" $ip "149" }}
{{- $nip -}}
{{- end }}

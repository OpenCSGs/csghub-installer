{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}


{{/*
Define the ip of proxy nginx service self-managed
*/}}
{{- define "proxy.dns.nginx" -}}
{{- $ip := include "coredns.dns.kube" . }}
{{- $newIP := regexReplaceAll "[0-9]+$" $ip "101" }}
{{- $newIP -}}
{{- end }}
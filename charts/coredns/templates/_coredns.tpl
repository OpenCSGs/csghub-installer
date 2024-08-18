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

{{/*
Define the ip of coredns within kube-system
*/}}
{{- define "coredns.dns.kube" -}}
{{- $kubeDNSClusterIP := "10.96.0.10"}}
{{- $kubeDNS := (lookup "v1" "Service" "kube-system" "kube-dns") }}
{{- if $kubeDNS }}
{{- $kubeDNSClusterIP = $kubeDNS.spec.clusterIP }}
{{- $kubeDNSClusterIP -}}
{{- end }}
{{- end }}

{{/*
Define the ip of kourier service
*/}}
{{- define "coredns.svc.kourier" -}}
{{- $kourierDNSClusterIP := "127.0.0.1" }}
{{- $kourierDNS := (lookup "v1" "Service" "kourier-system" "kourier-internal") }}
{{- if $kourierDNS }}
{{- $kourierDNSClusterIP = $kourierDNS.spec.clusterIP }}
{{- $kourierDNSClusterIP -}}
{{- end }}
{{- end }}

{{/*
Define the ip of coredns self-managed
*/}}
{{- define "coredns.dns.self" -}}
{{- $ip := include "coredns.dns.kube" . }}
{{- $newIP := regexReplaceAll "[0-9]+$" $ip "100" }}
{{- $newIP -}}
{{- end }}
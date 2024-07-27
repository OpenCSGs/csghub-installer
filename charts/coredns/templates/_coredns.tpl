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
{{- define "coredns.kube.dns" -}}
{{- $kubeDNSClusterIP := (lookup "v1" "Service" "kube-system" "kube-dns").spec.clusterIP }}
{{- $kubeDNSClusterIP -}}
{{- end }}

{{/*
Define the ip of kourier service
*/}}
{{- define "coredns.kourier.svc" -}}
{{- $kourierDNSClusterIP := (lookup "v1" "Service" "kourier-system" "kourier-internal").spec.clusterIP }}
{{- $kourierDNSClusterIP -}}
{{- end }}

{{/*
Define the ip of coredns self-managed
*/}}
{{- define "coredns.self.dns" -}}
{{- $ip := include "coredns.kube.dns" . }}
{{- $newIP := regexReplaceAll "[0-9]+$" $ip "100" }}
{{- $newIP -}}
{{- end }}
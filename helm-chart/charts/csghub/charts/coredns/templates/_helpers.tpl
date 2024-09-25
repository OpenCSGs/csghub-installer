{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Define the ip of coredns within kube-system
*/}}
{{- define "coredns.system" -}}
{{- $kubeDNSClusterIP := ""}}
{{- $kubeDNS := (lookup "v1" "Service" "kube-system" "kube-dns") }}
{{- if $kubeDNS }}
{{- $kubeDNSClusterIP = $kubeDNS.spec.clusterIP }}
{{- $kubeDNSClusterIP -}}
{{- end }}
{{- end }}

{{/*
Define the ip of coredns self-managed
*/}}
{{- define "coredns.csghub" -}}
{{- $kubeDNSClusterIP := include "coredns.system" . }}
{{- $csghubDNSClusterIP := regexReplaceAll "[0-9]+$" $kubeDNSClusterIP "11" }}
{{- $csghubDNSClusterIP -}}
{{- end }}
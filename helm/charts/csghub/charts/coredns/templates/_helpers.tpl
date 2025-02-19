{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Define the ip of coredns within kube-system
*/}}
{{- define "system.coredns.ip" -}}
{{- $kubeDNSClusterIP := ""}}
{{- $kubeDNS := (lookup "v1" "Service" "kube-system" "kube-dns") }}
{{- if not $kubeDNS }}
{{- $kubeDNS = (lookup "v1" "Service" "kube-system" "coredns") }}
{{- end }}
{{- if $kubeDNS }}
{{- $kubeDNSClusterIP = $kubeDNS.spec.clusterIP }}
{{- $kubeDNSClusterIP -}}
{{- end }}
{{- end }}

{{/*
Define the ip of coredns self-managed
*/}}
{{- define "coredns.csghub" -}}
{{- $kubeDNSClusterIP := include "system.coredns.ip" . }}
{{- $csghubDNSClusterIP := regexReplaceAll "[0-9]+$" $kubeDNSClusterIP "166" }}
{{- $csghubDNSClusterIP -}}
{{- end }}
{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Define the external domain
*/}}
{{- define "global.domain" -}}
{{- $ctx := index . 0 }}
{{- $subDomain := index . 1 }}
{{- if hasKey $ctx.Values.global "ingress" }}
    {{- if hasKey $ctx.Values.global.ingress "domain" }}
      {{- $domain := $ctx.Values.global.ingress.domain }}
      {{- if $domain }}
        {{- printf "%s.%s" $subDomain $domain }}
      {{- else }}
        {{ fail "A valid domain entry (like example.com) is required!" }}
      {{- end }}
    {{- else }}
      {{ fail "Global domain is not defined!" }}
    {{- end }}
  {{- end }}
{{- end }}

{{- define "cluster.domain" -}}
{{- $clusterDomain := "" -}}
{{- $kubeDNS := (lookup "v1" "ConfigMap" "kube-system" "kube-dns") }}
{{- if $kubeDNS }}
  {{- if $kubeDNS.data.domain }}
    {{- $clusterDomain = $kubeDNS.data.domain }}
  {{- end }}
{{- end -}}
{{- if not $clusterDomain }}
  {{- $coreDNS := (lookup "v1" "ConfigMap" "kube-system" "coredns") }}
  {{- if $coreDNS }}
    {{- if $coreDNS.data.Corefile }}
      {{- if contains "cluster.local" $coreDNS.data.Corefile }}
        {{- $clusterDomain = "cluster.local" }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end -}}
{{- if not $clusterDomain }}
  {{- $clusterDomain = "cluster.local" }}
{{- end -}}
{{- $clusterDomain -}}
{{- end -}}
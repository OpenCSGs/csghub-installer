{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{ define "common.checkDeprecated" }}

{{- if hasKey .Values.dataflow "enabled" }}
{{ fail "ERROR: 'dataflow.enabled' is deprecated. Please use 'global.dataflow.enabled' instead." }}
{{- end }}

{{- if hasKey .Values.global "deployment" }}
{{ fail "ERROR: 'global.deployment' is deprecated. Please use 'global.deploy' instead." }}
{{- end }}

{{- end }}
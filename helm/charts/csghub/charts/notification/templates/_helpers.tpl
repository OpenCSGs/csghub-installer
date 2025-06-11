{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Define the internal domain for notification
*/}}
{{- define "notification.internal.domain" -}}
{{- include "common.names.custom" (list . "notification") }}
{{- end }}

{{/*
Define the internal port for notification
*/}}
{{- define "notification.internal.port" -}}
{{- $port := "8095" }}
{{- if hasKey .Values.global "notification" }}
  {{- if hasKey .Values.global.notification "service" }}
    {{- if hasKey .Values.global.notification.service "port" }}
      {{- $port = .Values.global.notification.service.port }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $port | toString -}}
{{- end }}

{{/*
Define the internal endpoint for notification
*/}}
{{- define "notification.internal.endpoint" -}}
{{- printf "http://%s:%s" (include "notification.internal.domain" .) (include "notification.internal.port" .) -}}
{{- end }}

{{/*
Define the password of notification root
*/}}
{{- define "notification.password" -}}
{{- "Root@1234" -}}
{{- end }}

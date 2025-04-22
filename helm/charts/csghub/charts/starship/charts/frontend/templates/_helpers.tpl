{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Define the internal domain for portal
*/}}
{{- define "portal.internal.domain" -}}
{{- include "common.names.custom" (list . "starship-portal") }}
{{- end }}

{{/*
Define the internal port for portal
*/}}
{{- define "portal.internal.port" -}}
{{- $port := "80" }}
{{- if hasKey .Values.global "portal" }}
  {{- if hasKey .Values.global.portal "service" }}
    {{- if hasKey .Values.global.portal.service "port" }}
      {{- $port = .Values.global.portal.service.port }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $port | toString -}}
{{- end }}


#'${CASDOOR_ENDPOINT}/login/oauth/authorize?client_id=${CASDOOR_CLIENT_ID}&response_type=code&redirect_uri=${STARSHIP_API_URL}${CASDOOR_REDIRECT_URI_PATH}&scope=profile&state=casdoor',

{{/*
Define the internal domain for portal
*/}}
{{- define "portal.callback.url" -}}
{{- printf ""  -}}
{{- end }}

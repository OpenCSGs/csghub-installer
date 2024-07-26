{{- /*
Copyright OpenCSG, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Return name of ConfigMap
*/}}
{{- define "names.cm" -}}
{{ printf "%s-cm" ( include "common.names.fullname" . ) }}
{{- end -}}

{{/*
Return name of initialized ConfigMap
*/}}
{{- define "names.init.cm" -}}
{{ printf "%s-init-cm" ( include "common.names.fullname" . ) }}
{{- end -}}

{{/*
Return name of docker config ConfigMap
*/}}
{{- define "names.docker.cm" -}}
{{ printf "%s-docker-cm" ( include "common.names.fullname" . ) }}
{{- end -}}

{{/*
Return name of Service
*/}}
{{- define "names.svc" -}}
{{ printf "%s-svc" ( include "common.names.fullname" . ) }}
{{- end -}}

{{/*
Return name of headless Service
*/}}
{{- define "names.hl.svc" -}}
{{ printf "%s-hl-svc" ( include "common.names.fullname" . ) }}
{{- end -}}

{{/*
Return name of headless Service
*/}}
{{- define "names.docker.svc" -}}
{{ printf "%s-docker-svc" ( include "common.names.fullname" . ) }}
{{- end -}}

{{/*
Return name of external Service
*/}}
{{- define "names.external.svc" -}}
{{ printf "%s-external-svc" ( include "common.names.fullname" . ) }}
{{- end -}}

{{/*
Return name of PersistentVolumeClaim
*/}}
{{- define "names.pvc" -}}
{{ printf "%s-pvc" ( include "common.names.fullname" . ) }}
{{- end -}}

{{/*
Return name of NetworkPolicy
*/}}
{{- define "names.netpol" -}}
{{ printf "%s-netpol" ( include "common.names.fullname" . ) }}
{{- end -}}

{{/*
Return name of Job to create buckets
*/}}
{{- define "names.job" -}}
{{ printf "%s-job" ( include "common.names.fullname" . ) }}
{{- end -}}

{{/*
Return name of Secret
*/}}
{{- define "names.secret" -}}
{{ printf "%s-secret" ( include "common.names.fullname" . ) }}
{{- end -}}

{{/*
Return name of docker Secret
*/}}
{{- define "names.docker.secret" -}}
{{ printf "%s-docker-secret" ( include "common.names.fullname" . ) }}
{{- end -}}

{{/*
Return name of TLS Secret
*/}}
{{- define "names.tls.secret" -}}
{{ printf "%s-tls-secret" ( include "common.names.fullname" . ) }}
{{- end -}}

{{/*
Return name of Ingress
*/}}
{{- define "names.ing" -}}
{{ printf "%s-ing" ( include "common.names.fullname" . ) }}
{{- end -}}

{{/*
Return name of Ingress
*/}}
{{- define "names.gitserver.ing" -}}
{{ printf "%s-gitserver-ing" ( include "common.names.fullname" . ) }}
{{- end -}}

{{/*
Return name of ServiceAccount
*/}}
{{- define "names.sa" -}}
{{ printf "%s-sa" ( include "common.names.fullname" . ) }}
{{- end -}}

{{/*
Return name of StatefulSet
*/}}
{{- define "names.sts" -}}
{{ printf "%s-sts" ( include "common.names.fullname" . ) }}
{{- end -}}

{{/*
Return name of Deployment
*/}}
{{- define "names.deploy" -}}
{{ printf "%s-deploy" ( include "common.names.fullname" . ) }}
{{- end -}}
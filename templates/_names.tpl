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
Return init name of initialized ConfigMap
*/}}
{{- define "names.cm.init" -}}
{{ printf "%s-init-cm" ( include "common.names.fullname" . ) }}
{{- end -}}

{{/*
Return tls name of initialized ConfigMap
*/}}
{{- define "names.cm.tls" -}}
{{ printf "%s-tls-cm" ( include "common.names.fullname" . ) }}
{{- end -}}

{{/*
Return name of docker ConfigMap
*/}}
{{- define "names.cm.docker" -}}
{{ printf "%s-docker-cm" ( include "common.names.fullname" . ) }}
{{- end -}}

{{/*
Return name of nginx ConfigMap
*/}}
{{- define "names.cm.nginx" -}}
{{ printf "%s-nginx-cm" ( include "common.names.fullname" . ) }}
{{- end -}}

{{/*
Return name of Service
*/}}
{{- define "names.svc" -}}
{{ printf "%s-svc" ( include "common.names.fullname" . ) }}
{{- end -}}

{{/*
Return nginx name of Service
*/}}
{{- define "names.svc.nginx" -}}
{{ printf "%s-nginx-svc" ( include "common.names.fullname" . ) }}
{{- end -}}

{{/*
Return name of headless Service
*/}}
{{- define "names.svc.hl" -}}
{{ printf "%s-hl-svc" ( include "common.names.fullname" . ) }}
{{- end -}}

{{/*
Return git http name of headless Service
*/}}
{{- define "names.svc.hl.http" -}}
{{ printf "%s-http" ( include "common.names.fullname" . ) }}
{{- end -}}

{{/*
Return git ssh name of headless Service
*/}}
{{- define "names.svc.hl.ssh" -}}
{{ printf "%s-ssh" ( include "common.names.fullname" . ) }}
{{- end -}}

{{/*
Return name of headless Service
*/}}
{{- define "names.svc.docker" -}}
{{ printf "%s-docker-svc" ( include "common.names.fullname" . ) }}
{{- end -}}

{{/*
Return name of external Service
*/}}
{{- define "names.svc.external" -}}
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
{{- define "names.secret.docker" -}}
{{ printf "%s-docker-secret" ( include "common.names.fullname" . ) }}
{{- end -}}

{{/*
Return name of TLS Secret
*/}}
{{- define "names.secret.tls" -}}
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
{{- define "names.ing.gitea.admin" -}}
{{ printf "%s-admin-ing" ( include "common.names.fullname" . ) }}
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
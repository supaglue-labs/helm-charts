{{/* vim: set filetype=mustache: */}}
{{- define "supaglue.name" -}}
{{- template "common.names.name" . -}}
{{- end -}}

{{- define "supaglue.chart" -}}
{{- template "common.names.chart" . -}}
{{- end -}}

{{- define "supaglue.fullname" -}}
{{- template "common.names.fullname" . -}}
{{- end -}}

{{/*
Create the name of the service account
*/}}
{{- define "supaglue.serviceAccountName" -}}
{{ default (include "supaglue.fullname" .) .Values.serviceAccount.name }}
{{- end -}}

{{/*
Define the service account as needed
*/}}
{{- define "supaglue.serviceAccount" -}}
{{- if .Values.serviceAccount.create -}}
serviceAccountName: {{ include "supaglue.serviceAccountName" . }}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified component name from the full app name and a component name.
We truncate the full name at 63 - 1 (last dash) - len(component name) chars because some Kubernetes name fields are limited to this (by the DNS naming spec)
and we want to make sure that the component is included in the name.
*/}}
{{- define "supaglue.componentname" -}}
{{- $global := index . 0 -}}
{{- $component := index . 1 | trimPrefix "-" -}}
{{- printf "%s-%s" (include "supaglue.fullname" $global | trunc (sub 62 (len $component) | int) | trimSuffix "-" ) $component | trimSuffix "-" -}}
{{- end -}}

{{- define "supaglue.databaseName" -}}
{{- template "postgresql.database" .Subcharts.postgresql -}}
{{- end -}}

{{- define "supaglue.databaseUsername" -}}
{{- template "postgresql.username" .Subcharts.postgresql -}}
{{- end -}}

{{- define "supaglue.databasePassword" -}}
{{- required "A value for global.postgres.auth.password must be set." (default .Values.global.postgresql.auth.password .Values.postgresql.auth.password) -}}
{{- end -}}

{{- define "supaglue.databasePort" -}}
{{- default (include "postgresql.service.port" .Subcharts.postgresql) .Values.postgresql.port -}}
{{- end -}}

{{- define "supaglue.databaseHost" -}}
{{- default .Values.postgresql.host (printf "%s-postgresql.%s.svc.cluster.local" .Chart.Name $.Release.Namespace) -}}
{{- end -}}

{{- define "supaglue.temporalPort" -}}
{{- default (include "temporal.frontend.grpcPort" .Subcharts.temporal) .Values.temporal.port  -}}
{{- end -}}

{{- define "supaglue.temporalHost" -}}
{{- default (printf "%s-temporal-frontend.%s.svc.cluster.local" .Chart.Name $.Release.Namespace) .Values.temporal.host -}}
{{- end -}}

{{- define "supaglue.databaseUrl" -}}
{{- $database := include "supaglue.databaseName" . -}}
{{- $username := include "supaglue.databaseUsername" . -}}
{{- $password := include "supaglue.databasePassword" . -}}
{{- $host := include "supaglue.databaseHost" . -}}
{{- $port := include "supaglue.databasePort" . -}}
{{- printf "postgres://%s:%s@%s:%s/%s" $username $password $host $port $database -}}
{{- end -}}

{{- define "supaglue.secretName" -}}
{{- if .Values.existingSecret -}}
    {{- printf "%s" (tpl .Values.existingSecret $) -}}
{{- else -}}
    {{- print "supaglue-secret" -}}
{{- end -}}
{{- end -}}

{{- define "supaglue.deploymentId" -}}
{{- required "A value for deploymentId must be set." .Values.deploymentId -}}
{{- end -}}

{{/*
Expand the name of the chart.
*/}}
{{- define "helm-harbor-sync.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "helm-harbor-sync.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "helm-harbor-sync.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "helm-harbor-sync.labels" -}}
helm.sh/chart: {{ include "helm-harbor-sync.chart" . }}
{{ include "helm-harbor-sync.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels.
*/}}
{{- define "helm-harbor-sync.selectorLabels" -}}
app.kubernetes.io/name: {{ include "helm-harbor-sync.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Harbor credentials secret name.
*/}}
{{- define "helm-harbor-sync.harborSecretName" -}}
{{- if .Values.harbor.existingSecret }}
{{- .Values.harbor.existingSecret }}
{{- else }}
{{- include "helm-harbor-sync.fullname" . }}-harbor
{{- end }}
{{- end }}

{{/*
Generate charts.manifest content from values.charts.
*/}}
{{- define "helm-harbor-sync.chartsManifest" -}}
# Auto-generated from values.charts
{{- range .Values.charts }}
http|{{ .source }}|{{ .version }}|{{ .harborProject }}|{{ .name }}|{{ .envVar }}
{{- end }}
{{- end -}}

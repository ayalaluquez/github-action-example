#######################################################
###############        GENERAL       ##################
#######################################################

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to
this (by the DNS naming spec). If release name contains chart name it will
be used as a full name.
*/}}
{{- define "wakingup.fullname" -}}
{{- if ne (.Values.global.projectName | toString) "" -}}
{{- .Values.global.projectName | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "wakingup.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Expand the name of the chart.
*/}}
{{- define "wakingup.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

#######################################################
###############         API          ##################
#######################################################


{{/*
Set's the replica count based on the different modes configured by user
*/}}
{{- define "api.replicas" -}}
  {{ if eq .mode "ha" }}
    {{- .Values.api.ha.replicas | default 3 -}}
  {{ else }}
    {{- default 1 -}}
  {{ end }}
{{- end -}}

{{/*
Inject extra environment vars in the format key:value, if populated
*/}}
{{- define "api.extraEnvironmentVars" -}}
{{- if .extraEnvironmentVars -}}
{{- range $key, $value := .extraEnvironmentVars }}
- name: {{ printf "%s" $key | replace "." "_" | upper | quote }}
  value: {{ $value | quote }}
{{- end }}
{{- end -}}
{{- end -}}
{{/*
Inject extra environment populated by secrets, if populated
*/}}
{{- define "api.extraSecretEnvironmentVars" -}}
{{- if .extraSecretEnvironmentVars -}}
{{- range .extraSecretEnvironmentVars }}
- name: {{ .envName }}
  valueFrom:
   secretKeyRef:
     name: {{ .secretName }}
     key: {{ .secretKey }}
{{- end -}}
{{- end -}}
{{- end -}}


{{/*
Set's the node selector for pod placement when running in standalone and HA modes.
*/}}
{{- define "api.nodeselector" -}}
{{- end -}}


{{/*
Set's the affinity for pod placement when running in standalone and HA modes.
*/}}
{{- define "api.affinity" -}}
{{- end -}}

{{/*
Sets the api toleration for pod placement
*/}}
{{- define "api.tolerations" -}}
  {{- if .Values.api.tolerations }}
      tolerations:
        {{ tpl .Values.api.tolerations . | nindent 8 | trim }}
  {{- end }}
{{- end -}}

{{/*
Sets extra ingress annotations
*/}}
{{- define "api.ingress.annotations" -}}
  {{- if .Values.api.ingress.annotations }}
  annotations:
    {{- tpl .Values.api.ingress.annotations . | nindent 4 }}
  {{- end }}
{{- end -}}

{{/*
Set's the container resources if the user has set any.
*/}}
{{- define "api.resources" -}}
  {{- if .Values.api.resources -}}
          resources:
{{ toYaml .Values.api.resources | indent 12}}
  {{ else }}
  {{ end }}
{{- end -}}


{{/*
Set's up configmap mounts if this isn't a dev deployment and the user
defined a custom configuration.  Additionally iterates over any
extra volumes the user may have specified (such as a secret with TLS).
*/}}
{{- define "api.volumes" -}}
  {{ if .Values.api.extraVolumes }}
      volumes:
    {{- range .Values.api.extraVolumes }}
      - name: {{ .name }}
        {{ .type }}:
        {{- if (eq .type "configMap") }}
          name: {{ .name }}
        {{- else if (eq .type "secret") }}
          secretName: {{ .name }}
        {{- end }}
    {{- end }}
  {{ end }}
{{- end -}}

{{/*
Set's which additional volumes should be mounted to the container
based on the mode configured.
*/}}
{{- define "api.mounts" -}}
  {{ if .Values.api.extraVolumes }}
          volumeMounts:
    {{- range .Values.api.extraVolumes }}
          - name: {{ .name }}
            readOnly: true
            mountPath: {{ .path | default "/mnt" }}
    {{- end }}
  {{- end }}
{{- end -}}

{{/*
Sets extra api annotations
*/}}
{{- define "api.annotations" -}}
  {{- if .Values.api.annotations }}
      annotations:
    {{- $tp := typeOf .Values.api.annotations }}
    {{- if eq $tp "string" }}
      {{- tpl .Values.api.annotations . | nindent 8 }}
    {{- else }}
      {{- toYaml .Values.api.annotations | nindent 8 }}
    {{- end }}
  {{- end }}
{{- end -}}

#######################################################
###############         CRON         ##################
#######################################################


{{/*
Set's the replica count based on the different modes configured by user
*/}}
{{- define "cron.replicas" -}}
  {{ if eq .mode "ha" }}
    {{- .Values.cron.ha.replicas | default 3 -}}
  {{ else }}
    {{- default 1 -}}
  {{ end }}
{{- end -}}

{{/*
Inject extra environment vars in the format key:value, if populated
*/}}
{{- define "cron.extraEnvironmentVars" -}}
{{- if .extraEnvironmentVars -}}
{{- range $key, $value := .extraEnvironmentVars }}
- name: {{ printf "%s" $key | replace "." "_" | upper | quote }}
  value: {{ $value | quote }}
{{- end }}
{{- end -}}
{{- end -}}
{{/*
Inject extra environment populated by secrets, if populated
*/}}
{{- define "cron.extraSecretEnvironmentVars" -}}
{{- if .extraSecretEnvironmentVars -}}
{{- range .extraSecretEnvironmentVars }}
- name: {{ .envName }}
  valueFrom:
   secretKeyRef:
     name: {{ .secretName }}
     key: {{ .secretKey }}
{{- end -}}
{{- end -}}
{{- end -}}


{{/*
Set's the node selector for pod placement when running in standalone and HA modes.
*/}}
{{- define "cron.nodeselector" -}}
{{- end -}}


{{/*
Set's the affinity for pod placement when running in standalone and HA modes.
*/}}
{{- define "cron.affinity" -}}
{{- end -}}

{{/*
Sets the api toleration for pod placement
*/}}
{{- define "cron.tolerations" -}}
  {{- if .Values.cron.tolerations }}
      tolerations:
        {{ tpl .Values.cron.tolerations . | nindent 8 | trim }}
  {{- end }}
{{- end -}}

{{/*
Sets extra ingress annotations
*/}}
{{- define "cron.ingress.annotations" -}}
  {{- if .Values.cron.ingress.annotations }}
  annotations:
    {{- tpl .Values.cron.ingress.annotations . | nindent 4 }}
  {{- end }}
{{- end -}}

{{/*
Set's the container resources if the user has set any.
*/}}
{{- define "cron.resources" -}}
  {{- if .Values.cron.resources -}}
          resources:
{{ toYaml .Values.cron.resources | indent 12}}
  {{ else }}
  {{ end }}
{{- end -}}


{{/*
Set's up configmap mounts if this isn't a dev deployment and the user
defined a custom configuration.  Additionally iterates over any
extra volumes the user may have specified (such as a secret with TLS).
*/}}
{{- define "cron.volumes" -}}
  {{ if .Values.cron.extraVolumes }}
      volumes:
    {{- range .Values.cron.extraVolumes }}
      - name: {{ .name }}
        {{ .type }}:
        {{- if (eq .type "configMap") }}
          name: {{ .name }}
        {{- else if (eq .type "secret") }}
          secretName: {{ .name }}
        {{- end }}
    {{- end }}
  {{ end }}
{{- end -}}

{{/*
Set's which additional volumes should be mounted to the container
based on the mode configured.
*/}}
{{- define "cron.mounts" -}}
  {{ if .Values.cron.extraVolumes }}
          volumeMounts:
    {{- range .Values.cron.extraVolumes }}
          - name: {{ .name }}
            readOnly: true
            mountPath: {{ .path | default "/mnt" }}
    {{- end }}
  {{- end }}
{{- end -}}


{{/*
Sets extra cron annotations
*/}}
{{- define "cron.annotations" -}}
  {{- if .Values.cron.annotations }}
      annotations:
    {{- $tp := typeOf .Values.cron.annotations }}
    {{- if eq $tp "string" }}
      {{- tpl .Values.cron.annotations . | nindent 8 }}
    {{- else }}
      {{- toYaml .Values.cron.annotations | nindent 8 }}
    {{- end }}
  {{- end }}
{{- end -}}

#######################################################
##############      BACKGROUND       ##################
#######################################################


{{/*
Set's the replica count based on the different modes configured by user
*/}}
{{- define "background.replicas" -}}
  {{ if eq .mode "ha" }}
    {{- .Values.background.ha.replicas | default 3 -}}
  {{ else }}
    {{- default 1 -}}
  {{ end }}
{{- end -}}

{{/*
Inject extra environment vars in the format key:value, if populated
*/}}
{{- define "background.extraEnvironmentVars" -}}
{{- if .extraEnvironmentVars -}}
{{- range $key, $value := .extraEnvironmentVars }}
- name: {{ printf "%s" $key | replace "." "_" | upper | quote }}
  value: {{ $value | quote }}
{{- end }}
{{- end -}}
{{- end -}}
{{/*
Inject extra environment populated by secrets, if populated
*/}}
{{- define "background.extraSecretEnvironmentVars" -}}
{{- if .extraSecretEnvironmentVars -}}
{{- range .extraSecretEnvironmentVars }}
- name: {{ .envName }}
  valueFrom:
   secretKeyRef:
     name: {{ .secretName }}
     key: {{ .secretKey }}
{{- end -}}
{{- end -}}
{{- end -}}


{{/*
Set's the node selector for pod placement when running in standalone and HA modes.
*/}}
{{- define "background.nodeselector" -}}
{{- end -}}


{{/*
Set's the affinity for pod placement when running in standalone and HA modes.
*/}}
{{- define "background.affinity" -}}
{{- end -}}

{{/*
Sets the api toleration for pod placement
*/}}
{{- define "background.tolerations" -}}
  {{- if .Values.background.tolerations }}
      tolerations:
        {{ tpl .Values.background.tolerations . | nindent 8 | trim }}
  {{- end }}
{{- end -}}

{{/*
Sets extra ingress annotations
*/}}
{{- define "background.ingress.annotations" -}}
  {{- if .Values.background.ingress.annotations }}
  annotations:
    {{- tpl .Values.background.ingress.annotations . | nindent 4 }}
  {{- end }}
{{- end -}}

{{/*
Set's the container resources if the user has set any.
*/}}
{{- define "background.resources" -}}
  {{- if .Values.background.resources -}}
          resources:
{{ toYaml .Values.background.resources | indent 12}}
  {{ else }}
  {{ end }}
{{- end -}}


{{/*
Set's up configmap mounts if this isn't a dev deployment and the user
defined a custom configuration.  Additionally iterates over any
extra volumes the user may have specified (such as a secret with TLS).
*/}}
{{- define "background.volumes" -}}
  {{ if .Values.background.extraVolumes }}
      volumes:
    {{- range .Values.background.extraVolumes }}
      - name: {{ .name }}
        {{ .type }}:
        {{- if (eq .type "configMap") }}
          name: {{ .name }}
        {{- else if (eq .type "secret") }}
          secretName: {{ .name }}
        {{- end }}
    {{- end }}
  {{ end }}
{{- end -}}

{{/*
Set's which additional volumes should be mounted to the container
based on the mode configured.
*/}}
{{- define "background.mounts" -}}
  {{ if .Values.background.extraVolumes }}
          volumeMounts:
    {{- range .Values.background.extraVolumes }}
          - name: {{ .name }}
            readOnly: true
            mountPath: {{ .path | default "/mnt" }}
    {{- end }}
  {{- end }}
{{- end -}}


{{/*
Sets extra background annotations
*/}}
{{- define "background.annotations" -}}
  {{- if .Values.background.annotations }}
      annotations:
    {{- $tp := typeOf .Values.background.annotations }}
    {{- if eq $tp "string" }}
      {{- tpl .Values.background.annotations . | nindent 8 }}
    {{- else }}
      {{- toYaml .Values.background.annotations | nindent 8 }}
    {{- end }}
  {{- end }}
{{- end -}}

#######################################################
###############      WEBHOOKS        ##################
#######################################################


{{/*
Set's the replica count based on the different modes configured by user
*/}}
{{- define "webhooks.replicas" -}}
  {{ if eq .mode "ha" }}
    {{- .Values.webhooks.ha.replicas | default 3 -}}
  {{ else }}
    {{- default 1 -}}
  {{ end }}
{{- end -}}

{{/*
Inject extra environment vars in the format key:value, if populated
*/}}
{{- define "webhooks.extraEnvironmentVars" -}}
{{- if .extraEnvironmentVars -}}
{{- range $key, $value := .extraEnvironmentVars }}
- name: {{ printf "%s" $key | replace "." "_" | upper | quote }}
  value: {{ $value | quote }}
{{- end }}
{{- end -}}
{{- end -}}
{{/*
Inject extra environment populated by secrets, if populated
*/}}
{{- define "webhooks.extraSecretEnvironmentVars" -}}
{{- if .extraSecretEnvironmentVars -}}
{{- range .extraSecretEnvironmentVars }}
- name: {{ .envName }}
  valueFrom:
   secretKeyRef:
     name: {{ .secretName }}
     key: {{ .secretKey }}
{{- end -}}
{{- end -}}
{{- end -}}


{{/*
Set's the node selector for pod placement when running in standalone and HA modes.
*/}}
{{- define "webhooks.nodeselector" -}}
{{- end -}}


{{/*
Set's the affinity for pod placement when running in standalone and HA modes.
*/}}
{{- define "webhooks.affinity" -}}
{{- end -}}

{{/*
Sets the api toleration for pod placement
*/}}
{{- define "webhooks.tolerations" -}}
  {{- if .Values.webhooks.tolerations }}
      tolerations:
        {{ tpl .Values.webhooks.tolerations . | nindent 8 | trim }}
  {{- end }}
{{- end -}}

{{/*
Sets extra ingress annotations
*/}}
{{- define "webhooks.ingress.annotations" -}}
  {{- if .Values.webhooks.ingress.annotations }}
  annotations:
    {{- tpl .Values.webhooks.ingress.annotations . | nindent 4 }}
  {{- end }}
{{- end -}}

{{/*
Set's the container resources if the user has set any.
*/}}
{{- define "webhooks.resources" -}}
  {{- if .Values.webhooks.resources -}}
          resources:
{{ toYaml .Values.webhooks.resources | indent 12}}
  {{ else }}
  {{ end }}
{{- end -}}


{{/*
Set's up configmap mounts if this isn't a dev deployment and the user
defined a custom configuration.  Additionally iterates over any
extra volumes the user may have specified (such as a secret with TLS).
*/}}
{{- define "webhooks.volumes" -}}
  {{ if .Values.webhooks.extraVolumes }}
      volumes:
    {{- range .Values.webhooks.extraVolumes }}
      - name: {{ .name }}
        {{ .type }}:
        {{- if (eq .type "configMap") }}
          name: {{ .name }}
        {{- else if (eq .type "secret") }}
          secretName: {{ .name }}
        {{- end }}
    {{- end }}
  {{ end }}
{{- end -}}

{{/*
Set's which additional volumes should be mounted to the container
based on the mode configured.
*/}}
{{- define "webhooks.mounts" -}}
  {{ if .Values.webhooks.extraVolumes }}
          volumeMounts:
    {{- range .Values.webhooks.extraVolumes }}
          - name: {{ .name }}
            readOnly: true
            mountPath: {{ .path | default "/mnt" }}
    {{- end }}
  {{- end }}
{{- end -}}


{{/*
Sets extra webhooks annotations
*/}}
{{- define "webhooks.annotations" -}}
  {{- if .Values.webhooks.annotations }}
      annotations:
    {{- $tp := typeOf .Values.webhooks.annotations }}
    {{- if eq $tp "string" }}
      {{- tpl .Values.webhooks.annotations . | nindent 8 }}
    {{- else }}
      {{- toYaml .Values.webhooks.annotations | nindent 8 }}
    {{- end }}
  {{- end }}
{{- end -}}
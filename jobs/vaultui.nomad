
// K8 Deployment specs for vaultui
// apiVersion: extensions/v1beta1
// kind: Deployment
// metadata:
//   name: {{ template "fullname" . }}
//   labels:
//     app: {{ template "name" . }}
//     chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
//     release: {{ .Release.Name }}
//     heritage: {{ .Release.Service }}
// spec:
//   replicas: {{ .Values.replicaCount }}
//   template:
//     metadata:
//       labels:
//         app: {{ template "name" . }}
//         release: {{ .Release.Name }}
//     spec:
//       containers:
//         - name: {{ .Chart.Name }}
//           image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
//           imagePullPolicy: {{ .Values.image.pullPolicy }}
//           env:
//             - name: VAULT_URL_DEFAULT
//               value: {{ .Values.vault.url }}
//             - name: VAULT_AUTH_DEFAULT
//               value: {{ .Values.vault.auth }}

//           ports:
//             - containerPort: {{ .Values.service.internalPort }}
//           livenessProbe:
//             httpGet:
//               path: /
//               port: {{ .Values.service.internalPort }}
//           readinessProbe:
//             httpGet:
//               path: /
//               port: {{ .Values.service.internalPort }}
//           resources:
// {{ toYaml .Values.resources | indent 12 }}
//     {{- if .Values.nodeSelector }}
//       nodeSelector:
// {{ toYaml .Values.nodeSelector | indent 8 }}
//     {{- end }}
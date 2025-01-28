#!/bin/bash

# Variables
NAMESPACE="kube-system"
SERVICE_ACCOUNT="crd-reader"
SECRET_NAME="crd-reader-token"

TOKEN=$(kubectl -n ${NAMESPACE} get secret ${SECRET_NAME} -o jsonpath="{.data.token}" | base64 --decode)
CA_CRT=$(kubectl -n ${NAMESPACE} get secret ${SECRET_NAME} -o jsonpath="{.data['ca\.crt']}" | base64 --decode)

CLUSTER_NAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].name}')
CLUSTER_SERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
CONTEXT_NAME="${SERVICE_ACCOUNT}@${CLUSTER_NAME}"

KUBECONFIG_FILE="kubeconfig-${SERVICE_ACCOUNT}.yaml"
cat <<EOF > ${KUBECONFIG_FILE}
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority-data: $(echo "${CA_CRT}" | base64 | tr -d '\n')
    server: ${CLUSTER_SERVER}
  name: ${CLUSTER_NAME}
contexts:
- context:
    cluster: ${CLUSTER_NAME}
    user: ${SERVICE_ACCOUNT}
  name: ${CONTEXT_NAME}
current-context: ${CONTEXT_NAME}
users:
- name: ${SERVICE_ACCOUNT}
  user:
    token: ${TOKEN}
EOF

echo "Kubeconfig file ${KUBECONFIG_FILE} created successfully."

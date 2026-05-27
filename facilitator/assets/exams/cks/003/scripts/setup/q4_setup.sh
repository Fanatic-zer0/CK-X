#!/bin/bash
# Q4 Setup: Create dev-team namespace with dev-sa and overpermissive ClusterRoleBinding
set -e

kubectl create namespace dev-team --dry-run=client -o yaml | kubectl apply -f -

# Create the ServiceAccount
kubectl create serviceaccount dev-sa -n dev-team --dry-run=client -o yaml | kubectl apply -f -

# Create overly permissive ClusterRoleBinding (the "problem" to fix)
kubectl apply -f - <<'EOF'
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: dev-cluster-admin
subjects:
- kind: ServiceAccount
  name: dev-sa
  namespace: dev-team
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
EOF

echo "Q4 setup complete: dev-team namespace, dev-sa, and dev-cluster-admin ClusterRoleBinding"

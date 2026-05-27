#!/bin/bash
# Setup for Question 12: RBAC Audit - Remove Dangerous Permissions

# Create namespace
kubectl create namespace rbac-fix 2>/dev/null || true

# Create the ServiceAccount that has bad permissions
kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: temp-sa
  namespace: rbac-fix
EOF

# Create an overly permissive ClusterRole with wildcard permissions
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: over-permissive
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
EOF

# Create a dangerous ClusterRoleBinding granting cluster-admin
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: dangerous-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: temp-sa
  namespace: rbac-fix
EOF

echo "Setup completed for Question 12"
exit 0

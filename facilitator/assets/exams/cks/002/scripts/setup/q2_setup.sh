#!/bin/bash
# Setup for Question 2: ClusterRole Least Privilege

# Create namespace
kubectl create namespace cluster-rbac 2>/dev/null || true

# Pre-create the ServiceAccount that the candidate will bind
kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: audit-user
  namespace: cluster-rbac
EOF

echo "Setup completed for Question 2"
exit 0

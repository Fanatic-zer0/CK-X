#!/bin/bash
# Q10 Setup: Create legacy-workloads namespace with privileged deployment
set -e

kubectl create namespace legacy-workloads --dry-run=client -o yaml | kubectl apply -f -

# Create a deployment that violates PSS baseline (privileged + hostPID)
kubectl apply -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: privileged-app
  namespace: legacy-workloads
  labels:
    app: privileged-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: privileged-app
  template:
    metadata:
      labels:
        app: privileged-app
    spec:
      hostPID: true
      containers:
      - name: privileged-app
        image: nginx:1.25-alpine
        securityContext:
          privileged: true
EOF

echo "Q10 setup complete: legacy-workloads namespace with non-compliant privileged-app deployment"

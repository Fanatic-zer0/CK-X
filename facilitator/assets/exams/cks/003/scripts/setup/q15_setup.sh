#!/bin/bash
# Q15 Setup: Create workload-ns with legacy-app deployment using default SA
set -e

kubectl create namespace workload-ns --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: legacy-app
  namespace: workload-ns
  labels:
    app: legacy-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: legacy-app
  template:
    metadata:
      labels:
        app: legacy-app
    spec:
      serviceAccountName: default
      automountServiceAccountToken: true
      containers:
      - name: legacy-app
        image: nginx:1.25-alpine
        ports:
        - containerPort: 80
EOF

echo "Q15 setup complete: workload-ns with legacy-app deployment using default SA"

#!/bin/bash
# Q5 Setup: Create prod-apps namespace with api-backend deployment (no seccomp)
set -e

kubectl create namespace prod-apps --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-backend
  namespace: prod-apps
  labels:
    app: api-backend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: api-backend
  template:
    metadata:
      labels:
        app: api-backend
    spec:
      containers:
      - name: api-backend
        image: nginx:1.25-alpine
        ports:
        - containerPort: 8080
EOF

echo "Q5 setup complete: prod-apps namespace with api-backend deployment (no seccomp profile)"

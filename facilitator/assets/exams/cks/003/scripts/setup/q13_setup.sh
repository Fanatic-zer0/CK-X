#!/bin/bash
# Q13 Setup: Create mutable-apps namespace with insecure data-processor deployment
set -e

kubectl create namespace mutable-apps --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: data-processor
  namespace: mutable-apps
  labels:
    app: data-processor
spec:
  replicas: 1
  selector:
    matchLabels:
      app: data-processor
  template:
    metadata:
      labels:
        app: data-processor
    spec:
      containers:
      - name: data-processor
        image: nginx:1.25-alpine
        securityContext:
          runAsUser: 0
          allowPrivilegeEscalation: true
          readOnlyRootFilesystem: false
        ports:
        - containerPort: 80
EOF

echo "Q13 setup complete: mutable-apps namespace with insecure data-processor deployment"

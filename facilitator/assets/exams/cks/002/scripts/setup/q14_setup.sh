#!/bin/bash
# Setup for Question 14: Fix Vulnerable Deployment

# Create namespace
kubectl create namespace vuln-fix 2>/dev/null || true

# Create a deliberately insecure deployment for the candidate to fix
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: insecure-app
  namespace: vuln-fix
spec:
  replicas: 1
  selector:
    matchLabels:
      app: insecure-app
  template:
    metadata:
      labels:
        app: insecure-app
    spec:
      hostPID: true
      hostNetwork: true
      containers:
      - name: insecure-container
        image: nginx:alpine
        securityContext:
          privileged: true
          runAsUser: 0
          allowPrivilegeEscalation: true
EOF

echo "Setup completed for Question 14"
exit 0

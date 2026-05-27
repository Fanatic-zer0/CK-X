#!/bin/bash
# Q3 Setup: Create three-tier namespace with frontend, backend, db pods
set -e

kubectl create namespace three-tier --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f - <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: frontend
  namespace: three-tier
  labels:
    app: frontend
    tier: web
spec:
  containers:
  - name: frontend
    image: nginx:1.25-alpine
    ports:
    - containerPort: 80
---
apiVersion: v1
kind: Pod
metadata:
  name: backend
  namespace: three-tier
  labels:
    app: backend
    tier: app
spec:
  containers:
  - name: backend
    image: nginx:1.25-alpine
    ports:
    - containerPort: 8080
---
apiVersion: v1
kind: Pod
metadata:
  name: db
  namespace: three-tier
  labels:
    app: db
    tier: data
spec:
  containers:
  - name: db
    image: busybox:1.35
    command: ["sh", "-c", "while true; do nc -l -p 5432; done"]
    ports:
    - containerPort: 5432
EOF

echo "Q3 setup complete: three-tier namespace with frontend, backend, db pods"

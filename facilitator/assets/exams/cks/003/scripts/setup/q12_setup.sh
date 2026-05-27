#!/bin/bash
# Q12 Setup: Create web-tls namespace, web-service, and raw-certs ConfigMap with self-signed cert
set -e

kubectl create namespace web-tls --dry-run=client -o yaml | kubectl apply -f -

# Generate a self-signed certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /tmp/tls.key \
  -out /tmp/tls.crt \
  -subj "/CN=app.cks-exam.io/O=CKS-Exam" \
  -addext "subjectAltName=DNS:app.cks-exam.io" \
  2>/dev/null

TLS_CRT=$(cat /tmp/tls.crt)
TLS_KEY=$(cat /tmp/tls.key)
rm -f /tmp/tls.crt /tmp/tls.key

# Create ConfigMap with raw cert data for the candidate to use
kubectl create configmap raw-certs \
  --from-literal=tls.crt="$TLS_CRT" \
  --from-literal=tls.key="$TLS_KEY" \
  -n web-tls \
  --dry-run=client -o yaml | kubectl apply -f -

# Create a backend deployment
kubectl apply -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-backend
  namespace: web-tls
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web-backend
  template:
    metadata:
      labels:
        app: web-backend
    spec:
      containers:
      - name: web
        image: nginx:1.25-alpine
        ports:
        - containerPort: 80
EOF

# Create Service
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: Service
metadata:
  name: web-service
  namespace: web-tls
spec:
  selector:
    app: web-backend
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
EOF

echo "Q12 setup complete: web-tls namespace with web-service, raw-certs ConfigMap, and web-backend deployment"

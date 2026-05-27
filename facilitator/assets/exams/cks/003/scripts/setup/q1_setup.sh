#!/bin/bash
# Q1 Setup: Create image-audit namespace with legacy deployment and scan-data ConfigMap
set -e

kubectl create namespace image-audit --dry-run=client -o yaml | kubectl apply -f -

# Create scan data ConfigMap with pre-generated Trivy results
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: scan-data
  namespace: image-audit
data:
  nginx_1.14.json: |
    {
      "image": "nginx:1.14",
      "critical": 45,
      "high": 67,
      "medium": 23,
      "low": 12,
      "summary": "DANGEROUS: 112 HIGH/CRITICAL vulnerabilities including CVE-2019-9193, CVE-2019-0211"
    }
  nginx_1.21.json: |
    {
      "image": "nginx:1.21",
      "critical": 8,
      "high": 14,
      "medium": 9,
      "low": 6,
      "summary": "22 HIGH/CRITICAL vulnerabilities"
    }
  nginx_1.24.json: |
    {
      "image": "nginx:1.24",
      "critical": 2,
      "high": 5,
      "medium": 4,
      "low": 3,
      "summary": "7 HIGH/CRITICAL vulnerabilities"
    }
  nginx_1.25_alpine.json: |
    {
      "image": "nginx:1.25-alpine",
      "critical": 0,
      "high": 1,
      "medium": 2,
      "low": 1,
      "summary": "RECOMMENDED: Only 1 HIGH vulnerability - safest option"
    }
  recommendation: |
    Based on scan results, nginx:1.25-alpine has the fewest HIGH/CRITICAL CVEs.
    Action: Update legacy-web deployment to use nginx:1.25-alpine
EOF

# Create the vulnerable deployment
kubectl apply -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: legacy-web
  namespace: image-audit
  labels:
    app: legacy-web
spec:
  replicas: 1
  selector:
    matchLabels:
      app: legacy-web
  template:
    metadata:
      labels:
        app: legacy-web
    spec:
      containers:
      - name: legacy-web
        image: nginx:1.14
        ports:
        - containerPort: 80
EOF

echo "Q1 setup complete: image-audit namespace with legacy-web deployment and scan-data ConfigMap"

#!/bin/bash
# Q16 Setup: Create cert-monitoring namespace and monitor-cert TLS secret
set -e

kubectl create namespace cert-monitoring --dry-run=client -o yaml | kubectl apply -f -

# Generate a self-signed TLS certificate for monitoring
openssl req -x509 -nodes -days 90 -newkey rsa:2048 \
  -keyout /tmp/monitor.key \
  -out /tmp/monitor.crt \
  -subj "/CN=monitor.cks-exam.io/O=CertMonitoring" \
  2>/dev/null

# Create the TLS secret
kubectl create secret tls monitor-cert \
  --cert=/tmp/monitor.crt \
  --key=/tmp/monitor.key \
  -n cert-monitoring \
  --dry-run=client -o yaml | kubectl apply -f -

rm -f /tmp/monitor.crt /tmp/monitor.key

echo "Q16 setup complete: cert-monitoring namespace with monitor-cert TLS secret"

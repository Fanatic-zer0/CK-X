#!/bin/bash
# Setup for Question 11: mTLS with TLS Secrets

# Create namespace
kubectl create namespace mtls-app 2>/dev/null || true

# Generate a self-signed TLS certificate and key for demo purposes
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /tmp/tls.key \
  -out /tmp/tls.crt \
  -subj "/CN=mtls-app.example.com/O=CKS-Lab" 2>/dev/null

# Create the TLS secret that the candidate will use
kubectl create secret tls app-tls \
  --cert=/tmp/tls.crt \
  --key=/tmp/tls.key \
  -n mtls-app 2>/dev/null || true

# Clean up temp files
rm -f /tmp/tls.crt /tmp/tls.key

echo "Setup completed for Question 11"
exit 0

#!/bin/bash
# Q11: Validate Service tls-service exists and exposes port 443

kubectl get service tls-service -n mtls-app &> /dev/null
if [ $? -ne 0 ]; then
  echo "❌ Service 'tls-service' not found in namespace 'mtls-app'"
  exit 1
fi

PORT=$(kubectl get service tls-service -n mtls-app \
  -o jsonpath='{.spec.ports[0].port}' 2>/dev/null)

if [ "$PORT" = "443" ]; then
  echo "✅ Service 'tls-service' exists and exposes port 443"
  exit 0
else
  echo "❌ Service 'tls-service' port is '${PORT}' (expected: 443)"
  exit 1
fi

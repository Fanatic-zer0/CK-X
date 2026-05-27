#!/bin/bash
# Q12 S4: Check Ingress routes to web-service backend on port 80
ING_JSON=$(kubectl -n web-tls get ingress web-ingress -o json 2>/dev/null)

if [ -z "$ING_JSON" ]; then
  echo "❌ Ingress web-ingress not found"
  exit 1
fi

HAS_SVC=$(echo "$ING_JSON" | grep -c '"web-service"' 2>/dev/null || true)
HAS_PORT=$(echo "$ING_JSON" | grep -c '"number":80' 2>/dev/null || true)

if [ "$HAS_SVC" -gt 0 ] && [ "$HAS_PORT" -gt 0 ]; then
  echo "✅ Ingress routes to web-service backend on port 80"
  exit 0
else
  echo "❌ Ingress backend misconfigured (web-service: $HAS_SVC, port 80: $HAS_PORT)"
  exit 1
fi

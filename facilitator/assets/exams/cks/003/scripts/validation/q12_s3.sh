#!/bin/bash
# Q12 S3: Check Ingress has TLS configured for app.cks-exam.io with web-tls-secret
ING_JSON=$(kubectl -n web-tls get ingress web-ingress -o json 2>/dev/null)

if [ -z "$ING_JSON" ]; then
  echo "❌ Ingress web-ingress not found"
  exit 1
fi

HAS_HOST=$(echo "$ING_JSON" | grep -c "app.cks-exam.io" 2>/dev/null || true)
HAS_TLS_SECRET=$(echo "$ING_JSON" | grep -c "web-tls-secret" 2>/dev/null || true)

if [ "$HAS_HOST" -gt 0 ] && [ "$HAS_TLS_SECRET" -gt 0 ]; then
  echo "✅ Ingress has TLS configured for app.cks-exam.io with web-tls-secret"
  exit 0
else
  echo "❌ Ingress TLS misconfigured (host app.cks-exam.io: $HAS_HOST, web-tls-secret: $HAS_TLS_SECRET)"
  exit 1
fi

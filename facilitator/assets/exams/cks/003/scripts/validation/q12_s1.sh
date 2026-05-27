#!/bin/bash
# Q12 S1: Check TLS Secret web-tls-secret exists in web-tls with tls.crt and tls.key
SECRET_JSON=$(kubectl -n web-tls get secret web-tls-secret -o json 2>/dev/null)

if [ -z "$SECRET_JSON" ]; then
  echo "❌ Secret web-tls-secret not found in namespace web-tls"
  exit 1
fi

SECRET_TYPE=$(echo "$SECRET_JSON" | grep -o '"kubernetes.io/tls"' 2>/dev/null || true)
HAS_CRT=$(echo "$SECRET_JSON" | grep -c '"tls.crt"' 2>/dev/null || true)
HAS_KEY=$(echo "$SECRET_JSON" | grep -c '"tls.key"' 2>/dev/null || true)

if [ -n "$SECRET_TYPE" ] && [ "$HAS_CRT" -gt 0 ] && [ "$HAS_KEY" -gt 0 ]; then
  echo "✅ TLS Secret web-tls-secret exists in web-tls with tls.crt and tls.key"
  exit 0
else
  echo "❌ web-tls-secret exists but is misconfigured (type=kubernetes.io/tls: $([ -n "$SECRET_TYPE" ] && echo yes || echo no), tls.crt: $HAS_CRT, tls.key: $HAS_KEY)"
  exit 1
fi

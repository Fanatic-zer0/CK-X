#!/bin/bash
# Q12 S2: Check Ingress web-ingress exists in namespace web-tls
ING=$(kubectl -n web-tls get ingress web-ingress --no-headers 2>/dev/null)

if [ -n "$ING" ]; then
  echo "✅ Ingress web-ingress exists in namespace web-tls"
  exit 0
else
  echo "❌ Ingress web-ingress not found in namespace web-tls"
  exit 1
fi

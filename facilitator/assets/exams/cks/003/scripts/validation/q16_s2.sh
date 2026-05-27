#!/bin/bash
# Q16 S2: Check pod cert-validator uses openssl in its command
CMD=$(kubectl -n cert-monitoring get pod cert-validator \
  -o jsonpath='{.spec.containers[0].command}' 2>/dev/null)
ARGS=$(kubectl -n cert-monitoring get pod cert-validator \
  -o jsonpath='{.spec.containers[0].args}' 2>/dev/null)

if echo "$CMD $ARGS" | grep -q "openssl"; then
  echo "✅ Pod cert-validator uses openssl in its command"
  exit 0
else
  echo "❌ Pod cert-validator command does not reference openssl"
  exit 1
fi

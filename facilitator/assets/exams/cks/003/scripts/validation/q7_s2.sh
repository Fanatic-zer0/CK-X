#!/bin/bash
# Q7 S2: Check pod hash-checker command includes sha256sum
CMD=$(kubectl -n binary-verification get pod hash-checker \
  -o jsonpath='{.spec.containers[0].command}' 2>/dev/null)
ARGS=$(kubectl -n binary-verification get pod hash-checker \
  -o jsonpath='{.spec.containers[0].args}' 2>/dev/null)

if echo "$CMD $ARGS" | grep -q "sha256sum"; then
  echo "✅ Pod hash-checker command includes sha256sum"
  exit 0
else
  echo "❌ Pod hash-checker command does not include sha256sum"
  exit 1
fi

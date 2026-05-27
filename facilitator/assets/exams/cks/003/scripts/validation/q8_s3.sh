#!/bin/bash
# Q8 S3: Check encryption.yaml includes identity fallback provider
CONTENT=$(kubectl -n kube-system get configmap encryption-config \
  -o jsonpath='{.data.encryption\.yaml}' 2>/dev/null)

if echo "$CONTENT" | grep -q "identity"; then
  echo "✅ encryption.yaml includes identity fallback provider"
  exit 0
else
  echo "❌ encryption.yaml missing 'identity: {}' fallback provider"
  exit 1
fi

#!/bin/bash
# Q11 S2: Check admission_config.yaml contains defaultAllow: false
CONTENT=$(kubectl -n kube-system get configmap image-webhook-config \
  -o jsonpath='{.data.admission_config\.yaml}' 2>/dev/null)

if echo "$CONTENT" | grep -q "defaultAllow.*false"; then
  echo "✅ admission_config.yaml contains defaultAllow: false"
  exit 0
else
  echo "❌ admission_config.yaml missing 'defaultAllow: false' (got: $(echo "$CONTENT" | grep defaultAllow || echo 'not found'))"
  exit 1
fi

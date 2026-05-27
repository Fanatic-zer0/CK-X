#!/bin/bash
# Q8 S2: Check encryption.yaml contains aescbc provider with a key
CONTENT=$(kubectl -n kube-system get configmap encryption-config \
  -o jsonpath='{.data.encryption\.yaml}' 2>/dev/null)

HAS_AESCBC=$(echo "$CONTENT" | grep -c "aescbc" 2>/dev/null || true)
HAS_KEY=$(echo "$CONTENT" | grep -c "secret:" 2>/dev/null || true)
HAS_SECRETS_RESOURCE=$(echo "$CONTENT" | grep -c "secrets" 2>/dev/null || true)

if [ "$HAS_AESCBC" -gt 0 ] && [ "$HAS_KEY" -gt 0 ] && [ "$HAS_SECRETS_RESOURCE" -gt 0 ]; then
  echo "✅ encryption.yaml contains aescbc provider targeting secrets resource with a key"
  exit 0
else
  echo "❌ encryption.yaml missing required content (aescbc:$HAS_AESCBC, key:$HAS_KEY, secrets:$HAS_SECRETS_RESOURCE)"
  exit 1
fi

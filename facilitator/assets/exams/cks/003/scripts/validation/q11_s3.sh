#!/bin/bash
# Q11 S3: Check ConfigMap allowed-registries exists in kube-system with registries field
CM_JSON=$(kubectl -n kube-system get configmap allowed-registries -o json 2>/dev/null)

if [ -z "$CM_JSON" ]; then
  echo "❌ ConfigMap allowed-registries not found in kube-system"
  exit 1
fi

HAS_REGISTRIES=$(echo "$CM_JSON" | grep -c "registries" 2>/dev/null || true)

if [ "$HAS_REGISTRIES" -gt 0 ]; then
  echo "✅ ConfigMap allowed-registries exists in kube-system with registries field"
  exit 0
else
  echo "❌ ConfigMap allowed-registries missing registries field"
  exit 1
fi

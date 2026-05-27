#!/bin/bash
# Q9 S3: Check ConfigMap policy-exceptions exists with exempt_namespaces field
CM_JSON=$(kubectl -n policy-config get configmap policy-exceptions -o json 2>/dev/null)

if [ -z "$CM_JSON" ]; then
  echo "❌ ConfigMap policy-exceptions not found in namespace policy-config"
  exit 1
fi

HAS_EXEMPT=$(echo "$CM_JSON" | grep -c "exempt_namespaces" 2>/dev/null || true)

if [ "$HAS_EXEMPT" -gt 0 ]; then
  echo "✅ ConfigMap policy-exceptions exists with exempt_namespaces field"
  exit 0
else
  echo "❌ ConfigMap policy-exceptions missing exempt_namespaces field"
  exit 1
fi

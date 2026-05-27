#!/bin/bash
# Q7 S3: Check ConfigMap verification-info exists with required fields
CM_JSON=$(kubectl -n binary-verification get configmap verification-info -o json 2>/dev/null)

if [ -z "$CM_JSON" ]; then
  echo "❌ ConfigMap verification-info not found in namespace binary-verification"
  exit 1
fi

HAS_PATH=$(echo "$CM_JSON" | grep -c 'binary_path' 2>/dev/null || true)
HAS_METHOD=$(echo "$CM_JSON" | grep -c 'verification_method' 2>/dev/null || true)
HAS_STATUS=$(echo "$CM_JSON" | grep -c 'status' 2>/dev/null || true)

if [ "$HAS_PATH" -gt 0 ] && [ "$HAS_METHOD" -gt 0 ] && [ "$HAS_STATUS" -gt 0 ]; then
  echo "✅ ConfigMap verification-info exists with binary_path, verification_method, and status fields"
  exit 0
else
  echo "❌ ConfigMap verification-info missing required fields (path:$HAS_PATH, method:$HAS_METHOD, status:$HAS_STATUS)"
  exit 1
fi

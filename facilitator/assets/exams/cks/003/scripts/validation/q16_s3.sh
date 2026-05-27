#!/bin/bash
# Q16 S3: Check ConfigMap cert-info exists with certName and checkType fields
CM_JSON=$(kubectl -n cert-monitoring get configmap cert-info -o json 2>/dev/null)

if [ -z "$CM_JSON" ]; then
  echo "❌ ConfigMap cert-info not found in namespace cert-monitoring"
  exit 1
fi

HAS_CERT_NAME=$(echo "$CM_JSON" | grep -c "certName" 2>/dev/null || true)
HAS_CHECK_TYPE=$(echo "$CM_JSON" | grep -c "checkType" 2>/dev/null || true)

if [ "$HAS_CERT_NAME" -gt 0 ] && [ "$HAS_CHECK_TYPE" -gt 0 ]; then
  echo "✅ ConfigMap cert-info exists with certName and checkType fields"
  exit 0
else
  echo "❌ ConfigMap cert-info missing required fields (certName:$HAS_CERT_NAME, checkType:$HAS_CHECK_TYPE)"
  exit 1
fi

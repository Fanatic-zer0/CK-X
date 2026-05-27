#!/bin/bash
# Q4: Validate Deployment secure-deployment exists in hardened-ns

kubectl get deployment secure-deployment -n hardened-ns &> /dev/null
if [ $? -eq 0 ]; then
  echo "✅ Deployment 'secure-deployment' exists in namespace 'hardened-ns'"
  exit 0
else
  echo "❌ Deployment 'secure-deployment' not found in namespace 'hardened-ns'"
  exit 1
fi

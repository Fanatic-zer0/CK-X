#!/bin/bash
# Q13: Validate pod fully-hardened-pod exists in hardened-pod-ns

kubectl get pod fully-hardened-pod -n hardened-pod-ns &> /dev/null
if [ $? -eq 0 ]; then
  echo "✅ Pod 'fully-hardened-pod' exists in namespace 'hardened-pod-ns'"
  exit 0
else
  echo "❌ Pod 'fully-hardened-pod' not found in namespace 'hardened-pod-ns'"
  exit 1
fi

#!/bin/bash
# Q7: Validate ConfigMap falco-custom-rules exists in falco-config

kubectl get configmap falco-custom-rules -n falco-config &> /dev/null
if [ $? -eq 0 ]; then
  echo "✅ ConfigMap 'falco-custom-rules' exists in namespace 'falco-config'"
  exit 0
else
  echo "❌ ConfigMap 'falco-custom-rules' not found in namespace 'falco-config'"
  exit 1
fi

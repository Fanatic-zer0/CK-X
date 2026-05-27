#!/bin/bash
# Q8: Validate ConfigMap audit-policy exists in kube-system

kubectl get configmap audit-policy -n kube-system &> /dev/null
if [ $? -eq 0 ]; then
  echo "✅ ConfigMap 'audit-policy' exists in namespace 'kube-system'"
  exit 0
else
  echo "❌ ConfigMap 'audit-policy' not found in namespace 'kube-system'"
  exit 1
fi

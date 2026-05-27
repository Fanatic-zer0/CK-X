#!/bin/bash
# Q8 S1: Check ConfigMap encryption-config exists in kube-system with key encryption.yaml
CM=$(kubectl -n kube-system get configmap encryption-config --no-headers 2>/dev/null)
KEY=$(kubectl -n kube-system get configmap encryption-config \
  -o jsonpath='{.data.encryption\.yaml}' 2>/dev/null)

if [ -n "$CM" ] && [ -n "$KEY" ]; then
  echo "✅ ConfigMap encryption-config exists in kube-system with key encryption.yaml"
  exit 0
else
  echo "❌ ConfigMap encryption-config missing or key encryption.yaml not present"
  exit 1
fi

#!/bin/bash
# Q9 S1: Check ConfigMap security-policy exists in policy-config with key policy.yaml
CM=$(kubectl -n policy-config get configmap security-policy --no-headers 2>/dev/null)
KEY=$(kubectl -n policy-config get configmap security-policy \
  -o jsonpath='{.data.policy\.yaml}' 2>/dev/null)

if [ -n "$CM" ] && [ -n "$KEY" ]; then
  echo "✅ ConfigMap security-policy exists in namespace policy-config with key policy.yaml"
  exit 0
else
  echo "❌ ConfigMap security-policy missing or key policy.yaml not present in namespace policy-config"
  exit 1
fi

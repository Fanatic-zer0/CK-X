#!/bin/bash
# Q8: Validate audit policy has RequestResponse rule for secrets

POLICY=$(kubectl get configmap audit-policy -n kube-system \
  -o jsonpath='{.data.policy\.yaml}' 2>/dev/null)

if [ -z "$POLICY" ]; then
  echo "❌ ConfigMap key 'policy.yaml' is missing or empty"
  exit 1
fi

if echo "$POLICY" | grep -q "RequestResponse" && echo "$POLICY" | grep -q "secrets"; then
  echo "✅ Audit policy has RequestResponse rule for secrets"
  exit 0
else
  echo "❌ Audit policy missing RequestResponse rule for secrets resource"
  exit 1
fi

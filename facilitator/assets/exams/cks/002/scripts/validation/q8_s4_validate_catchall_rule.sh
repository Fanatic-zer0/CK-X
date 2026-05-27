#!/bin/bash
# Q8: Validate audit policy has Metadata catch-all rule

POLICY=$(kubectl get configmap audit-policy -n kube-system \
  -o jsonpath='{.data.policy\.yaml}' 2>/dev/null)

if [ -z "$POLICY" ]; then
  echo "❌ ConfigMap key 'policy.yaml' is missing or empty"
  exit 1
fi

if echo "$POLICY" | grep -q "Metadata" && echo "$POLICY" | grep -q "audit.k8s.io/v1"; then
  echo "✅ Audit policy has Metadata catch-all rule and correct API version"
  exit 0
else
  echo "❌ Audit policy missing Metadata catch-all rule or incorrect API version (expected audit.k8s.io/v1)"
  exit 1
fi

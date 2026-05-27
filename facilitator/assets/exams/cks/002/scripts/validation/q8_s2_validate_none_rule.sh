#!/bin/bash
# Q8: Validate audit policy has None rule for health check endpoints

POLICY=$(kubectl get configmap audit-policy -n kube-system \
  -o jsonpath='{.data.policy\.yaml}' 2>/dev/null)

if [ -z "$POLICY" ]; then
  echo "❌ ConfigMap key 'policy.yaml' is missing or empty"
  exit 1
fi

# Check for None level for health endpoints
if echo "$POLICY" | grep -q "None" && echo "$POLICY" | grep -qE "/healthz|/readyz|/livez"; then
  echo "✅ Audit policy has None rule for health check endpoints"
  exit 0
else
  echo "❌ Audit policy missing None rule for /healthz, /readyz, /livez endpoints"
  exit 1
fi

#!/bin/bash
# Q16: Validate NetworkPolicy restrict-egress-registries exists in supply-chain-ns

kubectl get networkpolicy restrict-egress-registries -n supply-chain-ns &> /dev/null
if [ $? -ne 0 ]; then
  echo "❌ NetworkPolicy 'restrict-egress-registries' not found in namespace 'supply-chain-ns'"
  exit 1
fi

NP_JSON=$(kubectl get networkpolicy restrict-egress-registries -n supply-chain-ns -o json 2>/dev/null)

# Verify it has egress rules
if echo "$NP_JSON" | grep -q '"egress"'; then
  echo "✅ NetworkPolicy 'restrict-egress-registries' exists with egress rules"
  exit 0
else
  echo "❌ NetworkPolicy 'restrict-egress-registries' has no egress rules defined"
  exit 1
fi

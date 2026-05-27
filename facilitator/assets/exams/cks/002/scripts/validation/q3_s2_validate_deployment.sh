#!/bin/bash
# Q3: Validate Deployment no-token-app exists with 2 replicas

kubectl get deployment no-token-app -n sa-restrict &> /dev/null
if [ $? -ne 0 ]; then
  echo "❌ Deployment 'no-token-app' not found in namespace 'sa-restrict'"
  exit 1
fi

REPLICAS=$(kubectl get deployment no-token-app -n sa-restrict \
  -o jsonpath='{.spec.replicas}' 2>/dev/null)
if [ "$REPLICAS" != "2" ]; then
  echo "❌ Deployment 'no-token-app' has ${REPLICAS} replicas (expected: 2)"
  exit 1
fi

echo "✅ Deployment 'no-token-app' exists with 2 replicas"
exit 0

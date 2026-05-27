#!/bin/bash
# Q10: Validate Secret app-secret exists and is immutable

kubectl get secret app-secret -n immutable-ns &> /dev/null
if [ $? -ne 0 ]; then
  echo "❌ Secret 'app-secret' not found in namespace 'immutable-ns'"
  exit 1
fi

IMMUTABLE=$(kubectl get secret app-secret -n immutable-ns \
  -o jsonpath='{.immutable}' 2>/dev/null)

if [ "$IMMUTABLE" = "true" ]; then
  echo "✅ Secret 'app-secret' exists and is immutable"
  exit 0
else
  echo "❌ Secret 'app-secret' is not immutable. Got: '${IMMUTABLE}' (expected: true)"
  exit 1
fi

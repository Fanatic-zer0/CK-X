#!/bin/bash
# Q10: Validate ConfigMap app-config exists and is immutable

kubectl get configmap app-config -n immutable-ns &> /dev/null
if [ $? -ne 0 ]; then
  echo "❌ ConfigMap 'app-config' not found in namespace 'immutable-ns'"
  exit 1
fi

IMMUTABLE=$(kubectl get configmap app-config -n immutable-ns \
  -o jsonpath='{.immutable}' 2>/dev/null)

if [ "$IMMUTABLE" = "true" ]; then
  echo "✅ ConfigMap 'app-config' exists and is immutable"
  exit 0
else
  echo "❌ ConfigMap 'app-config' is not immutable. Got: '${IMMUTABLE}' (expected: true)"
  exit 1
fi

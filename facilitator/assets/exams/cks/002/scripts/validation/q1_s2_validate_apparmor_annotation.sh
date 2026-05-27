#!/bin/bash
# Q1: Validate pod has AppArmor annotation with runtime/default

ANNOTATION=$(kubectl get pod apparmor-nginx -n apparmor-ns \
  -o jsonpath='{.metadata.annotations.container\.apparmor\.security\.beta\.kubernetes\.io/apparmor-nginx}' 2>/dev/null)

if [ "$ANNOTATION" = "runtime/default" ]; then
  echo "✅ Pod has correct AppArmor annotation: runtime/default"
  exit 0
else
  echo "❌ Pod AppArmor annotation incorrect or missing. Got: '${ANNOTATION}' (expected: 'runtime/default')"
  exit 1
fi

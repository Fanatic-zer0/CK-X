#!/bin/bash
# Q3: Validate pod spec in Deployment has automountServiceAccountToken: false

AUTOMOUNT=$(kubectl get deployment no-token-app -n sa-restrict \
  -o jsonpath='{.spec.template.spec.automountServiceAccountToken}' 2>/dev/null)

if [ "$AUTOMOUNT" = "false" ]; then
  echo "✅ Deployment pod spec has automountServiceAccountToken: false"
  exit 0
else
  echo "❌ Deployment pod spec automountServiceAccountToken is '${AUTOMOUNT}' (expected: false)"
  exit 1
fi

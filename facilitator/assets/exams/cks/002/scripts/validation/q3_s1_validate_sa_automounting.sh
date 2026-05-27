#!/bin/bash
# Q3: Validate default ServiceAccount has automountServiceAccountToken: false

AUTOMOUNT=$(kubectl get serviceaccount default -n sa-restrict \
  -o jsonpath='{.automountServiceAccountToken}' 2>/dev/null)

if [ "$AUTOMOUNT" = "false" ]; then
  echo "✅ Default ServiceAccount in 'sa-restrict' has automountServiceAccountToken: false"
  exit 0
else
  echo "❌ Default ServiceAccount automountServiceAccountToken is '${AUTOMOUNT}' (expected: false)"
  exit 1
fi

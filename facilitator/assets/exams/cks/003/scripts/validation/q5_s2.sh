#!/bin/bash
# Q5 S2: Check seccompProfile type is RuntimeDefault
TYPE=$(kubectl -n prod-apps get deployment api-backend \
  -o jsonpath='{.spec.template.spec.securityContext.seccompProfile.type}' 2>/dev/null)

if [ "$TYPE" = "RuntimeDefault" ]; then
  echo "✅ seccompProfile type is RuntimeDefault"
  exit 0
else
  echo "❌ seccompProfile type is '$TYPE', expected RuntimeDefault"
  exit 1
fi

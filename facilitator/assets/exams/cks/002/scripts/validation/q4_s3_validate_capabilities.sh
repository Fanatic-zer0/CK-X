#!/bin/bash
# Q4: Validate container drops ALL capabilities

DROP_CAPS=$(kubectl get deployment secure-deployment -n hardened-ns \
  -o jsonpath='{.spec.template.spec.containers[0].securityContext.capabilities.drop}' 2>/dev/null)

if echo "$DROP_CAPS" | grep -qi "ALL"; then
  echo "✅ Container drops ALL capabilities"
  exit 0
else
  echo "❌ Container does not drop ALL capabilities. Got: '${DROP_CAPS}'"
  exit 1
fi

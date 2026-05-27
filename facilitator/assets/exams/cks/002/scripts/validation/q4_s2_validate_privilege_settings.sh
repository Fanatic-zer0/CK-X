#!/bin/bash
# Q4: Validate allowPrivilegeEscalation: false and readOnlyRootFilesystem: true

APE=$(kubectl get deployment secure-deployment -n hardened-ns \
  -o jsonpath='{.spec.template.spec.containers[0].securityContext.allowPrivilegeEscalation}' 2>/dev/null)
ROFS=$(kubectl get deployment secure-deployment -n hardened-ns \
  -o jsonpath='{.spec.template.spec.containers[0].securityContext.readOnlyRootFilesystem}' 2>/dev/null)

if [ "$APE" = "false" ] && [ "$ROFS" = "true" ]; then
  echo "✅ Container has allowPrivilegeEscalation: false and readOnlyRootFilesystem: true"
  exit 0
else
  echo "❌ Security context incorrect. allowPrivilegeEscalation: '${APE}' (expected: false), readOnlyRootFilesystem: '${ROFS}' (expected: true)"
  exit 1
fi

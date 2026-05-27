#!/bin/bash
# Q14: Validate container is not privileged and allowPrivilegeEscalation is false

PRIVILEGED=$(kubectl get deployment insecure-app -n vuln-fix \
  -o jsonpath='{.spec.template.spec.containers[0].securityContext.privileged}' 2>/dev/null)
APE=$(kubectl get deployment insecure-app -n vuln-fix \
  -o jsonpath='{.spec.template.spec.containers[0].securityContext.allowPrivilegeEscalation}' 2>/dev/null)

if [ "$PRIVILEGED" = "true" ]; then
  echo "❌ Container is still privileged (privileged: true)"
  exit 1
fi

if [ "$APE" = "true" ]; then
  echo "❌ Container still has allowPrivilegeEscalation: true"
  exit 1
fi

echo "✅ Container is not privileged and allowPrivilegeEscalation is not true"
exit 0

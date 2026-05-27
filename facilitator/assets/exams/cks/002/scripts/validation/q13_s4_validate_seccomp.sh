#!/bin/bash
# Q13: Validate pod has seccomp RuntimeDefault profile

SECCOMP_TYPE=$(kubectl get pod fully-hardened-pod -n hardened-pod-ns \
  -o jsonpath='{.spec.securityContext.seccompProfile.type}' 2>/dev/null)

if [ "$SECCOMP_TYPE" = "RuntimeDefault" ]; then
  echo "✅ Pod has seccomp profile type: RuntimeDefault"
  exit 0
else
  echo "❌ Pod seccomp profile type is '${SECCOMP_TYPE}' (expected: RuntimeDefault)"
  exit 1
fi

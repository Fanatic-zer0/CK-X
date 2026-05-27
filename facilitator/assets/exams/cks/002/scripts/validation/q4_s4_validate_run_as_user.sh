#!/bin/bash
# Q4: Validate container runs as non-root user 10001

RUN_AS_NON_ROOT=$(kubectl get deployment secure-deployment -n hardened-ns \
  -o jsonpath='{.spec.template.spec.containers[0].securityContext.runAsNonRoot}' 2>/dev/null)
RUN_AS_USER=$(kubectl get deployment secure-deployment -n hardened-ns \
  -o jsonpath='{.spec.template.spec.containers[0].securityContext.runAsUser}' 2>/dev/null)

if [ "$RUN_AS_NON_ROOT" = "true" ] && [ "$RUN_AS_USER" = "10001" ]; then
  echo "✅ Container runs as non-root user 10001"
  exit 0
else
  echo "❌ Incorrect user context. runAsNonRoot: '${RUN_AS_NON_ROOT}' (expected: true), runAsUser: '${RUN_AS_USER}' (expected: 10001)"
  exit 1
fi

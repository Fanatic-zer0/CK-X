#!/bin/bash
# Q6: Validate pod restricted-app exists with compliant security context

kubectl get pod restricted-app -n restricted-ns &> /dev/null
if [ $? -ne 0 ]; then
  echo "❌ Pod 'restricted-app' not found in namespace 'restricted-ns'"
  exit 1
fi

# Check runAsNonRoot
RUN_AS_NON_ROOT=$(kubectl get pod restricted-app -n restricted-ns \
  -o jsonpath='{.spec.containers[0].securityContext.runAsNonRoot}' 2>/dev/null)
APE=$(kubectl get pod restricted-app -n restricted-ns \
  -o jsonpath='{.spec.containers[0].securityContext.allowPrivilegeEscalation}' 2>/dev/null)

if [ "$RUN_AS_NON_ROOT" = "true" ] && [ "$APE" = "false" ]; then
  echo "✅ Pod 'restricted-app' exists with compliant security context (runAsNonRoot: true, allowPrivilegeEscalation: false)"
  exit 0
else
  echo "❌ Pod security context is not compliant. runAsNonRoot: '${RUN_AS_NON_ROOT}' (expected: true), allowPrivilegeEscalation: '${APE}' (expected: false)"
  exit 1
fi

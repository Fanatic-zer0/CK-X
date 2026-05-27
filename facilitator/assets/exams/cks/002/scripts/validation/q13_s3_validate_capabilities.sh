#!/bin/bash
# Q13: Validate pod drops ALL capabilities and has allowPrivilegeEscalation: false

DROP_CAPS=$(kubectl get pod fully-hardened-pod -n hardened-pod-ns \
  -o jsonpath='{.spec.containers[0].securityContext.capabilities.drop}' 2>/dev/null)
ADD_CAPS=$(kubectl get pod fully-hardened-pod -n hardened-pod-ns \
  -o jsonpath='{.spec.containers[0].securityContext.capabilities.add}' 2>/dev/null)
APE=$(kubectl get pod fully-hardened-pod -n hardened-pod-ns \
  -o jsonpath='{.spec.containers[0].securityContext.allowPrivilegeEscalation}' 2>/dev/null)

if ! echo "$DROP_CAPS" | grep -qi "ALL"; then
  echo "❌ Pod does not drop ALL capabilities. Got: '${DROP_CAPS}'"
  exit 1
fi

if [ -n "$ADD_CAPS" ] && [ "$ADD_CAPS" != "[]" ] && [ "$ADD_CAPS" != "null" ]; then
  echo "❌ Pod adds capabilities: '${ADD_CAPS}' - no capabilities should be added"
  exit 1
fi

if [ "$APE" = "false" ]; then
  echo "✅ Pod drops ALL capabilities, adds none, and has allowPrivilegeEscalation: false"
  exit 0
else
  echo "❌ Pod allowPrivilegeEscalation is '${APE}' (expected: false)"
  exit 1
fi

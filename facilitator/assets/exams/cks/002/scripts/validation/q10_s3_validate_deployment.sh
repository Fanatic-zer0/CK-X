#!/bin/bash
# Q10: Validate Deployment immutable-app exists with readOnlyRootFilesystem

kubectl get deployment immutable-app -n immutable-ns &> /dev/null
if [ $? -ne 0 ]; then
  echo "❌ Deployment 'immutable-app' not found in namespace 'immutable-ns'"
  exit 1
fi

ROFS=$(kubectl get deployment immutable-app -n immutable-ns \
  -o jsonpath='{.spec.template.spec.containers[0].securityContext.readOnlyRootFilesystem}' 2>/dev/null)

# Check for volume mounts
CM_MOUNT=$(kubectl get deployment immutable-app -n immutable-ns \
  -o jsonpath='{.spec.template.spec.containers[0].volumeMounts}' 2>/dev/null)

if [ "$ROFS" = "true" ] && echo "$CM_MOUNT" | grep -q "config\|secrets"; then
  echo "✅ Deployment 'immutable-app' has readOnlyRootFilesystem and correct volume mounts"
  exit 0
else
  echo "❌ Deployment readOnlyRootFilesystem: '${ROFS}' (expected: true), or volume mounts are missing"
  exit 1
fi

#!/bin/bash
# Q13: Validate pod has correct non-root user/group settings

RUN_AS_NON_ROOT=$(kubectl get pod fully-hardened-pod -n hardened-pod-ns \
  -o jsonpath='{.spec.securityContext.runAsNonRoot}' 2>/dev/null)
RUN_AS_USER=$(kubectl get pod fully-hardened-pod -n hardened-pod-ns \
  -o jsonpath='{.spec.securityContext.runAsUser}' 2>/dev/null)
RUN_AS_GROUP=$(kubectl get pod fully-hardened-pod -n hardened-pod-ns \
  -o jsonpath='{.spec.securityContext.runAsGroup}' 2>/dev/null)
FS_GROUP=$(kubectl get pod fully-hardened-pod -n hardened-pod-ns \
  -o jsonpath='{.spec.securityContext.fsGroup}' 2>/dev/null)

if [ "$RUN_AS_NON_ROOT" = "true" ] && [ "$RUN_AS_USER" = "1001" ] && \
   [ "$RUN_AS_GROUP" = "1001" ] && [ "$FS_GROUP" = "2000" ]; then
  echo "✅ Pod has correct non-root user/group settings (user: 1001, group: 1001, fsGroup: 2000)"
  exit 0
else
  echo "❌ Pod user/group settings incorrect. runAsNonRoot: ${RUN_AS_NON_ROOT}, runAsUser: ${RUN_AS_USER} (expected: 1001), runAsGroup: ${RUN_AS_GROUP} (expected: 1001), fsGroup: ${FS_GROUP} (expected: 2000)"
  exit 1
fi

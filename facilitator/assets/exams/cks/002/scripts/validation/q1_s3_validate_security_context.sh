#!/bin/bash
# Q1: Validate pod runs as user 1000 and group 1000

RUN_AS_USER=$(kubectl get pod apparmor-nginx -n apparmor-ns \
  -o jsonpath='{.spec.securityContext.runAsUser}' 2>/dev/null)
RUN_AS_GROUP=$(kubectl get pod apparmor-nginx -n apparmor-ns \
  -o jsonpath='{.spec.securityContext.runAsGroup}' 2>/dev/null)

if [ "$RUN_AS_USER" = "1000" ] && [ "$RUN_AS_GROUP" = "1000" ]; then
  echo "✅ Pod runs as user 1000 and group 1000"
  exit 0
else
  echo "❌ Pod security context incorrect. runAsUser: '${RUN_AS_USER}' (expected: 1000), runAsGroup: '${RUN_AS_GROUP}' (expected: 1000)"
  exit 1
fi

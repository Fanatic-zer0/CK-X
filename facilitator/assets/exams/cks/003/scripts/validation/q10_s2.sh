#!/bin/bash
# Q10 S2: Check deployment privileged-app is not privileged and not using hostPID
PRIVILEGED=$(kubectl -n legacy-workloads get deployment privileged-app \
  -o jsonpath='{.spec.template.spec.containers[0].securityContext.privileged}' 2>/dev/null)
HOST_PID=$(kubectl -n legacy-workloads get deployment privileged-app \
  -o jsonpath='{.spec.template.spec.hostPID}' 2>/dev/null)

PASS=true
MSG=""

[ "$PRIVILEGED" != "true" ] || { PASS=false; MSG="$MSG privileged=true;"; }
[ "$HOST_PID" != "true" ] || { PASS=false; MSG="$MSG hostPID=true;"; }

if $PASS; then
  echo "✅ Deployment privileged-app has privileged=false and hostPID=false"
  exit 0
else
  echo "❌ Deployment privileged-app still has: $MSG"
  exit 1
fi

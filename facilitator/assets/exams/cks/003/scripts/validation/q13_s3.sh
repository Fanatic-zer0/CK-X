#!/bin/bash
# Q13 S3: Check data-processor has allowPrivilegeEscalation: false and emptyDir at /tmp
APE=$(kubectl -n mutable-apps get deployment data-processor \
  -o jsonpath='{.spec.template.spec.containers[0].securityContext.allowPrivilegeEscalation}' 2>/dev/null)
MOUNTS=$(kubectl -n mutable-apps get deployment data-processor \
  -o jsonpath='{.spec.template.spec.containers[0].volumeMounts}' 2>/dev/null)
VOLUMES=$(kubectl -n mutable-apps get deployment data-processor \
  -o jsonpath='{.spec.template.spec.volumes}' 2>/dev/null)

PASS=true
MSG=""

[ "$APE" = "false" ] || { PASS=false; MSG="$MSG allowPrivilegeEscalation=$APE (expected false);"; }
echo "$MOUNTS" | grep -q "/tmp" || { PASS=false; MSG="$MSG /tmp mountPath missing;"; }
echo "$VOLUMES" | grep -q "emptyDir" || { PASS=false; MSG="$MSG emptyDir volume missing;"; }

if $PASS; then
  echo "✅ data-processor has allowPrivilegeEscalation: false and emptyDir volume at /tmp"
  exit 0
else
  echo "❌ data-processor missing: $MSG"
  exit 1
fi

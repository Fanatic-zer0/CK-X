#!/bin/bash
# Q13 S2: Check data-processor runs as user 1000 with runAsNonRoot: true
RUN_AS_USER=$(kubectl -n mutable-apps get deployment data-processor \
  -o jsonpath='{.spec.template.spec.containers[0].securityContext.runAsUser}' 2>/dev/null)
NON_ROOT=$(kubectl -n mutable-apps get deployment data-processor \
  -o jsonpath='{.spec.template.spec.containers[0].securityContext.runAsNonRoot}' 2>/dev/null)

PASS=true
MSG=""

[ "$RUN_AS_USER" = "1000" ] || { PASS=false; MSG="$MSG runAsUser=$RUN_AS_USER (expected 1000);"; }
[ "$NON_ROOT" = "true" ] || { PASS=false; MSG="$MSG runAsNonRoot=$NON_ROOT (expected true);"; }

if $PASS; then
  echo "✅ Deployment data-processor runs as user 1000 with runAsNonRoot: true"
  exit 0
else
  echo "❌ data-processor security context misconfigured: $MSG"
  exit 1
fi

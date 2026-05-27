#!/bin/bash
# Q4 S2: Check Role dev-role exists with get/list/watch on pods, services, deployments
ROLE_JSON=$(kubectl -n dev-team get role dev-role -o json 2>/dev/null)

if [ -z "$ROLE_JSON" ]; then
  echo "❌ Role dev-role not found in namespace dev-team"
  exit 1
fi

PASS=true
MSG=""

for verb in get list watch; do
  echo "$ROLE_JSON" | grep -q "\"$verb\"" || { PASS=false; MSG="$MSG verb=$verb;"; }
done

for resource in pods services deployments; do
  echo "$ROLE_JSON" | grep -q "\"$resource\"" || { PASS=false; MSG="$MSG resource=$resource;"; }
done

# Check for wildcards (should NOT exist)
if echo "$ROLE_JSON" | grep -q '"\\*"'; then
  PASS=false
  MSG="$MSG wildcard (*) found - must not use wildcards;"
fi

if $PASS; then
  echo "✅ Role dev-role has correct get/list/watch permissions on pods, services, deployments"
  exit 0
else
  echo "❌ Role dev-role is misconfigured, missing: $MSG"
  exit 1
fi

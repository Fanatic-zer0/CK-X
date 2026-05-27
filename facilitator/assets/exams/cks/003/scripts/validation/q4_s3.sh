#!/bin/bash
# Q4 S3: Check RoleBinding dev-role-binding exists binding dev-role to dev-sa
RB_JSON=$(kubectl -n dev-team get rolebinding dev-role-binding -o json 2>/dev/null)

if [ -z "$RB_JSON" ]; then
  echo "❌ RoleBinding dev-role-binding not found in namespace dev-team"
  exit 1
fi

HAS_ROLE=$(echo "$RB_JSON" | grep -c '"dev-role"' 2>/dev/null || true)
HAS_SA=$(echo "$RB_JSON" | grep -c '"dev-sa"' 2>/dev/null || true)

if [ "$HAS_ROLE" -gt 0 ] && [ "$HAS_SA" -gt 0 ]; then
  echo "✅ RoleBinding dev-role-binding correctly binds dev-role to dev-sa"
  exit 0
else
  echo "❌ RoleBinding dev-role-binding misconfigured (role=dev-role: $HAS_ROLE, sa=dev-sa: $HAS_SA)"
  exit 1
fi

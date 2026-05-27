#!/bin/bash
# Q2: Validate ClusterRole does not grant access to secrets or write operations

RULES=$(kubectl get clusterrole resource-reader -o json 2>/dev/null)

# Check that wildcard verbs are not present
if echo "$RULES" | grep -q '"[*]"'; then
  echo "❌ ClusterRole contains wildcard (*) verbs - violates least privilege"
  exit 1
fi

# Check that write verbs are not present
if echo "$RULES" | grep -qE '"create"|"update"|"patch"|"delete"|"deletecollection"'; then
  echo "❌ ClusterRole contains write verbs (create/update/patch/delete) - violates least privilege"
  exit 1
fi

# Check that secrets resource is not in any rule
if echo "$RULES" | grep -q '"secrets"'; then
  echo "❌ ClusterRole grants access to 'secrets' - must not be included"
  exit 1
fi

echo "✅ ClusterRole 'resource-reader' correctly excludes secrets and write operations"
exit 0

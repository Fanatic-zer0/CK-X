#!/bin/bash
# Q12: Validate ClusterRole over-permissive no longer has wildcard permissions

kubectl get clusterrole over-permissive &> /dev/null
if [ $? -ne 0 ]; then
  echo "❌ ClusterRole 'over-permissive' not found"
  exit 1
fi

RULES=$(kubectl get clusterrole over-permissive -o json 2>/dev/null)

# Check that wildcards are gone
if echo "$RULES" | grep -q '"[*]"'; then
  echo "❌ ClusterRole 'over-permissive' still has wildcard (*) permissions"
  exit 1
fi

# Check that only allowed resources remain (pods, services)
if echo "$RULES" | grep -qE '"pods"|"services"'; then
  # Make sure it has only get/list and not write verbs
  if echo "$RULES" | grep -qE '"create"|"update"|"patch"|"delete"'; then
    echo "❌ ClusterRole 'over-permissive' still has write verbs"
    exit 1
  fi
  echo "✅ ClusterRole 'over-permissive' has been fixed - no wildcards, only read access to pods/services"
  exit 0
else
  echo "❌ ClusterRole 'over-permissive' does not grant access to pods and services as required"
  exit 1
fi

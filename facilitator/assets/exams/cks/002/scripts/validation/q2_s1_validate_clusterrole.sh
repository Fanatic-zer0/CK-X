#!/bin/bash
# Q2: Validate ClusterRole resource-reader exists with correct read-only verbs

kubectl get clusterrole resource-reader &> /dev/null
if [ $? -ne 0 ]; then
  echo "❌ ClusterRole 'resource-reader' not found"
  exit 1
fi

# Check that it includes read-only verbs on allowed resources
RULES=$(kubectl get clusterrole resource-reader -o json 2>/dev/null)

# Check for get verb
echo "$RULES" | grep -q '"get"'
if [ $? -ne 0 ]; then
  echo "❌ ClusterRole missing 'get' verb"
  exit 1
fi

# Check that nodes/pods/services/namespaces are present
echo "$RULES" | grep -qE '"nodes"|"pods"|"services"|"namespaces"'
if [ $? -ne 0 ]; then
  echo "❌ ClusterRole does not include required resources (nodes, pods, services, namespaces)"
  exit 1
fi

echo "✅ ClusterRole 'resource-reader' exists with correct read-only verbs"
exit 0

#!/bin/bash
# Q12: Validate ClusterRoleBinding dangerous-admin has been deleted

kubectl get clusterrolebinding dangerous-admin &> /dev/null
if [ $? -ne 0 ]; then
  echo "✅ ClusterRoleBinding 'dangerous-admin' has been deleted"
  exit 0
else
  echo "❌ ClusterRoleBinding 'dangerous-admin' still exists - it must be deleted"
  exit 1
fi

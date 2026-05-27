#!/bin/bash
# Q4 S1: Check ClusterRoleBinding dev-cluster-admin has been deleted
CRB=$(kubectl get clusterrolebinding dev-cluster-admin --no-headers 2>/dev/null)

if [ -z "$CRB" ]; then
  echo "✅ ClusterRoleBinding dev-cluster-admin has been deleted"
  exit 0
else
  echo "❌ ClusterRoleBinding dev-cluster-admin still exists and must be deleted"
  exit 1
fi

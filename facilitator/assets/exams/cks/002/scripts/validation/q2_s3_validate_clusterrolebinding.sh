#!/bin/bash
# Q2: Validate ClusterRoleBinding audit-user-binding exists and is correctly configured

kubectl get clusterrolebinding audit-user-binding &> /dev/null
if [ $? -ne 0 ]; then
  echo "❌ ClusterRoleBinding 'audit-user-binding' not found"
  exit 1
fi

# Check role reference
ROLE_REF=$(kubectl get clusterrolebinding audit-user-binding \
  -o jsonpath='{.roleRef.name}' 2>/dev/null)
if [ "$ROLE_REF" != "resource-reader" ]; then
  echo "❌ ClusterRoleBinding references wrong ClusterRole: '${ROLE_REF}' (expected: 'resource-reader')"
  exit 1
fi

# Check subject
SUBJECT_NAME=$(kubectl get clusterrolebinding audit-user-binding \
  -o jsonpath='{.subjects[0].name}' 2>/dev/null)
SUBJECT_NS=$(kubectl get clusterrolebinding audit-user-binding \
  -o jsonpath='{.subjects[0].namespace}' 2>/dev/null)

if [ "$SUBJECT_NAME" != "audit-user" ] || [ "$SUBJECT_NS" != "cluster-rbac" ]; then
  echo "❌ ClusterRoleBinding subject incorrect. name: '${SUBJECT_NAME}' (expected: audit-user), namespace: '${SUBJECT_NS}' (expected: cluster-rbac)"
  exit 1
fi

echo "✅ ClusterRoleBinding 'audit-user-binding' is correctly configured"
exit 0

#!/bin/bash
# Q12: Validate ClusterRoleBinding minimal-binding exists and is correctly configured

kubectl get clusterrolebinding minimal-binding &> /dev/null
if [ $? -ne 0 ]; then
  echo "❌ ClusterRoleBinding 'minimal-binding' not found"
  exit 1
fi

ROLE_REF=$(kubectl get clusterrolebinding minimal-binding \
  -o jsonpath='{.roleRef.name}' 2>/dev/null)
SUBJECT_NAME=$(kubectl get clusterrolebinding minimal-binding \
  -o jsonpath='{.subjects[0].name}' 2>/dev/null)
SUBJECT_NS=$(kubectl get clusterrolebinding minimal-binding \
  -o jsonpath='{.subjects[0].namespace}' 2>/dev/null)

if [ "$ROLE_REF" = "over-permissive" ] && [ "$SUBJECT_NAME" = "temp-sa" ] && [ "$SUBJECT_NS" = "rbac-fix" ]; then
  echo "✅ ClusterRoleBinding 'minimal-binding' is correctly configured"
  exit 0
else
  echo "❌ ClusterRoleBinding 'minimal-binding' incorrect. roleRef: '${ROLE_REF}' (expected: over-permissive), subject: '${SUBJECT_NAME}' in '${SUBJECT_NS}' (expected: temp-sa in rbac-fix)"
  exit 1
fi

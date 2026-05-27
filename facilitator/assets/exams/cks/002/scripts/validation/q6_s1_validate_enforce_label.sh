#!/bin/bash
# Q6: Validate namespace restricted-ns has enforce=restricted label

kubectl get namespace restricted-ns &> /dev/null
if [ $? -ne 0 ]; then
  echo "❌ Namespace 'restricted-ns' does not exist"
  exit 1
fi

ENFORCE_LABEL=$(kubectl get namespace restricted-ns \
  -o jsonpath='{.metadata.labels.pod-security\.kubernetes\.io/enforce}' 2>/dev/null)

if [ "$ENFORCE_LABEL" = "restricted" ]; then
  echo "✅ Namespace 'restricted-ns' has pod-security.kubernetes.io/enforce=restricted"
  exit 0
else
  echo "❌ Namespace enforce label is '${ENFORCE_LABEL}' (expected: restricted)"
  exit 1
fi

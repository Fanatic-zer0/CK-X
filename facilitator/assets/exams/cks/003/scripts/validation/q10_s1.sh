#!/bin/bash
# Q10 S1: Check namespace legacy-workloads has enforce=baseline label
LABEL=$(kubectl get namespace legacy-workloads \
  -o jsonpath='{.metadata.labels.pod-security\.kubernetes\.io/enforce}' 2>/dev/null)

if [ "$LABEL" = "baseline" ]; then
  echo "✅ Namespace legacy-workloads has pod-security.kubernetes.io/enforce=baseline label"
  exit 0
else
  echo "❌ Namespace legacy-workloads missing enforce=baseline label (got: '$LABEL')"
  exit 1
fi

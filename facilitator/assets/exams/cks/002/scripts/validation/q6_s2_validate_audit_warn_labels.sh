#!/bin/bash
# Q6: Validate namespace has audit=restricted and warn=restricted labels

AUDIT_LABEL=$(kubectl get namespace restricted-ns \
  -o jsonpath='{.metadata.labels.pod-security\.kubernetes\.io/audit}' 2>/dev/null)
WARN_LABEL=$(kubectl get namespace restricted-ns \
  -o jsonpath='{.metadata.labels.pod-security\.kubernetes\.io/warn}' 2>/dev/null)

if [ "$AUDIT_LABEL" = "restricted" ] && [ "$WARN_LABEL" = "restricted" ]; then
  echo "✅ Namespace has audit=restricted and warn=restricted labels"
  exit 0
else
  echo "❌ Labels incorrect. audit: '${AUDIT_LABEL}' (expected: restricted), warn: '${WARN_LABEL}' (expected: restricted)"
  exit 1
fi

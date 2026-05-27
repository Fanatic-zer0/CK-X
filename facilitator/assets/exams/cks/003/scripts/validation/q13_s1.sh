#!/bin/bash
# Q13 S1: Check data-processor has readOnlyRootFilesystem: true
RORF=$(kubectl -n mutable-apps get deployment data-processor \
  -o jsonpath='{.spec.template.spec.containers[0].securityContext.readOnlyRootFilesystem}' 2>/dev/null)

if [ "$RORF" = "true" ]; then
  echo "✅ Deployment data-processor has readOnlyRootFilesystem: true"
  exit 0
else
  echo "❌ Deployment data-processor readOnlyRootFilesystem is '$RORF', expected true"
  exit 1
fi

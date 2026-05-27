#!/bin/bash
# Q5: Validate pod uses runtimeClassName: secure-runtime

RUNTIME_CLASS=$(kubectl get pod sandboxed-pod -n sandbox-workloads \
  -o jsonpath='{.spec.runtimeClassName}' 2>/dev/null)

if [ "$RUNTIME_CLASS" = "secure-runtime" ]; then
  echo "✅ Pod uses runtimeClassName: secure-runtime"
  exit 0
else
  echo "❌ Pod runtimeClassName is '${RUNTIME_CLASS}' (expected: secure-runtime)"
  exit 1
fi

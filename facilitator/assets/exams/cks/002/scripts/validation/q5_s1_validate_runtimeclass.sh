#!/bin/bash
# Q5: Validate RuntimeClass secure-runtime exists with handler runc

kubectl get runtimeclass secure-runtime &> /dev/null
if [ $? -ne 0 ]; then
  echo "❌ RuntimeClass 'secure-runtime' not found"
  exit 1
fi

HANDLER=$(kubectl get runtimeclass secure-runtime \
  -o jsonpath='{.handler}' 2>/dev/null)

if [ "$HANDLER" = "runc" ]; then
  echo "✅ RuntimeClass 'secure-runtime' exists with handler 'runc'"
  exit 0
else
  echo "❌ RuntimeClass handler is '${HANDLER}' (expected: runc)"
  exit 1
fi

#!/bin/bash
# Q14: Validate hostPID and hostNetwork are not enabled

HOST_PID=$(kubectl get deployment insecure-app -n vuln-fix \
  -o jsonpath='{.spec.template.spec.hostPID}' 2>/dev/null)
HOST_NETWORK=$(kubectl get deployment insecure-app -n vuln-fix \
  -o jsonpath='{.spec.template.spec.hostNetwork}' 2>/dev/null)

if [ "$HOST_PID" = "true" ]; then
  echo "❌ Deployment still has hostPID: true"
  exit 1
fi

if [ "$HOST_NETWORK" = "true" ]; then
  echo "❌ Deployment still has hostNetwork: true"
  exit 1
fi

echo "✅ hostPID and hostNetwork are not enabled"
exit 0

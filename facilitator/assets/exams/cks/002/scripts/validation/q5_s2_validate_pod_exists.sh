#!/bin/bash
# Q5: Validate pod sandboxed-pod exists in sandbox-workloads

kubectl get pod sandboxed-pod -n sandbox-workloads &> /dev/null
if [ $? -eq 0 ]; then
  echo "✅ Pod 'sandboxed-pod' exists in namespace 'sandbox-workloads'"
  exit 0
else
  echo "❌ Pod 'sandboxed-pod' not found in namespace 'sandbox-workloads'"
  exit 1
fi

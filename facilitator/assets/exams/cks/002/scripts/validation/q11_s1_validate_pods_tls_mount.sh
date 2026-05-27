#!/bin/bash
# Q11: Validate both server-pod and client-pod exist and mount app-tls secret

for POD in server-pod client-pod; do
  kubectl get pod $POD -n mtls-app &> /dev/null
  if [ $? -ne 0 ]; then
    echo "❌ Pod '${POD}' not found in namespace 'mtls-app'"
    exit 1
  fi
  # Check that the pod mounts app-tls
  VOLUMES=$(kubectl get pod $POD -n mtls-app -o jsonpath='{.spec.volumes}' 2>/dev/null)
  if ! echo "$VOLUMES" | grep -q "app-tls"; then
    echo "❌ Pod '${POD}' does not mount the 'app-tls' secret"
    exit 1
  fi
done

echo "✅ Both 'server-pod' and 'client-pod' exist and mount app-tls secret"
exit 0

#!/bin/bash
# Q15: Validate pod trivy-scanner exists with correct scan command

kubectl get pod trivy-scanner -n image-security &> /dev/null
if [ $? -ne 0 ]; then
  echo "❌ Pod 'trivy-scanner' not found in namespace 'image-security'"
  exit 1
fi

# Check the pod image
POD_IMAGE=$(kubectl get pod trivy-scanner -n image-security \
  -o jsonpath='{.spec.containers[0].image}' 2>/dev/null)

if ! echo "$POD_IMAGE" | grep -q "trivy"; then
  echo "❌ Pod does not use a trivy image. Got: '${POD_IMAGE}'"
  exit 1
fi

# Check the command contains trivy image scan for nginx:1.19
POD_ARGS=$(kubectl get pod trivy-scanner -n image-security \
  -o jsonpath='{.spec.containers[0].args}' 2>/dev/null)
POD_CMD=$(kubectl get pod trivy-scanner -n image-security \
  -o jsonpath='{.spec.containers[0].command}' 2>/dev/null)

COMBINED="${POD_CMD} ${POD_ARGS}"

if echo "$COMBINED" | grep -q "nginx" && echo "$COMBINED" | grep -q "HIGH\|CRITICAL\|severity"; then
  echo "✅ Pod 'trivy-scanner' exists with trivy image scan command for nginx"
  exit 0
else
  echo "❌ Pod command does not appear to scan nginx with HIGH/CRITICAL severity filter. Got: '${COMBINED}'"
  exit 1
fi

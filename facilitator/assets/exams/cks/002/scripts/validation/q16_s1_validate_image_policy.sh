#!/bin/bash
# Q16: Validate ConfigMap image-policy exists in kube-system with blockLatestTag field

kubectl get configmap image-policy -n kube-system &> /dev/null
if [ $? -ne 0 ]; then
  echo "❌ ConfigMap 'image-policy' not found in namespace 'kube-system'"
  exit 1
fi

CM_DATA=$(kubectl get configmap image-policy -n kube-system \
  -o jsonpath='{.data.policy\.yaml}' 2>/dev/null)

if echo "$CM_DATA" | grep -q "blockLatestTag" && echo "$CM_DATA" | grep -q "allowedRegistries"; then
  echo "✅ ConfigMap 'image-policy' exists in kube-system with blockLatestTag and allowedRegistries fields"
  exit 0
else
  echo "❌ ConfigMap 'image-policy' missing required fields (blockLatestTag or allowedRegistries)"
  exit 1
fi

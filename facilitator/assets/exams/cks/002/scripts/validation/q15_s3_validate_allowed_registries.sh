#!/bin/bash
# Q15: Validate ConfigMap allowed-registries exists with correct registry list

kubectl get configmap allowed-registries -n image-security &> /dev/null
if [ $? -ne 0 ]; then
  echo "❌ ConfigMap 'allowed-registries' not found in namespace 'image-security'"
  exit 1
fi

CM_DATA=$(kubectl get configmap allowed-registries -n image-security \
  -o jsonpath='{.data.registries\.yaml}' 2>/dev/null)

if echo "$CM_DATA" | grep -q "docker.io" && echo "$CM_DATA" | grep -q "registry.k8s.io"; then
  echo "✅ ConfigMap 'allowed-registries' exists with correct registry list"
  exit 0
else
  echo "❌ ConfigMap 'allowed-registries' missing required registries (docker.io, registry.k8s.io)"
  exit 1
fi

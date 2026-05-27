#!/bin/bash
# Q16: Validate pod verified-app exists with all required labels

kubectl get pod verified-app -n supply-chain-ns &> /dev/null
if [ $? -ne 0 ]; then
  echo "❌ Pod 'verified-app' not found in namespace 'supply-chain-ns'"
  exit 1
fi

LABEL_VERIFIED=$(kubectl get pod verified-app -n supply-chain-ns \
  -o jsonpath='{.metadata.labels.image-verified}' 2>/dev/null)
LABEL_REGISTRY=$(kubectl get pod verified-app -n supply-chain-ns \
  -o jsonpath='{.metadata.labels.registry}' 2>/dev/null)
LABEL_TAG=$(kubectl get pod verified-app -n supply-chain-ns \
  -o jsonpath='{.metadata.labels.image-tag}' 2>/dev/null)

if [ "$LABEL_VERIFIED" = "true" ] && [ "$LABEL_REGISTRY" = "docker.io" ] && [ -n "$LABEL_TAG" ]; then
  echo "✅ Pod 'verified-app' exists with correct labels (image-verified: true, registry: docker.io, image-tag: ${LABEL_TAG})"
  exit 0
else
  echo "❌ Pod labels incorrect. image-verified: '${LABEL_VERIFIED}' (expected: true), registry: '${LABEL_REGISTRY}' (expected: docker.io), image-tag: '${LABEL_TAG}'"
  exit 1
fi

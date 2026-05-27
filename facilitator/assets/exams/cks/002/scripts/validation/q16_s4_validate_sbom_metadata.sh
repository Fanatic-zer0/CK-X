#!/bin/bash
# Q16: Validate ConfigMap sbom-metadata exists in supply-chain-ns with required fields

kubectl get configmap sbom-metadata -n supply-chain-ns &> /dev/null
if [ $? -ne 0 ]; then
  echo "❌ ConfigMap 'sbom-metadata' not found in namespace 'supply-chain-ns'"
  exit 1
fi

IMAGE=$(kubectl get configmap sbom-metadata -n supply-chain-ns \
  -o jsonpath='{.data.image}' 2>/dev/null)
SCANNER=$(kubectl get configmap sbom-metadata -n supply-chain-ns \
  -o jsonpath='{.data.scanner}' 2>/dev/null)
DIGEST=$(kubectl get configmap sbom-metadata -n supply-chain-ns \
  -o jsonpath='{.data.digest}' 2>/dev/null)

if [ -n "$IMAGE" ] && [ "$SCANNER" = "trivy" ] && [ -n "$DIGEST" ]; then
  echo "✅ ConfigMap 'sbom-metadata' exists with required SBOM fields (image: ${IMAGE}, scanner: trivy)"
  exit 0
else
  echo "❌ ConfigMap 'sbom-metadata' missing required fields. image: '${IMAGE}', scanner: '${SCANNER}' (expected: trivy), digest: '${DIGEST}'"
  exit 1
fi

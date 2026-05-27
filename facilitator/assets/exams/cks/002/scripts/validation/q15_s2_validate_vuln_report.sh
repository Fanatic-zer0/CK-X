#!/bin/bash
# Q15: Validate ConfigMap vulnerability-report exists with correct metadata

kubectl get configmap vulnerability-report -n image-security &> /dev/null
if [ $? -ne 0 ]; then
  echo "❌ ConfigMap 'vulnerability-report' not found in namespace 'image-security'"
  exit 1
fi

CM_DATA=$(kubectl get configmap vulnerability-report -n image-security \
  -o jsonpath='{.data.report\.txt}' 2>/dev/null)

if echo "$CM_DATA" | grep -q "nginx:1.19" && echo "$CM_DATA" | grep -q "trivy"; then
  echo "✅ ConfigMap 'vulnerability-report' exists with nginx:1.19 and trivy metadata"
  exit 0
else
  echo "❌ ConfigMap 'vulnerability-report' missing required fields (nginx:1.19 image or trivy tool reference)"
  exit 1
fi

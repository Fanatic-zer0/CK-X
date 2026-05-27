#!/bin/bash
# Q9 S2: Check policy.yaml contains ClusterPolicy with rule check-security-scan-label
CONTENT=$(kubectl -n policy-config get configmap security-policy \
  -o jsonpath='{.data.policy\.yaml}' 2>/dev/null)

HAS_CLUSTER_POLICY=$(echo "$CONTENT" | grep -c "ClusterPolicy" 2>/dev/null || true)
HAS_RULE=$(echo "$CONTENT" | grep -c "check-security-scan-label" 2>/dev/null || true)

if [ "$HAS_CLUSTER_POLICY" -gt 0 ] && [ "$HAS_RULE" -gt 0 ]; then
  echo "✅ policy.yaml contains ClusterPolicy with rule check-security-scan-label"
  exit 0
else
  echo "❌ policy.yaml missing ClusterPolicy kind or rule 'check-security-scan-label' (ClusterPolicy:$HAS_CLUSTER_POLICY, rule:$HAS_RULE)"
  exit 1
fi

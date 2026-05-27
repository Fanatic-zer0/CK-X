#!/bin/bash
# Q9: Validate default-deny NetworkPolicy exists and denies all ingress/egress

kubectl get networkpolicy default-deny -n isolated-app &> /dev/null
if [ $? -ne 0 ]; then
  echo "❌ NetworkPolicy 'default-deny' not found in namespace 'isolated-app'"
  exit 1
fi

# Check that policyTypes includes both Ingress and Egress
POLICY_TYPES=$(kubectl get networkpolicy default-deny -n isolated-app \
  -o jsonpath='{.spec.policyTypes}' 2>/dev/null)

if echo "$POLICY_TYPES" | grep -q "Ingress" && echo "$POLICY_TYPES" | grep -q "Egress"; then
  echo "✅ NetworkPolicy 'default-deny' exists and covers both Ingress and Egress"
  exit 0
else
  echo "❌ NetworkPolicy 'default-deny' does not cover both Ingress and Egress. Got: ${POLICY_TYPES}"
  exit 1
fi

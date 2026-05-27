#!/bin/bash
# Q9: Validate allow-internal NetworkPolicy permits same-namespace traffic

kubectl get networkpolicy allow-internal -n isolated-app &> /dev/null
if [ $? -ne 0 ]; then
  echo "❌ NetworkPolicy 'allow-internal' not found in namespace 'isolated-app'"
  exit 1
fi

POLICY_JSON=$(kubectl get networkpolicy allow-internal -n isolated-app -o json 2>/dev/null)

# Check ingress is defined
INGRESS=$(echo "$POLICY_JSON" | grep -c '"ingress"')
EGRESS=$(echo "$POLICY_JSON" | grep -c '"egress"')

if [ "$INGRESS" -gt 0 ] && [ "$EGRESS" -gt 0 ]; then
  echo "✅ NetworkPolicy 'allow-internal' has both ingress and egress rules for same-namespace traffic"
  exit 0
else
  echo "❌ NetworkPolicy 'allow-internal' is missing ingress or egress rules"
  exit 1
fi

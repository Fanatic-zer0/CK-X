#!/bin/bash
# Q11: Validate NetworkPolicy tls-only-traffic exists with port 443

kubectl get networkpolicy tls-only-traffic -n mtls-app &> /dev/null
if [ $? -ne 0 ]; then
  echo "❌ NetworkPolicy 'tls-only-traffic' not found in namespace 'mtls-app'"
  exit 1
fi

NP_JSON=$(kubectl get networkpolicy tls-only-traffic -n mtls-app -o json 2>/dev/null)

# Check for port 443
if echo "$NP_JSON" | grep -q '"443"' || echo "$NP_JSON" | python3 -c "
import sys, json
data = json.load(sys.stdin)
spec = data.get('spec', {})
ingress_ports = [p.get('port') for rule in spec.get('ingress', []) for p in rule.get('ports', [])]
egress_ports = [p.get('port') for rule in spec.get('egress', []) for p in rule.get('ports', [])]
exit(0 if 443 in ingress_ports or 443 in egress_ports else 1)
" 2>/dev/null; then
  echo "✅ NetworkPolicy 'tls-only-traffic' exists with port 443 rules"
  exit 0
else
  echo "❌ NetworkPolicy 'tls-only-traffic' does not have port 443 rules"
  exit 1
fi

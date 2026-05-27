#!/bin/bash
# Q9: Validate allow-internal NetworkPolicy has DNS egress rule on port 53

POLICY_JSON=$(kubectl get networkpolicy allow-internal -n isolated-app -o json 2>/dev/null)

if echo "$POLICY_JSON" | grep -q '"53"' || echo "$POLICY_JSON" | grep -q "'53'"; then
  echo "✅ NetworkPolicy 'allow-internal' includes DNS egress rule on port 53"
  exit 0
else
  # Also check for integer port 53
  if echo "$POLICY_JSON" | python3 -c "import sys,json; data=json.load(sys.stdin); egress=data.get('spec',{}).get('egress',[]); ports=[p.get('port') for rule in egress for p in rule.get('ports',[])] ; exit(0 if 53 in ports else 1)" 2>/dev/null; then
    echo "✅ NetworkPolicy 'allow-internal' includes DNS egress rule on port 53"
    exit 0
  fi
  echo "❌ NetworkPolicy 'allow-internal' missing DNS egress rule on port 53"
  exit 1
fi

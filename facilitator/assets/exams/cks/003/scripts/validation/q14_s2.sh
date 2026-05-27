#!/bin/bash
# Q14 S2: Check NetworkPolicy blocks egress to 169.254.169.254/32
NP_JSON=$(kubectl -n cloud-workloads get networkpolicy block-metadata -o json 2>/dev/null)

if [ -z "$NP_JSON" ]; then
  echo "❌ NetworkPolicy block-metadata not found"
  exit 1
fi

HAS_METADATA_IP=$(echo "$NP_JSON" | grep -c "169.254.169.254" 2>/dev/null || true)
HAS_EGRESS_TYPE=$(echo "$NP_JSON" | grep -c '"Egress"' 2>/dev/null || true)

if [ "$HAS_METADATA_IP" -gt 0 ] && [ "$HAS_EGRESS_TYPE" -gt 0 ]; then
  echo "✅ NetworkPolicy block-metadata blocks egress to 169.254.169.254/32"
  exit 0
else
  echo "❌ NetworkPolicy block-metadata missing metadata IP block (ip:$HAS_METADATA_IP, Egress type:$HAS_EGRESS_TYPE)"
  exit 1
fi

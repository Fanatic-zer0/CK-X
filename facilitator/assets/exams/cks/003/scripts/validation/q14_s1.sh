#!/bin/bash
# Q14 S1: Check NetworkPolicy block-metadata exists in cloud-workloads
NP=$(kubectl -n cloud-workloads get networkpolicy block-metadata --no-headers 2>/dev/null)

if [ -n "$NP" ]; then
  echo "✅ NetworkPolicy block-metadata exists in namespace cloud-workloads"
  exit 0
else
  echo "❌ NetworkPolicy block-metadata not found in namespace cloud-workloads"
  exit 1
fi

#!/bin/bash
# Q3 S1: Check NetworkPolicy backend-isolation exists in three-tier
NP=$(kubectl -n three-tier get networkpolicy backend-isolation --no-headers 2>/dev/null)

if [ -n "$NP" ]; then
  echo "✅ NetworkPolicy backend-isolation exists in namespace three-tier"
  exit 0
else
  echo "❌ NetworkPolicy backend-isolation not found in namespace three-tier"
  exit 1
fi

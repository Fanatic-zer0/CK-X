#!/bin/bash
# Q15 S1: Check ServiceAccount minimal-sa exists with automountServiceAccountToken: false
SA_JSON=$(kubectl -n workload-ns get serviceaccount minimal-sa -o json 2>/dev/null)

if [ -z "$SA_JSON" ]; then
  echo "❌ ServiceAccount minimal-sa not found in namespace workload-ns"
  exit 1
fi

AUTOMOUNT=$(echo "$SA_JSON" | grep -o '"automountServiceAccountToken":false' 2>/dev/null || true)

if [ -n "$AUTOMOUNT" ]; then
  echo "✅ ServiceAccount minimal-sa exists with automountServiceAccountToken: false"
  exit 0
else
  echo "❌ ServiceAccount minimal-sa exists but automountServiceAccountToken is not false"
  exit 1
fi

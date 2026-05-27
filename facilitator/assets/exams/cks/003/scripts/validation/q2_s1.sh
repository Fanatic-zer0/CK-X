#!/bin/bash
# Q2 S1: Check falco-custom-rules ConfigMap has priority: WARNING for detect_shell_exec
CONTENT=$(kubectl -n monitoring get configmap falco-custom-rules \
  -o jsonpath='{.data.falco_rules\.yaml}' 2>/dev/null)

if echo "$CONTENT" | grep -q "priority: WARNING"; then
  echo "✅ Rule detect_shell_exec has priority: WARNING in falco-custom-rules"
  exit 0
else
  echo "❌ Rule priority is not WARNING in falco-custom-rules ConfigMap"
  exit 1
fi

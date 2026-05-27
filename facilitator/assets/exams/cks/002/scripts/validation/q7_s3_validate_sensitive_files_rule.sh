#!/bin/bash
# Q7: Validate ConfigMap contains read_sensitive_files rule

CM_DATA=$(kubectl get configmap falco-custom-rules -n falco-config \
  -o jsonpath='{.data.custom_rules\.yaml}' 2>/dev/null)

if [ -z "$CM_DATA" ]; then
  echo "❌ ConfigMap key 'custom_rules.yaml' is missing or empty"
  exit 1
fi

if ! echo "$CM_DATA" | grep -q "read_sensitive_files"; then
  echo "❌ Falco rule 'read_sensitive_files' not found in ConfigMap"
  exit 1
fi

# Check that sensitive file paths are referenced
if echo "$CM_DATA" | grep -qE "/etc/shadow|/etc/passwd"; then
  echo "✅ ConfigMap contains 'read_sensitive_files' rule referencing sensitive file paths"
  exit 0
else
  echo "❌ 'read_sensitive_files' rule does not reference /etc/shadow or /etc/passwd"
  exit 1
fi

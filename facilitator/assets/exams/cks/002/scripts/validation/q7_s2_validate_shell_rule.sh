#!/bin/bash
# Q7: Validate ConfigMap contains shell_in_container rule with required fields

CM_DATA=$(kubectl get configmap falco-custom-rules -n falco-config \
  -o jsonpath='{.data.custom_rules\.yaml}' 2>/dev/null)

if [ -z "$CM_DATA" ]; then
  echo "❌ ConfigMap key 'custom_rules.yaml' is missing or empty"
  exit 1
fi

# Check for rule name
if ! echo "$CM_DATA" | grep -q "shell_in_container"; then
  echo "❌ Falco rule 'shell_in_container' not found in ConfigMap"
  exit 1
fi

# Check for required fields in the rule context
if echo "$CM_DATA" | grep -q "condition" && echo "$CM_DATA" | grep -q "output" && echo "$CM_DATA" | grep -q "priority"; then
  echo "✅ ConfigMap contains 'shell_in_container' rule with required fields"
  exit 0
else
  echo "❌ 'shell_in_container' rule is missing required fields (condition, output, priority)"
  exit 1
fi

#!/bin/bash
# Q2 S3: Check monitored_shells list exists with at least 5 entries
CONTENT=$(kubectl -n monitoring get configmap falco-custom-rules \
  -o jsonpath='{.data.falco_rules\.yaml}' 2>/dev/null)

if ! echo "$CONTENT" | grep -q "monitored_shells"; then
  echo "❌ List 'monitored_shells' not found in falco-custom-rules ConfigMap"
  exit 1
fi

# Count shell entries (bash, sh, ash, zsh, fish)
COUNT=0
for shell in bash sh ash zsh fish; do
  echo "$CONTENT" | grep -q "$shell" && COUNT=$((COUNT+1))
done

if [ "$COUNT" -ge 4 ]; then
  echo "✅ monitored_shells list exists with $COUNT shell entries (need at least 4)"
  exit 0
else
  echo "❌ monitored_shells list found but only has $COUNT entries, need at least 4 of: bash, sh, ash, zsh, fish"
  exit 1
fi

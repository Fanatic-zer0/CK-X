#!/bin/bash
# Q2 S2: Check output includes container.id and user.name
CONTENT=$(kubectl -n monitoring get configmap falco-custom-rules \
  -o jsonpath='{.data.falco_rules\.yaml}' 2>/dev/null)

HAS_CONTAINER=false
HAS_USER=false

echo "$CONTENT" | grep -q "container.id" && HAS_CONTAINER=true
echo "$CONTENT" | grep -q "user.name" && HAS_USER=true

if $HAS_CONTAINER && $HAS_USER; then
  echo "✅ Rule output includes container.id and user.name fields"
  exit 0
else
  MISSING=""
  $HAS_CONTAINER || MISSING="$MISSING container.id"
  $HAS_USER || MISSING="$MISSING user.name"
  echo "❌ Rule output missing fields:$MISSING"
  exit 1
fi

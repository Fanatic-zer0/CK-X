#!/bin/bash
# Q1 S2: Check pod template of legacy-web has label scanned=true
SCANNED=$(kubectl -n image-audit get deployment legacy-web \
  -o jsonpath='{.spec.template.metadata.labels.scanned}' 2>/dev/null)

if [ "$SCANNED" = "true" ]; then
  echo "✅ Pod template of legacy-web has label scanned=true"
  exit 0
else
  echo "❌ Pod template of legacy-web missing label scanned=true (got: '$SCANNED')"
  exit 1
fi

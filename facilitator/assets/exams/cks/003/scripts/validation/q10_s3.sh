#!/bin/bash
# Q10 S3: Check Pod baseline-compliant exists and is Running
PHASE=$(kubectl -n legacy-workloads get pod baseline-compliant \
  -o jsonpath='{.status.phase}' 2>/dev/null)

if [ "$PHASE" = "Running" ]; then
  echo "✅ Pod baseline-compliant exists and is Running"
  exit 0
elif [ -n "$PHASE" ]; then
  echo "❌ Pod baseline-compliant exists but is not Running (status: $PHASE)"
  exit 1
else
  echo "❌ Pod baseline-compliant not found in namespace legacy-workloads"
  exit 1
fi

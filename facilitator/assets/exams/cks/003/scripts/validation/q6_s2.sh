#!/bin/bash
# Q6 S2: Check pod nginx-apparmor is Running
PHASE=$(kubectl -n apparmor-workloads get pod nginx-apparmor \
  -o jsonpath='{.status.phase}' 2>/dev/null)

if [ "$PHASE" = "Running" ]; then
  echo "✅ Pod nginx-apparmor is Running"
  exit 0
else
  echo "❌ Pod nginx-apparmor is not Running (status: $PHASE)"
  exit 1
fi

#!/bin/bash
# Q14 S3: Check Pod cloud-app exists in cloud-workloads
POD=$(kubectl -n cloud-workloads get pod cloud-app --no-headers 2>/dev/null)

if [ -n "$POD" ]; then
  echo "✅ Pod cloud-app exists in namespace cloud-workloads"
  exit 0
else
  echo "❌ Pod cloud-app not found in namespace cloud-workloads"
  exit 1
fi

#!/bin/bash
# Q6 S3: Check Service nginx-svc exists exposing port 80
SVC_JSON=$(kubectl -n apparmor-workloads get service nginx-svc -o json 2>/dev/null)

if [ -z "$SVC_JSON" ]; then
  echo "❌ Service nginx-svc not found in namespace apparmor-workloads"
  exit 1
fi

PORT=$(echo "$SVC_JSON" | grep -o '"port":80' 2>/dev/null || true)

if [ -n "$PORT" ]; then
  echo "✅ Service nginx-svc exists and exposes port 80"
  exit 0
else
  echo "❌ Service nginx-svc exists but does not expose port 80"
  exit 1
fi

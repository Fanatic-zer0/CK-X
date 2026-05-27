#!/bin/bash
# Q1 S3: Check ConfigMap scan-data exists in image-audit namespace
CM=$(kubectl -n image-audit get configmap scan-data --no-headers 2>/dev/null)

if [ -n "$CM" ]; then
  echo "✅ ConfigMap scan-data exists in namespace image-audit"
  exit 0
else
  echo "❌ ConfigMap scan-data not found in namespace image-audit"
  exit 1
fi

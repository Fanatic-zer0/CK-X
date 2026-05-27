#!/bin/bash
# Q11 S1: Check ConfigMap image-webhook-config exists in kube-system
CM=$(kubectl -n kube-system get configmap image-webhook-config --no-headers 2>/dev/null)

if [ -n "$CM" ]; then
  echo "✅ ConfigMap image-webhook-config exists in kube-system"
  exit 0
else
  echo "❌ ConfigMap image-webhook-config not found in kube-system"
  exit 1
fi

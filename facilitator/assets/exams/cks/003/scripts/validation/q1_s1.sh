#!/bin/bash
# Q1 S1: Check deployment legacy-web uses nginx:1.25-alpine
IMAGE=$(kubectl -n image-audit get deployment legacy-web \
  -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)

if echo "$IMAGE" | grep -q "nginx:1.25-alpine"; then
  echo "✅ Deployment legacy-web uses image nginx:1.25-alpine"
  exit 0
else
  echo "❌ Expected deployment legacy-web to use nginx:1.25-alpine, got: $IMAGE"
  exit 1
fi

#!/bin/bash
# Q5 S1: Check deployment api-backend has a seccompProfile defined at pod level
SC=$(kubectl -n prod-apps get deployment api-backend \
  -o jsonpath='{.spec.template.spec.securityContext.seccompProfile}' 2>/dev/null)

if [ -n "$SC" ] && [ "$SC" != "null" ] && [ "$SC" != "{}" ]; then
  echo "✅ Deployment api-backend has a seccompProfile defined at pod level"
  exit 0
else
  echo "❌ Deployment api-backend missing seccompProfile in pod-level securityContext"
  exit 1
fi

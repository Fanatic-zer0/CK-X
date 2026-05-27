#!/bin/bash
# Q15 S2: Check Role minimal-role exists with only get/list on pods
ROLE_JSON=$(kubectl -n workload-ns get role minimal-role -o json 2>/dev/null)

if [ -z "$ROLE_JSON" ]; then
  echo "❌ Role minimal-role not found in namespace workload-ns"
  exit 1
fi

HAS_GET=$(echo "$ROLE_JSON" | grep -c '"get"' 2>/dev/null || true)
HAS_LIST=$(echo "$ROLE_JSON" | grep -c '"list"' 2>/dev/null || true)
HAS_PODS=$(echo "$ROLE_JSON" | grep -c '"pods"' 2>/dev/null || true)

if [ "$HAS_GET" -gt 0 ] && [ "$HAS_LIST" -gt 0 ] && [ "$HAS_PODS" -gt 0 ]; then
  echo "✅ Role minimal-role exists with get/list permissions on pods"
  exit 0
else
  echo "❌ Role minimal-role misconfigured (get:$HAS_GET, list:$HAS_LIST, pods:$HAS_PODS)"
  exit 1
fi

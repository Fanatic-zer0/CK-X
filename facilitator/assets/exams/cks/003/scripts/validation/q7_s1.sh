#!/bin/bash
# Q7 S1: Check pod hash-checker exists with hostPath volume mounting /usr/local/bin at /host-bin
POD_JSON=$(kubectl -n binary-verification get pod hash-checker -o json 2>/dev/null)

if [ -z "$POD_JSON" ]; then
  echo "❌ Pod hash-checker not found in namespace binary-verification"
  exit 1
fi

HAS_HOSTPATH=$(echo "$POD_JSON" | grep -c '"hostPath"' 2>/dev/null || true)
HAS_USR_LOCAL_BIN=$(echo "$POD_JSON" | grep -c 'usr/local/bin' 2>/dev/null || true)
HAS_HOST_BIN_MOUNT=$(echo "$POD_JSON" | grep -c '"host-bin"' 2>/dev/null || true)

if [ "$HAS_HOSTPATH" -gt 0 ] && [ "$HAS_USR_LOCAL_BIN" -gt 0 ] && [ "$HAS_HOST_BIN_MOUNT" -gt 0 ]; then
  echo "✅ Pod hash-checker has hostPath volume mounting /usr/local/bin at /host-bin"
  exit 0
else
  echo "❌ Pod hash-checker missing correct hostPath volume (hostPath:$HAS_HOSTPATH, path:$HAS_USR_LOCAL_BIN, mount:$HAS_HOST_BIN_MOUNT)"
  exit 1
fi

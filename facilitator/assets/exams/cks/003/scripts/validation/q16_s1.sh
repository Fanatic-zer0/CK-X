#!/bin/bash
# Q16 S1: Check pod cert-validator exists and mounts monitor-cert at /etc/tls
POD_JSON=$(kubectl -n cert-monitoring get pod cert-validator -o json 2>/dev/null)

if [ -z "$POD_JSON" ]; then
  echo "❌ Pod cert-validator not found in namespace cert-monitoring"
  exit 1
fi

HAS_SECRET=$(echo "$POD_JSON" | grep -c '"monitor-cert"' 2>/dev/null || true)
HAS_MOUNT=$(echo "$POD_JSON" | grep -c '"/etc/tls"' 2>/dev/null || true)

if [ "$HAS_SECRET" -gt 0 ] && [ "$HAS_MOUNT" -gt 0 ]; then
  echo "✅ Pod cert-validator exists and mounts monitor-cert at /etc/tls"
  exit 0
else
  echo "❌ Pod cert-validator missing correct volume mount (monitor-cert:$HAS_SECRET, /etc/tls:$HAS_MOUNT)"
  exit 1
fi

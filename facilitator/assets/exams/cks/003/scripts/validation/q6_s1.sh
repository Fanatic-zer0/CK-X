#!/bin/bash
# Q6 S1: Check pod nginx-apparmor has AppArmor annotation
POD_JSON=$(kubectl -n apparmor-workloads get pod nginx-apparmor -o json 2>/dev/null)

if [ -z "$POD_JSON" ]; then
  echo "❌ Pod nginx-apparmor not found in namespace apparmor-workloads"
  exit 1
fi

ANNOTATION=$(echo "$POD_JSON" | grep -o 'container.apparmor.security.beta.kubernetes.io.*runtime/default' 2>/dev/null || true)

if [ -n "$ANNOTATION" ]; then
  echo "✅ Pod nginx-apparmor has AppArmor annotation (runtime/default)"
  exit 0
else
  echo "❌ Pod nginx-apparmor missing AppArmor annotation 'container.apparmor.security.beta.kubernetes.io/<container>: runtime/default'"
  exit 1
fi

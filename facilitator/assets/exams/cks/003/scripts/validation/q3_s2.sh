#!/bin/bash
# Q3 S2: Check backend-isolation targets app=backend, allows ingress from app=frontend on port 8080
NP_JSON=$(kubectl -n three-tier get networkpolicy backend-isolation -o json 2>/dev/null)

if [ -z "$NP_JSON" ]; then
  echo "❌ NetworkPolicy backend-isolation not found"
  exit 1
fi

TARGETS_BACKEND=$(echo "$NP_JSON" | grep -c '"app":"backend"' 2>/dev/null || true)
HAS_INGRESS=$(echo "$NP_JSON" | grep -c '"Ingress"' 2>/dev/null || true)
HAS_8080=$(echo "$NP_JSON" | grep -c '"port":8080' 2>/dev/null || true)
HAS_FRONTEND=$(echo "$NP_JSON" | grep -c '"app":"frontend"' 2>/dev/null || true)

PASS=true
MSG=""

[ "$TARGETS_BACKEND" -gt 0 ] || { PASS=false; MSG="$MSG targets app=backend;"; }
[ "$HAS_INGRESS" -gt 0 ] || { PASS=false; MSG="$MSG has Ingress policy type;"; }
[ "$HAS_8080" -gt 0 ] || { PASS=false; MSG="$MSG port 8080;"; }
[ "$HAS_FRONTEND" -gt 0 ] || { PASS=false; MSG="$MSG from=app:frontend;"; }

if $PASS; then
  echo "✅ backend-isolation correctly restricts ingress from app=frontend on port 8080"
  exit 0
else
  echo "❌ backend-isolation is missing: $MSG"
  exit 1
fi

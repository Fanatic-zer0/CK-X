#!/bin/bash
# Q3 S3: Check db-isolation targets app=db, restricts ingress from backend on 5432, no egress
NP_JSON=$(kubectl -n three-tier get networkpolicy db-isolation -o json 2>/dev/null)

if [ -z "$NP_JSON" ]; then
  echo "❌ NetworkPolicy db-isolation not found in three-tier namespace"
  exit 1
fi

TARGETS_DB=$(echo "$NP_JSON" | grep -c '"app":"db"' 2>/dev/null || true)
HAS_5432=$(echo "$NP_JSON" | grep -c '"port":5432' 2>/dev/null || true)
HAS_BACKEND=$(echo "$NP_JSON" | grep -c '"app":"backend"' 2>/dev/null || true)
HAS_EGRESS_TYPE=$(echo "$NP_JSON" | grep -c '"Egress"' 2>/dev/null || true)

PASS=true
MSG=""

[ "$TARGETS_DB" -gt 0 ] || { PASS=false; MSG="$MSG targets app=db;"; }
[ "$HAS_5432" -gt 0 ] || { PASS=false; MSG="$MSG port 5432;"; }
[ "$HAS_BACKEND" -gt 0 ] || { PASS=false; MSG="$MSG from=app:backend;"; }
[ "$HAS_EGRESS_TYPE" -gt 0 ] || { PASS=false; MSG="$MSG Egress policy type (to restrict egress);"; }

if $PASS; then
  echo "✅ NetworkPolicy db-isolation exists with ingress from backend:5432 and restricted egress"
  exit 0
else
  echo "❌ db-isolation is missing: $MSG"
  exit 1
fi

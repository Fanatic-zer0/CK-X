#!/bin/bash
# Q15 S3: Check deployment legacy-app uses minimal-sa with automountServiceAccountToken: false in pod spec
SA=$(kubectl -n workload-ns get deployment legacy-app \
  -o jsonpath='{.spec.template.spec.serviceAccountName}' 2>/dev/null)
AUTOMOUNT=$(kubectl -n workload-ns get deployment legacy-app \
  -o jsonpath='{.spec.template.spec.automountServiceAccountToken}' 2>/dev/null)

PASS=true
MSG=""

[ "$SA" = "minimal-sa" ] || { PASS=false; MSG="$MSG serviceAccountName=$SA (expected minimal-sa);"; }
[ "$AUTOMOUNT" = "false" ] || { PASS=false; MSG="$MSG automountServiceAccountToken=$AUTOMOUNT (expected false);"; }

if $PASS; then
  echo "✅ Deployment legacy-app uses minimal-sa with automountServiceAccountToken: false in pod spec"
  exit 0
else
  echo "❌ Deployment legacy-app misconfigured: $MSG"
  exit 1
fi

#!/bin/bash
# Q8 S4: Check Secret encryption-test exists in kube-system
SECRET=$(kubectl -n kube-system get secret encryption-test --no-headers 2>/dev/null)

if [ -n "$SECRET" ]; then
  echo "✅ Secret encryption-test exists in kube-system"
  exit 0
else
  echo "❌ Secret encryption-test not found in kube-system"
  exit 1
fi

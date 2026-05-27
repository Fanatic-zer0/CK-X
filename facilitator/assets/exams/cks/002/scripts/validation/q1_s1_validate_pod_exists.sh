#!/bin/bash
# Q1: Validate pod apparmor-nginx exists

kubectl get pod apparmor-nginx -n apparmor-ns &> /dev/null
if [ $? -eq 0 ]; then
  echo "✅ Pod 'apparmor-nginx' exists in namespace 'apparmor-ns'"
  exit 0
else
  echo "❌ Pod 'apparmor-nginx' not found in namespace 'apparmor-ns'"
  exit 1
fi

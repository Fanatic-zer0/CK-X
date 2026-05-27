#!/bin/bash
# Q14: Validate Deployment insecure-app runs as non-root (not user 0)

RUN_AS_USER=$(kubectl get deployment insecure-app -n vuln-fix \
  -o jsonpath='{.spec.template.spec.containers[0].securityContext.runAsUser}' 2>/dev/null)
RUN_AS_NON_ROOT=$(kubectl get deployment insecure-app -n vuln-fix \
  -o jsonpath='{.spec.template.spec.containers[0].securityContext.runAsNonRoot}' 2>/dev/null)

# User 0 is root - must not be 0
if [ "$RUN_AS_USER" = "0" ]; then
  echo "❌ Deployment still runs as root user (runAsUser: 0)"
  exit 1
fi

if [ "$RUN_AS_NON_ROOT" = "true" ] || ([ -n "$RUN_AS_USER" ] && [ "$RUN_AS_USER" != "0" ]); then
  echo "✅ Deployment runs as non-root user (runAsUser: ${RUN_AS_USER}, runAsNonRoot: ${RUN_AS_NON_ROOT})"
  exit 0
else
  echo "❌ Deployment does not have non-root user settings. runAsUser: '${RUN_AS_USER}', runAsNonRoot: '${RUN_AS_NON_ROOT}'"
  exit 1
fi

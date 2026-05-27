#!/bin/bash
# Q11: Validate TLS volume mounts are read-only in both pods

for POD in server-pod client-pod; do
  READONLY=$(kubectl get pod $POD -n mtls-app \
    -o jsonpath='{.spec.containers[0].volumeMounts}' 2>/dev/null | \
    python3 -c "
import sys, json
mounts = json.load(sys.stdin)
tls_mounts = [m for m in mounts if 'tls' in m.get('name','').lower() or m.get('mountPath','') == '/etc/tls']
if tls_mounts and all(m.get('readOnly', False) for m in tls_mounts):
    print('true')
else:
    print('false')
" 2>/dev/null)

  if [ "$READONLY" != "true" ]; then
    echo "❌ TLS volume mount in pod '${POD}' is not read-only"
    exit 1
  fi
done

echo "✅ TLS volume mounts are read-only in both pods"
exit 0

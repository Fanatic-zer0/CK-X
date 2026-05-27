#!/bin/bash
# Q2 Setup: Create monitoring namespace with Falco rule ConfigMap
set -e

kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# Create Falco custom rules ConfigMap with a rule needing modification
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: falco-custom-rules
  namespace: monitoring
data:
  falco_rules.yaml: |
    - rule: detect_shell_exec
      desc: Detect execution of shell in a container
      condition: spawned_process and container and proc.name in (bash, sh)
      output: "Shell executed (proc=%proc.name)"
      priority: NOTICE
      tags: [container, shell]
EOF

echo "Q2 setup complete: monitoring namespace with falco-custom-rules ConfigMap"

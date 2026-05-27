#!/bin/bash
set -e

echo "Setting up CKS 003 exam environment..."

# Run all question-specific setup scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for i in $(seq 1 16); do
  script="$SCRIPT_DIR/q${i}_setup.sh"
  if [ -f "$script" ]; then
    echo "Running setup for question $i..."
    bash "$script" || echo "Warning: q${i}_setup.sh had errors (may be acceptable)"
  fi
done

echo "CKS 003 environment setup complete."

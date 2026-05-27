#!/bin/bash
# Master setup script for CKS 002 lab

echo "Starting CKS 002 lab setup..."

# Make all scripts executable
chmod +x scripts/setup/q*.sh

# Run all setup scripts
for script in scripts/setup/q*.sh; do
  echo "Running $script..."
  $script
  if [ $? -ne 0 ]; then
    echo "Error running $script"
    exit 1
  fi
done

echo "CKS 002 lab setup completed successfully"
exit 0

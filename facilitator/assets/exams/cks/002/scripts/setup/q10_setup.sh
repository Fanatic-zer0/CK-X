#!/bin/bash
# Setup for Question 10: Immutable ConfigMap and Secret

# Create namespace
kubectl create namespace immutable-ns 2>/dev/null || true

echo "Setup completed for Question 10"
exit 0

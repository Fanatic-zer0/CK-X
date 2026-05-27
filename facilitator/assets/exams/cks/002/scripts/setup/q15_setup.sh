#!/bin/bash
# Setup for Question 15: Trivy Image Scanning

# Create namespace
kubectl create namespace image-security 2>/dev/null || true

echo "Setup completed for Question 15"
exit 0

#!/bin/bash
# Setup for Question 6: Pod Security Standards - Restricted

# The candidate creates the namespace and applies labels
# No pre-setup needed beyond ensuring no conflicting namespace exists
kubectl delete namespace restricted-ns 2>/dev/null || true

echo "Setup completed for Question 6"
exit 0

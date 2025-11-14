#!/bin/bash

# Setup Script - Question 003
# Prepares the environment for Secret and Pod creation

set -e

echo "🚀 Preparing environment for Question 003..."

# Ensure we're working with default namespace (no need to create it)
echo "📦 Using default namespace..."

# Clean up any existing resources (optional - comment out if you want to preserve)
# kubectl delete secret db-credentials --ignore-not-found=true
# kubectl delete pod env-secret-pod --ignore-not-found=true

echo ""
echo "✅ Environment prepared successfully!"
echo ""
echo "📋 Next steps:"
echo "   1. Read the question in question.md"
echo "   2. Create Secret 'db-credentials' with username=admin and password=P@ssw0rd123"
echo "   3. Create Pod 'env-secret-pod' using busybox image with sleep 3600"
echo "   4. Map Secret values to environment variables DB_USER and DB_PASS"
echo "   5. Run ./validate.sh to validate your solution"



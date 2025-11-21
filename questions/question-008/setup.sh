#!/bin/bash

# Setup Script - Question 008
# Prepares the environment for Redis pod creation

set -e

echo "🚀 Preparing environment for Question 008..."

# Create namespace if it doesn't exist
echo "📦 Creating namespace web..."
kubectl create namespace web --dry-run=client -o yaml | kubectl apply -f - 2>/dev/null || true

# Clean up any existing cache pod (optional - comment out if you want to preserve)
# kubectl delete pod cache -n web --ignore-not-found=true

echo ""
echo "✅ Environment prepared successfully!"
echo ""
echo "📋 Next steps:"
echo "   1. Read the question in question.md"
echo "   2. Create a pod named 'cache' in namespace 'web'"
echo "   3. Use image redis:3.2"
echo "   4. Expose port 6379"
echo "   5. Make sure the pod is running"
echo "   6. Run ./validate.sh to validate your solution"


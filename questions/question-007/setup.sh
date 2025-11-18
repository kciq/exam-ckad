#!/bin/bash

# Setup Script - Question 007
# Prepares the environment for CronJob creation

set -e

echo "🚀 Preparing environment for Question 007..."

# Create namespace if it doesn't exist
echo "📦 Creating namespace production..."
kubectl create namespace production --dry-run=client -o yaml | kubectl apply -f - 2>/dev/null || true

# Clean up any existing CronJob (optional - comment out if you want to preserve)
# kubectl delete cronjob log-cleaner -n production --ignore-not-found=true

echo ""
echo "✅ Environment prepared successfully!"
echo ""
echo "📋 Next steps:"
echo "   1. Read the question in question.md"
echo "   2. Create CronJob 'log-cleaner' in namespace 'production'"
echo "   3. Configure schedule: every 30 minutes"
echo "   4. Set completions: 2, backoffLimit: 3, activeDeadlineSeconds: 30"
echo "   5. Use busybox image with 'date' command"
echo "   6. Name the container 'log'"
echo "   7. Run ./validate.sh to validate your solution"


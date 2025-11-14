#!/bin/bash

# Setup Script - Question 002
# Prepares the environment for deployment security context modification

set -e

echo "🚀 Preparing environment for Question 002..."

# Create namespace if it doesn't exist
echo "📦 Creating namespace quetzal..."
kubectl create namespace quetzal --dry-run=client -o yaml | kubectl apply -f - 2>/dev/null || true

# Create directory for deployment manifest
mkdir -p ~/broker-deployment

# Create the hotfix-deployment manifest if it doesn't exist
if [ ! -f ~/broker-deployment/hotfix-deployment.yaml ]; then
    echo "📝 Creating hotfix-deployment manifest..."
    cat > ~/broker-deployment/hotfix-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hotfix-deployment
  namespace: quetzal
spec:
  replicas: 1
  selector:
    matchLabels:
      app: hotfix
  template:
    metadata:
      labels:
        app: hotfix
    spec:
      containers:
      - name: hotfix-container
        image: nginx:latest
        ports:
        - containerPort: 80
EOF
    echo "✅ Manifest created successfully!"
else
    echo "ℹ️  Manifest already exists at ~/broker-deployment/hotfix-deployment.yaml"
fi

# Apply the deployment
echo "🚀 Applying deployment..."
kubectl apply -f ~/broker-deployment/hotfix-deployment.yaml 2>/dev/null || echo "ℹ️  Deployment may already exist"

# Wait a moment for resources to be created
sleep 2

echo ""
echo "✅ Environment prepared successfully!"
echo ""
echo "📋 Next steps:"
echo "   1. Read the question in question.md"
echo "   2. Modify the deployment to set user ID 30.000 and forbid privilege escalation"
echo "   3. Run ./validate.sh to validate your solution"



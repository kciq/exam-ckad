#!/bin/bash

# Setup Script - Question 005
# Prepares the environment for deployment scaling and service creation

set -e

echo "🚀 Preparing environment for Question 005..."

# Create namespace if it doesn't exist
echo "📦 Creating namespace nov2025..."
kubectl create namespace nov2025 --dry-run=client -o yaml | kubectl apply -f - 2>/dev/null || true

# Create the nov2025-deployment if it doesn't exist
echo "📝 Checking for nov2025-deployment..."
if ! kubectl get deployment nov2025-deployment -n nov2025 &> /dev/null; then
    echo "📝 Creating nov2025-deployment..."
    cat > /tmp/nov2025-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nov2025-deployment
  namespace: nov2025
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nov2025
  template:
    metadata:
      labels:
        app: nov2025
    spec:
      containers:
      - name: web
        image: nginx:latest
        ports:
        - containerPort: 8080
          name: http
EOF
    kubectl apply -f /tmp/nov2025-deployment.yaml
    echo "✅ Deployment created successfully!"
    rm /tmp/nov2025-deployment.yaml
else
    echo "ℹ️  Deployment nov2025-deployment already exists in namespace nov2025"
fi

# Wait a moment for resources
sleep 2

echo ""
echo "✅ Environment prepared successfully!"
echo ""
echo "📋 Next steps:"
echo "   1. Read the question in question.md"
echo "   2. Scale the deployment to 4 replicas"
echo "   3. Add label func=webFrontend to pod template metadata"
echo "   4. Create a NodePort service named Berry exposing port 8080"
echo "   5. Run ./validate.sh to validate your solution"



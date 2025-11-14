#!/bin/bash

# Setup Script - Question 006
# Prepares the environment for rolling update and rollback

set -e

echo "🚀 Preparing environment for Question 006..."

# Create namespace if it doesn't exist
echo "📦 Creating namespace nov2025..."
kubectl create namespace nov2025 --dry-run=client -o yaml | kubectl apply -f - 2>/dev/null || true

# Create the app deployment if it doesn't exist
echo "📝 Checking for app deployment..."
if ! kubectl get deployment app -n nov2025 &> /dev/null; then
    echo "📝 Creating app deployment..."
    cat > /tmp/app-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app
  namespace: nov2025
spec:
  replicas: 3
  selector:
    matchLabels:
      app: app
  template:
    metadata:
      labels:
        app: app
    spec:
      containers:
      - name: app
        image: nginx:1.21
        ports:
        - containerPort: 80
EOF
    kubectl apply -f /tmp/app-deployment.yaml
    echo "✅ app deployment created successfully!"
    rm /tmp/app-deployment.yaml
else
    echo "ℹ️  Deployment app already exists in namespace nov2025"
fi

# Create the web1 deployment if it doesn't exist
echo "📝 Checking for web1 deployment..."
if ! kubectl get deployment web1 -n nov2025 &> /dev/null; then
    echo "📝 Creating web1 deployment..."
    cat > /tmp/web1-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web1
  namespace: nov2025
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web1
  template:
    metadata:
      labels:
        app: web1
    spec:
      containers:
      - name: web
        image: nginx:1.20
        ports:
        - containerPort: 80
EOF
    kubectl apply -f /tmp/web1-deployment.yaml
    echo "✅ web1 deployment created successfully!"
    rm /tmp/web1-deployment.yaml
else
    echo "ℹ️  Deployment web1 already exists in namespace nov2025"
fi

# Wait for deployments to be ready
echo "⏳ Waiting for deployments to be ready..."
sleep 3

echo ""
echo "✅ Environment prepared successfully!"
echo ""
echo "📋 Next steps:"
echo "   1. Read the question in question.md"
echo "   2. Update app deployment with maxSurge: 5% and maxUnavailable: 2%"
echo "   3. Update web1 deployment image to nginx:1.13"
echo "   4. Rollback app deployment to previous version"
echo "   5. Run ./validate.sh to validate your solution"



#!/bin/bash

# Setup Script - Question 004
# Prepares the environment for RBAC troubleshooting

set -e

echo "🚀 Preparing environment for Question 004..."

# Create namespace if it doesn't exist
echo "📦 Creating namespace meta..."
kubectl create namespace meta --dry-run=client -o yaml | kubectl apply -f - 2>/dev/null || true

# Create the dev-deployment manifest
if [ ! -f ~/dev-deployment.yaml ]; then
    echo "📝 Creating dev-deployment manifest..."
    cat > ~/dev-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dev-deployment
  namespace: meta
spec:
  replicas: 1
  selector:
    matchLabels:
      app: dev
  template:
    metadata:
      labels:
        app: dev
    spec:
      serviceAccountName: default
      containers:
      - name: dev-container
        image: bitnami/kubectl:latest
        command: ['sh', '-c']
        args:
        - |
          while true; do
            kubectl get deployments -n meta
            sleep 10
          done
EOF
    echo "✅ Manifest created successfully!"
else
    echo "ℹ️  Manifest already exists at ~/dev-deployment.yaml"
fi

# Apply the deployment
echo "🚀 Applying deployment..."
kubectl apply -f ~/dev-deployment.yaml 2>/dev/null || echo "ℹ️  Deployment may already exist"

# Wait for pod to be created
echo "⏳ Waiting for pod to be ready..."
sleep 3

echo ""
echo "✅ Environment prepared successfully!"
echo ""
echo "📋 Next steps:"
echo "   1. Read the question in question.md"
echo "   2. Check the pod logs: kubectl logs -n meta -l app=dev"
echo "   3. Identify the RBAC issue"
echo "   4. Create Role and RoleBinding to fix the permissions"
echo "   5. Optionally update the deployment if needed"
echo "   6. Run ./validate.sh to validate your solution"



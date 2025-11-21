#!/bin/bash

# Setup Script - Question 009
# Prepares the environment for pod deployment and log/metrics retrieval

set -e

echo "🚀 Preparing environment for Question 009..."

# Create directory if it doesn't exist
mkdir -p /opt/ckadnov2025

# Create the winter.yaml file if it doesn't exist
if [ ! -f /opt/ckadnov2025/winter.yaml ]; then
    echo "📝 Creating winter.yaml..."
    cat > /opt/ckadnov2025/winter.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: winter
spec:
  containers:
  - name: winter-container
    image: busybox
    command: ['sh', '-c']
    args:
    - |
      while true; do
        echo "$(date): Winter pod is running"
        sleep 5
      done
EOF
    echo "✅ winter.yaml created successfully!"
else
    echo "ℹ️  winter.yaml already exists at /opt/ckadnov2025/winter.yaml"
fi

# Create output files if they don't exist
if [ ! -f /opt/ckadnov2025/log_output.txt ]; then
    touch /opt/ckadnov2025/log_output.txt
    echo "✅ Created log_output.txt"
fi

if [ ! -f /opt/ckadnov2025/pod.txt ]; then
    touch /opt/ckadnov2025/pod.txt
    echo "✅ Created pod.txt"
fi

# Create namespace cpu-stress if it doesn't exist
echo "📦 Creating namespace cpu-stress..."
kubectl create namespace cpu-stress --dry-run=client -o yaml | kubectl apply -f - 2>/dev/null || true

# Create some pods in cpu-stress namespace for testing (if they don't exist)
if ! kubectl get pod -n cpu-stress 2>/dev/null | grep -q "cpu-pod"; then
    echo "📝 Creating sample pods in cpu-stress namespace..."
    cat > /tmp/cpu-pod1.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: cpu-pod1
  namespace: cpu-stress
spec:
  containers:
  - name: cpu-container
    image: busybox
    command: ['sh', '-c']
    args: ['while true; do echo "CPU stress"; done']
    resources:
      requests:
        cpu: "100m"
      limits:
        cpu: "200m"
EOF
    cat > /tmp/cpu-pod2.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: cpu-pod2
  namespace: cpu-stress
spec:
  containers:
  - name: cpu-container
    image: busybox
    command: ['sh', '-c']
    args: ['while true; do echo "More CPU stress"; done']
    resources:
      requests:
        cpu: "200m"
      limits:
        cpu: "500m"
EOF
    kubectl apply -f /tmp/cpu-pod1.yaml 2>/dev/null || true
    kubectl apply -f /tmp/cpu-pod2.yaml 2>/dev/null || true
    rm -f /tmp/cpu-pod1.yaml /tmp/cpu-pod2.yaml
    echo "✅ Sample pods created in cpu-stress namespace"
fi

echo ""
echo "✅ Environment prepared successfully!"
echo ""
echo "📋 Next steps:"
echo "   1. Read the question in question.md"
echo "   2. Deploy the winter pod using: kubectl apply -f /opt/ckadnov2025/winter.yaml"
echo "   3. Retrieve logs and save to /opt/ckadnov2025/log_output.txt"
echo "   4. Find pod with highest CPU in cpu-stress namespace and save name to /opt/ckadnov2025/pod.txt"
echo "   5. Run ./validate.sh to validate your solution"


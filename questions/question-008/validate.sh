#!/bin/bash

# Validation Script - Question 008
# Validates if the question was solved correctly

set +e  # Don't exit on error - we want to check all validations

echo "🔍 Validating solution for Question 008..."
echo ""

PASSED=0
FAILED=0

check() {
    local description="$1"
    local command="$2"
    
    echo -n "Checking: $description... "
    
    if eval "$command" &> /dev/null; then
        echo "✅ PASSED"
        ((PASSED++))
        return 0
    else
        echo "❌ FAILED"
        ((FAILED++))
        return 1
    fi
}

check_with_error() {
    local description="$1"
    local command="$2"
    local error_msg="$3"
    
    echo -n "Checking: $description... "
    
    if eval "$command" &> /dev/null; then
        echo "✅ PASSED"
        ((PASSED++))
        return 0
    else
        echo "❌ FAILED"
        echo "   💡 $error_msg"
        ((FAILED++))
        return 1
    fi
}

echo "═══════════════════════════════════════════════════════════"
echo "Validation 1: Namespace exists"
echo "═══════════════════════════════════════════════════════════"
check "Namespace web exists" "kubectl get namespace web"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Validation 2: Pod exists"
echo "═══════════════════════════════════════════════════════════"
check "Pod cache exists in namespace web" "kubectl get pod cache -n web"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Validation 3: Pod is running"
echo "═══════════════════════════════════════════════════════════"

POD_STATUS=$(kubectl get pod cache -n web -o jsonpath='{.status.phase}' 2>/dev/null || echo "")

if [ "$POD_STATUS" = "Running" ]; then
    echo "✅ PASSED: Pod cache is in Running state"
    ((PASSED++))
else
    echo "❌ FAILED: Pod cache is not in Running state (current: $POD_STATUS)"
    echo "   💡 Make sure the pod is deployed and running"
    ((FAILED++))
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Validation 4: Image version"
echo "═══════════════════════════════════════════════════════════"

IMAGE=$(kubectl get pod cache -n web -o jsonpath='{.spec.containers[0].image}' 2>/dev/null || echo "")

if [ "$IMAGE" = "redis:3.2" ]; then
    echo "✅ PASSED: Pod is using redis:3.2 image"
    ((PASSED++))
else
    echo "❌ FAILED: Pod is not using redis:3.2 image (current: $IMAGE)"
    echo "   💡 Set image to redis:3.2"
    ((FAILED++))
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Validation 5: Port 6379 exposed"
echo "═══════════════════════════════════════════════════════════"

PORT=$(kubectl get pod cache -n web -o jsonpath='{.spec.containers[0].ports[0].containerPort}' 2>/dev/null || echo "")

if [ "$PORT" = "6379" ]; then
    echo "✅ PASSED: Port 6379 is exposed"
    ((PASSED++))
else
    # Check if port is defined with name
    PORT_BY_NAME=$(kubectl get pod cache -n web -o jsonpath='{.spec.containers[0].ports[?(@.containerPort==6379)].containerPort}' 2>/dev/null || echo "")
    
    if [ "$PORT_BY_NAME" = "6379" ]; then
        echo "✅ PASSED: Port 6379 is exposed"
        ((PASSED++))
    else
        echo "❌ FAILED: Port 6379 is not exposed (current: $PORT)"
        echo "   💡 Add port 6379 to the container spec"
        ((FAILED++))
    fi
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Final Result"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "✅ Tests passed: $PASSED"
echo "❌ Tests failed: $FAILED"
echo ""

if [ $FAILED -eq 0 ]; then
    echo "🎉 CONGRATULATIONS! All validations passed!"
    echo "✅ The question was solved correctly."
    exit 0
else
    echo "⚠️  Some validations failed."
    echo "📝 Review the items above and try again."
    exit 1
fi


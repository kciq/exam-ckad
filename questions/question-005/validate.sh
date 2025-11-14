#!/bin/bash

# Validation Script - Question 005
# Validates if the question was solved correctly

set -e

echo "🔍 Validating solution for Question 005..."
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
check "Namespace nov2025 exists" "kubectl get namespace nov2025"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Validation 2: Deployment exists"
echo "═══════════════════════════════════════════════════════════"
check "Deployment nov2025-deployment exists in namespace nov2025" "kubectl get deployment nov2025-deployment -n nov2025"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Validation 3: Deployment replicas"
echo "═══════════════════════════════════════════════════════════"

REPLICAS=$(kubectl get deployment nov2025-deployment -n nov2025 -o jsonpath='{.spec.replicas}' 2>/dev/null || echo "0")

if [ "$REPLICAS" = "4" ]; then
    echo "✅ PASSED: Deployment has 4 replicas"
    ((PASSED++))
else
    echo "❌ FAILED: Deployment does not have 4 replicas (current: $REPLICAS)"
    echo "   💡 Scale the deployment: kubectl scale deployment nov2025-deployment --replicas=4 -n nov2025"
    ((FAILED++))
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Validation 4: Pod template label func=webFrontend"
echo "═══════════════════════════════════════════════════════════"

LABEL_VALUE=$(kubectl get deployment nov2025-deployment -n nov2025 -o jsonpath='{.spec.template.metadata.labels.func}' 2>/dev/null || echo "")

if [ "$LABEL_VALUE" = "webFrontend" ]; then
    echo "✅ PASSED: Pod template has label func=webFrontend"
    ((PASSED++))
else
    echo "❌ FAILED: Pod template does not have label func=webFrontend (current: '$LABEL_VALUE')"
    echo "   💡 Add label func=webFrontend to the pod template metadata"
    ((FAILED++))
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Validation 5: Service Berry exists"
echo "═══════════════════════════════════════════════════════════"
check "Service Berry exists in namespace nov2025" "kubectl get service Berry -n nov2025"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Validation 6: Service type NodePort"
echo "═══════════════════════════════════════════════════════════"

SERVICE_TYPE=$(kubectl get service Berry -n nov2025 -o jsonpath='{.spec.type}' 2>/dev/null || echo "")

if [ "$SERVICE_TYPE" = "NodePort" ]; then
    echo "✅ PASSED: Service Berry is of type NodePort"
    ((PASSED++))
else
    echo "❌ FAILED: Service Berry is not of type NodePort (current: $SERVICE_TYPE)"
    echo "   💡 Set service type to NodePort"
    ((FAILED++))
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Validation 7: Service port 8080"
echo "═══════════════════════════════════════════════════════════"

SERVICE_PORT=$(kubectl get service Berry -n nov2025 -o jsonpath='{.spec.ports[0].port}' 2>/dev/null || echo "")

if [ "$SERVICE_PORT" = "8080" ]; then
    echo "✅ PASSED: Service Berry exposes port 8080"
    ((PASSED++))
else
    echo "❌ FAILED: Service Berry does not expose port 8080 (current: $SERVICE_PORT)"
    echo "   💡 Set service port to 8080"
    ((FAILED++))
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Validation 8: Service selector matches deployment"
echo "═══════════════════════════════════════════════════════════"

# Check if service selector matches pods with func=webFrontend label
SERVICE_SELECTOR_FUNC=$(kubectl get service Berry -n nov2025 -o jsonpath='{.spec.selector.func}' 2>/dev/null || echo "")

if [ "$SERVICE_SELECTOR_FUNC" = "webFrontend" ]; then
    echo "✅ PASSED: Service selector matches func=webFrontend label"
    ((PASSED++))
else
    # Check if it uses app label that would still match
    SERVICE_SELECTOR_APP=$(kubectl get service Berry -n nov2025 -o jsonpath='{.spec.selector.app}' 2>/dev/null || echo "")
    DEPLOYMENT_APP=$(kubectl get deployment nov2025-deployment -n nov2025 -o jsonpath='{.spec.selector.matchLabels.app}' 2>/dev/null || echo "")
    
    if [ "$SERVICE_SELECTOR_APP" = "$DEPLOYMENT_APP" ] && [ -n "$DEPLOYMENT_APP" ]; then
        echo "✅ PASSED: Service selector matches deployment labels"
        ((PASSED++))
    else
        echo "⚠️  WARNING: Service selector may not correctly match deployment pods"
        echo "   💡 Ensure service selector matches pods from nov2025-deployment (func=webFrontend)"
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



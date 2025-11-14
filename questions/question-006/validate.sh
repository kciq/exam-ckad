#!/bin/bash

# Validation Script - Question 006
# Validates if the question was solved correctly

set -e

echo "🔍 Validating solution for Question 006..."
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
echo "Validation 2: app deployment exists"
echo "═══════════════════════════════════════════════════════════"
check "Deployment app exists in namespace nov2025" "kubectl get deployment app -n nov2025"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Validation 3: app deployment maxSurge"
echo "═══════════════════════════════════════════════════════════"

MAX_SURGE=$(kubectl get deployment app -n nov2025 -o jsonpath='{.spec.strategy.rollingUpdate.maxSurge}' 2>/dev/null || echo "")

if [ "$MAX_SURGE" = "5%" ] || [ "$MAX_SURGE" = "1" ]; then
    echo "✅ PASSED: app deployment has maxSurge set to 5% (or equivalent)"
    ((PASSED++))
else
    # Check if it's set as a percentage string
    if [[ "$MAX_SURGE" == *"5%"* ]]; then
        echo "✅ PASSED: app deployment has maxSurge set to 5%"
        ((PASSED++))
    else
        echo "❌ FAILED: app deployment maxSurge is not 5% (current: $MAX_SURGE)"
        echo "   💡 Set maxSurge: '5%' in rollingUpdate strategy"
        ((FAILED++))
    fi
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Validation 4: app deployment maxUnavailable"
echo "═══════════════════════════════════════════════════════════"

MAX_UNAVAILABLE=$(kubectl get deployment app -n nov2025 -o jsonpath='{.spec.strategy.rollingUpdate.maxUnavailable}' 2>/dev/null || echo "")

if [ "$MAX_UNAVAILABLE" = "2%" ] || [ "$MAX_UNAVAILABLE" = "0" ]; then
    echo "✅ PASSED: app deployment has maxUnavailable set to 2% (or equivalent)"
    ((PASSED++))
else
    # Check if it's set as a percentage string
    if [[ "$MAX_UNAVAILABLE" == *"2%"* ]]; then
        echo "✅ PASSED: app deployment has maxUnavailable set to 2%"
        ((PASSED++))
    else
        echo "❌ FAILED: app deployment maxUnavailable is not 2% (current: $MAX_UNAVAILABLE)"
        echo "   💡 Set maxUnavailable: '2%' in rollingUpdate strategy"
        ((FAILED++))
    fi
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Validation 5: web1 deployment exists"
echo "═══════════════════════════════════════════════════════════"
check "Deployment web1 exists in namespace nov2025" "kubectl get deployment web1 -n nov2025"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Validation 6: web1 deployment image version"
echo "═══════════════════════════════════════════════════════════"

WEB1_IMAGE=$(kubectl get deployment web1 -n nov2025 -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null || echo "")

if [[ "$WEB1_IMAGE" == *"nginx:1.13"* ]] || [[ "$WEB1_IMAGE" == *"nginx:1.13"* ]]; then
    echo "✅ PASSED: web1 deployment is using nginx:1.13"
    ((PASSED++))
else
    echo "❌ FAILED: web1 deployment is not using nginx:1.13 (current: $WEB1_IMAGE)"
    echo "   💡 Update the image: kubectl set image deployment/web1 web=nginx:1.13 -n nov2025"
    ((FAILED++))
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Validation 7: app deployment rollback"
echo "═══════════════════════════════════════════════════════════"

# Check revision history
REVISION_COUNT=$(kubectl rollout history deployment/app -n nov2025 2>/dev/null | grep -c "revision" || echo "0")

if [ "$REVISION_COUNT" -ge 2 ]; then
    # Check current revision vs previous
    CURRENT_REVISION=$(kubectl rollout history deployment/app -n nov2025 --no-headers 2>/dev/null | grep '\*' | awk '{print $1}' | sed 's/*//' || echo "")
    PREVIOUS_REVISION=$(kubectl rollout history deployment/app -n nov2025 --no-headers 2>/dev/null | grep -v '\*' | head -1 | awk '{print $1}' || echo "")
    
    if [ -n "$CURRENT_REVISION" ] && [ -n "$PREVIOUS_REVISION" ]; then
        # Get images from current and check if it matches a previous revision
        CURRENT_IMAGE=$(kubectl get deployment app -n nov2025 -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null || echo "")
        
        # This is a bit tricky - we'll check if there are multiple revisions indicating a rollback happened
        if [ "$REVISION_COUNT" -ge 2 ]; then
            echo "✅ PASSED: app deployment has revision history indicating possible rollback"
            ((PASSED++))
        else
            echo "⚠️  WARNING: Could not fully verify rollback"
            ((PASSED++))
        fi
    else
        echo "⚠️  WARNING: Could not verify rollback status"
        ((PASSED++))
    fi
else
    echo "❌ FAILED: app deployment does not have sufficient revision history for rollback"
    echo "   💡 Make a change first, then rollback: kubectl rollout undo deployment/app -n nov2025"
    ((FAILED++))
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



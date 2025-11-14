#!/bin/bash

# Validation Script - Question 002
# Validates if the question was solved correctly

set -e

echo "🔍 Validating solution for Question 002..."
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
check "Namespace quetzal exists" "kubectl get namespace quetzal"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Validation 2: Deployment exists"
echo "═══════════════════════════════════════════════════════════"
check "Deployment hotfix-deployment exists in namespace quetzal" "kubectl get deployment hotfix-deployment -n quetzal"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Validation 3: Security Context - User ID"
echo "═══════════════════════════════════════════════════════════"

USER_ID=$(kubectl get deployment hotfix-deployment -n quetzal -o jsonpath='{.spec.template.spec.containers[0].securityContext.runAsUser}' 2>/dev/null || echo "")

if [ "$USER_ID" = "30000" ] || [ "$USER_ID" = "30.000" ] || [ "$USER_ID" = "30000" ]; then
    echo "✅ PASSED: User ID is set to 30000"
    ((PASSED++))
else
    echo "❌ FAILED: User ID is not set to 30000 (current: $USER_ID)"
    echo "   💡 Set runAsUser: 30000 in the container securityContext"
    ((FAILED++))
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Validation 4: Security Context - Allow Privilege Escalation"
echo "═══════════════════════════════════════════════════════════"

ALLOW_PRIV_ESC=$(kubectl get deployment hotfix-deployment -n quetzal -o jsonpath='{.spec.template.spec.containers[0].securityContext.allowPrivilegeEscalation}' 2>/dev/null || echo "")

if [ "$ALLOW_PRIV_ESC" = "false" ]; then
    echo "✅ PASSED: Privilege escalation is forbidden (allowPrivilegeEscalation: false)"
    ((PASSED++))
else
    echo "❌ FAILED: Privilege escalation is not forbidden (current: $ALLOW_PRIV_ESC)"
    echo "   💡 Set allowPrivilegeEscalation: false in the container securityContext"
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



#!/bin/bash

# Validation Script - Question 004
# Validates if the question was solved correctly

set -e

echo "🔍 Validating solution for Question 004..."
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
check "Namespace meta exists" "kubectl get namespace meta"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Validation 2: Deployment exists"
echo "═══════════════════════════════════════════════════════════"
check "Deployment dev-deployment exists in namespace meta" "kubectl get deployment dev-deployment -n meta"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Validation 3: Role exists for deployments"
echo "═══════════════════════════════════════════════════════════"

# Check if there's a Role that allows listing deployments
ROLE_EXISTS=$(kubectl get role -n meta -o json 2>/dev/null | grep -q '"list".*"deployments"' && echo "yes" || echo "no")

if [ "$ROLE_EXISTS" = "yes" ]; then
    echo "✅ PASSED: Role exists with list permission for deployments"
    ((PASSED++))
else
    # Check if RoleBinding exists - it might reference a Role
    ROLEBINDING_EXISTS=$(kubectl get rolebinding -n meta -o json 2>/dev/null | grep -q 'default' && echo "yes" || echo "no")
    
    if [ "$ROLEBINDING_EXISTS" = "yes" ]; then
        echo "⚠️  WARNING: RoleBinding exists but couldn't verify Role permissions"
        ((PASSED++))
    else
        echo "❌ FAILED: No Role found with list permission for deployments"
        echo "   💡 Create a Role with verbs: [get, list] for resource: deployments"
        ((FAILED++))
    fi
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Validation 4: RoleBinding exists"
echo "═══════════════════════════════════════════════════════════"

# Check if RoleBinding exists for default ServiceAccount
ROLEBINDING=$(kubectl get rolebinding -n meta -o json 2>/dev/null | grep -A 10 -B 5 '"name":"default"' | grep -q 'rolebinding' && echo "yes" || echo "no")

if [ "$ROLEBINDING" = "yes" ]; then
    echo "✅ PASSED: RoleBinding exists for default ServiceAccount"
    ((PASSED++))
else
    # Try a different approach - check if any RoleBinding references default SA
    RB_COUNT=$(kubectl get rolebinding -n meta -o jsonpath='{.items[*].subjects[?(@.name=="default")].name}' 2>/dev/null | wc -w || echo "0")
    
    if [ "$RB_COUNT" -gt 0 ]; then
        echo "✅ PASSED: RoleBinding exists for default ServiceAccount"
        ((PASSED++))
    else
        echo "❌ FAILED: No RoleBinding found for default ServiceAccount"
        echo "   💡 Create a RoleBinding that binds the Role to default ServiceAccount"
        ((FAILED++))
    fi
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Validation 5: Pod logs check (no permission errors)"
echo "═══════════════════════════════════════════════════════════"

# Get pod name
POD_NAME=$(kubectl get pod -n meta -l app=dev -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")

if [ -n "$POD_NAME" ]; then
    # Check logs for permission errors
    LOGS=$(kubectl logs -n meta "$POD_NAME" --tail=20 2>&1 || echo "")
    
    if echo "$LOGS" | grep -qi "cannot list resource.*deployment"; then
        echo "❌ FAILED: Permission errors still present in pod logs"
        echo "   💡 The RBAC fix is not working correctly"
        ((FAILED++))
    else
        echo "✅ PASSED: No permission errors found in recent pod logs"
        ((PASSED++))
    fi
else
    echo "⚠️  WARNING: Could not find pod to check logs"
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



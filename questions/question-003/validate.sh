#!/bin/bash

# Validation Script - Question 003
# Validates if the question was solved correctly

set -e

echo "🔍 Validating solution for Question 003..."
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
echo "Validation 1: Secret exists"
echo "═══════════════════════════════════════════════════════════"
check "Secret db-credentials exists in default namespace" "kubectl get secret db-credentials"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Validation 2: Secret data - username"
echo "═══════════════════════════════════════════════════════════"

USERNAME=$(kubectl get secret db-credentials -o jsonpath='{.data.username}' 2>/dev/null | base64 -d 2>/dev/null || echo "")

if [ "$USERNAME" = "admin" ]; then
    echo "✅ PASSED: Secret username is 'admin'"
    ((PASSED++))
else
    echo "❌ FAILED: Secret username is not 'admin' (current: '$USERNAME')"
    echo "   💡 Create secret with: kubectl create secret generic db-credentials --from-literal=username=admin --from-literal=password='P@ssw0rd123'"
    ((FAILED++))
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Validation 3: Secret data - password"
echo "═══════════════════════════════════════════════════════════"

PASSWORD=$(kubectl get secret db-credentials -o jsonpath='{.data.password}' 2>/dev/null | base64 -d 2>/dev/null || echo "")

if [ "$PASSWORD" = "P@ssw0rd123" ]; then
    echo "✅ PASSED: Secret password is 'P@ssw0rd123'"
    ((PASSED++))
else
    echo "❌ FAILED: Secret password is not 'P@ssw0rd123' (current: '$PASSWORD')"
    ((FAILED++))
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Validation 4: Pod exists"
echo "═══════════════════════════════════════════════════════════"
check "Pod env-secret-pod exists in default namespace" "kubectl get pod env-secret-pod"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Validation 5: Pod using busybox image"
echo "═══════════════════════════════════════════════════════════"

IMAGE=$(kubectl get pod env-secret-pod -o jsonpath='{.spec.containers[0].image}' 2>/dev/null || echo "")

if [[ "$IMAGE" == *"busybox"* ]]; then
    echo "✅ PASSED: Pod is using busybox image"
    ((PASSED++))
else
    echo "❌ FAILED: Pod is not using busybox image (current: $IMAGE)"
    ((FAILED++))
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Validation 6: Environment variable DB_USER"
echo "═══════════════════════════════════════════════════════════"

DB_USER_ENV=$(kubectl get pod env-secret-pod -o jsonpath='{.spec.containers[0].env[?(@.name=="DB_USER")].valueFrom.secretKeyRef.name}' 2>/dev/null || echo "")
DB_USER_KEY=$(kubectl get pod env-secret-pod -o jsonpath='{.spec.containers[0].env[?(@.name=="DB_USER")].valueFrom.secretKeyRef.key}' 2>/dev/null || echo "")

if [ "$DB_USER_ENV" = "db-credentials" ] && [ "$DB_USER_KEY" = "username" ]; then
    echo "✅ PASSED: DB_USER environment variable is correctly mapped from Secret"
    ((PASSED++))
else
    echo "❌ FAILED: DB_USER environment variable is not correctly mapped"
    echo "   💡 Map secretKeyRef: {name: db-credentials, key: username} to env var DB_USER"
    ((FAILED++))
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Validation 7: Environment variable DB_PASS"
echo "═══════════════════════════════════════════════════════════"

DB_PASS_ENV=$(kubectl get pod env-secret-pod -o jsonpath='{.spec.containers[0].env[?(@.name=="DB_PASS")].valueFrom.secretKeyRef.name}' 2>/dev/null || echo "")
DB_PASS_KEY=$(kubectl get pod env-secret-pod -o jsonpath='{.spec.containers[0].env[?(@.name=="DB_PASS")].valueFrom.secretKeyRef.key}' 2>/dev/null || echo "")

if [ "$DB_PASS_ENV" = "db-credentials" ] && [ "$DB_PASS_KEY" = "password" ]; then
    echo "✅ PASSED: DB_PASS environment variable is correctly mapped from Secret"
    ((PASSED++))
else
    echo "❌ FAILED: DB_PASS environment variable is not correctly mapped"
    echo "   💡 Map secretKeyRef: {name: db-credentials, key: password} to env var DB_PASS"
    ((FAILED++))
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Validation 8: Pod is running"
echo "═══════════════════════════════════════════════════════════"

POD_STATUS=$(kubectl get pod env-secret-pod -o jsonpath='{.status.phase}' 2>/dev/null || echo "")

if [ "$POD_STATUS" = "Running" ]; then
    echo "✅ PASSED: Pod is in Running state"
    ((PASSED++))
else
    echo "⚠️  WARNING: Pod is not in Running state (current: $POD_STATUS)"
    echo "   💡 Make sure the pod uses 'sleep 3600' command to keep it running"
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



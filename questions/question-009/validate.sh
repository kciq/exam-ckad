#!/bin/bash

# Validation Script - Question 009
# Validates if the question was solved correctly

set +e  # Don't exit on error - we want to check all validations

echo "🔍 Validating solution for Question 009..."
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
echo "Validation 1: YAML file exists"
echo "═══════════════════════════════════════════════════════════"
check "YAML file exists at /opt/ckadnov2025/winter.yaml" "test -f /opt/ckadnov2025/winter.yaml"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Validation 2: Winter pod deployed"
echo "═══════════════════════════════════════════════════════════"
check "Pod winter exists" "kubectl get pod winter"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Validation 3: Winter pod is running"
echo "═══════════════════════════════════════════════════════════"

POD_STATUS=$(kubectl get pod winter -o jsonpath='{.status.phase}' 2>/dev/null || echo "")

if [ "$POD_STATUS" = "Running" ]; then
    echo "✅ PASSED: Pod winter is in Running state"
    ((PASSED++))
else
    echo "❌ FAILED: Pod winter is not in Running state (current: $POD_STATUS)"
    echo "   💡 Make sure the pod is deployed and running"
    ((FAILED++))
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Validation 4: Log output file exists"
echo "═══════════════════════════════════════════════════════════"
check "Log output file exists at /opt/ckadnov2025/log_output.txt" "test -f /opt/ckadnov2025/log_output.txt"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Validation 5: Log output file contains logs"
echo "═══════════════════════════════════════════════════════════"

if [ -f /opt/ckadnov2025/log_output.txt ]; then
    LOG_SIZE=$(stat -f%z /opt/ckadnov2025/log_output.txt 2>/dev/null || stat -c%s /opt/ckadnov2025/log_output.txt 2>/dev/null || echo "0")
    if [ "$LOG_SIZE" -gt 0 ]; then
        echo "✅ PASSED: Log output file contains data ($LOG_SIZE bytes)"
        ((PASSED++))
        
        # Check if logs look like pod logs
        if grep -q "winter\|Winter\|date\|running" /opt/ckadnov2025/log_output.txt 2>/dev/null; then
            echo "✅ PASSED: Log output file contains pod log content"
            ((PASSED++))
        else
            echo "⚠️  WARNING: Log output file may not contain valid pod logs"
            ((FAILED++))
        fi
    else
        echo "❌ FAILED: Log output file is empty"
        echo "   💡 Retrieve logs using: kubectl logs winter > /opt/ckadnov2025/log_output.txt"
        ((FAILED++))
    fi
else
    echo "❌ FAILED: Log output file does not exist"
    ((FAILED++))
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Validation 6: Pod output file exists"
echo "═══════════════════════════════════════════════════════════"
check "Pod output file exists at /opt/ckadnov2025/pod.txt" "test -f /opt/ckadnov2025/pod.txt"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Validation 7: Pod output file contains pod name"
echo "═══════════════════════════════════════════════════════════"

if [ -f /opt/ckadnov2025/pod.txt ]; then
    POD_NAME=$(cat /opt/ckadnov2025/pod.txt 2>/dev/null | tr -d '[:space:]' || echo "")
    
    if [ -n "$POD_NAME" ]; then
        echo "✅ PASSED: Pod output file contains a pod name: $POD_NAME"
        ((PASSED++))
        
        # Verify the pod exists in cpu-stress namespace
        if kubectl get pod "$POD_NAME" -n cpu-stress &> /dev/null; then
            echo "✅ PASSED: Pod $POD_NAME exists in cpu-stress namespace"
            ((PASSED++))
            
            # Try to verify it's the one with highest CPU (if metrics server is available)
            if kubectl top pods -n cpu-stress &> /dev/null; then
                HIGHEST_CPU_POD=$(kubectl top pods -n cpu-stress --sort-by=cpu --no-headers 2>/dev/null | head -1 | awk '{print $1}' || echo "")
                if [ "$HIGHEST_CPU_POD" = "$POD_NAME" ]; then
                    echo "✅ PASSED: Pod $POD_NAME is the one with highest CPU usage"
                    ((PASSED++))
                else
                    echo "⚠️  WARNING: Pod $POD_NAME may not be the one with highest CPU (highest: $HIGHEST_CPU_POD)"
                    echo "   💡 Use: kubectl top pods -n cpu-stress --sort-by=cpu"
                    ((FAILED++))
                fi
            else
                echo "ℹ️  INFO: Metrics server not available, cannot verify CPU usage"
                ((PASSED++))
            fi
        else
            echo "❌ FAILED: Pod $POD_NAME does not exist in cpu-stress namespace"
            echo "   💡 Make sure the pod name is correct and exists in cpu-stress namespace"
            ((FAILED++))
        fi
    else
        echo "❌ FAILED: Pod output file is empty"
        echo "   💡 Write the pod name to /opt/ckadnov2025/pod.txt"
        ((FAILED++))
    fi
else
    echo "❌ FAILED: Pod output file does not exist"
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


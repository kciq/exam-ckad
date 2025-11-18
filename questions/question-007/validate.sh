#!/bin/bash

# Validation Script - Question 007
# Validates if the question was solved correctly

set +e  # Don't exit on error - we want to check all validations

echo "🔍 Validating solution for Question 007..."
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
check "Namespace production exists" "kubectl get namespace production"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Validation 2: CronJob exists"
echo "═══════════════════════════════════════════════════════════"
check "CronJob log-cleaner exists in namespace production" "kubectl get cronjob log-cleaner -n production"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Validation 3: CronJob schedule"
echo "═══════════════════════════════════════════════════════════"

SCHEDULE=$(kubectl get cronjob log-cleaner -n production -o jsonpath='{.spec.schedule}' 2>/dev/null || echo "")

if [ "$SCHEDULE" = "*/30 * * * *" ] || [ "$SCHEDULE" = "0,30 * * * *" ] || [[ "$SCHEDULE" == *"*/30"* ]]; then
    echo "✅ PASSED: CronJob schedule is every 30 minutes (current: $SCHEDULE)"
    ((PASSED++))
else
    echo "❌ FAILED: CronJob schedule is not every 30 minutes (current: $SCHEDULE)"
    echo "   💡 Set schedule to '*/30 * * * *' for every 30 minutes"
    ((FAILED++))
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Validation 4: Completions"
echo "═══════════════════════════════════════════════════════════"

COMPLETIONS=$(kubectl get cronjob log-cleaner -n production -o jsonpath='{.spec.successfulJobsHistoryLimit}' 2>/dev/null || echo "")

# Note: The question says "2 completions" which likely means successfulJobsHistoryLimit
# But it could also mean parallelism or completions in job template
# Let's check successfulJobsHistoryLimit first
if [ "$COMPLETIONS" = "2" ]; then
    echo "✅ PASSED: successfulJobsHistoryLimit is 2"
    ((PASSED++))
else
    # Check if it's in the job template
    JOB_COMPLETIONS=$(kubectl get cronjob log-cleaner -n production -o jsonpath='{.spec.jobTemplate.spec.completions}' 2>/dev/null || echo "")
    if [ "$JOB_COMPLETIONS" = "2" ]; then
        echo "✅ PASSED: Job completions is 2"
        ((PASSED++))
    else
        echo "❌ FAILED: Completions is not 2 (successfulJobsHistoryLimit: $COMPLETIONS, job completions: $JOB_COMPLETIONS)"
        echo "   💡 Set successfulJobsHistoryLimit: 2 or jobTemplate.spec.completions: 2"
        ((FAILED++))
    fi
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Validation 5: Retries (backoffLimit)"
echo "═══════════════════════════════════════════════════════════"

BACKOFF_LIMIT=$(kubectl get cronjob log-cleaner -n production -o jsonpath='{.spec.jobTemplate.spec.backoffLimit}' 2>/dev/null || echo "")

if [ "$BACKOFF_LIMIT" = "3" ]; then
    echo "✅ PASSED: backoffLimit is 3"
    ((PASSED++))
else
    echo "❌ FAILED: backoffLimit is not 3 (current: $BACKOFF_LIMIT)"
    echo "   💡 Set jobTemplate.spec.backoffLimit: 3"
    ((FAILED++))
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Validation 6: Active deadline (30 seconds)"
echo "═══════════════════════════════════════════════════════════"

ACTIVE_DEADLINE=$(kubectl get cronjob log-cleaner -n production -o jsonpath='{.spec.jobTemplate.spec.activeDeadlineSeconds}' 2>/dev/null || echo "")

if [ "$ACTIVE_DEADLINE" = "30" ]; then
    echo "✅ PASSED: activeDeadlineSeconds is 30"
    ((PASSED++))
else
    echo "❌ FAILED: activeDeadlineSeconds is not 30 (current: $ACTIVE_DEADLINE)"
    echo "   💡 Set jobTemplate.spec.activeDeadlineSeconds: 30"
    ((FAILED++))
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Validation 7: Container image (busybox)"
echo "═══════════════════════════════════════════════════════════"

CONTAINER_IMAGE=$(kubectl get cronjob log-cleaner -n production -o jsonpath='{.spec.jobTemplate.spec.template.spec.containers[0].image}' 2>/dev/null || echo "")

if [[ "$CONTAINER_IMAGE" == *"busybox"* ]]; then
    echo "✅ PASSED: Container is using busybox image (current: $CONTAINER_IMAGE)"
    ((PASSED++))
else
    echo "❌ FAILED: Container is not using busybox image (current: $CONTAINER_IMAGE)"
    echo "   💡 Set container image to busybox"
    ((FAILED++))
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Validation 8: Container name (log)"
echo "═══════════════════════════════════════════════════════════"

CONTAINER_NAME=$(kubectl get cronjob log-cleaner -n production -o jsonpath='{.spec.jobTemplate.spec.template.spec.containers[0].name}' 2>/dev/null || echo "")

if [ "$CONTAINER_NAME" = "log" ]; then
    echo "✅ PASSED: Container name is 'log'"
    ((PASSED++))
else
    echo "❌ FAILED: Container name is not 'log' (current: $CONTAINER_NAME)"
    echo "   💡 Set container name to 'log'"
    ((FAILED++))
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Validation 9: Command (date)"
echo "═══════════════════════════════════════════════════════════"

# Check if command is date
COMMAND=$(kubectl get cronjob log-cleaner -n production -o jsonpath='{.spec.jobTemplate.spec.template.spec.containers[0].command[0]}' 2>/dev/null || echo "")
ARGS=$(kubectl get cronjob log-cleaner -n production -o jsonpath='{.spec.jobTemplate.spec.template.spec.containers[0].args[0]}' 2>/dev/null || echo "")

if [ "$COMMAND" = "date" ] || [ "$ARGS" = "date" ] || [[ "$COMMAND" == *"date"* ]] || [[ "$ARGS" == *"date"* ]]; then
    echo "✅ PASSED: Container executes 'date' command"
    ((PASSED++))
else
    echo "❌ FAILED: Container does not execute 'date' command (command: $COMMAND, args: $ARGS)"
    echo "   💡 Set command or args to execute 'date'"
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


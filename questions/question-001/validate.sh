#!/bin/bash

# Validation Script - Question 001
# Validates if the question was solved correctly

set +e  # Don't exit on error - we want to check all validations

echo "🔍 Validating solution for Question 001..."
echo ""

# Contadores de validação
PASSED=0
FAILED=0

# Função para verificar e reportar
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

# Função para verificar e reportar (com detalhes do erro)
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
echo "Validation 1: Dockerfile exists"
echo "═══════════════════════════════════════════════════════════"
check "Dockerfile exists at ~/home/Dockerfile" "test -f ~/home/Dockerfile"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Validation 2: Image built"
echo "═══════════════════════════════════════════════════════════"

# Verificar se a imagem existe usando TODAS as ferramentas disponíveis
IMAGE_EXISTS=false
TOOL_USED=""
TOOLS_CHECKED=()

# Check Docker
if command -v docker &> /dev/null; then
    TOOLS_CHECKED+=("docker")
    # Try multiple formats: devmaq:3.0, devmaq:3, devmaq 3.0, etc.
    if docker images --format '{{.Repository}}:{{.Tag}}' 2>/dev/null | grep -qE "^devmaq:(3\.0|3)$"; then
        IMAGE_EXISTS=true
        TOOL_USED="docker"
    elif docker images devmaq --format '{{.Repository}}:{{.Tag}}' 2>/dev/null | grep -qE "devmaq.*3"; then
        IMAGE_EXISTS=true
        TOOL_USED="docker"
    fi
fi

# Check Podman (if not found yet)
if [ "$IMAGE_EXISTS" = false ] && command -v podman &> /dev/null; then
    TOOLS_CHECKED+=("podman")
    if podman images --format '{{.Repository}}:{{.Tag}}' 2>/dev/null | grep -qE "^devmaq:(3\.0|3)$"; then
        IMAGE_EXISTS=true
        TOOL_USED="podman"
    elif podman images devmaq --format '{{.Repository}}:{{.Tag}}' 2>/dev/null | grep -qE "devmaq.*3"; then
        IMAGE_EXISTS=true
        TOOL_USED="podman"
    fi
fi

# Check Buildah (if not found yet)
if [ "$IMAGE_EXISTS" = false ] && command -v buildah &> /dev/null; then
    TOOLS_CHECKED+=("buildah")
    if buildah images --format '{{.Repository}}:{{.Tag}}' 2>/dev/null | grep -qE "^devmaq:(3\.0|3)$"; then
        IMAGE_EXISTS=true
        TOOL_USED="buildah"
    elif buildah images devmaq --format '{{.Repository}}:{{.Tag}}' 2>/dev/null | grep -qE "devmaq.*3"; then
        IMAGE_EXISTS=true
        TOOL_USED="buildah"
    fi
fi

# Check img (if not found yet)
if [ "$IMAGE_EXISTS" = false ] && command -v img &> /dev/null; then
    TOOLS_CHECKED+=("img")
    if img ls 2>/dev/null | grep -qE "devmaq.*3"; then
        IMAGE_EXISTS=true
        TOOL_USED="img"
    fi
fi

if [ "$IMAGE_EXISTS" = true ]; then
    echo "✅ PASSED: Image devmaq:3.0 found (using $TOOL_USED)"
    if [ ${#TOOLS_CHECKED[@]} -gt 1 ]; then
        echo "   ℹ️  Checked tools: ${TOOLS_CHECKED[*]}"
    fi
    ((PASSED++))
else
    echo "❌ FAILED: Image devmaq:3.0 not found"
    if [ ${#TOOLS_CHECKED[@]} -gt 0 ]; then
        echo "   ℹ️  Checked tools: ${TOOLS_CHECKED[*]}"
        echo "   💡 Build the image using: ${TOOLS_CHECKED[0]} build -t devmaq:3.0 ~/home"
    else
        echo "   💡 No container tools found. Please install docker, podman, buildah, or img"
    fi
    ((FAILED++))
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Validation 3: Exported tar file"
echo "═══════════════════════════════════════════════════════════"

check_with_error \
    "File ~/human-stork/devmac3.0.tar exists" \
    "test -f ~/human-stork/devmac3.0.tar" \
    "Export the image to ~/human-stork/devmac3.0.tar"

# Verificar se o arquivo tar é válido (contém dados)
if [ -f ~/human-stork/devmac3.0.tar ]; then
    FILE_SIZE=$(stat -f%z ~/human-stork/devmac3.0.tar 2>/dev/null || stat -c%s ~/human-stork/devmac3.0.tar 2>/dev/null || echo "0")
    if [ "$FILE_SIZE" -gt 1000 ]; then
        echo "✅ PASSED: Tar file has valid size ($FILE_SIZE bytes)"
        ((PASSED++))
    else
        echo "❌ FAILED: Tar file seems empty or too small ($FILE_SIZE bytes)"
        echo "   💡 The file should contain the exported image"
        ((FAILED++))
    fi
    
    # Verificar se é um arquivo tar válido
    if tar -tf ~/human-stork/devmac3.0.tar &> /dev/null; then
        echo "✅ PASSED: File is a valid tar archive"
        ((PASSED++))
    else
        echo "⚠️  WARNING: File may not be a valid tar archive"
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

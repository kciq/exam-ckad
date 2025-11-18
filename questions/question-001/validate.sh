#!/bin/bash

# Script de Validação - Questão 001
# Valida se a questão foi resolvida corretamente

set +e  # Don't exit on error - we want to check all validations

echo "🔍 Validando solução da Questão 001..."
echo ""

# Contadores de validação
PASSED=0
FAILED=0

# Função para verificar e reportar
check() {
    local description="$1"
    local command="$2"
    
    echo -n "Verificando: $description... "
    
    if eval "$command" &> /dev/null; then
        echo "✅ PASSOU"
        ((PASSED++))
        return 0
    else
        echo "❌ FALHOU"
        ((FAILED++))
        return 1
    fi
}

# Função para verificar e reportar (com detalhes do erro)
check_with_error() {
    local description="$1"
    local command="$2"
    local error_msg="$3"
    
    echo -n "Verificando: $description... "
    
    if eval "$command" &> /dev/null; then
        echo "✅ PASSOU"
        ((PASSED++))
        return 0
    else
        echo "❌ FALHOU"
        echo "   💡 $error_msg"
        ((FAILED++))
        return 1
    fi
}

echo "═══════════════════════════════════════════════════════════"
echo "Validação 1: Dockerfile existe"
echo "═══════════════════════════════════════════════════════════"
check "Dockerfile existe em ~/home/Dockerfile" "test -f ~/home/Dockerfile"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Validação 2: Imagem construída"
echo "═══════════════════════════════════════════════════════════"

# Verificar se a imagem existe usando diferentes ferramentas
IMAGE_EXISTS=false
TOOL_USED=""

if command -v docker &> /dev/null; then
    if docker images --format '{{.Repository}}:{{.Tag}}' 2>/dev/null | grep -q "^devmaq:3.0$"; then
        IMAGE_EXISTS=true
        TOOL_USED="docker"
    fi
elif command -v podman &> /dev/null; then
    if podman images --format '{{.Repository}}:{{.Tag}}' 2>/dev/null | grep -q "^devmaq:3.0$"; then
        IMAGE_EXISTS=true
        TOOL_USED="podman"
    fi
elif command -v buildah &> /dev/null; then
    if buildah images --format '{{.Repository}}:{{.Tag}}' 2>/dev/null | grep -q "^devmaq:3.0$"; then
        IMAGE_EXISTS=true
        TOOL_USED="buildah"
    fi
elif command -v img &> /dev/null; then
    if img ls 2>/dev/null | grep -q "devmaq.*3.0"; then
        IMAGE_EXISTS=true
        TOOL_USED="img"
    fi
fi

if [ "$IMAGE_EXISTS" = true ]; then
    echo "✅ PASSOU: Imagem devmaq:3.0 encontrada (usando $TOOL_USED)"
    ((PASSED++))
else
    echo "❌ FALHOU: Imagem devmaq:3.0 não encontrada"
    echo "   💡 Construa a imagem usando: docker build -t devmaq:3.0 ~/home"
    ((FAILED++))
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Validação 3: Arquivo tar exportado"
echo "═══════════════════════════════════════════════════════════"

check_with_error \
    "Arquivo ~/human-stork/devmac3.0.tar existe" \
    "test -f ~/human-stork/devmac3.0.tar" \
    "Exporte a imagem para ~/human-stork/devmac3.0.tar"

# Verificar se o arquivo tar é válido (contém dados)
if [ -f ~/human-stork/devmac3.0.tar ]; then
    FILE_SIZE=$(stat -f%z ~/human-stork/devmac3.0.tar 2>/dev/null || stat -c%s ~/human-stork/devmac3.0.tar 2>/dev/null || echo "0")
    if [ "$FILE_SIZE" -gt 1000 ]; then
        echo "✅ PASSOU: Arquivo tar tem tamanho válido ($FILE_SIZE bytes)"
        ((PASSED++))
    else
        echo "❌ FALHOU: Arquivo tar parece estar vazio ou muito pequeno ($FILE_SIZE bytes)"
        echo "   💡 O arquivo deve conter a imagem exportada"
        ((FAILED++))
    fi
    
    # Verificar se é um arquivo tar válido
    if tar -tf ~/human-stork/devmac3.0.tar &> /dev/null; then
        echo "✅ PASSOU: Arquivo é um tar válido"
        ((PASSED++))
    else
        echo "⚠️  AVISO: Arquivo pode não ser um tar válido"
        ((FAILED++))
    fi
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Resultado Final"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "✅ Testes passados: $PASSED"
echo "❌ Testes falhados: $FAILED"
echo ""

if [ $FAILED -eq 0 ]; then
    echo "🎉 PARABÉNS! Todas as validações passaram!"
    echo "✅ A questão foi resolvida corretamente."
    exit 0
else
    echo "⚠️  Algumas validações falharam."
    echo "📝 Revise os itens acima e tente novamente."
    exit 1
fi



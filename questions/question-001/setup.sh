#!/bin/bash

# Script de Setup - Questão 001
# Prepara o ambiente para a questão de build e export de container image

set -e

echo "🚀 Preparando ambiente para Questão 001..."

# Criar diretório home se não existir
mkdir -p ~/home
mkdir -p ~/human-stork

# Criar uma Dockerfile de exemplo se não existir
if [ ! -f ~/home/Dockerfile ]; then
    echo "📝 Criando Dockerfile de exemplo em ~/home/Dockerfile..."
    cat > ~/home/Dockerfile << 'EOF'
FROM alpine:latest

LABEL maintainer="CKAD Lab"
LABEL version="3.0"

RUN apk add --no-cache curl

WORKDIR /app

COPY . /app

CMD ["sh"]
EOF
    echo "✅ Dockerfile criada com sucesso!"
else
    echo "ℹ️  Dockerfile já existe em ~/home/Dockerfile"
fi

# Criar um arquivo .dockerignore para evitar problemas
cat > ~/home/.dockerignore << 'EOF'
.git
.gitignore
EOF

# Verificar se as ferramentas estão disponíveis
echo ""
echo "🔍 Verificando ferramentas disponíveis..."

if command -v docker &> /dev/null; then
    echo "✅ Docker está disponível"
elif command -v podman &> /dev/null; then
    echo "✅ Podman está disponível"
elif command -v buildah &> /dev/null; then
    echo "✅ Buildah está disponível"
elif command -v img &> /dev/null; then
    echo "✅ Img está disponível"
else
    echo "⚠️  Nenhuma ferramenta de build encontrada. Verifique se docker, podman, buildah ou img está instalado."
fi

echo ""
echo "✅ Ambiente preparado com sucesso!"
echo ""
echo "📋 Próximos passos:"
echo "   1. Leia a questão em question.md"
echo "   2. Construa a imagem 'devmaq:3.0' usando ~/home/Dockerfile"
echo "   3. Exporte a imagem para ~/human-stork/devmac3.0.tar"
echo "   4. Execute ./validate.sh para validar sua solução"



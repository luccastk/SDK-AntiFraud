#!/bin/bash

# Instalador rápido de Java para Pop!_OS
# Execute como: ./install-java-popos.sh

echo "🦄 Instalando Java para Pop!_OS..."
echo "=================================="

# Verificar se Java já está instalado
if command -v java >/dev/null 2>&1; then
    echo "✅ Java já está instalado: $(java -version 2>&1 | head -n 1)"
    exit 0
fi

echo "📦 Instalando OpenJDK 17..."
sudo apt update
sudo apt install -y openjdk-17-jdk

if [ $? -eq 0 ]; then
    echo "✅ Java instalado com sucesso!"
    echo "📋 Versão: $(java -version 2>&1 | head -n 1)"
    
    # Configurar JAVA_HOME
    if ! grep -q "JAVA_HOME" ~/.bashrc; then
        echo "🔧 Configurando JAVA_HOME..."
        echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64' >> ~/.bashrc
        echo 'export PATH=$PATH:$JAVA_HOME/bin' >> ~/.bashrc
        echo "⚠️  JAVA_HOME configurado. Execute 'source ~/.bashrc' ou reinicie o terminal"
    fi
    
    echo ""
    echo "🎉 Java instalado! Agora você pode executar:"
    echo "   ./start-dev.sh"
else
    echo "❌ Erro ao instalar Java"
    exit 1
fi

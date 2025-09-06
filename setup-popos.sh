#!/bin/bash

# SDK AntiFraud - Setup para Pop!_OS
# Execute como: ./setup-popos.sh

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Função para imprimir com cores
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${PURPLE}$1${NC}"
}

# Função para verificar se um comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

print_header "🦄 SDK AntiFraud - Setup para Pop!_OS"
print_header "=================================================="

# Verificar se está rodando como root
if [ "$EUID" -eq 0 ]; then
    print_warning "Este script não deve ser executado como root"
    print_status "Execute sem sudo: ./setup-popos.sh"
    exit 1
fi

print_status "Atualizando lista de pacotes..."
sudo apt update

# Instalar Node.js e npm
print_status "Verificando Node.js..."
if ! command_exists node; then
    print_status "Instalando Node.js e npm..."
    sudo apt install -y nodejs npm
    
    # Verificar se a versão do Node.js é muito antiga
    NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_VERSION" -lt 16 ]; then
        print_warning "Versão do Node.js muito antiga ($(node --version)). Instalando NodeSource repository..."
        
        # Instalar NodeSource repository para versão mais recente
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        sudo apt install -y nodejs
        
        print_success "Node.js atualizado para $(node --version)"
    fi
else
    print_success "Node.js já instalado: $(node --version)"
fi

# Verificar npm
if ! command_exists npm; then
    print_status "Instalando npm..."
    sudo apt install -y npm
else
    print_success "npm já instalado: $(npm --version)"
fi

# Instalar Java
print_status "Verificando Java..."
if ! command_exists java; then
    print_status "Instalando OpenJDK 17..."
    sudo apt install -y openjdk-17-jdk
    
    # Configurar JAVA_HOME se necessário
    if ! grep -q "JAVA_HOME" ~/.bashrc; then
        print_status "Configurando JAVA_HOME..."
        echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64' >> ~/.bashrc
        echo 'export PATH=$PATH:$JAVA_HOME/bin' >> ~/.bashrc
        print_warning "JAVA_HOME configurado. Execute 'source ~/.bashrc' ou reinicie o terminal"
    fi
else
    print_success "Java já instalado: $(java -version 2>&1 | head -n 1)"
fi

# Instalar ferramentas úteis para desenvolvimento
print_status "Instalando ferramentas de desenvolvimento..."

# lsof para verificar portas
if ! command_exists lsof; then
    print_status "Instalando lsof..."
    sudo apt install -y lsof
fi

# curl para downloads
if ! command_exists curl; then
    print_status "Instalando curl..."
    sudo apt install -y curl
fi

# git para controle de versão
if ! command_exists git; then
    print_status "Instalando git..."
    sudo apt install -y git
fi

# build-essential para compilação
if ! dpkg -l | grep -q "^ii  build-essential "; then
    print_status "Instalando build-essential..."
    sudo apt install -y build-essential
fi

# make para Makefile
if ! command_exists make; then
    print_status "Instalando make..."
    sudo apt install -y make
fi

# Verificar versões finais
print_header "📊 Versões Instaladas:"
print_status "Node.js: $(node --version)"
print_status "npm: $(npm --version)"
print_status "Java: $(java -version 2>&1 | head -n 1)"
print_status "Git: $(git --version)"
print_status "Make: $(make --version | head -n 1)"

# Verificar se as portas necessárias estão livres
print_status "Verificando portas..."
if lsof -i :3000 >/dev/null 2>&1; then
    print_warning "Porta 3000 está em uso. Pode ser necessário parar outros serviços."
fi

if lsof -i :8080 >/dev/null 2>&1; then
    print_warning "Porta 8080 está em uso. Pode ser necessário parar outros serviços."
fi

print_header "✅ Instalação Concluída!"
print_header "=================================================="

print_success "Todas as dependências foram instaladas com sucesso!"
echo ""
echo -e "${CYAN}Próximos passos:${NC}"
echo -e "1. ${YELLOW}Execute o script de desenvolvimento:${NC} ./start-dev.sh"
echo -e "2. ${YELLOW}Ou configure manualmente:${NC}"
echo -e "   • Backend: cd kotlin-api && ./gradlew bootRun"
echo -e "   • Frontend: cd ecommerce-app && npm start"
echo ""
echo -e "${CYAN}URLs que estarão disponíveis:${NC}"
echo -e "• ${GREEN}Backend API:${NC} http://localhost:8080"
echo -e "• ${GREEN}Aplicação Web:${NC} http://localhost:3000"
echo -e "• ${GREEN}Interface Demo:${NC} http://localhost:3000/index.html"
echo ""
echo -e "${CYAN}Comandos úteis:${NC}"
echo -e "• ${YELLOW}Verificar portas em uso:${NC} lsof -i :3000,8080"
echo -e "• ${YELLOW}Matar processo na porta:${NC} sudo kill -9 \$(lsof -ti :3000)"
echo -e "• ${YELLOW}Ver logs do sistema:${NC} journalctl -f"
echo ""
print_success "Ambiente pronto para desenvolvimento! 🚀"

# Perguntar se quer iniciar o ambiente
echo ""
read -p "Deseja iniciar o ambiente de desenvolvimento agora? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "Iniciando ambiente de desenvolvimento..."
    ./start-dev.sh
fi

#!/bin/bash

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

# Função para verificar se uma porta está em uso
port_in_use() {
    lsof -i :$1 >/dev/null 2>&1
}

# Função para aguardar uma porta ficar disponível
wait_for_port() {
    local port=$1
    local service=$2
    local timeout=30
    local count=0
    
    print_status "Aguardando $service na porta $port..."
    while port_in_use $port && [ $count -lt $timeout ]; do
        sleep 1
        count=$((count + 1))
        echo -n "."
    done
    echo ""
    
    if [ $count -eq $timeout ]; then
        print_error "Timeout aguardando $service na porta $port"
        return 1
    fi
    return 0
}

# Função para matar processos em portas específicas
kill_port() {
    local port=$1
    local pids=$(lsof -ti :$port)
    if [ ! -z "$pids" ]; then
        print_warning "Matando processos na porta $port: $pids"
        echo $pids | xargs kill -9 2>/dev/null || true
        sleep 2
    fi
}

print_header "🚀 SDK AntiFraud - Ambiente de Desenvolvimento Ubuntu"
print_header "=================================================="

# Verificar dependências do sistema
print_status "Verificando dependências do sistema..."

if ! command_exists node; then
    print_error "Node.js não encontrado. Instale com: sudo apt update && sudo apt install nodejs npm"
    exit 1
fi

if ! command_exists npm; then
    print_error "npm não encontrado. Instale com: sudo apt update && sudo apt install npm"
    exit 1
fi

if ! command_exists java; then
    print_error "Java não encontrado. Instale com: sudo apt update && sudo apt install openjdk-17-jdk"
    exit 1
fi

print_success "Dependências do sistema verificadas"

# Verificar versões
NODE_VERSION=$(node --version)
NPM_VERSION=$(npm --version)
JAVA_VERSION=$(java -version 2>&1 | head -n 1)

print_status "Node.js: $NODE_VERSION"
print_status "npm: $NPM_VERSION"
print_status "Java: $JAVA_VERSION"

# Limpar portas se necessário
print_status "Verificando portas..."
kill_port 3000
kill_port 8080

# Verificar e instalar dependências do SDK
print_status "Verificando dependências do SDK..."
if [ ! -d "sdk-antifraude/node_modules" ]; then
    print_status "Instalando dependências do SDK..."
    cd sdk-antifraude
    npm install
    if [ $? -ne 0 ]; then
        print_error "Falha ao instalar dependências do SDK"
        exit 1
    fi
    cd ..
    print_success "Dependências do SDK instaladas"
else
    print_success "Dependências do SDK já instaladas"
fi

# Verificar e instalar dependências da aplicação de exemplo
print_status "Verificando dependências da aplicação de exemplo..."
if [ ! -d "ecommerce-app/node_modules" ]; then
    print_status "Instalando dependências da aplicação de exemplo..."
    cd ecommerce-app
    npm install
    if [ $? -ne 0 ]; then
        print_error "Falha ao instalar dependências da aplicação de exemplo"
        exit 1
    fi
    cd ..
    print_success "Dependências da aplicação de exemplo instaladas"
else
    print_success "Dependências da aplicação de exemplo já instaladas"
fi

# Build do SDK
print_status "Compilando SDK..."
cd sdk-antifraude
npm run build
if [ $? -ne 0 ]; then
    print_error "Falha ao compilar o SDK"
    exit 1
fi
cd ..
print_success "SDK compilado com sucesso"

# Verificar se o Gradle wrapper tem permissão de execução
print_status "Configurando Gradle wrapper..."
chmod +x kotlin-api/gradlew
print_success "Gradle wrapper configurado"

print_header "🎯 Ambiente configurado com sucesso!"
print_header "=================================================="

# Função para iniciar serviços
start_services() {
    print_header "🚀 Iniciando serviços..."
    
    # Iniciar backend Kotlin em background
    print_status "Iniciando backend Kotlin (porta 8080)..."
    cd kotlin-api
    ./gradlew bootRun > ../kotlin-api.log 2>&1 &
    KOTLIN_PID=$!
    cd ..
    
    # Aguardar backend ficar disponível
    if wait_for_port 8080 "Backend Kotlin"; then
        print_success "Backend Kotlin iniciado (PID: $KOTLIN_PID)"
    else
        print_error "Falha ao iniciar Backend Kotlin"
        return 1
    fi
    
    # Iniciar aplicação Node.js em background
    print_status "Iniciando aplicação Node.js (porta 3000)..."
    cd ecommerce-app
    npm start > ../ecommerce-app.log 2>&1 &
    NODE_PID=$!
    cd ..
    
    # Aguardar aplicação ficar disponível
    if wait_for_port 3000 "Aplicação Node.js"; then
        print_success "Aplicação Node.js iniciada (PID: $NODE_PID)"
    else
        print_error "Falha ao iniciar Aplicação Node.js"
        return 1
    fi
    
    print_header "✅ Todos os serviços iniciados!"
    print_header "=================================================="
    echo -e "${CYAN}📊 URLs disponíveis:${NC}"
    echo -e "  ${GREEN}• Backend API:${NC} http://localhost:8080"
    echo -e "  ${GREEN}• Aplicação Web:${NC} http://localhost:3000"
    echo -e "  ${GREEN}• Interface Demo:${NC} http://localhost:3000/index.html"
    echo ""
    echo -e "${CYAN}🎯 Teste as rotas:${NC}"
    echo -e "  ${YELLOW}• GET /checkout-ip${NC} (verificação de IP)"
    echo -e "  ${YELLOW}• GET /checkout-advanced${NC} (verificação avançada)"
    echo -e "  ${YELLOW}• POST /api/verify${NC} (verificação manual)"
    echo ""
    echo -e "${CYAN}📝 Logs:${NC}"
    echo -e "  ${YELLOW}• Backend:${NC} tail -f kotlin-api.log"
    echo -e "  ${YELLOW}• Frontend:${NC} tail -f ecommerce-app.log"
    echo ""
    echo -e "${CYAN}🛑 Para parar os serviços:${NC}"
    echo -e "  ${YELLOW}• kill $KOTLIN_PID $NODE_PID${NC}"
    echo -e "  ${YELLOW}• ou use Ctrl+C${NC}"
    
    # Salvar PIDs para cleanup
    echo "$KOTLIN_PID $NODE_PID" > .pids
    
    # Função de cleanup
    cleanup() {
        print_status "Parando serviços..."
        if [ -f .pids ]; then
            read KOTLIN_PID NODE_PID < .pids
            kill $KOTLIN_PID $NODE_PID 2>/dev/null || true
            rm .pids
        fi
        kill_port 3000
        kill_port 8080
        print_success "Serviços parados"
        exit 0
    }
    
    # Capturar Ctrl+C
    trap cleanup SIGINT SIGTERM
    
    # Manter script rodando
    print_status "Pressione Ctrl+C para parar os serviços..."
    while true; do
        sleep 1
    done
}

# Menu interativo
print_header "Escolha uma opção:"
echo "1) Iniciar todos os serviços automaticamente"
echo "2) Apenas configurar ambiente (não iniciar serviços)"
echo "3) Verificar status dos serviços"
echo "4) Parar todos os serviços"
echo "5) Sair"

read -p "Digite sua escolha (1-5): " choice

case $choice in
    1)
        start_services
        ;;
    2)
        print_success "Ambiente configurado! Para iniciar os serviços:"
        echo "  Backend: cd kotlin-api && ./gradlew bootRun"
        echo "  Frontend: cd ecommerce-app && npm start"
        ;;
    3)
        print_status "Verificando status dos serviços..."
        if port_in_use 8080; then
            print_success "Backend Kotlin está rodando na porta 8080"
        else
            print_warning "Backend Kotlin não está rodando"
        fi
        
        if port_in_use 3000; then
            print_success "Aplicação Node.js está rodando na porta 3000"
        else
            print_warning "Aplicação Node.js não está rodando"
        fi
        ;;
    4)
        print_status "Parando todos os serviços..."
        kill_port 3000
        kill_port 8080
        if [ -f .pids ]; then
            read KOTLIN_PID NODE_PID < .pids
            kill $KOTLIN_PID $NODE_PID 2>/dev/null || true
            rm .pids
        fi
        print_success "Serviços parados"
        ;;
    5)
        print_success "Saindo..."
        exit 0
        ;;
    *)
        print_error "Opção inválida"
        exit 1
        ;;
esac

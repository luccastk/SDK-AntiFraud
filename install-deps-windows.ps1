# SDK AntiFraud - Instalador de Dependências para Windows
# Execute como: PowerShell -ExecutionPolicy Bypass -File install-deps-windows.ps1

param(
    [switch]$Force
)

# Cores para output
$Colors = @{
    Red = "Red"
    Green = "Green"
    Yellow = "Yellow"
    Blue = "Cyan"
    Purple = "Magenta"
    Cyan = "Cyan"
}

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Write-Status {
    param([string]$Message)
    Write-ColorOutput "[INFO] $Message" $Colors.Blue
}

function Write-Success {
    param([string]$Message)
    Write-ColorOutput "[SUCCESS] $Message" $Colors.Green
}

function Write-Warning {
    param([string]$Message)
    Write-ColorOutput "[WARNING] $Message" $Colors.Yellow
}

function Write-Error {
    param([string]$Message)
    Write-ColorOutput "[ERROR] $Message" $Colors.Red
}

function Write-Header {
    param([string]$Message)
    Write-ColorOutput $Message $Colors.Purple
}

# Função para verificar se um comando existe
function Test-Command {
    param([string]$Command)
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

# Função para verificar se uma porta está em uso
function Test-Port {
    param([int]$Port)
    try {
        $connection = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
        return $connection -ne $null
    }
    catch {
        return $false
    }
}

Write-Header "🔧 Instalador de Dependências - SDK AntiFraud Windows"
Write-Header "=================================================="

# Verificar se está rodando como administrador
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Write-Warning "Este script precisa ser executado como Administrador"
    Write-Status "Clique com botão direito no PowerShell e selecione 'Executar como administrador'"
    Write-Status "Ou execute: Start-Process PowerShell -Verb RunAs"
    exit 1
}

Write-Status "Verificando dependências do sistema..."

# Verificar Chocolatey
Write-Status "Verificando Chocolatey..."
if (-not (Test-Command "choco")) {
    Write-Status "Instalando Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    
    if (-not (Test-Command "choco")) {
        Write-Error "Falha ao instalar Chocolatey"
        exit 1
    }
    Write-Success "Chocolatey instalado"
} else {
    Write-Success "Chocolatey já instalado"
}

# Instalar Node.js
Write-Status "Verificando Node.js..."
if (-not (Test-Command "node")) {
    Write-Status "Instalando Node.js..."
    choco install nodejs -y
    if (-not (Test-Command "node")) {
        Write-Error "Falha ao instalar Node.js"
        exit 1
    }
    Write-Success "Node.js instalado"
} else {
    $nodeVersion = node --version
    Write-Success "Node.js já instalado: $nodeVersion"
}

# Verificar npm
if (-not (Test-Command "npm")) {
    Write-Status "Instalando npm..."
    choco install npm -y
    Write-Success "npm instalado"
} else {
    $npmVersion = npm --version
    Write-Success "npm já instalado: $npmVersion"
}

# Instalar Java
Write-Status "Verificando Java..."
if (-not (Test-Command "java")) {
    Write-Status "Instalando OpenJDK 17..."
    choco install openjdk17 -y
    
    # Configurar JAVA_HOME
    $javaHome = "C:\Program Files\Eclipse Adoptium\jdk-17.0.9.9-hotspot"
    if (Test-Path $javaHome) {
        [Environment]::SetEnvironmentVariable("JAVA_HOME", $javaHome, "Machine")
        $env:JAVA_HOME = $javaHome
        Write-Success "JAVA_HOME configurado: $javaHome"
    }
    
    if (-not (Test-Command "java")) {
        Write-Error "Falha ao instalar Java"
        exit 1
    }
    Write-Success "Java instalado"
} else {
    $javaVersion = java -version 2>&1 | Select-Object -First 1
    Write-Success "Java já instalado: $javaVersion"
}

# Instalar ferramentas úteis
Write-Status "Instalando ferramentas de desenvolvimento..."

# Git
if (-not (Test-Command "git")) {
    Write-Status "Instalando Git..."
    choco install git -y
    Write-Success "Git instalado"
} else {
    $gitVersion = git --version
    Write-Success "Git já instalado: $gitVersion"
}

# Visual Studio Build Tools (para compilação nativa)
Write-Status "Verificando Visual Studio Build Tools..."
$vsBuildTools = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*Visual Studio*Build Tools*" }
if (-not $vsBuildTools) {
    Write-Status "Instalando Visual Studio Build Tools..."
    choco install visualstudio2022buildtools -y
    Write-Success "Visual Studio Build Tools instalado"
} else {
    Write-Success "Visual Studio Build Tools já instalado"
}

# PowerShell Core (opcional)
Write-Status "Verificando PowerShell Core..."
if (-not (Test-Command "pwsh")) {
    Write-Status "Instalando PowerShell Core..."
    choco install powershell-core -y
    Write-Success "PowerShell Core instalado"
} else {
    Write-Success "PowerShell Core já instalado"
}

# Verificar versões finais
Write-Header "📊 Versões Instaladas:"
$nodeVersion = node --version
$npmVersion = npm --version
$javaVersion = java -version 2>&1 | Select-Object -First 1
$gitVersion = git --version

Write-Status "Node.js: $nodeVersion"
Write-Status "npm: $npmVersion"
Write-Status "Java: $javaVersion"
Write-Status "Git: $gitVersion"

# Verificar se as portas necessárias estão livres
Write-Status "Verificando portas..."
if (Test-Port 3000) {
    Write-Warning "Porta 3000 está em uso. Pode ser necessário parar outros serviços."
}

if (Test-Port 8080) {
    Write-Warning "Porta 8080 está em uso. Pode ser necessário parar outros serviços."
}

# Configurar permissões de execução
Write-Status "Configurando permissões de execução..."
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
Write-Success "Política de execução configurada"

Write-Header "✅ Instalação Concluída!"
Write-Header "=================================================="

Write-Success "Todas as dependências foram instaladas com sucesso!"
Write-Host ""
Write-ColorOutput "Próximos passos:" $Colors.Cyan
Write-ColorOutput "1. Execute o script de desenvolvimento: .\start-dev.ps1" $Colors.Yellow
Write-ColorOutput "2. Ou configure manualmente:" $Colors.Yellow
Write-ColorOutput "   • Backend: cd kotlin-api; .\gradlew.bat bootRun" $Colors.Yellow
Write-ColorOutput "   • Frontend: cd ecommerce-app; npm start" $Colors.Yellow
Write-Host ""
Write-ColorOutput "URLs que estarão disponíveis:" $Colors.Cyan
Write-ColorOutput "• Backend API: http://localhost:8080" $Colors.Green
Write-ColorOutput "• Aplicação Web: http://localhost:3000" $Colors.Green
Write-ColorOutput "• Interface Demo: http://localhost:3000/index.html" $Colors.Green
Write-Host ""
Write-ColorOutput "Comandos úteis:" $Colors.Cyan
Write-ColorOutput "• Verificar portas em uso: netstat -an | findstr :3000" $Colors.Yellow
Write-ColorOutput "• Matar processo na porta: netstat -ano | findstr :3000" $Colors.Yellow
Write-ColorOutput "• Ver logs do sistema: Get-EventLog -LogName Application" $Colors.Yellow
Write-Host ""
Write-Success "Ambiente pronto para desenvolvimento! 🚀"

# Pausar para o usuário ler
Write-Host ""
Write-Host "Pressione qualquer tecla para continuar..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

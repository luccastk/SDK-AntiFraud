# SDK AntiFraud - Ambiente de Desenvolvimento Windows
# Execute como: PowerShell -ExecutionPolicy Bypass -File start-dev.ps1

param(
    [switch]$AutoStart
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

# Função para aguardar uma porta ficar disponível
function Wait-ForPort {
    param(
        [int]$Port,
        [string]$Service,
        [int]$TimeoutSeconds = 30
    )
    
    Write-Status "Aguardando $Service na porta $Port..."
    $count = 0
    while ((Test-Port $Port) -and ($count -lt $TimeoutSeconds)) {
        Start-Sleep -Seconds 1
        $count++
        Write-Host "." -NoNewline
    }
    Write-Host ""
    
    if ($count -eq $TimeoutSeconds) {
        Write-Error "Timeout aguardando $Service na porta $Port"
        return $false
    }
    return $true
}

# Função para matar processos em portas específicas
function Stop-Port {
    param([int]$Port)
    
    try {
        $processes = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue | 
                    Select-Object -ExpandProperty OwningProcess | 
                    Sort-Object -Unique
        
        if ($processes) {
            Write-Warning "Matando processos na porta $Port : $($processes -join ', ')"
            $processes | ForEach-Object { 
                try { 
                    Stop-Process -Id $_ -Force -ErrorAction SilentlyContinue 
                } catch { }
            }
            Start-Sleep -Seconds 2
        }
    }
    catch {
        # Ignorar erros
    }
}

Write-Header "🚀 SDK AntiFraud - Ambiente de Desenvolvimento Windows"
Write-Header "=================================================="

# Verificar dependências do sistema
Write-Status "Verificando dependências do sistema..."

if (-not (Test-Command "node")) {
    Write-Error "Node.js não encontrado. Execute: .\install-deps-windows.ps1"
    exit 1
}

if (-not (Test-Command "npm")) {
    Write-Error "npm não encontrado. Execute: .\install-deps-windows.ps1"
    exit 1
}

if (-not (Test-Command "java")) {
    Write-Error "Java não encontrado. Execute: .\install-deps-windows.ps1"
    exit 1
}

Write-Success "Dependências do sistema verificadas"

# Verificar versões
$nodeVersion = node --version
$npmVersion = npm --version
$javaVersion = java -version 2>&1 | Select-Object -First 1

Write-Status "Node.js: $nodeVersion"
Write-Status "npm: $npmVersion"
Write-Status "Java: $javaVersion"

# Limpar portas se necessário
Write-Status "Verificando portas..."
Stop-Port 3000
Stop-Port 8080

# Verificar e instalar dependências do SDK
Write-Status "Verificando dependências do SDK..."
if (-not (Test-Path "sdk-antifraude\node_modules")) {
    Write-Status "Instalando dependências do SDK..."
    Set-Location "sdk-antifraude"
    npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Falha ao instalar dependências do SDK"
        exit 1
    }
    Set-Location ".."
    Write-Success "Dependências do SDK instaladas"
} else {
    Write-Success "Dependências do SDK já instaladas"
}

# Verificar e instalar dependências da aplicação de exemplo
Write-Status "Verificando dependências da aplicação de exemplo..."
if (-not (Test-Path "ecommerce-app\node_modules")) {
    Write-Status "Instalando dependências da aplicação de exemplo..."
    Set-Location "ecommerce-app"
    npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Falha ao instalar dependências da aplicação de exemplo"
        exit 1
    }
    Set-Location ".."
    Write-Success "Dependências da aplicação de exemplo instaladas"
} else {
    Write-Success "Dependências da aplicação de exemplo já instaladas"
}

# Build do SDK
Write-Status "Compilando SDK..."
Set-Location "sdk-antifraude"
npm run build
if ($LASTEXITCODE -ne 0) {
    Write-Error "Falha ao compilar o SDK"
    exit 1
}
Set-Location ".."
Write-Success "SDK compilado com sucesso"

# Verificar se o Gradle wrapper tem permissão de execução
Write-Status "Configurando Gradle wrapper..."
if (Test-Path "kotlin-api\gradlew.bat") {
    Write-Success "Gradle wrapper configurado"
} else {
    Write-Warning "Gradle wrapper não encontrado"
}

Write-Header "🎯 Ambiente configurado com sucesso!"
Write-Header "=================================================="

# Variáveis globais para processos
$Global:KotlinProcess = $null
$Global:NodeProcess = $null

# Função para iniciar serviços
function Start-Services {
    Write-Header "🚀 Iniciando serviços..."
    
    # Iniciar backend Kotlin em background
    Write-Status "Iniciando backend Kotlin (porta 8080)..."
    Set-Location "kotlin-api"
    $Global:KotlinProcess = Start-Process -FilePath ".\gradlew.bat" -ArgumentList "bootRun" -PassThru -WindowStyle Hidden
    Set-Location ".."
    
    # Aguardar backend ficar disponível
    if (Wait-ForPort 8080 "Backend Kotlin") {
        Write-Success "Backend Kotlin iniciado (PID: $($Global:KotlinProcess.Id))"
    } else {
        Write-Error "Falha ao iniciar Backend Kotlin"
        return $false
    }
    
    # Iniciar aplicação Node.js em background
    Write-Status "Iniciando aplicação Node.js (porta 3000)..."
    Set-Location "ecommerce-app"
    $Global:NodeProcess = Start-Process -FilePath "npm" -ArgumentList "start" -PassThru -WindowStyle Hidden
    Set-Location ".."
    
    # Aguardar aplicação ficar disponível
    if (Wait-ForPort 3000 "Aplicação Node.js") {
        Write-Success "Aplicação Node.js iniciada (PID: $($Global:NodeProcess.Id))"
    } else {
        Write-Error "Falha ao iniciar Aplicação Node.js"
        return $false
    }
    
    Write-Header "✅ Todos os serviços iniciados!"
    Write-Header "=================================================="
    Write-ColorOutput "📊 URLs disponíveis:" $Colors.Cyan
    Write-ColorOutput "  • Backend API: http://localhost:8080" $Colors.Green
    Write-ColorOutput "  • Aplicação Web: http://localhost:3000" $Colors.Green
    Write-ColorOutput "  • Interface Demo: http://localhost:3000/index.html" $Colors.Green
    Write-Host ""
    Write-ColorOutput "🎯 Teste as rotas:" $Colors.Cyan
    Write-ColorOutput "  • GET /checkout-ip (verificação de IP)" $Colors.Yellow
    Write-ColorOutput "  • GET /checkout-advanced (verificação avançada)" $Colors.Yellow
    Write-ColorOutput "  • POST /api/verify (verificação manual)" $Colors.Yellow
    Write-Host ""
    Write-ColorOutput "🛑 Para parar os serviços:" $Colors.Cyan
    Write-ColorOutput "  • Pressione Ctrl+C" $Colors.Yellow
    Write-ColorOutput "  • Ou execute: .\stop-services.ps1" $Colors.Yellow
    
    # Salvar PIDs para cleanup
    @{
        KotlinPID = $Global:KotlinProcess.Id
        NodePID = $Global:NodeProcess.Id
    } | ConvertTo-Json | Out-File -FilePath ".pids.json" -Encoding UTF8
    
    return $true
}

# Função de cleanup
function Stop-Services {
    Write-Status "Parando serviços..."
    
    if ($Global:KotlinProcess -and !$Global:KotlinProcess.HasExited) {
        $Global:KotlinProcess.Kill()
        Write-Success "Backend Kotlin parado"
    }
    
    if ($Global:NodeProcess -and !$Global:NodeProcess.HasExited) {
        $Global:NodeProcess.Kill()
        Write-Success "Aplicação Node.js parada"
    }
    
    Stop-Port 3000
    Stop-Port 8080
    
    if (Test-Path ".pids.json") {
        Remove-Item ".pids.json" -Force
    }
    
    Write-Success "Serviços parados"
}

# Capturar Ctrl+C
$null = Register-EngineEvent PowerShell.Exiting -Action {
    Stop-Services
}

# Menu interativo
if (-not $AutoStart) {
    Write-Header "Escolha uma opção:"
    Write-Host "1) Iniciar todos os serviços automaticamente"
    Write-Host "2) Apenas configurar ambiente (não iniciar serviços)"
    Write-Host "3) Verificar status dos serviços"
    Write-Host "4) Parar todos os serviços"
    Write-Host "5) Sair"
    
    $choice = Read-Host "Digite sua escolha (1-5)"
    
    switch ($choice) {
        "1" {
            if (Start-Services) {
                Write-Status "Pressione Ctrl+C para parar os serviços..."
                try {
                    while ($true) {
                        Start-Sleep -Seconds 1
                    }
                }
                catch {
                    Stop-Services
                }
            }
        }
        "2" {
            Write-Success "Ambiente configurado! Para iniciar os serviços:"
            Write-Host "  Backend: cd kotlin-api; .\gradlew.bat bootRun"
            Write-Host "  Frontend: cd ecommerce-app; npm start"
        }
        "3" {
            Write-Status "Verificando status dos serviços..."
            if (Test-Port 8080) {
                Write-Success "Backend Kotlin está rodando na porta 8080"
            } else {
                Write-Warning "Backend Kotlin não está rodando"
            }
            
            if (Test-Port 3000) {
                Write-Success "Aplicação Node.js está rodando na porta 3000"
            } else {
                Write-Warning "Aplicação Node.js não está rodando"
            }
        }
        "4" {
            Write-Status "Parando todos os serviços..."
            Stop-Services
        }
        "5" {
            Write-Success "Saindo..."
            exit 0
        }
        default {
            Write-Error "Opção inválida"
            exit 1
        }
    }
} else {
    # Modo automático
    if (Start-Services) {
        Write-Status "Pressione Ctrl+C para parar os serviços..."
        try {
            while ($true) {
                Start-Sleep -Seconds 1
            }
        }
        catch {
            Stop-Services
        }
    }
}

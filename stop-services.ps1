# SDK AntiFraud - Parar Serviços Windows
# Execute como: PowerShell -ExecutionPolicy Bypass -File stop-services.ps1

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

Write-Header "🛑 SDK AntiFraud - Parando Serviços"
Write-Header "=================================================="

Write-Status "Parando todos os serviços do SDK AntiFraud..."

# Parar processos específicos
Write-Status "Parando processos do Gradle..."
Get-Process | Where-Object { $_.ProcessName -like "*java*" -and $_.CommandLine -like "*gradle*" } | 
    ForEach-Object { 
        Write-Warning "Matando processo Gradle: $($_.Id)"
        Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue 
    }

Write-Status "Parando processos do Node.js..."
Get-Process | Where-Object { $_.ProcessName -eq "node" } | 
    ForEach-Object { 
        Write-Warning "Matando processo Node.js: $($_.Id)"
        Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue 
    }

# Parar processos nas portas específicas
Write-Status "Limpando portas 3000 e 8080..."
Stop-Port 3000
Stop-Port 8080

# Verificar se ainda há processos rodando
Start-Sleep -Seconds 3

if (Test-Port 3000) {
    Write-Warning "Ainda há processos na porta 3000"
} else {
    Write-Success "Porta 3000 liberada"
}

if (Test-Port 8080) {
    Write-Warning "Ainda há processos na porta 8080"
} else {
    Write-Success "Porta 8080 liberada"
}

# Limpar arquivos temporários
if (Test-Path ".pids.json") {
    Remove-Item ".pids.json" -Force
    Write-Success "Arquivo de PIDs removido"
}

Write-Header "✅ Todos os serviços foram parados!"
Write-Header "=================================================="

Write-Success "Ambiente limpo e pronto para nova inicialização"
Write-Host ""
Write-ColorOutput "Para reiniciar os serviços:" $Colors.Cyan
Write-ColorOutput "• Execute: .\start-dev.ps1" $Colors.Yellow
Write-ColorOutput "• Ou use o Makefile: make start" $Colors.Yellow

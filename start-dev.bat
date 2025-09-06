@echo off
setlocal enabledelayedexpansion

REM SDK AntiFraud - Ambiente de Desenvolvimento Windows (Batch)
REM Execute como: start-dev.bat

title SDK AntiFraud - Ambiente de Desenvolvimento

echo.
echo ==================================================
echo 🚀 SDK AntiFraud - Ambiente de Desenvolvimento Windows
echo ==================================================
echo.

REM Verificar dependências do sistema
echo [INFO] Verificando dependências do sistema...

where node >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Node.js não encontrado. Execute: install-deps-windows.ps1
    pause
    exit /b 1
)

where npm >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] npm não encontrado. Execute: install-deps-windows.ps1
    pause
    exit /b 1
)

where java >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Java não encontrado. Execute: install-deps-windows.ps1
    pause
    exit /b 1
)

echo [SUCCESS] Dependências do sistema verificadas

REM Verificar versões
for /f "tokens=*" %%i in ('node --version') do set NODE_VERSION=%%i
for /f "tokens=*" %%i in ('npm --version') do set NPM_VERSION=%%i
for /f "tokens=*" %%i in ('java -version 2^>^&1 ^| findstr /r "version"') do set JAVA_VERSION=%%i

echo [INFO] Node.js: %NODE_VERSION%
echo [INFO] npm: %NPM_VERSION%
echo [INFO] Java: %JAVA_VERSION%

REM Limpar portas se necessário
echo [INFO] Verificando portas...
call :kill_port 3000
call :kill_port 8080

REM Verificar e instalar dependências do SDK
echo [INFO] Verificando dependências do SDK...
if not exist "sdk-antifraude\node_modules" (
    echo [INFO] Instalando dependências do SDK...
    cd sdk-antifraude
    call npm install
    if %errorlevel% neq 0 (
        echo [ERROR] Falha ao instalar dependências do SDK
        pause
        exit /b 1
    )
    cd ..
    echo [SUCCESS] Dependências do SDK instaladas
) else (
    echo [SUCCESS] Dependências do SDK já instaladas
)

REM Verificar e instalar dependências da aplicação de exemplo
echo [INFO] Verificando dependências da aplicação de exemplo...
if not exist "ecommerce-app\node_modules" (
    echo [INFO] Instalando dependências da aplicação de exemplo...
    cd ecommerce-app
    call npm install
    if %errorlevel% neq 0 (
        echo [ERROR] Falha ao instalar dependências da aplicação de exemplo
        pause
        exit /b 1
    )
    cd ..
    echo [SUCCESS] Dependências da aplicação de exemplo instaladas
) else (
    echo [SUCCESS] Dependências da aplicação de exemplo já instaladas
)

REM Build do SDK
echo [INFO] Compilando SDK...
cd sdk-antifraude
call npm run build
if %errorlevel% neq 0 (
    echo [ERROR] Falha ao compilar o SDK
    pause
    exit /b 1
)
cd ..
echo [SUCCESS] SDK compilado com sucesso

REM Verificar se o Gradle wrapper existe
echo [INFO] Configurando Gradle wrapper...
if exist "kotlin-api\gradlew.bat" (
    echo [SUCCESS] Gradle wrapper configurado
) else (
    echo [WARNING] Gradle wrapper não encontrado
)

echo.
echo ==================================================
echo 🎯 Ambiente configurado com sucesso!
echo ==================================================
echo.

REM Menu interativo
:menu
echo Escolha uma opção:
echo 1) Iniciar todos os serviços automaticamente
echo 2) Apenas configurar ambiente (não iniciar serviços)
echo 3) Verificar status dos serviços
echo 4) Parar todos os serviços
echo 5) Sair
echo.
set /p choice="Digite sua escolha (1-5): "

if "%choice%"=="1" goto start_services
if "%choice%"=="2" goto config_only
if "%choice%"=="3" goto check_status
if "%choice%"=="4" goto stop_services
if "%choice%"=="5" goto exit_script
echo [ERROR] Opção inválida
goto menu

:start_services
echo.
echo ==================================================
echo 🚀 Iniciando serviços...
echo ==================================================

echo [INFO] Iniciando backend Kotlin (porta 8080)...
cd kotlin-api
start "Backend Kotlin" /min cmd /c "gradlew.bat bootRun"
cd ..
echo [SUCCESS] Backend Kotlin iniciado

echo [INFO] Aguardando backend ficar disponível...
timeout /t 10 /nobreak >nul

echo [INFO] Iniciando aplicação Node.js (porta 3000)...
cd ecommerce-app
start "Frontend Node.js" /min cmd /c "npm start"
cd ..
echo [SUCCESS] Aplicação Node.js iniciada

echo.
echo ==================================================
echo ✅ Todos os serviços iniciados!
echo ==================================================
echo.
echo 📊 URLs disponíveis:
echo   • Backend API: http://localhost:8080
echo   • Aplicação Web: http://localhost:3000
echo   • Interface Demo: http://localhost:3000/index.html
echo.
echo 🎯 Teste as rotas:
echo   • GET /checkout-ip (verificação de IP)
echo   • GET /checkout-advanced (verificação avançada)
echo   • POST /api/verify (verificação manual)
echo.
echo 🛑 Para parar os serviços:
echo   • Feche as janelas dos serviços
echo   • Ou execute: stop-services.bat
echo.
pause
goto menu

:config_only
echo.
echo [SUCCESS] Ambiente configurado! Para iniciar os serviços:
echo   Backend: cd kotlin-api ^&^& gradlew.bat bootRun
echo   Frontend: cd ecommerce-app ^&^& npm start
echo.
pause
goto menu

:check_status
echo.
echo [INFO] Verificando status dos serviços...
call :check_port 8080 "Backend Kotlin"
call :check_port 3000 "Aplicação Node.js"
echo.
pause
goto menu

:stop_services
echo.
echo [INFO] Parando todos os serviços...
call :kill_port 3000
call :kill_port 8080
echo [SUCCESS] Serviços parados
echo.
pause
goto menu

:exit_script
echo.
echo [SUCCESS] Saindo...
exit /b 0

REM Função para verificar se uma porta está em uso
:check_port
set port=%1
set service=%2
netstat -an | findstr ":%port% " >nul
if %errorlevel% equ 0 (
    echo [SUCCESS] %service% está rodando na porta %port%
) else (
    echo [WARNING] %service% não está rodando
)
goto :eof

REM Função para matar processos em uma porta
:kill_port
set port=%1
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":%port% "') do (
    if not "%%a"=="0" (
        echo [WARNING] Matando processo %%a na porta %port%
        taskkill /PID %%a /F >nul 2>&1
    )
)
goto :eof

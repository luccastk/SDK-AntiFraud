# 🪟 SDK AntiFraud - Setup para Windows

Este guia fornece instruções detalhadas para configurar e executar o SDK AntiFraud no Windows.

## 📋 Pré-requisitos

- Windows 10/11
- PowerShell 5.1 ou superior
- Acesso de administrador (para instalação de dependências)

## 🚀 Instalação Rápida

### 1. Instalar Dependências do Sistema

Execute o PowerShell como **Administrador** e execute:

```powershell
# Baixar e executar o instalador
PowerShell -ExecutionPolicy Bypass -File install-deps-windows.ps1
```

Este script irá instalar:
- ✅ Node.js (versão mais recente)
- ✅ npm
- ✅ OpenJDK 17
- ✅ Git
- ✅ Visual Studio Build Tools
- ✅ Chocolatey (gerenciador de pacotes)

### 2. Iniciar Ambiente de Desenvolvimento

Após a instalação, execute:

```powershell
# Opção 1: PowerShell (Recomendado)
PowerShell -ExecutionPolicy Bypass -File start-dev.ps1

# Opção 2: Batch
start-dev.bat
```

## 🛠️ Instalação Manual

Se preferir instalar manualmente:

### Node.js
1. Baixe do [nodejs.org](https://nodejs.org/)
2. Execute o instalador
3. Verifique: `node --version`

### Java
1. Baixe OpenJDK 17 do [Adoptium](https://adoptium.net/)
2. Configure JAVA_HOME
3. Verifique: `java -version`

### Git
1. Baixe do [git-scm.com](https://git-scm.com/)
2. Execute o instalador
3. Verifique: `git --version`

## 🎯 Comandos Disponíveis

### Scripts PowerShell

| Script | Descrição |
|--------|-----------|
| `install-deps-windows.ps1` | Instala todas as dependências do sistema |
| `start-dev.ps1` | Inicia ambiente completo de desenvolvimento |
| `stop-services.ps1` | Para todos os serviços |

### Scripts Batch

| Script | Descrição |
|--------|-----------|
| `start-dev.bat` | Inicia ambiente completo de desenvolvimento |

### Makefile Windows

```cmd
# Ver todos os comandos
make -f Makefile.windows help

# Setup completo
make -f Makefile.windows dev

# Início rápido
make -f Makefile.windows quick-start

# Parar serviços
make -f Makefile.windows stop

# Verificar status
make -f Makefile.windows status
```

## 🔧 Configuração Avançada

### Política de Execução PowerShell

Se encontrar erros de política de execução:

```powershell
# Verificar política atual
Get-ExecutionPolicy

# Configurar para usuário atual
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Ou executar com bypass
PowerShell -ExecutionPolicy Bypass -File script.ps1
```

### Variáveis de Ambiente

Configure as seguintes variáveis se necessário:

```cmd
# JAVA_HOME
set JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-17.0.9.9-hotspot

# Adicionar ao PATH
set PATH=%PATH%;%JAVA_HOME%\bin
```

### Portas

O SDK usa as seguintes portas:
- **3000**: Aplicação Node.js
- **8080**: Backend Kotlin

Para verificar se estão em uso:

```cmd
netstat -an | findstr ":3000\|:8080"
```

## 🐛 Solução de Problemas

### Erro: "Execution Policy"
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Erro: "Java não encontrado"
```powershell
# Verificar se Java está instalado
java -version

# Se não estiver, reinstalar
choco install openjdk17 -y
```

### Erro: "Node.js não encontrado"
```powershell
# Verificar se Node.js está instalado
node --version

# Se não estiver, reinstalar
choco install nodejs -y
```

### Porta já em uso
```cmd
# Encontrar processo na porta
netstat -ano | findstr ":3000"

# Matar processo (substitua PID)
taskkill /PID 1234 /F
```

### Gradle não funciona
```cmd
# Verificar se gradlew.bat existe
dir kotlin-api\gradlew.bat

# Dar permissão de execução
icacls kotlin-api\gradlew.bat /grant Everyone:F
```

## 📊 Monitoramento

### Verificar Status dos Serviços

```powershell
# Verificar portas
Test-NetConnection -ComputerName localhost -Port 3000
Test-NetConnection -ComputerName localhost -Port 8080

# Ver processos
Get-Process | Where-Object { $_.ProcessName -eq "node" }
Get-Process | Where-Object { $_.ProcessName -like "*java*" }
```

### Logs

```cmd
# Ver logs do sistema
Get-EventLog -LogName Application -Newest 10

# Ver logs específicos (se existirem)
type kotlin-api.log
type ecommerce-app.log
```

## 🌐 URLs de Acesso

Após iniciar os serviços:

- **Backend API**: http://localhost:8080
- **Aplicação Web**: http://localhost:3000
- **Interface Demo**: http://localhost:3000/index.html

## 🧪 Testando

### Rotas de Teste

```cmd
# Verificação de IP
curl http://localhost:3000/checkout-ip

# Verificação avançada
curl http://localhost:3000/checkout-advanced

# API de verificação
curl -X POST http://localhost:3000/api/verify -H "Content-Type: application/json" -d "{\"userId\":\"test\"}"
```

### Interface Web

1. Abra http://localhost:3000/index.html
2. Clique nos botões para testar coleta de fingerprints
3. Monitore as estatísticas em tempo real

## 🔄 Atualizações

### Atualizar Dependências

```powershell
# Atualizar Node.js
choco upgrade nodejs -y

# Atualizar Java
choco upgrade openjdk17 -y

# Atualizar npm
npm install -g npm@latest
```

### Reinstalar SDK

```cmd
# Limpar e reinstalar
make -f Makefile.windows clean
make -f Makefile.windows install
```

## 📞 Suporte

Se encontrar problemas:

1. Verifique os logs de erro
2. Confirme que todas as dependências estão instaladas
3. Verifique se as portas estão livres
4. Execute os scripts como administrador
5. Abra uma issue no repositório

## 🎉 Próximos Passos

Após configurar o ambiente:

1. Explore a interface web em http://localhost:3000/index.html
2. Teste as diferentes rotas de verificação
3. Integre o SDK em sua aplicação
4. Configure regras de antifraude personalizadas
5. Monitore os logs e métricas

---

**Dica**: Mantenha o PowerShell aberto durante o desenvolvimento para monitorar logs e status dos serviços!

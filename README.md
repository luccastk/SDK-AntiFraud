# 🛡️ SDK AntiFraud

Um SDK completo de antifraude que coleta fingerprints do frontend, analisa no backend Kotlin e retorna decisões de risco para aplicações Node.js.

## 📋 Funcionalidades

### ✅ Implementadas
- **Coleta de Fingerprints Avançados**
  - Device fingerprinting (User Agent, resolução, timezone, plugins, fonts, canvas, WebGL)
  - Behavior fingerprinting (movimentos do mouse, teclas, scroll, cliques, duração da sessão)
  - Network fingerprinting (IP, tipo de conexão, velocidade)

- **Backend de Análise (Kotlin/Spring)**
  - Verificação de IP com dados geográficos
  - Análise de risco baseada em múltiplos fatores
  - Sistema de pontuação de risco (0-100)
  - Status: ALLOW, REVIEW, DENY

- **SDK TypeScript/JavaScript**
  - Middleware para Express.js
  - Coleta automática de fingerprints
  - Verificação síncrona e assíncrona
  - Compatibilidade com Node.js e browsers

## 🚀 Instalação

### Método Rápido (Ubuntu/Pop!_OS)

1. **Instalar dependências do sistema:**
```bash
# Para Pop!_OS (recomendado)
chmod +x setup-popos.sh
./setup-popos.sh

# Ou para Ubuntu genérico
chmod +x install-deps-ubuntu.sh
./install-deps-ubuntu.sh

# Ou apenas Java (se já tem Node.js)
chmod +x install-java-popos.sh
./install-java-popos.sh
```

2. **Iniciar ambiente de desenvolvimento:**
```bash
chmod +x start-dev.sh
./start-dev.sh
```

### Método Rápido (Windows)

1. **Instalar dependências do sistema:**
```powershell
# Execute como Administrador
PowerShell -ExecutionPolicy Bypass -File install-deps-windows.ps1
```

2. **Iniciar ambiente de desenvolvimento:**
```powershell
# PowerShell
PowerShell -ExecutionPolicy Bypass -File start-dev.ps1

# Ou usando Batch
start-dev.bat
```

### Método Manual

#### SDK
```bash
cd sdk-antifraude
npm install
npm run build
```

#### Backend Kotlin
```bash
cd kotlin-api
chmod +x gradlew
./gradlew bootRun
```

#### Aplicação de Exemplo
```bash
cd ecommerce-app
npm install
npm start
```

### Usando Makefile

#### Linux/Ubuntu
```bash
# Ver todos os comandos disponíveis
make help

# Setup completo de desenvolvimento
make dev

# Início rápido
make quick-start

# Parar todos os serviços
make stop

# Verificar status
make status
```

#### Windows
```cmd
# Ver todos os comandos disponíveis
make -f Makefile.windows help

# Setup completo de desenvolvimento
make -f Makefile.windows dev

# Início rápido
make -f Makefile.windows quick-start

# Parar todos os serviços
make -f Makefile.windows stop

# Verificar status
make -f Makefile.windows status
```

## 📖 Uso Básico

### Verificação Apenas de IP (Método Original)

```javascript
import IpVerifier from "sdk-antifraud";
import express from "express";

const app = express();
const verifier = IpVerifier.init();

app.get("/checkout", verifier.middlewareIpVerify(), (req, res) => {
  const result = req.ipVerificationResult;
  
  if (result?.status === "decline") {
    return res.status(403).json({ error: "Acesso negado" });
  }
  
  res.json({ message: "Checkout aprovado", verification: result });
});
```

### Verificação Avançada com Fingerprints

```javascript
import { AdvancedVerifier } from "sdk-antifraud";
import express from "express";

const app = express();
const verifier = AdvancedVerifier.init();

app.get("/checkout", verifier.middlewareAdvancedVerify("/checkout"), (req, res) => {
  const result = req.verificationResult;
  
  if (result?.status === "decline") {
    return res.status(403).json({ 
      error: "Acesso negado",
      riskScore: result.riskScore,
      reasons: result.reasons
    });
  }
  
  if (result?.status === "review") {
    return res.status(202).json({ 
      message: "Transação em revisão",
      riskScore: result.riskScore,
      reasons: result.reasons
    });
  }
  
  res.json({ message: "Checkout aprovado", verification: result });
});
```

### Coleta Manual de Fingerprints

```javascript
import { FingerprintCollector } from "sdk-antifraud";

const collector = new FingerprintCollector();

// Coletar fingerprint completo
const fingerprint = collector.collectCompleteFingerprint("user123");

// Coletar apenas device fingerprint
const deviceFingerprint = collector.collectDeviceFingerprint();

// Coletar apenas behavior fingerprint
const behaviorFingerprint = collector.collectBehaviorFingerprint();
```

## 🔧 Configuração

### Backend Kotlin

O backend roda por padrão na porta 8080. Para alterar:

```properties
# application.properties
server.port=8080
```

### SDK

Para configurar uma URL diferente do backend:

```javascript
const verifier = new AdvancedVerifier("https://seu-backend.com");
```

## 📊 Sistema de Pontuação de Risco

O sistema analisa múltiplos fatores e atribui uma pontuação de 0-100:

### Fatores Analisados

**Device Fingerprint:**
- User Agent suspeito (bot, crawler): +30 pontos
- Plugins insuficientes: +15 pontos
- Resolução muito baixa/alta: +5-10 pontos
- Timezone não brasileiro: +20 pontos
- Idioma não português: +15 pontos
- Hardware insuficiente: +10 pontos

**Behavior Fingerprint:**
- Sessão muito curta (<5s): +25 pontos
- Interações insuficientes: +20 pontos
- Movimentos de mouse insuficientes: +15 pontos
- Tempo de carregamento alto: +10 pontos
- Sem referrer: +5 pontos

**Network Fingerprint:**
- IP bloqueado: +40 pontos
- IP em revisão: +20 pontos
- Conexão móvel: +5 pontos
- Conexão lenta: +10 pontos

**Consistência:**
- Inconsistência timezone/idioma: +15 pontos
- Canvas fingerprint suspeito: +10 pontos
- WebGL não disponível: +10 pontos

### Decisões
- **0-39 pontos**: ALLOW (Aprovado)
- **40-79 pontos**: REVIEW (Revisão)
- **80-100 pontos**: DENY (Negado)

## 🛠️ API Endpoints

### Backend Kotlin

#### POST /verify-ip
Verifica apenas o IP do usuário.

**Request:**
```json
{
  "ip": "192.168.1.1"
}
```

**Response:**
```json
{
  "status": "ALLOW",
  "riskScore": 0,
  "reasons": ["IP aprovado"],
  "sessionId": "",
  "timestamp": 1640995200000
}
```

#### POST /verify-fingerprint
Verificação completa com fingerprints.

**Request:**
```json
{
  "fingerprint": {
    "device": {
      "userAgent": "Mozilla/5.0...",
      "language": "pt-BR",
      "platform": "Win32",
      "screenResolution": "1920x1080",
      "timezone": "America/Sao_Paulo",
      "colorDepth": 24,
      "pixelRatio": 1,
      "hardwareConcurrency": 8,
      "maxTouchPoints": 0,
      "cookieEnabled": true,
      "doNotTrack": null,
      "plugins": ["Chrome PDF Plugin", "..."],
      "fonts": ["Arial", "Times New Roman"],
      "canvas": "data:image/png;base64,...",
      "webgl": "ANGLE (Intel, Intel(R) HD Graphics 620 Direct3D11 vs_5_0 ps_5_0)"
    },
    "behavior": {
      "mouseMovements": 45,
      "keystrokes": 12,
      "scrollEvents": 8,
      "clickEvents": 3,
      "focusEvents": 2,
      "sessionDuration": 15000,
      "pageLoadTime": 1200,
      "referrer": "https://google.com",
      "timestamp": 1640995200000
    },
    "network": {
      "ip": "192.168.1.1",
      "connectionType": "wifi",
      "effectiveType": "4g",
      "downlink": 10,
      "rtt": 50
    },
    "sessionId": "session_abc123_1640995200000",
    "userId": "user123"
  },
  "endpoint": "/checkout",
  "userId": "user123"
}
```

**Response:**
```json
{
  "status": "ALLOW",
  "riskScore": 15,
  "reasons": ["Conexão móvel"],
  "sessionId": "session_abc123_1640995200000",
  "timestamp": 1640995200000
}
```

## 🧪 Testando

### Método Automático (Recomendado)

```bash
# Iniciar ambiente completo
./start-dev.sh

# Ou usando Makefile
make dev
```

### Método Manual

#### 1. Inicie o Backend Kotlin
```bash
cd kotlin-api
./gradlew bootRun
```

#### 2. Inicie a Aplicação de Exemplo
```bash
cd ecommerce-app
npm start
```

### 3. Acesse a Demonstração
- **API**: http://localhost:3000
- **Interface Web**: http://localhost:3000/index.html

### 4. Teste as Rotas
- `GET /checkout-ip` - Verificação apenas de IP
- `GET /checkout-advanced` - Verificação avançada
- `POST /api/verify` - Verificação manual
- `GET /api/verify-ip` - Verificação de IP via API

## 🛠️ Scripts de Desenvolvimento

### Scripts Disponíveis

#### Linux/Ubuntu
| Script | Descrição |
|--------|-----------|
| `install-deps-ubuntu.sh` | Instala dependências do sistema (Node.js, Java, etc.) |
| `start-dev.sh` | Inicia ambiente completo de desenvolvimento |
| `Makefile` | Comandos make para desenvolvimento |

#### Windows
| Script | Descrição |
|--------|-----------|
| `install-deps-windows.ps1` | Instala dependências do sistema (Node.js, Java, etc.) |
| `start-dev.ps1` | Inicia ambiente completo de desenvolvimento (PowerShell) |
| `start-dev.bat` | Inicia ambiente completo de desenvolvimento (Batch) |
| `stop-services.ps1` | Para todos os serviços |
| `Makefile.windows` | Comandos make para desenvolvimento no Windows |

### Comandos Make Úteis

```bash
make help          # Mostra todos os comandos disponíveis
make install       # Instala dependências
make build         # Compila o SDK
make start         # Inicia todos os serviços
make stop          # Para todos os serviços
make status        # Verifica status dos serviços
make clean         # Limpa arquivos temporários
make logs          # Mostra logs dos serviços
make dev           # Setup completo de desenvolvimento
```

### Gerenciamento de Serviços

#### Linux/Ubuntu
```bash
# Verificar se os serviços estão rodando
make status

# Ver logs em tempo real
make logs

# Parar todos os serviços
make stop

# Matar processos nas portas específicas
make kill-ports
```

#### Windows
```cmd
# Verificar se os serviços estão rodando
make -f Makefile.windows status

# Ver logs em tempo real
make -f Makefile.windows logs

# Parar todos os serviços
make -f Makefile.windows stop

# Ou usar PowerShell
PowerShell -ExecutionPolicy Bypass -File stop-services.ps1

# Matar processos nas portas específicas
make -f Makefile.windows kill-ports
```

### Comandos PowerShell Específicos

```powershell
# Instalar dependências do sistema
PowerShell -ExecutionPolicy Bypass -File install-deps-windows.ps1

# Iniciar ambiente de desenvolvimento
PowerShell -ExecutionPolicy Bypass -File start-dev.ps1

# Parar todos os serviços
PowerShell -ExecutionPolicy Bypass -File stop-services.ps1

# Verificar portas em uso
netstat -an | findstr ":3000\|:8080"

# Ver processos do Node.js
Get-Process | Where-Object { $_.ProcessName -eq "node" }

# Ver processos do Java
Get-Process | Where-Object { $_.ProcessName -like "*java*" }
```

## 📁 Estrutura do Projeto

```
SDK-AntiFraud/
├── sdk-antifraude/           # SDK TypeScript
│   ├── src/
│   │   ├── collectors/       # Coletor de fingerprints
│   │   ├── verifiers/        # Verificadores
│   │   └── index.ts         # Exportações principais
│   └── package.json
├── kotlin-api/              # Backend Kotlin/Spring
│   ├── src/main/kotlin/
│   │   └── controllers/     # Controllers REST
│   │   └── services/        # Lógica de negócio
│   │   └── dtos/           # Data Transfer Objects
│   │   └── enums/          # Enums
│   └── build.gradle.kts
└── ecommerce-app/           # Aplicação de exemplo
    ├── index.js            # Servidor Express
    ├── public/             # Arquivos estáticos
    └── package.json
```

## 🔒 Segurança

- **Fingerprints são coletados localmente** no browser
- **Dados sensíveis não são armazenados** permanentemente
- **Comunicação HTTPS** recomendada em produção
- **Rate limiting** deve ser implementado no backend
- **Logs de auditoria** para transações suspeitas

## 🚀 Próximos Passos

### Funcionalidades Planejadas
- [ ] Machine Learning para detecção de padrões
- [ ] Blacklist/Whitelist de fingerprints
- [ ] Dashboard de monitoramento
- [ ] Integração com bancos de dados de fraude
- [ ] Análise de comportamento temporal
- [ ] Detecção de bots avançada
- [ ] Geolocalização precisa
- [ ] Análise de velocidade de digitação

### Melhorias Técnicas
- [ ] Cache Redis para performance
- [ ] Métricas e alertas
- [ ] Testes automatizados
- [ ] CI/CD pipeline
- [ ] Documentação OpenAPI
- [ ] SDK para outras linguagens (Python, Java)

## 📝 Licença

ISC License

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📞 Suporte

Para dúvidas ou suporte, abra uma issue no repositório.

# 🛡️ SDK AntiFraud

Um SDK completo para detecção de fraude que coleta fingerprints do dispositivo e analisa riscos em tempo real.

## 📋 Funcionalidades

- **Device Fingerprinting**: Coleta informações únicas do dispositivo
- **Behavioral Analysis**: Monitora comportamento do usuário
- **IP Verification**: Verifica endereços IP suspeitos
- **Real-time Risk Scoring**: Pontuação de risco em tempo real
- **Express.js Middleware**: Integração fácil com Express

## 🚀 Instalação

```bash
npm install sdk-antifraud-core@latest
```

## 📖 Uso Básico

### Importação

```typescript
import { AdvancedVerifier, FingerprintCollector } from "sdk-antifraud-core";
```

### Verificação Simples de IP

```typescript
import { AdvancedVerifier } from "sdk-antifraud-core";

const verifier = AdvancedVerifier.init();

// Verificar IP específico
const result = await verifier.verifyIp({ ip: "192.168.1.1" });
console.log(result);
// { status: "ALLOW" | "REVIEW" | "DENY", riskScore: 25, reasons: [...], ... }

// OU usar como middleware (pega IP automaticamente da requisição)
app.use("/api", verifier.middlewareIpOnly());
```

### Middleware para Express

```typescript
import express from "express";
import { AdvancedVerifier } from "sdk-antifraud-core";

const app = express();
const verifier = AdvancedVerifier.init();

// Middleware de verificação avançada
app.use("/login", verifier.middlewareAdvancedVerify("/login", "user123"));

// Middleware apenas para IP
app.use("/api", verifier.middlewareIpOnly());

app.post("/login", (req, res) => {
  const result = req.verificationResult;

  if (result.status === "DENY") {
    return res.status(403).json({ error: "Acesso negado" });
  }

  if (result.status === "REVIEW") {
    return res.status(202).json({ message: "Em análise" });
  }

  // ALLOW - continuar com login
  res.json({ message: "Login aprovado" });
});
```

### Coleta Manual de Fingerprint

```typescript
import { FingerprintCollector } from "sdk-antifraud-core";

const collector = new FingerprintCollector();

// Coletar fingerprint completo
const fingerprint = collector.collectCompleteFingerprint("user123");

// Coletar apenas device fingerprint
const device = collector.collectDeviceFingerprint();

// Coletar apenas behavior fingerprint
const behavior = collector.collectBehaviorFingerprint();
```

## ⚙️ Configuração

### URL da API

Por padrão, o SDK usa `https://sdk-antifraud.koyeb.app`. Para alterar:

```typescript
// Opção 1: Via parâmetro
const verifier = AdvancedVerifier.init("https://sua-api.com");

// Opção 2: Via variável de ambiente
// ANTIFRAUD_API_URL=https://sua-api.com
const verifier = AdvancedVerifier.init();
```

### Configurações Avançadas

```typescript
import { Config } from "sdk-antifraud-core";

// Usar URLs pré-configuradas
const devUrl = Config.getApiUrl("DEVELOPMENT"); // http://localhost:8080
const prodUrl = Config.getApiUrl("PRODUCTION"); // https://sdk-antifraud.koyeb.app

// Configurações disponíveis
console.log(Config.API_URL);
console.log(Config.TIMEOUT);
```

## 🎯 Filosofia do SDK

O SDK é **neutro e flexível** - ele apenas coleta dados e fornece informações. **VOCÊ** decide as regras de negócio:

- ✅ **SDK coleta**: Fingerprints, IPs, dados de comportamento
- ✅ **SDK fornece**: Status, score de risco, motivos
- ✅ **VOCÊ decide**: O que fazer com cada resposta
- ✅ **VOCÊ cria**: Suas próprias regras de negócio

### Exemplo de Flexibilidade

```typescript
// Mesma resposta, regras diferentes:
const { status, riskScore } = req.verificationResult!;

// E-commerce: Negar se DENY
if (status === "DENY") res.status(403).json({ error: "Negado" });

// Banking: Sempre permitir, mas logar
if (status === "DENY") console.log("Alto risco detectado:", riskScore);

// Gaming: Apenas alertar
if (riskScore > 80) res.json({ warning: "Conta suspeita" });
```

## 📊 Tipos de Resposta

```typescript
interface VerificationResponse {
  status: "ALLOW" | "REVIEW" | "DENY";
  riskScore: number; // 0-100
  reasons: string[]; // Motivos da decisão
  sessionId: string; // ID da sessão
  timestamp: number; // Timestamp Unix
}
```

### Status de Verificação

- **`ALLOW`**: Aprovado - baixo risco
- **`REVIEW`**: Em análise - risco médio  
- **`DENY`**: Negado - alto risco

## 🔧 Exemplos Avançados

### 🛒 E-commerce - Regras Rígidas

```typescript
// Checkout com regras rígidas de segurança
app.post("/checkout", verifier.middlewareAdvancedVerify("/checkout"), (req, res) => {
  const { status, riskScore, reasons } = req.verificationResult!;

  // Regras rígidas para e-commerce
  if (status === "DENY") {
    return res.status(403).json({ error: "Transação bloqueada", reasons });
  }

  if (riskScore > 70) {
    return res.status(202).json({ 
      message: "Verificação adicional necessária",
      requiresAuth: true 
    });
  }

  // Processar pagamento
  res.json({ success: true, orderId: generateOrderId() });
});
```

### 🏦 Banking - Regras Flexíveis

```typescript
// Banking com regras mais flexíveis
app.post("/transfer", verifier.middlewareAdvancedVerify("/transfer"), (req, res) => {
  const { status, riskScore, reasons } = req.verificationResult!;

  // Banking: Sempre permitir, mas com controles
  if (status === "DENY") {
    // Log para auditoria, mas permite
    auditLog("Alto risco detectado", { riskScore, reasons });
  }

  if (riskScore > 80) {
    // Requer aprovação manual
    return res.json({ 
      status: "pending_approval",
      message: "Transferência em análise" 
    });
  }

  // Processar transferência
  res.json({ success: true });
});
```

### 🎮 Gaming - Regras Personalizadas

```typescript
// Gaming com regras específicas
app.post("/purchase-credits", verifier.middlewareAdvancedVerify("/credits"), (req, res) => {
  const { status, riskScore } = req.verificationResult!;

  // Gaming: Apenas alertar, não bloquear
  if (riskScore > 60) {
    return res.json({ 
      warning: "Conta suspeita detectada",
      requiresPhoneVerification: true 
    });
  }

  // Processar compra
  res.json({ success: true, credits: req.body.amount });
});
```

### 🔐 Login - Verificação de IP

```typescript
// Login com verificação de IP
app.post("/login", verifier.middlewareIpOnly(), (req, res) => {
  const { status, riskScore } = req.verificationResult!;

  // IP suspeito - solicitar 2FA
  if (riskScore > 70) {
    return res.json({ 
      requires2FA: true,
      message: "Verificação adicional necessária" 
    });
  }

  // IP confiável - login normal
  res.json({ 
    success: true, 
    token: generateToken(),
    riskLevel: riskScore < 30 ? "low" : "medium"
  });
});
```


### React/Next.js Integration

```typescript
// hooks/useAntiFraud.ts
import { FingerprintCollector } from "sdk-antifraud-core";

export const useAntiFraud = () => {
  const [collector] = useState(() => new FingerprintCollector());

  const getFingerprint = useCallback(() => {
    return collector.collectCompleteFingerprint();
  }, [collector]);

  return { getFingerprint };
};

// Component
const LoginForm = () => {
  const { getFingerprint } = useAntiFraud();

  const handleSubmit = async (data) => {
    const fingerprint = getFingerprint();

    const response = await fetch("/api/login", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        ...data,
        fingerprint,
      }),
    });
  };
};
```

## 🌐 API Endpoints

O SDK se conecta com estes endpoints:

- `POST /verify-ip` - Verificação de IP
- `POST /verify-fingerprint` - Verificação avançada
- `GET /` - Status da API
- `GET /actuator/health` - Health check

## 🔒 Segurança

- **HTTPS**: Sempre use HTTPS em produção
- **Rate Limiting**: Implemente rate limiting no servidor
- **Logs**: Monitore tentativas suspeitas
- **Dados**: Fingerprints não são armazenados permanentemente

## 🐛 Troubleshooting

### Erro de Conexão

```typescript
// Verificar se a API está online
const response = await fetch("https://sdk-antifraud.koyeb.app/");
console.log(await response.json());
```

### Timeout

```typescript
// Aumentar timeout
const verifier = AdvancedVerifier.init();
// O timeout padrão é 10 segundos
```

### Browser Compatibility

O SDK funciona em todos os navegadores modernos. Para navegadores antigos, alguns recursos podem não estar disponíveis.

## 📚 Tipos TypeScript

```typescript
// Principais interfaces
interface DeviceFingerprint {
  userAgent: string;
  language: string;
  platform: string;
  screenResolution: string;
  timezone: string;
  // ... outros campos
}

interface BehaviorFingerprint {
  mouseMovements: number;
  keystrokes: number;
  scrollEvents: number;
  // ... outros campos
}

interface NetworkFingerprint {
  ip: string;
  connectionType?: string;
  effectiveType?: string;
  // ... outros campos
}
```

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch: `git checkout -b feature/nova-funcionalidade`
3. Commit: `git commit -m 'Add nova funcionalidade'`
4. Push: `git push origin feature/nova-funcionalidade`
5. Abra um Pull Request

## 📄 Licença

MIT License - veja o arquivo [LICENSE](LICENSE) para detalhes.

## 🔗 Links

- **API**: https://sdk-antifraud.koyeb.app
- **Swagger**: https://sdk-antifraud.koyeb.app/swagger-ui.html
- **NPM**: https://www.npmjs.com/package/sdk-antifraud-core
- **GitHub**: https://github.com/luccastk/SDK-AntiFraud

---

**Desenvolvido com ❤️ para proteger aplicações web**

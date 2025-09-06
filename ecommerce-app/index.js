import { AdvancedVerifier, IpVerifier } from "sdk-antifraud";
import express from "express";

const app = express();
const port = 3000;

// Inicializar verificadores
const ipVerifier = IpVerifier.init();
const advancedVerifier = AdvancedVerifier.init();

app.set("trust proxy", true);
app.use(express.json());
app.use(express.static('public'));

// Rota básica
app.get("/", (request, response) => {
  response.send(`
    <h1>SDK AntiFraud - Exemplo de Uso</h1>
    <p>Rotas disponíveis:</p>
    <ul>
      <li><a href="/checkout-ip">/checkout-ip</a> - Verificação apenas de IP</li>
      <li><a href="/checkout-advanced">/checkout-advanced</a> - Verificação avançada com fingerprints</li>
      <li><a href="/api/verify">/api/verify</a> - API para verificação manual</li>
    </ul>
  `);
});

// Verificação apenas de IP (método antigo)
app.get("/checkout-ip", ipVerifier.middlewareIpVerify(), (req, res) => {
  console.log("Resultado verificação IP:", req.ipVerificationResult);
  
  const result = req.ipVerificationResult;
  if (result?.status === "DENY" || result?.status === "decline") {
    return res.status(403).json({
      error: "Acesso negado",
      reason: "IP bloqueado",
      details: result
    });
  }
  
  if (result?.status === "REVIEW" || result?.status === "review") {
    return res.status(202).json({
      message: "Transação em revisão",
      reason: "IP em análise",
      details: result
    });
  }
  
  res.json({
    message: "Checkout aprovado - Verificação de IP",
    verification: result
  });
});

// Verificação avançada com fingerprints
app.get("/checkout-advanced", advancedVerifier.middlewareAdvancedVerify("/checkout-advanced"), (req, res) => {
  console.log("Resultado verificação avançada:", req.verificationResult);
  
  const result = req.verificationResult;
  if (result?.status === "DENY" || result?.status === "decline") {
    return res.status(403).json({
      error: "Acesso negado",
      riskScore: result.riskScore,
      reasons: result.reasons,
      details: result
    });
  }
  
  if (result?.status === "REVIEW" || result?.status === "review") {
    return res.status(202).json({
      message: "Transação em revisão",
      riskScore: result.riskScore,
      reasons: result.reasons,
      details: result
    });
  }
  
  res.json({
    message: "Checkout aprovado - Verificação avançada",
    verification: result
  });
});

// API para verificação manual
app.post("/api/verify", async (req, res) => {
  try {
    const { userId, endpoint = "/api/verify" } = req.body;
    
    // Coletar fingerprint manualmente
    const fingerprint = advancedVerifier.collectFingerprint(userId);
    
    // Verificar
    const result = await advancedVerifier.verifyFingerprint({
      fingerprint,
      endpoint,
      userId
    });
    
    res.json({
      success: true,
      verification: result,
      fingerprint: {
        sessionId: fingerprint.sessionId,
        device: {
          userAgent: fingerprint.device.userAgent,
          platform: fingerprint.device.platform,
          timezone: fingerprint.device.timezone
        }
      }
    });
  } catch (error) {
    console.error("Erro na verificação manual:", error);
    res.status(500).json({
      success: false,
      error: "Erro interno do servidor"
    });
  }
});

// Middleware para verificação apenas de IP
app.get("/api/verify-ip", advancedVerifier.middlewareIpOnly(), (req, res) => {
  const result = req.verificationResult;
  res.json({
    success: true,
    verification: result
  });
});

// Middleware de tratamento de erros
app.use((err, req, res, next) => {
  console.error("Erro não tratado:", err);
  res.status(500).json({
    error: "Erro interno do servidor",
    message: err.message
  });
});

app.listen(port, () => {
  console.log(`🚀 Aplicação rodando em http://localhost:${port}`);
  console.log(`📊 SDK AntiFraud integrado com sucesso!`);
  console.log(`🔍 Verificação de IP: http://localhost:${port}/checkout-ip`);
  console.log(`🛡️  Verificação Avançada: http://localhost:${port}/checkout-advanced`);
});

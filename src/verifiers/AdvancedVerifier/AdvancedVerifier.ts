import axios, { AxiosInstance } from "axios";
import { NextFunction, Request } from "express";
import {
  FingerprintCollector,
  CompleteFingerprint,
} from "../../collectors/FingerprintCollector.js";
import { Config } from "../../config/Config.js";

type VerificationRequest = {
  fingerprint: CompleteFingerprint;
  endpoint: string;
  userId?: string;
};

type VerificationResponse = {
  status: "ALLOW" | "REVIEW" | "DENY";
  riskScore: number;
  reasons: string[];
  sessionId: string;
  timestamp: number;
};

interface CustomRequest extends Request {
  verificationResult?: VerificationResponse;
}

// URL da API usando a classe Config
const baseUrl = Config.API_URL;

export default class AdvancedVerifier {
  private readonly client: AxiosInstance;
  private readonly fingerprintCollector: FingerprintCollector;

  private constructor(baseUrl: string) {
    this.client = axios.create({
      baseURL: baseUrl,
      headers: {
        "Content-Type": "application/json",
        "User-Agent": "SDK-AntiFraud-Core/1.0.4",
      },
      timeout: Config.TIMEOUT,
    });
    this.fingerprintCollector = new FingerprintCollector();
  }

  public static init(apiUrl?: string): AdvancedVerifier {
    const url = apiUrl || baseUrl;
    return new AdvancedVerifier(url);
  }

  public async verifyFingerprint(
    payload: VerificationRequest
  ): Promise<VerificationResponse> {
    try {
      const response = await this.client.post<VerificationResponse>(
        "/verify-fingerprint",
        payload
      );
      return response.data;
    } catch (error: any) {
      console.warn("Erro na verificação de fingerprint:", {
        message: error.message,
        status: error.response?.status,
        data: error.response?.data,
      });

      // Return a safe fallback response instead of throwing
      return {
        status: "REVIEW",
        riskScore: 100,
        reasons: ["Erro na comunicação com a API"],
        sessionId: payload.fingerprint.sessionId || "",
        timestamp: Date.now(),
      };
    }
  }

  public async verifyIp(payload: {
    ip: string;
  }): Promise<VerificationResponse> {
    try {
      const response = await this.client.post<VerificationResponse>(
        "/verify-ip",
        payload
      );
      return response.data;
    } catch (error: any) {
      console.warn("Erro na verificação de IP:", {
        message: error.message,
        status: error.response?.status,
        data: error.response?.data,
      });

      // Return a safe fallback response instead of throwing
      return {
        status: "REVIEW",
        riskScore: 100,
        reasons: ["Erro na comunicação com a API"],
        sessionId: "",
        timestamp: Date.now(),
      };
    }
  }

  public middlewareAdvancedVerify(endpoint: string, userId?: string) {
    return async (req: Request, res: any, next: NextFunction) => {
      try {
        // Criar fingerprint básico apenas com dados do servidor
        const basicFingerprint = {
          device: {
            userAgent: req.headers['user-agent'] || 'Unknown',
            language: req.headers['accept-language']?.split(',')[0] || 'en-US',
            platform: 'Server',
            screenResolution: '0x0',
            timezone: 'UTC',
            colorDepth: 0,
            pixelRatio: 1,
            hardwareConcurrency: 0,
            maxTouchPoints: 0,
            cookieEnabled: false,
            doNotTrack: null,
            plugins: [],
            fonts: [],
            canvas: '',
            webgl: ''
          },
          behavior: {
            mouseMovements: 0,
            keystrokes: 0,
            scrollEvents: 0,
            clickEvents: 0,
            focusEvents: 0,
            sessionDuration: 0,
            pageLoadTime: 0,
            referrer: req.headers['referer'] || '',
            timestamp: Date.now()
          },
          network: {
            ip: req.ip || req.socket.remoteAddress || '',
            connectionType: 'unknown',
            effectiveType: 'unknown',
            downlink: 0,
            rtt: 0
          },
          sessionId: `session_${Date.now()}_${Math.random().toString(36).substring(2, 11)}`,
          userId
        };

        const payload: VerificationRequest = {
          fingerprint: basicFingerprint,
          endpoint,
          userId,
        };

        const result = await this.verifyFingerprint(payload);
        (req as CustomRequest).verificationResult = result;

        // Sempre continua - usuário decide no controller
        next();
      } catch (error: any) {
        console.warn("Erro no middleware de verificação avançada:", {
          message: error.message,
          endpoint,
          userId,
        });
        // Em caso de erro, adiciona flag de erro mas continua
        (req as CustomRequest).verificationResult = {
          status: "REVIEW",
          riskScore: 100,
          reasons: ["Erro na verificação"],
          sessionId: `session_${Date.now()}_error`,
          timestamp: Date.now(),
        };
        // Sempre continua - usuário decide no controller
        next();
      }
    };
  }

  public middlewareIpOnly() {
    return async (req: Request, res: any, next: NextFunction) => {
      try {
        const payload = { ip: req.ip || req.socket.remoteAddress || "" };
        const result = await this.verifyIp(payload);
        (req as CustomRequest).verificationResult = result;

        // Sempre continua - usuário decide no controller
        next();
      } catch (error: any) {
        console.warn("Erro no middleware de verificação de IP:", {
          message: error.message,
          ip: req.ip || req.socket.remoteAddress || "",
        });
        (req as CustomRequest).verificationResult = {
          status: "REVIEW",
          riskScore: 100,
          reasons: ["Erro na verificação de IP"],
          sessionId: "",
          timestamp: Date.now(),
        };
        // Sempre continua - usuário decide no controller
        next();
      }
    };
  }

  // Método para obter o coletor de fingerprints (para uso manual)
  public getFingerprintCollector(): FingerprintCollector {
    return this.fingerprintCollector;
  }

  // Método para coletar fingerprint manualmente
  public collectFingerprint(userId?: string): CompleteFingerprint {
    return this.fingerprintCollector.collectCompleteFingerprint(userId);
  }

  // Método para testar conectividade com a API
  public async testApiConnection(): Promise<{
    status: string;
    message: string;
  }> {
    try {
      await this.client.get("/");
      return {
        status: "success",
        message: "API está online e acessível",
      };
    } catch (error: any) {
      return {
        status: "error",
        message: `Erro ao conectar com a API: ${error.message}`,
      };
    }
  }

  // Método para obter informações da API
  public async getApiInfo(): Promise<any> {
    try {
      const response = await this.client.get("/");
      return response.data;
    } catch (error: any) {
      console.warn("Erro ao obter informações da API:", error.message);
      return null;
    }
  }
}

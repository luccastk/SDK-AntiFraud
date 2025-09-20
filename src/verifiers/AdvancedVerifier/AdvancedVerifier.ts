import axios, { AxiosInstance } from "axios";
import { NextFunction, Request } from "express";
import {
  FingerprintCollector,
  CompleteFingerprint,
} from "../../collectors/FingerprintCollector.js";

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

// URL da API pode ser configurada via variável de ambiente
const baseUrl = "https://sdk-antifraud.koyeb.app";

export default class AdvancedVerifier {
  private readonly client: AxiosInstance;
  private readonly fingerprintCollector: FingerprintCollector;

  private constructor(baseUrl: string) {
    this.client = axios.create({
      baseURL: baseUrl,
      headers: {
        "Content-Type": "application/json",
      },
      timeout: 10000,
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
    } catch (error) {
      console.warn("Erro na verificação de fingerprint:", error);
      throw error;
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
    } catch (error) {
      console.warn("Erro na verificação de IP:", error);
      throw error;
    }
  }

  public middlewareAdvancedVerify(endpoint: string, userId?: string) {
    return async (req: Request, res: any, next: NextFunction) => {
      try {
        // Coleta o fingerprint completo
        const fingerprint =
          this.fingerprintCollector.collectCompleteFingerprint(userId);

        // Adiciona o IP da requisição
        fingerprint.network.ip = req.ip || req.socket.remoteAddress || "";

        const payload: VerificationRequest = {
          fingerprint,
          endpoint,
          userId,
        };

        const result = await this.verifyFingerprint(payload);
        (req as CustomRequest).verificationResult = result;

        next();
      } catch (error) {
        console.warn("Erro no middleware de verificação avançada:", error);
        // Em caso de erro, permite a requisição mas adiciona flag de erro
        (req as CustomRequest).verificationResult = {
          status: "REVIEW",
          riskScore: 100,
          reasons: ["Erro na verificação"],
          sessionId: "",
          timestamp: Date.now(),
        };
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
        next();
      } catch (error) {
        console.error("Erro no middleware de verificação de IP:", error);
        (req as CustomRequest).verificationResult = {
          status: "REVIEW",
          riskScore: 100,
          reasons: ["Erro na verificação de IP"],
          sessionId: "",
          timestamp: Date.now(),
        };
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
}

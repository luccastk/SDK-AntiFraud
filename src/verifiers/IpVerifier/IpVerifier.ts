import axios, { AxiosInstance } from "axios";
import { NextFunction, Request } from "express";

type RequestIpVerify = {
  ip: string;
};

type ResponseIpVerify = {
  status: "aprove" | "review" | "decline";
};

interface CustomRequest extends Request {
  ipVerificationResult?: ResponseIpVerify;
}

// URL da API pode ser configurada via variável de ambiente
const baseUrl =
  process.env.ANTIFRAUD_API_URL || "https://sdk-antifraud.koyeb.app";

export default class IpVerifier {
  private client: AxiosInstance;

  private constructor(baseUrl: string) {
    this.client = axios.create({
      baseURL: baseUrl,
      headers: {
        "Content-Type": "application/json",
      },
      timeout: 5000,
    });
  }

  public static init(apiUrl?: string): IpVerifier {
    const url = apiUrl || baseUrl;
    return new IpVerifier(url);
  }

  public async verify(payload: RequestIpVerify): Promise<ResponseIpVerify> {
    const response = await this.client.post<ResponseIpVerify>(
      "/verify-ip",
      payload
    );
    return response.data;
  }

  public middlewareIpVerify() {
    return async (req: Request, res: any, next: NextFunction) => {
      try {
        const payload: RequestIpVerify = {
          ip: req.ip || req.connection.remoteAddress || "",
        };
        const result = await this.verify(payload);

        (req as CustomRequest).ipVerificationResult = result;

        next();
      } catch (error) {
        console.error("Erro no antifraud middleware:", error);
        next();
      }
    };
  }
}

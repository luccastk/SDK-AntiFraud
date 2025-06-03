import axios, { AxiosInstance } from "axios";
import { NextFunction, Request, Response } from "express";

type InitConfig = {
  baseUrl: string;
};

type RequestIpVerify = {
  ip: string;
};

type ResponseIpVerify = {
  status: "aprove" | "review" | "decline";
};

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

  public static init(config: InitConfig): IpVerifier {
    return new IpVerifier(config.baseUrl);
  }

  public async verify(payload: RequestIpVerify): Promise<ResponseIpVerify> {
    const response = await this.client.post<ResponseIpVerify>(
      "/verify",
      payload
    );
    return response.data;
  }

  public middlewareIpVerify() {
    return async (req: Request, res: Response, next: NextFunction) => {
      try {
        const payload: RequestIpVerify = {
          ip: req.ip || "0.0.0.0",
        };
        const result = await this.verify(payload);
        next();
      } catch (error) {
        console.error("Erro no antifraud middleware:", error);
        next();
      }
    };
  }
}

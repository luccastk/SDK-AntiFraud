/**
 * Configurações do SDK AntiFraud
 */
export class Config {
  /**
   * URL da API AntiFraud (pode ser sobrescrita por variável de ambiente)
   */
  public static readonly API_URL: string =
    process.env.ANTIFRAUD_API_URL || "https://sdk-antifraud.koyeb.app";

  /**
   * Timeout para requisições (em ms)
   */
  public static readonly TIMEOUT: number = parseInt(
    process.env.ANTIFRAUD_TIMEOUT || "10000"
  );

  /**
   * URLs pré-configuradas para diferentes ambientes
   */
  public static readonly PRESET_URLS = {
    DEVELOPMENT: "http://localhost:8080",
    STAGING: "https://sdk-antifraud-staging.koyeb.app",
    PRODUCTION: "https://sdk-antifraud.koyeb.app",
  } as const;

  /**
   * Obter URL baseada no ambiente
   */
  public static getApiUrl(
    environment?: keyof typeof Config.PRESET_URLS
  ): string {
    // Se uma variável de ambiente específica for definida, use-a
    if (process.env.ANTIFRAUD_API_URL) {
      return process.env.ANTIFRAUD_API_URL;
    }

    // Caso contrário, use o ambiente especificado ou o padrão
    if (environment && this.PRESET_URLS[environment]) {
      return this.PRESET_URLS[environment];
    }
    return this.API_URL;
  }

  /**
   * Verificar se estamos em ambiente de desenvolvimento
   */
  public static isDevelopment(): boolean {
    return process.env.NODE_ENV === "development";
  }

  /**
   * Verificar se estamos em ambiente de produção
   */
  public static isProduction(): boolean {
    return process.env.NODE_ENV === "production";
  }

  /**
   * Obter todas as configurações atuais
   */
  public static getConfig() {
    return {
      apiUrl: this.API_URL,
      timeout: this.TIMEOUT,
      environment: process.env.NODE_ENV || "development",
      isDevelopment: this.isDevelopment(),
      isProduction: this.isProduction(),
    };
  }
}

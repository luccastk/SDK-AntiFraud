/**
 * Configurações do SDK AntiFraud
 */
export class Config {
  /**
   * URL da API AntiFraud
   */
  public static readonly API_URL: string = "https://sdk-antifraud.koyeb.app";

  /**
   * Timeout para requisições (em ms)
   */
  public static readonly TIMEOUT: number = 10000;

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
    // Use o ambiente especificado ou o padrão
    if (environment && this.PRESET_URLS[environment]) {
      return this.PRESET_URLS[environment];
    }
    return this.API_URL;
  }

  /**
   * Verificar se estamos em ambiente de desenvolvimento
   */
  public static isDevelopment(): boolean {
    return false; // Sempre produção para simplicidade
  }

  /**
   * Verificar se estamos em ambiente de produção
   */
  public static isProduction(): boolean {
    return true; // Sempre produção para simplicidade
  }

  /**
   * Obter todas as configurações atuais
   */
  public static getConfig() {
    return {
      apiUrl: this.API_URL,
      timeout: this.TIMEOUT,
      environment: "production",
      isDevelopment: this.isDevelopment(),
      isProduction: this.isProduction(),
    };
  }
}

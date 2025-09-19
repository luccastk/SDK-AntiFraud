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
  public static readonly TIMEOUT: number = parseInt("10000");

  /**
   * URLs pré-configuradas para diferentes ambientes
   */
  public static readonly PRESET_URLS = {
    DEVELOPMENT: "http://localhost:8080",
    PRODUCTION: "https://sdk-antifraud.koyeb.app",
  } as const;

  /**
   * Obter URL baseada no ambiente
   */
  public static getApiUrl(
    environment?: keyof typeof Config.PRESET_URLS
  ): string {
    if (environment && this.PRESET_URLS[environment]) {
      return this.PRESET_URLS[environment];
    }
    return this.API_URL;
  }
}

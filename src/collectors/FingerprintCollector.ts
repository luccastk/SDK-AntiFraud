export interface DeviceFingerprint {
  userAgent: string;
  language: string;
  platform: string;
  screenResolution: string;
  timezone: string;
  colorDepth: number;
  pixelRatio: number;
  hardwareConcurrency: number;
  maxTouchPoints: number;
  cookieEnabled: boolean;
  doNotTrack: string | null;
  plugins: string[];
  fonts: string[];
  canvas: string;
  webgl: string;
}

export interface BehaviorFingerprint {
  mouseMovements: number;
  keystrokes: number;
  scrollEvents: number;
  clickEvents: number;
  focusEvents: number;
  sessionDuration: number;
  pageLoadTime: number;
  referrer: string;
  timestamp: number;
}

export interface NetworkFingerprint {
  ip: string;
  connectionType?: string;
  effectiveType?: string;
  downlink?: number;
  rtt?: number;
}

export interface CompleteFingerprint {
  device: DeviceFingerprint;
  behavior: BehaviorFingerprint;
  network: NetworkFingerprint;
  sessionId: string;
  userId?: string;
}

export class FingerprintCollector {
  private readonly sessionId: string;
  private readonly startTime: number;
  private readonly behaviorData: Partial<BehaviorFingerprint> = {
    mouseMovements: 0,
    keystrokes: 0,
    scrollEvents: 0,
    clickEvents: 0,
    focusEvents: 0,
    pageLoadTime: 0,
    sessionDuration: 0,
    referrer: "",
    timestamp: Date.now(),
  };

  // Singleton para browser
  private static instance: FingerprintCollector | null = null;

  constructor() {
    this.sessionId = this.getOrCreateSessionId();
    this.startTime = Date.now();
    this.initializeBehaviorTracking();
  }

  // Método estático para obter instância singleton (apenas no browser)
  public static getInstance(): FingerprintCollector {
    if (typeof window !== "undefined") {
      // No browser, usar singleton
      if (!FingerprintCollector.instance) {
        FingerprintCollector.instance = new FingerprintCollector();
      }
      return FingerprintCollector.instance;
    } else {
      // No servidor, sempre criar nova instância
      return new FingerprintCollector();
    }
  }

  // Gera ou recupera session ID do localStorage (browser) ou gera novo (servidor)
  private getOrCreateSessionId(): string {
    if (typeof window !== "undefined" && typeof localStorage !== "undefined") {
      try {
        let sessionId = localStorage.getItem('antifraud_session_id');
        if (!sessionId) {
          sessionId = this.generateSessionId();
          localStorage.setItem('antifraud_session_id', sessionId);
        }
        return sessionId;
      } catch {
        return this.generateSessionId();
      }
    }
    return this.generateSessionId();
  }

  private generateSessionId(): string {
    return (
      "session_" +
      Math.random().toString(36).substring(2, 11) +
      "_" +
      Date.now()
    );
  }

  private initializeBehaviorTracking(): void {
    // Verificar se estamos no browser
    if (typeof document === "undefined" || typeof window === "undefined") {
      return; // Não executar no servidor Node.js
    }

    // Inicializar contadores do localStorage se estivermos no browser
    if (typeof localStorage !== "undefined") {
      try {
        if (!localStorage.getItem("sessionStart")) {
          localStorage.setItem("sessionStart", Date.now().toString());
        }
        
        this.behaviorData.mouseMovements = parseInt(localStorage.getItem("mouseMovements") || "0");
        this.behaviorData.keystrokes = parseInt(localStorage.getItem("keystrokes") || "0");
        this.behaviorData.scrollEvents = parseInt(localStorage.getItem("scrollEvents") || "0");
        this.behaviorData.clickEvents = parseInt(localStorage.getItem("clickEvents") || "0");
        this.behaviorData.focusEvents = parseInt(localStorage.getItem("focusEvents") || "0");
      } catch (e) {
        // Fallback se localStorage não funcionar
      }
    }

    // Mouse movements
    document.addEventListener("mousemove", () => {
      this.behaviorData.mouseMovements!++;
      this.saveToLocalStorage("mouseMovements", this.behaviorData.mouseMovements!);
    });

    // Keystrokes
    document.addEventListener("keydown", () => {
      this.behaviorData.keystrokes!++;
      this.saveToLocalStorage("keystrokes", this.behaviorData.keystrokes!);
    });

    // Scroll events
    document.addEventListener("scroll", () => {
      this.behaviorData.scrollEvents!++;
      this.saveToLocalStorage("scrollEvents", this.behaviorData.scrollEvents!);
    });

    // Click events
    document.addEventListener("click", () => {
      this.behaviorData.clickEvents!++;
      this.saveToLocalStorage("clickEvents", this.behaviorData.clickEvents!);
    });

    // Focus events
    document.addEventListener("focus", () => {
      this.behaviorData.focusEvents!++;
      this.saveToLocalStorage("focusEvents", this.behaviorData.focusEvents!);
    });

    // Page load time
    window.addEventListener("load", () => {
      this.behaviorData.pageLoadTime = performance.now();
    });

    // Referrer
    this.behaviorData.referrer = document.referrer;
  }

  private saveToLocalStorage(key: string, value: number): void {
    if (typeof localStorage !== "undefined") {
      try {
        localStorage.setItem(key, value.toString());
      } catch (e) {
        // Falha silenciosa se localStorage não funcionar
      }
    }
  }

  public collectDeviceFingerprint(): DeviceFingerprint {
    // Verificar se estamos no browser
    if (typeof navigator === "undefined" || typeof window === "undefined") {
      // Retornar dados padrão para servidor
      return {
        userAgent: "Node.js Server",
        language: "en-US",
        platform: "Node.js",
        screenResolution: "0x0",
        timezone: "UTC",
        colorDepth: 0,
        pixelRatio: 1,
        hardwareConcurrency: 0,
        maxTouchPoints: 0,
        cookieEnabled: false,
        doNotTrack: null,
        plugins: [],
        fonts: [],
        canvas: "",
        webgl: "",
      };
    }

    const canvas = this.getCanvasFingerprint();
    const webgl = this.getWebGLFingerprint();
    const fonts = this.getFontFingerprint();

    return {
      userAgent: navigator.userAgent,
      language: navigator.language,
      platform: (navigator as any).userAgentData?.platform || "Unknown",
      screenResolution: `${screen.width}x${screen.height}`,
      timezone: Intl.DateTimeFormat().resolvedOptions().timeZone,
      colorDepth: screen.colorDepth,
      pixelRatio: window.devicePixelRatio,
      hardwareConcurrency: navigator.hardwareConcurrency || 0,
      maxTouchPoints: navigator.maxTouchPoints || 0,
      cookieEnabled: navigator.cookieEnabled,
      doNotTrack: navigator.doNotTrack,
      plugins: [],
      fonts,
      canvas,
      webgl,
    };
  }

  public collectBehaviorFingerprint(): BehaviorFingerprint {
    // Calcular duração da sessão usando localStorage se disponível
    let sessionStart = this.startTime;
    if (typeof localStorage !== "undefined") {
      try {
        const storedStart = localStorage.getItem("sessionStart");
        if (storedStart) {
          sessionStart = parseInt(storedStart);
        }
      } catch (e) {
        // Usar fallback
      }
    }

    this.behaviorData.sessionDuration = Date.now() - sessionStart;
    this.behaviorData.timestamp = Date.now();

    return this.behaviorData as BehaviorFingerprint;
  }

  public collectNetworkFingerprint(): NetworkFingerprint {
    const connection =
      (navigator as any).connection ||
      (navigator as any).mozConnection ||
      (navigator as any).webkitConnection;

    return {
      ip: "", // Will be filled by the server
      connectionType: connection?.type,
      effectiveType: connection?.effectiveType,
      downlink: connection?.downlink,
      rtt: connection?.rtt,
    };
  }

  public collectCompleteFingerprint(userId?: string): CompleteFingerprint {
    return {
      device: this.collectDeviceFingerprint(),
      behavior: this.collectBehaviorFingerprint(),
      network: this.collectNetworkFingerprint(),
      sessionId: this.sessionId,
      userId,
    };
  }

  private getCanvasFingerprint(): string {
    if (typeof document === "undefined") return "";

    const canvas = document.createElement("canvas");
    const ctx = canvas.getContext("2d");

    if (!ctx) return "";

    // Draw some text and shapes
    ctx.textBaseline = "top";
    ctx.font = "14px Arial";
    ctx.fillStyle = "#f60";
    ctx.fillRect(125, 1, 62, 20);
    ctx.fillStyle = "#069";
    ctx.fillText("AntiFraud SDK", 2, 15);
    ctx.fillStyle = "rgba(102, 204, 0, 0.7)";
    ctx.fillText("AntiFraud SDK", 4, 17);

    return canvas.toDataURL();
  }

  private getWebGLFingerprint(): string {
    if (typeof document === "undefined") return "";

    const canvas = document.createElement("canvas");
    const gl =
      canvas.getContext("webgl") || canvas.getContext("experimental-webgl");

    if (!gl) return "";

    // Type assertion para WebGLRenderingContext
    const webglContext = gl as WebGLRenderingContext;
    const debugInfo = webglContext.getExtension("WEBGL_debug_renderer_info");
    if (!debugInfo) return "";

    return webglContext.getParameter(debugInfo.UNMASKED_RENDERER_WEBGL);
  }

  private getFontFingerprint(): string[] {
    if (typeof document === "undefined") return [];

    const testString = "abcdefghijklmnopqrstuvwxyz0123456789";
    const testSize = "72px";
    const h = document.getElementsByTagName("body")[0];
    const s = document.createElement("span");

    s.style.fontSize = testSize;
    s.innerHTML = testString;

    const defaultWidth: { [key: string]: number } = {};
    const defaultHeight: { [key: string]: number } = {};

    const defaultFonts = ["monospace", "sans-serif", "serif"];

    for (const font of defaultFonts) {
      s.style.fontFamily = font;
      h.appendChild(s);
      defaultWidth[font] = s.offsetWidth;
      defaultHeight[font] = s.offsetHeight;
      h.removeChild(s);
    }

    const detectedFonts: string[] = [];
    const fonts = [
      "Arial",
      "Arial Black",
      "Arial Narrow",
      "Arial Rounded MT Bold",
      "Calibri",
      "Cambria",
      "Candara",
      "Century Gothic",
      "Comic Sans MS",
      "Consolas",
      "Courier",
      "Courier New",
      "Franklin Gothic Medium",
      "Garamond",
      "Georgia",
      "Helvetica",
      "Impact",
      "Lucida Console",
      "Lucida Sans Unicode",
      "Microsoft Sans Serif",
      "Palatino Linotype",
      "Segoe UI",
      "Tahoma",
      "Times",
      "Times New Roman",
      "Trebuchet MS",
      "Verdana",
    ];

    for (const font of fonts) {
      let detected = false;
      for (const baseFont of defaultFonts) {
        s.style.fontFamily = font + "," + baseFont;
        h.appendChild(s);
        const matched =
          s.offsetWidth !== defaultWidth[baseFont] ||
          s.offsetHeight !== defaultHeight[baseFont];
        h.removeChild(s);
        if (matched) {
          detected = true;
          break;
        }
      }
      if (detected) {
        detectedFonts.push(font);
      }
    }

    return detectedFonts;
  }
}

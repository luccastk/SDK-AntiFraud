import IpVerifier from "./verifiers/IpVerifier/IpVerifier.js";
import AdvancedVerifier from "./verifiers/AdvancedVerifier/AdvancedVerifier.js";
import { FingerprintCollector } from "./collectors/FingerprintCollector.js";
import { Config } from "./config/Config.js";

// Export default (mantém compatibilidade)
export default IpVerifier;

// Export named exports para funcionalidades avançadas
export { AdvancedVerifier, FingerprintCollector, IpVerifier, Config };

// Export types
export type {
  DeviceFingerprint,
  BehaviorFingerprint,
  NetworkFingerprint,
  CompleteFingerprint,
} from "./collectors/FingerprintCollector.js";

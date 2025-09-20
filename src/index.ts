import { FingerprintCollector } from "./collectors/FingerprintCollector.js";
import AdvancedVerifier from "./verifiers/AdvancedVerifier/AdvancedVerifier.js";
import { Config } from "./config/Config.js";

// Export default
export default AdvancedVerifier;

// Export named exports
export { AdvancedVerifier, FingerprintCollector, Config };

// Export types
export type {
  BehaviorFingerprint,
  CompleteFingerprint,
  DeviceFingerprint,
  NetworkFingerprint,
} from "./collectors/FingerprintCollector.js";

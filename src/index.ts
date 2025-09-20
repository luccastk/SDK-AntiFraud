import { FingerprintCollector } from "./collectors/FingerprintCollector.js";
import AdvancedVerifier from "./verifiers/AdvancedVerifier/AdvancedVerifier.js";

// Export default
export default AdvancedVerifier;

// Export named exports
export { AdvancedVerifier, FingerprintCollector };

// Export types
export type {
  BehaviorFingerprint,
  CompleteFingerprint,
  DeviceFingerprint,
  NetworkFingerprint,
} from "./collectors/FingerprintCollector.js";

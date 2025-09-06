package br.com.api.kotlin.kotlin_api.dtos

data class CompleteFingerprintDTO(
    val device: DeviceFingerprintDTO,
    val behavior: BehaviorFingerprintDTO,
    val network: NetworkFingerprintDTO,
    val sessionId: String,
    val userId: String?
)

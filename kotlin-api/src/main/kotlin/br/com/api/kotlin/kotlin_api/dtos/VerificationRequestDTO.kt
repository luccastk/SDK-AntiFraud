package br.com.api.kotlin.kotlin_api.dtos

data class VerificationRequestDTO(
    val fingerprint: CompleteFingerprintDTO,
    val endpoint: String,
    val userId: String?
)

package br.com.api.kotlin.kotlin_api.dtos

import br.com.api.kotlin.kotlin_api.enums.IpStatus

data class VerificationResponseDTO(
    val status: IpStatus,
    val riskScore: Int,
    val reasons: List<String>,
    val sessionId: String,
    val timestamp: Long
)

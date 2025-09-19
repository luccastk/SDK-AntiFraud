package br.com.api.kotlin.kotlin_api.dtos

import br.com.api.kotlin.kotlin_api.enums.IpStatus
import io.swagger.v3.oas.annotations.media.Schema

@Schema(description = "DTO para resposta de verificação")
data class VerificationResponseDTO(
    @Schema(description = "Status da verificação", example = "ALLOW")
    val status: IpStatus,
    
    @Schema(description = "Pontuação de risco (0-100)", example = "25")
    val riskScore: Int,
    
    @Schema(description = "Lista de motivos para a decisão")
    val reasons: List<String>,
    
    @Schema(description = "ID da sessão")
    val sessionId: String,
    
    @Schema(description = "Timestamp da verificação")
    val timestamp: Long
)

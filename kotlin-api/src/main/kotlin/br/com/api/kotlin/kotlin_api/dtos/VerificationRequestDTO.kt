package br.com.api.kotlin.kotlin_api.dtos

import io.swagger.v3.oas.annotations.media.Schema

@Schema(description = "DTO para requisição de verificação avançada")
data class VerificationRequestDTO(
    @Schema(description = "Fingerprint completo do dispositivo e comportamento")
    val fingerprint: CompleteFingerprintDTO,
    
    @Schema(description = "Endpoint da requisição", example = "/login")
    val endpoint: String,
    
    @Schema(description = "ID do usuário (opcional)", example = "user123")
    val userId: String?
)

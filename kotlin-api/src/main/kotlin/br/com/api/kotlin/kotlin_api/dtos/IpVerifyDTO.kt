package br.com.api.kotlin.kotlin_api.dtos

import io.swagger.v3.oas.annotations.media.Schema

@Schema(description = "DTO para verificação de IP")
data class IpVerifyDTO(
    @Schema(description = "Endereço IP para verificação", example = "192.168.1.1")
    val ip: String
)

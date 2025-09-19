package br.com.api.kotlin.kotlin_api.controllers

import br.com.api.kotlin.kotlin_api.dtos.IpVerifyDTO
import br.com.api.kotlin.kotlin_api.dtos.IpVerifyView
import br.com.api.kotlin.kotlin_api.dtos.VerificationResponseDTO
import br.com.api.kotlin.kotlin_api.services.IpVerifyService
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.responses.ApiResponse
import io.swagger.v3.oas.annotations.responses.ApiResponses
import io.swagger.v3.oas.annotations.tags.Tag
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/verify-ip")
@Tag(name = "IP Verification", description = "Endpoints para verificação de IP e análise de risco")
class IpVerifyController(private val service: IpVerifyService) {

    @PostMapping
    @Operation(
        summary = "Verificar IP",
        description = "Verifica se um endereço IP é seguro ou representa risco de fraude"
    )
    @ApiResponses(
        value = [
            ApiResponse(responseCode = "200", description = "Verificação realizada com sucesso"),
            ApiResponse(responseCode = "400", description = "Dados de entrada inválidos")
        ]
    )
    fun verifyIp(@RequestBody dto: IpVerifyDTO): ResponseEntity<VerificationResponseDTO> {
        val result = service.verifyIp(dto)
        
        val response = VerificationResponseDTO(
            status = result.status,
            riskScore = when (result.status) {
                br.com.api.kotlin.kotlin_api.enums.IpStatus.ALLOW -> 0
                br.com.api.kotlin.kotlin_api.enums.IpStatus.REVIEW -> 50
                br.com.api.kotlin.kotlin_api.enums.IpStatus.DENY -> 100
            },
            reasons = when (result.status) {
                br.com.api.kotlin.kotlin_api.enums.IpStatus.ALLOW -> listOf("IP aprovado")
                br.com.api.kotlin.kotlin_api.enums.IpStatus.REVIEW -> listOf("IP em revisão")
                br.com.api.kotlin.kotlin_api.enums.IpStatus.DENY -> listOf("IP bloqueado")
            },
            sessionId = "",
            timestamp = System.currentTimeMillis()
        )
        
        return ResponseEntity.ok(response)
    }
}
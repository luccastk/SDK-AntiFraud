package br.com.api.kotlin.kotlin_api.controllers

import br.com.api.kotlin.kotlin_api.dtos.VerificationRequestDTO
import br.com.api.kotlin.kotlin_api.dtos.VerificationResponseDTO
import br.com.api.kotlin.kotlin_api.services.AdvancedVerificationService
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
@RequestMapping("/verify-fingerprint")
@Tag(name = "Advanced Verification", description = "Endpoints para verificação avançada de fingerprint e análise comportamental")
class AdvancedVerificationController(
    private val advancedVerificationService: AdvancedVerificationService
) {

    @PostMapping
    @Operation(
        summary = "Verificar Fingerprint",
        description = "Realiza verificação avançada baseada em fingerprint do dispositivo e comportamento do usuário"
    )
    @ApiResponses(
        value = [
            ApiResponse(responseCode = "200", description = "Verificação realizada com sucesso"),
            ApiResponse(responseCode = "400", description = "Dados de entrada inválidos ou erro na verificação")
        ]
    )
    fun verifyFingerprint(@RequestBody request: VerificationRequestDTO): ResponseEntity<VerificationResponseDTO> {
        return try {
            val result = advancedVerificationService.verifyFingerprint(request)
            ResponseEntity.ok(result)
        } catch (e: Exception) {
            println("Erro na verificação de fingerprint: ${e.message}")
            ResponseEntity.badRequest().build()
        }
    }
}

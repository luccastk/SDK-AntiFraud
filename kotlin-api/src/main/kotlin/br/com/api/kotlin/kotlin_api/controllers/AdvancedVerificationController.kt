package br.com.api.kotlin.kotlin_api.controllers

import br.com.api.kotlin.kotlin_api.dtos.VerificationRequestDTO
import br.com.api.kotlin.kotlin_api.dtos.VerificationResponseDTO
import br.com.api.kotlin.kotlin_api.services.AdvancedVerificationService
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/verify-fingerprint")
class AdvancedVerificationController(
    private val advancedVerificationService: AdvancedVerificationService
) {

    @PostMapping
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

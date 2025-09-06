package br.com.api.kotlin.kotlin_api.controllers

import br.com.api.kotlin.kotlin_api.dtos.IpVerifyDTO
import br.com.api.kotlin.kotlin_api.dtos.IpVerifyView
import br.com.api.kotlin.kotlin_api.dtos.VerificationResponseDTO
import br.com.api.kotlin.kotlin_api.services.IpVerifyService
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/verify-ip")
class IpVerifyController(private val service: IpVerifyService) {

    @PostMapping
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
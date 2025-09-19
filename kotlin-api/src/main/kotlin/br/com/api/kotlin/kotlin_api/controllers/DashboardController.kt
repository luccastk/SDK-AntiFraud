package br.com.api.kotlin.kotlin_api.controller

import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.responses.ApiResponse
import io.swagger.v3.oas.annotations.responses.ApiResponses
import io.swagger.v3.oas.annotations.tags.Tag
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter

@RestController
@RequestMapping("/")
@Tag(name = "Dashboard", description = "Endpoints para informações do sistema e status da API")
class DashboardController {

    @GetMapping
    @Operation(
        summary = "Status da API",
        description = "Retorna informações sobre o status da API Anti-Fraud"
    )
    @ApiResponses(
        value = [
            ApiResponse(responseCode = "200", description = "Informações do sistema retornadas com sucesso")
        ]
    )
    fun getApiStatus(): ResponseEntity<Map<String, Any>> {
        val status = mapOf(
            "service" to "SDK Anti-Fraud API",
            "version" to "1.0.0",
            "status" to "UP",
            "timestamp" to LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME),
            "endpoints" to listOf(
                "/verify-ip - Verificação de IP",
                "/verify-fingerprint - Verificação avançada de fingerprint",
                "/actuator/health - Health check do sistema"
            ),
            "features" to listOf(
                "IP Risk Analysis",
                "Device Fingerprinting",
                "Behavioral Analysis",
                "Real-time Verification"
            )
        )
        
        return ResponseEntity.ok(status)
    }

    @GetMapping("/health")
    @Operation(
        summary = "Health Check",
        description = "Endpoint simples para verificar se a API está funcionando"
    )
    @ApiResponses(
        value = [
            ApiResponse(responseCode = "200", description = "API funcionando corretamente")
        ]
    )
    fun healthCheck(): ResponseEntity<Map<String, String>> {
        val health = mapOf(
            "status" to "healthy",
            "service" to "anti-fraud-api",
            "timestamp" to System.currentTimeMillis().toString()
        )
        
        return ResponseEntity.ok(health)
    }

    @GetMapping("/info")
    @Operation(
        summary = "Informações da API",
        description = "Retorna informações detalhadas sobre a API e seus recursos"
    )
    @ApiResponses(
        value = [
            ApiResponse(responseCode = "200", description = "Informações detalhadas retornadas")
        ]
    )
    fun getApiInfo(): ResponseEntity<Map<String, Any>> {
        val info = mapOf(
            "name" to "SDK Anti-Fraud API",
            "description" to "API para verificação de fraude e análise de risco",
            "version" to "1.0.0",
            "build" to mapOf(
                "java" to System.getProperty("java.version"),
                "spring" to org.springframework.boot.SpringBootVersion.getVersion(),
                "kotlin" to kotlin.KotlinVersion.CURRENT
            ),
            "capabilities" to mapOf(
                "ipVerification" to "Análise de risco baseada em IP",
                "fingerprintAnalysis" to "Análise de fingerprint do dispositivo",
                "behavioralAnalysis" to "Análise comportamental do usuário",
                "realTimeScoring" to "Pontuação de risco em tempo real"
            )
        )
        
        return ResponseEntity.ok(info)
    }
}

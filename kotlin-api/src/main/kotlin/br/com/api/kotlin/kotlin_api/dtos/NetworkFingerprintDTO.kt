package br.com.api.kotlin.kotlin_api.dtos

data class NetworkFingerprintDTO(
    val ip: String,
    val connectionType: String?,
    val effectiveType: String?,
    val downlink: Double?,
    val rtt: Int?
)

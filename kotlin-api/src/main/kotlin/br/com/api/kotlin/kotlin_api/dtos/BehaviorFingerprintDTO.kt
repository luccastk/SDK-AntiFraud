package br.com.api.kotlin.kotlin_api.dtos

data class BehaviorFingerprintDTO(
    val mouseMovements: Int,
    val keystrokes: Int,
    val scrollEvents: Int,
    val clickEvents: Int,
    val focusEvents: Int,
    val sessionDuration: Long,
    val pageLoadTime: Double,
    val referrer: String,
    val timestamp: Long
)

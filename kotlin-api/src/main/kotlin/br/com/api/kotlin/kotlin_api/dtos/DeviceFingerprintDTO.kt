package br.com.api.kotlin.kotlin_api.dtos

data class DeviceFingerprintDTO(
    val userAgent: String,
    val language: String,
    val platform: String,
    val screenResolution: String,
    val timezone: String,
    val colorDepth: Int,
    val pixelRatio: Double,
    val hardwareConcurrency: Int,
    val maxTouchPoints: Int,
    val cookieEnabled: Boolean,
    val doNotTrack: String?,
    val plugins: List<String>,
    val fonts: List<String>,
    val canvas: String,
    val webgl: String
)

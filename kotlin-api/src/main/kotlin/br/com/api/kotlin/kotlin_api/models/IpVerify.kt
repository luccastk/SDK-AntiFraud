package br.com.api.kotlin.kotlin_api.models

import java.time.LocalDateTime

data class IpVerify(
    val id: Long? = null,
    val timeStamp: LocalDateTime = LocalDateTime.now(),
)

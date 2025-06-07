package br.com.api.kotlin.kotlin_api.controllers

import br.com.api.kotlin.kotlin_api.dtos.IpVerifyDTO
import br.com.api.kotlin.kotlin_api.dtos.IpVerifyView
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
    fun verifyIp(@RequestBody dto: IpVerifyDTO): ResponseEntity<IpVerifyView> {
        return ResponseEntity.ok(
            service.verifyIp(
                dto
            )
        )
    }
}
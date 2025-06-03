package br.com.api.kotlin.kotlin_api.controller

import br.com.api.kotlin.kotlin_api.service.IpVerifyService
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/verify-ip")
class IpVerifyController(private val service: IpVerifyService) {

    @PostMapping
    fun verifyIp(){
        service
    }
}
package br.com.api.kotlin.kotlin_api.service


import org.springframework.stereotype.Service
import java.net.URI
import java.net.http.HttpClient
import java.net.http.HttpRequest
import java.net.http.HttpResponse

@Service
class IpVerifyService {



    fun verifyIp(ip: String) {
        val client = HttpClient.newHttpClient()

        val request = HttpRequest.newBuilder()
            .uri(URI.create("https://http://ip-api.com/json/$ip"))
            .GET()
            .build()

        val response = client.send(request, HttpResponse.BodyHandlers.ofString())
    }
}
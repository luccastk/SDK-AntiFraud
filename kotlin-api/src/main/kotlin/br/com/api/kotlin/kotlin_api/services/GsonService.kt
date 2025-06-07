package br.com.api.kotlin.kotlin_api.services

import com.google.gson.Gson
import org.springframework.stereotype.Service

@Service
class GsonService(
    val gson: Gson = Gson()
) {

    fun <T> deserializer(json: String, o: Class<T>): T {
        return gson.fromJson<T>(json, o)
    }
}
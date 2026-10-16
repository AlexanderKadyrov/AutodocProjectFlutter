package com.autodoc.news.data.repository

import com.autodoc.news.data.model.AutodocNewsResponseDto
import io.ktor.client.*
import io.ktor.client.call.*
import io.ktor.client.plugins.contentnegotiation.*
import io.ktor.client.request.*
import io.ktor.serialization.kotlinx.json.*
import kotlinx.serialization.json.Json

class AutodocNewsRepository {

    private val httpClient = HttpClient {
        install(ContentNegotiation) {
            json(Json {
                ignoreUnknownKeys = true 
                coerceInputValues = true 
            })
        }
    }

    suspend fun getLiveNews(offset: Int, limit: Int): AutodocNewsResponseDto {
        val targetUrl = "https://webapi.autodoc.ru/api/news/$offset/$limit"
        return httpClient.get(targetUrl).body()
    }
}
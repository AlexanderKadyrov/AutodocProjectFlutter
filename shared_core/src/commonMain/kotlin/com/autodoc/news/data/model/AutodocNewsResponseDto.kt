package com.autodoc.news.data.model

import kotlinx.serialization.Serializable

@Serializable
data class AutodocNewsResponseDto(
    val totalCount: Int,
    val news: List<NewsItemDto>
)

@Serializable
data class NewsItemDto(
    val id: Long,
    val title: String,
    val description: String,
    val publishedDate: String,
    val url: String,
    val titleImageUrl: String?
)
package com.autodoc.news.interop

import com.autodoc.news.data.repository.AutodocNewsRepository
import autodoc.news.NewsRequest
import autodoc.news.NewsResponse
import autodoc.news.NewsItem
import kotlinx.coroutines.runBlocking
import kotlinx.cinterop.*
import kotlin.native.CName
import kotlin.experimental.ExperimentalNativeApi

private val autodocRepository = AutodocNewsRepository()

@OptIn(ExperimentalForeignApi::class, ExperimentalNativeApi::class)
@CName("native_fetch")
fun nativeFetch(
    actionPtr: CPointer<ByteVar>,
    requestBytesPtr: CPointer<ByteVar>,
    requestLength: Int,
    outLength: CPointer<IntVar>
): CPointer<ByteVar> {
    
    val action = actionPtr.toKStringFromUtf8() 
    var responseBytes = byteArrayOf()

    if (action == "get_news") {
        runBlocking {
            try {
                val rawRequest = requestBytesPtr.readBytes(requestLength)
                val requestParams = NewsRequest.ADAPTER.decode(rawRequest)

                val liveDto = autodocRepository.getLiveNews(requestParams.offset, requestParams.limit)

                val response = NewsResponse(
                    total_count = liveDto.totalCount,
                    news = liveDto.news.map { itemDto ->
                        NewsItem(
                            id = itemDto.id.toInt(),
                            title = itemDto.title,
                            description = itemDto.description,
                            published_date = itemDto.publishedDate,
                            category_url = itemDto.url,
                            image_url = itemDto.titleImageUrl ?: ""
                        )
                    }
                )
                responseBytes = response.encode()
            } catch (e: Exception) {
                responseBytes = NewsResponse(total_count = 0).encode()
            }
        }
    }

    outLength.pointed.value = responseBytes.size

    val nativeBuffer = nativeHeap.allocArray<ByteVar>(responseBytes.size)
    for (i in responseBytes.indices) {
        nativeBuffer[i] = responseBytes[i]
    }

    return nativeBuffer
}
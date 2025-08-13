package com.example.fruitties.network

import com.example.fruitties.di.MultipartBodyPart
import io.ktor.client.HttpClient
import io.ktor.client.request.forms.MultiPartFormDataContent
import io.ktor.client.request.forms.formData
import io.ktor.client.request.post
import io.ktor.client.request.setBody
import io.ktor.client.statement.HttpResponse
import io.ktor.http.cio.Response
import kotlinx.atomicfu.TraceBase.None.append

interface PhotoEnhancerApi {

    suspend fun process(image: MultipartBodyPart): HttpResponse

}


class PhotoEnhancerApiImpl(
    private val client: HttpClient,
    private val apiUrl: String,
) : PhotoEnhancerApi {
    override suspend fun process(image: MultipartBodyPart): HttpResponse {
        val response = client.post("$apiUrl/upload-image") {
            setBody(MultiPartFormDataContent(formData {
                append(image.part.key, image.part.value, image.part.headers)
            }))
        }
        return response
    }
}

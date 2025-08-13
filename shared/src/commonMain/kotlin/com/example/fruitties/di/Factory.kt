/*
 * Copyright 2024 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.example.fruitties.di

import com.example.fruitties.database.AppDatabase
import com.example.fruitties.database.CartDataStore
import com.example.fruitties.network.BgRemoverApi
import com.example.fruitties.network.BgRemoverApiImpl
import com.example.fruitties.network.FruittieApi
import com.example.fruitties.network.FruittieNetworkApi
import com.example.fruitties.network.PhotoEnhancerApi
import com.example.fruitties.network.PhotoEnhancerApiImpl
import io.ktor.client.HttpClient
import io.ktor.client.plugins.HttpTimeout
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.client.plugins.logging.LogLevel
import io.ktor.client.plugins.logging.Logger
import io.ktor.client.plugins.logging.Logging
import io.ktor.client.plugins.logging.SIMPLE
import io.ktor.client.request.forms.FormPart
import io.ktor.http.ContentType
import io.ktor.serialization.kotlinx.json.json
import kotlinx.serialization.json.Json

expect class Factory {
    fun createRoomDatabase(): AppDatabase

    fun createApi(): FruittieApi

    fun createEnhancerApi(): PhotoEnhancerApi

    fun createBgRemoverApi(): BgRemoverApi

    fun createCartDataStore(): CartDataStore
}

expect class PlatformImage {
    fun toFile(): File
}

expect class File {
    val path: String
    val name: String
    val parent: String?
}

expect class MultipartBodyPart {
    val part: FormPart<ByteArray>

    companion object {
        fun createFormData(name: String, filename: String?, body: ByteArray): MultipartBodyPart
    }
}

expect fun saveResponseStreamToPublicDirectory(data: ByteArray, fileName: String): Boolean
expect fun createPlatformFile(parent: String?, name: String): File

expect fun saveResponseStreamToFile(data: ByteArray, file: File)

expect fun File.toByteArray(): ByteArray

internal fun commonCreateApi(): FruittieApi =
    FruittieNetworkApi(
        client = HttpClient {
            install(ContentNegotiation) {
                json(json, contentType = ContentType.Any)
            }
        },
        apiUrl = "https://android.github.io/kotlin-multiplatform-samples/fruitties-api",
    )

internal fun commonEnhanceApi(): PhotoEnhancerApi =
    PhotoEnhancerApiImpl(
        client = HttpClient {
            install(ContentNegotiation) {
                json(json, contentType = ContentType.Any)
            }
            install(Logging) {
                logger = Logger.SIMPLE
                level = LogLevel.ALL
            }

            install(HttpTimeout) {
                requestTimeoutMillis = 1_800_000
                connectTimeoutMillis = 1_800_000
                socketTimeoutMillis = 1_800_000
            }
        },
        apiUrl = BASE_URL
    )

internal fun commonBgRemoverApi(): BgRemoverApi =
    BgRemoverApiImpl(
        client = HttpClient {
            install(ContentNegotiation) {
                json(json, contentType = ContentType.Any)
            }
        },
        apiUrl = BASE_URL_BG_REMOVE
    )


private const val BASE_URL = "https://pe-pro.niamtechnologies.com"
private const val BASE_URL_BG_REMOVE = "https://bg-pro.niamtechnologies.com"

val json = Json { ignoreUnknownKeys = true }

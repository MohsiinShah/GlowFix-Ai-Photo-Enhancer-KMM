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
package com.example.fruitties

import com.example.fruitties.database.AppDatabase
import com.example.fruitties.database.CartDataStore
import com.example.fruitties.di.File
import com.example.fruitties.di.MultipartBodyPart
import com.example.fruitties.di.PlatformImage
import com.example.fruitties.di.createPlatformFile
import com.example.fruitties.di.saveResponseStreamToFile
import com.example.fruitties.di.saveResponseStreamToPublicDirectory
import com.example.fruitties.di.toByteArray
import com.example.fruitties.model.CartItemDetails
import com.example.fruitties.model.Fruittie
import com.example.fruitties.network.BgRemoverApi
import com.example.fruitties.network.FruittieApi
import com.example.fruitties.network.PhotoEnhancerApi
import com.example.fruitties.viewmodel.PROCESSOR
import io.ktor.client.call.body
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.IO
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.mapLatest
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import kotlin.time.Clock
import kotlin.time.ExperimentalTime

class DataRepository(
    private val api: FruittieApi,
    private val enhanceApi: PhotoEnhancerApi,
    private val bgRemoveApi: BgRemoverApi,
    private var database: AppDatabase,
    private val cartDataStore: CartDataStore,
    private val scope: CoroutineScope,
) {
    @OptIn(ExperimentalCoroutinesApi::class)
    val cartDetails: Flow<List<CartItemDetails>>
        get() = cartDataStore.cart.mapLatest {
            val ids = it.items.map { it.id }
            val fruitties = database.fruittieDao().loadMapped(ids)
            it.items.mapNotNull {
                fruitties[it.id]?.let { fruittie ->
                    CartItemDetails(fruittie, it.count)
                }
            }
        }

    suspend fun addToCart(fruittie: Fruittie) {
        cartDataStore.add(fruittie)
    }

    suspend fun removeFromCart(fruittie: Fruittie) {
        cartDataStore.remove(fruittie)
    }

    fun getData(): Flow<List<Fruittie>> {
        scope.launch {
            if (database.fruittieDao().count() < 1) {
                refreshData()
            }
        }
        return loadData()
    }

    suspend fun getFruittie(id: Long): Fruittie? = database.fruittieDao().getFruittie(id)

    fun fruittieInCart(id: Long): Flow<Int> =
        cartDataStore.cart.map { cart ->
            cart.items.find { it.id == id }?.count ?: 0
        }

    fun loadData(): Flow<List<Fruittie>> = database.fruittieDao().getAllAsFlow()

    suspend fun refreshData() {
        val response = api.getData()
        database.fruittieDao().insert(response.feed)
    }


    @OptIn(ExperimentalTime::class)
    fun enhanceImage(
        image: PlatformImage,

        processor: PROCESSOR,
        onSuccess: (File) -> Unit,
        onError: (Throwable) -> Unit,
    ) {
        scope.launch(Dispatchers.IO) {
            try {
                val file = image.toFile()
                val requestBody = file.toByteArray()
                println("Request Body Size: ${requestBody.size}")
                val multipartBody =
                    MultipartBodyPart.createFormData("image", file.name, requestBody)
                println("Multi part value: ${multipartBody.part.value}")

                val response = if (processor == PROCESSOR.ENHANCE) enhanceApi.process(multipartBody)
                else bgRemoveApi.process(multipartBody)

                if (response.status.value == 200) {
                    val restoredFile =
                        createPlatformFile(file.parent, "${Clock.System.now()}_${file.name}")
                    saveResponseStreamToFile(response.body(), restoredFile)
                    withContext(Dispatchers.Main) {
                        onSuccess(restoredFile)
                    }
                } else {
                    withContext(Dispatchers.Main) {
                        onError(Exception("Upload failed with code: ${response.status.value}"))
                    }
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    onError(e)
                }
            }
        }
    }

    @OptIn(ExperimentalTime::class)
    fun downloadImage(
        image: PlatformImage,
        onSuccess: () -> Unit,
        onError: () -> Unit,
    ) {
        scope.launch(Dispatchers.IO) {
            val file = image.toFile()
            val downloaded = saveResponseStreamToPublicDirectory(file.toByteArray(), file.name)

            if (downloaded) {
                withContext(Dispatchers.Main) {
                    println("Platform File downloaded")
                    onSuccess()
                }
            } else {
                withContext(Dispatchers.Main) {
                    onSuccess()
                }
            }
        }

    }

}

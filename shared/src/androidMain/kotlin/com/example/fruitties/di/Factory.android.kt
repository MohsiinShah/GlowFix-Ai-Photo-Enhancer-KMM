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

import android.app.Application
import android.content.Context
import android.net.Uri
import android.os.Environment
import androidx.room.Room
import androidx.sqlite.driver.bundled.BundledSQLiteDriver
import com.example.fruitties.database.AppDatabase
import com.example.fruitties.database.CartDataStore
import com.example.fruitties.database.DB_FILE_NAME
import com.example.fruitties.network.BgRemoverApi
import com.example.fruitties.network.FruittieApi
import com.example.fruitties.network.PhotoEnhancerApi
import io.ktor.client.request.forms.FormPart
import io.ktor.http.Headers
import io.ktor.http.HttpHeaders
import kotlinx.coroutines.Dispatchers
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.MultipartBody
import okhttp3.RequestBody.Companion.toRequestBody
import java.io.FileOutputStream
import java.io.IOException

actual class Factory(
    private val app: Application,
) {
    actual fun createRoomDatabase(): AppDatabase {
        val dbFile = app.getDatabasePath(DB_FILE_NAME)
        return Room
            .databaseBuilder<AppDatabase>(
                context = app,
                name = dbFile.absolutePath,
            ).setDriver(BundledSQLiteDriver())
            .setQueryCoroutineContext(Dispatchers.IO)
            .build()
    }

    actual fun createCartDataStore(): CartDataStore =
        CartDataStore {
            app.filesDir
                .resolve(
                    "cart.json",
                ).absolutePath
        }

    actual fun createApi(): FruittieApi = commonCreateApi()

    actual fun createEnhancerApi(): PhotoEnhancerApi = commonEnhanceApi()

    actual fun createBgRemoverApi(): BgRemoverApi = commonBgRemoverApi()
}

actual class PlatformImage(
    private val uri: Uri,
    private val context: Context,
) {
    actual fun toFile(): File {
        val inputStream = context.contentResolver.openInputStream(uri)
            ?: throw IllegalStateException("Could not open input stream")
        val file = java.io.File(context.cacheDir, "temp_image_${System.currentTimeMillis()}.jpg")
        FileOutputStream(file).use { output ->
            inputStream.use { input ->
                input.copyTo(output)
            }
        }
        return File(file.absolutePath)
    }
}

// ✅ Common File wrapper for multiplatform
actual class File(actual val path: String) {
    internal val javaFile = java.io.File(path)
    actual val name: String get() = javaFile.name
    actual val parent: String? get() = javaFile.parent
}

// ✅ Create a file in parent directory (or temp)
actual fun createPlatformFile(parent: String?, name: String): File {
    val parentDir =
        parent?.let { java.io.File(it) } ?: java.io.File.createTempFile("temp", ".jpg").parentFile!!
    val targetFile = java.io.File(parentDir, name)
    return File(targetFile.absolutePath)
}

// ✅ Save ByteArray to File
actual fun saveResponseStreamToFile(data: ByteArray, file: File) {
    FileOutputStream(file.path).use { output ->
        output.write(data)
    }
}

actual fun saveResponseStreamToPublicDirectory(data: ByteArray, fileName: String): Boolean {
    // Get the public Documents directory
    val documentsDir =
        Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOCUMENTS)

    if (!documentsDir.exists()) {
        if (!documentsDir.mkdirs()) {
            throw IllegalStateException("Failed to create public Documents directory")
        }
    }

    val targetFile = java.io.File(documentsDir, fileName)

    try {
        FileOutputStream(targetFile).use { output ->
            output.write(data)
        }
        return true
    } catch (e: IOException) {
        e.printStackTrace()
        return false
    }
}

// ✅ Convert File to ByteArray
actual fun File.toByteArray(): ByteArray {
    return java.io.File(this.path).readBytes()
}

// ✅ MultipartBody.Part wrapper for Android
actual class MultipartBodyPart(
    actual val part: FormPart<ByteArray>, // Satisfies expect declaration
) {
    actual companion object {
        actual fun createFormData(
            name: String,
            filename: String?,
            body: ByteArray,
        ): MultipartBodyPart {
            val requestBody = body.toRequestBody("image/*".toMediaTypeOrNull())
            val okHttpPart = MultipartBody.Part.createFormData(name, filename, requestBody)
            val headers = Headers.build {
                if (filename != null) append(HttpHeaders.ContentDisposition, "filename=$filename")
            }
            return MultipartBodyPart(FormPart(name, body, headers))
        }
    }

    // Helper function to convert OkHttp's MultipartBody.Part to Ktor's FormPart<ByteArray>
    fun toOkHttpPart(): MultipartBody.Part {
        val requestBody = part.value.toRequestBody("image/*".toMediaTypeOrNull())
        return MultipartBody.Part.createFormData(part.key, null, requestBody)
    }
}

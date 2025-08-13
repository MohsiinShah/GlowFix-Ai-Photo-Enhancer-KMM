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
import kotlinx.cinterop.ByteVar
import kotlinx.cinterop.COpaquePointer
import kotlinx.cinterop.ExperimentalForeignApi
import kotlinx.cinterop.ObjCAction
import kotlinx.cinterop.addressOf
import kotlinx.cinterop.allocArray
import kotlinx.cinterop.memScoped
import kotlinx.cinterop.objc_release
import kotlinx.cinterop.objc_retain
import kotlinx.cinterop.refTo
import kotlinx.cinterop.usePinned
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.IO
import platform.Foundation.NSData
import platform.Foundation.NSDocumentDirectory
import platform.Foundation.NSDownloadsDirectory
import platform.Foundation.NSError
import platform.Foundation.NSFileManager
import platform.Foundation.NSTemporaryDirectory
import platform.Foundation.NSURL
import platform.Foundation.NSUserDomainMask
import platform.Foundation.data
import platform.Foundation.dataWithBytes
import platform.Foundation.dataWithContentsOfFile
import platform.Foundation.getBytes
import platform.Foundation.writeToFile
import platform.Foundation.writeToURL
import platform.UIKit.UIImage
import platform.UIKit.UIImageJPEGRepresentation
import platform.UIKit.UIImageWriteToSavedPhotosAlbum
import platform.darwin.NSObject
import platform.posix.memcpy
import kotlin.time.Clock
import kotlin.time.ExperimentalTime

actual class Factory {
    actual fun createRoomDatabase(): AppDatabase {
        val dbFile = "${fileDirectory()}/$DB_FILE_NAME"
        return Room
            .databaseBuilder<AppDatabase>(
                name = dbFile,
            ).setDriver(BundledSQLiteDriver())
            .setQueryCoroutineContext(Dispatchers.IO)
            .build()
    }

    actual fun createCartDataStore(): CartDataStore =
        CartDataStore {
            "${fileDirectory()}/cart.json"
        }

    @OptIn(ExperimentalForeignApi::class)
    private fun fileDirectory(): String {
        val documentDirectory: NSURL? = NSFileManager.defaultManager.URLForDirectory(
            directory = NSDocumentDirectory,
            inDomain = NSUserDomainMask,
            appropriateForURL = null,
            create = false,
            error = null,
        )
        return requireNotNull(documentDirectory).path!!
    }

    actual fun createApi(): FruittieApi = commonCreateApi()

    actual fun createEnhancerApi(): PhotoEnhancerApi = commonEnhanceApi()

    actual fun createBgRemoverApi(): BgRemoverApi = commonBgRemoverApi()
}

actual class PlatformImage(
    private val image: UIImage,
) {
    @OptIn(ExperimentalTime::class)
    actual fun toFile(): File {
        val data = UIImageJPEGRepresentation(image, 1.0)
            ?: throw IllegalStateException("Could not convert UIImage to data")
        val fileName = "temp_image_${Clock.System.now()}.jpg"
        val filePath = NSTemporaryDirectory() + fileName
        if (!data.writeToFile(filePath, true)) {
            throw IllegalStateException("Failed to write image to file")
        }
        return File(filePath)
    }
}

actual class File(actual val path: String) {
    actual val name: String
        get() = path.split("/").last()
    actual val parent: String?
        get() = NSFileManager.defaultManager.fileExistsAtPath(path).let {
            val components = path.split("/")
            if (components.size > 1) components.dropLast(1).joinToString("/") else null
        }
}

actual fun createPlatformFile(parent: String?, name: String): File {
    val parentDir = parent ?: NSTemporaryDirectory()
    val file = File("$parentDir/$name")
    println("Platform File Created AT: ${file.path}")
    return File("$parentDir/$name")
}
actual fun saveResponseStreamToFile(data: ByteArray, file: File) {
    val nsData = data.toNSData()
    nsData.writeToFile(file.path, true) || throw IllegalStateException("Failed to save file")
}


// Kotlin Native (iOS)

@OptIn(ExperimentalForeignApi::class)
actual fun saveResponseStreamToPublicDirectory(data: ByteArray, fileName: String): Boolean {
    try {
        val nsData = data.toNSData()
        val image = UIImage(data = nsData) ?: error("Invalid image data")

        UIImageWriteToSavedPhotosAlbum(image, null, null, null)

        return true
    }catch (e: Exception){
        e.printStackTrace()
        return false
    }
}



actual fun File.toByteArray(): ByteArray {
    return NSData.dataWithContentsOfFile(path)?.toByteArray()
        ?: throw IllegalStateException("Could not read file")
}

actual class MultipartBodyPart public constructor(
    actual val part: FormPart<ByteArray>,
) {
    actual companion object {
        actual fun createFormData(
            name: String,
            filename: String?,
            body: ByteArray,
        ): MultipartBodyPart {
            return MultipartBodyPart(FormPart(name, body, Headers.build {
                append(HttpHeaders.ContentDisposition, "filename=$filename")
            }))
        }
    }
}


@OptIn(ExperimentalForeignApi::class)
fun NSData.toByteArray(): ByteArray {
    val length = this.length.toInt()
    if (length == 0) return ByteArray(0)

    val bytes = ByteArray(length)
    bytes.usePinned { pinned ->
        this.getBytes(pinned.addressOf(0), length.toULong())
    }
    return bytes
}

@OptIn(ExperimentalForeignApi::class)
fun ByteArray.toNSData(): NSData {
    if (this.isEmpty()) return NSData.data()
    return memScoped {
        val buffer = allocArray<ByteVar>(this@toNSData.size)
        memcpy(buffer, this@toNSData.refTo(0), this@toNSData.size.toULong())
        NSData.dataWithBytes(buffer, this@toNSData.size.toULong())
    }
}
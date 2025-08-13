package com.example.fruitties.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import co.touchlab.kermit.Logger
import com.example.fruitties.DataRepository
import com.example.fruitties.di.File
import com.example.fruitties.di.PlatformImage
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

class PhotoEnhancerViewModel(private val repository: DataRepository): ViewModel() {
    init {
        Logger.v { "Photo Enhancer VM created" }
    }

    override fun onCleared() {
        super.onCleared()
        Logger.v { "Photo Enhancer VM cleared" }
    }
    private val _selectedProcessor = MutableStateFlow(PROCESSOR.ENHANCE)
    val selectedProcessor: StateFlow<PROCESSOR> = _selectedProcessor

    val processingState: MutableStateFlow<ProcessingState> = MutableStateFlow(ProcessingState.Idle)

    fun enhanceImage(platformImage: PlatformImage, processor: PROCESSOR){
        viewModelScope.launch {
            processingState.emit(ProcessingState.Processing)
            repository.enhanceImage(platformImage, processor, onSuccess = {file ->
                println( "enhanceImage: Success")
                viewModelScope.launch {
                    processingState.emit(ProcessingState.Success(file = file))
                }

            }, onError = { exception ->
                viewModelScope.launch {
                processingState.emit(ProcessingState.Failure(message = exception.message.toString()))
}
            })
        }
    }

    fun downloadImage(platformImage: PlatformImage){
        viewModelScope.launch {
            processingState.emit(ProcessingState.Processing)
            repository.downloadImage(platformImage, onSuccess = {
                println( "enhanceImage: Success")
                viewModelScope.launch {
                    processingState.emit(ProcessingState.Success(file = null))
                }

            }, onError = {
                viewModelScope.launch {
                    processingState.emit(ProcessingState.Failure(message = "Failed to download"))
                }
            })
        }
    }

    fun clearState(){
        viewModelScope.launch {
            processingState.value = ProcessingState.Idle
        }
    }
}

sealed class ProcessingState {
    data object Idle : ProcessingState()

    data object Processing: ProcessingState()
    data class Success(
        val file: File?
    ) : ProcessingState()

    data class Failure(
        val message: String
    ): ProcessingState()
}

enum class PROCESSOR{
    ENHANCE,
    BACKGROUND_REMOVER
}
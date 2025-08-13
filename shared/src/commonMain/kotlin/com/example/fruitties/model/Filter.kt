package com.example.fruitties.model

import com.example.fruitties.utils.FilterType

data class Filter(val type: FilterType, val intensity: Float = 1.0f)

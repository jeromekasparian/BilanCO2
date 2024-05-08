package com.example.bilanco2.data

import androidx.compose.ui.graphics.Color
import com.example.bilanco2.ui.theme.Indigo

data class Category(
    val id: Int = 0,
    val name: String
) {
    companion object {
        val mainColorDefault: Color = Indigo
        val headerTextColorDefault = Color.White
    }
}

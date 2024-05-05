package com.example.bilanco2prototype.ui

import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.example.bilanco2prototype.data.Category
import kotlin.math.roundToInt

@Composable
fun CategoryCardHeader(
    name: String,
    values: List<Float>,
    modifier: Modifier = Modifier,
    mainColor: Color = Category.mainColorDefault,
    textColor: Color = Category.headerTextColorDefault
) {
    Surface(color = mainColor) {
        val sum = values.sumOf { it.toDouble() }.toFloat() // TODO: remplacer par vrai calcul
        Text(
            text = "$name: ${sum.roundToInt()}",
            fontSize = MaterialTheme.typography.titleLarge.fontSize,
            fontWeight = FontWeight.Bold,
            color = textColor,
            modifier = modifier
                .fillMaxWidth()
                .padding(8.dp)
        )
    }
}
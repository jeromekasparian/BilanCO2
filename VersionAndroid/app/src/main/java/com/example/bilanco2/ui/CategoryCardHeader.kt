package com.example.bilanco2.ui

import android.annotation.SuppressLint
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
import com.example.bilanco2.data.Category
import kotlin.math.roundToInt

@SuppressLint("DefaultLocale")
@Composable
fun CategoryCardHeader(
    name: String,
    scaledEmissions: List<Double>,
    totalEmissions: Double,
    modifier: Modifier = Modifier,
    mainColor: Color = Category.mainColorDefault,
    textColor: Color = Category.headerTextColorDefault
) {
    Surface(color = mainColor) {
        val percentage =
            if (totalEmissions != 0.0) 100 * scaledEmissions.sumOf { it } / totalEmissions
            else 0.0

        Text(
            text = "$name " +
                if (percentage == 0.0) ""
                else if (percentage < 1.0) "(<1 %)"
                else String.format("(%d %%)", percentage.roundToInt()),
            fontSize = MaterialTheme.typography.titleLarge.fontSize,
            fontWeight = FontWeight.Bold,
            color = textColor,
            modifier = modifier
                .fillMaxWidth()
                .padding(8.dp)
        )
    }
}
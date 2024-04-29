package com.example.bilanco2prototype.ui

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Slider
import androidx.compose.material3.SliderDefaults
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.example.bilanco2prototype.data.Category

@Composable
fun CategoryCardField(
    text: String,
    min: Float,
    max: Float,
    sliderPosition: Float,
    onSliderPositionChanged: (Float) -> Unit,
    modifier: Modifier = Modifier,
    color: Color = Category.mainColorDefault,
) {
    Surface(color = Color.Transparent) {
        Column(
            modifier = modifier.padding(start = 24.dp)
        ) {
            Text(
                text = text,
                fontSize = MaterialTheme.typography.bodyLarge.fontSize,
                modifier = modifier.padding(top = 8.dp)
            )
            Slider(
                value = sliderPosition,
                valueRange = min .. max,
                steps = max.toInt() - 1,
                onValueChange = onSliderPositionChanged,
                colors = SliderDefaults.colors().copy(
                    thumbColor = color,
                    activeTrackColor = color,
                    inactiveTrackColor = Color.White.copy(alpha = 0.4f),
                    activeTickColor = Color.Transparent,
                    inactiveTickColor = Color.Transparent,
                    disabledActiveTickColor = Color.Transparent,
                    disabledInactiveTickColor = Color.Transparent
                ),
                modifier = modifier
                    .padding(end = 48.dp)
            )
        }
    }
}

package com.example.bilanco2prototype.ui

import androidx.compose.foundation.Image
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Slider
import androidx.compose.material3.SliderDefaults
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.dp
import com.example.bilanco2prototype.R
import com.example.bilanco2prototype.data.Category

@Composable
fun CategoryCardField(
    text: String,
    icon: String,
    info: String,
    min: Float,
    max: Float,
    sliderPosition: Float,
    onSliderPositionChanged: (Float) -> Unit,
    modifier: Modifier = Modifier,
    color: Color = Category.mainColorDefault,
) {
    Surface(color = Color.Transparent) {
        Column(modifier = modifier.padding(start = 24.dp)) {
            Row {
                Text(
                    text = text,
                    fontSize = MaterialTheme.typography.bodyLarge.fontSize,
                    modifier = Modifier
                        .weight(1f)
                        .padding(top = 8.dp)
                )

                var showDialog by rememberSaveable { mutableStateOf(false) }
                // val context = LocalContext.current

                Image(
                    painter = painterResource(id = R.drawable.baseline_info_outline_24),
                    contentDescription = "info_icon",
                    modifier = Modifier
                        .padding(top = 8.dp, end = 8.dp)
                        .clickable { showDialog = true }
                )

                if (showDialog) {
                    AlertDialog(
                        onDismissRequest = { showDialog = false },
                        title = { Text(text = "Information") }, // TODO: à localiser
                        text = { Text(
                            text = info,
                            fontSize = MaterialTheme.typography.bodyLarge.fontSize)
                        },
                        confirmButton = { }
                    )
                }
            }

            Row {
                Text(
                    text = icon,
                    fontSize = MaterialTheme.typography.bodyLarge.fontSize,
                    modifier = Modifier.align(Alignment.CenterVertically)
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
                        .padding(end = 48.dp, start = 6.dp)
                )
            }
        }
    }
}
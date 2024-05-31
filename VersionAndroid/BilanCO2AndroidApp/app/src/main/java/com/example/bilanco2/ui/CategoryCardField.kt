/*
 *  This is an android port of the application Bilan CO2, originally
 *  written by Prof. Jérôme Kasparian.
 *
 *  Copyright (C) 2024 Imad Eddine Bouibed, Liam Burke
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

package com.example.bilanco2.ui

import android.annotation.SuppressLint
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
import com.example.bilanco2.R
import com.example.bilanco2.data.Category

@SuppressLint("DefaultLocale")
@Composable
fun CategoryCardField(
    fieldId: Int,
    text: String,
    icon: String,
    info: String,
    min: Float,
    max: Float,
    scaled: Map<Int, Double>,
    total: Double,
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
                    colors = SliderDefaults.colors(
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
            val scaledValue = scaled.getValue(fieldId)
            if((total != 0.0) and (scaledValue != 0.0)) {
                val percentage = 100 * scaledValue / total
                Row {
                    Text( // TODO: translate "eq. CO2" properly and handle units (kg, ton etc.)
                        text = String.format("%.0f kg eq. CO2 ", scaledValue) + String.format(
                            if(percentage < 1.0) "(<1 %%)" else "(%.0f %%)", percentage
                        ),
                        color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.7f),
                        modifier = modifier.padding(bottom = 6.dp)
                    )
                }
            }
        }
    }
}
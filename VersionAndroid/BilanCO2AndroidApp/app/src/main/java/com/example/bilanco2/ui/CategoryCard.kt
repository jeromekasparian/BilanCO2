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

import androidx.compose.foundation.layout.Column
import androidx.compose.material3.Divider
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import com.example.bilanco2.data.Category
import com.example.bilanco2.data.Field

@Composable
fun CategoryCard(
    name: String,
    fields: List<Field>,
    totalEmissions: Double,
    scaledEmissions: Map<Int, Double>,
    onSliderPositionChanged : (Field, Float) -> Unit,
    mainColor: Color = Category.mainColorDefault,
    headerTextColor: Color = Category.headerTextColorDefault
) {
    Surface(color = mainColor.copy(alpha = 0.3f)) {
        Column {
            CategoryCardHeader(
                name = name,
                scaledEmissions = scaledEmissions.values.toList(),
                totalEmissions = totalEmissions,
                mainColor = mainColor,
                textColor = headerTextColor
            )
            Column {
                val first: Field = fields.first()
                CategoryCardField(
                    fieldId = first.fieldId,
                    text = first.toString(),
                    icon = first.icon,
                    info = first.info,
                    min = first.min,
                    max = first.max,
                    scaled = scaledEmissions,
                    total = totalEmissions,
                    sliderPosition = first.value,
                    onSliderPositionChanged = { value ->
                        onSliderPositionChanged(first, value)
                    },
                    color = mainColor
                )
                fields.drop(1).forEach { field ->
                    Divider(
                        color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.2f)
                    )

                    CategoryCardField(
                        fieldId = field.fieldId,
                        text = field.toString(),
                        icon = field.icon,
                        info = field.info,
                        min = field.min,
                        max = field.max,
                        scaled = scaledEmissions,
                        total = totalEmissions,
                        sliderPosition = field.value,
                        onSliderPositionChanged = { value ->
                            onSliderPositionChanged(field, value)
                        },
                        color = mainColor
                    )
                }
            }
        }
    }
}

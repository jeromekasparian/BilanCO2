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

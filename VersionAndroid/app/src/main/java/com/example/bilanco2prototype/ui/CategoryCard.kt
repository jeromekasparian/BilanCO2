package com.example.bilanco2prototype.ui

import androidx.compose.foundation.layout.Column
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import com.example.bilanco2prototype.data.Category
import com.example.bilanco2prototype.data.Field

@Composable
fun CategoryCard(
    name: String,
    fields: List<Field>,
    onSliderPositionChanged : (Field, Float) -> Unit,
    mainColor: Color = Category.mainColorDefault,
    headerTextColor: Color = Category.headerTextColorDefault
) {
    Surface(color = mainColor.copy(alpha = 0.3f)) {
        Column {
            CategoryCardHeader(
                name = name,
                values = fields.map { field -> field.value },
                mainColor = mainColor,
                textColor = headerTextColor
            )
            Column {
                val first: Field = fields.first()
                CategoryCardField(
                    text = first.toString(),
                    icon = first.icon,
                    info = first.info,
                    min = first.min,
                    max = first.max,
                    sliderPosition = first.value,
                    onSliderPositionChanged = { value ->
                        onSliderPositionChanged(first, value)
                    },
                    color = mainColor
                )
                fields.drop(1).forEach { field ->
                    HorizontalDivider(
                        color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.2f)
                    )
                    CategoryCardField(
                        text = field.toString(),
                        icon = field.icon,
                        info = field.info,
                        min = field.min,
                        max = field.max,
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

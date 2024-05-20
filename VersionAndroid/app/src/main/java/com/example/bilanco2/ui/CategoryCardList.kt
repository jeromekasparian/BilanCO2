package com.example.bilanco2.ui

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import com.example.bilanco2.data.Category
import com.example.bilanco2.data.Field

@Composable
fun CategoryCardList(
    categories: List<Category>,
    fields: List<Field>,
    scaledEmissions: Map<Int, Double>,
    totalEmissions: Double,
    onSliderPositionChanged: (Field, Float) -> Unit,
    colors: List<Color> = listOf(Category.mainColorDefault)
) {
    Column(modifier = Modifier.verticalScroll(rememberScrollState())) {
        var categoryFields: List<Field>
        for (category in categories) {
            categoryFields = fields.filter { field -> field.categoryId == category.id }
            CategoryCard(
                name = category.name,
                fields = categoryFields,
                scaledEmissions = scaledEmissions.filter {
                    categoryFields.map { field -> field.fieldId }.contains(it.key)
                },
                totalEmissions = totalEmissions,
                onSliderPositionChanged = onSliderPositionChanged,
                mainColor = colors[category.id % colors.size]
            )
        }
    }
}

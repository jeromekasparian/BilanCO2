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
    onSliderPositionChanged: (Field, Float) -> Unit,
    colors: List<Color> = listOf(Category.mainColorDefault)
) {
    Column(modifier = Modifier.verticalScroll(rememberScrollState())) {
        for (category in categories) {
            CategoryCard(
                name = category.name,
                fields = fields.filter { field -> field.categoryId == category.id },
                onSliderPositionChanged = onSliderPositionChanged,
                mainColor = colors[category.id % colors.size]
            )
        }
    }
}

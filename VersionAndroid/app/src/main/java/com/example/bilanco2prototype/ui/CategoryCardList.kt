package com.example.bilanco2prototype.ui

import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import com.example.bilanco2prototype.data.Category
import com.example.bilanco2prototype.data.Field

@Composable
fun CategoryCardList(
    categories: List<Category>,
    fields: List<Field>,
    onSliderPositionChanged: (Field, Float) -> Unit,
    colors: List<Color> = listOf(Category.mainColorDefault)
) {
    LazyColumn {
        items(categories) { category ->
            CategoryCard(
                name = category.name,
                fields = fields.filter { field -> field.categoryId == category.id },
                onSliderPositionChanged = onSliderPositionChanged,
                mainColor = colors[category.id % colors.size]
            )
        }
    }
}

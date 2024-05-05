package com.example.bilanco2prototype.ui

import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.bilanco2prototype.data.Category
import com.example.bilanco2prototype.data.Field
import com.example.bilanco2prototype.data.FieldViewModel

@Composable
fun MainScreen(
    categories: List<Category>,
    fields: List<Field>,
    colors: List<Color> = listOf(Category.mainColorDefault),
    fieldViewModel: FieldViewModel = viewModel(),
) {
    fieldViewModel.populate(fields)
    Surface(
        modifier = Modifier.fillMaxSize(),
        color = MaterialTheme.colorScheme.background
    ) {
        CategoryCardList(
            categories = categories,
            fields = fieldViewModel.fields,
            onSliderPositionChanged = { field, value ->
                fieldViewModel.sliderPositionChanged(field, value)
            },
            colors = colors
        )
    }
}
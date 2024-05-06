package com.example.bilanco2.ui

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.bilanco2.data.Category
import com.example.bilanco2.data.Field
import com.example.bilanco2.data.FieldViewModel
import com.example.bilanco2.ui.CategoryCardList
import com.example.bilanco2.ui.TotalCard
import kotlin.math.roundToInt

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
        Column {
            val total = fieldViewModel.fields
                .map { field -> field.value }
                .sumOf { it.toDouble() }
                .roundToInt()
            TotalCard(total)
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
}
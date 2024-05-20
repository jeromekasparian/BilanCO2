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
import com.example.bilanco2.data.scaledEmissions
import com.example.bilanco2.data.totalEmissions
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
            val scaledEmissions = scaledEmissions(
                fieldViewModel.fields,
                durationId = 0,
                participationId = 1
            )
            val totalEmissions = totalEmissions(scaledEmissions)
            TotalCard(totalEmissions)
            CategoryCardList(
                categories = categories,
                fields = fieldViewModel.fields,
                scaledEmissions = scaledEmissions,
                totalEmissions = totalEmissions,
                onSliderPositionChanged = { field, value ->
                    fieldViewModel.sliderPositionChanged(field, value)
                },
                colors = colors
            )
        }
    }
}
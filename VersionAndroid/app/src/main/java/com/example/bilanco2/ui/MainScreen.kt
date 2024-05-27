package com.example.bilanco2.ui

import android.os.Build
import androidx.annotation.RequiresApi
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.lifecycle.viewmodel.compose.viewModel
//import com.example.bilanco2.ColorManager
import com.example.bilanco2.data.Category
import com.example.bilanco2.data.Field
import com.example.bilanco2.data.FieldViewModel
import com.example.bilanco2.data.scaledEmissions
import com.example.bilanco2.data.totalEmissions

@RequiresApi(Build.VERSION_CODES.O)
@Composable
fun MainScreen(
    categories: List<Category>,
    fields: List<Field>,
    colors: List<Color> = listOf(Category.mainColorDefault),
    colorsFields: List<Color>,
    iconsField: List<String>,
    fieldViewModel: FieldViewModel = viewModel(),) {
    fieldViewModel.populate(fields)
    Surface(
        modifier = Modifier.fillMaxSize(),
        color = MaterialTheme.colorScheme.background
    ) {
        val durationId = 0
        val participationId = 1
        Column {
            val scaledEmissions = scaledEmissions(
                fields = fieldViewModel.fields,
                durationId = durationId,
                participationId = participationId
            )
            val totalEmissions = totalEmissions(scaledEmissions)

            PieChart(
                values = scaledEmissions.values.map { it.toFloat() },
                colors = colorsFields,
                icons = iconsField
            )

            TotalCard(
                total = totalEmissions,
                participation = fieldViewModel.fields.find
                    { it.fieldId == participationId }?.value?.toDouble() ?: 0.0,
                duration = fieldViewModel.fields.find
                    { it.fieldId == durationId }?.value?.toDouble() ?: 0.0
            )

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
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

import android.content.res.Configuration
import android.os.Build
import androidx.annotation.RequiresApi
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.IntrinsicSize
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
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
        val dayCount = fields.get(0).value.toInt()

        val scaledEmissions = scaledEmissions(
            fields = fieldViewModel.fields,
            durationId = durationId,
            participationId = participationId
        )
        val totalEmissions = totalEmissions(scaledEmissions)
        val daysOfAcceptableEmissions = totalEmissions/5.4795 // total / (2 tonnes per year in kg/day)

        val orientation = LocalConfiguration.current.orientation

        if (orientation == Configuration.ORIENTATION_LANDSCAPE) {
            Row(modifier = Modifier.fillMaxSize()) {
                Column(modifier = Modifier.weight(3f)) {
                    PieChart(
                        values = scaledEmissions.values.map { it.toFloat() },
                        colors = colorsFields,
                        icons = iconsField,
                        daysOfAcceptableEmission = daysOfAcceptableEmissions,
                        daysActual = dayCount,
                        modifier = Modifier
                            .padding(top = 4.dp)
                            .align(Alignment.CenterHorizontally)
                    )
                    TotalCard(
                        total = totalEmissions,
                        daysOfAcceptableEmissions = daysOfAcceptableEmissions,
                        participation = fieldViewModel.fields.find { it.fieldId == participationId }?.value?.toDouble() ?: 0.0,
                        duration = fieldViewModel.fields.find { it.fieldId == durationId }?.value?.toDouble() ?: 0.0,
                    )
                }
                Column(modifier = Modifier.weight(5f)) {
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

        else {      // Orientation is Portrait
            Column {
                Row(
                    modifier =
                    Modifier
                        .fillMaxWidth()
                        .height(IntrinsicSize.Min)

                ) {
                    PieChart(
                        values = scaledEmissions.values.map { it.toFloat() },
                        colors = colorsFields,
                        icons = iconsField,
                        daysOfAcceptableEmission = daysOfAcceptableEmissions,
                        daysActual = dayCount,
                        modifier =
                        Modifier.padding(horizontal = 4.dp, vertical = 4.dp)
                    )

                    TotalCard(
                        total = totalEmissions,
                        daysOfAcceptableEmissions = daysOfAcceptableEmissions,
                        participation = fieldViewModel.fields.find { it.fieldId == participationId }?.value?.toDouble() ?: 0.0,
                        duration = fieldViewModel.fields.find { it.fieldId == durationId }?.value?.toDouble() ?: 0.0
                    )
                }

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
}
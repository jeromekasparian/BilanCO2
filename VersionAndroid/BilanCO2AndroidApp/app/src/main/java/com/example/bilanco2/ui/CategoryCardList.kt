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

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

import android.annotation.SuppressLint
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.example.bilanco2.data.Category
import kotlin.math.roundToInt

@SuppressLint("DefaultLocale")
@Composable
fun CategoryCardHeader(
    name: String,
    scaledEmissions: List<Double>,
    totalEmissions: Double,
    modifier: Modifier = Modifier,
    mainColor: Color = Category.mainColorDefault,
    textColor: Color = Category.headerTextColorDefault
) {
    Surface(color = mainColor) {
        val percentage =
            if (totalEmissions != 0.0) 100 * scaledEmissions.sumOf { it } / totalEmissions
            else 0.0

        Text(
            text = "$name " +
                if (percentage == 0.0) ""
                else if (percentage < 1.0) "(<1 %)"
                else String.format("(%d %%)", percentage.roundToInt()),
            fontSize = MaterialTheme.typography.titleLarge.fontSize,
            fontWeight = FontWeight.Bold,
            color = textColor,
            modifier = modifier
                .fillMaxWidth()
                .padding(8.dp)
        )
    }
}
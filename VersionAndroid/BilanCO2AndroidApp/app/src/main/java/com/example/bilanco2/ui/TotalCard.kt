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
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.wrapContentSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.withStyle
import com.example.bilanco2.R
import com.example.bilanco2.ui.theme.Red
import kotlin.math.roundToInt

@Composable
fun TotalCard(
    total: Double,
    participation: Double,
    duration: Double,
    daysOfAcceptableEmissions: Double
) {
    val perPerson = if (participation != 0.0) total/participation else 0.0

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .fillMaxHeight()
            .wrapContentSize(Alignment.Center),

    ) {
        Text(
            text = buildAnnotatedString {
                withStyle(style = SpanStyle(fontSize = MaterialTheme.typography.titleLarge.fontSize)) {
                    append("CO2: ${total.roundToInt()} kg\n")
                }
                withStyle(style = SpanStyle(fontSize = MaterialTheme.typography.bodyLarge.fontSize)) {
                    append(
                        "${perPerson.roundToInt()} " +
                        stringResource(id = R.string.kgPerson) + "\n" +
                        stringResource(id = R.string.equivalence1) +
                        " ${duration.roundToInt()} " +
                        stringResource(id = R.string.equivalence2) +
                        " ${daysOfAcceptableEmissions.roundToInt()} " +
                        stringResource(id = R.string.equivalence3)
                    )
                }
            },
            color = Red,
            fontSize = MaterialTheme.typography.bodyLarge.fontSize,
            textAlign = TextAlign.Center,
        )
    }
}
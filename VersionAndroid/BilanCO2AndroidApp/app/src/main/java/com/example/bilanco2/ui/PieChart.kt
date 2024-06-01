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

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Paint
import androidx.compose.ui.graphics.drawscope.Fill
import androidx.compose.ui.graphics.nativeCanvas
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.bilanco2.R
import kotlin.math.cos
import kotlin.math.sin

@Composable
fun PieChart(
    values: List<Float>,
    colors: List<Color>,
    icons: List<String>,    // Added color attribute for chart
    daysOfAcceptableEmission: Double,
    daysActual: Int,

    modifier: Modifier = Modifier,
) {
    val total = values.sum()
    val angles = values.map { 360 * it / total }
    val separationAngle = 1f // Angle/thickness of the separating lines between slices

    // Determine the center text/icon and it's size to display based on the total
    val (centerIconSize, centerIcon) = when {
        total == 0f -> 18.sp to stringResource(id = R.string.emptyChart)
        daysActual >= daysOfAcceptableEmission -> 35.sp to "\uD83D\uDC4D"
        else -> 35.sp to "\uD83D\uDC4E"
    }

    Canvas(
        modifier = modifier.size(200.dp)
    ) {
        val radius = size.minDimension / 2
        val centerX = size.width / 2
        val centerY = size.height / 2

        var startAngle = 0f
        for (i in angles.indices) {
            if (values[i] > 0) {
                // Draw the colored arc slice
                drawArc(
                    color = colors[i],
                    startAngle = startAngle,
                    sweepAngle = angles[i] - separationAngle,
                    useCenter = true
                )

                // Draw the separating line as a small black arc/slice
                drawArc(
                    color = Color.Black,
                    startAngle = startAngle + angles[i] - separationAngle,
                    sweepAngle = separationAngle,
                    useCenter = true
                )

                // Here you can adjust the position of icon pushing it to outer or inner by changing 0.7
                val middleAngle = startAngle + (angles[i] / 2)  //  middle angle for the icon position
                val angleInRad = Math.toRadians(middleAngle.toDouble())
                val textX = (centerX + (radius / 1.35) * cos(angleInRad)).toFloat() // change value here to push in or out
                val textY = (centerY + (radius / 1.35) * sin(angleInRad)).toFloat()

                // Draw the icon if it takes more than x degrees of the pie
                if (angles[i] > 30) {
                    drawContext.canvas.nativeCanvas.drawText(
                        icons[i],
                        textX,
                        textY + 14.sp.toPx() / 3, // Adjust the Y offset as needed to center the text vertically
                        Paint().asFrameworkPaint().apply {
                            isAntiAlias = true
                            textAlign = android.graphics.Paint.Align.CENTER
                            textSize = 20.sp.toPx()
                            color = android.graphics.Color.BLACK
                        }
                    )
                }

                startAngle += angles[i]
            }
        }
        // Draw the white circle in the center
        drawCircle(
            color = Color.White,
            radius = radius / 2.8f, // Adjust the size of the inner circle as needed
            center = androidx.compose.ui.geometry.Offset(centerX, centerY),
            style = Fill
        )

        // Draw the center thumb icon inside the white circle
        drawContext.canvas.nativeCanvas.drawText(
            centerIcon,
            centerX,
            centerY + 12.sp.toPx(), // Adjust the Y offset as needed to center the text vertically
            Paint().asFrameworkPaint().apply {
                isAntiAlias = true
                textAlign = android.graphics.Paint.Align.CENTER
                textSize = centerIconSize.toPx()
                color = android.graphics.Color.BLACK
            }
        )
    }
}

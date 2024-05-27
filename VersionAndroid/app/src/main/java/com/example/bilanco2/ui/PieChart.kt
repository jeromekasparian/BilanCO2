package com.example.bilanco2.ui

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
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
    modifier: Modifier = Modifier
) {
    val total = values.sum()
    val angles = values.map { 360 * it / total }
    val separationAngle = 1f // Angle for the separating lines

    // Determine the text to display based on the total
    val centerIcon = when {
        total == 0f -> stringResource(id = R.string.emptyChart)
        total < 100 -> "\uD83D\uDC4D"
        else -> "\uD83D\uDC4E"
    }

    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.Center
    ) {
        Canvas(
            modifier = modifier.size(200.dp)
        ) {
            val radius = size.minDimension / 2
            val centerX = size.width / 2
            val centerY = size.height / 2

            var startAngle = 0f
            for (i in angles.indices) {
                if (values[i] > 0) {
                    // Draw the colored arc
                    drawArc(
                        color = colors[i],
                        startAngle = startAngle,
                        sweepAngle = angles[i] - separationAngle,
                        useCenter = true
                    )

                    // Draw the separating line as a small black arc
                    drawArc(
                        color = Color.Black,
                        startAngle = startAngle + angles[i] - separationAngle,
                        sweepAngle = separationAngle,
                        useCenter = true
                    )

                    // Calculate the middle angle for the text position
                    val middleAngle = startAngle + (angles[i] / 2)

                    // Calculate the position for the text
                    // Here you can adjust the placement of icon pushing it to outer or inner by changing 0.7
                    val angleInRad = Math.toRadians(middleAngle.toDouble())
                    val textX = (centerX + (radius / 1.35) * cos(angleInRad)).toFloat()
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

            // Draw the text "No" inside the white circle
            drawContext.canvas.nativeCanvas.drawText(
                centerIcon,
                centerX,
                centerY + 12.sp.toPx(), // Adjust the Y offset as needed to center the text vertically
                Paint().asFrameworkPaint().apply {
                    isAntiAlias = true
                    textAlign = android.graphics.Paint.Align.CENTER
                    textSize = 35.sp.toPx()
                    color = android.graphics.Color.BLACK
                }
            )
        }
    }
}

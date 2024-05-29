package com.example.bilanco2.ui

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
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
import androidx.compose.ui.unit.dp
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
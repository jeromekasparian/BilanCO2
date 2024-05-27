package com.example.bilanco2.ui

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextAlign
import com.example.bilanco2.ui.theme.Red
import kotlin.math.roundToInt

@Composable
fun TotalCard(
    total: Double,
    participation: Double,
    duration: Double
) {
    val perPerson = if (participation != 0.0) total/participation else 0.0
    val daysOfAcceptableEmissions = total/5.4795 // total / (2 tonnes per year in kg/day)

    Column(
        modifier = Modifier.fillMaxWidth(),
        horizontalAlignment = Alignment.CenterHorizontally
    ) { // TODO: translate properly and handle units
        Text(
            text = "CO2: ${total.roundToInt()} kg\n",
            color = Red,
            fontSize = MaterialTheme.typography.titleLarge.fontSize,
            textAlign = TextAlign.Center
        )

        Text(
            text = "${perPerson.roundToInt()} kg/personne\n" +
                    "En ${duration.roundToInt()} jours, ce congrès produit autant que " +
                    "${daysOfAcceptableEmissions.roundToInt()} " +
                    "jours d'émissions acceptables pour préserver le climat.",
            color = Red,
            textAlign = TextAlign.Center
        )
    }
}
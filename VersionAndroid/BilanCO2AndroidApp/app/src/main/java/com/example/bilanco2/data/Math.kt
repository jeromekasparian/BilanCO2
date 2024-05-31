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

package com.example.bilanco2.data

fun scaledEmissions(
    fields: List<Field>,
    durationId: Int = -1,
    participationId: Int = -1,
    distanceId: Int = -1
): Map<Int, Double> {
    val duration = fields.find { it.fieldId == durationId }?.value?.toDouble() ?: 0.0
    val participation = fields.find { it.fieldId == participationId }?.value?.toDouble() ?: 0.0
    val distance = fields.find { it.fieldId == distanceId }?.value?.toDouble() ?: 0.0
    return fields
        .associate { field ->
            var multiplier = 1.0
            if (field.perDay != 0.0) multiplier *= field.perPerson * duration
            if (field.perPerson != 0.0) multiplier *= field.perPerson * participation
            if (field.perKmDistance != 0.0) multiplier *= field.perKmDistance * distance
            field.fieldId to field.value.toDouble() * field.factor * multiplier
        }
}

fun totalEmissions(
    scaledEmissions: Map<Int, Double>
): Double {
    return scaledEmissions.values.sumOf { it }
}
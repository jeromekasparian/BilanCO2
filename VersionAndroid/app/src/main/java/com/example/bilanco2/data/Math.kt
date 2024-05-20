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
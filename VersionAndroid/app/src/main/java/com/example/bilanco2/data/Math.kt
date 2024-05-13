package com.example.bilanco2.data

fun totalEmissions(
    fields: List<Field>,
    durationId: Int = 0,
    participationId: Int = 1
): Double {
    val duration = fields.find { it.fieldId == durationId }?.value?.toDouble()
    val participation = fields.find { it.fieldId == participationId }?.value?.toDouble()
    return participation?.let { duration?.times(it) }?.times( fields
        .filter { (it.fieldId != durationId) and (it.fieldId != participationId) }
        .sumOf { it.value.toDouble() }
    ) ?: Double.NaN
}
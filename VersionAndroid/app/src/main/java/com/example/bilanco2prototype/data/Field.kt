package com.example.bilanco2prototype.data

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.setValue

class Field(
    val fieldId: Int = 0,
    val categoryId: Int = 0,
    val name: String,

    val icon: String,
    val info: String,

    val unit: MeasurementUnit = MeasurementUnit.PERCENT,
    val min: Float = 0f,
    val max: Float = 100f
) {
    var value by mutableFloatStateOf(min)

    override fun toString(): String {
        return when(unit) {
            MeasurementUnit.PERCENT -> String.format("%s: %.0f%%", name, value)
            MeasurementUnit.PERCENT_CONTINUOUS -> {
                if (value < 1 && value > 0) String.format("%s: <1%%", name)
                else String.format("%s: %.0f%%", name, value)
            }
            MeasurementUnit.ITEM -> String.format("%.0f %s", value, name)
            MeasurementUnit.ITEM_PER_DAY -> String.format("%.0f %s / jour", value, name)
            MeasurementUnit.HOUR -> String.format("%s: %.0f h", name, value)
            MeasurementUnit.DAY -> String.format("%s: %.0f jours", name, value)
            MeasurementUnit.KM -> String.format("%s: %.0f km", name, value)
        }
    }
}

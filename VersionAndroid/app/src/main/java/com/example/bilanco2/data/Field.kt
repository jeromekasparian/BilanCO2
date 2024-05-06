package com.example.bilanco2.data

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.setValue
import kotlin.math.roundToInt

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

    override fun toString(): String { // TODO: voir si on peut/doit mieux gérer la localisation
        val intValue = value.roundToInt()
        return when(unit) {
            MeasurementUnit.PERCENT             ->  "$name: $intValue%"
            MeasurementUnit.PERCENT_CONTINUOUS  -> {
                if (0 < value && value < 1)         "$name: <1%"
                else                                "$name: $intValue%"
            }
            MeasurementUnit.ITEM                ->  "$intValue $name"
            MeasurementUnit.ITEM_PER_DAY        ->  "$intValue $name / jour"
            MeasurementUnit.HOUR                ->  "$name: $intValue h"
            MeasurementUnit.DAY                 ->  "$name: $intValue jours"
            MeasurementUnit.KM                  ->  "$name: $intValue km"
        }
    }
}

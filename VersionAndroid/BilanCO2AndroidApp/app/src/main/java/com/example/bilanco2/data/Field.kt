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

import android.annotation.SuppressLint
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.setValue

class Field(
//    val color: androidx.compose.ui.graphics.Color,

    val fieldId: Int = 0,
    val categoryId: Int = 0,
    val name: String,
    val icon: String,
    val info: String,
    val unitId: MeasurementUnit = MeasurementUnit.PERCENT,
    var unitName: String,
    val unitNamePlural: String,
    val min: Float = 0f,
    val max: Float = 100f,
    val factor: Double,
    val perPerson: Double,
    val perKmDistance: Double,
    val perDay: Double
) {
    var value by mutableFloatStateOf(min)

    private fun unitUpdate(): String {
        return if (value == 1f) unitName
        else unitNamePlural
    }

    @SuppressLint("DefaultLocale")
    override fun toString(): String {
        return when(unitId) {
            MeasurementUnit.PERCENT -> String.format("%s: %.0f%%", name, value)
//            MeasurementUnit.PERCENT_CONTINUOUS -> {
//                if (value < 1 && value > 0) String.format("%s: <1%%", name)
//                else String.format("%s: %.0f%%", name, value)
//            }
//            MeasurementUnit.ITEM -> String.format("%.0f %s", value, name)
//            MeasurementUnit.ITEM_PER_DAY -> String.format("%.0f %s / jour", value, name)
//            MeasurementUnit.HOUR -> String.format("%s: %.0f h", name, value)
//            MeasurementUnit.DAY -> String.format("%s: %.0f jours", name, value)
//            MeasurementUnit.KM -> String.format("%s: %.0f km", name, value)

//  TODO Add correspondant format
            MeasurementUnit.DURATION -> String.format("%s: %.0f %s", name, value, unitUpdate())
            MeasurementUnit.PARTICIPATION -> String.format("%.0f %s", value, unitUpdate())
            MeasurementUnit.COFFEE_BREAK -> String.format("%.0f %s", value, unitUpdate())
            MeasurementUnit.SURFACE_AREA -> String.format("%s: %.0f %s", name, value, unitName)
            MeasurementUnit.GOODIE -> String.format("%.0f %s", value, unitUpdate())
            MeasurementUnit.USB_KEY -> String.format("%.0f %s", value, unitUpdate())
            MeasurementUnit.PAGE -> String.format("%.0f %s", value, unitUpdate())
        }
    }
}

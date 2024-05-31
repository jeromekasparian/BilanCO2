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

import androidx.compose.runtime.mutableStateListOf
import androidx.lifecycle.ViewModel

class FieldViewModel: ViewModel() {
    private val _fields = mutableStateListOf<Field>()
    val fields: List<Field> get() = _fields

    fun populate(fieldList: List<Field>) {
        if( _fields.isEmpty() ) _fields.addAll(fieldList)
    }

    fun sliderPositionChanged(item: Field, sliderPosition: Float) =
        _fields.find { it.fieldId == item.fieldId }?.let { field ->
            field.value = sliderPosition
        }
}

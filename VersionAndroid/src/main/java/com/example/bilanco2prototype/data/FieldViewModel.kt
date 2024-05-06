package com.example.bilanco2prototype.data

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

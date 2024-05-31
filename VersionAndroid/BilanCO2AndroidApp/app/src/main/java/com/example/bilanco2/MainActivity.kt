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

package com.example.bilanco2

import android.annotation.SuppressLint
import android.content.Context
import android.os.Build
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.annotation.RequiresApi
import androidx.compose.ui.graphics.Color
import com.example.bilanco2.data.Category
import com.example.bilanco2.data.Field
import com.example.bilanco2.data.MeasurementUnit
import com.example.bilanco2.ui.MainScreen
import com.example.bilanco2.ui.theme.BilanCO2Theme
import java.io.BufferedReader
import java.io.InputStreamReader

class MainActivity : ComponentActivity() {
    @RequiresApi(Build.VERSION_CODES.O)
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val fieldDataList = mutableListOf<Field>()
        val categoryDataList = mutableListOf<Category>()

        //  Chart Attributes
        val colorsFieldList = mutableListOf<Color>()
        val iconsFieldList = mutableListOf<String>()

        // Read CSV file to populate data lists
        val fileCSV = InputStreamReader(assets.open("DataInternationalCongres.csv"))
        val reader = BufferedReader(fileCSV)
        var previousCategoryName = ""
        var currentCategoryId = -1 // First category is always new, so it will increment
        var currentFieldId = 0
        var currentColor = Color.Black
        reader.useLines { lines -> lines
            .drop(1) // Ignore the header line
            .filter { it.isNotBlank() } // Ignore empty lines
            .forEach {
                val row = it.split(';', limit = 20) // TODO Check limit? -> 7
                val categoryName = getMyString(row[0])
                if(categoryName != previousCategoryName) {
                    currentCategoryId++
                    currentColor = getColorForCategory(currentCategoryId)
                    previousCategoryName = categoryName
                    categoryDataList.add(
                        Category(
                            id = currentCategoryId,
                            name = categoryName
                        )
                    )
                }
                val measurementUnit = when(row[2]) {
                    // TODO Add measurement units
                    "unitDuree" -> MeasurementUnit.DURATION
                    "unitEffectif" -> MeasurementUnit.PARTICIPATION

                    "unitPauseCafe" -> MeasurementUnit.COFFEE_BREAK
                    "unitSurfaceM2" -> MeasurementUnit.SURFACE_AREA
                    "unitGoodie" -> MeasurementUnit.GOODIE
                    "unitCleUSB" -> MeasurementUnit.USB_KEY
                    "unitPage" -> MeasurementUnit.PAGE

                    "unitPourcentage" -> MeasurementUnit.PERCENT
                    "unitPourcentageParticipants" -> MeasurementUnit.PERCENT

                    else -> MeasurementUnit.PERCENT
                }
                fieldDataList.add(
                    Field(
                        fieldId = currentFieldId,
                        categoryId = currentCategoryId,
                        name = getMyString(row[1]),
                        icon = row[15],
                        info = getMyString(row[13]),
                        unitId = measurementUnit,
                        unitName = getMyString(row[2]),
                        unitNamePlural = getMyString(row[3]),
                        max = row[4].toFloat(),
                        factor = row[5].toDouble(),
                        perPerson = row[6].toDouble(),
                        perKmDistance = if(row[7].isEmpty()) 0.0 else row[7].toDouble(),
                        perDay = if(row[8].isEmpty()) 0.0 else row[8].toDouble()
                    )
                )
                currentFieldId++

                // Populate attributes lists for PieChart
                iconsFieldList += row[15]
                colorsFieldList += currentColor
            }
        }

        setContent {
            BilanCO2Theme {
                val colors = resources.getIntArray(R.array.categoryColors)
                    .map{ colorInt -> Color(colorInt) }
                MainScreen(categoryDataList, fieldDataList, colors, colorsFieldList, iconsFieldList)
            }
        }
    }

    private fun getColorForCategory(categoryId: Int): Color {
        val categoryColors = resources.getIntArray(R.array.categoryColors)
        // Modulo to ensure the index is within bounds
        return Color(categoryColors[categoryId % categoryColors.size])
    }
}

@SuppressLint("DiscouragedApi")
fun Context.getMyString(label: String): String {
    if (label.isEmpty()) return ""
    val resourceId = resources.getIdentifier(label, "string", packageName)
    return if (resourceId != 0) getString(resourceId)
    else "Error : Resource not found !"
}

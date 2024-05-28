package com.example.bilanco2

import android.annotation.SuppressLint
import android.content.Context
import android.os.Build
import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.annotation.RequiresApi
import androidx.compose.ui.graphics.Color
import com.example.bilanco2.data.Category
import com.example.bilanco2.ui.MainScreen
import com.example.bilanco2.ui.theme.BilanCO2Theme
import java.io.BufferedReader
import java.io.InputStreamReader
import com.example.bilanco2.data.Field
import com.example.bilanco2.data.MeasurementUnit

class MainActivity : ComponentActivity() {
    @RequiresApi(Build.VERSION_CODES.O)
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val fieldDataList = mutableListOf<Field>()
        val categoryDataList = mutableListOf<Category>()

        //  Chart Attributes
        var colorsFieldList = listOf<Color>()
        var iconsFieldList = listOf<String>()

        // Read CSV file to populate data lists
        // val fileCSV = InputStreamReader(assets.open("sample_data.csv"))
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

                    "unitDuree" -> MeasurementUnit.unitDuree
                    "unitEffectif" -> MeasurementUnit.unitEffectif

                    "unitPauseCafe" -> MeasurementUnit.unitPauseCafe
                    "unitSurfaceM2" -> MeasurementUnit.unitSurfaceM2
                    "unitGoodie" -> MeasurementUnit.unitGoodie
                    "unitCleUSB" -> MeasurementUnit.unitCleUSB
                    "unitPage" -> MeasurementUnit.unitPage

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
    // Function to get color for a category
    private fun getColorForCategory(categoryId: Int): Color {
        val categoryColors = resources.getIntArray(R.array.categoryColors)
        // Ensure the index is within bounds
        val colorIndex = categoryId % categoryColors.size
        return Color(categoryColors[colorIndex])
    }
}

@SuppressLint("DiscouragedApi")
fun Context.getMyString(label: String): String {
    if (label.isEmpty()) return ""
    val resourceId = resources.getIdentifier(label, "string", packageName)
    return if (resourceId != 0) getString(resourceId)
    else "Error : Resource not found !"
}




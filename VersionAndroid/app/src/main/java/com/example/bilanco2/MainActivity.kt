package com.example.bilanco2

import android.annotation.SuppressLint
import android.content.Context
import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.ui.graphics.Color
import com.example.bilanco2.data.Category
import com.example.bilanco2.ui.MainScreen
import com.example.bilanco2.ui.theme.BilanCO2Theme
import java.io.BufferedReader
import java.io.InputStreamReader
import com.example.bilanco2.data.Field
import com.example.bilanco2.data.MeasurementUnit


class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val fieldDataList = mutableListOf<Field>()
        val categoryDataList = mutableListOf<Category>()

        // Read CSV file to populate data lists
        // val fileCSV = InputStreamReader(assets.open("sample_data.csv"))
        val fileCSV = InputStreamReader(assets.open("DataInternationalCongres.csv"))
        val reader = BufferedReader(fileCSV)
        var previousCategoryName = ""
        var currentCategoryId = -1 // First category is always new, so it will increment
        var currentFieldId = 0
        reader.useLines { lines -> lines
            .drop(1) // Ignore the header line
            .filter { it.isNotBlank() } // Ignore empty lines
            .forEach {
                val row = it.split(';', limit = 20) // TODO Check limit? -> 7
                // val categoryName = row[0]
                val categoryName = getMyString(row[0])
                Log.d("TAG", "onCreate: ${row[0]} - $categoryName")
                if(categoryName != previousCategoryName) {
                    currentCategoryId++
                    previousCategoryName = categoryName
                    categoryDataList.add(
                        Category(
                            id = currentCategoryId,
                            name = categoryName
                        )
                    )
                }
                val measurementUnit = when(row[2]) {
//                    "personnes" -> MeasurementUnit.ITEM
//                    "assiettes" -> MeasurementUnit.ITEM
//                    "jours" -> MeasurementUnit.DAY
//
//                    "Day" -> MeasurementUnit.ITEM
//                    "Item" -> MeasurementUnit.ITEM
//                    "ItemPerDay" -> MeasurementUnit.ITEM_PER_DAY

                    // TODO Add measurement units
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
                        max = row[4].toFloat(),
                        unit = getMyString(row[2]),
                        unitP = getMyString(row[3])
                    )
                )
                currentFieldId++
            }
        }

        setContent {
            BilanCO2Theme {
                val colors = resources.getIntArray(R.array.categoryColors)
                    .map{ colorInt -> Color(colorInt) }
                MainScreen(categoryDataList, fieldDataList, colors)
            }
        }
    }
}

/*
@SuppressLint("DiscouragedApi")
fun Context.getMyString(label: String?): String {
    label?.let {
        if (label.isEmpty()) {
            return ""
        }
        return getString(resources.getIdentifier(it, "string", packageName))
    }
    throw Resources.NotFoundException()
}
 */

@SuppressLint("DiscouragedApi")
fun Context.getMyString(label: String): String {
    if (label.isEmpty()) return ""
    val resourceId = resources.getIdentifier(label, "string", packageName)
    return if (resourceId != 0) getString(resourceId)
    else "Error : Resource not found !"
}

/*
fun getMyString(label: String): String {
    val myId = resources.getIdentifier(label, "string", packageName)
    val myString = getString(myId)
    return getString(resources.getIdentifier(label, "string", packageName))
}
 */

/*
@Preview(
    name = "Light Mode",
    uiMode = Configuration.UI_MODE_NIGHT_NO,
    showBackground = true
)
@Preview(
    name = "Dark Mode",
    uiMode = Configuration.UI_MODE_NIGHT_YES,
    showBackground = true
)
@Composable
fun CategoryPreview() {
    BilanCO2Theme {
        MainScreen(
            categories = sampleCategories,
            fields = sampleFields,
            colors = sampleColors
        )
    }
}
 */

/* TODO: à voir si besoin
fun String.slug(): String {
    return this
        .lowercase()
        .replace(" ", "_")
        .replace("à", "a")
        .replace("é", "e")
        .replace("è", "e")
}

fun Context.stringByName(string: String): String {
    return resources.getString(this.stringIdByName(string.slug()))
}
 */

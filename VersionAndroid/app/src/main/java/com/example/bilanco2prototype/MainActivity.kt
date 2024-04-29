package com.example.bilanco2prototype

import android.annotation.SuppressLint
import android.content.Context
import android.content.res.Configuration
import android.content.res.Resources
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.tooling.preview.Preview
import com.example.bilanco2prototype.data.Category
import com.example.bilanco2prototype.data.Field
import com.example.bilanco2prototype.data.MeasurementUnit
import com.example.bilanco2prototype.data.sampleCategories
import com.example.bilanco2prototype.data.sampleColors
import com.example.bilanco2prototype.data.sampleFields
import com.example.bilanco2prototype.ui.MainScreen
import com.example.bilanco2prototype.ui.theme.BilanCO2PrototypeTheme
import java.io.BufferedReader
import java.io.InputStreamReader

@SuppressLint("DiscouragedApi")
fun Context.stringIdByName(resIdName: String?): Int {
    resIdName?.let {
        return resources.getIdentifier(it, "string", packageName)
    }
    throw Resources.NotFoundException()
}

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

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val fieldDataList = mutableListOf<Field>()
        val categoryDataList = mutableListOf<Category>()

        // Read CSV file to populate data lists
        val fileCSV = InputStreamReader(assets.open("sample_data.csv"))
        val reader = BufferedReader(fileCSV)
        var previousCategoryName = ""
        var currentCategoryId = -1 // First category is always new, so it will increment
        var currentFieldId = 0
        reader.useLines { lines -> lines
            .drop(1) // Ignore the header line
            .filter { it.isNotBlank() } // Ignore empty lines
            .forEach {
                val line = it.split(';', limit = 7)
                val categoryName = line[0]
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
                val measurementUnit = when(line[2]) {
                    "personnes" -> MeasurementUnit.ITEM
                    "assiettes" -> MeasurementUnit.ITEM
                    "jours" -> MeasurementUnit.DAY
                    else -> MeasurementUnit.PERCENT
                }
                fieldDataList.add(
                    Field(
                        fieldId = currentFieldId,
                        categoryId = currentCategoryId,
                        name = line[1],
                        unit = measurementUnit,
                        max = line[3].toFloat()
                    )
                )
                currentFieldId++
            }
        }

        setContent {
            BilanCO2PrototypeTheme {
                val colors = resources.getIntArray(R.array.categoryColors).map{
                    colorInt -> Color(colorInt)
                }
                MainScreen(categoryDataList, fieldDataList, colors)
            }
        }
    }
}

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
    BilanCO2PrototypeTheme {
        MainScreen(
            categories = sampleCategories,
            fields = sampleFields,
            colors = sampleColors
        )
    }
}

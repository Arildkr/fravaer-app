package no.fravaer.fravaer_app

import android.app.Activity
import android.app.AlertDialog
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.os.Bundle
import org.json.JSONArray

class WidgetConfigActivity : Activity() {

    private var appWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setResult(RESULT_CANCELED)

        appWidgetId = intent?.extras?.getInt(
            AppWidgetManager.EXTRA_APPWIDGET_ID,
            AppWidgetManager.INVALID_APPWIDGET_ID
        ) ?: AppWidgetManager.INVALID_APPWIDGET_ID

        if (appWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
            finish()
            return
        }

        val prefs = getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val groupsJson = prefs.getString("available_groups", "[]") ?: "[]"

        val groupIds = mutableListOf<String>()
        val groupNames = mutableListOf<String>()
        try {
            val arr = JSONArray(groupsJson)
            for (i in 0 until arr.length()) {
                val obj = arr.getJSONObject(i)
                groupIds.add(obj.getString("id"))
                groupNames.add(obj.getString("name"))
            }
        } catch (_: Exception) {}

        // "Vis aktiv økt" er alltid første valg (ingen pinning)
        val displayItems = (listOf("Vis aktiv økt") + groupNames).toTypedArray()

        AlertDialog.Builder(this)
            .setTitle("Velg gruppe for widget")
            .setItems(displayItems) { _, which ->
                if (which == 0) {
                    saveAndFinish(pinnedName = "")
                } else {
                    saveAndFinish(pinnedName = groupNames[which - 1])
                }
            }
            .setOnCancelListener { finish() }
            .show()
    }

    private fun saveAndFinish(pinnedName: String) {
        val prefs = getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        prefs.edit()
            .putString("widget_pinned_name_$appWidgetId", pinnedName)
            .apply()

        // Be widgeten oppdatere seg
        val updateIntent = Intent(AppWidgetManager.ACTION_APPWIDGET_UPDATE).apply {
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, intArrayOf(appWidgetId))
        }
        sendBroadcast(updateIntent)

        val result = Intent().apply {
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
        }
        setResult(RESULT_OK, result)
        finish()
    }
}

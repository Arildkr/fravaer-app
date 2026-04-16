package no.fravaer.fravaer_app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class HomeWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            ?.apply { flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP }
        val pendingIntent = PendingIntent.getActivity(
            context, 0, launchIntent ?: Intent(),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val activeGroup = widgetData.getString("widget_status", "") ?: ""
        val activeCount = widgetData.getString("widget_count", "") ?: ""

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.home_widget_layout)

            val pinnedName = widgetData.getString("widget_pinned_name_$widgetId", "") ?: ""

            val displayStatus: String
            val displayCount: String

            if (pinnedName.isEmpty()) {
                // Ingen pinnet gruppe — vis aktiv økt
                displayStatus = activeGroup.ifEmpty { "Ingen aktiv økt" }
                displayCount = activeCount
            } else if (pinnedName == activeGroup && activeCount.isNotEmpty()) {
                // Pinnet gruppe er aktiv
                displayStatus = pinnedName
                displayCount = activeCount
            } else {
                // Pinnet gruppe, men ikke aktiv nå
                displayStatus = pinnedName
                displayCount = "Ingen aktiv økt"
            }

            views.setTextViewText(R.id.widget_status, displayStatus)
            views.setTextViewText(R.id.widget_count, displayCount)
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}

package no.fravaer.fravaer_app

import android.appwidget.AppWidgetManager
import android.content.Context
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
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.home_widget_layout)

            val status = widgetData.getString("widget_status", "Ingen aktiv økt") ?: "Ingen aktiv økt"
            val count = widgetData.getString("widget_count", "") ?: ""

            views.setTextViewText(R.id.widget_status, status)
            views.setTextViewText(R.id.widget_count, count)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}

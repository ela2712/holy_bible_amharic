package com.holy.amharic_bible.holy_bible_amharic

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class DailyVerseWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.daily_verse_widget).apply {
                val verseText = widgetData.getString("daily_verse_text", null)
                    ?: "“በመጀመሪያ ቃል ነበረ፥ ቃልም በእግዚአብሔር ዘንድ ነበረ፥ ቃልም እግዚአብሔር ነበረ።”"
                val reference = widgetData.getString("daily_verse_reference", null)
                    ?: "— የዮሐንስ ወንጌል 1:1"
                val theme = widgetData.getString("daily_verse_theme", null)
                    ?: "የዕለቱ ቃል"

                setTextViewText(R.id.widget_verse_text, verseText)
                setTextViewText(R.id.widget_reference, reference)
                setTextViewText(R.id.widget_theme, theme)

                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java
                )
                setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}

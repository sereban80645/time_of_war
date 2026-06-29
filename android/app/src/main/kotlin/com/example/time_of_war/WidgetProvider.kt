package com.example.time_of_war

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import android.app.PendingIntent

class WidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        super.onUpdate(context, appWidgetManager, appWidgetIds, widgetData)
        
        val res = context.resources
        val pkg = context.packageName
        
        val layoutId = res.getIdentifier("widget_layout", "layout", pkg)
        val rootId = res.getIdentifier("widget_root", "id", pkg)
        val imageId = res.getIdentifier("widget_image", "id", pkg)
        
        if (layoutId != 0) {
            for (appWidgetId in appWidgetIds) {
                val views = RemoteViews(pkg, layoutId)
                
                // Універсальний спосіб відкрити додаток без помилок Unresolved reference
                val intent = context.packageManager.getLaunchIntentForPackage(pkg)
                if (intent != null) {
                    val pendingIntent = PendingIntent.getActivity(
                        context, 
                        0, 
                        intent, 
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )
                    if (rootId != 0) views.setOnClickPendingIntent(rootId, pendingIntent)
                    if (imageId != 0) views.setOnClickPendingIntent(imageId, pendingIntent)
                }
                
                appWidgetManager.updateAppWidget(appWidgetId, views)
            }
        }
    }
}

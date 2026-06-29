package com.example.time_of_war

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import android.graphics.BitmapFactory
import android.app.PendingIntent
import es.antonborri.home_widget.HomeWidgetProvider
import java.io.File

class WidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        val pkg = context.packageName
        val res = context.resources
        val layoutId = res.getIdentifier("widget_layout", "layout", pkg)
        val rootId = res.getIdentifier("widget_root", "id", pkg)
        val imageId = res.getIdentifier("widget_image", "id", pkg)

        if (layoutId == 0) return

        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(pkg, layoutId)

            // Зчитуємо зображення (ваші налаштовані години, шпалери тощо), яке Flutter зберігає у фоні
            val imagePath = widgetData.getString("widget_image", null) ?: widgetData.getString("filename", null)
            if (imagePath != null) {
                val file = File(imagePath)
                if (file.exists()) {
                    val bitmap = BitmapFactory.decodeFile(file.absolutePath)
                    if (bitmap != null && imageId != 0) {
                        views.setImageViewBitmap(imageId, bitmap)
                    }
                }
            }

            // Налаштовуємо виклик прозорого меню по кліку на віджет
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

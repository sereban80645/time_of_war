package com.example.time_of_war;

import android.content.Context;
import android.appwidget.AppWidgetManager;
import android.content.SharedPreferences;
import android.widget.RemoteViews;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.content.Intent;
import android.app.PendingIntent;
import es.antonborri.home_widget.HomeWidgetProvider;

public class TimerWidgetProvider extends HomeWidgetProvider {
    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds, SharedPreferences widgetData) {
        for (int appWidgetId : appWidgetIds) {
            RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.widget_layout);

            // Отримуємо шлях до згенерованої картинки
            String imagePath = widgetData.getString("widget_image", null);
            if (imagePath != null) {
                Bitmap bitmap = BitmapFactory.decodeFile(imagePath);
                if (bitmap != null) {
                    views.setImageViewBitmap(R.id.widget_image, bitmap);
                }
            }

            // Додаємо клік для відкриття схованого застосунку
            Intent intent = new Intent(context, MainActivity.class);
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            PendingIntent pendingIntent = PendingIntent.getActivity(context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent);

            appWidgetManager.updateAppWidget(appWidgetId, views);
        }
    }
}
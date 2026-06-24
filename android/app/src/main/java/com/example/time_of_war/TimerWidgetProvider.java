package com.example.time_of_war;

import android.appwidget.AppWidgetManager;
import android.content.Context;
import android.content.SharedPreferences;
import android.widget.RemoteViews;
import es.antonborri.home_widget.HomeWidgetProvider;

public class TimerWidgetProvider extends HomeWidgetProvider {
    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds, SharedPreferences widgetData) {
        for (int appWidgetId : appWidgetIds) {
            RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.widget_layout);
            
            String txt2022 = widgetData.getString("timer_2022", "Обчислення...");
            String txt2014 = widgetData.getString("timer_2014", "Обчислення...");
            
            // Правильно екрановані перенесення рядків
            views.setTextViewText(R.id.timer_text_2022, "Вторгнення 2022:\n" + txt2022);
            views.setTextViewText(R.id.timer_text_2014, "Війна 2014:\n" + txt2014);

            appWidgetManager.updateAppWidget(appWidgetId, views);
        }
    }
}

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

            String timer2022 = widgetData.getString("timer_2022", "Очікування даних...");
            String timer2014 = widgetData.getString("timer_2014", "Очікування даних...");

            views.setTextViewText(R.id.timer_text_2022, "Вторгнення 2022:\n" + timer2022);
            views.setTextViewText(R.id.timer_text_2014, "Війна 2014:\n" + timer2014);

            appWidgetManager.updateAppWidget(appWidgetId, views);
        }
    }
}

package com.example.vnote2

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class NoteWidget : AppWidgetProvider() {

    override fun onUpdate(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onDeleted(context: Context, appWidgetIds: IntArray) {
        super.onDeleted(context, appWidgetIds)
        val prefs = HomeWidgetPlugin.getData(context).edit()
        for (appWidgetId in appWidgetIds) {
            prefs.remove(PREF_KEY_WIDGET_NOTE_PREFIX + appWidgetId)
        }
        prefs.apply()
    }

    companion object {
        fun updateWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
            val pref = HomeWidgetPlugin.getData(context)
            val noteId = pref.getString(PREF_KEY_WIDGET_NOTE_PREFIX + appWidgetId, "") ?: ""

            val views = RemoteViews(context.packageName, R.layout.note_widget_layout)
            val serviceIntent =
                    Intent(context, NoteWidgetService::class.java).apply {
                        putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
                        data = Uri.parse(toUri(Intent.URI_INTENT_SCHEME))
                    }

            views.setRemoteAdapter(R.id.widget_list_view, serviceIntent)

            val openNoteIntent =
                    Intent(context, MainActivity::class.java).apply {
                        action = "OPEN_NOTE"
                        putExtra("noteId", noteId)
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                    }

            val openNotePendingIntent =
                    PendingIntent.getActivity(
                            context,
                            appWidgetId * 1000, // unique code
                            openNoteIntent,
                            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )

            views.setOnClickPendingIntent(R.id.button_edit_note, openNotePendingIntent)

            val configNoteIntent =
                    Intent(context, MainActivity::class.java).apply {
                        action = AppWidgetManager.ACTION_APPWIDGET_CONFIGURE
                        putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    }
            val configNotePendingIntent =
                    PendingIntent.getActivity(
                            context,
                            appWidgetId * 1000 + 1,
                            configNoteIntent,
                            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )

            views.setOnClickPendingIntent(R.id.button_change_target, configNotePendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
            appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetId, R.id.widget_list_view)
        }
    }
}

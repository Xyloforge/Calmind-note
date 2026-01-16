package com.example.vnote2

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.Intent
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

public val PREF_KEY_OPEN_NOTE = "open_note"
public val PREF_KEY_CONFIG_WIDGET = "config_widget"
public val PREF_KEY_WIDGET_NOTE_PREFIX = "widget_note_"
public val PREF_KEY_NOTE_CONTENT_PREFIX = "note_content_"

class MainActivity : FlutterActivity() {
    private var channel: MethodChannel? = null

    // Store noteId from widget click
    private var openNoteId: String? = null
    private var configWidgetId: Int = AppWidgetManager.INVALID_APPWIDGET_ID

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Check if we were started for a widget configuration OR widget click
        handleWidgetIntent(intent)

        channel =
                MethodChannel(
                        flutterEngine.dartExecutor.binaryMessenger,
                        "com.example.vnote2/widget_config"
                )

        channel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "getConfigWidgetId" -> {
                    result.success(
                            configWidgetId.takeIf { it != AppWidgetManager.INVALID_APPWIDGET_ID }
                    )
                    configWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID
                }
                "getOpenNoteId" -> {
                    result.success(openNoteId)
                    openNoteId = null
                }
                "finishConfig" -> {
                    val widgetId = call.argument<Int>("widgetId")
                    if (widgetId == null) {
                        result.error("INVALID_WIDGET_ID", "Widget ID is required", null)
                        return@setMethodCallHandler
                    }

                    val resultValue =
                            Intent().apply {
                                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)
                            }
                    setResult(Activity.RESULT_OK, resultValue)
                    finish()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        sendOpenNoteEvent()
        sendSwapNoteEvent()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleWidgetIntent(intent)

        sendSwapNoteEvent()
        sendOpenNoteEvent()
    }

    private fun sendOpenNoteEvent() {
        openNoteId?.let { noteId ->
            channel?.invokeMethod("openNote", mapOf("noteId" to noteId))
            openNoteId = null
        }
    }

    private fun sendSwapNoteEvent() {
        Log.d("MainActivity", "Sending swap note event for widget ID: $configWidgetId")
        if (configWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) return
        Log.d("MainActivity", "SENTTTTT")
        configWidgetId?.let { widgetId ->
            channel?.invokeMethod("swapNote", mapOf("widgetId" to widgetId))
            configWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID
        }
    }

    private fun handleWidgetIntent(intent: Intent?) {
        when (intent?.action) {
            AppWidgetManager.ACTION_APPWIDGET_CONFIGURE -> {
                configWidgetId =
                        intent.getIntExtra(
                                AppWidgetManager.EXTRA_APPWIDGET_ID,
                                AppWidgetManager.INVALID_APPWIDGET_ID
                        )
            }
            "OPEN_NOTE" -> {
                openNoteId = intent.getStringExtra("noteId")
            }
        }
    }
}

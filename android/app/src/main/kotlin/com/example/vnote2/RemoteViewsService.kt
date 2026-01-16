package com.example.vnote2

import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.graphics.Paint
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray
import org.json.JSONObject

class NoteWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return NoteWidgetRemoteViewsFactory(applicationContext, intent)
    }
}

class NoteWidgetRemoteViewsFactory(private val context: Context, intent: Intent) :
        RemoteViewsService.RemoteViewsFactory {

    private val appWidgetId =
            intent.getIntExtra(
                    android.appwidget.AppWidgetManager.EXTRA_APPWIDGET_ID,
                    android.appwidget.AppWidgetManager.INVALID_APPWIDGET_ID
            )

    private data class NoteItem(
            val type: ItemType,
            val text: String,
            val isChecked: Boolean = false,
            val number: Int = 0
    )

    enum class ItemType {
        TEXT,
        CHECKBOX,
        BULLET,
        NUMBERED
    }

    private val items = mutableListOf<NoteItem>()
    private val isDarkMode = isDarkMode(context)

    override fun onCreate() {
        loadData()
    }

    override fun onDataSetChanged() {
        loadData()
    }

    private fun loadData() {
        items.clear()

        val widgetData = HomeWidgetPlugin.getData(context)
        val noteId = widgetData.getString(PREF_KEY_WIDGET_NOTE_PREFIX + appWidgetId, "") ?: ""
        val contentJson = widgetData.getString(PREF_KEY_NOTE_CONTENT_PREFIX + noteId, "") ?: ""

        parseQuillDelta(contentJson)
    }

    private fun parseQuillDelta(jsonString: String) {
        try {
            val json = JSONArray(jsonString)
            var numberedCounter = 1

            for (i in 0 until json.length()) {
                val op = json.getJSONObject(i)

                if (op.has("insert")) {
                    val insert = op.get("insert")

                    when {
                        insert is JSONObject -> {
                            // Skip embeds
                            continue
                        }
                        insert is String -> {
                            val text = insert.trim()
                            if (text.isEmpty()) continue

                            val attrs = op.optJSONObject("attributes")

                            if (attrs != null && attrs.has("list")) {
                                when (attrs.getString("list")) {
                                    "bullet" -> {
                                        items.add(NoteItem(ItemType.BULLET, text))
                                    }
                                    "ordered" -> {
                                        items.add(
                                                NoteItem(
                                                        ItemType.NUMBERED,
                                                        text,
                                                        number = numberedCounter++
                                                )
                                        )
                                    }
                                    "checked" -> {
                                        items.add(
                                                NoteItem(ItemType.CHECKBOX, text, isChecked = true)
                                        )
                                        numberedCounter = 1
                                    }
                                    "unchecked" -> {
                                        items.add(
                                                NoteItem(ItemType.CHECKBOX, text, isChecked = false)
                                        )
                                        numberedCounter = 1
                                    }
                                }
                            } else {
                                items.add(NoteItem(ItemType.TEXT, text))
                                numberedCounter = 1
                            }
                        }
                    }
                }
            }
        } catch (e: Exception) {
            items.add(NoteItem(ItemType.TEXT, "Error: ${e.message}"))
        }
    }

    override fun getViewAt(position: Int): RemoteViews {
        val item = items[position]

        return when (item.type) {
            ItemType.TEXT -> createTextItem(item.text)
            ItemType.CHECKBOX -> createCheckboxItem(item.text, item.isChecked)
            ItemType.BULLET -> createBulletItem(item.text)
            ItemType.NUMBERED -> createNumberedItem(item.number, item.text)
        }
    }

    private fun createTextItem(text: String): RemoteViews {
        return RemoteViews(context.packageName, R.layout.widget_item_text).apply {
            setTextViewText(R.id.item_text, text)
        }
    }

    private fun createCheckboxItem(text: String, isChecked: Boolean): RemoteViews {
        return RemoteViews(context.packageName, R.layout.widget_item_checkbox).apply {
            setImageViewResource(
                    R.id.checkbox_icon,
                    if (isChecked) R.drawable.ic_checkbox_checked
                    else R.drawable.ic_checkbox_unchecked
            )
            setTextViewText(R.id.checkbox_text, text)

            if (isChecked) {
                setInt(
                        R.id.checkbox_text,
                        "setPaintFlags",
                        Paint.STRIKE_THRU_TEXT_FLAG or Paint.ANTI_ALIAS_FLAG
                )
                setTextColor(R.id.checkbox_text, context.getColor(R.color.widget_text_checked))
            }
        }
    }

    private fun createBulletItem(text: String): RemoteViews {
        return RemoteViews(context.packageName, R.layout.widget_item_bullet).apply {
            setTextViewText(R.id.bullet_text, text)
        }
    }

    private fun createNumberedItem(number: Int, text: String): RemoteViews {
        return RemoteViews(context.packageName, R.layout.widget_item_numbered).apply {
            setTextViewText(R.id.number_text, "$number.")
            setTextViewText(R.id.numbered_item_text, text)
        }
    }

    override fun getCount(): Int = items.size

    override fun getLoadingView(): RemoteViews? = null

    override fun getViewTypeCount(): Int = 4 // TEXT, CHECKBOX, BULLET, NUMBERED

    override fun getItemId(position: Int): Long = position.toLong()

    override fun hasStableIds(): Boolean = true

    override fun onDestroy() {
        items.clear()
    }

    private fun isDarkMode(context: Context): Boolean {
        return context.resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK ==
                Configuration.UI_MODE_NIGHT_YES
    }
}

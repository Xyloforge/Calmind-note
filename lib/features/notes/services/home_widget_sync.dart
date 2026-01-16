import 'package:home_widget/home_widget.dart';

class HomeWidgetSync {
  static const String appGroupId = 'group.com.example.vnote2';
  static const String androidWidgetName = 'NoteWidget';

  static const String widgetNotePrefix = 'widget_note_';
  static const String noteContentPrefix = 'note_content_';

  /// Update widget with note data
  static Future<void> updateWidget({
    required String noteId,
    required String contentJson,
  }) async {
    await HomeWidget.saveWidgetData<String>(
      noteContentPrefix + noteId,
      contentJson,
    );

    await HomeWidget.updateWidget(androidName: androidWidgetName);
  }

  /// Set specific widget to show a specific note
  static Future<void> setWidgetNote({
    required int widgetId,
    required String noteId,
    required String contentJson,
  }) async {
    await HomeWidget.saveWidgetData<String>(
      widgetNotePrefix + widgetId.toString(),
      noteId,
    );
    await HomeWidget.saveWidgetData<String>(
      noteContentPrefix + noteId,
      contentJson,
    );

    await HomeWidget.updateWidget(androidName: androidWidgetName);
  }

  /// Refresh all widgets
  static Future<void> refreshAllWidgets() async {
    await HomeWidget.updateWidget(androidName: androidWidgetName);
  }
}

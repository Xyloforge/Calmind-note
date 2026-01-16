import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vnote2/features/notes/presentation/screens/note_editor_screen.dart';
import 'package:vnote2/features/notes/presentation/screens/widget_config_screen.dart';

class WidgetNavigationService {
  static const platform = MethodChannel('com.example.vnote2/widget_config');

  final GlobalKey<NavigatorState> navigatorKey;

  WidgetNavigationService(this.navigatorKey);

  Future<bool> checkAndOpenWidgetNavigation() async {
    final noteId = await getOpenNoteId();
    debugPrint("noteId: $noteId");
    if (noteId != null && noteId.isNotEmpty) {
      await openNote(noteId);
      return true;
    }

    final widgetId = await getConfigWidgetId();
    debugPrint("widgetId: $widgetId");
    if (widgetId != null && widgetId != 0) {
      swapNote(widgetId);
      return true;
    }

    return false;
  }

  /// Open a note by ID
  Future<void> openNote(String noteId) async {
    final context = navigatorKey.currentContext;
    if (context == null) {
      debugPrint('No navigation context available');
      return;
    }

    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => NoteEditorScreen(noteId: noteId)),
      (_) => false,
    );
  }

  /// Swap note for widget
  Future<void> swapNote(int widgetId) async {
    final context = navigatorKey.currentContext;
    if (context == null) {
      return;
    }
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => WidgetConfigScreen(widgetId: widgetId),
      ),
      (_) => false,
    );
  }

  /// Finish widget configuration
  Future<void> finishConfiguration(int widgetId) async {
    try {
      await platform.invokeMethod('finishConfig', {'widgetId': widgetId});
    } catch (e) {
      debugPrint('Error finishing configuration: $e');
      rethrow;
    }
  }

  /// Get configuration widget ID
  Future<int?> getConfigWidgetId() async {
    try {
      return await platform.invokeMethod<int>('getConfigWidgetId');
    } catch (e) {
      debugPrint('Error getting config widget ID: $e');
      return null;
    }
  }

  /// Get open note ID
  Future<String?> getOpenNoteId() async {
    try {
      return await platform.invokeMethod<String>('getOpenNoteId');
    } catch (e) {
      debugPrint('Error getting open note ID: $e');
      return null;
    }
  }
}

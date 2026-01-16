import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vnote2/features/notes/presentation/screens/note_editor_screen.dart';
import 'package:vnote2/features/notes/presentation/screens/widget_config_screen.dart';

class WidgetNavigationService {
  static const platform = MethodChannel('com.example.vnote2/widget_config');

  final GlobalKey<NavigatorState> navigatorKey;

  WidgetNavigationService(this.navigatorKey);

  /// Initialize the service and set up handlers
  void initialize() {
    platform.setMethodCallHandler(_handleMethodCall);
  }

  /// Handle method calls from native side
  Future<void> _handleMethodCall(MethodCall call) async {
    debugPrint('WidgetNavigationService: ${call.method}');

    switch (call.method) {
      case 'openNote':
        final noteId = call.arguments['noteId'] as String?;
        if (noteId != null && noteId.isNotEmpty) {
          await openNote(noteId);
        }
        break;
      case 'swapNote':
        debugPrint('Swapping note for widget: ${call.arguments['widgetId']}');
        final widgetId = call.arguments['widgetId'] as int?;
        if (widgetId != null && widgetId != 0) {
          debugPrint('Swapping note for widget: $widgetId');
          await swapNote(widgetId);
        }
        break;
      default:
        debugPrint('Unknown method: ${call.method}');
    }
  }

  /// Check for pending intents (call when app resumes)
  Future<void> checkForPendingIntent() async {
    try {
      final noteId = await platform.invokeMethod<String>('getOpenNoteId');
      if (noteId != null && noteId.isNotEmpty) {
        await openNote(noteId);
      }
    } catch (e) {
      debugPrint('Error checking for pending intent: $e');
    }
  }

  /// Open a note by ID
  Future<void> openNote(String noteId) async {
    debugPrint('Opening note: $noteId');

    final context = navigatorKey.currentContext;
    if (context == null) {
      debugPrint('No navigation context available');
      return;
    }

    // Pop to root
    navigatorKey.currentState?.popUntil((route) => route.isFirst);

    // Navigate to note
    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (context) => NoteEditorScreen(noteId: noteId)),
    );
  }

  /// Swap note for widget
  Future<void> swapNote(int widgetId) async {
    debugPrint('Swapping note for widget: $widgetId');
    final context = navigatorKey.currentContext;
    if (context == null) {
      debugPrint('No navigation context available');
      return;
    }
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => WidgetConfigScreen(widgetId: widgetId),
      ),
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

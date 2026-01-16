import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:home_widget/home_widget.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/notes_provider.dart';
import '../../services/home_widget_sync.dart';

class WidgetConfigScreen extends ConsumerStatefulWidget {
  const WidgetConfigScreen({super.key, required this.widgetId});

  final int widgetId;

  @override
  ConsumerState<WidgetConfigScreen> createState() => _WidgetConfigScreenState();
}

class _WidgetConfigScreenState extends ConsumerState<WidgetConfigScreen> {
  static const platform = MethodChannel('com.example.vnote2/widget_config');
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _selectNote(String noteId, String contentJson) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      // Save widget configuration
      await HomeWidgetSync.setWidgetNote(
        widgetId: widget.widgetId,
        noteId: noteId,
        contentJson: contentJson,
      );

      // Notify native side that configuration is complete
      await platform.invokeMethod('finishConfig', {
        'widgetId': widget.widgetId,
      });

      // Configuration complete - activity will finish on native side
      // No need to pop here as the activity finishes
    } catch (e) {
      debugPrint('Error configuring widget: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to configure widget: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final notesState = ref.watch(notesListProvider);
    final theme = Theme.of(context);

    return WillPopScope(
      // Prevent back button during configuration
      onWillPop: () async => !_isProcessing,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Select Note for Widget',
            style: TextStyle(color: theme.textTheme.titleLarge?.color),
          ),
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          automaticallyImplyLeading: !_isProcessing,
        ),
        body: notesState.when(
          data: (notes) {
            if (notes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.note_outlined, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'No notes available',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create a note first to use in widgets',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              );
            }

            return Stack(
              children: [
                ListView.builder(
                  itemCount: notes.length,
                  padding: const EdgeInsets.all(8),
                  itemBuilder: (context, index) {
                    final note = notes[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: ListTile(
                        enabled: !_isProcessing,
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.note, color: theme.primaryColor),
                        ),
                        title: Text(
                          note.title.isEmpty ? 'Untitled Note' : note.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              _getPreviewText(note.contentJson),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Updated: ${_formatDate(note.updatedAt)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: Colors.grey[400],
                        ),
                        onTap: () => _selectNote(note.id, note.contentJson),
                      ),
                    );
                  },
                ),
                if (_isProcessing)
                  Container(
                    color: Colors.black26,
                    child: Center(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              const SizedBox(height: 16),
                              Text('Configuring widget...'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error loading notes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getPreviewText(String contentJson) {
    try {
      final doc = Document.fromJson(jsonDecode(contentJson));
      final plainText = doc.toPlainText();
      return plainText.isEmpty ? 'Empty note' : plainText;
    } catch (e) {
      return 'Unable to preview';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

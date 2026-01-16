import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vnote2/core/enums/pref_keys.dart';
import 'package:vnote2/features/notes/domain/models/note_model.dart';
import 'package:vnote2/features/notes/presentation/widgets/quill_editor.dart';

import '../providers/notes_provider.dart';

import '../../services/home_widget_sync.dart';

enum ToolBarMode { editor, format, list }

class NoteEditorScreen extends ConsumerStatefulWidget {
  final String? noteId;

  const NoteEditorScreen({super.key, this.noteId});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  QuillController? _quillController;
  String? _currentNoteId;

  @override
  void initState() {
    super.initState();
    _currentNoteId = widget.noteId;
    if (_currentNoteId != null) {
      _markAsLastScreen(_currentNoteId!);
    }
  }

  @override
  void dispose() {
    _quillController?.dispose();
    super.dispose();
  }

  Future<void> _markAsLastScreen(String noteId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(LastScreenKeys.screen, LastScreenKeys.note);
    await prefs.setString(LastScreenKeys.noteId, noteId);
  }

  Future<void> _save() async {
    if (!mounted || _quillController == null) return;

    final plainText = _quillController!.document.toPlainText().trim();
    final title = plainText.split('\n').firstOrNull ?? 'Untitled';

    final contentJson = jsonEncode(
      _quillController!.document.toDelta().toJson(),
    );

    if (_currentNoteId == null) {
      if (plainText.isEmpty) {
        return;
      }

      final newId = await ref
          .read(notesListProvider.notifier)
          .addNote(title.isEmpty ? 'Untitled' : title, contentJson);
      if (mounted) {
        _markAsLastScreen(newId);
        setState(() {
          _currentNoteId = newId;
        });
      }
    } else {
      final notesState = ref.read(notesListProvider);
      notesState.whenData((notes) {
        try {
          final existingNote = notes.firstWhere((n) => n.id == _currentNoteId);
          final updatedNote = existingNote.copyWith(
            title: title.isEmpty ? 'Untitled' : title,
            contentJson: contentJson,
          );
          ref.read(notesListProvider.notifier).updateNote(updatedNote);
        } catch (e) {
          debugPrint('Error saving note: $e');
        }
      });
    }
    // Update home widget with contentJson for rich formatting
    if (_currentNoteId != null) {
      HomeWidgetSync.updateWidget(
        noteId: _currentNoteId!,
        contentJson: contentJson,
      );
    }
  }

  void _initializeController(Note? note) {
    if (_quillController != null) return;

    Document doc;
    if (note != null && note.contentJson.isNotEmpty) {
      try {
        doc = Document.fromJson(jsonDecode(note.contentJson));
      } catch (e) {
        doc = Document()..insert(0, '${note.title}\n');
      }
    } else {
      doc = Document();
      if (note == null) doc.format(0, 1, Attribute.h1); // New note auto-h1
    }

    _quillController = QuillController(
      document: doc,
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(notesListProvider);
    final theme = Theme.of(context);

    return notesAsync.when(
      data: (notes) {
        final note = _currentNoteId != null
            ? notes.where((n) => n.id == _currentNoteId).firstOrNull
            : null;
        _initializeController(note);

        if (_quillController == null) return const SizedBox.shrink();

        return MyQuillEditor(onSave: _save, quillController: _quillController!);
      },
      loading: () {
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: theme.colorScheme.primary),
          ),
        );
      },
      error: (error, stackTrace) {
        return Scaffold(body: Center(child: Text(error.toString())));
      },
    );
  }
}

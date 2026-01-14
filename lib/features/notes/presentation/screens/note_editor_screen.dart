import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/notes_provider.dart';
import '../widgets/formatting_toolbar.dart';
import '../widgets/top_navigation_bar.dart';
import '../widgets/format_panel.dart';

enum ToolBarMode { editor, format }

class NoteEditorScreen extends ConsumerStatefulWidget {
  final String? noteId;

  const NoteEditorScreen({super.key, this.noteId});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late final QuillController _quillController;
  late final TextEditingController _titleController;
  final FocusNode _editorFocusNode = FocusNode();
  final FocusNode _titleFocusNode = FocusNode();

  String? _currentNoteId;
  Timer? _debounceTimer;
  bool _isLoading = true;
  ToolBarMode _toolBarMode = ToolBarMode.editor;

  @override
  void initState() {
    super.initState();
    _currentNoteId = widget.noteId;
    _titleController = TextEditingController();
    _quillController = QuillController.basic();

    _loadNote();

    // Listen to controller changes to update Undo/Redo state
    _quillController.addListener(_onEditorChange);
    // Listen to focus changes to hide format panel when typing
    _editorFocusNode.addListener(_onFocusChange);
    _titleFocusNode.addListener(_onFocusChange);
  }

  void _onEditorChange() {
    if (mounted) setState(() {});
    _onChanged();
  }

  void _onFocusChange() {
    if ((_editorFocusNode.hasFocus || _titleFocusNode.hasFocus) &&
        _toolBarMode == ToolBarMode.format) {
      setState(() {
        _toolBarMode = ToolBarMode.editor;
      });
    }
  }

  Future<void> _loadNote() async {
    if (_currentNoteId != null) {
      final notesState = ref.read(notesListProvider);
      notesState.whenData((notes) {
        final note = notes.firstWhere(
          (n) => n.id == _currentNoteId,
          orElse: () => throw Exception('Note not found'),
        );

        _titleController.text = note.title;

        if (note.contentJson.isNotEmpty) {
          try {
            final json = jsonDecode(note.contentJson);
            _quillController.document = Document.fromJson(json);
          } catch (e) {
            print('Error parsing delta: $e');
          }
        }
      });
    }

    setState(() {
      _isLoading = false;
    });

    _titleController.addListener(_onChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _quillController.removeListener(_onEditorChange);
    _editorFocusNode.removeListener(_onFocusChange);
    _titleFocusNode.removeListener(_onFocusChange);

    _titleController.dispose();
    _quillController.dispose();
    _editorFocusNode.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 1000), _save);
  }

  Future<void> _save() async {
    if (!mounted) return;

    final title = _titleController.text;
    final contentJson = jsonEncode(
      _quillController.document.toDelta().toJson(),
    );

    if (_currentNoteId == null) {
      if (title.isEmpty &&
          _quillController.document.toPlainText().trim().isEmpty) {
        return;
      }

      final newId = await ref
          .read(notesListProvider.notifier)
          .addNote(title, contentJson);
      if (mounted) {
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
            title: title,
            contentJson: contentJson,
          );
          ref.read(notesListProvider.notifier).updateNote(updatedNote);
        } catch (e) {}
      });
    }
  }

  void switchToolBarMode(ToolBarMode mode) {
    setState(() {
      _toolBarMode = mode;
    });
  }

  void _toggleFormat(Attribute attribute) {
    final selectionStyle = _quillController.getSelectionStyle();
    final currentAttr = selectionStyle.attributes[attribute.key];

    if (currentAttr != null) {
      // Remove format
      _quillController.formatSelection(Attribute.clone(attribute, null));
    } else {
      // Apply format
      _quillController.formatSelection(attribute);
    }
  }

  bool _isFormatActive(Attribute attribute) {
    final style = _quillController.getSelectionStyle();
    return style.attributes.containsKey(attribute.key);
  }

  bool _isHeaderActive(Attribute header) {
    final style = _quillController.getSelectionStyle();
    final attr = style.attributes[Attribute.header.key];
    return attr?.value == header.value;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            TopNavigationBar(
              title: '', // Title is in the content area
              onBack: () => Navigator.of(context).pop(),
              onUndo: () => _quillController.undo(),
              onRedo: () => _quillController.redo(),
              onMore: () {
                // Show more menu
              },
              canUndo: _quillController.hasUndo,
              canRedo: _quillController.hasRedo,
            ),
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      controller: _titleController,
                      focusNode: _titleFocusNode,
                      decoration: const InputDecoration(
                        hintText: 'Title',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      maxLines: null,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: QuillEditor.basic(
                        controller: _quillController,
                        focusNode: _editorFocusNode,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_toolBarMode == ToolBarMode.editor)
              FormattingToolbar(
                onFormatTap: () => switchToolBarMode(ToolBarMode.format),
                onChecklistTap: () => _toggleFormat(Attribute.unchecked),
                onAttachTap: () {},
              )
            else if (_toolBarMode == ToolBarMode.format)
              FormatPanel(
                onTitle: () => _quillController.formatSelection(Attribute.h1),
                onHeading: () => _quillController.formatSelection(Attribute.h2),
                onSubheading: () =>
                    _quillController.formatSelection(Attribute.h3),
                onBody: () => _quillController.formatSelection(
                  Attribute.header,
                ), // Clear header
                onMonospace: () => _toggleFormat(Attribute.codeBlock),
                onBold: () => _toggleFormat(Attribute.bold),
                onItalic: () => _toggleFormat(Attribute.italic),
                onUnderline: () => _toggleFormat(Attribute.underline),
                onStrikethrough: () => _toggleFormat(Attribute.strikeThrough),
                onDashedList: () => _toggleFormat(Attribute.ul),
                onNumberedList: () => _toggleFormat(Attribute.ol),
                onBulletList: () => _toggleFormat(Attribute.ul),
                onIndent: () => _quillController.indentSelection(true),
                onOutdent: () => _quillController.indentSelection(false),

                isBoldActive: _isFormatActive(Attribute.bold),
                isItalicActive: _isFormatActive(Attribute.italic),
                isUnderlineActive: _isFormatActive(Attribute.underline),
                isStrikeActive: _isFormatActive(Attribute.strikeThrough),
                isMonoActive: _isFormatActive(Attribute.codeBlock),
              ),
          ],
        ),
      ),
    );
  }
}

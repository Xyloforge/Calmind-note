import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/notes_provider.dart';
import '../widgets/formatting_toolbar.dart';
import '../widgets/top_navigation_bar.dart';
import '../widgets/format_panel.dart';

import '../widgets/list_format_panel.dart';

enum ToolBarMode { editor, format, list }

class NoteEditorScreen extends ConsumerStatefulWidget {
  final String? noteId;

  const NoteEditorScreen({super.key, this.noteId});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late final QuillController _quillController;
  final FocusNode _editorFocusNode = FocusNode();

  String? _currentNoteId;
  Timer? _debounceTimer;
  bool _isLoading = true;
  ToolBarMode _toolBarMode = ToolBarMode.editor;

  @override
  void initState() {
    super.initState();
    _currentNoteId = widget.noteId;

    if (_currentNoteId == null) {
      final doc = Document();
      // Apply H1 to the first line (paragraph) by formatting the newline character
      doc.format(0, 1, Attribute.h1);
      _quillController = QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
      );
      _isLoading = false; // New notes don't need async loading
    } else {
      _quillController = QuillController.basic();
      _loadNote();
    }

    // Listen to controller changes to update Undo/Redo state and save
    _quillController.addListener(_onEditorChange);
    // Listen to focus changes to hide format panel when typing
    _editorFocusNode.addListener(_onFocusChange);
  }

  void _onEditorChange() {
    if (mounted) setState(() {});
    _onChanged();
  }

  void _onFocusChange() {
    if (_editorFocusNode.hasFocus &&
        (_toolBarMode == ToolBarMode.format ||
            _toolBarMode == ToolBarMode.list)) {
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

        if (note.contentJson.isNotEmpty) {
          try {
            final json = jsonDecode(note.contentJson);
            final doc = Document.fromJson(json);

            // Check if title extraction logic is needed for migration
            // If the document is plain text or doesn't look like it has a title H1,
            // we could choose to insert it. For now, we trust the saved content
            // but ensure we update valid title on save.
            _quillController.document = doc;
          } catch (e) {
            debugPrint('Error parsing delta: $e');
          }
        } else {
          // Fallback for empty content but existing note (shouldn't happen often)
          final doc = Document();
          doc.insert(0, note.title + '\n');
          doc.format(0, 1, Attribute.h1);
          _quillController.document = doc;
        }
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _quillController.removeListener(_onEditorChange);
    _editorFocusNode.removeListener(_onFocusChange);

    _quillController.dispose();
    _editorFocusNode.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 1000), _save);
  }

  Future<void> _save() async {
    if (!mounted) return;

    final plainText = _quillController.document.toPlainText().trim();
    final title = plainText.split('\n').firstOrNull ?? 'Untitled';

    final contentJson = jsonEncode(
      _quillController.document.toDelta().toJson(),
    );

    if (_currentNoteId == null) {
      if (plainText.isEmpty) {
        return;
      }

      final newId = await ref
          .read(notesListProvider.notifier)
          .addNote(title.isEmpty ? 'Untitled' : title, contentJson);
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
            title: title.isEmpty ? 'Untitled' : title,
            contentJson: contentJson,
          );
          ref.read(notesListProvider.notifier).updateNote(updatedNote);
        } catch (e) {
          debugPrint('Error saving note: $e');
        }
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null && mounted) {
      final index = _quillController.selection.baseOffset;
      final length = _quillController.selection.extentOffset - index;

      _quillController.replaceText(
        index,
        length,
        BlockEmbed.image(image.path),
        null,
      );

      _save();
    }
  }

  void _insertHorizontalRule() {
    final index = _quillController.selection.baseOffset;
    final length = _quillController.selection.extentOffset - index;

    // 1. Insert a newline first if cursor is not at start of line
    if (index > 0) {
      _quillController.replaceText(index, 0, '\n', null);
    }

    // 2. Insert the divider embed
    _quillController.replaceText(
      index + 1,
      length,
      const BlockEmbed('divider', 'hr'),
      null,
    );

    // 3. Insert a newline after the divider so next text is on a new line
    _quillController.replaceText(index + 2, 0, '\n', null);

    // Move cursor after the newline
    _quillController.moveCursorToPosition(index + 3);
  }

  void switchToolBarMode(ToolBarMode mode) {
    setState(() {
      _toolBarMode = mode;
    });
  }

  void _toggleFormat(Attribute attribute) {
    final selectionStyle = _quillController.getSelectionStyle();
    final currentAttr = selectionStyle.attributes[attribute.key];

    if (currentAttr != null && currentAttr.value == attribute.value) {
      // Remove format
      _quillController.formatSelection(Attribute.clone(attribute, null));
    } else {
      // Apply format
      _quillController.formatSelection(attribute);
    }
  }

  bool _isFormatActive(Attribute attribute) {
    final style = _quillController.getSelectionStyle();
    return style.attributes.containsKey(attribute.key) &&
        style.attributes[attribute.key]!.value == attribute.value;
  }

  bool _isHeaderActive(Attribute header) {
    final style = _quillController.getSelectionStyle();
    final attr = style.attributes[Attribute.header.key];
    return attr?.value == header.value;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Check if keyboard is visible
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    // Check if editor has focus
    final isEditorFocused = _editorFocusNode.hasFocus;

    final shouldShowToolbar = isKeyboardVisible && isEditorFocused;

    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: theme.colorScheme.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: QuillEditor.basic(
                        controller: _quillController,
                        focusNode: _editorFocusNode,
                        config: QuillEditorConfig(
                          embedBuilders: [
                            ...FlutterQuillEmbeds.editorBuilders(),
                            const DividerEmbedBuilder(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (shouldShowToolbar) ...[
              if (_toolBarMode == ToolBarMode.editor)
                FormattingToolbar(
                  onFormatTap: () => switchToolBarMode(ToolBarMode.format),
                  onChecklistTap: () => _toggleFormat(Attribute.unchecked),
                  onListTap: () => switchToolBarMode(ToolBarMode.list),
                  onAttachTap: _pickImage,
                )
              else if (_toolBarMode == ToolBarMode.format)
                FormatPanel(
                  onTitle: () => _quillController.formatSelection(Attribute.h1),
                  onHeading: () =>
                      _quillController.formatSelection(Attribute.h2),
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
                  onClosePanel: () => switchToolBarMode(ToolBarMode.editor),

                  isBoldActive: _isFormatActive(Attribute.bold),
                  isItalicActive: _isFormatActive(Attribute.italic),
                  isUnderlineActive: _isFormatActive(Attribute.underline),
                  isStrikeActive: _isFormatActive(Attribute.strikeThrough),
                  isMonoActive: _isFormatActive(Attribute.codeBlock),

                  isTitleActive: _isHeaderActive(Attribute.h1),
                  isHeadingActive: _isHeaderActive(Attribute.h2),
                  isSubheadingActive: _isHeaderActive(Attribute.h3),
                  isBodyActive: _isHeaderActive(Attribute.header),
                )
              else if (_toolBarMode == ToolBarMode.list)
                ListFormatPanel(
                  onDashedList: () => _toggleFormat(Attribute.ul),
                  onNumberedList: () => _toggleFormat(Attribute.ol),
                  onBulletList: () =>
                      _toggleFormat(Attribute.ul), // Reusing UL for bullet
                  onSeparator: _insertHorizontalRule,
                  onIndent: () => _quillController.indentSelection(true),
                  onOutdent: () => _quillController.indentSelection(false),
                  onClosePanel: () => switchToolBarMode(ToolBarMode.editor),
                  isDashedListActive: _isFormatActive(Attribute.ul),
                  isNumberedListActive: _isFormatActive(Attribute.ol),
                  isBulletListActive: _isFormatActive(
                    Attribute.ul,
                  ), // Reusing UL
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class DividerEmbedBuilder extends EmbedBuilder {
  const DividerEmbedBuilder();

  @override
  String get key => 'divider';

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Divider(height: 1, thickness: 1),
    );
  }
}

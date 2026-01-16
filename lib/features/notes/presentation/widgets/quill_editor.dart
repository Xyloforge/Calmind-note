import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vnote2/features/notes/presentation/screens/home_screen.dart';

import '../widgets/formatting_toolbar.dart';
import '../widgets/top_navigation_bar.dart';
import '../widgets/format_panel.dart';

import '../widgets/list_format_panel.dart';

enum ToolBarMode { editor, format, list }

class MyQuillEditor extends ConsumerStatefulWidget {
  final Function onSave;
  final QuillController quillController;

  const MyQuillEditor({
    super.key,
    required this.onSave,
    required this.quillController,
  });

  @override
  ConsumerState<MyQuillEditor> createState() => _MyQuillEditorState();
}

class _MyQuillEditorState extends ConsumerState<MyQuillEditor> {
  late final FocusNode _editorFocusNode = FocusNode();

  Timer? _debounceTimer;
  ToolBarMode _toolBarMode = ToolBarMode.editor;

  @override
  void initState() {
    super.initState();

    widget.quillController.addListener(_onEditorChange);

    _autoFocusOnNewNote();
    _editorFocusNode.addListener(_onFocusChange);
  }

  void _autoFocusOnNewNote() {
    if (widget.quillController.document.isEmpty()) {
      // We wait for the first frame to be painted before requesting focus
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _editorFocusNode.requestFocus();
          // Ensure the cursor is at the very beginning
          widget.quillController.updateSelection(
            const TextSelection.collapsed(offset: 0),
            ChangeSource.local,
          );
        }
      });
    }
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

  @override
  void dispose() {
    _debounceTimer?.cancel();
    widget.quillController.removeListener(_onEditorChange);
    _editorFocusNode.removeListener(_onFocusChange);

    _editorFocusNode.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(
      const Duration(milliseconds: 1000),
      () => widget.onSave(),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null && mounted) {
      final index = widget.quillController.selection.baseOffset;
      final length = widget.quillController.selection.extentOffset - index;

      widget.quillController.replaceText(
        index,
        length,
        BlockEmbed.image(image.path),
        null,
      );

      widget.onSave();
    }
  }

  void _insertHorizontalRule() {
    final index = widget.quillController.selection.baseOffset;
    final length = widget.quillController.selection.extentOffset - index;

    // 1. Insert a newline first if cursor is not at start of line
    if (index > 0) {
      widget.quillController.replaceText(index, 0, '\n', null);
    }

    // 2. Insert the divider embed
    widget.quillController.replaceText(
      index + 1,
      length,
      const BlockEmbed('divider', 'hr'),
      null,
    );

    // 3. Insert a newline after the divider so next text is on a new line
    widget.quillController.replaceText(index + 2, 0, '\n', null);

    // Move cursor after the newline
    widget.quillController.moveCursorToPosition(index + 3);
  }

  void switchToolBarMode(ToolBarMode mode) {
    setState(() {
      _toolBarMode = mode;
    });
  }

  void _toggleFormat(Attribute attribute) {
    final selectionStyle = widget.quillController.getSelectionStyle();
    final currentAttr = selectionStyle.attributes[attribute.key];

    if (currentAttr != null && currentAttr.value == attribute.value) {
      // Remove format
      widget.quillController.formatSelection(Attribute.clone(attribute, null));
    } else {
      // Apply format
      widget.quillController.formatSelection(attribute);
    }
  }

  bool _isFormatActive(Attribute attribute) {
    final style = widget.quillController.getSelectionStyle();
    return style.attributes.containsKey(attribute.key) &&
        style.attributes[attribute.key]!.value == attribute.value;
  }

  bool _isHeaderActive(Attribute header) {
    final style = widget.quillController.getSelectionStyle();
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
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          widget.onSave();
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              TopNavigationBar(
                title: '', // Title is in the content area
                onBack: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (_) => false,
                ),
                onUndo: () => widget.quillController.undo(),
                onRedo: () => widget.quillController.redo(),
                onMore: () {
                  // Show more menu
                },
                canUndo: widget.quillController.hasUndo,
                canRedo: widget.quillController.hasRedo,
              ),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: QuillEditor.basic(
                          controller: widget.quillController,
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
                    onTitle: () =>
                        widget.quillController.formatSelection(Attribute.h1),
                    onHeading: () =>
                        widget.quillController.formatSelection(Attribute.h2),
                    onSubheading: () =>
                        widget.quillController.formatSelection(Attribute.h3),
                    onBody: () => widget.quillController.formatSelection(
                      Attribute.header,
                    ), // Clear header
                    onMonospace: () => _toggleFormat(Attribute.codeBlock),
                    onBold: () => _toggleFormat(Attribute.bold),
                    onItalic: () => _toggleFormat(Attribute.italic),
                    onUnderline: () => _toggleFormat(Attribute.underline),
                    onStrikethrough: () =>
                        _toggleFormat(Attribute.strikeThrough),
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
                    onIndent: () =>
                        widget.quillController.indentSelection(true),
                    onOutdent: () =>
                        widget.quillController.indentSelection(false),
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

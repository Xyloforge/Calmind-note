import 'dart:convert';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vnote2/core/enums/pref_keys.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../domain/models/note_model.dart';
import '../providers/notes_provider.dart';
import 'folder_list_screen.dart';
import 'note_editor_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final String? folderId;
  final String? folderName;

  const HomeScreen({super.key, this.folderId, this.folderName});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _markHomeAsLastScreen();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  Future<void> _markHomeAsLastScreen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(LastScreenKeys.screen, LastScreenKeys.home);
    await prefs.remove(LastScreenKeys.noteId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Map<String, List<Note>> _groupNotes(List<Note> notes) {
    if (notes.isEmpty) return {};

    final grouped = <String, List<Note>>{};

    final filtered = notes.where((note) {
      // 1. Filter by Search Query
      if (_searchQuery.isNotEmpty) {
        final content = _getPreview(note.contentJson).toLowerCase();
        final matchesSearch =
            note.title.toLowerCase().contains(_searchQuery) ||
            content.contains(_searchQuery);
        if (!matchesSearch) return false;
      }

      // 2. Filter by Folder
      // If folderId is provided, note.folderId must match it.
      // If folderId is null (All Notes), show all notes?
      // Requirement: "All Notes" shows everything.
      // Requirement: "Notes store a folderId? null = All Notes" -> Wait,
      // "null = All Notes" usually means "Uncategorized".
      // But "All Notes" view shows EVERYTHING (categorized or not).
      // And "Uncategorized" isn't a folder in the list?
      // Re-reading requirements:
      // "Notes store a folderId? null = All Notes" (This phrasing is slightly ambiguous).
      // "Folder deletion: Notes inside return to All Notes" -> Implies folderId becomes null.
      // "Folder List Screen: 'All Notes' always at the top".
      // "Notes List Screen: Shows notes filtered by selected folder. 'All Notes' shows everything."
      // So:
      // - widget.folderId == null => Show ALL notes (ignore note.folderId).
      // - widget.folderId == 'someId' => Show notes where note.folderId == 'someId'.

      if (widget.folderId != null) {
        return note.folderId == widget.folderId;
      }

      return true;
    }).toList();

    filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final note in filtered) {
      String group;

      if (note.isPinned) {
        group = 'Pinned';
      } else {
        final date = DateTime(
          note.updatedAt.year,
          note.updatedAt.month,
          note.updatedAt.day,
        );

        if (date.isAtSameMomentAs(today)) {
          group = 'Today';
        } else if (date.isAtSameMomentAs(yesterday)) {
          group = 'Yesterday';
        } else if (now.difference(note.updatedAt).inDays <= 7) {
          group = 'Previous 7 Days';
        } else if (now.difference(note.updatedAt).inDays <= 30) {
          group = 'Previous 30 Days';
        } else {
          group = DateFormat('MMMM yyyy').format(note.updatedAt);
        }
      }

      grouped.putIfAbsent(group, () => []).add(note);
    }

    return grouped;
  }

  List<String> _sortGroups(List<String> keys) {
    return keys..sort((a, b) {
      if (a == 'Pinned') return -1;
      if (b == 'Pinned') return 1;
      return 0; // Maintain chronological order from insertion
    });
  }

  String _getPreview(String jsonContent) {
    if (jsonContent.isEmpty) return 'No additional text';

    try {
      final json = jsonDecode(jsonContent);
      final doc = quill.Document.fromJson(json);
      final lines = doc.toPlainText().split('\n');
      if (lines.length <= 1) return 'No additional text';
      final contentWithoutTitle = lines.sublist(1).join(' ').trim();
      return contentWithoutTitle.isEmpty
          ? 'No additional text'
          : contentWithoutTitle;
    } catch (e) {
      return 'Note content';
    }
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(notesListProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // iOS styled background
    final backgroundColor = theme.scaffoldBackgroundColor;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: backgroundColor,
      body: notesAsync.when(
        data: (notes) {
          final groupedNotes = _groupNotes(notes);
          final sortedKeys = _sortGroups(groupedNotes.keys.toList());

          return CustomScrollView(
            slivers: [
              SliverAppBar.large(
                backgroundColor: backgroundColor,
                surfaceTintColor: Colors.transparent,
                expandedHeight: 120,
                iconTheme: IconThemeData(color: theme.primaryColor),
                collapsedHeight: 80,
                floating: false,
                pinned: true,
                leading: widget.folderId == null
                    ? IconButton(
                        icon: Icon(
                          CupertinoIcons.folder,
                          color: theme.primaryColor,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const FolderListScreen(),
                            ),
                          );
                        },
                      )
                    : null, // Default Back button for folders
                titleTextStyle: TextStyle(
                  fontSize: 22,
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
                title: Text(widget.folderName ?? 'Notes'),
                actions: [
                  IconButton(
                    icon: Icon(Icons.settings, color: theme.primaryColor),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: CupertinoSearchTextField(
                    controller: _searchController,
                    placeholder: 'Search',
                    backgroundColor: isDark
                        ? const Color(0xFF1C1C1E)
                        : const Color(0xFFE5E5EA),
                    itemColor: const Color(0xFF8E8E93),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),

              if (notes.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'No notes yet',
                      style: TextStyle(color: theme.disabledColor),
                    ),
                  ),
                )
              else if (groupedNotes.values.every((l) => l.isEmpty))
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'No matches found',
                      style: TextStyle(color: theme.disabledColor),
                    ),
                  ),
                )
              else
                ...sortedKeys.map((group) {
                  final groupNotes = groupedNotes[group]!;
                  return SliverMainAxisGroup(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 16, 8),
                          child: Text(
                            group.toUpperCase(),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? const Color(0xFF8E8E93)
                                  : const Color(0xFF6E6E73),
                            ),
                          ),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final note = groupNotes[index];
                          final isFirst = index == 0;
                          final isLast = index == groupNotes.length - 1;
                          return _buildNoteTile(note, isFirst, isLast, theme);
                        }, childCount: groupNotes.length),
                      ),
                    ],
                  );
                }),

              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      extendBody: true,
      bottomNavigationBar: RepaintBoundary(
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom,
                top: 10,
                left: 20,
                right: 20,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2), // Subtle tint
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Right Side: Create Note
                  IconButton(
                    icon: Icon(
                      Icons.edit_note,
                      size: 32,
                      color: theme.primaryColor,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              NoteEditorScreen(folderId: widget.folderId),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoteTile(Note note, bool isFirst, bool isLast, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final dividerColor = isDark
        ? const Color(0xFF38383A)
        : const Color(0xFFC6C6C8);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(10) : Radius.zero,
          bottom: isLast ? const Radius.circular(10) : Radius.zero,
        ),
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => NoteEditorScreen(noteId: note.id),
                  ),
                );
              },
              borderRadius: BorderRadius.vertical(
                top: isFirst ? const Radius.circular(10) : Radius.zero,
                bottom: isLast ? const Radius.circular(10) : Radius.zero,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.title.isEmpty ? 'New Note' : note.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          _formatTime(note.updatedAt),
                          style: TextStyle(
                            color: theme.disabledColor,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _getPreview(note.contentJson),
                            style: TextStyle(
                              color: theme.disabledColor.withOpacity(0.6),
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (!isLast)
            Divider(height: 1, thickness: 0.5, indent: 16, color: dividerColor),
        ],
      ),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return DateFormat('h:mm a').format(date);
    } else if (now.difference(date).inDays < 7) {
      return DateFormat('EEEE').format(date);
    }
    return DateFormat('M/d/yy').format(date);
  }
}

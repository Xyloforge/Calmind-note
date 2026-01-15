import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../domain/models/note_model.dart';
import '../providers/notes_provider.dart';
import 'note_editor_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
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
      if (_searchQuery.isEmpty) return true;
      final content = _getPreview(note.contentJson).toLowerCase();
      return note.title.toLowerCase().contains(_searchQuery) ||
          content.contains(_searchQuery);
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
                collapsedHeight: 80,
                floating: false,
                pinned: true,
                titleTextStyle: TextStyle(
                  fontSize: 22,
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
                title: const Text('Notes'),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.primaryColor,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const NoteEditorScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
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

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vnote2/features/notes/presentation/screens/note_editor_screen.dart';
import '../providers/folders_provider.dart';
import '../providers/notes_provider.dart';
import 'home_screen.dart';

class FolderListScreen extends ConsumerStatefulWidget {
  const FolderListScreen({super.key});

  @override
  ConsumerState<FolderListScreen> createState() => _FolderListScreenState();
}

class _FolderListScreenState extends ConsumerState<FolderListScreen> {
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

  @override
  Widget build(BuildContext context) {
    final foldersAsync = ref.watch(foldersListProvider);
    final allNotesAsync = ref.watch(notesListProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = theme.scaffoldBackgroundColor;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      backgroundColor: backgroundColor,
      body: foldersAsync.when(
        data: (folders) {
          final allNotesCount = allNotesAsync.valueOrNull?.length ?? 0;

          final filteredFolders = folders.where((folder) {
            if (_searchQuery.isEmpty) return true;
            return folder.name.toLowerCase().contains(_searchQuery);
          }).toList();

          // Sort folders if needed, currently just using the order from provider

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
                titleTextStyle: TextStyle(
                  fontSize: 22,
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
                title: const Text('Folders'),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: CupertinoSearchTextField(
                    controller: _searchController,
                    placeholder: 'Search Folders',
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

              if (filteredFolders.isEmpty && _searchQuery.isNotEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'No folders found',
                      style: TextStyle(color: theme.disabledColor),
                    ),
                  ),
                )
              else ...[
                // "All Notes" Section - Only show if not searching or if query matches "all notes" broadly?
                // Actually, typically search usually allows finding "All Notes" if the user types it,
                // but let's keep "All Notes" always visible at the top unless search explicitly filters it out logic-wise.
                // For simplicity and standard behavior, let's keep "All Notes" visible unless it clearly doesn't match,
                // BUT user said "search for folders list". "All Notes" is a special "smart folder".
                // Let's matching 'All Notes' name if query is not empty.
                if (_searchQuery.isEmpty || 'all notes'.contains(_searchQuery))
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: 24,
                      ), // Space between All Notes and Folders
                      child: _buildSingleItemGroup(
                        theme,
                        title: 'All Notes',
                        icon: CupertinoIcons.tray,
                        count: allNotesCount,
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomeScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                // Folders List
                if (filteredFolders.isNotEmpty)
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final folder = filteredFolders[index];
                      final noteCount =
                          allNotesAsync.valueOrNull
                              ?.where((n) => n.folderId == folder.id)
                              .length ??
                          0;

                      final isFirst = index == 0;
                      final isLast = index == filteredFolders.length - 1;

                      return _buildFolderTile(
                        context,
                        folder,
                        noteCount,
                        isFirst,
                        isLast,
                        theme,
                      );
                    }, childCount: filteredFolders.length),
                  ),
              ],

              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left Side: Create Folder
                  IconButton(
                    icon: Icon(
                      Icons.create_new_folder_outlined,
                      size: 28,
                      color: theme.primaryColor,
                    ),
                    onPressed: () {
                      _showFolderDialog(context, ref, null, null);
                    },
                  ),
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
                          builder: (context) => const NoteEditorScreen(),
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

  Widget _buildSingleItemGroup(
    ThemeData theme, {
    required String title,
    required IconData icon,
    required int count,
    required VoidCallback onTap,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: theme.primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '$count',
                  style: TextStyle(color: theme.disabledColor, fontSize: 16),
                ),
                const SizedBox(width: 8),
                Icon(
                  CupertinoIcons.chevron_right,
                  size: 16,
                  color: theme.disabledColor.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFolderTile(
    BuildContext context,
    dynamic
    folder, // Using dynamic to avoid import issues if Folder model isn't exported perfectly, but ideally should be typed
    int noteCount,
    bool isFirst,
    bool isLast,
    ThemeData theme,
  ) {
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final dividerColor = isDark
        ? const Color(0xFF38383A)
        : const Color(0xFFC6C6C8);

    return Dismissible(
      key: Key(folder.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Folder?'),
            content: const Text(
              'Notes in this folder will be moved to "All Notes".',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        ref.read(foldersListProvider.notifier).deleteFolder(folder.id);
      },
      child: Container(
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(
                        folderId: folder.id,
                        folderName: folder.name,
                      ),
                    ),
                  );
                },
                onLongPress: () {
                  _showFolderDialog(context, ref, folder.id, folder.name);
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
                  child: Row(
                    children: [
                      Icon(CupertinoIcons.folder, color: theme.primaryColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          folder.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '$noteCount',
                        style: TextStyle(
                          color: theme.disabledColor,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        CupertinoIcons.chevron_right,
                        size: 16,
                        color: theme.disabledColor.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (!isLast)
              Divider(
                height: 1,
                thickness: 0.5,
                indent: 44,
                color: dividerColor,
              ),
          ],
        ),
      ),
    );
  }

  void _showFolderDialog(
    BuildContext context,
    WidgetRef ref,
    String? folderId,
    String? currentName,
  ) {
    final isEditing = folderId != null;
    final controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Rename Folder' : 'New Folder'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Folder Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Consumer(
            builder: (context, ref, child) {
              return TextButton(
                onPressed: () {
                  final name = controller.text.trim();
                  if (name.isNotEmpty) {
                    if (isEditing) {
                      ref
                          .read(foldersListProvider.notifier)
                          .renameFolder(folderId, name);
                    } else {
                      ref.read(foldersListProvider.notifier).createFolder(name);
                    }
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
              );
            },
          ),
        ],
      ),
    );
  }
}

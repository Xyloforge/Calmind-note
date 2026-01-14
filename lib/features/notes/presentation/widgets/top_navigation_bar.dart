import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TopNavigationBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onMore;
  final bool canUndo;
  final bool canRedo;

  const TopNavigationBar({
    super.key,
    required this.title,
    required this.onBack,
    required this.onUndo,
    required this.onRedo,
    required this.onMore,
    required this.canUndo,
    required this.canRedo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final disabledColor = theme.disabledColor;

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Back button (left)
          IconButton(
            icon: const Icon(CupertinoIcons.back),
            padding: EdgeInsets.zero,
            onPressed: onBack,
            color: primaryColor,
          ),
          Text(title, style: TextStyle(color: primaryColor)),

          const Spacer(),

          // Undo button (right)
          IconButton(
            icon: const Icon(CupertinoIcons.arrow_turn_up_left),
            padding: EdgeInsets.zero,
            onPressed: canUndo ? onUndo : null,
            color: canUndo ? primaryColor : disabledColor,
          ),

          // Redo button (right)
          IconButton(
            icon: const Icon(CupertinoIcons.arrow_turn_up_right),
            padding: EdgeInsets.zero,
            onPressed: canRedo ? onRedo : null,
            color: canRedo ? primaryColor : disabledColor,
          ),

          // More menu (right)
          IconButton(
            icon: const Icon(CupertinoIcons.ellipsis),
            padding: EdgeInsets.zero,
            onPressed: onMore,
            color: primaryColor,
          ),
        ],
      ),
    );
  }
}

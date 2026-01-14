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
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Back button (left)
          IconButton(
            icon: const Icon(CupertinoIcons.back),
            padding: EdgeInsets.zero,
            onPressed: onBack,
          ),
          Text(title, style: const TextStyle(color: Colors.blue)),

          const Spacer(),

          // Undo button (right)
          IconButton(
            icon: const Icon(CupertinoIcons.arrow_turn_up_left),
            padding: EdgeInsets.zero,
            onPressed: canUndo ? onUndo : null,
            color: canUndo ? null : Colors.grey.withOpacity(0.3),
          ),

          // Redo button (right)
          IconButton(
            icon: const Icon(CupertinoIcons.arrow_turn_up_right),
            padding: EdgeInsets.zero,
            onPressed: canRedo ? onRedo : null,
            color: canRedo ? null : Colors.grey.withOpacity(0.3),
          ),

          // More menu (right)
          IconButton(
            icon: const Icon(CupertinoIcons.ellipsis),
            padding: EdgeInsets.zero,
            onPressed: onMore,
          ),
        ],
      ),
    );
  }
}

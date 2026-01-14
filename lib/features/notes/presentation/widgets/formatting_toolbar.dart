import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FormattingToolbar extends StatelessWidget {
  final VoidCallback onFormatTap; // Aa button
  final VoidCallback onChecklistTap; // Checklist button
  final VoidCallback onAttachTap; // Attach button
  final VoidCallback? onAudioTap; // Audio (optional, Phase 2)
  final VoidCallback? onDrawTap; // Draw (optional, Phase 2)

  const FormattingToolbar({
    super.key,
    required this.onFormatTap,
    required this.onChecklistTap,
    required this.onAttachTap,
    this.onAudioTap,
    this.onDrawTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      color: const Color(0xFFF2F2F7), // iOS toolbar gray
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Format button (Aa)
          _ToolbarButton(label: 'Aa', isText: true, onTap: onFormatTap),

          // Checklist button
          _ToolbarButton(
            icon: CupertinoIcons.checkmark_square,
            onTap: onChecklistTap,
          ),

          // Attach button
          _ToolbarButton(icon: CupertinoIcons.paperclip, onTap: onAttachTap),

          // Audio button (disabled in MVP)
          _ToolbarButton(
            icon: CupertinoIcons.mic,
            onTap: onAudioTap,
            enabled: onAudioTap != null,
          ),

          // Draw button (disabled in MVP)
          _ToolbarButton(
            icon: CupertinoIcons.pencil_outline,
            onTap: onDrawTap,
            enabled: onDrawTap != null,
          ),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData? icon;
  final String? label;
  final bool isText;
  final VoidCallback? onTap;
  final bool enabled;

  const _ToolbarButton({
    this.icon,
    this.label,
    this.isText = false,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        child: isText
            ? Text(
                label ?? '',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: enabled ? Colors.black : Colors.grey,
                ),
              )
            : Icon(
                icon,
                size: 24,
                color: enabled ? Colors.black : Colors.grey.withOpacity(0.4),
              ),
      ),
    );
  }
}

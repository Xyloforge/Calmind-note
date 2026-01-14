import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FormatPanel extends StatelessWidget {
  final VoidCallback onTitle;
  final VoidCallback onHeading;
  final VoidCallback onSubheading;
  final VoidCallback onBody;
  final VoidCallback onMonospace;
  final VoidCallback onBold;
  final VoidCallback onItalic;
  final VoidCallback onUnderline;
  final VoidCallback onStrikethrough;
  final VoidCallback onDashedList;
  final VoidCallback onNumberedList;
  final VoidCallback onBulletList;
  final VoidCallback onIndent;
  final VoidCallback onOutdent;
  final bool isBoldActive;
  final bool isItalicActive;
  final bool isUnderlineActive;
  final bool isStrikeActive;
  final bool isMonoActive;

  const FormatPanel({
    super.key,
    required this.onTitle,
    required this.onHeading,
    required this.onSubheading,
    required this.onBody,
    required this.onMonospace,
    required this.onBold,
    required this.onItalic,
    required this.onUnderline,
    required this.onStrikethrough,
    required this.onDashedList,
    required this.onNumberedList,
    required this.onBulletList,
    required this.onIndent,
    required this.onOutdent,
    required this.isBoldActive,
    required this.isItalicActive,
    required this.isUnderlineActive,
    required this.isStrikeActive,
    required this.isMonoActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF2F2F7),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Text Styles
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StyleButton(
                  label: 'Title',
                  onTap: onTitle,
                  fontSize: 20,
                  isBold: true,
                ),
                const SizedBox(width: 8),
                _StyleButton(
                  label: 'Heading',
                  onTap: onHeading,
                  fontSize: 17,
                  isBold: true,
                ),
                const SizedBox(width: 8),
                _StyleButton(
                  label: 'Subhead',
                  onTap: onSubheading,
                  fontSize: 15,
                  isBold: true,
                ),
                const SizedBox(width: 8),
                _StyleButton(label: 'Body', onTap: onBody, fontSize: 14),
                const SizedBox(width: 8),
                _StyleButton(
                  label: 'Mono',
                  onTap: onMonospace,
                  fontSize: 13,
                  isMono: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Row 2: Text Formatting
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _FormatButton(label: 'B', onTap: onBold, isBold: true),
              const SizedBox(width: 16),
              _FormatButton(label: 'I', onTap: onItalic, isItalic: true),
              const SizedBox(width: 16),
              _FormatButton(label: 'U', onTap: onUnderline, isUnderline: true),
              const SizedBox(width: 16),
              _FormatButton(label: 'S', onTap: onStrikethrough, isStrike: true),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Row 3: Lists
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ListButton(icon: CupertinoIcons.minus, onTap: onDashedList),
              _ListButton(label: '1.', onTap: onNumberedList),
              _ListButton(
                icon: CupertinoIcons.circle_fill,
                onTap: onBulletList,
                iconSize: 8,
              ),
              const SizedBox(width: 20),
              _ListButton(
                icon: CupertinoIcons.arrow_left_to_line,
                onTap: onOutdent,
              ),
              _ListButton(
                icon: CupertinoIcons.arrow_right_to_line,
                onTap: onIndent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StyleButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final double fontSize;
  final bool isBold;
  final bool isMono;

  const _StyleButton({
    required this.label,
    required this.onTap,
    required this.fontSize,
    this.isBold = false,
    this.isMono = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontFamily: isMono ? 'Courier' : null,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

class _FormatButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isBold;
  final bool isItalic;
  final bool isUnderline;
  final bool isStrike;

  const _FormatButton({
    required this.label,
    required this.onTap,
    this.isBold = false,
    this.isItalic = false,
    this.isUnderline = false,
    this.isStrike = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 20,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
            decoration: isUnderline
                ? TextDecoration.underline
                : isStrike
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

class _ListButton extends StatelessWidget {
  final IconData? icon;
  final String? label;
  final VoidCallback onTap;
  final double? iconSize;

  const _ListButton({
    this.icon,
    this.label,
    required this.onTap,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: icon != null
            ? Icon(icon, size: iconSize ?? 24, color: Colors.black)
            : Text(
                label ?? '',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
      ),
    );
  }
}

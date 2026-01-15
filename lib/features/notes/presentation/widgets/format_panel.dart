import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

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
  final VoidCallback onClosePanel;

  final bool isTitleActive;
  final bool isHeadingActive;
  final bool isSubheadingActive;
  final bool isBodyActive;
  final bool isMonoActive;
  final bool isBoldActive;
  final bool isItalicActive;
  final bool isUnderlineActive;
  final bool isStrikeActive;
  final bool isDashedListActive;
  final bool isNumberedListActive;
  final bool isBulletListActive;

  const FormatPanel({
    super.key,
    required this.onClosePanel,
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
    required this.isBodyActive,
    required this.isMonoActive,
    required this.isBoldActive,
    required this.isItalicActive,
    required this.isUnderlineActive,
    required this.isStrikeActive,
    required this.isDashedListActive,
    required this.isNumberedListActive,
    required this.isBulletListActive,
    required this.isTitleActive,
    required this.isHeadingActive,
    required this.isSubheadingActive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final toolbarColor = theme.appColors.toolbarBackground;

    return Container(
      color: toolbarColor,
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
                  fontSize: 17,
                  isBold: true,
                  isActive: isTitleActive,
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: Theme.of(context).dividerColor,
                ),
                _StyleButton(
                  label: 'Heading',
                  onTap: onHeading,
                  fontSize: 17,
                  isBold: true,
                  isActive: isHeadingActive,
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: Theme.of(context).dividerColor,
                ),
                _StyleButton(
                  label: 'Subhead',
                  onTap: onSubheading,
                  fontSize: 17,
                  isBold: true,
                  isActive: isSubheadingActive,
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: Theme.of(context).dividerColor,
                ),
                _StyleButton(
                  label: 'Body',
                  onTap: onBody,
                  fontSize: 17,
                  isActive: isBodyActive,
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: Theme.of(context).dividerColor,
                ),
                _StyleButton(
                  label: 'Mono',
                  onTap: onMonospace,
                  fontSize: 17,
                  isMono: true,
                  isActive: isMonoActive,
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          const SizedBox(height: 8),

          // Row 2: Text Formatting
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _FormatButton(
                label: 'B',
                onTap: onBold,
                isBold: true,
                isActive: isBoldActive,
              ),
              const SizedBox(width: 34),
              _FormatButton(
                label: 'I',
                onTap: onItalic,
                isItalic: true,
                isActive: isItalicActive,
              ),
              const SizedBox(width: 34),
              _FormatButton(
                label: 'U',
                onTap: onUnderline,
                isUnderline: true,
                isActive: isUnderlineActive,
              ),
              const SizedBox(width: 34),
              _FormatButton(
                label: 'S',
                onTap: onStrikethrough,
                isStrike: true,
                isActive: isStrikeActive,
              ),
              const SizedBox(width: 34),
              _FormatButton(label: 'X', onTap: onClosePanel),
            ],
          ),

          const SizedBox(height: 8),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          const SizedBox(height: 8),

          // Row 3: Lists
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ListButton(
                icon: CupertinoIcons.minus,
                onTap: onDashedList,
                isActive: isDashedListActive,
              ),
              const SizedBox(width: 8),
              _ListButton(
                label: '1.',
                onTap: onNumberedList,
                isActive: isNumberedListActive,
              ),
              const SizedBox(width: 8),
              _ListButton(
                icon: CupertinoIcons.circle_fill,
                onTap: onBulletList,
                iconSize: 8,
                isActive: isBulletListActive,
              ),
              const SizedBox(width: 8),
              _ListButton(
                icon: CupertinoIcons.arrow_left_to_line,
                onTap: onOutdent,
                isActive: false,
              ),
              const SizedBox(width: 8),
              _ListButton(
                icon: CupertinoIcons.arrow_right_to_line,
                onTap: onIndent,
                isActive: false,
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
  final bool isActive;

  const _StyleButton({
    required this.label,
    required this.onTap,
    required this.fontSize,
    this.isBold = false,
    this.isMono = false,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Colors based on theme
    final activeColor = theme.colorScheme.primary;
    final inactiveBackground = theme.appColors.toolbarBackground;
    final inactiveBorder = theme.colorScheme.secondary;
    final activeTextColor = theme.colorScheme.surface;
    final inactiveTextColor = theme.textTheme.bodyLarge?.color ?? Colors.black;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? activeColor : inactiveBackground,
          borderRadius: isActive ? BorderRadius.circular(8) : null,
          border: isActive ? Border.all(color: activeColor) : null,
          boxShadow: isActive || isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontFamily: isMono ? 'Courier' : null,
            color: isActive ? activeTextColor : inactiveTextColor,
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
  final bool isActive;

  const _FormatButton({
    required this.label,
    required this.onTap,
    this.isBold = false,
    this.isItalic = false,
    this.isUnderline = false,
    this.isStrike = false,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final background = theme.appColors.toolbarBackground;
    final inactiveBorder = theme.appColors.toolbarBackground;
    final activeTextColor = theme.colorScheme.primary;
    final inactiveTextColor = theme.textTheme.bodyLarge?.color ?? Colors.black;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: inactiveBorder),
          boxShadow: isActive || isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
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
            color: isActive ? activeTextColor : inactiveTextColor,
            decorationColor: isActive ? activeTextColor : inactiveTextColor,
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
  final bool isActive;

  const _ListButton({
    this.icon,
    this.label,
    required this.onTap,
    this.iconSize,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final background = theme.appColors.toolbarBackground;
    final inactiveBorder = theme.appColors.toolbarBackground;
    final activeContentColor = theme.colorScheme.primary;
    final inactiveContentColor =
        theme.textTheme.bodyLarge?.color ?? Colors.black;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: inactiveBorder),
          boxShadow: isActive || isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: icon != null
            ? Icon(
                icon,
                size: iconSize ?? 24,
                color: isActive ? activeContentColor : inactiveContentColor,
              )
            : Text(
                label ?? '',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: isActive ? activeContentColor : inactiveContentColor,
                ),
              ),
      ),
    );
  }
}

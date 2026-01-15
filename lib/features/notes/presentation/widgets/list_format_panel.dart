import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ListFormatPanel extends StatelessWidget {
  final VoidCallback onDashedList;
  final VoidCallback onNumberedList;
  final VoidCallback onBulletList;
  final VoidCallback onSeparator; // New functionality
  final VoidCallback onIndent;
  final VoidCallback onOutdent;
  final VoidCallback onClosePanel;

  final bool isDashedListActive;
  final bool isNumberedListActive;
  final bool isBulletListActive;

  const ListFormatPanel({
    super.key,
    required this.onDashedList,
    required this.onNumberedList,
    required this.onBulletList,
    required this.onSeparator,
    required this.onIndent,
    required this.onOutdent,
    required this.onClosePanel,
    required this.isDashedListActive,
    required this.isNumberedListActive,
    required this.isBulletListActive,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
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
                icon: CupertinoIcons.minus_square, // Icon for Separator
                onTap: onSeparator,
                isActive: false,
              ),
              const SizedBox(height: 8),
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
              const SizedBox(width: 8), // Add spacing before close button
              _CloseButton(onTap: onClosePanel),
            ],
          ),
        ],
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

class _CloseButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CloseButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final background = theme.appColors.toolbarBackground;
    final activeTextColor =
        theme.colorScheme.primary; // Using primary color for consistency

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 50, // Slightly wider for text
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isDark
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
          "Close",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: activeTextColor,
          ),
        ),
      ),
    );
  }
}

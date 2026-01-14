import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum AppLanguage {
  english('English', 'en'),
  spanish('Español', 'es'),
  french('Français', 'fr'),
  german('Deutsch', 'de'),
  chinese('中文', 'zh'),
  japanese('日本語', 'ja'),
  korean('한국어', 'ko'),
  russian('Русский', 'ru');

  final String displayName;
  final String code;

  const AppLanguage(this.displayName, this.code);
}

class LanguageSelectorScreen extends StatefulWidget {
  const LanguageSelectorScreen({super.key});

  @override
  State<LanguageSelectorScreen> createState() => _LanguageSelectorScreenState();
}

class _LanguageSelectorScreenState extends State<LanguageSelectorScreen> {
  // Temporary state since provider was removed
  AppLanguage _selectedLanguage = AppLanguage.english;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Determine colors based on theme
    final backgroundColor = isDark
        ? const Color(0xFF000000)
        : const Color(0xFFF2F2F7);
    final surfaceColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final primaryColor = theme.primaryColor;

    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Language'),
        previousPageTitle: 'Settings',
        backgroundColor: null,
        border: null,
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          children: [
            Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(10),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: AppLanguage.values.asMap().entries.map((entry) {
                  final index = entry.key;
                  final language = entry.value;
                  final isSelected = language == _selectedLanguage;
                  final isLast = index == AppLanguage.values.length - 1;

                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedLanguage = language;
                          });
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12, // Increased touch target
                          ),
                          child: Row(
                            children: [
                              Text(
                                language.displayName,
                                style: TextStyle(
                                  fontSize: 17,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                              const Spacer(),
                              if (isSelected)
                                Icon(
                                  CupertinoIcons.check_mark,
                                  color: primaryColor,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (!isLast)
                        Divider(
                          height: 1,
                          thickness: 0.5,
                          indent: 16, // iOS style separator indent
                          color: isDark
                              ? const Color(0xFF38383A)
                              : const Color(0xFFC6C6C8),
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Language changes will take effect immediately.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? const Color(0xFF8E8E93)
                      : const Color(0xFF6E6E73),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

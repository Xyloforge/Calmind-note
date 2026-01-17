import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/settings_tile.dart';
import '../widgets/theme_selector.dart';
import 'language_selector_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use CupertinoPageScaffold for the authentic iOS feel
    // since we wrapped the whole app in Material, we can nest Cupertino scaffolds.
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Settings',

          style: TextStyle(fontSize: 20, color: Theme.of(context).primaryColor),
        ),

        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        border: null, // Clean look
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: ListView(
          children: [
            // Appearance Section
            _buildSectionHeader('APPEARANCE'),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: _sectionDecoration(context),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: ThemeSelector(),
              ),
            ),

            const SizedBox(height: 24),

            // Language Section
            _buildSectionHeader('LANGUAGE'),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: _sectionDecoration(context),
              child: Column(
                children: [
                  SettingsTile(
                    icon: Icons.language,
                    iconColor: Colors.blue,
                    title: 'Language',
                    trailing: const Text(
                      'English',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => const LanguageSelectorScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Backup & Sync Section
            _buildSectionHeader('BACKUP & SYNC'),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: _sectionDecoration(context),
              child: Column(
                children: [
                  SettingsTile(
                    icon: CupertinoIcons.cloud,
                    iconColor: Colors.purple,
                    title: 'iCloud Backup',
                    trailing: CupertinoSwitch(value: false, onChanged: (v) {}),
                    showArrow: false,
                  ),
                  _buildDivider(context),
                  SettingsTile(
                    icon: CupertinoIcons.doc_on_clipboard,
                    iconColor: Colors.orange,
                    title: 'Export Notes',
                    onTap: () {}, // Disabled/Coming soon
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Editor Section
            _buildSectionHeader('EDITOR'),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: _sectionDecoration(context),
              child: Column(
                children: [
                  SettingsTile(
                    icon: CupertinoIcons.text_alignleft,
                    iconColor: Colors.green,
                    title: 'Smart Formatting',
                    showArrow: false,
                    trailing: CupertinoSwitch(value: true, onChanged: (v) {}),
                  ),
                  _buildDivider(context),
                  SettingsTile(
                    icon: CupertinoIcons.sparkles,
                    iconColor: Colors.indigo,
                    title: 'AI Auto-Layout',
                    showArrow: false,
                    trailing: CupertinoSwitch(value: false, onChanged: (v) {}),
                  ),
                  _buildDivider(context),
                  SettingsTile(
                    icon: CupertinoIcons.waveform,
                    iconColor: Colors.pink,
                    title: 'Haptic Feedback',
                    showArrow: false,
                    trailing: CupertinoSwitch(value: true, onChanged: (v) {}),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // General Section
            _buildSectionHeader('GENERAL'),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: _sectionDecoration(context),
              child: Column(
                children: [
                  SettingsTile(
                    icon: CupertinoIcons.info,
                    iconColor: Colors.grey,
                    title: 'About',
                    onTap: () {},
                  ),
                  _buildDivider(context),
                  SettingsTile(
                    icon: CupertinoIcons.ellipses_bubble,
                    iconColor: Colors.blueGrey,
                    title: 'Send Feedback',
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            Center(
              child: Text(
                'Version 0.1.0',
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 32, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  BoxDecoration _sectionDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      borderRadius: BorderRadius.circular(10),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      indent: 50, // Indent to align with text
      color: Theme.of(context).dividerColor,
    );
  }
}

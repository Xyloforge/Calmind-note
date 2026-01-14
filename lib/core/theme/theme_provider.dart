import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

// Keys for SharedPreferences
const String kThemeModeKey = 'theme_mode';
const String kAccentColorKey = 'accent_color';

class ThemeState {
  final ThemeMode themeMode;
  final AppAccentColor accentColor;

  const ThemeState({required this.themeMode, required this.accentColor});

  ThemeState copyWith({ThemeMode? themeMode, AppAccentColor? accentColor}) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
    );
  }
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  final SharedPreferences prefs;

  ThemeNotifier(this.prefs)
    : super(
        ThemeState(
          themeMode: _loadThemeMode(prefs),
          accentColor: _loadAccentColor(prefs),
        ),
      );

  static ThemeMode _loadThemeMode(SharedPreferences prefs) {
    final modeIndex = prefs.getInt(kThemeModeKey);
    if (modeIndex == null) return ThemeMode.system; // Default to System
    return ThemeMode.values[modeIndex];
  }

  static AppAccentColor _loadAccentColor(SharedPreferences prefs) {
    final accentIndex = prefs.getInt(kAccentColorKey);
    if (accentIndex == null) return AppAccentColor.blue; // Default to Blue
    // Safe check if enum index is out of bounds (e.g. if we remove colors later)
    if (accentIndex < 0 || accentIndex >= AppAccentColor.values.length) {
      return AppAccentColor.blue;
    }
    return AppAccentColor.values[accentIndex];
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await prefs.setInt(kThemeModeKey, mode.index);
  }

  Future<void> setAccentColor(AppAccentColor color) async {
    state = state.copyWith(accentColor: color);
    await prefs.setInt(kAccentColorKey, color.index);
  }
}

// Provider for SharedPreferences (Assuming it's initialized in main and overridden,
// but for cleaner DI we can use a FutureProvider or just pass it if we init in main)
// For now, let's assume we initialize SP in main and pass it to a provider via override,
// OR we use a FutureProvider.
// Given main.dart does 'ensureInitialized', we can just expect it to be ready or wait for it.
// To keep it simple and synchronous where possible after init,
// let's define a provider that throws if not overridden, or use a FutureProvider.
// However, waiting for FutureProvider in MaterialApp can be tricky without a loading screen.
// A common pattern is to await SP in main() and pass it to the provider scope.

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Shared Preferences not initialized');
});

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeNotifier(prefs);
});

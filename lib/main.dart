import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vnote2/core/enums/pref_keys.dart';
import 'package:vnote2/features/notes/presentation/screens/home_screen.dart';
import 'package:vnote2/features/notes/presentation/screens/note_editor_screen.dart';
import 'package:vnote2/features/notes/services/home_widget_navigation.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const CalmindApp(),
    ),
  );
}

class CalmindApp extends ConsumerStatefulWidget {
  const CalmindApp({super.key});

  @override
  ConsumerState<CalmindApp> createState() => _CalmindAppState();
}

class _CalmindAppState extends ConsumerState<CalmindApp>
    with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  late final WidgetNavigationService _widgetNavService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _widgetNavService = WidgetNavigationService(navigatorKey);
    _startUp();
  }

  void _startUp() async {
    // open widget note
    if (await _widgetNavService.checkAndOpenWidgetNavigation()) return;

    // open last screen
    final prefs = await SharedPreferences.getInstance();
    final lastScreen = prefs.getString(LastScreenKeys.screen);

    if (lastScreen == LastScreenKeys.note) {
      final noteId = prefs.getString(LastScreenKeys.noteId);
      if (noteId != null) {
        _replace(NoteEditorScreen(noteId: noteId));
        return;
      }
    }

    // default
    _replace(const HomeScreen());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed &&
        await _widgetNavService.checkAndOpenWidgetNavigation())
      return;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _replace(Widget screen) {
    Navigator.of(navigatorKey.currentContext!).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => screen),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Calmind',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: FlutterQuillLocalizations.localizationsDelegates,
      supportedLocales: FlutterQuillLocalizations.supportedLocales,
      themeMode: themeState.themeMode,
      theme: AppTheme.lightTheme(themeState.accentColor),
      darkTheme: AppTheme.darkTheme(themeState.accentColor),
      home: const Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.black,
        body: Center(),
      ),
    );
  }
}

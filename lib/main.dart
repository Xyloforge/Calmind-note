import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vnote2/features/notes/presentation/screens/note_editor_screen.dart';
import 'package:vnote2/features/notes/presentation/screens/widget_config_screen.dart';
import 'package:vnote2/features/notes/services/home_widget_navigation.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/notes/presentation/screens/home_screen.dart';

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
    _widgetNavService.initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // When app resumes, check for pending intents
    if (state == AppLifecycleState.resumed) {
      _widgetNavService.checkForPendingIntent();
    }
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
      home: const HomeScreen(),
    );
  }
}

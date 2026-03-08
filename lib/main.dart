import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'core/database/database_provider.dart';
import 'core/database/database.dart';
import 'core/providers/app_providers.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/lock_screen.dart';
import 'features/groups/presentation/home_screen.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: FravaerApp()));
}

class FravaerApp extends ConsumerWidget {
  const FravaerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Fraværsverktøy',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      home: const AppShell(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// AppShell håndterer biometrisk lås, onboarding og opprettelse av lærer.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> with WidgetsBindingObserver {
  bool _authenticated = false;
  bool _onboardingDone = false;
  bool _initialized = false;
  DateTime? _lastPause;

  static const _onboardingKey = 'onboarding_done';
  static const _laererIdKey = 'laerer_id';
  static const _inactivityTimeout = Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _init();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _lastPause = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      if (_lastPause != null &&
          DateTime.now().difference(_lastPause!) > _inactivityTimeout) {
        setState(() => _authenticated = false);
      }
    }
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool(_onboardingKey) ?? false;

    var laererId = prefs.getString(_laererIdKey);
    final db = ref.read(databaseProvider);

    if (laererId == null) {
      laererId = const Uuid().v4();
      await prefs.setString(_laererIdKey, laererId);
    }

    // Sørg for at læreren finnes i databasen
    final existing = await (db.select(db.laerere)
          ..where((l) => l.id.equals(laererId!)))
        .getSingleOrNull();

    if (existing == null) {
      await db.into(db.laerere).insert(LaerereCompanion.insert(
            id: laererId!,
            navn: 'Min bruker',
          ));
    }

    ref.read(activeLaererIdProvider.notifier).state = laererId;

    if (mounted) {
      setState(() {
        _onboardingDone = onboardingDone;
        _initialized = true;
      });
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
    setState(() => _onboardingDone = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_authenticated) {
      return LockScreen(
        onAuthenticated: () => setState(() => _authenticated = true),
      );
    }

    if (!_onboardingDone) {
      return OnboardingScreen(onComplete: _completeOnboarding);
    }

    return const HomeScreen();
  }
}

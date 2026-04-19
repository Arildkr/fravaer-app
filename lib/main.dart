import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'firebase_options.dart';

import 'package:fravaer_app/l10n/app_localizations.dart';

import 'core/database/database_provider.dart';
import 'core/database/database.dart';
import 'core/providers/app_providers.dart';
import 'core/utils/widget_updater.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/lock_screen.dart';
import 'features/groups/presentation/home_screen.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/splash/presentation/splash_screen.dart';
import 'features/subscription/data/subscription_service.dart';
import 'features/subscription/presentation/paywall_screen.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: FravaerApp()));
}

class FravaerApp extends ConsumerWidget {
  const FravaerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Alle med',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      home: const AppShell(),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: ref.watch(localeProvider),
      supportedLocales: const [
        Locale('en'),
        Locale('nb'),
        Locale('sv'),
        Locale('da'),
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) return const Locale('nb');
        for (final supported in supportedLocales) {
          if (supported.languageCode == locale.languageCode) return supported;
        }
        return const Locale('nb');
      },
    );
  }
}

/// AppShell håndterer abonnement, biometrisk lås, onboarding og opprettelse av lærer.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> with WidgetsBindingObserver {
  bool _authenticated = false;
  bool _onboardingDone = false;
  bool _initialized = false;
  bool _biometricLockEnabled = false;
  DateTime? _lastPause;

  late final SubscriptionService _subscriptionService;
  SubscriptionStatus _subscriptionStatus = SubscriptionStatus.loading;

  static const _onboardingKey = 'onboarding_done';
  static const _laererIdKey = 'laerer_id';
  static const _inactivityTimeout = Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _subscriptionService = SubscriptionService();
    _subscriptionService.status.addListener(_onSubscriptionChange);
    _subscriptionService.initialize();
  }

  void _onSubscriptionChange() {
    if (mounted) {
      setState(() {
        _subscriptionStatus = _subscriptionService.status.value;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _subscriptionService.status.removeListener(_onSubscriptionChange);
    _subscriptionService.dispose();
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

  static const _localeKey = 'locale_override';

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool(_onboardingKey) ?? false;

    // Last lagret språkvalg
    final savedLocale = prefs.getString(_localeKey);
    if (savedLocale != null) {
      ref.read(localeProvider.notifier).state = Locale(savedLocale);
    }

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
            id: laererId,
            navn: 'Min bruker',
          ));
    }

    ref.read(activeLaererIdProvider.notifier).state = laererId;
    ref.read(subscriptionServiceProvider.notifier).state = _subscriptionService;

    // Skriv grupper til SharedPreferences så WidgetConfigActivity kan lese dem
    final alleGrupper = await (db.select(db.grupper)
          ..where((g) => g.laererId.equals(laererId!)))
        .get();
    final aktiveGrupper = alleGrupper.where((g) => !g.arkivert).toList();
    WidgetUpdater.saveGroups(
      aktiveGrupper.map((g) => (id: g.id, name: g.navn)).toList(),
    ).catchError((e) {
      debugPrint('WidgetUpdater.saveGroups feil: $e');
    });

    // Les biometrisk lås-innstilling
    final laerer = await (db.select(db.laerere)
          ..where((l) => l.id.equals(laererId!)))
        .getSingleOrNull();

    if (mounted) {
      setState(() {
        _onboardingDone = onboardingDone;
        _biometricLockEnabled = laerer?.biometriskLaasAktiv ?? false;
        _initialized = true;
      });
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
    if (mounted) setState(() => _onboardingDone = true);
  }

  @override
  Widget build(BuildContext context) {
    // Vent på krypteringsnøkkel før noe annet
    final keyAsync = ref.watch(encryptionKeyProvider);

    return keyAsync.when(
      loading: () => const SplashScreen(),
      error: (error, _) => Scaffold(
        body: Center(child: Text('${AppLocalizations.of(context)?.startupError ?? 'Error:'} $error')),
      ),
      data: (_) => _buildApp(),
    );
  }

  Widget _buildApp() {
    // Start initialisering etter at nøkkelen er klar
    if (!_initialized) {
      SchedulerBinding.instance.addPostFrameCallback((_) => _init());
      return const SplashScreen();
    }

    // Sjekk abonnementsstatus
    if (_subscriptionStatus == SubscriptionStatus.loading) {
      return const SplashScreen();
    }

    // Appen er klar — fjern native splash
    FlutterNativeSplash.remove();

    if (_subscriptionStatus == SubscriptionStatus.expired) {
      return PaywallScreen(
        subscriptionService: _subscriptionService,
        onSubscribed: () =>
            setState(() => _subscriptionStatus = SubscriptionStatus.active),
      );
    }

    // Reaktiv: oppdateres umiddelbart når innstillingen endres i Innstillinger.
    final biometricEnabled =
        ref.watch(biometricLockEnabledProvider).valueOrNull ??
            _biometricLockEnabled;

    // Re-lås appen umiddelbart dersom biometri slås PÅ mens brukeren er inne.
    ref.listen<AsyncValue<bool>>(biometricLockEnabledProvider, (prev, next) {
      final wasEnabled = prev?.valueOrNull ?? false;
      final isEnabled = next.valueOrNull ?? false;
      if (!wasEnabled && isEnabled && _authenticated) {
        setState(() => _authenticated = false);
      }
    });

    if (!_authenticated && biometricEnabled) {
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

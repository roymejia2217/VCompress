import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:vcompressor/core/constants/app_constants.dart';
import 'package:vcompressor/core/error/app_error.dart';
import 'package:vcompressor/providers/settings_provider.dart';
import 'package:vcompressor/providers/hardware_provider.dart';
import 'package:vcompressor/router/app_router.dart';

import 'package:vcompressor/ui/theme/app_theme.dart' as app_theme;
import 'package:vcompressor/utils/cache_service.dart';
import 'package:vcompressor/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inicializar servicio de cache
    await CacheService.instance.init();

    runApp(const ProviderScope(child: VCompressorApp()));
  } catch (e) {
    final appError = AppError.fromException(e, StackTrace.current);
    debugPrint('Error inicializando aplicación: ${appError.message}');

    // Aún ejecutar la aplicación con configuración básica
    runApp(const ProviderScope(child: VCompressorApp()));
  }
}

class VCompressorApp extends ConsumerWidget {
  const VCompressorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    // Inicializa providers críticos al arranque para evitar condiciones de carrera
    ref.watch(hardwareCapabilitiesProvider);
    ref.watch(saveDirProvider);
    ref.watch(themeModeProvider);
    ref.watch(localeProvider);

    final lightTheme = app_theme.lightTheme;
    final darkTheme = app_theme.darkTheme;

    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es'), Locale('en'), Locale('fr'), Locale('it')],
      locale: locale,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash/splash_screen.dart';
import 'core/repository/pennypal_repository.dart';
import 'core/theme/theme_service.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/language_service.dart';
import 'core/notifications/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('[Firebase] Initialization: $e');
  }
  await PennyPalRepository.instance.initialize();
  await ThemeService.instance.init();
  await LanguageService.instance.init();
  await NotificationService.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        ThemeService.instance,
        LanguageService.instance,
      ]),
      builder: (context, _) {
        return MaterialApp(
          title: 'PennyPal',
          debugShowCheckedModeBanner: false,
          themeMode: ThemeService.instance.themeMode,
          theme: AppTheme.lightTheme(LanguageService.instance.currentCode),
          darkTheme: AppTheme.darkTheme(LanguageService.instance.currentCode),
          locale: LanguageService.instance.currentLocale,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            _FallbackMaterialLocalizationsDelegate(),
            _FallbackCupertinoLocalizationsDelegate(),
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('ur'),
            Locale('ar'),
            Locale('es'),
            Locale('fr'),
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            if (locale != null) {
              for (final supported in supportedLocales) {
                if (supported.languageCode == locale.languageCode) {
                  return supported;
                }
              }
            }
            return supportedLocales.first;
          },
          home: const SplashScreen(),
        );
      },
    );
  }
}

/// Fallback delegates ensuring MaterialApp never throws "No MaterialLocalizations found"
/// even on platforms or custom environments where a specific language translation is missing.
class _FallbackMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _FallbackMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) async =>
      const DefaultMaterialLocalizations();

  @override
  bool shouldReload(_FallbackMaterialLocalizationsDelegate old) => false;
}

class _FallbackCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const _FallbackCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) async =>
      const DefaultCupertinoLocalizations();

  @override
  bool shouldReload(_FallbackCupertinoLocalizationsDelegate old) => false;
}
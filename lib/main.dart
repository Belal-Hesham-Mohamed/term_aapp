import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/main_navigation.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setup();
  runApp(const TermApp());
}

class TermApp extends StatelessWidget {
  const TermApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TERM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      locale: const Locale('ar'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const MainNavigation(),
    );
  }
}

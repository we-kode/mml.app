import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/mml_app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mml_app/lib_color_schemes.g.dart';
import 'package:mml_app/services/messenger.dart';
import 'package:mml_app/services/router.dart';

/// Application for My Media Lib.
class MMLApp extends StatelessWidget {
  /// Initializes the instance.
  const MMLApp({super.key});

  /// Creates the app with the necessary configurations.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      onGenerateTitle: (BuildContext context) =>
          AppLocalizations.of(context)!.appTitle,

      // Specify key for the snackbar at the bottom of the app.
      scaffoldMessengerKey: MessengerService.getInstance().snackbarKey,

      // Configure theme data.
      theme: ThemeData(
        colorScheme: lightColorScheme,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: darkColorScheme,
        useMaterial3: true,
      ),

      themeMode: ThemeMode.system,

      // Configure the main navigator of the app.
      navigatorKey: RouterService.getInstance().navigatorKey,
      initialRoute: RouterService.getInstance().initialRoute,
      routes: RouterService.getInstance().routes,

      // Configure the localizations of the app.
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('de', ''),
        Locale('ru', ''),
      ],
    );
  }
}

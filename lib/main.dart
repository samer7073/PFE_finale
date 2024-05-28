// ignore_for_file: prefer_const_literals_to_create_immutables

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/screens/homeNavigate_page.dart';
import 'package:flutter_application_stage_project/screens/home_page.dart';
import 'package:flutter_application_stage_project/screens/login_page.dart';
import 'package:flutter_application_stage_project/screens/onboarding_screen.dart';
import 'package:flutter_application_stage_project/providers/langue_provider.dart';
import 'package:flutter_application_stage_project/providers/theme_provider.dart';
import 'package:flutter_application_stage_project/core/constants/design/theme.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String onboardingCompletedKey = 'onboardingCompleted';

Future<bool> isFirstTimeLaunch() async {
  final prefs = await SharedPreferences.getInstance();
  final onboardingCompleted = prefs.getBool(onboardingCompletedKey) ?? false;
  return !onboardingCompleted;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final showOnboarding = await isFirstTimeLaunch();
  final prefs = await SharedPreferences.getInstance();
  String token = prefs.getString('token') ?? "";
  log('Token retrieved: $token'); // Log the token value
  log("token est null" + token.isEmpty.toString());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) =>
                ThemeProvider()), // Assuming ThemeProvider manages theme
        ChangeNotifierProvider(
            create: (_) =>
                LangueProvider()), // Assuming LangueProvider manages language
      ],
      child: MyApp(
        showOnboarding: showOnboarding,
        token: token,
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final bool showOnboarding;
  final String token;

  const MyApp({Key? key, required this.showOnboarding, required this.token})
      : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final provider =
        Provider.of<ThemeProvider>(context); // Access ThemeProvider
    final providerLangue =
        Provider.of<LangueProvider>(context); // Access LangueProvider

    log('Building MaterialApp with token: ${widget.token}'); // Log the token before using it

    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) {
          if (widget.showOnboarding) {
            return OnBoardingScreen();
          } else if (widget.token.isNotEmpty) {
            return HomeNavigate(id_page: 0);
          } else {
            return LoginPage();
          }
        },
        '/login': (context) => LoginPage(), // Assuming LoginPage exists
        '/home': (context) => HomePage(),
        '/homeNavigate': (context) => HomeNavigate(id_page: 0),
      },
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: providerLangue.locale, // Set locale based on LangueProvider
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
        Locale('ar'),
      ],
      debugShowCheckedModeBanner: false,
      theme: provider.isDarkMode
          ? MyThemes.darkTheme
          : MyThemes.lightTheme, // Apply theme based on ThemeProvider
      themeMode: provider.themeMode,
    );
  }
}

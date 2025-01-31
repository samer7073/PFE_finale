import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/providers/NotificationProvider.dart';
import 'package:flutter_application_stage_project/providers/providerstagechange.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_stage_project/core/constants/design/theme.dart';
import 'package:flutter_application_stage_project/providers/langue_provider.dart';
import 'package:flutter_application_stage_project/providers/theme_provider.dart';
import 'package:flutter_application_stage_project/screens/homeNavigate_page.dart';
import 'package:flutter_application_stage_project/screens/home_page.dart';
import 'package:flutter_application_stage_project/screens/login_page.dart';
import 'package:flutter_application_stage_project/screens/onboarding_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

const String onboardingCompletedKey = 'onboardingCompleted';

// Fonction pour les messages en arrière-plan
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log("Message reçu en arrière-plan : ${message.notification?.title}");
}

Future<bool> isFirstTimeLaunch() async {
  final prefs = await SharedPreferences.getInstance();
  final onboardingCompleted = prefs.getBool(onboardingCompletedKey) ?? false;
  return !onboardingCompleted;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Gérer les messages en arrière-plan
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Souscrire à un topic (exemple : "test")
  await FirebaseMessaging.instance.subscribeToTopic("test");

  // Configurer les overrides HTTP pour ignorer SSL en développement
  HttpOverrides.global = MyHttpOverrides();

  final showOnboarding = await isFirstTimeLaunch();
  final prefs = await SharedPreferences.getInstance();
  String token = prefs.getString('token') ?? "";

  log('Token récupéré: $token'); // Log le token stocké
  log("Token est null: ${token.isEmpty}");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LangueProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => stagechangeprovider()),
      ],
      child: MyApp(showOnboarding: showOnboarding, token: token),
    ),
  );
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final langueProvider = Provider.of<LangueProvider>(context);

    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) {
          if (widget.showOnboarding) {
            return const OnBoardingScreen();
          } else if (widget.token.isNotEmpty) {
            return HomeNavigate(id_page: 0);
          } else {
            return const LoginPage();
          }
        },
        '/login': (context) => const LoginPage(),
        '/home': (context) => HomePage(),
        '/homeNavigate': (context) => HomeNavigate(id_page: 0),
      },
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: langueProvider.locale,
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
        Locale('ar'),
      ],
      debugShowCheckedModeBanner: false,
      theme:
          themeProvider.isDarkMode ? MyThemes.darkTheme : MyThemes.lightTheme,
      themeMode: themeProvider.themeMode,
    );
  }
}

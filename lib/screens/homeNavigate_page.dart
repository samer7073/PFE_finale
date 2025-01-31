import 'dart:developer';

import 'package:flutter_application_stage_project/screens/Deal/Deal_page.dart';
import 'package:flutter_application_stage_project/screens/bookings/bookings_page.dart';
import 'package:flutter_application_stage_project/screens/contactPage.dart';
import 'package:flutter_application_stage_project/screens/leads/leads_page.dart';
import 'package:flutter_application_stage_project/services/fcm/FirebaseMessagingService.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/screens/project/Project_page.dart';
import 'package:flutter_application_stage_project/screens/home_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/NotificationProvider.dart';
import '../services/MercureNotificationService.dart';
import 'Activity/home_view.dart';

class HomeNavigate extends StatefulWidget {
  final int id_page;
  const HomeNavigate({super.key, required this.id_page});

  @override
  State<HomeNavigate> createState() => _HomeNavigateState();
}

class _HomeNavigateState extends State<HomeNavigate> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Ajouter l'observateur du cycle de vie

    _setupFCM();

    // Vérification de l'état des notifications à l'initialisation
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    if (notificationProvider.notification) {
      MercureNotificationService().initialize(); // Initialiser Mercure si les notifications sont activées
    }

    // Si l'ID de la page est différent de 0, on met à jour la page sélectionnée
    if (widget.id_page != 0) {
      setState(() {
        selectedPage = widget.id_page;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Retirer l'observateur lors de la destruction du widget
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Toujours arrêter Mercure lorsque l'application entre en arrière-plan
    if (state == AppLifecycleState.paused) {
      MercureNotificationService().stop();  // Arrêter Mercure en arrière-plan
    } else if (state == AppLifecycleState.resumed) {
      // Lorsque l'application revient au premier plan, réactiver Mercure si les notifications sont activées
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      if (notificationProvider.notification) {
        MercureNotificationService().initialize();  // Réactiver Mercure si les notifications sont activées
      }
    }
  }

  Future<void> _setupFCM() async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('token') ?? "";

    if (authToken.isNotEmpty) {
      await FirebaseMessagingService().initialize(authToken);
    } else {
      log("Token d'authentification non trouvé.");
    }
  }

  int selectedPage = 0;
  final _pageOptions = [
    HomePage(),
    HomeScreen(),
    ContactPage(),
    LeadsPage(),
    DealPage(),
    ProjectPage(),
    ContactPage(),
    BookingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pageOptions[selectedPage],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
                width: 30,
              'assets/Home.png',
              color: Colors.grey,
            ),
            activeIcon: Image.asset(
                width: 30,
              'assets/Home.png',
              color: Colors.blue,
            ),
            label: AppLocalizations.of(context)!.overview,
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
                width: 30,
              'assets/calendar-2.png',
              color: Colors.grey,
            ),
            activeIcon: Image.asset(
                width: 30,
              'assets/calendar-2.png',
              color: Colors.blue,
            ),
            label: AppLocalizations.of(context)!.activities,
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              width: 30,
              'assets/user.png',
              color: Colors.grey,
            ),
            activeIcon: Image.asset(
              width: 30,
              'assets/user.png',
              color: Colors.blue,
            ),
            label: AppLocalizations.of(context)!.contacts,
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              width: 30,
               'assets/lead.png',
              color: Colors.grey,
            ),
            activeIcon: Image.asset(
              width: 30,
               'assets/lead.png',
              color: Colors.blue,
            ),
            label: AppLocalizations.of(context)!.leads,
          ),
        ],
        currentIndex: selectedPage,
        onTap: (index) {
          setState(() {
            selectedPage = index;
          });
        },
      ),
    );
  }
}

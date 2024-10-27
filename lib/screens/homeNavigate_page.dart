// ignore_for_file: prefer_const_constructors

import 'package:flutter_application_stage_project/screens/Deal/Deal_page.dart';
import 'package:flutter_application_stage_project/screens/bookings/bookings_page.dart';
import 'package:flutter_application_stage_project/screens/contactPage.dart';
import 'package:flutter_application_stage_project/screens/leads/leads_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/screens/project/Project_page.dart';
import 'package:flutter_application_stage_project/screens/home_page.dart';
import 'package:provider/provider.dart';
import '../providers/NotificationProvider.dart';
import '../services/MercureNotificationService.dart';
import 'Activity/home_view.dart';

class HomeNavigate extends StatefulWidget {
  final int id_page;
  const HomeNavigate({super.key, required this.id_page});

  @override
  State<HomeNavigate> createState() => _HomeNavigateState();
}

class _HomeNavigateState extends State<HomeNavigate> {
  @override
  void initState() {
    super.initState();

    // Obtenez le fournisseur de notifications
    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);

    // Vérifiez si la notification est activée
    if (notificationProvider.notification == true) {
      MercureNotificationService().initialize();
    }

    if (widget.id_page != 0) {
      setState(() {
        selectedPage = widget.id_page;
      });
    }
  }

  void mercure() async {
    MercureNotificationService().initialize();
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
            label: "Leads",
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

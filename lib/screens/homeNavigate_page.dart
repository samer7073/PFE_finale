// ignore_for_file: prefer_const_constructors

import 'dart:developer';
import 'package:flutter_application_stage_project/screens/Deal/Deal_page.dart';
import 'package:flutter_application_stage_project/screens/bookings/bookings_page.dart';
import 'package:flutter_application_stage_project/screens/contactPage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/screens/project/Project_page.dart';
import 'package:flutter_application_stage_project/screens/home_page.dart';
import 'package:flutter_application_stage_project/screens/ticket/ticket_page.dart';
import 'package:provider/provider.dart';
import '../providers/NotificationProvider.dart';
import '../services/MercureNotificationService.dart';
import 'Activity/home_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
    TicketPage(),
    DealPage(), // KanbanPage1(),
    ProjectPage(),
    ContactPage(),
    BookingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pageOptions[selectedPage],
      bottomNavigationBar: BottomNavigationBar(
        unselectedLabelStyle: TextStyle(color: Colors.grey),
        unselectedIconTheme: IconThemeData(color: Colors.grey),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart_outline_rounded),
            activeIcon: Icon(Icons.pie_chart),
            label: AppLocalizations.of(context)!.overview,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.calendar_today_outlined,
              color: Colors.grey,
            ),
            activeIcon: Icon(Icons.calendar_today_rounded),
            label: AppLocalizations.of(context)!.activities,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons
                .confirmation_number_outlined), // Utiliser ticketSimple pour l'icône outline
            activeIcon: Icon(Icons
                .confirmation_number_rounded), // Utiliser ticket pour l'icône filled
            label: AppLocalizations.of(context)!.tickets,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.handshake_outlined),
            activeIcon: Icon(Icons.handshake_rounded),
            label: AppLocalizations.of(context)!.deals,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note_outlined),
            activeIcon: Icon(Icons.event_note_rounded),
            label: AppLocalizations.of(context)!.projects,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_2_outlined),
            activeIcon: Icon(Icons.person_2_rounded),
            label: AppLocalizations.of(context)!.contacts,
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.tree),
            activeIcon: FaIcon(FontAwesomeIcons.tree, color: Colors.blue),
            label: "Bookings",
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

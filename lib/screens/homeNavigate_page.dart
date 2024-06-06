// ignore_for_file: prefer_const_constructors
import 'dart:developer';

import 'package:flutter_application_stage_project/screens/Deal/Deal_page.dart';

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
    log("hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh");

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
    ContactPage()
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _pageOptions[selectedPage],
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              // backgroundColor: Color.fromARGB(255, 246, 214, 252),
              icon: Icon(
                Icons.pie_chart_outline_rounded,
                //color: selectedIndex == 0 ? Colors.purple : Colors.black,
              ),
              activeIcon: Icon(
                Icons.pie_chart,
                //color: Colors.purple,
              ),
              label: "Overview",

              // TextStyle for unselected
              // TextStyle(color: selectedIndex == 0 ? Colors.purple : Colors.black),
            ),
            BottomNavigationBarItem(
              //backgroundColor: Color.fromARGB(255, 246, 214, 252),
              icon: Icon(
                Icons.calendar_today_outlined,
                //color: selectedIndex == 1 ? Colors.purple : Colors.black,
              ),
              activeIcon: Icon(
                Icons.calendar_today_rounded,
                //color: Colors.purple,
              ),
              label: AppLocalizations.of(context).activities,
            ),
            BottomNavigationBarItem(
              // backgroundColor: Color.fromARGB(255, 246, 214, 252),
              icon: Icon(
                Icons.airplane_ticket_outlined,
                //color: selectedIndex == 2 ? Colors.purple : Colors.black,
              ),
              activeIcon: Icon(
                Icons.airplane_ticket_rounded,
                // color: Colors.purple,
              ),
              label: AppLocalizations.of(context).tickets,
            ),
            BottomNavigationBarItem(
              //backgroundColor: Color.fromARGB(255, 246, 214, 252),
              icon: Icon(
                Icons.handshake_outlined,
                // color: selectedIndex == 3 ? Colors.purple : Colors.black,
              ),
              activeIcon: Icon(
                Icons.handshake_rounded,
                // color: Colors.purple,
              ),
              label: AppLocalizations.of(context).deals,
            ),
            BottomNavigationBarItem(
              //backgroundColor: Color.fromARGB(255, 246, 214, 252),
              icon: Icon(
                Icons.event_note_outlined,
                // color: selectedIndex == 3 ? Colors.purple : Colors.black,
              ),
              activeIcon: Icon(
                Icons.event_note_rounded,
                // color: Colors.purple,
              ),
              label: "Projects",
            ),
            BottomNavigationBarItem(
              //backgroundColor: Color.fromARGB(255, 246, 214, 252),
              icon: Icon(
                Icons.person_2_outlined,
                // color: selectedIndex == 3 ? Colors.purple : Colors.black,
              ),
              activeIcon: Icon(
                Icons.person_2_rounded,
                // color: Colors.purple,
              ),
              label: "Contacts",
            ),
          ],

          currentIndex: selectedPage,
          //backgroundColor: Colors.white,
          onTap: (index) {
            setState(() {
              selectedPage = index;
            });
          },
        ));
  }
}

// ignore_for_file: prefer_const_constructors


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
      unselectedLabelStyle: TextStyle(color: Colors.grey, fontSize: 10), // Taille plus petite pour les labels non sélectionnés
      selectedLabelStyle: TextStyle(color: Colors.blue, fontSize: 10), // Taille plus petite pour les labels sélectionnés
      unselectedIconTheme: IconThemeData(color: Colors.grey),
      showSelectedLabels: true, // Afficher les labels sélectionnés
      showUnselectedLabels: true, // Afficher les labels non sélectionnés
      selectedFontSize: 5, // Taille du texte pour les labels sélectionnés
      unselectedFontSize: 8, // Taille du texte pour les labels non sélectionnés
      enableFeedback: true,
      items: [
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/Home.png',
            color: Colors.grey,
          ),
          activeIcon: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(
              'assets/Home.png',
              color: Colors.blue,
            ),
          ),
          label: AppLocalizations.of(context)!.overview,
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/calendar-2.png',
            color: Colors.grey,
          ),
          activeIcon: Image.asset(
            'assets/calendar-2.png',
            color: Colors.blue,
          ),
          label: AppLocalizations.of(context)!.activities,
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/ticket-2.png',
            color: Colors.grey,
          ),
          activeIcon: Image.asset(
            'assets/ticket-2.png',
            color: Colors.blue,
          ),
          label: AppLocalizations.of(context)!.tickets,
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/Activity.png',
            color: Colors.grey,
          ),
          activeIcon: Image.asset(
            'assets/Activity.png',
            color: Colors.blue,
          ),
          label: AppLocalizations.of(context)!.deals,
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/document.png',
            color: Colors.grey,
          ),
          activeIcon: Image.asset(
            'assets/document.png',
            color: Colors.blue,
          ),
          label: AppLocalizations.of(context)!.projects,
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/user.png',
            color: Colors.grey,
          ),
          activeIcon: Image.asset(
            'assets/user.png',
            color: Colors.blue,
          ),
          label: AppLocalizations.of(context)!.contacts,
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/booking (1).png',
            color: Colors.grey,
          ),
          activeIcon: Image.asset(
            'assets/booking (1).png',
           
            color: Colors.blue,
          ),
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

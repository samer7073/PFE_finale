import 'dart:async';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/models/profil/Profile.dart';
import 'package:flutter_application_stage_project/screens/Deal/Deal_page.dart';
import 'package:flutter_application_stage_project/screens/NotficationPage.dart';
import 'package:flutter_application_stage_project/screens/bookings/bookings_page.dart';
import 'package:flutter_application_stage_project/screens/notes/notes_page.dart';
import 'package:flutter_application_stage_project/screens/project/Project_page.dart';
import 'package:flutter_application_stage_project/screens/taskKpi_page.dart';
import 'package:flutter_application_stage_project/screens/ticket/ticket_page.dart';
import 'package:flutter_application_stage_project/services/ApiGetProfile.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_stage_project/screens/settings/settings.dart';
import 'package:flutter_application_stage_project/providers/theme_provider.dart';
import '../core/constants/shared/config.dart';
import '../services/sharedPreference.dart';
import 'KpiFamilyPage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late ThemeProvider themeProvider;
  late TabController _tabController;
  String? storedToken;
  String? image;
  String? storedUuid;
  String? storedJwt;

  Future<String>? imageUrlFuture;
  String? cachedImageUrl;

  @override
  void initState() {
    super.initState();
    imageUrlFuture = _fetchImageUrl();
    themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    _tabController = TabController(length: 4, vsync: this);
    log("Init state activated: isDarkMode = ${themeProvider.isDarkMode}");

    _loadStoredData();
    _loadCachedImage();
    fetchProfile(); // Fetch profile data
  }

  Future<String> _fetchImageUrl() async {
    String url = await Config.getApiUrl("urlImage");
    log("Fetched image URL: $url");
    return url;
  }

  Profile? _profile;

  Future<void> fetchProfile() async {
  try {
    log("Fetching profile...");
    Profile profileResponse = await ApiProfil.getProfil();

    setState(() {
      _profile = profileResponse;
      image = _profile?.avatar.label ?? ""; // Assign the new image, ensure it's not null
    });

    // Sauvegarder la date formatée dans SharedPreferences
    await SharedPrefernce.saveToken(
        'date_formate', _profile!.location.date_format);

    // Récupérer la date formatée de SharedPreferences
    String? dateFormate = await SharedPrefernce.getToken('date_formate');
    log("date_formate: $dateFormate");

    // Vérifier si l'image mise en cache est différente de la nouvelle
    if (image != null && image != cachedImageUrl) {
      await SharedPrefernce.saveToken('cachedImageUrl', image!);
      cachedImageUrl = image; // Mettre à jour l'image mise en cache
    }
  } catch (e) {
    log('Failed to fetch Profile: $e');
  }
}


  void _loadCachedImage() async {
    cachedImageUrl = await SharedPrefernce.getToken('cachedImageUrl');
    log("Loaded cached image URL: $cachedImageUrl");
    setState(() {
      image = cachedImageUrl; // Set the cached image on load
    });
  }

  void _loadStoredData() async {
    String? token = await SharedPrefernce.getToken('token');
    String? uuid = await SharedPrefernce.getToken('uuid');
    String? jwt = await SharedPrefernce.getToken('jwt');
    setState(() {
      storedToken = token;
      storedUuid = uuid;
      storedJwt = jwt;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void goToSettingsPage() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => Settings()));
  }

  void goToNotif() {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => NotificationPage()));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: imageUrlFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: Colors.blue));
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading image URL'));
        }

        String imageUrl = snapshot.data ?? "";

        log("Image URL: $imageUrl and User Image: $image");

        return Scaffold(
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 79, 167, 239),
                  ),
                  margin: EdgeInsets.zero,
                  padding: EdgeInsets.zero,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      (image != null && image!.isNotEmpty)
                          ? (image!.length == 1)
                              ? CircleAvatar(
                                  child: Text(
                                    image!,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 14),
                                  ),
                                  backgroundColor: Colors.blue,
                                  radius: 40, // Adjust the radius here
                                )
                              : CircleAvatar(
                                  backgroundImage: CachedNetworkImageProvider(
                                      "$imageUrl$image"),
                                  radius: 40, // Adjust the radius here
                                )
                          : CircularProgressIndicator(color: Colors.blue),
                      SizedBox(height: 8),
                      if (_profile != null) ...[
                        Text(
                          _profile!.name.label,
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(height: 8),
                        Text(
                          _profile!.email.label,
                          style: TextStyle(color: Colors.white),
                        ),
                      ] else
                        Text(
                          'Chargement du profil...', // Placeholder text
                          style: TextStyle(color: Colors.white),
                        ),
                    ],
                  ),
                ),
                /*
                ListTile(
                  leading: Image.asset(
                    width: 25,
                    'assets/user.png',
                    color: const Color.fromARGB(255, 98, 97, 97),
                  ),
                  title: Text(AppLocalizations.of(context)!.contacts),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => ContactPage()));
                  },
                ),
                */
                ListTile(
                  leading: Image.asset(
                    width: 25,
                    'assets/booking (1).png',
                    color: const Color.fromARGB(255, 98, 97, 97),
                  ),
                  title: Text("${AppLocalizations.of(context)!.bookings}"),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => BookingsPage()));
                  },
                ),
                ListTile(
                  leading: Image.asset(
                    width: 25,
                    'assets/document.png',
                    color: const Color.fromARGB(255, 98, 97, 97),
                  ),
                  title: Text("${AppLocalizations.of(context)!.projects}"),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => ProjectPage()));
                  },
                ),
                /*
                ListTile(
                  leading: Image.asset(
                    width: 25,
                    'assets/lead.png',
                    color: const Color.fromARGB(255, 98, 97, 97),
                  ),
                  title: Text("Leads"),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => LeadsPage()));
                  },
                ),
                */
                /*
                ListTile(
                  leading: Icon(
                    Icons.edit_document,
                    size: 25,
                    color: const Color.fromARGB(255, 98, 97, 97),
                  ),
                  title: Text("${AppLocalizations.of(context)!.notes}"),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => NotesPage()));
                  },
                ),
                */
                ListTile(
                  leading: Image.asset(
                    'assets/Activity.png',
                    color: const Color.fromARGB(255, 98, 97, 97),
                  ),
                  title: Text(AppLocalizations.of(context)!.deals),
                  onTap: () {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (_) => DealPage()));
                  },
                ),
                ListTile(
                  leading: Image.asset(
                    'assets/ticket-2.png',
                    color: const Color.fromARGB(255, 98, 97, 97),
                  ),
                  title: Text(
                    AppLocalizations.of(context)!.tickets,
                  ),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => TicketPage()));
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.settings,
                    color: const Color.fromARGB(255, 98, 97, 97),
                  ),
                  title: Text("${AppLocalizations.of(context)!.settings}"),
                  onTap: () {
                    goToSettingsPage();
                  },
                ),

                // Add more ListTile here for each additional page
              ],
            ),
          ),
          appBar: AppBar(
            centerTitle: true,
            title: Text('Comunik Sphere'),
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: AppLocalizations.of(context)!.activities),
                Tab(text: AppLocalizations.of(context)!.ticket),
                Tab(text: AppLocalizations.of(context)!.deal),
                Tab(text: AppLocalizations.of(context)!.project),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none_sharp, size: 30),
                onPressed: goToNotif,
              ),
            ],
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              TaskKpiPage(),
              KpiFamilyPage(family_id: "6"),
              KpiFamilyPage(family_id: "3"),
              KpiFamilyPage(family_id: "7"),
            ],
          ),
        );
      },
    );
  }
}

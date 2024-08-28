import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/models/profil/Profile.dart';
import 'package:flutter_application_stage_project/screens/NotficationPage.dart';

import 'package:flutter_application_stage_project/screens/taskKpi_page.dart';

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
  int selectedIndex = 0;

  String? storedToken;
  String? image;
  String? storedUuid;
  String? storedJwt;

  Future<String>? imageUrlFuture;

  @override
  void initState() {
    super.initState();
    themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    _tabController = TabController(length: 4, vsync: this);
    log("Init state activated: isDarkMode = ${themeProvider.isDarkMode}");
    _loadStoredData();
    fetchProfile();
    imageUrlFuture = Config.getApiUrl("urlImage");
  }

  void _saveString(String key, String value) async {
    await SharedPrefernce.saveToken(key, value);
    _loadStoredData(); // Reload all stored data after saving
  }

  Profile? _profile;

  Future<void> fetchProfile() async {
    try {
      Profile profileResponse = await ApiProfil.getProfil();
      log(profileResponse.toString());

      setState(() {
        loading = false;
        _profile = profileResponse;
      });
      // _saveString("uuid", _profile!.uuid);
    } catch (e) {
      print('Failed to fetch Profile: $e');
      setState(() {
        loading = false;
      });
    }
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

  bool loading = true;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: imageUrlFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
                                    color: Colors.blue,
                                  ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading image URL'),
          );
        }

        String imageUrl = snapshot.data ?? "";

        return Scaffold(
          appBar: AppBar(
            leading: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: GestureDetector(
                onTap: goToSettingsPage,
                child: _profile != null && _profile!.avatar.label.length == 1
                    ? CircleAvatar(
                        backgroundColor: Colors
                            .blue, // Choisissez une couleur de fond appropriée
                        child: Text(
                          _profile!.avatar.label,
                          style: TextStyle(
                              color: Colors
                                  .white), // Choisissez une couleur de texte appropriée
                        ),
                        radius: 15,
                      )
                    : _profile != null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(
                                "$imageUrl${_profile!.avatar.label}"),
                            radius: 15,
                          )
                        : CircularProgressIndicator(
                                    color: Colors.blue,
                                  ),
              ),
            ),
            centerTitle: true,
            title: Text('Comunik Sphere'),
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  text: AppLocalizations.of(context)!.activities,
                ),
                Tab(text: AppLocalizations.of(context)!.ticket),
                Tab(text: AppLocalizations.of(context)!.deal),
                Tab(text: AppLocalizations.of(context)!.project)
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

import 'dart:async';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
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

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
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
        image = _profile!.avatar.label; // Assign the new image
      });

      // Check if the cached image URL is different from the new one
      if (image != null && image != cachedImageUrl) {
        SharedPrefernce.saveToken('cachedImageUrl', image!);
        cachedImageUrl = image; // Update cached image
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
    Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationPage()));
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
          appBar: AppBar(
            leading: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: GestureDetector(
                onTap: goToSettingsPage,
                child: (image != null && image!.isNotEmpty)
                    ? (image!.length == 1)
                        ? CircleAvatar(
                            child: Text(
                              image!,
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.blue,
                            radius: 15,
                          )
                        : CircleAvatar(
                            backgroundImage: CachedNetworkImageProvider("$imageUrl$image"),
                            radius: 15,
                          )
                    : CircularProgressIndicator(color: Colors.blue),
              ),
            ),
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
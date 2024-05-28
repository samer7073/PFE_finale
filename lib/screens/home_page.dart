// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, sort_child_properties_last

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/models/profil/Profile.dart';

import 'package:flutter_application_stage_project/screens/containerDashbored.dart';
import 'package:flutter_application_stage_project/screens/taskKpi_page.dart';
import 'package:flutter_application_stage_project/services/ApiGetProfile.dart';

import 'package:provider/provider.dart';
import 'package:flutter_application_stage_project/screens/settings/settings.dart';

import 'package:flutter_application_stage_project/providers/theme_provider.dart';

import '../models/profil/Avatar.dart';
import '../models/profil/Email.dart';
import '../models/profil/Name.dart';
import '../models/profil/PhoneNumber.dart';
import '../services/sharedPreference.dart';

import 'package:fl_chart/fl_chart.dart';

import 'KpiFamilyPage.dart';
import 'loading.dart';

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

  final Map<int, String> bottomTitle = {
    0: 'Jan',
    10: 'Feb',
    20: 'Mar',
    30: 'Apr',
    40: 'May',
    50: 'Jun',
    60: 'Jul',
    70: 'Aug',
    80: 'Sep',
    90: 'Oct',
    100: 'Nov',
    110: 'Dec',
  };
  final Map<int, String> leftTitle = {
    0: '0',
    20: '2K',
    40: '4K',
    60: '6K',
    80: '8K',
    100: '10K'
  };
  final List<FlSpot> _data = [
    FlSpot(1, 3),
    FlSpot(3, 5),
    FlSpot(5, 4),
    FlSpot(7, 6),
    FlSpot(9, 8),
  ];
  String? storedToken;
  String? image;
  String? storedUuid;
  @override
  void initState() {
    super.initState();
    themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    _tabController = TabController(length: 4, vsync: this);
    log("Init state activated: isDarkMode = ${themeProvider.isDarkMode}");
    _loadString();
    fetchProfile();
  }

  void _saveString(String key, String value) async {
    await SharedPrefernce.saveToken(key, value);
    _loadString(); // Reload the string after saving
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
      _saveString("uuid", _profile!.uuid);
      print(_profile);
    } catch (e) {
      print('Failed to fetch Profile: $e');
    }
  }

  void _loadString() async {
    String? retrievedString = await SharedPrefernce.getToken('token');
    setState(() {
      storedToken = retrievedString;
    });
  }

  void _loadSUid() async {
    String? retrievedString = await SharedPrefernce.getToken('uuid');
    setState(() {
      storedUuid = retrievedString;
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

  bool loading = true;
  @override
  Widget build(BuildContext context) {
    return loading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
              leading: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: GestureDetector(
                  onTap: goToSettingsPage,
                  child: _profile!.avatar.label.length == 1
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
                      : CircleAvatar(
                          backgroundImage: NetworkImage(
                              "https://spherebackdev.cmk.biz:4543/storage/uploads/${_profile!.avatar.label}"),
                          radius: 15,
                        ),
                ),
              ),
              centerTitle: true,
              title: Text('Comunik Sphere'),
              bottom: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(
                    text: 'Activity',
                  ),
                  Tab(text: 'Ticket'),
                  Tab(text: 'Deal'),
                  Tab(text: 'Project')
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_none_sharp, size: 30),
                  onPressed: goToSettingsPage,
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
  }
}

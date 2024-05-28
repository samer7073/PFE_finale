// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../services/sharedPreference.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late ThemeProvider themeProvider;
  void initState() {
    // TODO: implement initState
    super.initState();
    themeProvider = Provider.of<ThemeProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).profile),
      ),
      body: Center(
        child: Tooltip(
          message: "hellllo world",
          child: Text("helllo"),
          decoration: BoxDecoration(color: Colors.red),
        ),
      ),
    );
  }
}

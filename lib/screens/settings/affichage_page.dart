// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../providers/langue_provider.dart';
import '../../providers/theme_provider.dart';

class Affichage extends StatefulWidget {
  const Affichage({super.key});

  @override
  State<Affichage> createState() => _AffichageState();
}

class _AffichageState extends State<Affichage> {
  late ThemeProvider themeProvider;
  late LangueProvider langueProvider;
  @override
  void initState() {
    // TODO: implement initState
    themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    langueProvider = Provider.of<LangueProvider>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(AppLocalizations.of(context).display),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).theme,
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 10),
            Container(
              height: 50,
              child: customSwitch(
                AppLocalizations.of(context).darkMode,
                themeProvider.isDarkMode,
                (value) {
                  themeProvider.toggleTheme();
                },
                context,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget customSwitch(
  String text,
  bool val,
  onChangeMethod,
  BuildContext context,
) {
  log("la valeur de button switch ==== $val");
  return Padding(
    padding: EdgeInsets.only(top: 0, left: 0, right: 0),
    child: Row(
      children: [
        Text(
          text,
          style: Theme.of(context).textTheme.bodyText1,
        ),
        Spacer(),
        CupertinoSwitch(
          activeColor: Colors.purple,
          value: val,
          onChanged: onChangeMethod,
        ),
      ],
    ),
  );
}

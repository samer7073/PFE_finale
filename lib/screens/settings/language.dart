// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/langue_provider.dart';
import 'changesLanguges_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Language extends StatefulWidget {
  const Language({super.key});

  @override
  State<Language> createState() => _LanguageState();
}

class _LanguageState extends State<Language> {
  late LangueProvider langueProvider;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    langueProvider = Provider.of<LangueProvider>(context, listen: false);
    langueProvider.addListener(_onLocaleChange);
    updateValueSelected(langueProvider.locale);
  }

  @override
  void dispose() {
    langueProvider.removeListener(_onLocaleChange);
    super.dispose();
  }

  void _onLocaleChange() {
    setState(() {
      updateValueSelected(langueProvider.locale);
    });
  }

  void updateValueSelected(Locale locale) {
    setState(() {
      valueSelected = locale.languageCode == 'fr'
          ? "Francais"
          : locale.languageCode == "en"
              ? "English"
              : "العربية";
    });
  }

  String valueSelected = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text(AppLocalizations.of(context).language)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GestureDetector(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context).applicationlanguage,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  Row(
                    children: [
                      Text(valueSelected),
                      SizedBox(
                        width: 10,
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey,
                      )
                    ],
                  )
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangeLangugePage(),
                  ),
                );
              }),
          SizedBox(
            height: 10,
          ),
          Text(AppLocalizations.of(context)
              .selectyourdefaultapplicationlanguage),
        ]),
      ),
    );
  }
}

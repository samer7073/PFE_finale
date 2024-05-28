import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../providers/langue_provider.dart';

class ChangeLangugePage extends StatefulWidget {
  const ChangeLangugePage({super.key});

  @override
  State<ChangeLangugePage> createState() => _ChangeLangugePageState();
}

class _ChangeLangugePageState extends State<ChangeLangugePage> {
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

  String? valueSelected = '';
  String? Country = "Francais";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).choosealanguage),
        centerTitle: true,
      ),
      body: Column(
        children: [
          RadioListTile(
            title: Text("Francais"),
            value: "Francais",
            groupValue: valueSelected,
            onChanged: (value) {
              print(value);
              setState(() {
                valueSelected = value;
                langueProvider.setLocale(Locale('fr'));
              });
            },
          ),
          RadioListTile(
            title: Text("English"),
            value: "English",
            groupValue: valueSelected,
            onChanged: (value) {
              print(value);
              setState(() {
                valueSelected = value;
                langueProvider.setLocale(Locale('en'));
              });
            },
          ),
          RadioListTile(
            title: Text("العربية"),
            value: "العربية",
            groupValue: valueSelected,
            onChanged: (value) {
              print(value);
              setState(() {
                valueSelected = value;
                langueProvider.setLocale(Locale('ar'));
              });
            },
          )
        ],
      ),
    );
  }
}

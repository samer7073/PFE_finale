import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class IndisponibilitePage extends StatefulWidget {
  const IndisponibilitePage({super.key});

  @override
  State<IndisponibilitePage> createState() => _IndisponibilitePageState();
}

class _IndisponibilitePageState extends State<IndisponibilitePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).unavailability),
        centerTitle: true,
      ),
    );
  }
}

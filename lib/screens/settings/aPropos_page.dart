import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Apropos extends StatefulWidget {
  const Apropos({super.key});

  @override
  State<Apropos> createState() => _AproposState();
}

class _AproposState extends State<Apropos> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).about),
        centerTitle: true,
      ),
    );
  }
}

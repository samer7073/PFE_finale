import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ConfidentialitePage extends StatefulWidget {
  const ConfidentialitePage({super.key});

  @override
  State<ConfidentialitePage> createState() => _ConfidentialitePageState();
}

class _ConfidentialitePageState extends State<ConfidentialitePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).confidentiality),
        centerTitle: true,
      ),
    );
  }
}

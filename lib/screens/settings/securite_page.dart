import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SecuritePage extends StatefulWidget {
  const SecuritePage({super.key});

  @override
  State<SecuritePage> createState() => _SecuritePageState();
}

class _SecuritePageState extends State<SecuritePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).securityandpermissions),
        centerTitle: true,
      ),
    );
  }
}

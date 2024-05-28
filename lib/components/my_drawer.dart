// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/components/my_list_tile.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyDrawer extends StatelessWidget {
  void Function()? onProfileTap;
  void Function()? onLogoutTap;
  void Function()? onSettingsTap;
  void Function()? onChatTap;
  MyDrawer(
      {super.key,
      required this.onProfileTap,
      required this.onLogoutTap,
      required this.onSettingsTap,
      required this.onChatTap});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      //shadowColor: Colors.purple,
      //backgroundColor: Colors.purple,
      child: Column(
        children: [
          DrawerHeader(
              child: Icon(
            Icons.person,
            color: Colors.white,
            size: 64,
          )),
          MyListTile(
            icon: Icons.chat_rounded,
            text: "Chat",
            onTap: onChatTap,
          ),
          MyListTile(
            icon: Icons.home,
            text: AppLocalizations.of(context).drawerHome,
            onTap: () => Navigator.pop(context),
          ),
          MyListTile(
            icon: Icons.person,
            text: AppLocalizations.of(context).drawerProfile,
            onTap: onProfileTap,
          ),
          MyListTile(
            icon: Icons.settings,
            text: AppLocalizations.of(context).drawerSettings,
            onTap: onSettingsTap,
          ),
          MyListTile(
            icon: Icons.logout,
            text: AppLocalizations.of(context).drawerLogout,
            onTap: onLogoutTap,
          ),
        ],
      ),
    );
  }
}

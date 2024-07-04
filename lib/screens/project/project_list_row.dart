// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_application_stage_project/core/constants/shared/config.dart';

class ProjectListRow extends StatelessWidget {
  final String reference;
  final String title;
  final String owner;
  final String ownerImage;
  final String createTime;
  final String pipline;

  const ProjectListRow({
    super.key,
    required this.reference,
    required this.title,
    required this.owner,
    required this.ownerImage,
    required this.createTime,
    required this.pipline,
  });

  Future<String> _getImageUrl() async {
    return await Config.getApiUrl("urlImage");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getImageUrl(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error loading image URL');
        }

        String baseUrl = snapshot.data ?? "";

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      AppLocalizations.of(context).ref + " ",
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                    Text(
                      reference,
                      style: Theme.of(context).textTheme.bodyText1,
                    )
                  ],
                ),
                Text(
                  createTime,
                  style: Theme.of(context).textTheme.bodyText2,
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Text(
                  AppLocalizations.of(context).label + " ",
                  style: Theme.of(context).textTheme.subtitle2,
                ),
                Text(title,
                    style: TextStyle(
                        color: Color.fromARGB(255, 5, 104, 225),
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      AppLocalizations.of(context).pipeline + " ",
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                    Text(
                      pipline,
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      owner,
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    ownerImage.length == 1
                        ? CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Text(
                              ownerImage,
                              style: TextStyle(color: Colors.white),
                            ),
                            radius: 15,
                          )
                        : CircleAvatar(
                            backgroundImage:
                                NetworkImage("$baseUrl$ownerImage"),
                            radius: 15,
                          ),
                  ],
                ),
              ],
            ),
            Divider()
          ],
        );
      },
    );
  }
}

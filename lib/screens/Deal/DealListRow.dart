// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'package:flutter/material.dart';

class DealListRow extends StatelessWidget {
  final String reference;
  final String title;
  final String owner;
  final String ownerImage;
  final String createTime;
  final String organisation;
  final String piepline;
  const DealListRow(
      {super.key,
      required this.reference,
      required this.title,
      required this.owner,
      required this.ownerImage,
      required this.createTime,
      required this.organisation,
      required this.piepline});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  "Ref: ",
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  "Organisation: ",
                  style: Theme.of(context).textTheme.subtitle2,
                ),
                Text(
                  organisation,
                  style: Theme.of(context).textTheme.bodyText1,
                )
              ],
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Text(
              "Label :",
              style: Theme.of(context).textTheme.subtitle2,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyText1,
            ),
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
                  "Pipeline :",
                  style: Theme.of(context).textTheme.subtitle2,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  piepline,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
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
                        backgroundColor: Colors
                            .blue, // Choisissez une couleur de fond appropriée
                        child: Text(
                          ownerImage,
                          style: TextStyle(
                              color: Colors
                                  .white), // Choisissez une couleur de texte appropriée
                        ),
                        radius: 15,
                      )
                    : CircleAvatar(
                        backgroundImage: NetworkImage(
                            "https://spherebackdev.cmk.biz:4543/storage/uploads/$ownerImage"),
                        radius: 15,
                      ),
              ],
            ),
          ],
        ),
        Divider()
      ],
    );
  }
}

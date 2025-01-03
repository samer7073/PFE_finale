// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_application_stage_project/core/constants/shared/config.dart';
import 'package:intl/intl.dart';

class BookingsListRow extends StatefulWidget {
  final IconData SourceIcon;
  final String id;
  final String title;
  final String owner;
  final String createTime;

  final String ownerImage;
  final String Pipeline;

  const BookingsListRow(
      {super.key,
      required this.SourceIcon,
      required this.id,
      required this.title,
      required this.owner,
      required this.createTime,
      required this.ownerImage,
      required this.Pipeline});

  @override
  State<BookingsListRow> createState() => _BookingsListRowState();
}

class _BookingsListRowState extends State<BookingsListRow> {
  @override
  void initState() {
    super.initState();
    imageUrlFuture = Config.getApiUrl("urlImage");
  }

  String formatDate(String dateString, Locale locale) {
    DateTime date = DateTime.parse(dateString);
    DateTime now = DateTime.now();

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return DateFormat.Hm(locale.languageCode).format(date);
    }

    if (now.difference(date).inDays < 7) {
      return DateFormat.E(locale.languageCode).format(date);
    }

    return DateFormat('d MMM yyyy HH:MM', locale.languageCode).format(date);
  }

  late Future<String> imageUrlFuture;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return FutureBuilder<String>(
      future: imageUrlFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(
            color: Colors.blue,
          );
        }

        if (snapshot.hasError) {
          return Text('Error loading image URL');
        }

        String baseUrl = snapshot.data ?? "";

        return Container(
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: isDarkMode == false
                  ? Color.fromARGB(255, 244, 245, 247)
                  : Color.fromARGB(255, 31, 24, 24),
              borderRadius: BorderRadius.circular(25)),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.ref + " ",
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(widget.id,
                            style: Theme.of(context).textTheme.bodyLarge)
                      ],
                    ),
                    Text(
                        formatDate(
                          widget.createTime, Localizations.localeOf(context)),
                      style: Theme.of(context).textTheme.headlineMedium,
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
                          AppLocalizations.of(context)!.label + " ",
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        Container(
                          width: 200,
                          child: Text(
                            widget.title,
                            style: TextStyle(
                                color: Color.fromARGB(255, 5, 104, 225),
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 10,
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
                          AppLocalizations.of(context)!.pipeline + " ",
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        Container(
                          width: 150,
                          child: Text(
                            widget.Pipeline,
                            style: Theme.of(context).textTheme.bodyLarge,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          width: 100,
                          child: Text(
                            widget.owner,
                            style: Theme.of(context).textTheme.headlineSmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        widget.ownerImage.length == 1
                            ? CircleAvatar(
                                backgroundColor: Colors
                                    .blue, // Choisissez une couleur de fond appropriée
                                child: Text(
                                  widget.ownerImage,
                                  style: TextStyle(
                                      color: Colors
                                          .white), // Choisissez une couleur de texte appropriée
                                ),
                                radius: 15,
                              )
                            : CircleAvatar(
                                backgroundImage: NetworkImage(
                                    "$baseUrl${widget.ownerImage}"),
                                radius: 15,
                              ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

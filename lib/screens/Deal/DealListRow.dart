// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_application_stage_project/core/constants/shared/config.dart';

class DealListRow extends StatefulWidget {
  final String reference;
  final String title;
  final String owner;
  final String ownerImage;
  final String createTime;
  final String organisation;
  final String piepline;

  const DealListRow({
    super.key,
    required this.reference,
    required this.title,
    required this.owner,
    required this.ownerImage,
    required this.createTime,
    required this.organisation,
    required this.piepline,
  });

  @override
  State<DealListRow> createState() => _DealListRowState();
}

class _DealListRowState extends State<DealListRow> {
  @override
  void initState() {
    super.initState();
    imageUrlFuture = Config.getApiUrl("urlImage");
    log("44444444444444   ${widget.piepline}");
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
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          widget.reference,
                          style: Theme.of(context).textTheme.headlineLarge,
                          overflow: TextOverflow.ellipsis,
                        )
                      ],
                    ),
                    Text(
                      widget.createTime,
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
                          AppLocalizations.of(context)!.organisation + " ",
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        Container(
                          width: 270,
                          child: Text(
                            widget.organisation,
                            style: Theme.of(context).textTheme.headlineLarge,
                            overflow: TextOverflow.ellipsis,
                          ),
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
                      AppLocalizations.of(context)!.label,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      width: 150,
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
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: widget.piepline.isNotEmpty
                      ? MainAxisAlignment.spaceBetween
                      : MainAxisAlignment.end,
                  children: [
                    if (widget.piepline.isNotEmpty)
                      Row(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.pipeline + " ",
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                          Container(
                            width: 100,
                            child: Text(
                              widget.piepline,
                              style: Theme.of(context).textTheme.headlineLarge,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.owner,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        widget.ownerImage.length == 1
                            ? CircleAvatar(
                                backgroundColor: Colors.blue,
                                child: Text(
                                  widget.ownerImage,
                                  style: TextStyle(color: Colors.white),
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

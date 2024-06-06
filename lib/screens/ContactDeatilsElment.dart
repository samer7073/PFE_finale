import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/detailModel.dart';
import '../providers/theme_provider.dart';
import '../services/ApiDetailElment.dart';

class ContactDetailsElment extends StatefulWidget {
  final String elementId;
  final String elementLabel;

  const ContactDetailsElment(
      {super.key, required this.elementId, required this.elementLabel});

  @override
  State<ContactDetailsElment> createState() => _ContactDetailsElmentState();
}

class _ContactDetailsElmentState extends State<ContactDetailsElment> {
  late Future<DetailResponse> futureApiResponse;

  late ThemeProvider themeProvider;

  @override
  void initState() {
    super.initState();
    fetchData();
    themeProvider = Provider.of<ThemeProvider>(context, listen: false);
  }

  void fetchData() {
    futureApiResponse = ApiDetailElment.getDetail(widget.elementId);
  }

  // Utility method to remove square brackets from strings
  String removeBrackets(String value) {
    return value.replaceAll('[', '').replaceAll(']', '');
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(widget.elementLabel)),
      body: FutureBuilder<DetailResponse>(
        future: futureApiResponse,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No details found'));
          } else {
            var detailData = snapshot.data!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: detailData.data.entries
                        .where((entry) =>
                            entry.key != 'id' && entry.key != 'stage_id')
                        .map((entry) {
                      return ListTile(
                        title: Text(
                          entry.key.toUpperCase(),
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                        subtitle: Text(
                          removeBrackets(entry.value.toString()),
                          style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

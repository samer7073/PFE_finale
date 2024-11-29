import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/services/ApiOverView.dart';
import '../components/my_time_line_tiel.dart';
import '../models/ouverviewModel.dart';

class OverviewPage extends StatefulWidget {
  final String elementId;
  final String familyId;
  const OverviewPage(
      {super.key, required this.elementId, required this.familyId});

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  late Future<OverviewModelRespone> futureApiResponse;

  @override
  void initState() {
    super.initState();
    futureApiResponse =
        ApiOverVeiw.getOverview(widget.elementId, widget.familyId);
  }

  String removeHtmlTags(String htmlText) {
    final regex = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false);
    return htmlText.replaceAll(regex, '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<OverviewModelRespone>(
        future: futureApiResponse,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data!.data;
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final isFirst = index == 0;
                final isLast = index == data.length - 1;
                final item = data[index];
                final isPast =
                    DateTime.parse(item.date).isBefore(DateTime.now());

                final cleanedAction = removeHtmlTags(item.action);

                return MyTimelineTile(
                  name: item.user,
                  isFirst: isFirst,
                  isLast: isLast,
                  isPast: isPast,
                  time: item.date,
                  title: cleanedAction,
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return Center(child: CircularProgressIndicator(
                                    color: Colors.blue,
                                  ));
        },
      ),
    );
  }
}

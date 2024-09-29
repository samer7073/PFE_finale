import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/core/constants/shared/config.dart';
import 'package:flutter_application_stage_project/models/leads_models/lead.dart';
import 'package:flutter_application_stage_project/screens/webViewTest.dart';
import 'package:intl/intl.dart';

class LeadTile extends StatelessWidget {
  final Lead lead;

  const LeadTile({Key? key, required this.lead}) : super(key: key);
  String formatDate(String dateString, Locale locale) {
    DateTime date = DateTime.parse(dateString);
    String formattedDate =
        DateFormat.yMMMMd(locale.languageCode).add_Hm().format(date);
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    Locale currentLocale = Localizations.localeOf(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: lead.conversation_id.isNotEmpty
            ? () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => WebView(
                              lead: lead,
                            )));
              }
            : null,
        child: ListTile(
          leading: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.blue,
            child: lead.ownerAvatar.length == 1
                ? Text(
                    lead.ownerAvatar.substring(0, 1).toUpperCase(),
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  )
                : FutureBuilder<String>(
                    future: Config.getApiUrl('urlImage'),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(
                          color: Colors.blue,
                        );
                      }
                      if (snapshot.hasError || !snapshot.hasData) {
                        return Icon(Icons.error);
                      }
                      return CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(
                          "${snapshot.data}${lead.avatar}",
                        ),
                      );
                    },
                  ),
          ),
          title: Row(
            children: [
              Text(
                lead.fullName,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 8,
              ),

              /*
              if (lead.owner != null && lead.owner.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.person, size: 16),
                    SizedBox(width: 4),
                    Text(lead.owner),
                  ],
                ),
              ],
              if (lead.email != null && lead.email.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.email, size: 16),
                    SizedBox(width: 4),
                    Text(lead.email),
                  ],
                ),
              ],
              */
              if (lead.source != null && lead.source.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.source, size: 16),
                    SizedBox(width: 4),
                    Text(lead.source),
                  ],
                ),
              ],
              /*
              if (lead.pipeline != null && lead.pipeline.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.track_changes, size: 16),
                    SizedBox(width: 4),
                    Text(lead.pipeline),
                  ],
                ),
              ],
              
              if (lead.reference != null && lead.reference.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.confirmation_number, size: 16),
                    SizedBox(width: 4),
                    Text(lead.reference),
                  ],
                ),
              ],
              */
              SizedBox(
                height: 8,
              ),
              if (lead.createdAt != null && lead.createdAt.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.date_range, size: 16),
                    SizedBox(width: 4),
                    Text(formatDate(lead.createdAt.toString(), currentLocale)),
                  ],
                ),
              ],
              /*
              if (lead.roomId != null && lead.roomId!.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.meeting_room, size: 16),
                    SizedBox(width: 4),
                    Text(lead.roomId!),
                  ],
                ),
              ],
              if (lead.partagerAvec.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.group, size: 16),
                    SizedBox(width: 4),
                    Text(lead.partagerAvec.join(', ')),
                  ],
                ),
              ],
              */
            ],
          ),
        ),
      ),
    );
  }
}

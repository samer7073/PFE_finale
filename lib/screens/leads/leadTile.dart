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
  DateTime now = DateTime.now();
  
  // Check if the date is today
  if (date.year == now.year && date.month == now.month && date.day == now.day) {
    return DateFormat.Hm(locale.languageCode).format(date); // "12:45"
  }

  
  // Check if the date is within the last week
  if (now.difference(date).inDays < 7) {
    return DateFormat.E(locale.languageCode).format(date); // "Mon", "Tue", etc.
  }

  // For dates older than a week, return full date format
  return DateFormat('d MMM yyyy', locale.languageCode).format(date); // "14 Dec 2023"
}

  @override
  Widget build(BuildContext context) {
    Locale currentLocale = Localizations.localeOf(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
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
        child: Card(
          color: isDarkMode == false
              ? Color.fromARGB(255, 244, 245, 247)
              : Color.fromARGB(255, 31, 24, 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Avatar du lead
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blueAccent,
                  child: lead.avatar.length == 1
                      ? Text(
                          lead.avatar,
                          style: TextStyle(color: Colors.white, fontSize: 24),
                        )
                      : FutureBuilder<String>(
                          future: Config.getApiUrl('urlImage'),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator(
                                color: Colors.blue,
                              );
                            }
                            if (snapshot.hasError || !snapshot.hasData) {
                              return Icon(Icons.error);
                            }
                            return CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(
                                "${snapshot.data}${lead.avatar}",
                              ),
                            );
                          },
                        ),
                ),
                SizedBox(width: 16),
                // Détails du lead
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nom du lead
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 150,
                            child: Text(
                              lead.fullName,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black87),
                            ),
                          ),
                          // Date de création
                          if (lead.updated_at != null &&
                              lead.updated_at.isNotEmpty) ...[
                            SizedBox(
                              
                              child: Text(
                                overflow: TextOverflow.ellipsis,
                                formatDate(lead.updated_at, currentLocale),
                                style: TextStyle(color: Colors.blueGrey),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 4),
                      // Source (si disponible)
                      if (lead.source != null && lead.source.isNotEmpty) ...[
                        Row(
                          children: [
                            Icon(Icons.source,
                                size: 18, color: Colors.blueGrey),
                            SizedBox(width: 4),
                            Text(
                              lead.source,
                              style: TextStyle(color: Colors.blueGrey),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        if (lead.seen_by != null &&
                            lead.seen_by.isNotEmpty) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Display `seen_by` text
                              Text(
                                lead.seen_by + " :",
                                style: TextStyle(color: Colors.blueGrey),
                              ),
                              SizedBox(
                                  width:
                                      4), // Adds a small gap between `seen_by` and the message

                              // Make `last_message` flexible and wrap properly
                              Expanded(
                                child: Text(
                                  textAlign: TextAlign.start,
                                  lead.last_message,
                                  overflow: TextOverflow
                                      .ellipsis, // Use ellipsis for longer messages
                                  maxLines:
                                      1, // Limit to one line or increase as per need
                                  style: TextStyle(color: Colors.blueGrey),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
                // Icône de navigation
                if (lead.conversation_id.isNotEmpty)
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.blue,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

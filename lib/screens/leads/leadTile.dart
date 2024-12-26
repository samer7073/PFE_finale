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

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return DateFormat.Hm(locale.languageCode).format(date);
    }

    if (now.difference(date).inDays < 7) {
      return DateFormat.E(locale.languageCode).format(date);
    }

    return DateFormat('d MMM yyyy ', locale.languageCode).format(date);
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
          color: isDarkMode
              ? Color.fromARGB(255, 31, 24, 24)
              : Color.fromARGB(255, 244, 245, 247),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Lead Avatar
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
                                  color: Colors.blue);
                            }
                            if (snapshot.hasError || !snapshot.hasData) {
                              return Icon(Icons.error);
                            }

                            // Check if image is an SVG
                            String imageUrl = "${snapshot.data}${lead.avatar}";
                            bool isSvg =
                                imageUrl.toLowerCase().endsWith(".svg");

                            return isSvg
                                ? CircleAvatar(
                                    radius: 30,
                                    backgroundImage: AssetImage(
                                        'assets/user17301116397295.png'),
                                  )
                                : CircleAvatar(
                                    radius: 30,
                                    backgroundImage: NetworkImage(imageUrl),
                                  );
                          },
                        ),
                ),
                SizedBox(width: 16),
                // Lead Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                  fontWeight: FontWeight.w500,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black87),
                            ),
                          ),
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
                            crossAxisAlignment: CrossAxisAlignment
                                .center, // Aligne verticalement au centre
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5
                                  ),
                                  color: const Color.fromARGB(255, 207, 225, 240)
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(width: 5,),
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                          maxWidth:
                                              100), // Limite la largeur à 100 pixels
                                      child: Text(
                                        lead.seen_by,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: TextStyle(color: Colors.blueGrey),
                                      ),
                                    ),
                                    SizedBox(
                                        width:
                                            4), // Ajoute un espace entre le nom et le message
                                    Text(":"),
                                        SizedBox(
                                  width:
                                      4), 
                                  ],
                                ),
                              ),
                              SizedBox(width: 5,),

                          // Ajoute un espace entre le ":" et le message
                              Expanded(
                                child: Text(
                                  lead.last_message,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(color: Colors.blueGrey),
                                ),
                              ),
                            ],
                          )
                        ],
                      ],
                    ],
                  ),
                ),
                if (lead.conversation_id.isNotEmpty)
                  Icon(Icons.arrow_forward_ios, color: Colors.blue),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

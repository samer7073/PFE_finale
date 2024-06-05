import 'package:flutter/material.dart';

import '../models/contactModel/ContactModelDetails/ApiResponseContactDeatils.dart';
import '../services/contact/ApiContact.dart';

class ContactDetailsPage extends StatefulWidget {
  final String contactId;
  const ContactDetailsPage({super.key, required this.contactId});

  @override
  State<ContactDetailsPage> createState() => _ContactDetailsPageState();
}

class _ContactDetailsPageState extends State<ContactDetailsPage> {
  Future<ApiResponseContactDetails>? _futureContactDetails;

  @override
  void initState() {
    super.initState();
    _futureContactDetails = ApiContact.getAllContactsDetails(widget.contactId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Details'),
      ),
      body: FutureBuilder<ApiResponseContactDetails>(
        future: _futureContactDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final contactDetails = snapshot.data;
            return ListView(
              children: <Widget>[
                ListTile(
                  title: Text('Label: ${contactDetails!.info.label}'),
                ),
                ListTile(
                  title: Text('Email: ${contactDetails!.info.email ?? 'N/A'}'),
                ),
                ListTile(
                  title: Text(
                      'Phone Number: ${contactDetails!.info.phoneNumber ?? 'N/A'}'),
                ),
                ExpansionTile(
                  title:
                      Text('Deals (${contactDetails.relations.deal!.length})'),
                  children: contactDetails.relations.deal
                      .map((deal) => ListTile(
                            title: Text(deal.label ?? 'No Label'),
                          ))
                      .toList(),
                ),
                ExpansionTile(
                  title: Text(
                      'Projects (${contactDetails.relations.project!.length})'),
                  children: contactDetails.relations.project!
                      .map((project) => ListTile(
                            title: Text(project['label'] ?? 'No Label'),
                          ))
                      .toList(),
                ),
                ExpansionTile(
                  title: Text(
                      'Helpdesk (${contactDetails.relations.helpdesk!.length})'),
                  children: contactDetails.relations.helpdesk!
                      .map((helpdesk) => ListTile(
                            title: Text(helpdesk['label'] ?? 'No Label'),
                          ))
                      .toList(),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

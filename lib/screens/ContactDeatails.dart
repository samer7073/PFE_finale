import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/screens/ContactDeatilsElment.dart';
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}'),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _futureContactDetails =
                            ApiContact.getAllContactsDetails(widget.contactId);
                      });
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          } else {
            final contactDetails = snapshot.data;
            String cleanedPhoneNumber = contactDetails?.info.phoneNumber
                    .toString()
                    .replaceAll('[', '')
                    .replaceAll(']', '')
                    .replaceAll(',', '') ??
                'N/A';

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: <Widget>[
                  Card(
                    child: ListTile(
                      title: Text('Label: ${contactDetails!.info.label}',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.email),
                      title: Text(
                        contactDetails.info.email == "null" ||
                                contactDetails.info.email!.isEmpty
                            ? 'Email: (Email not available)'
                            : 'Email: ${contactDetails.info.email}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.phone),
                      title: Text(
                        contactDetails.info.phoneNumber == "null" ||
                                contactDetails.info.phoneNumber!.isEmpty
                            ? 'Phone Number: (Phone number not available)'
                            : 'Phone Number: $cleanedPhoneNumber',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Card(
                    child: ExpansionTile(
                      title: Text(
                          'Deals (${contactDetails.relations.deal!.length})',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      children: contactDetails.relations.deal!
                          .map((deal) => ListTile(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) {
                                      return ContactDetailsElment(
                                          elementLabel: deal.label,
                                          elementId: deal.id);
                                    },
                                  ));
                                },
                                title: Text(deal.label ?? 'No Label'),
                                leading: Icon(Icons.business),
                              ))
                          .toList(),
                    ),
                  ),
                  Card(
                    child: ExpansionTile(
                      title: Text(
                          'Projects (${contactDetails.relations.project!.length})',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      children: contactDetails.relations.project!
                          .map((project) => ListTile(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) {
                                      return ContactDetailsElment(
                                          elementLabel: project.label,
                                          elementId: project.id);
                                    },
                                  ));
                                },
                                title: Text(project.label ?? 'No Label'),
                                leading: Icon(Icons.work),
                              ))
                          .toList(),
                    ),
                  ),
                  Card(
                    child: ExpansionTile(
                      title: Text(
                          'Helpdesk (${contactDetails.relations.helpdesk!.length})',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      children: contactDetails.relations.helpdesk!
                          .map((helpdesk) => ListTile(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) {
                                      return ContactDetailsElment(
                                          elementLabel: helpdesk.label,
                                          elementId: helpdesk.id);
                                    },
                                  ));
                                },
                                title: Text(helpdesk.label ?? 'No Label'),
                                leading: Icon(Icons.help),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

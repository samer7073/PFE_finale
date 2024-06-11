import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/models/contactModel/data.dart';
import 'package:flutter_application_stage_project/screens/ContactDeatails.dart';
import 'package:flutter_application_stage_project/services/contact/ApiContact.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  List<Data> contacts = [];
  bool isLoading = false;
  int page = 1;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchDeals();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        fetchMoreDeals();
      }
    });
  }

  Future<void> fetchDeals() async {
    setState(() {
      isLoading = true;
    });

    List<Data> fetcheContact = await ApiContact.getAllContact(page: page);
    setState(() {
      contacts.addAll(fetcheContact);
      isLoading = false;
    });
  }

  Future<void> fetchMoreDeals() async {
    if (!isLoading) {
      page++;
      fetchDeals();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).contacts),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return ListTile(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return ContactDetailsPage(contactId: contact.id);
                      },
                    ));
                  },
                  leading: contact.avatar.length == 1
                      ? CircleAvatar(
                          backgroundColor: Colors
                              .blue, // Choisissez une couleur de fond appropriée
                          child: Text(
                            contact.avatar,
                            style: TextStyle(
                                color: Colors
                                    .white), // Choisissez une couleur de texte appropriée
                          ),
                          radius: 25,
                        )
                      : CircleAvatar(
                          backgroundImage: NetworkImage(
                              "https://spherebackdev.cmk.biz:4543/storage/uploads/${contact.avatar}"),
                          radius: 25,
                        ),
                  title: Text(contact.label),
                  subtitle: Text(contact.familyLabel),
                  // Ajoutez d'autres détails du contact ici si nécessaire
                );
              },
            ),
          ),
          if (isLoading) ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          ],
        ],
      ),
    );
  }
}

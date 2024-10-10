import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/core/constants/shared/config.dart';
import 'package:flutter_application_stage_project/models/leads_models/lead.dart';
import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebView extends StatefulWidget {
  final Lead lead;

  WebView({required this.lead});

  @override
  _WebViewState createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  late WebViewController controller;
  String? token;
  String? baseUrl;
  bool isLoading = true;  // Variable pour gérer l'état de chargement

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    // Récupération asynchrone du token et du baseUrl
    token = await SharedPrefernce.getToken("token");
    baseUrl = await Config.getApiUrl('rmcChat');

    if (token != null && baseUrl != null) {
      // Initialisation du WebViewController une fois le token et le baseUrl récupérés
      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000)) // Optionnel
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (url) {
              setState(() {
                isLoading = true;  // Page commence à charger
              });
              print("Chargement de la page commencé: $url");
            },
            onPageFinished: (url) {
              setState(() {
                isLoading = false;  // Page finie de charger
              });
              log("Chargement de la page terminé: $url");
            },
            onWebResourceError: (error) {
              setState(() {
                isLoading = false;  // Erreur, arrêt du chargement
              });
              print("Erreur lors du chargement de la page: ${error.description}");
            },
          ),
        )
        ..loadRequest(
          Uri.parse(
              "$baseUrl?Token=$token&conversation=${widget.lead.conversation_id}&vue=360"),
        );
    } else {
      print("Erreur : le token ou le baseUrl est nul");
    }

    // Mise à jour de l'état après initialisation
    if (mounted) {
      setState(() {});
    }
  }

  String formatDate(String dateString, Locale locale) {
    DateTime date = DateTime.parse(dateString);
    String formattedDate =
        DateFormat.yMMMMd(locale.languageCode).add_Hm().format(date);
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    Locale currentLocale = Localizations.localeOf(context);
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String>(
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
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blueAccent,
                  child: widget.lead.avatar.length == 1
                      ? Text(
                          widget.lead.avatar,
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
                                "${snapshot.data}${widget.lead.avatar}",
                              ),
                            );
                          },
                        ),
                ),
                SizedBox(
                  width: 8,
                ),
                Center(
                  child: Text(
                    widget.lead.fullName,
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            );
          },
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              // Afficher un AlertDialog avec les détails du lead
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Détails du Lead'),
                    content: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          if (widget.lead.fullName.isNotEmpty) ...[
                            Row(
                              children: [
                                Icon(Icons.person, color: Colors.blue),
                                SizedBox(width: 8),
                                Text('Nom: ${widget.lead.fullName}',
                                    style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            SizedBox(height: 8),
                          ],
                          if (widget.lead.email.isNotEmpty) ...[
                            Row(
                              children: [
                                Icon(Icons.email, color: Colors.blueAccent),
                                SizedBox(width: 8),
                                Text('Email: ${widget.lead.email}'),
                              ],
                            ),
                            SizedBox(height: 8),
                          ],
                          if (widget.lead.source.isNotEmpty) ...[
                            Row(
                              children: [
                                Icon(Icons.source, color: Colors.blueAccent),
                                SizedBox(width: 8),
                                Text('Source: ${widget.lead.source}'),
                              ],
                            ),
                            SizedBox(height: 8),
                          ],
                          if (widget.lead.pipeline.isNotEmpty) ...[
                            Row(
                              children: [
                                Icon(Icons.linear_scale, color: Colors.blueAccent),
                                SizedBox(width: 8),
                                Text('Pipeline: ${widget.lead.pipeline}'),
                              ],
                            ),
                            SizedBox(height: 8),
                          ],
                          if (widget.lead.reference.isNotEmpty) ...[
                            Row(
                              children: [
                                Icon(Icons.bookmark, color: Colors.blueAccent),
                                SizedBox(width: 8),
                                Text('Référence: ${widget.lead.reference}'),
                              ],
                            ),
                            SizedBox(height: 8),
                          ],
                          if (widget.lead.owner.isNotEmpty) ...[
                            Row(
                              children: [
                                Icon(Icons.person_outline, color: Colors.blueAccent),
                                SizedBox(width: 8),
                                Text('Propriétaire: ${widget.lead.owner}'),
                              ],
                            ),
                            SizedBox(height: 8),
                          ],
                          if (widget.lead.partagerAvec.isNotEmpty) ...[
                            Row(
                              children: [
                                Icon(Icons.group, color: Colors.blueAccent),
                                SizedBox(width: 8),
                                Text('Partagé avec: ${widget.lead.partagerAvec.join(', ')}'),
                              ],
                            ),
                            SizedBox(height: 8),
                          ],
                          if (widget.lead.createdAt.isNotEmpty) ...[
                            Row(
                              children: [
                                Icon(Icons.calendar_today, color: Colors.blueAccent),
                                SizedBox(width: 8),
                                Text('Créé à: ${formatDate(widget.lead.createdAt, currentLocale)}'),
                              ],
                            ),
                            SizedBox(height: 8),
                          ],
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Fermer'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
            icon: Icon(Icons.info_outline_rounded, size: 30),
          )
        ],
      ),
      body: Stack(
        children: [
          // Affichage de la WebView
          token == null || baseUrl == null
              ? Center(child: CircularProgressIndicator())
              : SizedBox(
                  child: WebViewWidget(controller: controller),
                ),
          
          // Indicateur de chargement
          if (isLoading)
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: CircularProgressIndicator(),
                ),
                SizedBox(height: 10,),
                Center(
                  child: Text("Loading .......",style: TextStyle(color: Colors.blue),),
                )
              ],
            ),
        ],
      ),
    );
  }
}

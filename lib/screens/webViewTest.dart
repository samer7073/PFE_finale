import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/core/constants/shared/config.dart';
import 'package:flutter_application_stage_project/models/leads_models/lead.dart';
import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebView extends StatefulWidget {
  final Lead lead;
  const WebView({super.key, required this.lead});

  @override
  State<WebView> createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    final token = SharedPrefernce.getToken("token");

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000)) // Optionnel
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            print("Page loading started: $url");
          },
          onPageFinished: (url) {
            print("Page loading finished: $url");
          },
          onWebResourceError: (error) {
            print("Error loading page: ${error.description}");
          },
        ),
      )
      ..loadRequest(
        Uri.parse(
            "https://rmcdemo.comunikcrm.info/comuniksocialdev/admin.php?Token=$token&conversation=${widget.lead.conversation_id}&vue=360"),
      );
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
                  backgroundImage: NetworkImage(
                    "${snapshot.data}${widget.lead.avatar}",
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
                // Nom
                if (widget.lead.fullName.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.person, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Nom: ${widget.lead.fullName}', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 8),
                ],
                // Email
                if (widget.lead.email.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.email, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Email: ${widget.lead.email}'),
                    ],
                  ),
                  SizedBox(height: 8),
                ],
                // Source
                if (widget.lead.source.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.source, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Source: ${widget.lead.source}'),
                    ],
                  ),
                  SizedBox(height: 8),
                ],
                // Pipeline
                if (widget.lead.pipeline.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.linear_scale, color: Colors.purple),
                      SizedBox(width: 8),
                      Text('Pipeline: ${widget.lead.pipeline}'),
                    ],
                  ),
                  SizedBox(height: 8),
                ],
              
                // Référence
                if (widget.lead.reference.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.bookmark, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Référence: ${widget.lead.reference}'),
                    ],
                  ),
                  SizedBox(height: 8),
                ],
                // Propriétaire
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
                // Partager avec
                if (widget.lead.partagerAvec.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.group, color: Colors.deepOrange),
                      SizedBox(width: 8),
                      Text('Partagé avec: ${widget.lead.partagerAvec.join(', ')}'),
                    ],
                  ),
                  SizedBox(height: 8),
                ],
                // Créé à
                if (widget.lead.createdAt.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.indigo),
                      SizedBox(width: 8),
                      Text('Créé à: ${formatDate(widget.lead.createdAt,currentLocale)}'),
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
      body: SizedBox(
        child: WebViewWidget(controller: controller),
      ),
    );
  }
}

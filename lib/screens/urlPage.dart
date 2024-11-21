// ignore_for_file: prefer_const_constructors

import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/sharedPreference.dart';
import 'login_page.dart';

class UrlPage extends StatefulWidget {
  UrlPage({super.key});

  @override
  State<UrlPage> createState() => _UrlPageState();
}

class _UrlPageState extends State<UrlPage> {
  final _formKey = GlobalKey<FormState>();
  String? url;
  String urlForm = "";
  final FocusNode _focusNodeURL = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadUrl();
    _focusNodeURL.addListener(() {
      setState(() {}); // Rebuild the widget to update hintText
    });
  }

  @override
  void dispose() {
    _focusNodeURL.dispose();
    super.dispose();
  }

  void _loadUrl() async {
    String? storedString = await SharedPrefernce.getToken('url');
    setState(() {
      url = storedString;
      log("Url---------------------------------------- $url");
    });
  }

  void _saveUrl(String key, String value) async {
    await SharedPrefernce.saveUrl(key, value);
    _loadUrl(); // Reload the string after saving
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          // Image de fond
          Positioned.fill(
            child: Image.asset(
              'assets/bg.png',
              fit: BoxFit.cover,
            ),
          ),
          // Contenu principal
          Column(
            children: [
              SizedBox(height: 50),
              Image.asset(
                'assets/logo-cmk.png', // Remplacez par le chemin de votre image
                fit: BoxFit.cover,
              ),
              SizedBox(height: 10),
              Text(
                "Comunik Sphere",
                style: TextStyle(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  fontSize: 20.55,

                  fontFamily: 'ProstoOne', // Use the "Prosto One" font
                ),
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(
                      height: 70,
                    ),
                    Text(
                      "Connection to a host server",
                      style: textTheme?.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontFamily: 'ProstoOne',
                      ), // Texte en blanc
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "What is the address of your server?",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'ProstoOne',
                      ), // Texte en blanc
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(40, 0, 40, 0),
                      child: TextFormField(
                        focusNode: _focusNodeURL,
                        onChanged: (value) {
                          urlForm = value;
                          _saveUrl('url', value);
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your URL';
                          }
                          return null;
                        },
                        cursorColor: Colors.white,
                        keyboardType: TextInputType.url,
                        decoration: InputDecoration(
                          hintText: _focusNodeURL.hasFocus || urlForm.isNotEmpty
                              ? ''
                              : "Host server URL",
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors
                                    .white), // Color of the underline when the field is enabled
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white), // C
                          ),

                          hintStyle: TextStyle(
                              fontFamily: 'ProstoOne',
                              color: Colors.white), // Texte d'indice en blanc

                          prefixIcon: const Icon(
                            Icons.link,
                            color: Colors.white, // Icône en blanc
                          ),
                        ),
                        style: TextStyle(
                            color: Colors.white), // Texte saisi en blanc
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          shape: StadiumBorder(),
                          padding: EdgeInsets.symmetric(
                              horizontal: 130, vertical: 16),
                          backgroundColor: Colors.white),
                      child: Text(
                        "${AppLocalizations.of(context)!.save}",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 22, 105, 161),
                          fontWeight: FontWeight.w900,
                          fontFamily: 'ProstoOne',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

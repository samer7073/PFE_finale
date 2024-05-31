// ignore_for_file: prefer_const_constructors

import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadUrl();
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

// Store theme for efficiency

    return Scaffold(
      body: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/serveurImage.jpg',
              width: 200,
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Connection to a host server",
                    style: textTheme?.bodyText1, // Use null-safe access
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                      "What is the address of your server?"), // Corrected French spelling
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(40, 0, 40, 0),
                    child: TextFormField(
                      onChanged: (value) {
                        _saveUrl('url', value);
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your URL'; // Improved French message
                        }
                        return null;
                      },
                      keyboardType:
                          TextInputType.url, // Use TextInputType.url for URLs
                      decoration: InputDecoration(
                        hintText: "Host server URL",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        fillColor:
                            Color.fromARGB(255, 39, 149, 176).withOpacity(0.1),
                        filled: true,
                        prefixIcon: const Icon(
                          Icons.link,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        // Handle form submission logic here (e.g., save URL)
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (context) =>
                                  LoginPage()), // Replace with your main screen
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: StadiumBorder(),
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                      backgroundColor: Color.fromARGB(255, 228, 244, 250),
                    ),
                    child: Text(
                      "Save",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_stage_project/models/login/loginResponse.dart';
import 'package:flutter_application_stage_project/screens/home_page.dart';
import 'package:flutter_application_stage_project/screens/login_page.dart';
import 'package:flutter_application_stage_project/providers/theme_provider.dart';
import 'package:flutter_application_stage_project/services/ApiOtpGenerate.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/sharedPreference.dart';
import 'loading.dart';

class VerfierPassword extends StatefulWidget {
  final String email;
  const VerfierPassword({super.key, required this.email});

  @override
  State<VerfierPassword> createState() => _VerfierPasswordState();
}

class _VerfierPasswordState extends State<VerfierPassword> {
  late ThemeProvider themeProvider;
  String otp = "";
  String errorMessage = "";
  Map<String, dynamic> data = {};
  Map<String, dynamic> otpData = {};

  @override
  void initState() {
    super.initState();
    themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    postOtp();
  }

  void postOtp() async {
    data!['email'] = widget.email;
    log(data.toString());
    try {
      setState(() {
        loading = true;
      });
      final isProd = await checkIsProd();

      final otpResponse = await ApiOtpGenrate.OtpGenrate(data);
      if (otpResponse == 200) {
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      log(e.toString());
    }
  }

  void confirmUser() async {
    if (otp.isEmpty) {
      setState(() {
        errorMessage = "Le code de vérification ne peut pas être vide.";
      });
    } else {
      setState(() {
        loading = true;
        errorMessage = "";
        otpData['otp'] = otp;
      });
      print(otpData.toString());
      try {
        final postOtp = await ApiOtpGenrate.LoginOtp(otpData);
        if (postOtp!.success == true) {
          _saveString('token', postOtp!.token.access_token);
          Navigator.pushNamedAndRemoveUntil(
              context, '/homeNavigate', (route) => false);
          setState(() {
            loading = false;
          });
        }
      } catch (e) {
        setState(() {
          loading = false;
        });
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Ok"))
                  ],
                  title: Text("Probléme d'authentiification"),
                  contentPadding: EdgeInsets.all(20),
                  content: Text("Merci de vérifier votre code otp"),
                ));
        log(e.toString());
      }

      // Logique de confirmation de l'utilisateur
      log("OTP CODE EST : $otp");
    }
  }

  void _saveString(String key, String value) async {
    await SharedPrefernce.saveToken(key, value);
  }

  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return loading
        ? Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            appBar: AppBar(),
            body: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    SizedBox(height: 50),
                    Text(
                      "le code de vérification",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 30),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "nous avons envoyé la vérification du code à votre email",
                    ),
                    SizedBox(height: 40),
                    OtpTextField(
                      keyboardType: TextInputType.number,
                      mainAxisAlignment: MainAxisAlignment.center,
                      numberOfFields: 6,
                      fillColor:
                          Color.fromARGB(255, 39, 69, 176).withOpacity(0.1),
                      filled: true,
                      onSubmit: (value) {
                        log("OTP CODE EST : $value");
                        setState(() {
                          otp = value;
                        });
                        if (value.length == 6) {
                          confirmUser(); // Appel de l'API lorsque tous les champs sont remplis
                        }
                      },
                    ),
                    SizedBox(height: 30),
                    if (errorMessage.isNotEmpty)
                      Text(
                        errorMessage,
                        style: TextStyle(color: Colors.red),
                      ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: confirmUser,
                          style: ElevatedButton.styleFrom(
                            shape: const StadiumBorder(),
                            minimumSize: Size(150, 50),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 130, vertical: 16),
                            backgroundColor: Color.fromARGB(255, 228, 236, 250),
                          ),
                          child: const Text(
                            "Confirmer",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color.fromARGB(255, 62, 33, 250),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  Future<bool> checkIsProd() async {
    final url = await getUrlFromSharedPreferences();
    log('Stored URL: $url');

    bool isProd = false;

    if (url == "sphere.cmk.biz") {
      log('isProd set to true');
      isProd = true;
    } else {
      log('isProd set to false');
      isProd = false;
    }

    await setIsProdInSharedPreferences(
        isProd); // Enregistrement de la valeur isProd dans SharedPreferences
    return isProd;
  }

  Future<String?> getUrlFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('url');
  }

  Future<void> setIsProdInSharedPreferences(bool isProd) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isProd', isProd);
  }
}

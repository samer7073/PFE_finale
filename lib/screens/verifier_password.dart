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
    data['email'] = widget.email;
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
            body: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/bgotp.png', // Replace with your image asset path
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 194, 18, 0),
                  child: Column(
                    children: [
                      Text(
                        "VERIFY ACCOUNT!",
                        style: TextStyle(
                            fontFamily: 'ProstoOne',
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 30),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Enter 6-digit Code code we have sent to at your email",
                        style: TextStyle(
                            fontFamily: 'ProstoOne',
                            fontSize: 16,
                            color: Color.fromRGBO(255, 255, 255, 0.8)),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 40),
                      OtpTextField(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        showFieldAsBox: true,
                        fieldWidth: 50,
                        keyboardType: TextInputType.number,
                        mainAxisAlignment: MainAxisAlignment.center,
                        numberOfFields: 6,
                        fillColor: Colors.white,
                        filled: true,
                        onSubmit: (value) {
                          log("OTP CODE EST : $value");
                          setState(() {
                            otp = value;
                          });
                          if (value.length == 6) {
                            confirmUser();
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
                                    horizontal: 150, vertical: 16),
                                backgroundColor: Color(0xFF5909B1)),
                            child: const Text(
                              "NEXT",
                              style: TextStyle(
                                fontFamily: 'ProstoOne',
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
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

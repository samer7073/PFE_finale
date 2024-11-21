// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import pour accéder au presse-papiers
import 'package:flutter_application_stage_project/providers/theme_provider.dart';
import 'package:flutter_application_stage_project/services/ApiOtpGenerate.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/ApiGetJWT.dart';
import '../services/sharedPreference.dart';

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
  bool loading = false;

  final List<TextEditingController> otpControllers =
      List.generate(6, (_) => TextEditingController());

  final FocusNode focusNode0 = FocusNode();
  final FocusNode focusNode1 = FocusNode();
  final FocusNode focusNode2 = FocusNode();
  final FocusNode focusNode3 = FocusNode();
  final FocusNode focusNode4 = FocusNode();
  final FocusNode focusNode5 = FocusNode();

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
    } else if (otp.length < 6) {
      setState(() {
        errorMessage =
            "Le code de vérification doit contenir au moins 6 chiffres.";
      });
    } else {
      setState(() {
        loading = true;
        errorMessage = "";
        otpData['otp'] = otp;
      });

      try {
        final postOtp = await ApiOtpGenrate.LoginOtp(otpData);
        if (postOtp!.success == true) {
          _saveString('token', postOtp.token.access_token);
          final jwtResponse = await ApiGetJwt.getJwt();
          log("jwt: ${jwtResponse.jwtMercure}");
          _saveString('jwt', jwtResponse.jwtMercure);
          log("Uuid: ${jwtResponse.uuid}");
          _saveString("uuid", jwtResponse.uuid);
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
                        child: Text("${AppLocalizations.of(context)!.ok}",style: TextStyle(
                          color: Colors.blue
                        ),))
                  ],
                  title: Text("${AppLocalizations.of(context)!.authenticationproblem}"),
                  contentPadding: EdgeInsets.all(20),
                  content: Text("${AppLocalizations.of(context)!.merciverifiercode}"),
                ));
        log(e.toString());
      }
      log("OTP CODE EST : $otp");
    }
  }

  void _saveString(String key, String value) async {
    await SharedPrefernce.saveToken(key, value);
  }

  Future<void> _handlePaste() async {
    final clipboardData = await Clipboard.getData('text/plain');
    if (clipboardData != null) {
      final pastedText = clipboardData.text;
      if (pastedText!.length == 6) {
        setState(() {
          for (int i = 0; i < 6; i++) {
            otpControllers[i].text = pastedText[i];
          }
          otp = pastedText;
        });
       // confirmUser();
      }
    }
  }

  void _handleChange(String value, int index) {
    if (value.length == 0) {
      if (index > 0) {
        FocusScope.of(context).previousFocus();
      }
    } else if (value.length == 1) {
      if (index < 5) {
        FocusScope.of(context).nextFocus();
      } else {
        setState(() {
          otp = otpControllers.map((controller) => controller.text).join();
        });
       // confirmUser();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.blue,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Veuillez patienter, le traitement est en cours...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          )
        : Scaffold(
            body: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/bg.png', // Remplacez par le chemin de votre image
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
                        "Enter 6-digit code we have sent to your email",
                        style: TextStyle(
                            fontFamily: 'ProstoOne',
                            fontSize: 16,
                            color: Color.fromRGBO(255, 255, 255, 0.8)),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(6, (index) {
                          return Container(
                            width: 40,
                            margin: EdgeInsets.symmetric(horizontal: 5),
                            child: TextFormField(
                              controller: otpControllers[index],
                              focusNode: [
                                focusNode0,
                                focusNode1,
                                focusNode2,
                                focusNode3,
                                focusNode4,
                                focusNode5
                              ][index],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              onChanged: (value) {
                                _handleChange(value, index);
                              },
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              cursorColor: Colors.blue, // Couleur du curseur
                              decoration: InputDecoration(
                                counterText: '',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.white), // Couleur du contour
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.white), // Couleur du contour lorsqu'il est focus
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.white), // Couleur du contour lorsqu'il est non focus
                                ),
                              ),
                              onTap: index == 0
                                  ? () async {
                                       // Délai court
                                      await _handlePaste();
                                    }
                                  : null,
                            ),
                          );
                        }),
                      ),
                      SizedBox(height: 30),
                      if (errorMessage.isNotEmpty)
                        Text(
                          errorMessage,
                          style: TextStyle(color: Colors.white),
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
                                backgroundColor: Colors.white),
                            child: const Text(
                              "NEXT",
                              style: TextStyle(
                                fontFamily: 'ProstoOne',
                                fontSize: 16,
                                color: Color.fromARGB(255, 22, 105, 161),
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

    await setIsProdInSharedPreferences(isProd);
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

// ignore_for_file: prefer_const_constructors

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/screens/home_page.dart';
import 'package:flutter_application_stage_project/providers/theme_provider.dart';
import 'package:flutter_application_stage_project/screens/verifier_password.dart';
import 'package:flutter_application_stage_project/services/loginApi.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ApiGetJWT.dart';
import '../services/sharedPreference.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final urlController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  late ThemeProvider themeProvider;
  String? savedToken;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    _loadUrl();
  }

  void _loadUrl() async {
    String? storedString = await SharedPrefernce.getToken('url');
    setState(() {
      url = storedString ?? "";
      log("Url---------------------------------------- $url");
    });
  }

  void _saveUrl(String key, String value) async {
    await SharedPrefernce.saveUrl(key, value);
    _loadUrl(); // Reload the string after saving
  }

  void _saveString(String key, String value) async {
    await SharedPrefernce.saveToken(key, value);
  }

  void signUser() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  final _formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  String url = "";
  final LoginApi loginAPI = LoginApi();
  bool loading = false;
  bool securePassword = true;

  @override
  Widget build(BuildContext context) {
    log("Url build---------------------------------------- $url");
    log('build ${themeProvider.isDarkMode}');
    return loading
        ? Scaffold(
            body: Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          )
        : Scaffold(
            body: Container(
              margin: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _header(context),
                    Form(key: _formKey, child: _inputField(context)),
                  ],
                ),
              ),
            ),
          );
  }

  _header(context) {
    return Column(
      children: [
        SizedBox(
          height: 50,
        ),
        Text(
          AppLocalizations.of(context).headerLogin,
          style: Theme.of(context).textTheme.headline1,
        ),
        SizedBox(
          height: 20,
        ),
        Text(AppLocalizations.of(context).textLogin),
        SizedBox(
          height: 50,
        )
      ],
    );
  }

  _inputField(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              url,
              style: Theme.of(context).textTheme.bodyText1,
            ),
            ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return SingleChildScrollView(
                        child: SizedBox(
                          height: 2000,
                          child: Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 30,
                                ),
                                Text(
                                  "Connexion à un serveur d'accueil",
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Text("Quelle est l'adresse de votre serveur ?"),
                                SizedBox(
                                  height: 15,
                                ),
                                Form(
                                    child: Column(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.fromLTRB(50, 0, 50, 0),
                                      child: TextFormField(
                                        initialValue: url,
                                        onChanged: (value) {
                                          _saveUrl('url', value);
                                        },
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Please enter your Url';
                                          }

                                          return null;
                                        },
                                        keyboardType: TextInputType.url,
                                        decoration: InputDecoration(
                                            hintText:
                                                "URL du serveur d'acceuil",
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                                borderSide: BorderSide.none),
                                            fillColor:
                                                Color.fromARGB(255, 15, 65, 245)
                                                    .withOpacity(0.1),
                                            filled: true,
                                            prefixIcon: const Icon(
                                              Icons.link_rounded,
                                            )),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                          shape: StadiumBorder(),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 50, vertical: 16),
                                          backgroundColor: Color.fromARGB(
                                              255, 181, 218, 240)),
                                      child: Text(
                                        "Modify",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.blue,
                                            fontWeight: FontWeight.w900),
                                      ),
                                    )
                                  ],
                                ))
                              ],
                            ),
                          ),
                        ),
                      );
                    });
              },
              style: ElevatedButton.styleFrom(
                  shape: StadiumBorder(),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                  backgroundColor: Colors.white),
              child: Text(
                "modify",
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                    fontWeight: FontWeight.w900),
              ),
            )
          ],
        ),
        SizedBox(
          height: 10,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: emailController,
          onChanged: (value) {
            setState(() => email = value);
          },
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter your email';
            }
            if (!isValidEmail(value)) {
              return AppLocalizations.of(context).enterValidEmail;
            }
            return null;
          },
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
              hintText: AppLocalizations.of(context).email,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none),
              fillColor: Color.fromARGB(255, 15, 65, 245).withOpacity(0.1),
              filled: true,
              prefixIcon: const Icon(
                Icons.email,
              )),
        ),
        const SizedBox(height: 10),
        TextFormField(
          onChanged: (value) {
            setState(() => password = value);
          },
          validator: (value) {
            if (value!.isEmpty) {
              return AppLocalizations.of(context)!.fieldRequired;
            }
          },
          decoration: InputDecoration(
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  securePassword = !securePassword;
                });
              },
              icon: Icon(securePassword == true
                  ? Icons.visibility
                  : Icons.visibility_off),
            ),
            hintText: AppLocalizations.of(context).password,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none),
            fillColor: Color.fromARGB(255, 15, 65, 245).withOpacity(0.1),
            filled: true,
            prefixIcon: const Icon(
              Icons.password,
            ),
          ),
          obscureText: securePassword,
        ),
        const SizedBox(height: 50),
        Container(
          padding: EdgeInsets.fromLTRB(60, 0, 60, 0),
          width: 50,
          height: 50,
          child: ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                log(password + "," + email);
                setState(() {
                  loading = true;
                });

                try {
                  final isProd = await checkIsProd();
                  final loginResponse =
                      await loginAPI.loginUser(email, password, isProd);

                  if (loginResponse.success) {
                    _saveString('token', loginResponse.token.access_token);
                    log("token: ${loginResponse.token.access_token}");
                    final jwtResponse = await ApiGetJwt.getJwt();
                    log("jwt: ${jwtResponse.jwtMercure}");
                    _saveString('jwt', jwtResponse.jwtMercure);
                    log("Uuid: ${jwtResponse.uuid}");
                    _saveString("uuid", jwtResponse.uuid);
                    /*

                    setState(() {
                      loading = false;
                    });
                    */

                    Navigator.pushNamedAndRemoveUntil(
                        context, '/homeNavigate', (route) => false);
                  }
                } on LoginException catch (e) {
                  log("LoginException: $e");
                  setState(() {
                    loading = false;
                  });

                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Problème d'authentification"),
                      contentPadding: EdgeInsets.all(20),
                      content: Text(
                        "Merci de vérifier vos informations ou bien contacter l'administrateur.\n$e",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("Ok"),
                        ),
                      ],
                    ),
                  );
                } catch (e) {
                  log("Error: $e");
                  setState(() {
                    loading = false;
                  });

                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Problème d'authentification"),
                      contentPadding: EdgeInsets.all(20),
                      content: Text(
                        "Merci de vérifier vos informations ou bien contacter l'administrateur.\n$e",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("Ok"),
                        ),
                      ],
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              shape: StadiumBorder(),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
              backgroundColor: Color.fromARGB(255, 181, 218, 240),
            ),
            child: Text(
              AppLocalizations.of(context).login,
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue,
                  fontWeight: FontWeight.w900),
            ),
          ),
        ),
        SizedBox(
          height: 100,
        ),
        TextButton(
          onPressed: () {
            if (emailController.text.isEmpty ||
                !isValidEmail(emailController.text)) {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: Text("Invalid Email"),
                        content: Text("Please enter a valid email address."),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("OK"))
                        ],
                      ));
            } else {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return VerfierPassword(
                    email: emailController.text,
                  );
                },
              ));
            }
          },
          child: Text(
            "Send me a code !",
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    );
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  Future<bool> checkIsProd() async {
    final url = await getUrlFromSharedPreferences();
    log('Stored URL: $url');

    bool isProd = false;

    if (url == "sphereback.cmk.biz") {
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

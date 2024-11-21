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
  final FocusNode _focusNodeEmail = FocusNode();
  final FocusNode _focusNodePassword = FocusNode();

  @override
  void initState() {
    super.initState();
    themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    _loadUrl();
    _focusNodeEmail.addListener(() {
      setState(() {}); // Rebuild the widget to update hintText
    });
    _focusNodePassword.addListener(() {
      setState(() {}); // Rebuild the widget to update hintText
    });
  }

  @override
  void dispose() {
    _focusNodeEmail.dispose();
    _focusNodePassword.dispose();
    super.dispose();
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
              clipBehavior: Clip.hardEdge,
              fit: StackFit.expand,
              children: [
                // Image de fond
                Image.asset(
                  'assets/bg.png', // Remplacez par le chemin de votre image
                  fit: BoxFit.cover,
                ),
                // Contenu de la page
                Container(
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
              ],
            ),
          );
  }

  _header(context) {
    return Column(
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
        SizedBox(height: 50),
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
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            IconButton(onPressed: (){
              showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return SizedBox(
                        height: 2000,
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 30,
                              ),
                              Text(
                                "${AppLocalizations.of(context)!.connectingtoahostserver}",
                                style: Theme.of(context).textTheme.headlineLarge,
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Text("${AppLocalizations.of(context)!.address}"),
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
                                      cursorColor: Colors.black,
                                      keyboardType: TextInputType.url,
                                      decoration: InputDecoration(
                                          hintText:
                                              "${AppLocalizations.of(context)!.homeserverurl}",
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                              borderSide: BorderSide.none),
                                          fillColor:
                                              Colors.grey.shade200,
                                          filled: true,
                                          prefixIcon: const Icon(
                                            Icons.link_rounded,color: Colors.blue,
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
                                        backgroundColor: Colors.blue),
                                    child: Text(
                                      "${AppLocalizations.of(context)!.modifyurl}",
                                      style: TextStyle(
                                          fontFamily: 'ProstoOne',
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900),
                                    ),
                                  )
                                ],
                              ))
                            ],
                          ),
                        ),
                      );
                    });
            }, icon:  Icon(Icons.edit,color: Colors.white)),
           
          ],
        ),
        SizedBox(
          height: 10,
        ),
        const SizedBox(height: 10),
        TextFormField(
          cursorColor: Colors.white,
          controller: emailController,
          focusNode: _focusNodeEmail,
          onChanged: (value) {
            setState(() => email = value);
          },
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter your email';
            }
            if (!isValidEmail(value)) {
              return AppLocalizations.of(context)!.enterValidEmail;
            }
            return null;
          },
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
              errorBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors
                      .white, // Color of the underline when there is an error
                ),
              ),
              focusedErrorBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors
                      .white, // Color of the underline when there is an error and the field is focused
                ),
              ),
              errorStyle: TextStyle(
                color: Colors.white, // Color of the error message
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                    color: Colors
                        .white), // Color of the underline when the field is enabled
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                    color: Colors
                        .white), // Color of the underline when the field is focused
              ),
              hintStyle: TextStyle(color: Colors.white),
              hintText: _focusNodeEmail.hasFocus || email.isNotEmpty
                  ? ''
                  : AppLocalizations.of(context)!
                      .email, // Masquer le texte de l'indicateur en cas de focus
              prefixIcon: const Icon(
                Icons.email,
                color: Colors.white,
              )),
          style: TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 10),
        TextFormField(
          onFieldSubmitted: _onFieldSubmitted,
          cursorColor: Colors.white,
          controller: passwordController,
          focusNode: _focusNodePassword,
          onChanged: (value) {
            setState(() => password = value);
          },
          validator: (value) {
            if (value!.isEmpty) {
              return AppLocalizations.of(context)!.fieldRequired;
            }
            return null;
          },
          obscureText: securePassword,
          decoration: InputDecoration(
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  securePassword = !securePassword;
                });
              },
              icon: Icon(
                securePassword ? Icons.visibility : Icons.visibility_off,
                color: Colors.white,
              ),
            ),
            hintText: _focusNodePassword.hasFocus || password.isNotEmpty
                ? ''
                : AppLocalizations.of(context)!
                    .password, // Masquer le texte de l'indicateur en cas de focus
            hintStyle: TextStyle(color: Colors.white),
            prefixIcon: const Icon(
              Icons.password,
              color: Colors.white,
            ),
            errorBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors
                    .white, // Color of the underline when there is an error
              ),
            ),
            focusedErrorBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors
                    .white, // Color of the underline when there is an error and the field is focused
              ),
            ),
            errorStyle: TextStyle(
              color: Colors.white, // Color of the error message
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                  color: Colors
                      .white), // Color of the underline when the field is enabled
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                  color: Colors
                      .white), // Color of the underline when the field is focused
            ),
          ),
          style: TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 50),
        Container(
          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          width: 50,
          height: 50,
          child: ElevatedButton(
            onPressed: _handleLogin,
            style: ElevatedButton.styleFrom(
              shape: StadiumBorder(),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              backgroundColor: Colors.white,
            ),
            child: Text(
              AppLocalizations.of(context)!.login,
              style: TextStyle(
                  fontFamily: 'ProstoOne',
                  fontSize: 14,
                  color: Color.fromARGB(255, 22, 105, 161),
                  fontWeight: FontWeight.w900),
            ),
          ),
        ),
        SizedBox(
          height: 30,
        ),
        TextButton(
          onPressed: () {
            if (emailController.text.isEmpty ||
                !isValidEmail(emailController.text)) {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: Text("${AppLocalizations.of(context)!.invalidemail}"),
                        content: Text("${AppLocalizations.of(context)!.pleaseenteravalidemailaddress}"),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("${AppLocalizations.of(context)!.ok}",style: TextStyle(
                                color: Colors.blue
                              ),))
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
            "${AppLocalizations.of(context)!.sendmeacode}",
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'ProstoOne',
            ),
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

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      log(password + "," + email);
      setState(() {
        loading = true;
      });

      try {
        final isProd = await checkIsProd();
        final loginResponse = await loginAPI.loginUser(email, password, isProd);

        if (loginResponse.success) {
          _saveString('token', loginResponse.token.access_token);
          log("token: ${loginResponse.token.access_token}");
          final jwtResponse = await ApiGetJwt.getJwt();
          log("jwt: ${jwtResponse.jwtMercure}");
          _saveString('jwt', jwtResponse.jwtMercure);
          log("Uuid: ${jwtResponse.uuid}");
          _saveString("uuid", jwtResponse.uuid);

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
            title: Text("${AppLocalizations.of(context)!.authenticationproblem}"),
            contentPadding: EdgeInsets.all(20),
            content: Text(
              "${AppLocalizations.of(context)!.pleasecheckyourinformationorcontacttheadministrator} \n$e",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("${AppLocalizations.of(context)!.ok}"),
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
            title: Text("${AppLocalizations.of(context)!.authenticationproblem}"),
            contentPadding: EdgeInsets.all(20),
            content: Text(
             " ${AppLocalizations.of(context)!.pleasecheckyourinformationorcontacttheadministrator}\n$e",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("${AppLocalizations.of(context)!.ok}"),
              ),
            ],
          ),
        );
      }
    }
  }

  void _onFieldSubmitted(String value) async {
    await _handleLogin();
  }
}

// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unrelated_type_equality_checks, use_build_context_synchronously

import 'dart:developer';
import 'dart:ffi';
import 'dart:ui';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/providers/langue_provider.dart';
import 'package:flutter_application_stage_project/providers/theme_provider.dart';
import 'package:flutter_application_stage_project/screens/login_page.dart';
import 'package:flutter_application_stage_project/screens/settings/aPropos_page.dart';
import 'package:flutter_application_stage_project/screens/settings/activties_settings_page.dart';
import 'package:flutter_application_stage_project/screens/settings/affichage_page.dart';
import 'package:flutter_application_stage_project/screens/settings/compte/compte_page.dart';
import 'package:flutter_application_stage_project/screens/settings/confidentialite_page.dart';
import 'package:flutter_application_stage_project/screens/settings/indisponibilite_page.dart';
import 'package:flutter_application_stage_project/screens/settings/language.dart';
import 'package:flutter_application_stage_project/screens/settings/notifications_page.dart';
import 'package:flutter_application_stage_project/screens/settings/securite_page.dart';
import 'package:flutter_application_stage_project/services/ApiChangePassword.dart';
import 'package:flutter_application_stage_project/services/ApiLogout.dart';
import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../main.dart';
import '../../providers/NotificationProvider.dart';
import '../../services/MercureNotificationService.dart';
import '../NotficationPage.dart';
import '../homeNavigate_page.dart';
import '../loading.dart';
import 'changesLanguges_page.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> with WidgetsBindingObserver {
  late ThemeProvider themeProvider;
  late LangueProvider langueProvider;
  late Locale value;

  @override
  void initState() {
    super.initState();
    log("test initstate Activate Settings");
    themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    langueProvider = Provider.of<LangueProvider>(context, listen: false);
    langueProvider.addListener(_onLocaleChange);
    updateValueSelected(langueProvider.locale);
  }

  @override
  void dispose() {
    langueProvider.removeListener(_onLocaleChange);
    super.dispose();
  }

  void _onLocaleChange() {
    setState(() {
      updateValueSelected(langueProvider.locale);
    });
  }

  void updateValueSelected(Locale locale) {
    setState(() {
      valueSelected = locale.languageCode == 'fr'
          ? "Français"
          : locale.languageCode == "en"
              ? "English"
              : "العربية";
    });
  }

  void removeToken() async {
    await SharedPrefernce.removeData("token");
  }

  void removeUuid() async {
    await SharedPrefernce.removeData("uuid");
  }

  void removeJwt() async {
    await SharedPrefernce.removeData("jwt");
  }

  String valueSelected = '';
  Future<void>? _launched;
  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  bool notification = true;
  bool loading = true;

  @override
  Widget build(BuildContext context) {
    final Uri toLaunch = Uri(
        scheme: 'https',
        host: 'www.comunikcrm.com',
        path: 'confidentialite.html');
    log("la langage de systeme est  $valueSelected");
    log("la valuer dans langueProvider ${langueProvider.locale}");
    return Scaffold(
      backgroundColor:
          themeProvider.isDarkMode == true ? Colors.black : Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil<dynamic>(
              context,
              MaterialPageRoute<dynamic>(
                builder: (BuildContext context) => HomeNavigate(
                  id_page: 0,
                ),
              ),
              (route) =>
                  false, //if you want to disable back feature set to false
            );
          },
          icon: Icon(Icons.arrow_back_ios_new),
        ),
        title: Text(AppLocalizations.of(context).settings),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return NotificationPage();
                },
              ));
            },
            icon: Icon(
              Icons.notifications_none_sharp,
              size: 30,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        //padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(15),
              child: Text(
                AppLocalizations.of(context).account,
                style: Theme.of(context).textTheme.subtitle2,
              ),
            ), //Text(AppLocalizations.of(context).account)),
            Container(
              padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
              color: themeProvider.isDarkMode == true
                  ? Colors.black
                  : Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return ComptePage();
                        },
                      ));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              color: themeProvider.isDarkMode == false
                                  ? Colors.black
                                  : Colors.white,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              AppLocalizations.of(context).account,
                              style: Theme.of(context).textTheme.subtitle1,
                            )
                          ],
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.blue,
                          size: 15,
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          bool securePassword = true;
                          TextEditingController currentPassword =
                              TextEditingController();
                          TextEditingController newPassword =
                              TextEditingController();
                          TextEditingController PaswwordConfirmation =
                              TextEditingController();
                          Map<String, dynamic> data = {};
                          final _formKey = GlobalKey<FormState>();
                          return StatefulBuilder(
                            builder:
                                (BuildContext context, StateSetter setState) {
                              return AlertDialog(
                                scrollable: true,
                                title: Text(AppLocalizations.of(context)
                                    .changeYourPassword),
                                content: Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      TextFormField(
                                        controller: currentPassword,
                                        obscureText: securePassword,
                                        decoration: InputDecoration(
                                          suffixIcon: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                securePassword =
                                                    !securePassword;
                                              });
                                            },
                                            icon: Icon(securePassword == false
                                                ? Icons.visibility_off
                                                : Icons.visibility),
                                          ),
                                          labelText:
                                              AppLocalizations.of(context)
                                                  .currentPassword,
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return AppLocalizations.of(context)
                                                .pleaseEnterYourCurrentPassword;
                                          }
                                          return null;
                                        },
                                      ),
                                      SizedBox(height: 30),
                                      TextFormField(
                                        controller: newPassword,
                                        obscureText: securePassword,
                                        decoration: InputDecoration(
                                          suffixIcon: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                securePassword =
                                                    !securePassword;
                                              });
                                            },
                                            icon: Icon(securePassword == false
                                                ? Icons.visibility_off
                                                : Icons.visibility),
                                          ),
                                          labelText:
                                              AppLocalizations.of(context)
                                                  .newPassword,
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return AppLocalizations.of(context)
                                                .pleaseEnterYourNewPassword;
                                          }
                                          // Password validation regex
                                          String pattern =
                                              r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!;%*#?&^])[A-Za-z\d@$!;%*#?&^]{8,}$';
                                          RegExp regex = RegExp(pattern);

                                          if (!regex.hasMatch(value)) {
                                            return AppLocalizations.of(context)
                                                .passwordRequirements;
                                          }

                                          return null;
                                        },
                                      ),
                                      SizedBox(height: 30),
                                      TextFormField(
                                        controller: PaswwordConfirmation,
                                        obscureText: securePassword,
                                        decoration: InputDecoration(
                                          suffixIcon: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                securePassword =
                                                    !securePassword;
                                              });
                                            },
                                            icon: Icon(securePassword == false
                                                ? Icons.visibility_off
                                                : Icons.visibility),
                                          ),
                                          labelText:
                                              AppLocalizations.of(context)
                                                  .passwordConfirmation,
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return AppLocalizations.of(context)
                                                .pleaseConfirmYourNewPassword;
                                          }
                                          if (value != newPassword.text) {
                                            return AppLocalizations.of(context)
                                                .passwordConfirmationDoesNotMatch;
                                          }
                                          // Password validation regex
                                          String pattern =
                                              r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!;%*#?&^])[A-Za-z\d@$!;%*#?&^]{8,}$';
                                          RegExp regex = RegExp(pattern);

                                          if (!regex.hasMatch(value)) {
                                            return AppLocalizations.of(context)
                                                .passwordRequirements;
                                          }

                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(true);
                                      // User confirmed deletion
                                    },
                                    child: Text(AppLocalizations.of(context)
                                        .returnlabel),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        if (newPassword.text ==
                                            PaswwordConfirmation.text) {
                                          data['old_password'] =
                                              currentPassword.text;
                                          data['new_password'] =
                                              newPassword.text;
                                          data['new_password_confirmation'] =
                                              PaswwordConfirmation.text;
                                          log(data.toString());

                                          try {
                                            final postPassword =
                                                await ApiChangePasword
                                                    .ChangePassword(data);
                                            if (postPassword == 200) {
                                              // Si la réponse de l'API est 200, procédez normalement
                                              removeToken();
                                              Navigator.pushNamedAndRemoveUntil(
                                                context,
                                                '/login',
                                                (route) => false,
                                              );
                                            } else {
                                              // Si la réponse de l'API n'est pas 200, affichez une erreur
                                              Navigator.of(context).pop();
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: Text("Error"),
                                                    content: Text(AppLocalizations
                                                            .of(context)
                                                        .failedToChangePassword),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Text("OK"),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            }
                                          } catch (e) {
                                            // Gérez les erreurs ici, par exemple, affichez une boîte de dialogue avec le message d'erreur
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: Text("Error"),
                                                  content: Text(
                                                      "An error occurred: $e"),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Text("OK"),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          }
                                        } else {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: Text("Error"),
                                                content: Text(AppLocalizations
                                                        .of(context)
                                                    .pleaseConfirmYourNewPassword),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Text("OK"),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        }
                                      }
                                    },
                                    child:
                                        Text(AppLocalizations.of(context).save),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.security,
                              color: themeProvider.isDarkMode == false
                                  ? Colors.black
                                  : Colors.white,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              AppLocalizations.of(context).changeYourPassword,
                              style: Theme.of(context).textTheme.subtitle1,
                            )
                          ],
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.blue,
                          size: 15,
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  GestureDetector(
                    onTap: () async {
                      _launched = _launchInBrowser(toLaunch);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lock_person_rounded,
                              color: themeProvider.isDarkMode == false
                                  ? Colors.black
                                  : Colors.white,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              AppLocalizations.of(context).confidentiality,
                              style: Theme.of(context).textTheme.subtitle1,
                            )
                          ],
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.blue,
                          size: 15,
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(15),
              child: Text(
                AppLocalizations.of(context).contentanddisplay,
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
              color: themeProvider.isDarkMode == true
                  ? Colors.black
                  : Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return NotificationsPage();
                        },
                      ));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.notifications_sharp,
                              color: themeProvider.isDarkMode == false
                                  ? Colors.black
                                  : Colors.white,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              AppLocalizations.of(context).notifications,
                              style: Theme.of(context).textTheme.subtitle1,
                            )
                          ],
                        ),
                        Consumer<NotificationProvider>(
                          builder: (context, notifier, _) => CupertinoSwitch(
                            activeColor: Colors.blue,
                            value: notifier.notification,
                            onChanged: (value) {
                              if (value == true) {
                                MercureNotificationService().initialize();
                              } else {
                                MercureNotificationService().dispose();
                              }
                              notifier.notification = value;
                              log(value.toString());
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return ChangeLangugePage();
                        },
                      ));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.language_outlined,
                              color: themeProvider.isDarkMode == false
                                  ? Colors.black
                                  : Colors.white,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              AppLocalizations.of(context).languages,
                              style: Theme.of(context).textTheme.subtitle1,
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Text(valueSelected),
                            SizedBox(
                              width: 5,
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.blue,
                              size: 15,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return Affichage();
                        },
                      ));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.nightlight_sharp,
                              color: themeProvider.isDarkMode == false
                                  ? Colors.black
                                  : Colors.white,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              AppLocalizations.of(context).display,
                              style: Theme.of(context).textTheme.subtitle1,
                            )
                          ],
                        ),
                        CupertinoSwitch(
                          activeColor: Colors.blue,
                          value: themeProvider.isDarkMode,
                          onChanged: (value) {
                            setState(() {
                              themeProvider.toggleTheme();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(15),
              child: Text(
                AppLocalizations.of(context).connection,
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
              color: themeProvider.isDarkMode == true
                  ? Colors.black
                  : Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () async {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Disconnect"),
                            content: Text("Do you really want to disconnect?"),
                            actions: [
                              ElevatedButton(
                                onPressed: () async {
                                  try {
                                    log("logout");
                                    final logoutResponse =
                                        await ApiLogout.logOut();
                                    if (logoutResponse == "Logout successful") {
                                      removeToken();
                                      removeUuid();
                                      removeJwt();
                                      MercureNotificationService().dispose();
                                      Navigator.pushNamedAndRemoveUntil(
                                          context, '/login', (route) => false);
                                    }
                                  } catch (e) {
                                    print("problem de logout $e");
                                  }
                                },
                                child: Text("Yes"),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(false); // User cancelled deletion
                                },
                                child: Text("No"),
                              )
                            ],
                          );
                        },
                      );

                      /*
                      try {
                        log("logout");
                        final logoutResponse = await ApiLogout.logOut();
                        if (logoutResponse == "Logout successful") {
                          removeToken();
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/login', (route) => false);
                        }
                      } catch (e) {
                        print("problem de logout $e");
                      }
                      */
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.logout_outlined,
                              color: themeProvider.isDarkMode == false
                                  ? Colors.black
                                  : Colors.white,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              AppLocalizations.of(context).disconnect,
                              style: Theme.of(context).textTheme.subtitle1,
                            )
                          ],
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.blue,
                          size: 15,
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 70,
            )
          ],
        ),
      ),
    );
  }
}

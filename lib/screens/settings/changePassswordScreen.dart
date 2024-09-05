import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/services/ApiChangePassword.dart'; // Importez le service correspondant
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool securePassword = true;
  TextEditingController currentPassword = TextEditingController();
  TextEditingController newPassword = TextEditingController();
  TextEditingController passwordConfirmation = TextEditingController();
  Map<String, dynamic> data = {};
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      if (newPassword.text == passwordConfirmation.text) {
        setState(() {
          isLoading = true;
        });

        data['old_password'] = currentPassword.text;
        data['new_password'] = newPassword.text;
        data['new_password_confirmation'] = passwordConfirmation.text;

        try {
          final postPassword = await ApiChangePassword.changePassword(data);
          if (postPassword == 200) {
            // Si la réponse de l'API est 200, procédez normalement
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          } else {
            // Show error message via SnackBar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.failedToChangePassword),
                backgroundColor: Colors.red,
              ),
            );
          }
        } catch (e) {
          // Show error message via SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("An error occurred: $e"),
              backgroundColor: Colors.red,
            ),
          );
        } finally {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        // Show error message via SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.pleaseConfirmYourNewPassword),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
          ? Scaffold(
            body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.blue, // Couleur du CircularProgressIndicator
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading, please wait...',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
              ),
          )
          :  Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.changeYourPassword),
      ),
      body:  Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 40,),
                    TextFormField(
                      controller: currentPassword,
                      obscureText: securePassword,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        fillColor: Colors.grey.shade200,
                        filled: true,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              securePassword = !securePassword;
                            });
                          },
                          icon: Icon(securePassword
                              ? Icons.visibility
                              : Icons.visibility_off),
                        ),
                        hintText: AppLocalizations.of(context)!.currentPassword,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!
                              .pleaseEnterYourCurrentPassword;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 40),
                    TextFormField(
                      controller: newPassword,
                      obscureText: securePassword,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        fillColor: Colors.grey.shade200,
                        filled: true,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              securePassword = !securePassword;
                            });
                          },
                          icon: Icon(securePassword
                              ? Icons.visibility
                              : Icons.visibility_off),
                        ),
                        hintText: AppLocalizations.of(context)!.newPassword,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!
                              .pleaseEnterYourNewPassword;
                        }
                        // Password validation regex
                        String pattern =
                            r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!;%*#?&^])[A-Za-z\d@$!;%*#?&^]{8,}$';
                        RegExp regex = RegExp(pattern);

                        if (!regex.hasMatch(value)) {
                          return AppLocalizations.of(context)!
                              .passwordRequirements;
                        }

                        return null;
                      },
                    ),
                    SizedBox(height: 40),
                    TextFormField(
                      controller: passwordConfirmation,
                      obscureText: securePassword,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        fillColor: Colors.grey.shade200,
                        filled: true,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              securePassword = !securePassword;
                            });
                          },
                          icon: Icon(securePassword
                              ? Icons.visibility
                              : Icons.visibility_off),
                        ),
                        hintText: AppLocalizations.of(context)!.passwordConfirmation,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!
                              .pleaseConfirmYourNewPassword;
                        }
                        if (value != newPassword.text) {
                          return AppLocalizations.of(context)!
                              .passwordConfirmationDoesNotMatch;
                        }
                        // Password validation regex
                        String pattern =
                            r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!;%*#?&^])[A-Za-z\d@$!;%*#?&^]{8,}$';
                        RegExp regex = RegExp(pattern);

                        if (!regex.hasMatch(value)) {
                          return AppLocalizations.of(context)!
                              .passwordRequirements;
                        }

                        return null;
                      },
                    ),
                    SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: StadiumBorder(),
                            padding: EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: _handleSubmit,
                          child: Text(AppLocalizations.of(context)!.save),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

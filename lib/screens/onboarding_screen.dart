// ignore_for_file: prefer_const_literals_to_create_immutables

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_stage_project/intro_screens/intro_page_1.dart';
import 'package:flutter_application_stage_project/intro_screens/intro_page_2.dart';
import 'package:flutter_application_stage_project/intro_screens/intro_page_3.dart';
import 'package:flutter_application_stage_project/providers/theme_provider.dart';
import 'package:flutter_application_stage_project/screens/urlPage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../main.dart';
import 'login_page.dart';
import '../../models/ticket/ticket.dart';
import '../../models/ticket/ticketData.dart';
import '../../services/tickets/getTicketApi.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  late ThemeProvider themeProvider;
  PageController _controller = PageController();
  bool onLastPage = false;
  bool isSystemThemeDark = false; // Initialize here
  bool isFirstBuild = true;
  List<TicketData> tickets = [];

  @override
  void initState() {
    super.initState();
    themeProvider = Provider.of<ThemeProvider>(context, listen: false);
  }

  Future<void> markOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(onboardingCompletedKey, true);
  }

  @override
  Widget build(BuildContext context) {
    log('la  valeur de isdark dans build onBordingScrren  ==== ${themeProvider.isDarkMode}');
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                onLastPage = (index == 2);
              });
            },
            children: [
              IntroPage1(),
              IntroPage2(),
              IntroPage3(),
            ],
          ),
          Container(
            alignment: Alignment(0, 0.75),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    _controller.jumpToPage(2);
                  },
                  child: Text(
                    AppLocalizations.of(context).skip,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: themeProvider.isDarkMode == true
                          ? Colors.white
                          : Colors.blue,
                    ),
                  ),
                ),
                SmoothPageIndicator(controller: _controller, count: 3),
                onLastPage
                    ? GestureDetector(
                        onTap: () async {
                          await markOnboardingComplete();
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (context) =>
                                    UrlPage()), // Replace with your main screen
                          );
                        },
                        child: Text(
                          AppLocalizations.of(context).done,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: themeProvider.isDarkMode == true
                                ? Colors.white
                                : Colors.blue,
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTap: () {
                          _controller.nextPage(
                            duration: Duration(microseconds: 500),
                            curve: Curves.bounceIn,
                          );
                        },
                        child: Text(
                          AppLocalizations.of(context).next,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: themeProvider.isDarkMode == true
                                ? Colors.white
                                : Colors.blue,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

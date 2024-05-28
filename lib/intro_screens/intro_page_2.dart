// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class IntroPage2 extends StatefulWidget {
  const IntroPage2({super.key});

  @override
  State<IntroPage2> createState() => _IntroPage2State();
}

class _IntroPage2State extends State<IntroPage2> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/undraw_undraw_undraw_undraw_undraw_undraw_completion_progress_1oxr_gag2_-1-_0h44_-1-_vov5_-1-_wbt2_(1)_fu4s.png',
        ),
        /*
        LottieBuilder.network(
            "https://lottie.host/733c2bef-77f6-46cc-825a-40a99f75b9c2/OvJNIiqfXL.json"),
            */
        Text('Page 2'),
      ],
    ));
  }
}

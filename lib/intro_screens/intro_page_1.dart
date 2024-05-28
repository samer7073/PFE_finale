// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class IntroPage1 extends StatefulWidget {
  const IntroPage1({super.key});

  @override
  State<IntroPage1> createState() => _IntroPage1State();
}

class _IntroPage1State extends State<IntroPage1> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Image.asset(
        'assets/undraw_sign_up_ln1s.png',
      ),
      /*
      Lottie.network(
          "https://lottie.host/3760c715-3788-43ff-bbd1-32b6dd1bb796/9H8xECNCPh.json"),
          */
      Text("Page 1")
    ]));
  }
}

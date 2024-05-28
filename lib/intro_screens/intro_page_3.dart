// ignore_for_file: prefer_const_constructors
import 'package:lottie/lottie.dart';

import 'package:flutter/material.dart';

class IntroPage3 extends StatefulWidget {
  const IntroPage3({super.key});

  @override
  State<IntroPage3> createState() => _IntroPage3State();
}

class _IntroPage3State extends State<IntroPage3> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/undraw_undraw_undraw_undraw_undraw_undraw_undraw_undraw_calling_mcgf_gyrw_2jtb_-1-_eb38_-1-_fikj_5ef3_-1-_b52m_(1)_7noa.png',
        ),
        /*
        LottieBuilder.network(
            "https://lottie.host/8155de52-c265-44a3-bcee-ee95423b844d/It5G3sUaxe.json"),
            */
        Text("Page 3"),
      ],
    ));
  }
}

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
          'assets/undraw_Modern_design_re_dlp8.png',
        ),
        /*
        LottieBuilder.network(
            "https://lottie.host/733c2bef-77f6-46cc-825a-40a99f75b9c2/OvJNIiqfXL.json"),
            */
        Text(
          "Efficiently manage your activities",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          "Optimize your helpdesk support.",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          "Master your projects",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        SizedBox(
          height: 10,
        ),
      ],
    ));
  }
}

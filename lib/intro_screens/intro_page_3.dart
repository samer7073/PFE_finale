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
          'assets/undraw_New_ideas_re_asn4.png',
        ),
        /*
        LottieBuilder.network(
            "https://lottie.host/8155de52-c265-44a3-bcee-ee95423b844d/It5G3sUaxe.json"),
            */
        Text(
          "Ready to get started?",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          "Explore our features.",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          "Sign up today!",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        SizedBox(
          height: 10,
        ),
      ],
    ));
  }
}

// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

class IntroPage3 extends StatefulWidget {
  const IntroPage3({super.key});

  @override
  State<IntroPage3> createState() => _IntroPage3State();
}

class _IntroPage3State extends State<IntroPage3> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Image de fond
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  'assets/Onbordingscreen3.png'), // Chemin vers votre image de fond
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Contenu de la page
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 400,
              ),
              Text(
                "Ready to get started?",
                style: TextStyle(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  fontSize: 20.55,

                  fontFamily: 'ProstoOne', // Use the "Prosto One" font
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text("Explore our features.",
                  style: TextStyle(
                      fontFamily: 'ProstoOne',
                      color: Color.fromARGB(255, 216, 208, 208))),
              SizedBox(
                height: 10,
              ),
              Text("Sign up today!",
                  style: TextStyle(
                      fontFamily: 'ProstoOne',
                      color: Color.fromARGB(255, 216, 208, 208))),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

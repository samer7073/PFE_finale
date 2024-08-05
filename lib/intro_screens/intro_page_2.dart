// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

class IntroPage2 extends StatefulWidget {
  const IntroPage2({super.key});

  @override
  State<IntroPage2> createState() => _IntroPage2State();
}

class _IntroPage2State extends State<IntroPage2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Image en arrière-plan
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/Onbordingscreen.png'), // Remplacez par le chemin de votre image
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Contenu de l'écran
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 300,
                ),
                Text(
                  "Efficiently manage your activities",
                  style: TextStyle(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    fontSize: 20.55,

                    fontFamily: 'ProstoOne', // Use the "Prosto One" font
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text("Optimize your helpdesk support.",
                    style: TextStyle(
                        fontFamily: 'ProstoOne',
                        color: Color.fromARGB(255, 216, 208, 208))),
                SizedBox(
                  height: 10,
                ),
                Text("Master your projects",
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
      ),
    );
  }
}

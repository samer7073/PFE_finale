// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

class IntroPage1 extends StatefulWidget {
  const IntroPage1({super.key});

  @override
  State<IntroPage1> createState() => _IntroPage1State();
}

class _IntroPage1State extends State<IntroPage1> {
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
                    'assets/Frame 1618868070.png'), // Remplacez par le chemin de votre image
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
                  height: 320,
                ),
                const Text(
                  "Welcome to Sphere Comunik!",
                  style: TextStyle(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    fontSize: 20.55,

                    fontFamily: 'ProstoOne', // Use the "Prosto One" font
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text("Manage all your activities",
                    style: TextStyle(
                        fontFamily: 'ProstoOne',
                        color: Color.fromARGB(255, 216, 208, 208))),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Simplify your projects, deals and tickets",
                  style: TextStyle(
                      fontFamily: 'ProstoOne',
                      color: Color.fromARGB(255, 216, 208, 208)),
                ),
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

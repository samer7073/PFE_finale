// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class MyThemes {
  static final lightTheme = ThemeData(
    tabBarTheme: TabBarTheme(
      labelColor: Colors.black,
      unselectedLabelColor: Colors.black,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(
            width: 4.0,
            color: Color.fromARGB(
                255, 41, 93, 235)), // Couleur et épaisseur de la ligne
      ),
    ),

    cardTheme: CardTheme(
      color: Colors.white,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 66, 115, 231),
        shape: CircleBorder(
          eccentricity: 0.9,
        )),
    dropdownMenuTheme: DropdownMenuThemeData(
      inputDecorationTheme: InputDecorationTheme(
          outlineBorder: BorderSide.none,
          border: InputBorder.none,
          iconColor: Colors.purple,
          suffixIconColor: Colors.purple),
    ),
    textTheme: TextTheme(
      headline1: TextStyle(
          fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black),
      headline2: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      bodyText1: TextStyle(
          fontSize: 16, color: Colors.black), // Your custom body text style
      bodyText2: TextStyle(fontSize: 14, color: Colors.grey),
      subtitle1: TextStyle(fontSize: 16, color: Colors.black),
      subtitle2: TextStyle(fontSize: 14, color: Colors.grey),
      button: TextStyle(fontSize: 16, color: Colors.white),
      caption: TextStyle(fontSize: 12, color: Colors.grey),
      overline: TextStyle(fontSize: 10, color: Colors.grey),
    ),
    primaryColor: Colors.white,
    colorScheme: ColorScheme.light(),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedIconTheme: IconThemeData(color: Color.fromARGB(255, 58, 52, 232)),
      unselectedIconTheme: IconThemeData(color: Colors.black),
      unselectedItemColor: Colors.black,
      selectedItemColor: Color.fromARGB(255, 38, 55, 245),
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Color.fromARGB(255, 244, 245, 247),
      titleTextStyle:
          TextStyle(color: Color.fromARGB(255, 57, 123, 245), fontSize: 22),
      iconTheme: IconThemeData(color: Color.fromARGB(255, 41, 93, 235)),
    ),

    //useMaterial3: true,
    drawerTheme: const DrawerThemeData(
      shadowColor: Colors.deepPurple,
      backgroundColor: Colors.purple,
    ),
  );

  static final darkTheme = ThemeData(
    cardTheme: CardTheme(
      color: Colors.black,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.blue,
        shape: CircleBorder(
          eccentricity: 0.9,
        )),
    dropdownMenuTheme: DropdownMenuThemeData(
      inputDecorationTheme: InputDecorationTheme(
          outlineBorder: BorderSide.none,
          border: InputBorder.none,
          iconColor: Colors.blue,
          suffixIconColor: Colors.blue),
    ),
    textTheme: TextTheme(
      headline1: TextStyle(
          fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
      headline2: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      headline3: TextStyle(fontSize: 16, color: Colors.black),
      bodyText1: TextStyle(
          fontSize: 16, color: Colors.white), // Your custom body text style
      bodyText2: TextStyle(fontSize: 14, color: Colors.grey),
      subtitle1: TextStyle(fontSize: 16, color: Colors.white),
      subtitle2: TextStyle(fontSize: 14, color: Colors.grey),
      button: TextStyle(fontSize: 16, color: Colors.white),
      caption: TextStyle(fontSize: 12, color: Colors.grey),
      overline: TextStyle(fontSize: 10, color: Colors.grey),
    ),
    primaryColor: Colors.black,
    colorScheme: ColorScheme.dark(),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedIconTheme: IconThemeData(color: Colors.blue),
      unselectedIconTheme: IconThemeData(color: Colors.white),
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 22),
      iconTheme: IconThemeData(color: Colors.blue),
    ),
    // Utilisation de ThemeData.dark().copyWith() pour créer un thème sombre à partir du thème par défaut
    scaffoldBackgroundColor: Colors.black,
    textSelectionTheme: const TextSelectionThemeData(
      selectionColor: Colors.white,
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: Colors.black,
      shadowColor: Colors.black,
    ),
    shadowColor: Colors.black,
  );
}

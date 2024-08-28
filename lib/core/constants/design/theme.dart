import 'package:flutter/material.dart';

class MyThemes {
  static final lightTheme = ThemeData(
    useMaterial3: false,
    tabBarTheme: TabBarTheme(
      labelColor: Colors.black,
      unselectedLabelColor: Colors.black,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(
          width: 4.0,
          color: Color.fromARGB(255, 41, 93, 235), // Couleur de la sous-ligne du Tab
        ),
      ),
      dividerColor: Colors.transparent, // Supprimer la ligne grise sous le TabBar
    ),
    cardTheme: CardTheme(
      color: Colors.white,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 0,
      backgroundColor: Color.fromARGB(255, 66, 115, 231),
      shape: CircleBorder(eccentricity: 0.9),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      inputDecorationTheme: InputDecorationTheme(
        outlineBorder: BorderSide.none,
        border: InputBorder.none,
        iconColor: Colors.blue,
        suffixIconColor:  Colors.blue,
      ),
    ),
    textTheme: TextTheme(
      displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(fontSize: 14, color: Colors.grey),
      headlineSmall: TextStyle(fontSize: 16, color: Colors.black),
      headlineLarge: TextStyle(fontSize: 16, color: Colors.black),
      headlineMedium: TextStyle(fontSize: 14, color: Colors.grey),
    ),
    primaryColor: Colors.white,
    colorScheme: ColorScheme.light(
      error: Colors.red,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedIconTheme: IconThemeData(color: Colors.blue),
      unselectedIconTheme: IconThemeData(color: Colors.black),
      unselectedItemColor: Colors.black,
      selectedItemColor: Colors.blue,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: Color.fromARGB(255, 244, 245, 247), // Couleur de fond de l'AppBar
      titleTextStyle: TextStyle(
        color: Color.fromARGB(255, 57, 123, 245),
        fontSize: 22,
      ),
      iconTheme: IconThemeData(
        color: Color.fromARGB(255, 41, 93, 235),
      ),
      shadowColor: Colors.transparent, // Supprimer l'ombre sous l'AppBar
    ),
    
    dividerColor: Colors.transparent, // Supprimer les lignes diviseurs globales
  );

  static final darkTheme = ThemeData(
    useMaterial3: false,
    cardTheme: CardTheme(
      color: Colors.black,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.blue,
      shape: CircleBorder(eccentricity: 0.9),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      inputDecorationTheme: InputDecorationTheme(
        outlineBorder: BorderSide.none,
        border: InputBorder.none,
        iconColor: Colors.blue,
        suffixIconColor: Colors.blue,
      ),
    ),
    textTheme: TextTheme(
      headlineSmall: TextStyle(fontSize: 16, color: Colors.white),
      headlineLarge: TextStyle(fontSize: 16, color: Colors.white),
      headlineMedium: TextStyle(fontSize: 14, color: Colors.grey),
      displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(fontSize: 14, color: Colors.black),
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
      shadowColor: Colors.transparent, // Supprimer l'ombre sous l'AppBar en mode sombre
    ),
    scaffoldBackgroundColor: Colors.black,
    textSelectionTheme: const TextSelectionThemeData(
      selectionColor: Colors.white,
    ),
   
    dividerColor: Colors.transparent, // Supprimer les lignes diviseurs globales en mode sombre
    shadowColor: Colors.black,
    
  );
}

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
          iconColor: const Color.fromARGB(255, 78, 39, 176),
          suffixIconColor: const Color.fromARGB(255, 62, 39, 176)),
    ),
    textTheme: TextTheme(
      
       displayMedium:TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
       displaySmall: TextStyle(fontSize: 14, color: Colors.grey),
       headlineSmall:TextStyle(fontSize: 16, color: Colors.white), 
       headlineLarge: TextStyle(
          fontSize: 16, color: Colors.black),
        headlineMedium:TextStyle(fontSize: 14, color: Colors.grey)
        
       
   
      
    
   
      
     
     
    ),
    primaryColor: Colors.white,
    colorScheme: ColorScheme.light(
      error: Colors.red
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
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Color.fromARGB(255, 244, 245, 247),
      titleTextStyle:
          TextStyle(color: Color.fromARGB(255, 57, 123, 245), fontSize: 22),
      iconTheme: IconThemeData(color: Color.fromARGB(255, 41, 93, 235)),
    ),

    //useMaterial3: true,
    drawerTheme: const DrawerThemeData(
      shadowColor: Color.fromARGB(255, 58, 77, 183),
      backgroundColor: Color.fromARGB(255, 39, 53, 176),
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
      headlineSmall:TextStyle(fontSize: 16, color: Colors.white), 
      headlineLarge: TextStyle(
          fontSize: 16, color: Colors.white),
      headlineMedium:TextStyle(fontSize: 14, color: Colors.grey), 
      displayMedium:TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(fontSize: 14, color: Colors.grey),
     
      
    
     
    
     
      
      
      
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

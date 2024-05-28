// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;
  final Function()? onTap;
  final Color backgroundColor;
  final Color textColor;

  const MyButton({
    super.key,
    required this.onTap,
    required this.text,
    this.backgroundColor = Colors.blue,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        backgroundColor: backgroundColor, // Removed MaterialStateProperty.all
        foregroundColor: textColor,     // Removed MaterialStateProperty.all
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

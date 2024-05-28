// ignore_for_file: prefer_const_constructors

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.purple[100],
      child: Center(
        child: const SpinKitCircle(
          color: Colors.white,
          size: 100.0,
        ),
      ),
    );
  }
}

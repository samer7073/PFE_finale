import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String filename;
  const UserAvatar({
    Key? key,
    required this.filename,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: Colors.white,
      child: CircleAvatar(
        backgroundImage: Image.asset('assets/$filename').image,
        radius: 18,
      ),
    );
  }
}

import 'package:flutter/material.dart';

class containerDashbored extends StatelessWidget {
  const containerDashbored({
    super.key,
    required this.tiltle,
    required this.totale,
    required this.text1,
    required this.nbText1,
    required this.text2,
    required this.nbText2,
  });

  final String tiltle;
  final String totale;
  final String text1;
  final String nbText1;
  final String text2;
  final String nbText2;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
          color: Color.fromARGB(255, 247, 237, 249),
          borderRadius: BorderRadius.circular(10)),
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.all(20),
      width: double.infinity,
      child: Column(children: [
        Text(
          tiltle,
          style: TextStyle(
              fontSize: 24, color: Colors.black, fontWeight: FontWeight.w700),
        ),
        SizedBox(
          height: 20,
        ),
        Text(
          totale,
          style: TextStyle(fontSize: 24, color: Colors.grey),
        ),
        SizedBox(
          height: 30,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text(
                  text1,
                  style: TextStyle(
                      color: Colors.green,
                      fontSize: 20,
                      fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  nbText1,
                  style: TextStyle(color: Colors.green, fontSize: 20),
                )
              ],
            ),
            Column(
              children: [
                Text(
                  text2,
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                      fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  nbText2,
                  style: TextStyle(color: Colors.red, fontSize: 20),
                )
              ],
            ),
          ],
        )
      ]),
    );
  }
}

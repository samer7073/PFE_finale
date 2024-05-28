import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Otp extends StatelessWidget {
  const Otp({super.key});

  @override
  Widget build(BuildContext context) {
    TextStyle otpTextStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: Colors.black,
    );

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: SizedBox(
        height: 68,
        width: 35,
        child: TextFormField(
          onChanged: (value) {
            if (value.length == 1) {
              FocusScope.of(context).nextFocus();
            }
          },
          onSaved: (pin1) {},
          decoration: InputDecoration(
            hintText: "0",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            fillColor: Colors.purple.withOpacity(0.1),
            filled: true,
          ),
          style: otpTextStyle,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          inputFormatters: [
            LengthLimitingTextInputFormatter(1),
            FilteringTextInputFormatter.digitsOnly,
          ],
        ),
      ),
    );
  }
}

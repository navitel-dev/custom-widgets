import 'package:flutter/material.dart';

class StyleCircle {
  ButtonStyle giveStyle(double radius) {
    return ButtonStyle(
      minimumSize: MaterialStateProperty.all(
          const Size(double.infinity, double.infinity)),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radius)),
        ),
      ),
      foregroundColor: MaterialStateProperty.all(Colors.grey.withOpacity(0.5)),
      surfaceTintColor: MaterialStateProperty.all(Colors.grey.withOpacity(0.5)),
      shadowColor: MaterialStateProperty.all(Colors.grey.withOpacity(0.5)),
    );
  }
}

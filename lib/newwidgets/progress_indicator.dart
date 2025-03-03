import 'package:flutter/material.dart';

Color getColor(double value) {
  if (value >= 80.0) {
    return Colors.redAccent; // Low level
  } else if (value >= 50.0) {
    return Colors.orangeAccent; // Medium level
  } else {
    return Colors.lightGreen; // High level
  }
}

@override
Widget progrseIndicator(double val) {
  // if (val == null)
  //   return Container();
  // else
  return Container(
    width: 300,
    height: 40,
    child: LinearProgressIndicator(
      value: val / 100, // Normalize between 0 and 1
      backgroundColor: Colors.grey.shade300,
      valueColor: AlwaysStoppedAnimation<Color>(
        getColor(val),
      ),
    ),
  );
}

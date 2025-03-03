import 'package:flutter/material.dart';

class MyRowWidget extends StatelessWidget {
  final String dat1, dat2;

  const MyRowWidget({super.key, required this.dat1, required this.dat2});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [Text(dat1), Text(dat2)],
      ),
    );
  }
}

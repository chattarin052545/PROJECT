import 'package:flutter/material.dart';

class CardWidget extends StatelessWidget {
  final String title;
  final Color color;

  const CardWidget({Key? key, required this.title, required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(40, 10, 40, 10.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.purple, width: 1.5),
        // border: Border.all(color: Colors.grey.shade300, width: 1.5),
        borderRadius: BorderRadius.circular(15.0),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 6,
            offset: Offset(0, 4), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "ข้อมูลการดูดจุกนม:",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                // color: Colors.blueAccent,
                color: Colors.black),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // _buildDataCard(title, Colors.green),
              _buildDataCard(title, Colors.red),
            ],
          ),
          // const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // _buildDataCard("Average", Colors.orange),
              // _buildDataCard("Count", Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataCard(String title, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            // const SizedBox(height: 8),
            // Text(
            //   value.toStringAsFixed(2),
            //   style: const TextStyle(
            //     fontSize: 18,
            //     fontWeight: FontWeight.bold,
            //     color: Colors.black87,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

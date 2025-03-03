import 'package:flutter/material.dart';

Widget durationOption(
    List<int> durations, int selected, Function onDurationSelected) {
  return Container(
    margin: const EdgeInsets.fromLTRB(40, 00, 40, 00.0),
    padding: const EdgeInsets.all(16),
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
        Text(
          "เลือกเวลา : $selected วินาที",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: durations.map((duration) {
            return ElevatedButton(
              onPressed: () {
                onDurationSelected(duration);
                selected = duration;
              },
              child: Text(
                "$duration",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    duration == selected ? Colors.blue : Colors.grey.shade200,
                foregroundColor: duration == selected
                    ? Colors.white
                    : Colors.black87, // Text color
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }).toList(),
        ),
        /*
        Wrap(
          spacing: 8.0, // Space between buttons
          runSpacing: 4.0, // Space between rows
          children: durations.map((duration) {
            return ElevatedButton(
              onPressed: () {
                onDurationSelected(duration);
                selected = duration;
              },
              child: Text(
                "$duration",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    duration == selected ? Colors.green : Colors.grey,
              ),
            );
          }).toList(),
        )*/
        //
      ],
    ),
  );
  // return Text('xxx');
}

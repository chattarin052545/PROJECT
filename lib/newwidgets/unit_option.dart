import 'package:flutter/material.dart';

Widget unitOption(
    List<String> units, int selectedIndex, Function onUnitSelected) {
  return Container(
    margin: const EdgeInsets.fromLTRB(40, 0, 40, 0.0),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.purple, width: 1.5),
      borderRadius: BorderRadius.circular(15.0),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          spreadRadius: 2,
          blurRadius: 6,
          offset: const Offset(0, 4), // Adjusts shadow position
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "เลือกหน่วย: ${units[selectedIndex]}",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: units.asMap().entries.map((entry) {
            int index = entry.key;
            String unit = entry.value;
            return ElevatedButton(
              onPressed: () {
                selectedIndex = index;
                onUnitSelected(selectedIndex);
              },
              child: Text(
                unit,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedIndex == index
                    ? Colors.blue // Highlighted color
                    : Colors.grey.shade200, // Default button color
                foregroundColor: selectedIndex == index
                    ? Colors.white
                    : Colors.black87, // Text color
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: selectedIndex == index ? 4 : 1, // Dynamic elevation
              ),
            );
          }).toList(),
        ),
      ],
    ),
  );
}


/*
Widget unitOption(
    List<String> units, int selectedIndex, Function onUnitSelected) {
  // int newSelected = selected;
  return Container(
    // margin: const EdgeInsets.all(16.0),
    margin: const EdgeInsets.fromLTRB(40, 00, 40, 00.0),
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(15.0),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 2,
          blurRadius: 5,
          offset: Offset(0, 3), // changes position of shadow
        ),
      ],
    ),
    child: Column(
      children: [
        Text(
          "หน่วย : ${units[selectedIndex]} ",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: units.map((unit) {
            return ElevatedButton(
              onPressed: () {
                selectedIndex = units.indexOf(unit);
                onUnitSelected(selectedIndex);

                // onDurationSelected(duration);
                // selected = duration;
              },
              child: Text(
                unit,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                  // backgroundColor:
                  // duration == selected ? Colors.green : Colors.grey,
                  ),
            );
          }).toList(),
        ),
      ],
    ),
  );
}
*/
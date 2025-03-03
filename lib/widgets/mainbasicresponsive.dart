import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Responsive Scrollable Example")),
        body: ScrollableContent(),
      ),
    );
  }
}

class ScrollableContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Button
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.02,
            ),
            child: ElevatedButton(
              onPressed: () {},
              child: Text("Button"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(screenWidth * 0.8, 50), // Responsive width
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),

          // Text
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: Text(
              "Sample Text",
              style: TextStyle(fontSize: screenWidth * 0.05), // Responsive font
            ),
          ),
          SizedBox(height: screenHeight * 0.02),

          // ListView with fixed height
          Container(
            height: screenHeight *
                0.25, // Set height as a fraction of screen height
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: 20,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: ListTile(
                    title: Text(
                      "List m Item $index",
                      style: TextStyle(fontSize: screenWidth * 0.045),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: screenHeight * 0.02),

          // Wide Chart with horizontal scroll
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              width: screenWidth *
                  1.5, // Set width as a fraction of screen width for horizontal scroll
              height: screenHeight * 0.4,
              color: Colors.blueAccent,
              child: Center(
                child: Text(
                  "This is a wide chart or large widget",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.05,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),

          // Other content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: Text(
              "Other content goes here",
              style: TextStyle(fontSize: screenWidth * 0.05),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
        ],
      ),
    );
  }
}

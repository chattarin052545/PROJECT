import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Scrollable Example")),
        body: ScrollableContent(),
      ),
    );
  }
}

class ScrollableContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton(
            onPressed: () {},
            child: Text("Button"),
          ),
          SizedBox(height: 10),
          Text("Sample Text"),
          SizedBox(height: 10),
          Container(
            height: 200, // set a height for the list to fit in the column
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: 10,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text("List Item $index"),
                );
              },
            ),
          ),
          SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              width: 800, // specify a wide width for horizontal scrolling
              height: 300,
              color: Colors.blueAccent,
              child: Center(
                child: Text(
                  "This is a wide chart or large widget",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Text("Other content goes here"),
        ],
      ),
    );
  }
}

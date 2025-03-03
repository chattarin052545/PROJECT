// import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:v1/ble_control_screen.dart';

// import 'device_screen_rw.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  // List of discovered devices
  List<ScanResult> scanResults = [];

  @override
  void initState() {
    super.initState();
    startScan();
  }

  // Method to start scanning for Bluetooth devices
  void startScan() {
    setState(() {
      scanResults = []; // Clear the list before starting a new scan
    });

    // Start scanning for Bluetooth devices
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    // Listen to scan results
    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        // scanResults = results;  // ทุก device
        scanResults = results.where((r) {
          final deviceName = r.device.advName.toLowerCase();
          return deviceName.contains('esp32'); // anan edit
        }).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan for Devices')),
      body: ListView.builder(
        itemCount: scanResults.length,
        itemBuilder: (context, index) {
          final device = scanResults[index].device;
          return ListTile(
            title:
                Text(device.name.isNotEmpty ? device.name : 'Unknown Device'),
            subtitle: Text(device.id.toString()),
            trailing: ElevatedButton(
              child: const Text('Connect'),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  // builder: (context) => DeviceScreen(device: device),
                  builder: (context) => BLEControlScreen(device: device),
                ));
              },
            ),
          );
        },
      ),
      // Add a floating action button to re-scan devices
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          startScan(); // Call startScan() when the button is pressed
        },
        child: const Icon(Icons.search),
        tooltip: 'Scan for devices',
      ),
    );
  }
}

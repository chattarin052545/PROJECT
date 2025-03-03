import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'device_screen.dart';

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

  void startScan() {
    // Start scanning for Bluetooth devices
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    // Listen to scan results
    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        scanResults = results;
      });
    });

    // print('result: $scanResults');
    // Stop scanning after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      FlutterBluePlus.stopScan();
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
              child: const Text('x1:Connect'),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => DeviceScreen(device: device),
                ));
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.refresh),
        onPressed: startScan,
      ),
    );
  }
}

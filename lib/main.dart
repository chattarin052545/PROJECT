import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:v1/ble_control_screen.dart';
import 'package:v1/main_screen.dart';
import 'package:v1/widgets/card_widget_notitle.dart';

void main() {
  runApp(const FlutterBLEApp());
}

class FlutterBLEApp extends StatelessWidget {
  const FlutterBLEApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sucking Force',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.purple),
      home: const BLEScanScreen(),
    );
  }
}

class BLEScanScreen extends StatefulWidget {
  const BLEScanScreen({Key? key}) : super(key: key);

  @override
  _BLEScanScreenState createState() => _BLEScanScreenState();
}

class _BLEScanScreenState extends State<BLEScanScreen> {
  late StreamSubscription<List<ScanResult>> _scanSubscription;
  List<ScanResult> scanResults = [];

  @override
  void initState() {
    super.initState();
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        // scanResults = results;
        scanResults = results.where((r) {
          final deviceName = r.device.name.toLowerCase();
          return deviceName.contains('esp32') ||
              deviceName.contains('cmu'); // anan edit
        }).toList();
      });
    });
  }

  /// Start scanning for devices
  void _startScan() {
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        scanResults = results.where((r) {
          final deviceName = r.device.name.toLowerCase();
          return deviceName.contains('esp32') ||
              deviceName.contains(
                  'cmu'); // Filter for devices with "esp32" in their name
        }).toList();
      });
    });
  }

  /// Stop and refresh the scan
  void _refreshScan() {
    FlutterBluePlus.stopScan(); // Stop the current scan
    setState(() {
      scanResults = []; // Clear previous results
    });
    _startScan(); // Start a new scan
  }

  @override
  void dispose() {
    _scanSubscription.cancel();
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Scan BLE Devices')),
      appBar: AppBar(
        title: const Text('ค้นหาอุปกรณ์'),
        // title: CardWidgetNoTitle(
        //     title: "NeoSmartNip: เลือกอุปกรณ์", color: Colors.purple),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshScan, // Call refresh scan method
            tooltip: 'รีเฟรช',
          ),
        ],
      ),
      body: scanResults.isEmpty
          ? const Center(
              child: Text(
                'ไม่พบอุปกรณ์ !  กด Refresh',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            )
          : ListView.builder(
              itemCount: scanResults.length,
              itemBuilder: (context, index) {
                var result = scanResults[index];
                return ListTile(
                  title: Text(result.device.name.isNotEmpty
                      ? result.device.name
                      : "ไม่รู้ชื่อ"),
                  subtitle: Text(result.device.id.toString()),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      await result.device.connect();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              BLEControlScreen(device: result.device),
                          // SuckingForceMonitorApp(device: result.device),
                        ),
                      );
                    },
                    child: const Text('เชื่อมต่อ'),
                  ),
                );
              },
            ),
    );
  }
}

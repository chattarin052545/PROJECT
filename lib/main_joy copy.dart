import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:v1/ble_control_screen.dart';

void main() {
  runApp(const FlutterBLEApp());
}

class FlutterBLEApp extends StatelessWidget {
  const FlutterBLEApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JoyBLEApp',
      theme: ThemeData(primarySwatch: Colors.blue),
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
          return deviceName.contains('esp32'); // anan edit
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
          return deviceName.contains(
              'esp32'); // Filter for devices with "esp32" in their name
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
        title: const Text('Scan BLE Devices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshScan, // Call refresh scan method
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: scanResults.isEmpty
          ? const Center(
              child: Text(
                'No devices found',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: scanResults.length,
              itemBuilder: (context, index) {
                var result = scanResults[index];
                return ListTile(
                  title: Text(result.device.name.isNotEmpty
                      ? result.device.name
                      : "Unknown Device"),
                  subtitle: Text(result.device.id.toString()),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      await result.device.connect();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              BLEControlScreen(device: result.device),
                        ),
                      );
                    },
                    child: const Text('Connect'),
                  ),
                );
              },
            ),
    );
  }
}
/*
class BLEControlScreen extends StatefulWidget {
  final BluetoothDevice device;

  const BLEControlScreen({Key? key, required this.device}) : super(key: key);

  @override
  _BLEControlScreenState createState() => _BLEControlScreenState();
}

class _BLEControlScreenState extends State<BLEControlScreen> {
  BluetoothCharacteristic? writeCharacteristic;
  BluetoothCharacteristic? notifyCharacteristic;
  StreamSubscription<List<int>>? _notificationSubscription;

  String fsrValue = "N/A";
  String batteryLevel = "N/A";
  String status = "Device stopped";

  @override
  void initState() {
    super.initState();
    _initializeDevice();
  }

  Future<void> _initializeDevice() async {
    var services = await widget.device.discoverServices();
    for (var service in services) {
      for (var characteristic in service.characteristics) {
        if (characteristic.properties.write) {
          writeCharacteristic = characteristic;
        }
        if (characteristic.properties.notify) {
          notifyCharacteristic = characteristic;
          await notifyCharacteristic!.setNotifyValue(true);
          _notificationSubscription =
              notifyCharacteristic!.value.listen((value) {
            final receivedData = utf8.decode(value);

            // ตรวจสอบว่าเป็นข้อมูลแบตเตอรี่ (ถ้าเริ่มต้นด้วย "BAT:")
            if (receivedData.startsWith("Battery:")) {
              setState(() {
                batteryLevel = receivedData.replaceFirst(
                    "Battery:", ""); // แสดงค่าแบตเตอรี่
              });
            } else {
              // ถ้าไม่ใช่ข้อมูลแบตเตอรี่ แสดงค่า FSR
              setState(() {
                fsrValue = receivedData; // แสดงค่า FSR
              });
            }
          });
        }
      }
    }
  }

  Future<void> _sendCommand(String command) async {
    if (writeCharacteristic != null) {
      await writeCharacteristic!.write(utf8.encode(command));
    }
  }

  @override
  void dispose() {
    _sendCommand("stop");
    _notificationSubscription?.cancel();
    // widget.device.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Device  ${widget.device.platformName}")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("v2:", style: TextStyle(fontSize: 18)),
            const Text("FSR Value:", style: TextStyle(fontSize: 18)),
            Text(fsrValue,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _sendCommand("start");
                setState(() {
                  status = "Device is running";
                });
              },
              child: const Text("Start"),
            ),
            ElevatedButton(
              onPressed: () async {
                await _sendCommand("stop");
                setState(() {
                  status = "Device stopped";
                });
              },
              child: const Text("Stop"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _sendCommand("batt");
              },
              child: const Text("Check Battery"),
            ),
            const SizedBox(height: 10),
            const Text("Battery Level:", style: TextStyle(fontSize: 18)),
            Text(batteryLevel,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            // เพิ่มปุ่มตั้งเวลา
            ElevatedButton(
              onPressed: () async {
                await _sendCommand("15");
              },
              child: const Text("Set Timer: 15 seconds"),
            ),
            ElevatedButton(
              onPressed: () async {
                await _sendCommand("30");
              },
              child: const Text("Set Timer: 30 seconds"),
            ),
            ElevatedButton(
              onPressed: () async {
                await _sendCommand("60");
              },
              child: const Text("Set Timer: 60 seconds"),
            ),
            const SizedBox(height: 20),
            Text(status,
                style: const TextStyle(fontSize: 18, color: Colors.green)),
          ],
        ),
      ),
    );
  }
}
*/
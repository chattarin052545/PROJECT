import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DeviceScreen extends StatefulWidget {
  final BluetoothDevice device;

  const DeviceScreen({Key? key, required this.device}) : super(key: key);

  @override
  _DeviceScreenState createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  BluetoothCharacteristic? characteristicToWrite;
  String batteryData = 'No data';
  String sensorData = 'No data';
  StreamSubscription<List<int>>? sensorDataSubscription;

  @override
  void initState() {
    super.initState();
    _connectToDevice();
  }

  Future<void> _connectToDevice() async {
    try {
      await widget.device.connect();
      await _discoverServices();
    } catch (e) {
      print("Error connecting to device: $e");
    }
  }

  Future<void> _discoverServices() async {
    List<BluetoothService> services = await widget.device.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.properties.write) {
          characteristicToWrite = characteristic;
        }
        if (characteristic.properties.notify) {
          // Sensor data notifications
          characteristic.setNotifyValue(true);
          sensorDataSubscription = characteristic.value.listen((value) {
            final decodedValue = String.fromCharCodes(value);
            setState(() {
              sensorData = decodedValue;
            });
          });
        }
      }
    }
  }

  Future<void> _sendCommand(int command) async {
    if (characteristicToWrite != null) {
      await characteristicToWrite!.write([command]);
    } else {
      print("Characteristic for writing not found!");
    }
  }

  Future<void> _readBatteryLevel() async {
    await _sendCommand(0); // Command to read battery
    setState(() {
      batteryData = "Reading battery level...";
    });
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> _startReadingSensor() async {
    await _sendCommand(1); // Command to start sensor reading
    setState(() {
      sensorData = "Reading sensor data...";
    });
  }

  Future<void> _stopReadingSensor() async {
    await _sendCommand(2); // Command to stop sensor reading
    setState(() {
      sensorData = "Sensor reading stopped.";
    });
  }

  @override
  void dispose() {
    sensorDataSubscription?.cancel();
    widget.device.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Device Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Battery Level Button
            ElevatedButton(
              onPressed: _readBatteryLevel,
              child: const Text('Read Battery Level'),
            ),
            const SizedBox(height: 10),
            Text(
              'Battery Level: $batteryData',
              style: const TextStyle(fontSize: 16),
            ),
            const Divider(),

            // Start and Stop Buttons for Sensor Data
            Row(
              children: [
                ElevatedButton(
                  onPressed: _startReadingSensor,
                  child: const Text('Start Reading Sensor'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _stopReadingSensor,
                  child: const Text('Stop Reading Sensor'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Sensor Data: $sensorData',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DeviceScreen extends StatefulWidget {
  final BluetoothDevice device;

  const DeviceScreen({Key? key, required this.device}) : super(key: key);

  @override
  _DeviceScreenState createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  BluetoothCharacteristic? characteristic;
  BluetoothCharacteristic? characteristicToWrite;
  String data = 'No data';

  BluetoothCharacteristic? writeCharacteristic;
  BluetoothCharacteristic? notifyCharacteristic;
  StreamSubscription<List<int>>? _notificationSubscription;

  String fsrValue = "N/A";
  String batteryLevel = "N/A";
  String status = "Device stopped";

  // List<BluetoothService> _services = [];
  List<int> receivedData = [];

//

  @override
  void initState() {
    super.initState();
    _connectToDevice();
  }

  Future<void> _connectToDevice() async {
    // Connect to the device
    await widget.device.connect();
    discoverServices();
  }

  Future<void> discoverServices() async {
    // ค้นหาบริการและลักษณะเฉพาะ
    List<BluetoothService> services = await widget.device!.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
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

  Future<void> _writeValue() async {
    await characteristicToWrite?.write([0x01, 0x02, 0x03]);
  }

  Future<void> _sendCommand(String command) async {
    if (writeCharacteristic != null) {
      await writeCharacteristic!.write(utf8.encode(command));
    }
  }

  Future<void> _readData() async {
    List<int>? value = await characteristic?.read();
    if (value != null) {
      // แปลงค่าจาก Uint8List เป็นค่าแบตเตอรี่ (สมมติว่าค่าแรกใน Uint8List คือค่าแบตเตอรี่)
      double batteryLevel = value[0].toDouble();
      setState(() {
        data = 'Battery: $batteryLevel%';
      });
    }
  }

  Future<void> _startReading() async {
    if (characteristic != null) {
      await characteristic?.setNotifyValue(true);
      characteristic?.value.listen((value) {
        // แปลงค่าและอัปเดต UI
        double batteryLevel = value[0].toDouble();
        setState(() {
          data = 'Battery: $batteryLevel%';
        });
      });
    }
  }

  Future<void> _stopReading() async {
    if (characteristic != null) {
      await characteristic?.setNotifyValue(false);
    }
  }

  @override
  void dispose() {
    // Disconnect from the device
    // widget.device.disconnect();   // ไม่ต้อง disconnect anan
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Device Control")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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

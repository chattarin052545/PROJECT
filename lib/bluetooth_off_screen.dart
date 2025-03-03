import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothOffScreen extends StatelessWidget {
  final BluetoothAdapterState adapterState;

  const BluetoothOffScreen({Key? key, required this.adapterState})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bluetooth Off')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('บลูทูธปิดอยู่'),
            ElevatedButton(
              onPressed: () {
                // FlutterBluePlus.openBluetoothSettings(); // Open Bluetooth settings
                FlutterBluePlus.turnOn(); // Enable Bluetooth
              },
              child: const Text('เปิดบลูทูธ'),
            ),
          ],
        ),
      ),
    );
  }
}

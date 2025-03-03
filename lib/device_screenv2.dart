import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DeviceScreen extends StatefulWidget {
  final BluetoothDevice device;

  const DeviceScreen({Key? key, required this.device}) : super(key: key);

  @override
  _DeviceScreenState createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  List<BluetoothService> _services = [];
  List<int> receivedData = []; // Store received notification data

  @override
  void initState() {
    super.initState();
    _connectToDevice();
  }

  Future<void> _connectToDevice() async {
    // Connect to the device
    await widget.device.connect();
    // Discover services and characteristics
    _services = await widget.device.discoverServices();
    setState(() {});
    // Automatically subscribe to characteristics that support notifications
    _setupNotifications();
  }

  void _setupNotifications() {
    for (BluetoothService service in _services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.properties.notify) {
          _subscribeToCharacteristic(characteristic);
        }
      }
    }
  }

  void _subscribeToCharacteristic(
      BluetoothCharacteristic characteristic) async {
    // Subscribe to notifications for this characteristic
    await characteristic.setNotifyValue(true);

    // Listen to characteristic value changes
    characteristic.value.listen((value) {
      setState(() {
        receivedData.addAll(value); // Add received data to the list
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connected to ${widget.device.name}'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            'Received Notification Data:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: receivedData.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Data: ${receivedData[index]}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    widget.device.disconnect();
    super.dispose();
  }
}

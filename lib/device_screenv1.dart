import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DeviceScreen extends StatefulWidget {
  final BluetoothDevice device;

  const DeviceScreen({Key? key, required this.device}) : super(key: key);

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  List<BluetoothService> services = [];
  bool isConnected = false;

  List<int> data = [];

  @override
  void initState() {
    super.initState();
    connectToDevice();
  }

  // Connect to the BLE device and discover services
  void connectToDevice() async {
    try {
      await widget.device.connect();
      setState(() => isConnected = true);

      // Discover services once connected
      services = await widget.device.discoverServices();
      setState(() {}); // Update the UI to show the services
    } catch (e) {
      print("Error connecting to device: $e");
    }
  }

  @override
  void dispose() {
    widget.device.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: connectToDevice,
          )
        ],
      ),
      body: isConnected
          ? ListView.builder(
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                return ServiceTile(service: service);
              },
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

class ServiceTile extends StatelessWidget {
  final BluetoothService service;

  const ServiceTile({Key? key, required this.service}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text('Service: ${service.uuid.toString()}'),
      children: service.characteristics.map((characteristic) {
        return CharacteristicTile(characteristic: characteristic);
      }).toList(),
    );
  }
}

class CharacteristicTile extends StatelessWidget {
  final BluetoothCharacteristic characteristic;

  const CharacteristicTile({Key? key, required this.characteristic})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Characteristic: ${characteristic.uuid}'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Properties: ${_getProperties(characteristic)}'),
          Row(
            children: [
              if (characteristic.properties.read)
                ElevatedButton(
                  onPressed: () async {
                    var value = await characteristic.read();
                    print('x:Read value: $value');
                  },
                  child: const Text('xRead'),
                ),
              if (characteristic.properties.write)
                ElevatedButton(
                  onPressed: () async {
                    await characteristic.write([0x12, 0x34]); // Example data
                    print('x:Write complete');
                  },
                  child: const Text('x:Write'),
                ),
              if (characteristic.properties.notify)
                ElevatedButton(
                  onPressed: () async {
                    characteristic.value.listen((value) {
                      print('x:Notification received: $value');
                      // data.add(value);  => Doesn't work have to use data provider  Here
                    });
                    await characteristic.setNotifyValue(true);
                    print('x:Subscribed to notifications');
                  },
                  child: const Text('x:Notify'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper function to show the available properties of the characteristic
  String _getProperties(BluetoothCharacteristic characteristic) {
    List<String> props = [];
    if (characteristic.properties.read) props.add("Read");
    if (characteristic.properties.write) props.add("Write");
    if (characteristic.properties.notify) props.add("Notify");
    if (characteristic.properties.indicate) props.add("Indicate");
    return props.join(", ");
  }
}

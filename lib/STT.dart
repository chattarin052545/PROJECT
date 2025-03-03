import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shared_preferences/shared_preferences.dart'; // เพิ่ม package นี้

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Control with BLE',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BluetoothConnectionPage(),
    );
  }
}

class BluetoothConnectionPage extends StatefulWidget {
  @override
  _BluetoothConnectionPageState createState() => _BluetoothConnectionPageState();
}

class _BluetoothConnectionPageState extends State<BluetoothConnectionPage> {
  List<BluetoothDevice> devicesList = [];
  BluetoothDevice? connectedDevice;
  bool _isBluetoothOn = false;
  StreamSubscription<BluetoothAdapterState>? _bluetoothStateSubscription;
  Timer? _connectionCheckTimer;

  @override
  void initState() {
    super.initState();
    _checkBluetoothState();
    _startScan();
    _listenToBluetoothState();
    _startConnectionCheckTimer();
  }

  @override
  void dispose() {
    _bluetoothStateSubscription?.cancel();
    _connectionCheckTimer?.cancel();
    super.dispose();
  }

  // ตรวจสอบสถานะ Bluetooth
  void _checkBluetoothState() async {
    bool isOn = await FlutterBluePlus.isOn;
    setState(() {
      _isBluetoothOn = isOn;
    });
  }

  // ฟังการเปลี่ยนแปลงสถานะ Bluetooth
  void _listenToBluetoothState() {
    _bluetoothStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      setState(() {
        _isBluetoothOn = state == BluetoothAdapterState.on;
      });
    });
  }

  // ตรวจสอบสถานะการเชื่อมต่อเป็นระยะๆ
  void _startConnectionCheckTimer() {
    _connectionCheckTimer = Timer.periodic(Duration(seconds: 2), (timer) async {
      if (connectedDevice != null) {
        bool isConnected = await connectedDevice!.isConnected;
        if (!isConnected) {
          setState(() {
            connectedDevice = null;
          });
        }
      }
    });
  }

  void _startScan() async {
    if (!_isBluetoothOn) {
      print("Bluetooth is off");
      return;
    }

    await FlutterBluePlus.startScan(timeout: Duration(seconds: 4));

    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (!devicesList.contains(result.device)) {
          setState(() {
            devicesList.add(result.device);
          });
        }
      }
    });
  }

  void _connectToDevice(BluetoothDevice device) async {
    await device.connect();
    setState(() {
      connectedDevice = device;
    });

    // Navigate to VoiceControlHome after successful connection
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VoiceControlHome(connectedDevice: connectedDevice),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Connection'),
        actions: [
          Icon(
            Icons.bluetooth,
            color: _getBluetoothIconColor(),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          ElevatedButton(
            onPressed: _startScan,
            child: Text('Scan for Devices'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: devicesList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(devicesList[index].name),
                  subtitle: Text(devicesList[index].id.toString()),
                  onTap: () => _connectToDevice(devicesList[index]),
                );
              },
            ),
          ),
          if (connectedDevice != null)
            Text('Connected to: ${connectedDevice!.name}'),
        ],
      ),
    );
  }

  // ฟังก์ชันกำหนดสีไอคอน Bluetooth
  Color _getBluetoothIconColor() {
    if (!_isBluetoothOn) {
      return Colors.grey; // Bluetooth ปิด
    } else if (connectedDevice == null) {
      return Colors.red; // Bluetooth เปิด แต่ยังไม่เชื่อมต่อ
    } else {
      return Colors.green; // Bluetooth เชื่อมต่อแล้ว
    }
  }
}

class VoiceControlHome extends StatefulWidget {
  final BluetoothDevice? connectedDevice;

  VoiceControlHome({this.connectedDevice});

  @override
  _VoiceControlHomeState createState() => _VoiceControlHomeState();
}

class _VoiceControlHomeState extends State<VoiceControlHome> {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  bool _isListening = false;
  String _text = '';

  bool _light1 = false;
  bool _light2 = false;
  bool _light3 = false;
  bool _light4 = false;

  String _device1 = 'อุปกรณ์ 1';
  String _device2 = 'อุปกรณ์ 2';
  String _device3 = 'อุปกรณ์ 3';
  String _device4 = 'อุปกรณ์ 4';

  BluetoothCharacteristic? _relayCharacteristic;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _loadSavedData(); // โหลดข้อมูลที่บันทึกไว้
    _startListening();
    _setupBluetooth();
  }

  // โหลดข้อมูลที่บันทึกไว้จาก SharedPreferences
  void _loadSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _light1 = prefs.getBool('light1') ?? false;
      _light2 = prefs.getBool('light2') ?? false;
      _light3 = prefs.getBool('light3') ?? false;
      _light4 = prefs.getBool('light4') ?? false;

      _device1 = prefs.getString('device1') ?? 'อุปกรณ์ 1';
      _device2 = prefs.getString('device2') ?? 'อุปกรณ์ 2';
      _device3 = prefs.getString('device3') ?? 'อุปกรณ์ 3';
      _device4 = prefs.getString('device4') ?? 'อุปกรณ์ 4';
    });
  }

  // บันทึกข้อมูลลงใน SharedPreferences
  void _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('light1', _light1);
    prefs.setBool('light2', _light2);
    prefs.setBool('light3', _light3);
    prefs.setBool('light4', _light4);

    prefs.setString('device1', _device1);
    prefs.setString('device2', _device2);
    prefs.setString('device3', _device3);
    prefs.setString('device4', _device4);
  }

  // เมื่อมีการเปลี่ยนแปลงสถานะรีเลย์หรือชื่ออุปกรณ์
  void _updateState(bool lightState, String deviceName, int deviceNumber) {
    setState(() {
      switch (deviceNumber) {
        case 1:
          _light1 = lightState;
          break;
        case 2:
          _light2 = lightState;
          break;
        case 3:
          _light3 = lightState;
          break;
        case 4:
          _light4 = lightState;
          break;
      }
    });
    _saveData(); // บันทึกข้อมูลทุกครั้งที่มีการเปลี่ยนแปลง
  }

  void _setupBluetooth() async {
    if (widget.connectedDevice != null) {
      List<BluetoothService> services = await widget.connectedDevice!.discoverServices();
      for (BluetoothService service in services) {
        if (service.uuid.toString() == "4fafc201-1fb5-459e-8fcc-c5c9c331914b") {
          for (BluetoothCharacteristic characteristic in service.characteristics) {
            if (characteristic.uuid.toString() == "beb5483e-36e1-4688-b7f5-ea07361b26a8") {
              setState(() {
                _relayCharacteristic = characteristic;
              });
              break;
            }
          }
        }
      }
    }
  }

  void _sendCommand(String command) async {
    if (_relayCharacteristic != null) {
      await _relayCharacteristic!.write(command.codeUnits);
      print("Command sent: $command");
    }
  }

  void _startListening() async {
    bool available = await _speech.initialize();
    if (!available) {
      print('ไม่สามารถเริ่มการฟังได้');
      return;
    }

    if (!_isListening) {
      setState(() {
        _text = '';
        _isListening = true;
      });

      _speech.listen(
        onResult: (val) {
          setState(() {
            _text = val.recognizedWords;
          });
        },
        listenFor: Duration(seconds: 30),
        pauseFor: Duration(seconds: 5),
        partialResults: true,
        localeId: 'th_TH',
      );

      await Future.delayed(const Duration(seconds: 5));
      _speech.stop();
      setState(() {
        _isListening = false;
      });

      _processCommand(_text);
    }
  }

  void _processCommand(String command) async {
    command = command.toLowerCase();

    if (command.contains('ระบุอุปกรณ์ที่ 1 เป็น')) {
      setState(() {
        _device1 = command.replaceAll('ระบุอุปกรณ์ที่ 1 เป็น', '').trim();
      });
      _saveData(); // บันทึกชื่ออุปกรณ์ใหม่
    } else if (command.contains('ระบุอุปกรณ์ที่ 2 เป็น')) {
      setState(() {
        _device2 = command.replaceAll('ระบุอุปกรณ์ที่ 2 เป็น', '').trim();
      });
      _saveData(); // บันทึกชื่ออุปกรณ์ใหม่
    } else if (command.contains('ระบุอุปกรณ์ที่ 3 เป็น')) {
      setState(() {
        _device3 = command.replaceAll('ระบุอุปกรณ์ที่ 3 เป็น', '').trim();
      });
      _saveData(); // บันทึกชื่ออุปกรณ์ใหม่
    } else if (command.contains('ระบุอุปกรณ์ที่ 4 เป็น')) {
      setState(() {
        _device4 = command.replaceAll('ระบุอุปกรณ์ที่ 4 เป็น', '').trim();
      });
      _saveData(); // บันทึกชื่ออุปกรณ์ใหม่
    }

    if (command.contains('เปิด')) {
      if (command.contains(_device1)) {
        _updateState(true, _device1, 1);
        await _speakFeedback('เปิด $_device1');
        _sendCommand("ON1");
      } else if (command.contains(_device2)) {
        _updateState(true, _device2, 2);
        await _speakFeedback('เปิด $_device2');
        _sendCommand("ON2");
      } else if (command.contains(_device3)) {
        _updateState(true, _device3, 3);
        await _speakFeedback('เปิด $_device3');
        _sendCommand("ON3");
      } else if (command.contains(_device4)) {
        _updateState(true, _device4, 4);
        await _speakFeedback('เปิด $_device4');
        _sendCommand("ON4");
      }
    } else if (command.contains('ปิด')) {
      if (command.contains(_device1)) {
        _updateState(false, _device1, 1);
        await _speakFeedback('ปิด $_device1');
        _sendCommand("OFF1");
      } else if (command.contains(_device2)) {
        _updateState(false, _device2, 2);
        await _speakFeedback('ปิด $_device2');
        _sendCommand("OFF2");
      } else if (command.contains(_device3)) {
        _updateState(false, _device3, 3);
        await _speakFeedback('ปิด $_device3');
        _sendCommand("OFF3");
      } else if (command.contains(_device4)) {
        _updateState(false, _device4, 4);
        await _speakFeedback('ปิด $_device4');
        _sendCommand("OFF4");
      }
    }

    if (command.contains('สถานะอุปกรณ์ไฟฟ้าทั้งหมด')) {
      await _speakDeviceStatus();
      await Future.delayed(const Duration(seconds: 6));
    }
    await Future.delayed(const Duration(seconds: 2));
    _startListening();
  }

  Future<void> _speakDeviceStatus() async {
    String status = 'สถานะอุปกรณ์ไฟฟ้าทั้งหมด ';
    status += _device1 + (_light1 ? ' เปิด' : ' ปิด') + ', ';
    status += _device2 + (_light2 ? ' เปิด' : ' ปิด') + ', ';
    status += _device3 + (_light3 ? ' เปิด' : ' ปิด') + ', ';
    status += _device4 + (_light4 ? ' เปิด' : ' ปิด');
    await _flutterTts.setLanguage('th-TH');
    await _flutterTts.speak(status);
  }

  Future<void> _speakFeedback(String message) async {
    await _flutterTts.setLanguage('th-TH');
    await _flutterTts.speak(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voice Control App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDeviceRow(_device1, _light1, (value) {
                  _updateState(value, _device1, 1);
                  if (value) {
                    _sendCommand("ON1");
                  } else {
                    _sendCommand("OFF1");
                  }
                }, 1),
                _buildDeviceRow(_device2, _light2, (value) {
                  _updateState(value, _device2, 2);
                  if (value) {
                    _sendCommand("ON2");
                  } else {
                    _sendCommand("OFF2");
                  }
                }, 2),
                _buildDeviceRow(_device3, _light3, (value) {
                  _updateState(value, _device3, 3);
                  if (value) {
                    _sendCommand("ON3");
                  } else {
                    _sendCommand("OFF3");
                  }
                }, 3),
                _buildDeviceRow(_device4, _light4, (value) {
                  _updateState(value, _device4, 4);
                  if (value) {
                    _sendCommand("ON4");
                  } else {
                    _sendCommand("OFF4");
                  }
                }, 4),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'ข้อความที่พูด $_text',
                style: TextStyle(fontSize: 20.0),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onTap: _startListening,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: _isListening ? Colors.grey[300] : Colors.grey[800],
                  child: Icon(
                    Icons.mic,
                    color: _isListening ? Colors.black : Colors.white,
                    size: 50,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceRow(String deviceName, bool isOn, Function(bool) onChanged, int deviceNumber) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: isOn ? Colors.yellow : Colors.grey,
                size: 50,
              ),
              SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'อุปกรณ์ที่ $deviceNumber',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Row(
                    children: [
                      Text(
                        deviceName,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _showEditDialog(deviceNumber);
                        },
                      ),
                    ],
                  ),
                  Text(
                    isOn ? 'สถานะ เปิด' : 'สถานะ ปิด',
                    style: TextStyle(
                      fontSize: 14,
                      color: isOn ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () async {
              bool newState = !isOn;
              onChanged(newState);
              if (newState) {
                await _speakFeedback('เปิด $deviceName');
              } else {
                await _speakFeedback('ปิด $deviceName');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isOn ? Colors.green : Colors.grey,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(
              isOn ? 'ON' : 'OFF',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(int deviceNumber) {
    TextEditingController controller = TextEditingController();
    String currentDeviceName = '';
    if (deviceNumber == 1) currentDeviceName = _device1;
    else if (deviceNumber == 2) currentDeviceName = _device2;
    else if (deviceNumber == 3) currentDeviceName = _device3;
    else if (deviceNumber == 4) currentDeviceName = _device4;

    controller.text = currentDeviceName;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('เปลี่ยนชื่ออุปกรณ์'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'กรอกชื่ออุปกรณ์'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  if (deviceNumber == 1) _device1 = controller.text;
                  else if (deviceNumber == 2) _device2 = controller.text;
                  else if (deviceNumber == 3) _device3 = controller.text;
                  else if (deviceNumber == 4) _device4 = controller.text;
                });
                Navigator.of(context).pop();
              },
              child: Text('บันทึก'),
            ),
          ],
        );
      },
    );
  }
}
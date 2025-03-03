import 'dart:async';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:v1/ftchart.dart';
import 'package:v1/ftchart_option.dart';
import 'package:v1/main_screen.dart';
import 'package:v1/newwidgets/progress_indicator.dart';
import 'package:v1/newwidgets/row2cols_string.dart';
import 'package:v1/newwidgets/duration_option.dart';
import 'package:v1/newwidgets/unit_option.dart';
import 'package:v1/utils/my_function.dart';
import 'package:v1/widgets/aggegate_widget.dart';
import 'package:v1/widgets/card_widget.dart';
import 'package:v1/widgets/card_widget_notitle.dart';

enum ButtonState { start, stop, reset }

enum DeviceState { running, stopped, error }

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

  String fsrValue = "0.0";
  String batteryLevel = "N/A";
  var deviceState = DeviceState.stopped;

  // Variable about Timer
  // int _totalTimeInSeconds = 0;
  int _timerCounter = 0; // counter
  int _previousTimerCounter = 0; // previous counter
  Timer? _timer;
  // Variable to store main duration
  List<String> mainUnits = ['Pa', 'N/m^2', 'mmHg'];
  int mainUnitSelectIndex = 0;
  List<int> durations = [10, 30, 60, 90];
  late int mainDuration;
  // List to store FSR values
  List<int> fsrValues = [];
  List<double> aggregateValues = [];

  @override
  void initState() {
    super.initState();
    mainDuration = durations.first; // นำค่าแรกออกมา
    _timerCounter = mainDuration;
    // _totalTimeInSeconds = mainDuration;
    _initializeDevice();
    // getBattValue();
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

            if (receivedData.startsWith("Battery:")) {
              setState(() {
                batteryLevel = receivedData.replaceFirst("Battery:", "");
              });
            } else {
              setState(() {
                fsrValue = receivedData;
                // Parse FSR value to int and add it to the list
                final intValue = int.tryParse(receivedData);
                if (intValue != null) {
                  fsrValues.add(intValue); // Add the parsed value to the list
                  // print('add $intValue');
                }
              });
            }
          });
        }
      }
    }
  }

  // Function to send a command
  Future<void> _sendCommand(String command) async {
    if (writeCharacteristic != null) {
      await writeCharacteristic!.write(utf8.encode(command));
    }
  }

  void getUnitIndex(int index) {
    setState(() {
      mainUnitSelectIndex = index;
    });
  }

  void setDuration(int duration) {
    setState(() {
      mainDuration = duration;
      _timerCounter = duration;
    });
  }

  String get formattedTime {
    int minutes = _timerCounter ~/ 60;
    int seconds = _timerCounter % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void _startTimer() {
    try {
      _previousTimerCounter = _timerCounter;
      deviceState = DeviceState.running;
      setState(() {
        _timerCounter = mainDuration;
      });

      // Start the timer
      _timer?.cancel();
      const oneSec = Duration(seconds: 1);
      _timer = Timer.periodic(oneSec, (Timer timer) async {
        if (_timerCounter > 1) {
          setState(() {
            _timerCounter--;
          });
        } else {
          /*await _sendCommand("stop");
          setState(() {
            deviceState = DeviceState.stopped;
          });

          timer.cancel();*/
          _stopTimer();
          // _showTimeUpDialog();
          _showTimeUpSnackBar();
        }
      });
    } catch (e) {
      _showInvalidInputDialog();
    }
  }

  void _showInvalidInputDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("มีบางอย่างผิดพลาด!"),
          content: const Text("โปรดตรวจสอบ"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _stopTimer() async {
    await _sendCommand("stop");
    deviceState = DeviceState.stopped;
    _timer?.cancel();
    setState(() {
      _timerCounter = 0;
    });
    _timerCounter = _previousTimerCounter; // anan
    aggregateValues = aggregateFx(data: fsrValues);
  }

  void _showTimeUpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Time's up!"),
          content: const Text("The timer has finished."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showTimeUpSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          "Time's up! The timer has finished.",
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16), // Adds some spacing
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)), // Rounded corners
        duration: const Duration(seconds: 4), // Automatically disappears
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            // Handle SnackBar action if needed
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _sendCommand("stop");
    _notificationSubscription?.cancel();
    fsrValue = "N/A";
    batteryLevel = "N/A";
    deviceState = DeviceState.stopped;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("[อุปกรณ์: ${widget.device.platformName}]"),
        backgroundColor: Colors.grey.shade200,
        foregroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CardWidgetNoTitle(title: "NeoSmartNip", color: Colors.lightBlue),
            // const SizedBox(height: 20),
            aggregateValues.length == 0
                ? CardWidget(title: 'ยังไม่มีข้อมูล', color: Colors.red)
                : AggregateWidget(aggregateValues: aggregateValues),

            const SizedBox(height: 5),
            unitOption(mainUnits, mainUnitSelectIndex, getUnitIndex),
            const SizedBox(height: 5),
            durationOption(durations, mainDuration, setDuration), //ok

            // fsrValue == "0.0"
            //     ? const CircularProgressIndicator()
            //     : progrseIndicator(double.parse(fsrValue)),
            SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.only(left: 40.0),
              alignment: Alignment.topLeft,
              child: Text(
                  "${deviceState == DeviceState.running ? "กำลังอ่าน !  [ ${formattedTime} ] FSR: $fsrValue" : "กดปุ่ม [ เริ่ม ] เพื่ออ่าน !"}",
                  // "${deviceState == DeviceState.running ? "FSR: $fsrValue" : "หยุดทํางาน"}",
                  style: deviceState == DeviceState.running
                      ? TextStyle(fontSize: 22, color: Colors.green)
                      : TextStyle(fontSize: 22, color: Colors.red)),
            ),

            startStopTimerGraph(), // ok
          ],
        ),
      ),
    );
  }

// widget
  Widget startStopTimerGraph() {
    return Container(
      margin: const EdgeInsets.fromLTRB(40, 00, 40, 00.0),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.purple),
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            child: const Text(
              'เริ่ม',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: deviceState == DeviceState.stopped
                  ? Colors.lightGreen
                  : Colors.grey,
            ),
            onPressed: deviceState == DeviceState.running
                ? null
                : () async {
                    await _sendCommand("start");
                    _startTimer();
                    setState(() {
                      deviceState = DeviceState.running;
                      fsrValues.clear(); // Clear previous values when starting
                    });
                  },
          ),
          ElevatedButton(
              child: const Text(
                'หยุด',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: deviceState == DeviceState.running
                    ? Colors.redAccent
                    : Colors.white,
              ),
              onPressed: deviceState == DeviceState.stopped
                  ? null
                  : () async {
                      await _sendCommand("stop");
                      _stopTimer();
                      setState(() {
                        deviceState = DeviceState.stopped;
                      });
                    }),
          deviceState == DeviceState.stopped && aggregateValues.length > 0
              ? ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: Text(
                    "กราฟ",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        // builder: (context) => ChartScreen(spots: graphSpots),
                        builder: (context) =>
                            FsrChartScreen(fsrDatas: fsrValues),
                      ),
                    );
                  },
                )
              : Container(),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'chart_screen.dart';
import 'timer_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// void main() {
//   runApp(SuckingForceMonitorApp());
// }

class SuckingForceMonitorApp extends StatelessWidget {
  final BluetoothDevice device;
  const SuckingForceMonitorApp({Key? key, required this.device})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TimerModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SFM-v123',
        home: SuckingForceMonitor(device: device),
      ),
    );
  }
}

Color getColor(double value) {
  if (value >= 80.0) {
    return Colors.redAccent; // Low level
  } else if (value >= 50.0) {
    return Colors.orangeAccent; // Medium level
  } else {
    return Colors.lightGreen; // High level
  }
}

class SuckingForceMonitor extends StatefulWidget {
  final BluetoothDevice device;

  const SuckingForceMonitor({Key? key, required this.device}) : super(key: key);

  @override
  State<SuckingForceMonitor> createState() => _SuckingForceMonitorState();
}

class _SuckingForceMonitorState extends State<SuckingForceMonitor> {
  BluetoothCharacteristic? writeCharacteristic;
  BluetoothCharacteristic? notifyCharacteristic;
  StreamSubscription<List<int>>? _notificationSubscription;

  String fsrValue = "N/A";
  String batteryLevel = "N/A";
  String status = "Device stopped";

  // List to store FSR values
  List<int> fsrValues = [];

  @override
  void initState() {
    super.initState();

    _initializeDevice();
    // getBattValue();
  }

  void getBattValue() async {
    await _sendCommand("batt");
  }

  void startGetFSRValue() async {
    await _sendCommand("start");
  }

  void stopGetFSRValue() async {
    await _sendCommand("stop");
  }

// initialize device & read battery, sensor data
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

  Future<void> _sendCommand(String command) async {
    if (writeCharacteristic != null) {
      await writeCharacteristic!.write(utf8.encode(command));
    }
  }

  @override
  void dispose() {
    _sendCommand("stop");
    _notificationSubscription?.cancel();
    fsrValue = "N/A";
    batteryLevel = "N/A";
    status = "Device stopped";
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timerModel = Provider.of<TimerModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Device:${widget.device.platformName}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DurationOptionWidget(),
            SizedBox(height: 20),
            TimeDisplayWidget(),
            SizedBox(height: 20),
            StartStopButtonWidget(
              startFx: startGetFSRValue,
              stopFx: stopGetFSRValue,
            ),
            SizedBox(height: 20),
            Container(
              width: 300,
              height: 40,
              child: LinearProgressIndicator(
                value: timerModel.lastForce / 100, // Normalize between 0 and 1
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  getColor(timerModel.lastForce),
                ),
              ),
            ),
            SizedBox(height: 10),
            const Text("FSR Value:", style: TextStyle(fontSize: 18)),
            Text(fsrValue,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed:
                  timerModel.isRunning || timerModel.suckingForces.isEmpty
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ChartScreen(timerModel.suckingForces),
                            ),
                          );
                        },
              child: Text('Graph'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: SuckingForceChart(timerModel.suckingForces),
            ),
          ],
        ),
      ),
    );
  }
}

class DurationOptionWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final timerModel = Provider.of<TimerModel>(context);

    return Column(
      children: [
        Text(
          "เลือกเวลา",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [5, 10, 30, 60].map((duration) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: ElevatedButton(
                onPressed: timerModel.isRunning
                    ? null
                    : () => timerModel.setTimer(duration),
                child: Text("$duration"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: timerModel.initialDuration == duration
                      ? Colors.green
                      : Colors.grey, // Highlight selected duration
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class TimeDisplayWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final timerModel = Provider.of<TimerModel>(context);

    return Text(
      "${timerModel.seconds} วินาที",
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }
}

class StartStopButtonWidget extends StatelessWidget {
  final Function startFx;
  final Function stopFx;

  StartStopButtonWidget({required this.startFx, required this.stopFx});

  @override
  Widget build(BuildContext context) {
    final timerModel = Provider.of<TimerModel>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // ElevatedButton(
        //   onPressed: () {
        //   },
        //   child: Text('Startx'),
        // ),
        ElevatedButton(
          // onPressed: timerModel.isRunning ? timerModel.stopTimer : timerModel.startTimer,

          onPressed: () {
            if (timerModel.isRunning) {
              timerModel.startTimer();
              // startFx; // start read fsr value
            }
            startFx();
          },
          child: Text("Start123"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            disabledForegroundColor: Colors.grey.withOpacity(0.38),
            disabledBackgroundColor:
                Colors.grey.withOpacity(0.12), // Disabled button color
          ),
        ),
        SizedBox(width: 20),
        ElevatedButton(
          onPressed: timerModel.isRunning ? timerModel.stopTimer : null,
          child: Text("Stop"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            disabledForegroundColor: Colors.grey.withOpacity(0.38),
            disabledBackgroundColor:
                Colors.grey.withOpacity(0.12), // Disabled button color
          ),
        ),
      ],
    );
  }
}

class SuckingForceChart extends StatelessWidget {
  final List<double> forces;

  SuckingForceChart(this.forces);

  @override
  Widget build(BuildContext context) {
    return Text('Chart ${forces.toString()}\n ');
  }
}

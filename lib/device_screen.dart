import 'dart:async';

import 'package:chart_sparkline/chart_sparkline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:v1/utils/timermodel.dart';

class DeviceScreen extends StatefulWidget {
  final BluetoothDevice device;

  const DeviceScreen({Key? key, required this.device}) : super(key: key);

  @override
  _DeviceScreenState createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  List<BluetoothService> _services = [];
  List<int> receivedData = []; // Store received notification data
//

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

/*
if (!context.read<TimerModel>().isRunning) {
        timer.cancel();
      } else {
        // Simulate receiving random pressure data
        Random random = Random();
        double r = random.nextInt(100) * 1.0;

        // double randomPressure =
        //     20 + 30 * (timer.tick % 2); // Simulate a varying force
        // // print('$randomPressure $r'); // anan
        // context.read<TimerModel>().addSuckingForce(randomPressure);
        context.read<TimerModel>().addSuckingForce(r);
      }
    });
*/
  void _subscribeToCharacteristic(
      BluetoothCharacteristic characteristic) async {
    // Subscribe to notifications for this characteristic
    await characteristic.setNotifyValue(true);

    // Listen to characteristic value changes
    characteristic.lastValueStream.listen((value) {
      setState(() {
        // receivedData.addAll(value); // Add received data to the list ไม่ใช่ ใช้ line ล่าง

        // receivedData.addAll(value); // ทดสอบ random
        Timer.periodic(Duration(seconds: 1), (timer) {
          if (!context.read<TimerModel>().isRunning) {
            timer.cancel();
          } else {
            // Simulate receiving random pressure data
            receivedData.addAll(value);
            context.read<TimerModel>().addSuckingForce(value.last.toDouble());
          }
        });
      });
    });
  }

  void listenToPressureData(BuildContext context) {
    // In a real scenario, this would handle the Bluetooth connection
    // and listen for data, then update the TimerModel accordingly.
    // For this example, we simulate pressure data.
    // Timer.periodic(Duration(seconds: 1), (timer) {
    //   if (!context.read<TimerModel>().isRunning) {
    //     timer.cancel();
    //   } else {
    //     // Simulate receiving random pressure data
    //     Random random = Random();
    //     double r = random.nextInt(100) * 1.0;
    //     context.read<TimerModel>().addSuckingForce(r);
    //   }
    // });
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
      appBar: AppBar(
        title:
            Text('Connected to ${widget.device.platformName}'), // ชื่ออุปกรณ์
      ),
      /*body: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'Received Notification Data:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            // Expanded(
            //   child: ListView.builder(
            //     itemCount: receivedData.length,
            //     itemBuilder: (context, index) {
            //       return ListTile(
            //         title: Text('Data: ${receivedData[index]}'),
            //       );
            //     },
            //   ),
            // ),
            Text('Data: ${receivedData.toString()}'),
          ],
        ),
        */
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Timer Display
              Consumer<TimerModel>(
                builder: (context, timerModel, child) {
                  return Text(
                    '${(timerModel.seconds ~/ 60).toString().padLeft(2, '0')}:${(timerModel.seconds % 60).toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
              // Consumer<TimerModel>(
              //   builder: (context, timerModel, child) {
              //     return Text(
              //       '${(timerModel.suckingForces)}',
              //       style: TextStyle(
              //         fontSize: 8,
              //         // fontWeight: FontWeight.bold,
              //       ),
              //     );
              //   },
              // ),
              Consumer<TimerModel>(
                builder: (context, timerModel, child) {
                  return Text(
                    '${(timerModel.suckingForces).length}',
                    style: TextStyle(
                      fontSize: 8,
                      // fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
              SizedBox(
                width: 400,
                height: 200,
                child: Sparkline(
                    data: receivedData.map((i) => i.toDouble()).toList(),
                    // data: [10, 20, 5],
                    pointsMode: PointsMode.all,
                    pointSize: 7,
                    lineWidth: 2.5,
                    // kLine: ['all'],
                    xValueShow: true,
                    kLine: ['min', 'max'],
                    gridLinesEnable: true,
                    averageLine: true,
                    averageLineColor: Colors.red,
                    averageLabel: true,
                    useCubicSmoothing: true,
                    cubicSmoothingFactor: .2,
                    gridLinelabelPrefix: 'x',
                    gridLinelabelSuffix: ' J.',
                    gridLineLabelStyle: TextStyle(
                      textBaseline: TextBaseline.alphabetic,
                      color: Colors.black,
                      fontSize: 10.0,
                    )),
              ),
              SizedBox(height: 20),
              // Start Button
              ElevatedButton(
                onPressed: () {
                  receivedData.clear();
                  context.read<TimerModel>().startTimer(10); // 2 minutes 120
                  // Start listening to pressure data here
                  listenToPressureData(context); // ยังไม่พร้อม listen anan
                },
                child: Text(
                  'Start Monitoring',
                  // style: TextStyle(fontSize: 24),
                ),
                style: ElevatedButton.styleFrom(
                  // primary: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                ),
              ),
              SizedBox(height: 20),
              // Bar Chart
              Expanded(
                child:
                    // SuckingForceChart(), // This should be replaced by your chart widget
                    Text('test'),
              ),
              SizedBox(height: 20),
              // Stop Button
              ElevatedButton(
                onPressed: () {
                  context.read<TimerModel>().stopTimer();
                },
                child: Text(
                  'Stop Monitoring',
                  style: TextStyle(fontSize: 24),
                ),
                style: ElevatedButton.styleFrom(
                  // primary: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                ),
              ),
              Expanded(child: Text('Data: ${receivedData.toString()}')),
            ],
          ),
        ),
      ),
    );
  }
}

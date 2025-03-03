import 'dart:async';

import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// main Data Model for the Timer ข้อมูลที่ต้องการแชร์ให้ widget ลูกนำไปใช้งาน
class TimerModel with ChangeNotifier {
  int _seconds = 1; // Default to 2 minutes 120
  bool _isRunning = false;
  List<double> _suckingForces = [];

  int get seconds => _seconds;
  bool get isRunning => _isRunning;
  List<double> get suckingForces => _suckingForces;

  void startTimer(int duration) {
    _seconds = duration;
    _isRunning = true;
    _suckingForces.clear();
    notifyListeners();
    _startCountdown();
  }

  void stopTimer() {
    _isRunning = false;
    notifyListeners();
  }

  // นับถอยหลัง 1 วินาที
  void _startCountdown() {
    print('startCountdown');

    Timer.periodic(Duration(seconds: 1), (timer) {
      print('data $_suckingForces');
      if (_seconds > 0 && _isRunning) {
        _seconds--;
        notifyListeners();
      } else {
        _isRunning = false;
        timer.cancel();
        notifyListeners();
      }
    });
  }

  void addSuckingForce(double force) {
    if (_isRunning) {
      _suckingForces.add(force);
      notifyListeners();
    }
  }
}

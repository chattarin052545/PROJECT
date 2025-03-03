import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class TimerModel with ChangeNotifier {
  int _seconds = 30; // Default to 60 seconds
  int _initialDuration = 30; // Stores initially selected duration
  bool _isRunning = false;
  List<double> _suckingForces = [];
  final Random _random = Random(); // For generating random double values
  Timer? _inputDataTimer; // Timer for simulating Bluetooth data input

  int get seconds => _seconds;
  bool get isRunning => _isRunning;
  List<double> get suckingForces => _suckingForces;
  int get initialDuration => _initialDuration; // Getter for initial duration
  double get lastForce => _suckingForces.isNotEmpty ? _suckingForces.last : 0.0;

  void setTimer(int duration) {
    _seconds = duration;
    _initialDuration = duration; // Set initial duration
    notifyListeners();
  }

  void startTimer() {
    _isRunning = true;
    _suckingForces.clear();
    notifyListeners();
    _startCountdown();
    _startReadingData(); // Call this to start simulating Bluetooth data input
  }

  void stopTimer() {
    _isRunning = false;
    _seconds = _initialDuration; // Reset to initial duration on stop
    _inputDataTimer?.cancel(); // Stop reading data
    notifyListeners();
  }

  void _startCountdown() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (_seconds > 0 && _isRunning) {
        _seconds--;
        notifyListeners();
      } else {
        _isRunning = false;
        timer.cancel();
        _inputDataTimer?.cancel(); // Stop reading data when time is up
        notifyListeners();
      }
    });
  }

  void _startReadingData() {
    _inputDataTimer = Timer.periodic(Duration(milliseconds: 200), (timer) {
      if (_isRunning) {
        double randomForce =
            _random.nextDouble() * 100; // Generate random double
        addSuckingForce(randomForce); // Simulate reading data
      } else {
        timer.cancel(); // Stop the timer if not running
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

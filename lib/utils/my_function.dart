int countPositivePulses(List<int> data) {
  int pulseCount = 0;
  bool inPulse = false;

  for (int value in data) {
    if (value > 0) {
      if (!inPulse) {
        // Start of a new pulse
        pulseCount++;
        inPulse = true;
      }
    } else {
      // End of the current pulse
      inPulse = false;
    }
  }

  return pulseCount;
}

List<double> aggregateFx({required List<int> data}) {
  if (data.isEmpty) {
    return [0.0, 0.0, 0.0, 0.0]; // Return default values for empty list
  }
  double puleCnt = countPositivePulses(data).toDouble();
  double maxData = data.reduce((a, b) => a > b ? a : b).toDouble();
  double minData = data.reduce((a, b) => a < b ? a : b).toDouble();
  double averageData = data.reduce((a, b) => a + b) / data.length;

  return [maxData, minData, averageData, puleCnt];
}

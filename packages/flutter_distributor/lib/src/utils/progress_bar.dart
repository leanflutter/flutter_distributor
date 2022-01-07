import 'dart:async';
import 'dart:io';

class ProgressBar {
  final String format;
  final String barCompleteChar;
  final String barIncompleteChar;
  late int barSize;

  Timer? timer;

  // the current bar value
  int value = 0;

  // the end value of the bar
  int total = 100;

  // start time (used for eta calculation)
  DateTime? startTime = null;

  // stop time (used for duration calculation)
  DateTime? stopTime = null;

  // progress bar active ?
  bool isActive = false;

  ProgressBar({
    required this.format,
    this.barCompleteChar = '\u2588',
    this.barIncompleteChar = '\u2591',
  }) {
    barSize = (stdout.terminalColumns * 0.5).toInt();
  }

  /// Starts the progress bar and set the total and initial value
  void start(int totalValue, [int? startValue]) {
    // set initial values
    value = startValue ?? 0;
    total = (totalValue >= 0) ? totalValue : 100;

    // store start time for duration+eta calculation
    startTime = DateTime.now();

    // reset stop time for 're-start' scenario (used for duration calculation)
    stopTime = null;

    // set flag
    isActive = true;

    timer = Timer.periodic(Duration(milliseconds: 10), (_) {
      render();
      if (!isActive && timer?.isActive == true) {
        timer?.cancel();
        timer = null;
        stdout.writeln();
      }
    });
  }

  void update(int currentValue) {
    value = currentValue;

    if (currentValue >= total) {
      stop();
    }
  }

  /// Gets the total progress value.
  int getTotal() {
    return total;
  }

  /// Sets the total progress value while progressbar is active.
  void setTotal(totalValue) {
    if (totalValue >= 0) {
      total = totalValue;
    }
  }

  /// Stops the progress bar and go to next line
  void stop() {
    // set flag
    isActive = false;

    // store stop timestamp to get total duration
    stopTime = DateTime.now();
  }

  void render() {
    // calculate the bar complete size
    int barCompleteSize = ((value / total) * barSize).toInt();

    String bar =
        '${barCompleteChar * barCompleteSize}${barIncompleteChar * (barSize - barCompleteSize)}';
    String percentage = '${(value * 100 / total).toStringAsFixed(1)}';

    stdout.write("\r");
    stdout.write(format
        .replaceAll('{bar}', bar)
        .replaceAll('{percentage}', percentage)
        .replaceAll('{value}', '${value}')
        .replaceAll('{total}', '${total}'));
  }
}

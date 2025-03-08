import 'dart:async';
import 'dart:io';

/// A customizable command-line progress bar.
///
/// This class provides a simple way to display progress in command-line applications.
/// It supports customization of appearance, automatic updates, and calculation of
/// progress statistics like duration and ETA.
class ProgressBar {
  /// Creates a new progress bar with the specified format and appearance.
  ///
  /// The [format] string can include the following placeholders:
  /// - {bar}: The progress bar itself
  /// - {percentage}: The progress percentage (e.g., "42.0")
  /// - {value}: The current value
  /// - {total}: The total value
  /// - {duration}: The elapsed time in seconds
  /// - {eta}: The estimated time remaining in seconds
  ProgressBar({
    required this.format,
    this.barCompleteChar = '\u2588',
    this.barIncompleteChar = '\u2591',
    this.barSize = 40,
    this.updateInterval = const Duration(milliseconds: 100),
  });

  /// The format string for the progress bar.
  final String format;
  
  /// The character used for completed portions of the bar.
  final String barCompleteChar;
  
  /// The character used for incomplete portions of the bar.
  final String barIncompleteChar;
  
  /// The total width of the progress bar in characters.
  final int barSize;
  
  /// How frequently the progress bar should update on screen.
  final Duration updateInterval;

  Timer? _timer;

  /// The current progress value.
  int _value = 0;

  /// The end value of the bar.
  int _total = 100;

  /// Start time (used for duration and ETA calculation).
  DateTime? _startTime;

  /// Stop time (used for duration calculation).
  DateTime? _stopTime;

  /// Whether the progress bar is currently active.
  bool _isActive = false;

  /// Gets the current progress value.
  int get value => _value;

  /// Gets the total progress value.
  int get total => _total;

  /// Gets whether the progress bar is active.
  bool get isActive => _isActive;

  /// Gets the elapsed duration in seconds.
  double get duration {
    if (_startTime == null) return 0;
    final end = _stopTime ?? DateTime.now();
    return end.difference(_startTime!).inMilliseconds / 1000;
  }

  /// Gets the estimated time remaining in seconds.
  double get eta {
    if (_startTime == null || _value <= 0 || _value >= _total) return 0;
    final elapsed = DateTime.now().difference(_startTime!).inMilliseconds / 1000;
    final rate = _value / elapsed;
    return rate > 0 ? (_total - _value) / rate : 0;
  }

  /// Starts the progress bar and sets the total and initial value.
  ///
  /// [totalValue] is the maximum value for the progress bar.
  /// [startValue] is the initial value (defaults to 0).
  void start(int totalValue, [int? startValue]) {
    // Validate inputs
    if (totalValue < 0) {
      throw ArgumentError('Total value must be non-negative');
    }
    
    if (startValue != null && (startValue < 0 || startValue > totalValue)) {
      throw ArgumentError('Start value must be between 0 and total value');
    }
    
    // Set initial values
    _value = startValue ?? 0;
    _total = totalValue;

    // Store start time for duration+eta calculation
    _startTime = DateTime.now();

    // Reset stop time for 're-start' scenario
    _stopTime = null;

    // Set flag
    _isActive = true;

    // Cancel existing timer if any
    _timer?.cancel();
    
    // Start new timer
    _timer = Timer.periodic(updateInterval, (_) {
      render();
      if (!_isActive && _timer?.isActive == true) {
        _timer?.cancel();
        _timer = null;
        stdout.writeln();
      }
    });
    
    // Initial render
    render();
  }

  /// Updates the current progress value.
  ///
  /// If the value reaches or exceeds the total, the progress bar will stop automatically.
  void update(int currentValue) {
    if (!_isActive) {
      return;
    }
    
    if (currentValue < 0) {
      throw ArgumentError('Current value must be non-negative');
    }
    
    if (_value == currentValue) return;
    _value = currentValue;

    if (currentValue >= _total) {
      stop();
    }
  }

  /// Increments the current progress value by the specified amount.
  void increment([int amount = 1]) {
    if (amount <= 0) {
      throw ArgumentError('Increment amount must be positive');
    }
    update(_value + amount);
  }

  /// Sets the total progress value while the progress bar is active.
  void setTotal(int totalValue) {
    if (totalValue < 0) {
      throw ArgumentError('Total value must be non-negative');
    }
    
    if (totalValue < _value) {
      throw ArgumentError('New total cannot be less than current value');
    }
    
    _total = totalValue;
  }

  /// Stops the progress bar and moves to the next line.
  void stop() {
    // Set flag
    _isActive = false;

    // Store stop timestamp to get total duration
    _stopTime = DateTime.now();
    
    // Final render to show 100% completion
    render();
  }

  /// Renders the current state of the progress bar to stdout.
  void render() {
    // Calculate the bar complete size
    final barCompleteSize = ((_value / _total) * barSize).round().clamp(0, barSize);
    
    final bar = barCompleteChar * barCompleteSize + 
                barIncompleteChar * (barSize - barCompleteSize);
    
    final percentage = (_value * 100 / _total).toStringAsFixed(1);
    final durationStr = duration.toStringAsFixed(1);
    final etaStr = eta.toStringAsFixed(1);

    stdout.write('\r');
    stdout.write(
      format
          .replaceAll('{bar}', bar)
          .replaceAll('{percentage}', percentage)
          .replaceAll('{value}', '$_value')
          .replaceAll('{total}', '$_total')
          .replaceAll('{duration}', durationStr)
          .replaceAll('{eta}', etaStr),
    );
  }
  
  /// Disposes of resources used by the progress bar.
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _isActive = false;
  }
}

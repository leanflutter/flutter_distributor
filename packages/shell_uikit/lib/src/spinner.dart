import 'dart:async';
import 'dart:io';

/// A command-line spinner component that shows an animation
/// to indicate a loading or processing state.
class Spinner {
  /// Creates a new spinner with the specified configuration.
  ///
  /// [text] is the message displayed next to the spinner.
  /// [spinnerType] defines the animation style (default is 'dots').
  Spinner({
    String text = 'Loading',
    this.spinnerType = SpinnerType.dots,
    this.interval = const Duration(milliseconds: 80),
  }) : _text = text;

  /// The text displayed next to the spinner.
  String _text;

  /// Gets the current spinner text.
  String get text => _text;

  /// The type of spinner animation to display.
  final SpinnerType spinnerType;

  /// The interval between animation frames.
  final Duration interval;

  /// Timer that controls the animation.
  Timer? _timer;

  /// Current frame index in the animation sequence.
  int _frameIndex = 0;

  /// Whether the spinner is currently running.
  bool get isRunning => _timer != null;

  /// Starts the spinner animation.
  void start() {
    if (_timer != null) return;

    // Record the start time
    _frameIndex = 0;

    // Clear the current line
    stdout.write('\r');

    // Start the animation timer
    _timer = Timer.periodic(interval, (_) {
      _draw();
    });
  }

  /// Stops the spinner animation.
  void stop() {
    _timer?.cancel();
    _timer = null;

    // Clear the spinner line
    _clearLine();
  }

  /// Stops the spinner and shows a success message.
  void success([String? message]) {
    stop();
    if (message != null) {
      stdout.write('\r✓ $message\n');
    }
  }

  /// Stops the spinner and shows an error message.
  void error([String? message]) {
    stop();
    if (message != null) {
      stdout.write('\r✗ $message\n');
    }
  }

  /// Stops the spinner and shows an info message.
  void info([String? message]) {
    stop();
    if (message != null) {
      stdout.write('\rℹ $message\n');
    }
  }

  /// Stops the spinner and shows a warning message.
  void warn([String? message]) {
    stop();
    if (message != null) {
      stdout.write('\r⚠ $message\n');
    }
  }

  /// Updates the spinner text while it's running.
  void updateText(String newText) {
    if (_text != newText) {
      _clearLine();
      _text = newText;
      if (isRunning) {
        _draw();
      }
    }
  }

  /// Draws the current frame of the spinner animation.
  void _draw() {
    final frames = _getFrames();
    final frame = frames[_frameIndex % frames.length];

    // Clear the current line and write the new frame
    stdout.write('\r$frame $_text');

    // Move to the next frame
    _frameIndex++;
  }

  /// Clears the current line in the terminal.
  void _clearLine() {
    stdout.write('\r${' ' * (_text.length + 10)}\r');
  }

  /// Gets the animation frames based on the selected spinner type.
  List<String> _getFrames() {
    switch (spinnerType) {
      case SpinnerType.dots:
        return ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'];
      case SpinnerType.line:
        return ['-', '\\', '|', '/'];
      case SpinnerType.growVertical:
        return ['▁', '▃', '▄', '▅', '▆', '▇', '█', '▇', '▆', '▅', '▄', '▃'];
      case SpinnerType.growHorizontal:
        return ['▏', '▎', '▍', '▌', '▋', '▊', '▉', '█'];
      case SpinnerType.circle:
        return ['◜', '◠', '◝', '◞', '◡', '◟'];
      case SpinnerType.dots2:
        return ['.  ', '.. ', '...', ' ..', '  .', '   '];
      case SpinnerType.bounce:
        return ['⠁', '⠂', '⠄', '⠂'];
      case SpinnerType.arrows:
        return ['←', '↖', '↑', '↗', '→', '↘', '↓', '↙'];
    }
  }
}

/// Defines different spinner animation styles.
enum SpinnerType {
  /// Braille dots animation (default)
  dots,

  /// Simple line animation
  line,

  /// Growing vertical bar
  growVertical,

  /// Growing horizontal bar
  growHorizontal,

  /// Circle animation
  circle,

  /// Simple dots animation
  dots2,

  /// Bouncing animation
  bounce,

  /// Rotating arrows
  arrows,
}

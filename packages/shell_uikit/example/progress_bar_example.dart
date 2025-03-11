import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:shell_uikit/shell_uikit.dart';

/// This example demonstrates various ways to use the ProgressBar component.
void main() async {
  // Clear the screen
  if (Platform.isWindows) {
    stdout.write('\x1B[2J\x1B[0f');
  } else {
    stdout.write('\x1B[2J\x1B[H');
  }

  stdout.writeln('ProgressBar Examples\n');

  // Run examples one by one
  await basicExample();
  await customFormatExample();
  await customAppearanceExample();
  await incrementExample();
  await simulateDownloadExample();
  await multipleProgressBarsExample();

  stdout.writeln('\nAll examples completed!');
}

/// Basic usage of ProgressBar
Future<void> basicExample() async {
  stdout.writeln('1. Basic Progress Bar:');

  // Create a simple progress bar
  final progressBar = ProgressBar(
    format: '[{bar}] {percentage}% ({value}/{total})',
  );

  // Start the progress bar with a total of 100
  progressBar.start(100);

  // Update the progress bar in a loop
  for (int i = 0; i <= 100; i++) {
    await Future.delayed(Duration(milliseconds: 20));
    progressBar.update(i);
  }

  // Progress bar will automatically stop when it reaches 100%
  await Future.delayed(Duration(milliseconds: 500));
  stdout.writeln('\n');
}

/// Example with custom format including duration and ETA
Future<void> customFormatExample() async {
  stdout.writeln('2. Custom Format with Duration and ETA:');

  // Create a progress bar with custom format
  final progressBar = ProgressBar(
    format: '[{bar}] {percentage}% | Elapsed: {duration}s | ETA: {eta}s',
  );

  // Start the progress bar with a total of 50
  progressBar.start(50);

  // Update the progress bar with varying speed to demonstrate ETA changes
  for (int i = 0; i <= 50; i++) {
    // Simulate varying processing speed
    final delay = 30 + (math.sin(i / 5) * 20).round();
    await Future.delayed(Duration(milliseconds: delay));
    progressBar.update(i);
  }

  await Future.delayed(Duration(milliseconds: 500));
  stdout.writeln('\n');
}

/// Example with custom appearance
Future<void> customAppearanceExample() async {
  stdout.writeln('3. Custom Appearance:');

  // Create a progress bar with custom characters and size
  final progressBar = ProgressBar(
    format: '[{bar}] {percentage}%',
    barCompleteChar: '█', // Full block
    barIncompleteChar: '░', // Light shade
    barSize: 30, // Shorter bar
  );

  progressBar.start(100);

  for (int i = 0; i <= 100; i++) {
    await Future.delayed(Duration(milliseconds: 15));
    progressBar.update(i);
  }

  await Future.delayed(Duration(milliseconds: 500));
  stdout.writeln('\n');
}

/// Example using increment method
Future<void> incrementExample() async {
  stdout.writeln('4. Using Increment Method:');

  final progressBar = ProgressBar(
    format: '[{bar}] {percentage}% | {value}/{total} steps completed',
  );

  // Start with a total of 20 steps
  progressBar.start(20);

  // Increment by different amounts
  for (int i = 0; i < 5; i++) {
    await Future.delayed(Duration(milliseconds: 300));
    progressBar.increment(); // Increment by 1 (default)
  }

  for (int i = 0; i < 3; i++) {
    await Future.delayed(Duration(milliseconds: 500));
    progressBar.increment(2); // Increment by 2
  }

  await Future.delayed(Duration(milliseconds: 700));
  progressBar.increment(5); // Increment by 5

  await Future.delayed(Duration(milliseconds: 1000));
  progressBar.update(20); // Complete

  await Future.delayed(Duration(milliseconds: 500));
  stdout.writeln('\n');
}

/// Example simulating a file download with changing total
Future<void> simulateDownloadExample() async {
  stdout.writeln('5. Simulating Download (with changing total):');

  final progressBar = ProgressBar(
    format: '[{bar}] {percentage}% | {value}/{total} KB | {duration}s elapsed',
  );

  // Start with an initial estimate
  progressBar.start(1000);

  int value = 0;

  // Simulate download with varying speed and changing total size
  for (int i = 0; i < 20; i++) {
    await Future.delayed(Duration(milliseconds: 200));

    // Simulate downloaded chunk
    final chunk = 50 + (math.Random().nextInt(50));
    value += chunk;
    progressBar.update(value);

    // Occasionally update the total size (simulating better estimates as download progresses)
    if (i == 5) {
      progressBar.setTotal(1200);
      stdout.writeln('\n   (Download size updated to 1200 KB)');
    } else if (i == 12) {
      progressBar.setTotal(1500);
      stdout.writeln('\n   (Download size updated to 1500 KB)');
    }
  }

  // Complete the download
  progressBar.update(progressBar.total);

  await Future.delayed(Duration(milliseconds: 500));
  stdout.writeln('\n');
}

/// Example showing multiple progress bars
Future<void> multipleProgressBarsExample() async {
  stdout.writeln('6. Multiple Progress Bars:');
  stdout.writeln('   (Three tasks running at different speeds)');

  // Create three progress bars with different formats
  final task1 = ProgressBar(
    format: 'Task 1: [{bar}] {percentage}%',
    barCompleteChar: '=',
    barIncompleteChar: ' ',
  );

  final task2 = ProgressBar(
    format: 'Task 2: [{bar}] {percentage}%',
    barCompleteChar: '#',
    barIncompleteChar: '-',
  );

  final task3 = ProgressBar(
    format: 'Task 3: [{bar}] {percentage}%',
    barCompleteChar: '■',
    barIncompleteChar: '□',
  );

  // Start all tasks
  task1.start(100);
  stdout.writeln();
  task2.start(100);
  stdout.writeln();
  task3.start(100);

  // Update tasks at different speeds
  for (int i = 0; i <= 100; i++) {
    await Future.delayed(Duration(milliseconds: 30));

    if (i <= 100) task1.update(i);
    if (i <= 100 && i % 2 == 0) task2.update(i ~/ 2);
    if (i <= 100 && i % 3 == 0) task3.update(i ~/ 3);
  }

  // Wait for task2 to complete
  for (int i = 51; i <= 100; i++) {
    await Future.delayed(Duration(milliseconds: 60));
    task2.update(i);
  }

  // Wait for task3 to complete
  for (int i = 34; i <= 100; i++) {
    await Future.delayed(Duration(milliseconds: 90));
    task3.update(i);
  }

  await Future.delayed(Duration(milliseconds: 500));
  stdout.writeln('\n');

  // Make sure to dispose all progress bars
  task1.dispose();
  task2.dispose();
  task3.dispose();
}

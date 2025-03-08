import 'dart:async';
import 'package:shell_uikit/shell_uikit.dart';

/// This example demonstrates how to use various features of the Spinner component
void main() async {
  print('Spinner Component Examples\n');
  
  // Basic usage example
  await basicExample();
  
  // Show all animation types
  await allSpinnerTypesExample();
  
  // Demonstrate text updating functionality
  await updateTextExample();
  
  // Show different status messages
  await statusMessagesExample();
  
  print('\nAll examples completed!');
}

/// Demonstrates basic usage of Spinner
Future<void> basicExample() async {
  print('1. Basic Usage Example:');
  
  final spinner = Spinner(text: 'Loading...');
  spinner.start();
  
  // Simulate some time-consuming operation
  await Future.delayed(const Duration(seconds: 2));
  
  spinner.success('Loading completed!');
  await Future.delayed(const Duration(milliseconds: 500));
}

/// Shows all available Spinner animation types
Future<void> allSpinnerTypesExample() async {
  print('\n2. All Animation Types Example:');
  
  final spinnerTypes = SpinnerType.values;
  
  for (final type in spinnerTypes) {
    final spinner = Spinner(
      text: '${type.name} type animation',
      spinnerType: type,
    );
    
    spinner.start();
    await Future.delayed(const Duration(seconds: 2));
    spinner.stop();
    
    print('  - Displayed ${type.name} type');
    await Future.delayed(const Duration(milliseconds: 300));
  }
}

/// Demonstrates how to update text while Spinner is running
Future<void> updateTextExample() async {
  print('\n3. Text Update Example:');
  
  final spinner = Spinner(text: 'Initial text');
  spinner.start();
  
  await Future.delayed(const Duration(seconds: 1));
  spinner.updateText('Updated text 1');
  
  await Future.delayed(const Duration(seconds: 1));
  spinner.updateText('Updated text 2');
  
  await Future.delayed(const Duration(seconds: 1));
  spinner.updateText('Updated text 3');
  
  await Future.delayed(const Duration(seconds: 1));
  spinner.success('Text update example completed');
  await Future.delayed(const Duration(milliseconds: 500));
}

/// Shows different status messages (success, error, info, warning)
Future<void> statusMessagesExample() async {
  print('\n4. Status Messages Example:');
  
  // Success message
  var spinner = Spinner(text: 'Processing success message');
  spinner.start();
  await Future.delayed(const Duration(seconds: 1));
  spinner.success('Operation completed successfully');
  await Future.delayed(const Duration(milliseconds: 500));
  
  // Error message
  spinner = Spinner(text: 'Processing error message');
  spinner.start();
  await Future.delayed(const Duration(seconds: 1));
  spinner.error('Operation failed');
  await Future.delayed(const Duration(milliseconds: 500));
  
  // Info message
  spinner = Spinner(text: 'Processing info message');
  spinner.start();
  await Future.delayed(const Duration(seconds: 1));
  spinner.info('This is an information message');
  await Future.delayed(const Duration(milliseconds: 500));
  
  // Warning message
  spinner = Spinner(text: 'Processing warning message');
  spinner.start();
  await Future.delayed(const Duration(seconds: 1));
  spinner.warn('This is a warning message');
  await Future.delayed(const Duration(milliseconds: 500));
} 
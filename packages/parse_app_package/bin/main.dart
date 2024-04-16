import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:parse_app_package/parse_app_package.dart';

JsonEncoder _encoder = const JsonEncoder.withIndent('  ');

Future<void> main(List<String> args) async {
  ArgParser argParser = ArgParser();

  ArgResults argResults = argParser.parse(args);

  String path = argResults.arguments.first;
  AppPackage appPackage = await parseAppPackage(File(path));

  print(_encoder.convert(appPackage.toJson()));
}

import 'package:logging/logging.dart';

Logger logger = Logger('any_app_packager')
  ..onRecord.listen((record) {
    print(record.message);
  });

import 'package:logging/logging.dart';

Logger logger = Logger('unified_distributor')
  ..onRecord.listen((record) {
    print(record.message);
  });

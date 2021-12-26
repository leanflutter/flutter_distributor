import 'package:logging/logging.dart';

Logger logger = Logger('flutter_distributor')
  ..onRecord.listen((record) {
    print(record.message);
  });

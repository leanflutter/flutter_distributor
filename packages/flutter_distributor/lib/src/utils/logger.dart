import 'package:logging/logging.dart';

Logger logger = Logger('flutter_distributor')
  ..onRecord.listen((record) {
    String log = '${record.level.name}: ${record.time}: ${record.message}';
    print(log);
  });

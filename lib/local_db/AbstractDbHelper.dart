import 'DbHelper.dart';

abstract class AbstractDbHelper implements DbHelper {
  @override
  Future<int> truncateTable(String tableName) {
    return Future(() => 0);
  }
}

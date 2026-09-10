import 'dart:async';

abstract class DbHelper<T> {
  Future<T> save(T t, String tableName);
  Future<T> update(T t, String tableName);
  Future<bool> delete(int id, String tableName);
  Future<List<T>> select(T t, String tableName);
  Future<List<T>> selectAll(String tableName);
  Future<List<T>> selectById(int id, String tableName);
  Future<List<T>> selectBy(Map<String, dynamic> cols, String tableName);

  Future<List<T>> mapper(List<Map> tMaps);

  Future<int> truncateTable(String tableName);
}

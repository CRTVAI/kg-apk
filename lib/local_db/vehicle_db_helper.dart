import 'dart:async';

import 'package:cargo/models/vehicle_list_response.dart';

import 'Db.dart';
import 'DbHelper.dart';

class VehicleDbHelper extends DbHelper<VehicleList> {
  Db _db = Db();

  @override
  Future<VehicleList> save(VehicleList t, String tableName) async {
    var db = await _db.db;
    t.id = await db!.insert(tableName, t.toJson());
    return t;
  }

  @override
  Future<List<VehicleList>> select(VehicleList t, String tblName) async {
    var db = await _db.db;
    List<Map> prefs = await db!.query(tblName, columns: null);
    List<VehicleList> rList = [];
    return rList;
  }

  @override
  Future<bool> delete(int id, String tableName) async {
    var db = await _db.db;
    List<dynamic> list = [];
    list.add(id);
    return true;
  }

  @override
  Future<int> truncateTable(String tblName) async {
    var db = await _db.db;
    db!.execute('DELETE FROM ' + tblName, []);
    return 1;
  }

  @override
  Future<VehicleList> update(VehicleList t, String tableName) async {
    return t;
  }

  @override
  Future<List<VehicleList>> selectBy(
      Map<String, dynamic> cols, String tableName) async {
    List<VehicleList> rList = [];
    return rList;
  }

  @override
  Future<List<VehicleList>> selectById(int id, String tableName) async {
    List<VehicleList> rList = [];
    return rList;
  }

  @override
  Future<List<VehicleList>> selectAll(String tblName) async {
    var db = await _db.db;
    List<Map> prefs = await db!.query(tblName, columns: null);
    return await mapper(prefs);
  }

  @override
  Future<List<VehicleList>> mapper(List<Map> tMaps) async {
    List<VehicleList> prefList = [];
    if (tMaps == null || tMaps.length == 0) {
      return prefList;
    }
    for (var i = 0; i < tMaps.length; i++) {
      prefList.add(VehicleList.fromJson(tMaps[i]));
    }
    return prefList;
  }
}

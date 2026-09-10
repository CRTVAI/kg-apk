import 'dart:async';

import 'package:cargo/models/vehicle_list_response.dart';

import 'Db.dart';
import 'DbHelper.dart';

class VehicleImageDbHelper extends DbHelper<VehicleImage> {
  Db _db = Db();

  @override
  Future<VehicleImage> save(VehicleImage t, String tableName) async {
    var db = await _db.db;
    t.id = await db!.insert(tableName, t.toJson());
    return t;
  }

  @override
  Future<List<VehicleImage>> select(VehicleImage t, String tblName) async {
    var db = await _db.db;
    List<Map> prefs = await db!.query(tblName, columns: null);
    List<VehicleImage> rList = [];
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
  Future<VehicleImage> update(VehicleImage t, String tableName) async {
    return t;
  }

  @override
  Future<List<VehicleImage>> selectBy(
      Map<String, dynamic> cols, String tableName) async {
    List<VehicleImage> rList = [];
    return rList;
  }

  @override
  Future<List<VehicleImage>> selectById(int id, String tableName) async {
    List<VehicleImage> rList = [];
    return rList;
  }

  @override
  Future<List<VehicleImage>> selectAll(String tblName) async {
    var db = await _db.db;
    List<Map> prefs = await db!.query(tblName, columns: null);
    return await mapper(prefs);
  }

  Future<List<VehicleImage>> getVehicleImageByVehicleId(
      String tblName, int vehicleId) async {
    var db = await _db.db;
    List<Map> prefs = await db!.query(tblName,
        columns: null, where: 'vehicle_id = ?', whereArgs: [vehicleId]);
    return await mapper(prefs);
  }

  @override
  Future<List<VehicleImage>> mapper(List<Map> tMaps) async {
    List<VehicleImage> prefList = [];
    if (tMaps == null || tMaps.length == 0) {
      return prefList;
    }
    for (var i = 0; i < tMaps.length; i++) {
      prefList.add(VehicleImage.fromJson(tMaps[i]));
    }
    return prefList;
  }
}

import 'dart:async';

import 'package:cargo/models/container_list_response.dart';
import 'package:cargo/models/vehicle_list_response.dart';

import 'Db.dart';
import 'DbHelper.dart';

class ContainerDbHelper extends DbHelper<Containers> {
  Db _db = Db();

  @override
  Future<Containers> save(Containers t, String tableName) async {
    var db = await _db.db;
    t.id = await db!.insert(tableName, {
      'id': t.id,
      'status_id': t.statusId,
      'shipper_id': t.shipperId,
      'shipping_line_id': t.shippingLineId,
      'booking_no': t.bookingNo,
      'container_no': t.containerNo,
      'status_name': t.status == null ? '' : t.status!.name,
      'shipping_line_name': t.shippingLine == null ? '' : t.shippingLine!.name,
      'consignee_name': t.consignee == null ? '' : t.consignee!.companyName,
      'consignee_address': t.consignee == null ? '' : t.consignee!.address,
      'loading_port_name': t.loadingPort == null ? '' : t.loadingPort!.name,
      'destination_port_name':
          t.destinationPort == null ? '' : t.destinationPort!.name,
      'departure': t.departure,
      'arrival': t.arrival,
    });
    return t;
  }

  @override
  Future<List<Containers>> select(Containers t, String tblName) async {
    var db = await _db.db;
    List<Map> prefs = await db!.query(tblName, columns: null);
    List<Containers> rList = [];
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
  Future<Containers> update(Containers t, String tableName) async {
    return t;
  }

  @override
  Future<List<Containers>> selectBy(
      Map<String, dynamic> cols, String tableName) async {
    List<Containers> rList = [];
    return rList;
  }

  @override
  Future<List<Containers>> selectById(int id, String tableName) async {
    List<Containers> rList = [];
    return rList;
  }

  @override
  Future<List<Containers>> selectAll(String tblName) async {
    var db = await _db.db;
    List<Map> prefs = await db!.query(tblName, columns: null);
    return await mapper(prefs);
  }

  @override
  Future<List<Containers>> mapper(List<Map> tMaps) async {
    List<Containers> prefList = [];
    if (tMaps == null || tMaps.length == 0) {
      return prefList;
    }
    for (var i = 0; i < tMaps.length; i++) {
      // prefList.add(Containers.fromJson(tMaps[i]));
    }
    return prefList;
  }
}

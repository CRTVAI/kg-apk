// To parse this JSON data, do
//
//     final pickupRequestResponse = pickupRequestResponseFromJson(jsonString);

import 'dart:convert';

import 'destination_port_response.dart';
import 'login_response.dart';
import 'vehicle_list_response.dart';

PickupRequestResponse pickupRequestResponseFromJson(String str) =>
    PickupRequestResponse.fromJson(json.decode(str));

String pickupRequestResponseToJson(PickupRequestResponse data) =>
    json.encode(data.toJson());

class PickupRequestResponse {
  dynamic success;
  List<PickupRequest> pickupRequestList;
  dynamic message;

  PickupRequestResponse({
    this.success,
    required this.pickupRequestList,
    this.message,
  });

  factory PickupRequestResponse.fromJson(Map<String, dynamic> json) =>
      PickupRequestResponse(
        success: json["success"],
        pickupRequestList: List<PickupRequest>.from(
            json["data"].map((x) => PickupRequest.fromJson(x))),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": List<dynamic>.from(pickupRequestList.map((x) => x.toJson())),
        "message": message,
      };
}

class PickupRequest {
  int id;
  int? userId;
  int? vehicleId;
  String? comments;
  String? type;
  String? pickerName;
  String? file;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic paymentStatus;
  Vehicle? vehicle;
  AppUser? user;
  PickupRequest(
      {required this.id,
      this.userId,
      this.vehicleId,
      this.comments,
      this.type,
      this.pickerName,
      this.file,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.paymentStatus,
      this.vehicle,
      this.user});

  factory PickupRequest.fromJson(Map<String, dynamic> json) => PickupRequest(
        id: int.tryParse('${json["id"] ?? 0}') ?? 0,
        userId: _intFromJson(json["user_id"]),
        vehicleId: _intFromJson(json["vehicle_id"]),
        comments: _stringFromJson(json["comments"]),
        type: _stringFromJson(json["type"] ?? json["request_type"]),
        pickerName: _stringFromJson(json["picker_name"] ?? json["name"]),
        file: _stringFromJson(json["file"]),
        status: _stringFromJson(json["status"]),
        createdAt: _dateFromJson(json["created_at"]),
        updatedAt: _dateFromJson(json["updated_at"]),
        paymentStatus: json['payment_status'],
        vehicle: _vehicleFromJson(json["vehicle"]),
        user: _userFromJson(json["user"]),
      );

  static int? _intFromJson(dynamic value) {
    if (value == null) return null;
    return int.tryParse('$value');
  }

  static String? _stringFromJson(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }

  static Vehicle? _vehicleFromJson(dynamic value) {
    if (value is! Map) return null;
    final json = Map<String, dynamic>.from(value);
    try {
      return Vehicle.fromJson(json);
    } catch (_) {
      return Vehicle(
        id: _intFromJson(json["id"]) ?? 0,
        companyName: json["company_name"],
        name: json["name"],
        modal: json["modal"],
        vin: json["vin"],
        lotnumber: json["lotnumber"] ?? json["lot"],
        destinationManual: json["destination_manual"],
        destinationPort: _destinationFromJson(json["destination_port"]),
      );
    }
  }

  static DestinationPort? _destinationFromJson(dynamic value) {
    if (value is! Map) return null;
    try {
      return DestinationPort.fromJson(Map<String, dynamic>.from(value));
    } catch (_) {
      return null;
    }
  }

  static AppUser? _userFromJson(dynamic value) {
    if (value is! Map) return null;
    try {
      return AppUser.fromJson(Map<String, dynamic>.from(value));
    } catch (_) {
      return null;
    }
  }

  static DateTime? _dateFromJson(dynamic value) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty || text == '0000-00-00') return null;
    return DateTime.tryParse(text);
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "vehicle_id": vehicleId,
        "comments": comments,
        "type": type,
        "request_type": type,
        "picker_name": pickerName,
        "file": file,
        "status": status,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "payment_status": paymentStatus,
        "vehicle": vehicle?.toJson(),
        "user": user?.toJson()
      };
}

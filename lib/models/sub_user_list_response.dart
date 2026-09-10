// To parse this JSON data, do
//
//     final subUserListResponse = subUserListResponseFromJson(jsonString);

import 'dart:convert';

import 'package:cargo/models/login_response.dart';

SubUserListResponse subUserListResponseFromJson(String str) =>
    SubUserListResponse.fromJson(json.decode(str));

String subUserListResponseToJson(SubUserListResponse data) =>
    json.encode(data.toJson());

class SubUserListResponse {
  dynamic success;
  List<AppUser> subUserList;
  dynamic message;

  SubUserListResponse({
    this.success,
    required this.subUserList,
    this.message,
  });

  factory SubUserListResponse.fromJson(Map<String, dynamic> json) =>
      SubUserListResponse(
        success: json["success"],
        subUserList:
            List<AppUser>.from(json["data"].map((x) => AppUser.fromJson(x))),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": List<dynamic>.from(subUserList.map((x) => x.toJson())),
        "message": message,
      };
}

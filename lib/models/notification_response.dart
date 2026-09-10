// // To parse this JSON data, do
// //
// //     final notificationResponse = notificationResponseFromJson(jsonString);
//
// import 'dart:convert';
//
// import 'package:cargo/models/container_list_response.dart';
// import 'package:cargo/models/vehicle_list_response.dart';
//
// import 'login_response.dart';
//
// NotificationResponses notificationResponseFromJson(String str) => NotificationResponses.fromJson(json.decode(str));
//
// String notificationResponseToJson(NotificationResponses data) => json.encode(data.toJson());
//
// class NotificationResponses {
//   int id;
//   int userId;
//   int vehicleId;
//   int assignedTo;
//   dynamic createdAt;
//   DateTime? updatedAt;
//   AppUser user;
//   Vehicle vehicle;
//   Containers? container;
//
//   NotificationResponses({
//     required this.id,
//     required this.userId,
//     required this.vehicleId,
//     required this.assignedTo,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.user,
//     required this.vehicle,
//     required this.container,
//   });
//
//   factory NotificationResponses.fromJson(Map<String, dynamic> json) => NotificationResponses(
//     id: json["id"],
//     userId: json["user_id"],
//     vehicleId: json["vehicle_id"],
//     assignedTo: json["assigned_to"],
//     createdAt: json["created_at"],
//     updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
//     user: AppUser.fromJson(json["user"]),
//     vehicle: Vehicle.fromJson(json["vehicle"]),
//     container: json["container"] == null ? null : Containers.fromJson(json["container"]),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "id": id,
//     "user_id": userId,
//     "vehicle_id": vehicleId,
//     "assigned_to": assignedTo,
//     "created_at": createdAt,
//     "updated_at": updatedAt?.toIso8601String(),
//     "user": user.toJson(),
//     "vehicle": vehicle.toJson(),
//     "container": container?.toJson(),
//   };
// }
//

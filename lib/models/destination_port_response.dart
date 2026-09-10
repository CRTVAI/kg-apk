// To parse this JSON data, do
//
//     final destinationPortResponse = destinationPortResponseFromJson(jsonString);

import 'dart:convert';

DestinationPortResponse destinationPortResponseFromJson(String str) =>
    DestinationPortResponse.fromJson(json.decode(str));

String destinationPortResponseToJson(DestinationPortResponse data) =>
    json.encode(data.toJson());

class DestinationPortResponse {
  bool? success;
  DestinationData destinationData;
  String? message;

  DestinationPortResponse({
    this.success,
    required this.destinationData,
    required this.message,
  });

  factory DestinationPortResponse.fromJson(Map<String, dynamic> json) =>
      DestinationPortResponse(
        success: json["success"],
        destinationData: DestinationData.fromJson(json["data"]),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": destinationData.toJson(),
        "message": message,
      };
}

class DestinationData {
  List<DestinationPort>? destinationList;
  List<DestinationPort>? shippingLineList;

  DestinationData({
    this.destinationList,
    this.shippingLineList,
  });

  factory DestinationData.fromJson(Map<String, dynamic> json) =>
      DestinationData(
        destinationList: json["destination"] == null
            ? null
            : List<DestinationPort>.from(
                json["destination"].map((x) => DestinationPort.fromJson(x))),
        shippingLineList: json["shipping_line"] == null
            ? null
            : List<DestinationPort>.from(
                json["shipping_line"].map((x) => DestinationPort.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "destination":
            List<dynamic>.from(destinationList!.map((x) => x.toJson())),
        "shipping_line":
            List<dynamic>.from(shippingLineList!.map((x) => x.toJson())),
      };
}

class DestinationPort {
  int id;
  dynamic name;
  dynamic position;
  dynamic unloadingFee;
  dynamic scacCode;

  DestinationPort(
      {required this.id,
      required this.name,
      this.position,
      this.unloadingFee,
      this.scacCode});

  factory DestinationPort.fromJson(Map<String, dynamic> json) =>
      DestinationPort(
        id: json["id"],
        name: json["name"],
        position: json["position"],
        unloadingFee: json["unloading_fee"],
        scacCode: json["scac_code"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "position": position,
        "unloading_fee": unloadingFee,
        "scac_code": scacCode,
      };

  @override
  String toString() {
    return '${name}';
  }
}

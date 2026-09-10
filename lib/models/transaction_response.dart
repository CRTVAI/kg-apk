// To parse this JSON data, do
//
//     final destinationPortResponse = destinationPortResponseFromJson(jsonString);

import 'dart:convert';

import 'package:cargo/models/vehicle_list_response.dart';

TransactionResponse transactionResponseFromJson(String str) =>
    TransactionResponse.fromJson(json.decode(str));

String transactionResponseToJson(TransactionResponse data) =>
    json.encode(data.toJson());

class TransactionResponse {
  bool? success;
  TransactionData? transactionData;
  String? message;

  TransactionResponse({
    this.success,
    this.transactionData,
    this.message,
  });

  factory TransactionResponse.fromJson(Map<String, dynamic> json) =>
      TransactionResponse(
        success: json["success"],
        transactionData: json["data"] == null
            ? null
            : TransactionData.fromJson(json["data"]),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": transactionData!.toJson(),
        "message": message,
      };
}

class TransactionData {
  List<TransactionHistory> transactionHistory;
  dynamic totalTransactions;
  dynamic lastTransactionAmount;
  dynamic balance;
  dynamic duePaymentsLimit;
  dynamic duePayments;

  TransactionData({
    required this.transactionHistory,
    this.totalTransactions,
    this.lastTransactionAmount,
    this.balance,
    this.duePaymentsLimit,
    this.duePayments,
  });

  factory TransactionData.fromJson(Map<String, dynamic> json) =>
      TransactionData(
        transactionHistory: json["history"] == null
            ? []
            : List<TransactionHistory>.from(
                json["history"].map((x) => TransactionHistory.fromJson(x))),
        totalTransactions: json["total_transactions"],
        lastTransactionAmount: json["last_transaction_amount"],
        balance: json["balance"],
        duePaymentsLimit: json["due_payments_limit"],
        duePayments: json["due_payments"],
      );

  Map<String, dynamic> toJson() => {
        "history":
            List<dynamic>.from(transactionHistory.map((x) => x.toJson())),
        "total_transactions": totalTransactions,
        "last_transaction_amount": lastTransactionAmount,
        "balance": balance,
        "due_payments_limit": duePaymentsLimit,
        "due_payments": duePayments,
      };
}

class TransactionHistory {
  dynamic id;
  dynamic userId;
  dynamic amount;
  dynamic totalAmount;
  dynamic vehicleId;
  dynamic type;
  Vehicle? vehicle;

  TransactionHistory({
    this.id,
    this.userId,
    this.amount,
    this.totalAmount,
    this.vehicleId,
    this.type,
    this.vehicle,
  });

  factory TransactionHistory.fromJson(Map<String, dynamic> json) =>
      TransactionHistory(
        id: json["id"],
        userId: json["user_id"],
        amount: json["amount"],
        totalAmount: json["total_amount"],
        vehicleId: json["vehicle_id"],
        type: json["type"],
        vehicle:
            json["vehicle"] == null ? null : Vehicle.fromJson(json["vehicle"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "amount": amount,
        "vehicle_id": vehicleId,
        "type": type,
        "vehicle": vehicle!.toJson(),
      };
}

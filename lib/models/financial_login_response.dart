// To parse this JSON data, do
//
//     final loginResponse = loginResponseFromJson(jsonString);

import 'dart:convert';

FinancialLoginResponse financialLoginResponseFromJson(String str) =>
    FinancialLoginResponse.fromJson(json.decode(str));

String financialLoginResponseToJson(FinancialLoginResponse data) =>
    json.encode(data.toJson());

class FinancialLoginResponse {
  dynamic success;
  LoginData loginData;
  dynamic message;

  FinancialLoginResponse({
    this.success,
    required this.loginData,
    this.message,
  });

  factory FinancialLoginResponse.fromJson(Map<String, dynamic> json) =>
      FinancialLoginResponse(
        success: json["success"],
        loginData: LoginData.fromJson(json["data"]),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": loginData.toJson(),
        "message": message,
      };
}

class LoginData {
  dynamic error;
  dynamic success;

  LoginData({
    this.error,
    this.success,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) => LoginData(
        error: json["error"],
        success: json["success"],
      );

  Map<String, dynamic> toJson() => {
        "error": error,
        "success": success,
      };
}

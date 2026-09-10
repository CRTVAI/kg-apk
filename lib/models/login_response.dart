// To parse this JSON data, do
//
//     final loginResponse = loginResponseFromJson(jsonString);

import 'dart:convert';

LoginResponse loginResponseFromJson(String str) =>
    LoginResponse.fromJson(json.decode(str));

String loginResponseToJson(LoginResponse data) => json.encode(data.toJson());

class LoginResponse {
  dynamic success;
  Data data;
  dynamic message;

  LoginResponse({
    this.success,
    required this.data,
    this.message,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        success: json["success"],
        data: Data.fromJson(json["data"]),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data.toJson(),
        "message": message,
      };
}

class Data {
  dynamic token;
  AppUser user;

  Data({
    this.token,
    required this.user,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        token: json["token"],
        user: AppUser.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {
        "token": token,
        "user": user.toJson(),
      };
}

class AppUser {
  int id;
  dynamic name;
  dynamic email;
  dynamic emailVerifiedAt;
  dynamic surname;
  dynamic company;
  dynamic address;
  dynamic phone;
  dynamic fax;
  dynamic country;
  dynamic levelId;
  dynamic adminLevelId;
  dynamic operatorLevelId;
  dynamic mainUserId;
  dynamic balance;
  dynamic role;
  UserLevel? userLevel;
  OperatorLevel? operatorLevel;

  AppUser({
    required this.id,
    this.name,
    required this.email,
    this.emailVerifiedAt,
    this.surname,
    this.company,
    this.address,
    this.phone,
    this.fax,
    this.country,
    this.levelId,
    this.adminLevelId,
    this.operatorLevelId,
    this.mainUserId,
    this.balance,
    this.role,
    this.userLevel,
    this.operatorLevel,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        emailVerifiedAt: json["email_verified_at"],
        surname: json["surname"],
        company: json["company"],
        address: json["address"],
        phone: json["phone"],
        fax: json["fax"],
        country: json["country"],
        levelId: json["level_id"],
        adminLevelId: json["admin_level_id"],
        operatorLevelId: json["operator_level_id"],
        mainUserId: json["main_user_id"],
        balance: json["balance"],
        role: json["role"],
        userLevel: json["user_level"] == null
            ? null
            : UserLevel.fromJson(json["user_level"]),
        operatorLevel: json["operator_level"] == null
            ? null
            : OperatorLevel.fromJson(json["operator_level"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "email_verified_at": emailVerifiedAt,
        "surname": surname,
        "company": company,
        "address": address,
        "phone": phone,
        "fax": fax,
        "country": country,
        "level_id": levelId,
        "admin_level_id": adminLevelId,
        "operator_level_id": operatorLevelId,
        "main_user_id": mainUserId,
        "balance": balance,
        "role": role,
        "user_level": userLevel!.toJson(),
        "operator_level": operatorLevel!.toJson(),
      };

  @override
  String toString() {
    return '${name}';
  }
}

class UserLevel {
  int id;
  dynamic name;
  dynamic duePaymentLimit;
  dynamic companyFee;
  dynamic deletedAt;
  dynamic createdAt;
  dynamic updatedAt;

  UserLevel({
    required this.id,
    required this.name,
    required this.duePaymentLimit,
    required this.companyFee,
    required this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserLevel.fromJson(Map<String, dynamic> json) => UserLevel(
        id: json["id"],
        name: json["name"],
        duePaymentLimit: json["due_payment_limit"],
        companyFee: json["company_fee"],
        deletedAt: json["deleted_at"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "due_payment_limit": duePaymentLimit,
        "company_fee": companyFee,
        "deleted_at": deletedAt,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}

class OperatorLevel {
  dynamic id;
  dynamic name;
  dynamic access;

  OperatorLevel({
    required this.id,
    required this.name,
    required this.access,
  });

  factory OperatorLevel.fromJson(Map<String, dynamic> json) =>
      OperatorLevel(id: json["id"], name: json["name"], access: json["access"]);

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "access": access,
      };
}
